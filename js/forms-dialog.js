import { esc, options, formDialog, confirmDialog, toast, errorMessage } from './ui.js';
import { QUESTION_TYPES, FIELDS_FOR_TYPE, questionType, loadProjectForms, saveForm, deleteForm, formLink, newQuestionKey } from './forms.js';

// A project's Forms dialog (Forms button on the project page): its forms,
// with Open, Copy link, Edit and Delete, and + New form.
// page: { campaign, fields, sections }; team: people who can be assigned.
export function openFormsDialog(page, team) {
  const { campaign } = page;
  let forms = [];
  const dialog = formDialog({
    title: `Forms in ${campaign.name}`,
    submitLabel: 'Done',
    body: `
      <p class="muted small">A form lets anyone at DSD send a request to this project, even if they can't see it. Each one sent becomes a task here.
        Every form is listed under <a href="#/forms">Forms</a> in the menu, and has its own link to share.</p>
      <div data-form-list><p class="muted">Loading forms…</p></div>
      <button class="btn btn-small" type="button" data-new-form>+ New form</button>`,
    onSubmit: () => {},
  });
  dialog.classList.add('dialog-wide');
  dialog.querySelector('.dialog-footer [data-close]').hidden = true;
  const list = dialog.querySelector('[data-form-list]');

  const refresh = async () => {
    try {
      forms = await loadProjectForms(campaign.id);
    } catch (error) {
      list.innerHTML = `<p class="form-error">${esc(errorMessage(error))}</p>`;
      return;
    }
    list.innerHTML = forms.length ? `<ul class="field-list">${forms.map(f => `
      <li data-id="${esc(f.id)}">
        <span class="field-list-name"><strong>${esc(f.name)}</strong>
          <span class="muted small">${f.active ? 'Open' : 'Closed: nobody can send it'} · ${(f.questions || []).length + 1} questions</span></span>
        <a class="btn btn-ghost btn-small" href="#/forms/${esc(f.id)}" data-open>Open</a>
        <button class="btn btn-ghost btn-small" type="button" data-copy>Copy link</button>
        <button class="btn btn-ghost btn-small" type="button" data-edit>Edit</button>
        <button class="btn btn-ghost btn-small" type="button" data-delete>Delete</button>
      </li>`).join('')}</ul>` : '<p class="muted">No forms yet.</p>';
  };

  list.addEventListener('click', async event => {
    const button = event.target.closest('button, a');
    const form = forms.find(f => f.id === button?.closest('[data-id]')?.dataset.id);
    if (!form) return;
    if (button.matches('[data-open]')) dialog.close();
    if (button.matches('[data-copy]')) {
      try {
        await navigator.clipboard.writeText(formLink(form.id));
        toast('Link copied');
      } catch { toast(formLink(form.id)); }
    }
    if (button.matches('[data-edit]')) openFormEditor(page, team, form, refresh);
    if (button.matches('[data-delete]')) {
      const ok = await confirmDialog({
        title: 'Delete form?',
        message: `“${form.name}” will stop working for everyone. Tasks already sent with it stay in the project.`,
        confirmLabel: 'Delete', danger: true,
      });
      if (!ok) return;
      try {
        await deleteForm(form.id);
        toast('Form deleted');
      } catch (error) {
        toast(errorMessage(error), 'error');
      }
      refresh();
    }
  });
  dialog.querySelector('[data-new-form]').addEventListener('click', () => openFormEditor(page, team, null, refresh));
  refresh();
}

// Make or edit one form
function openFormEditor(page, team, form, onSaved) {
  const { campaign, fields, sections } = page;
  let questions = (form?.questions || []).map(q => ({ ...q }));
  const personFields = fields.filter(f => f.type === 'person');
  // Where an answer of each type can go: the description, the due date
  // (dates), or a project field of the same kind
  const targetsFor = type => ({
    text: 'The description',
    ...(type === 'date' ? { due_date: 'The due date' } : {}),
    ...Object.fromEntries(fields.filter(f => FIELDS_FOR_TYPE[type].includes(f.type))
      .map(f => [`field:${f.id}`, `The ${f.name} field`])),
  });
  const targetOf = q => (q.target === 'field' ? `field:${q.field_id}` : q.target);

  const dialog = formDialog({
    title: form ? `Edit “${form.name}”` : 'New form',
    submitLabel: form ? 'Save form' : 'Create form',
    body: `
      <label class="field"><span>Name</span>
        <input name="name" required maxlength="120" value="${esc(form?.name || '')}" placeholder="For example: Marketing request"></label>
      <label class="field"><span>Introduction (optional)</span>
        <textarea name="intro" rows="3" maxlength="4000" placeholder="What this form is for, and what happens after someone sends it">${esc(form?.intro || '')}</textarea></label>
      <div class="field-row">
        <label class="field"><span>New requests go to section</span>
          <select name="section_id"><option value="">No section</option>${options(Object.fromEntries(sections.map(s => [s.id, s.name])), form?.section_id || '')}</select></label>
        <label class="field"><span>And are assigned to</span>
          <select name="assignee_id"><option value="">Nobody yet</option>${options(Object.fromEntries(team.map(p => [p.id, p.name])), form?.assignee_id || '')}</select></label>
      </div>
      ${personFields.length ? `<label class="field"><span>Fill this person field with whoever sends it (optional)</span>
        <select name="requestor_field_id"><option value="">Don't</option>${options(Object.fromEntries(personFields.map(f => [f.id, f.name])), form?.requestor_field_id || '')}</select></label>` : ''}
      <label class="checkbox-line"><input type="checkbox" name="active" ${form?.active === false ? '' : 'checked'}> Open: people can send it</label>
      <fieldset class="field form-questions">
        <legend>Questions</legend>
        <label class="field"><span>1. Becomes the task's title (always required)</span>
          <input name="title_label" required maxlength="200" value="${esc(form?.title_label || 'What do you need?')}"></label>
        <div data-questions></div>
        <button class="btn btn-small" type="button" data-add-question>+ Add question</button>
      </fieldset>`,
    onSubmit: async el => {
      readQuestions();
      const name = el.elements.name.value.trim();
      const titleLabel = el.elements.title_label.value.trim();
      if (!name) return 'Give the form a name.';
      if (!titleLabel) return 'Write the first question, the one that becomes the task title.';
      const blank = questions.findIndex(q => !q.label);
      if (blank !== -1) return `Question ${blank + 2} needs its wording.`;
      const noChoices = questions.findIndex(q => ['choice', 'multi'].includes(q.type) && q.target !== 'field' && !(q.options || []).length);
      if (noChoices !== -1) return `Question ${noChoices + 2} needs its choices, one per line.`;
      const values = {
        campaign_id: campaign.id, name, title_label: titleLabel,
        intro: el.elements.intro.value.trim() || null,
        section_id: el.elements.section_id.value || null,
        assignee_id: el.elements.assignee_id.value || null,
        requestor_field_id: el.elements.requestor_field_id?.value || null,
        active: el.elements.active.checked,
        questions,
      };
      try {
        await saveForm(values, form?.id);
      } catch (error) {
        return errorMessage(error);
      }
      toast(form ? 'Form saved' : `${name} created`);
      onSaved();
    },
  });
  dialog.classList.add('dialog-wide');
  const box = dialog.querySelector('[data-questions]');

  // Keep what's typed before redrawing
  function readQuestions() {
    questions = [...box.querySelectorAll('[data-q]')].map(row => {
      const target = row.querySelector('[data-target]').value;
      const isField = target.startsWith('field:');
      const type = row.querySelector('[data-type]').value;
      const options = [...new Set(row.querySelector('[data-options]').value.split('\n').map(s => s.trim()).filter(Boolean))];
      return {
        key: row.dataset.q,
        label: row.querySelector('[data-label]').value.trim(),
        help: row.querySelector('[data-help]').value.trim() || undefined,
        type,
        target: isField ? 'field' : target,
        ...(isField ? { field_id: target.slice(6) } : {}),
        ...(!isField && ['choice', 'multi'].includes(type) ? { options } : {}),
        required: row.querySelector('[data-required]').checked,
      };
    });
  }

  function draw() {
    box.innerHTML = questions.map((q, i) => {
      const type = questionType(q, fields);
      const targets = targetsFor(type);
      const target = targetOf(q) in targets ? targetOf(q) : 'text';
      const ownChoices = ['choice', 'multi'].includes(type) && !target.startsWith('field:');
      return `
      <div class="form-question" data-q="${esc(q.key)}">
        <div class="form-question-top">
          <strong class="muted">${i + 2}.</strong>
          <input data-label maxlength="200" value="${esc(q.label || '')}" placeholder="The question" aria-label="Question ${i + 2}">
          <button class="icon-btn" type="button" data-up ${i === 0 ? 'disabled' : ''} aria-label="Move question ${i + 2} up" title="Move up">↑</button>
          <button class="icon-btn" type="button" data-down ${i === questions.length - 1 ? 'disabled' : ''} aria-label="Move question ${i + 2} down" title="Move down">↓</button>
          <button class="icon-btn" type="button" data-remove aria-label="Remove question ${i + 2}" title="Remove">×</button>
        </div>
        <div class="form-question-details">
          <label class="field-inline"><span class="muted small">Type</span>
            <select data-type>${options(QUESTION_TYPES, type)}</select></label>
          <label class="field-inline"><span class="muted small">Answer goes to</span>
            <select data-target>${options(targets, target)}</select></label>
          <label class="checkbox-line"><input type="checkbox" data-required ${q.required ? 'checked' : ''}> Required</label>
        </div>
        <input data-help maxlength="300" value="${esc(q.help || '')}" placeholder="Help text (optional)" aria-label="Help text for question ${i + 2}">
        <label class="field" ${ownChoices ? '' : 'hidden'}><span class="muted small">Choices, one per line</span>
          <textarea data-options rows="3" placeholder="Option 1&#10;Option 2">${esc((q.options || []).join('\n'))}</textarea></label>
        ${target.startsWith('field:') && ['choice', 'multi'].includes(type) ? '<p class="muted small">Uses the choices (and colours) of that field. Change them in Fields.</p>' : ''}
      </div>`;
    }).join('') || '<p class="muted small">Add the other things you need to know: text, a single or multi-select, a date or a number. Answers go into the description, the due date or one of the project\'s fields.</p>';
  }

  // A new type or destination changes what the question offers
  box.addEventListener('change', event => {
    if (event.target.matches('[data-type], [data-target]')) {
      readQuestions();
      draw();
    }
  });
  box.addEventListener('click', event => {
    const button = event.target.closest('button');
    const row = button?.closest('[data-q]');
    if (!row) return;
    readQuestions();
    const i = questions.findIndex(q => q.key === row.dataset.q);
    if (button.matches('[data-remove]')) questions.splice(i, 1);
    if (button.matches('[data-up]') && i > 0) [questions[i - 1], questions[i]] = [questions[i], questions[i - 1]];
    if (button.matches('[data-down]') && i < questions.length - 1) [questions[i + 1], questions[i]] = [questions[i], questions[i + 1]];
    draw();
  });
  dialog.querySelector('[data-add-question]').addEventListener('click', () => {
    readQuestions();
    questions.push({ key: newQuestionKey(), label: '', type: 'text', target: 'text', required: false });
    draw();
    box.querySelector('[data-q]:last-child [data-label]')?.focus();
  });
  draw();
}
