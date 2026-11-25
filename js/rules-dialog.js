import { esc, options, formDialog, confirmDialog, toast, errorMessage, TASK_STATUSES } from './ui.js';
import { state } from './state.js';
import { fieldInput, readFieldInput } from './fields.js';
import { loadSections } from './tasks.js';
import { loadProjectForms } from './forms.js';
import { TRIGGERS, CONDITIONS, ACTIONS, loadRules, saveRule, deleteRule, copyTargets, describeRule } from './rules.js';

// A project's Rules dialog (Rules button on the project page): its rules in
// words, each with an On switch, Edit and Delete, and + New rule.
// page: { campaign, fields, sections }; team: people who can be assigned.
export async function openRulesDialog(page, team) {
  const { campaign } = page;
  let rules = [];
  let forms = [];
  let projects = [];
  const dialog = formDialog({
    title: `Rules in ${campaign.name}`,
    submitLabel: 'Done',
    body: `
      <p class="muted small">Rules do routine work for you: <strong>when</strong> something happens to a task in this project,
        <strong>if</strong> some things are true, <strong>then</strong> Atlas does what you choose. Rules don't set off other rules.</p>
      <div data-rule-list><p class="muted">Loading rules…</p></div>
      <button class="btn btn-small" type="button" data-new-rule>+ New rule</button>`,
    onSubmit: () => {},
  });
  dialog.classList.add('dialog-wide');
  dialog.querySelector('.dialog-footer [data-close]').hidden = true;
  const list = dialog.querySelector('[data-rule-list]');
  const context = () => ({ fields: page.fields, sections: page.sections, forms, projects });

  const refresh = async () => {
    try {
      [rules, forms, projects] = await Promise.all([loadRules(campaign.id), loadProjectForms(campaign.id), copyTargets(campaign.id)]);
    } catch (error) {
      list.innerHTML = `<p class="form-error">${esc(errorMessage(error))}</p>`;
      return;
    }
    list.innerHTML = rules.length ? `<ul class="field-list rule-list">${rules.map(r => `
      <li data-id="${esc(r.id)}">
        <span class="field-list-name"><strong>${esc(r.name)}</strong><span class="muted small">${esc(describeRule(r, context()))}</span></span>
        <label class="checkbox-line small" title="Switch this rule on or off"><input type="checkbox" data-active ${r.active ? 'checked' : ''}> On</label>
        <button class="btn btn-ghost btn-small" type="button" data-edit>Edit</button>
        <button class="btn btn-ghost btn-small" type="button" data-delete>Delete</button>
      </li>`).join('')}</ul>` : '<p class="muted">No rules yet.</p>';
  };

  list.addEventListener('change', async event => {
    const rule = rules.find(r => r.id === event.target.closest('[data-id]')?.dataset.id);
    if (!rule || !event.target.matches('[data-active]')) return;
    try {
      await saveRule({ active: event.target.checked }, rule.id);
      toast(event.target.checked ? `“${rule.name}” is on` : `“${rule.name}” is off`);
    } catch (error) {
      toast(errorMessage(error), 'error');
    }
    refresh();
  });
  list.addEventListener('click', async event => {
    const button = event.target.closest('button');
    const rule = rules.find(r => r.id === button?.closest('[data-id]')?.dataset.id);
    if (!rule) return;
    if (button.matches('[data-edit]')) openRuleEditor(page, team, { forms, projects }, rule, refresh);
    if (button.matches('[data-delete]')) {
      const ok = await confirmDialog({ title: 'Delete rule?', message: `“${rule.name}” will stop working. What it already did stays.`, confirmLabel: 'Delete', danger: true });
      if (!ok) return;
      try {
        await deleteRule(rule.id);
        toast('Rule deleted');
      } catch (error) {
        toast(errorMessage(error), 'error');
      }
      refresh();
    }
  });
  dialog.querySelector('[data-new-rule]').addEventListener('click', () => openRuleEditor(page, team, { forms, projects }, null, refresh));
  refresh();
}

// Make or edit one rule
function openRuleEditor(page, team, { forms, projects }, rule, onSaved) {
  const { campaign, fields, sections } = page;
  const draft = {
    trigger: { type: 'task_added', ...(rule?.trigger || {}) },
    conditions: (rule?.conditions || []).map(c => ({ ...c })),
    actions: (rule?.actions || [{ type: 'assign' }]).map(a => ({ ...a })),
  };
  const everyone = state.people.filter(p => p.active && p.role !== 'director');
  const targetSections = {};   // other projects' sections, loaded when picked
  const field = id => fields.find(f => f.id === id);
  const sectionOpts = (value, empty) => `${empty ? `<option value="">${esc(empty)}</option>` : ''}${options(Object.fromEntries(sections.map(s => [s.id, s.name])), value || '')}`;
  const fieldOpts = (value, types) => options(Object.fromEntries(fields.filter(f => !types || types.includes(f.type)).map(f => [f.id, f.name])), value || '');
  const peopleOpts = (list, value, empty) => `${empty ? `<option value="">${esc(empty)}</option>` : ''}${options(Object.fromEntries(list.map(p => [p.id, p.name])), value || '')}`;
  // A field's value box; empty means "any value" in a trigger or condition
  const valueBox = (fieldId, value) => {
    const f = field(fieldId);
    return f ? `<div class="rule-value" data-value-of="${esc(f.id)}">${fieldInput(f, value ?? null)}</div>` : '';
  };

  const dialog = formDialog({
    title: rule ? `Edit “${rule.name}”` : 'New rule',
    submitLabel: rule ? 'Save rule' : 'Create rule',
    body: `
      <label class="field"><span>Name</span>
        <input name="name" required maxlength="120" value="${esc(rule?.name || '')}" placeholder="For example: Web requests go to Ángel"></label>
      <fieldset class="field rule-part"><legend>When</legend><div data-when></div></fieldset>
      <fieldset class="field rule-part"><legend>Only if <span class="muted small">(optional)</span></legend>
        <div data-ifs></div>
        <button class="btn btn-small btn-ghost" type="button" data-add-if>+ Add condition</button></fieldset>
      <fieldset class="field rule-part"><legend>Then</legend>
        <div data-thens></div>
        <button class="btn btn-small btn-ghost" type="button" data-add-then>+ Add action</button></fieldset>
      <label class="checkbox-line"><input type="checkbox" name="active" ${rule?.active === false ? '' : 'checked'}> On</label>`,
    onSubmit: async el => {
      read();
      const name = el.elements.name.value.trim();
      if (!name) return 'Give the rule a name.';
      if (draft.trigger.type === 'field_changed' && !draft.trigger.field_id) return 'Choose which field the rule watches.';
      if (!draft.actions.length) return 'Add at least one action.';
      const missing = draft.actions.find(a => (a.type === 'section' && !a.section_id) || (a.type === 'field' && !a.field_id)
        || (a.type === 'copy' && !a.campaign_id) || (a.type === 'week_section' && !a.source)
        || (a.type === 'comment' && !a.text) || (a.type === 'subtasks' && !(a.titles || []).length));
      if (missing) return `Finish the action “${ACTIONS[missing.type]}”.`;
      try {
        await saveRule({ campaign_id: campaign.id, name, active: el.elements.active.checked, ...draft }, rule?.id);
      } catch (error) {
        return errorMessage(error);
      }
      toast(rule ? 'Rule saved' : `${name} created`);
      onSaved();
    },
  });
  dialog.classList.add('dialog-wide');
  const when = dialog.querySelector('[data-when]');
  const ifs = dialog.querySelector('[data-ifs]');
  const thens = dialog.querySelector('[data-thens]');

  // The value typed for the field picked in this row (none if the field was
  // just changed). Triggers and conditions check one choice of a multi-select.
  const readValue = (row, fieldId, { single = false } = {}) => {
    const box = row.querySelector('[data-value-of]');
    if (!box || box.dataset.valueOf !== fieldId) return undefined;
    const f = field(fieldId);
    const value = readFieldInput(f, box.querySelector('[data-field-id]'));
    if (value == null || (Array.isArray(value) && !value.length)) return undefined;
    return single && f.type === 'multi' ? value[0] : value;
  };
  const pick = (row, name) => row.querySelector(`[data-pick="${name}"]`)?.value || undefined;

  // Everything typed so far, back into the draft
  function read() {
    const w = when.querySelector('[data-row]');
    const t = { type: pick(w, 'type') };
    if (['task_added', 'section_changed'].includes(t.type) && pick(w, 'section')) t.section_id = pick(w, 'section');
    if (t.type === 'field_changed') {
      t.field_id = pick(w, 'field');
      const v = readValue(w, t.field_id, { single: true });
      if (v !== undefined) t.value = v;
    }
    if (t.type === 'assigned' && pick(w, 'person')) t.person_id = pick(w, 'person');
    draft.trigger = t;
    draft.conditions = [...ifs.querySelectorAll('[data-row]')].map(row => {
      const c = { type: pick(row, 'type') };
      if (c.type === 'field') {
        c.field_id = pick(row, 'field');
        const v = readValue(row, c.field_id, { single: true });
        if (v !== undefined) c.value = v;
      }
      if (c.type === 'section') c.section_id = pick(row, 'section') || null;
      if (c.type === 'form') c.form_id = pick(row, 'form');
      return c;
    });
    draft.actions = [...thens.querySelectorAll('[data-row]')].map(row => {
      const a = { type: pick(row, 'type') };
      if (a.type === 'assign') a.person_id = pick(row, 'person') || null;
      if (a.type === 'section') a.section_id = pick(row, 'section');
      if (a.type === 'field') {
        a.field_id = pick(row, 'field');
        const v = readValue(row, a.field_id);
        a.value = v === undefined ? null : v;
      }
      if (a.type === 'due') a.days = Math.max(0, Math.round(Number(row.querySelector('[data-pick="days"]')?.value || 0)));
      if (a.type === 'status') a.status = pick(row, 'status') || 'done';
      if (a.type === 'comment') a.text = row.querySelector('[data-pick="text"]')?.value.trim() || '';
      if (a.type === 'subtasks') a.titles = (row.querySelector('[data-pick="titles"]')?.value || '').split('\n').map(s => s.trim()).filter(Boolean);
      if (a.type === 'week_section') a.source = pick(row, 'source');
      if (a.type === 'copy') {
        a.campaign_id = pick(row, 'project');
        a.section_id = pick(row, 'target-section') || null;
        a.person_id = pick(row, 'person') || null;
      }
      return a;
    });
  }

  function drawWhen() {
    const t = draft.trigger;
    let detail = '';
    if (['task_added', 'section_changed'].includes(t.type)) {
      detail = `<select data-pick="section" aria-label="Section">${sectionOpts(t.section_id, t.type === 'task_added' ? 'anywhere in the project' : 'any section')}</select>`;
    }
    if (t.type === 'field_changed') {
      const f = t.field_id || fields[0]?.id;
      detail = fields.length ? `<select data-pick="field" aria-label="Field">${fieldOpts(f)}</select>
        <span class="muted small">to (leave empty for any change)</span>${valueBox(f, t.value)}` : '<span class="muted small">This project has no fields yet. Add some with Fields.</span>';
    }
    if (t.type === 'assigned') detail = `<select data-pick="person" aria-label="Person">${peopleOpts(team, t.person_id, 'anyone')}</select>`;
    when.innerHTML = `<div class="rule-row" data-row>
      <select data-pick="type" aria-label="When">${options(TRIGGERS, t.type)}</select>${detail}</div>`;
  }

  function drawIfs() {
    ifs.innerHTML = draft.conditions.map((c, i) => {
      let detail = '';
      if (c.type === 'field') {
        const f = c.field_id || fields[0]?.id;
        detail = fields.length ? `<select data-pick="field" aria-label="Field">${fieldOpts(f)}</select>
          <span class="muted small">is (leave empty for any value)</span>${valueBox(f, c.value)}` : '<span class="muted small">No fields yet.</span>';
      }
      if (c.type === 'section') detail = `<select data-pick="section" aria-label="Section">${sectionOpts(c.section_id, 'No section')}</select>`;
      if (c.type === 'form') detail = forms.length
        ? `<select data-pick="form" aria-label="Form">${options(Object.fromEntries(forms.map(f => [f.id, f.name])), c.form_id || '')}</select>`
        : '<span class="muted small">This project has no forms yet.</span>';
      return `<div class="rule-row" data-row data-i="${i}">
        <select data-pick="type" aria-label="Condition">${options(CONDITIONS, c.type)}</select>${detail}
        <button class="icon-btn" type="button" data-remove aria-label="Remove this condition" title="Remove">×</button></div>`;
    }).join('') || '<p class="muted small">Always, when the trigger happens.</p>';
  }

  function drawThens() {
    thens.innerHTML = draft.actions.map((a, i) => {
      let detail = '';
      switch (a.type) {
        case 'assign': detail = `<select data-pick="person" aria-label="Person">${peopleOpts(team, a.person_id, 'Nobody (unassign)')}</select>`; break;
        case 'section': detail = `<select data-pick="section" aria-label="Section">${sectionOpts(a.section_id)}</select>`; break;
        case 'field': {
          const f = a.field_id || fields[0]?.id;
          detail = fields.length ? `<select data-pick="field" aria-label="Field">${fieldOpts(f)}</select>
            <span class="muted small">to</span>${valueBox(f, a.value)}` : '<span class="muted small">No fields yet.</span>';
          break;
        }
        case 'due': detail = `<span class="muted small">in</span><input type="number" min="0" max="365" data-pick="days" value="${esc(a.days ?? 3)}" aria-label="Days" class="rule-days"><span class="muted small">days from when the rule runs</span>`; break;
        case 'status': detail = `<select data-pick="status" aria-label="Status">${options(TASK_STATUSES, a.status || 'done')}</select>`; break;
        case 'comment': detail = `<textarea data-pick="text" rows="2" maxlength="2000" placeholder="What the comment says">${esc(a.text || '')}</textarea>`; break;
        case 'subtasks': detail = `<textarea data-pick="titles" rows="3" placeholder="One subtask per line">${esc((a.titles || []).join('\n'))}</textarea>`; break;
        case 'week_section': {
          const dates = fields.filter(f => f.type === 'date');
          detail = `<span class="muted small">by</span><select data-pick="source" aria-label="Date">${options({ due: 'Due date', ...Object.fromEntries(dates.map(f => [f.id, f.name])) }, a.source || 'due')}</select>`;
          break;
        }
        case 'copy': {
          const loaded = a.campaign_id ? targetSections[a.campaign_id] : [];
          detail = `<select data-pick="project" aria-label="Project"><option value="">Choose a project</option>${options(Object.fromEntries(projects.map(p => [p.id, p.name])), a.campaign_id || '')}</select>
            ${a.campaign_id ? `<select data-pick="target-section" aria-label="Section there">${loaded
              ? `<option value="">No section</option>${options(Object.fromEntries(loaded.map(s => [s.id, s.name])), a.section_id || '')}`
              : '<option value="">Loading sections…</option>'}</select>` : ''}
            <select data-pick="person" aria-label="Assign the copy to">${peopleOpts(everyone, a.person_id, 'Copy unassigned')}</select>`;
          if (a.campaign_id && !loaded) {
            loadSections(a.campaign_id).then(list => { targetSections[a.campaign_id] = list; read(); drawThens(); }).catch(() => { targetSections[a.campaign_id] = []; });
          }
          break;
        }
        default: break;
      }
      return `<div class="rule-row" data-row data-i="${i}">
        <select data-pick="type" aria-label="Action">${options(ACTIONS, a.type)}</select>${detail}
        <button class="icon-btn" type="button" data-remove aria-label="Remove this action" title="Remove">×</button></div>`;
    }).join('') || '<p class="muted small">Add what Atlas should do.</p>';
  }

  const drawAll = () => { drawWhen(); drawIfs(); drawThens(); };

  // A new type, field or project changes the boxes next to it
  dialog.addEventListener('change', event => {
    if (event.target.matches('[data-pick="type"], [data-pick="field"], [data-pick="project"]')) {
      read();
      drawAll();
    }
  });
  dialog.addEventListener('click', event => {
    const button = event.target.closest('button');
    if (!button) return;
    if (button.matches('[data-remove]')) {
      read();
      const row = button.closest('[data-row]');
      const listName = row.parentElement === ifs ? 'conditions' : 'actions';
      draft[listName].splice(Number(row.dataset.i), 1);
      drawAll();
    }
    if (button.matches('[data-add-if]')) { read(); draft.conditions.push({ type: 'field' }); drawAll(); }
    if (button.matches('[data-add-then]')) { read(); draft.actions.push({ type: 'assign' }); drawAll(); }
  });
  drawAll();
}
