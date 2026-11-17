import { esc, options, formDialog, confirmDialog, toast, errorMessage } from './ui.js';
import {
  FIELD_TYPES, FIELD_SETS, loadFields, createField, updateField, deleteField, addFieldSet, settingsFromForm,
} from './fields.js';

// The project's Fields dialog: its fields in order (move, edit, delete), a
// button to add one, and the ready-made sets. countValues(fieldId) says how
// many tasks have a value, for the delete warning.
export function openFieldsDialog(campaign, { countValues = () => 0, onChanged = () => {} } = {}) {
  let fields = [];
  const dialog = formDialog({
    title: `Fields in ${campaign.name}`,
    submitLabel: 'Done',
    body: `
      <p class="muted small">Fields add your own information to every task in this project, such as an amount, a date or a status of your own.
        They show in each task's panel and as columns in the List view.</p>
      <div data-field-list><p class="muted">Loading fields…</p></div>
      <button class="btn btn-small" type="button" data-add-field>+ Add field</button>
      <h3 class="fields-sets-title">Ready-made sets</h3>
      <p class="muted small">Add a whole set in one go. Fields this project already has are skipped, and you can edit any of them afterwards.</p>
      <div class="field-sets">
        ${Object.entries(FIELD_SETS).map(([key, set]) => `
          <div class="field-set">
            <div><strong>${esc(set.name)}</strong><span class="muted small">${esc(set.description)}</span>
              <span class="muted small">${esc(set.fields().map(f => f.name).join(' · '))}</span></div>
            <button class="btn btn-small" type="button" data-add-set="${esc(key)}">Add</button>
          </div>`).join('')}
      </div>`,
    onSubmit: () => {},
  });
  dialog.classList.add('dialog-wide');
  dialog.querySelector('.dialog-footer [data-close]').hidden = true;
  const list = dialog.querySelector('[data-field-list]');

  const refresh = async () => {
    try {
      fields = await loadFields(campaign.id);
    } catch (error) {
      list.innerHTML = `<p class="form-error">${esc(errorMessage(error))}</p>`;
      return;
    }
    draw();
    onChanged(fields);
  };

  const describe = f => {
    const extra = f.type === 'choice' || f.type === 'multi' ? ` · ${(f.settings?.options || []).length} choices`
      : f.type === 'money' ? ` · ${(f.settings?.currencies || []).join(', ')}`
      : f.type === 'number' && f.settings?.unit ? ` · in ${f.settings.unit}` : '';
    return `${FIELD_TYPES[f.type] || f.type}${extra}`;
  };

  const draw = () => {
    list.innerHTML = fields.length ? `
      <ul class="field-list">${fields.map((f, i) => `
        <li data-id="${esc(f.id)}">
          <span class="field-list-name"><strong>${esc(f.name)}</strong><span class="muted small">${esc(describe(f))}</span></span>
          <button class="icon-btn" type="button" data-up ${i === 0 ? 'disabled' : ''} aria-label="Move ${esc(f.name)} up" title="Move up">↑</button>
          <button class="icon-btn" type="button" data-down ${i === fields.length - 1 ? 'disabled' : ''} aria-label="Move ${esc(f.name)} down" title="Move down">↓</button>
          <button class="btn btn-ghost btn-small" type="button" data-edit>Edit</button>
          <button class="btn btn-ghost btn-small" type="button" data-delete>Delete</button>
        </li>`).join('')}
      </ul>` : '<p class="muted">No fields yet. Add one, or add a ready-made set below.</p>';
  };

  list.addEventListener('click', async event => {
    const button = event.target.closest('button');
    const field = fields.find(f => f.id === button?.closest('li')?.dataset.id);
    if (!field) return;
    if (button.matches('[data-edit]')) openFieldForm(campaign, fields, field, refresh);
    if (button.matches('[data-delete]')) {
      const count = countValues(field.id);
      const ok = await confirmDialog({
        title: `Delete “${field.name}”?`,
        message: count
          ? `It's filled in on ${count} task${count === 1 ? '' : 's'}; those values are deleted too. This can't be undone.`
          : 'No task has a value in it yet, so nothing else changes.',
        confirmLabel: 'Delete field',
        danger: true,
      });
      if (!ok) return;
      try {
        await deleteField(field.id);
        toast('Field deleted');
      } catch (error) {
        toast(errorMessage(error), 'error');
      }
      refresh();
    }
    if (button.matches('[data-up], [data-down]')) {
      const i = fields.indexOf(field);
      const j = i + (button.matches('[data-up]') ? -1 : 1);
      if (!fields[j]) return;
      [fields[i], fields[j]] = [fields[j], fields[i]];
      const changed = fields.filter((f, n) => f.position !== (n + 1) * 1000);
      fields.forEach((f, n) => { f.position = (n + 1) * 1000; });
      draw();
      try {
        await Promise.all(changed.map(f => updateField(f.id, { position: f.position })));
      } catch (error) {
        toast(errorMessage(error), 'error');
      }
      refresh();
    }
  });

  dialog.querySelector('[data-add-field]').addEventListener('click', () => openFieldForm(campaign, fields, null, refresh));
  dialog.querySelectorAll('[data-add-set]').forEach(button => button.addEventListener('click', async () => {
    const set = FIELD_SETS[button.dataset.addSet];
    button.disabled = true;
    try {
      const added = await addFieldSet(campaign.id, button.dataset.addSet, fields);
      toast(added ? `${set.name}: ${added} field${added === 1 ? '' : 's'} added` : `This project already has the ${set.name} fields`);
    } catch (error) {
      toast(errorMessage(error), 'error');
    } finally {
      button.disabled = false;
    }
    refresh();
  }));

  refresh();
}

// Add or edit one field. The type is fixed once a field exists.
function openFieldForm(campaign, fields, field, onSaved) {
  const lines = list => esc((list || []).join('\n'));
  const dialog = formDialog({
    title: field ? `Edit “${field.name}”` : 'Add field',
    submitLabel: field ? 'Save' : 'Add field',
    body: `
      <label class="field"><span>Name</span>
        <input name="name" required maxlength="80" value="${esc(field?.name || '')}" placeholder="For example: Invoice date"></label>
      <label class="field"><span>Type</span>
        <select name="type" ${field ? 'disabled' : ''}>${options(FIELD_TYPES, field?.type || 'text')}</select></label>
      ${field ? '<p class="muted small form-note">A field\'s type can\'t be changed. To use another type, add a new field.</p>' : ''}
      <label class="field" data-for="choice multi"><span>Choices, one per line</span>
        <textarea name="options" rows="6" placeholder="Pending&#10;Approved&#10;Done">${lines(field?.settings?.options)}</textarea></label>
      <label class="field" data-for="money"><span>Currencies, one per line (the first is the default)</span>
        <textarea name="currencies" rows="3">${lines(field?.settings?.currencies || ['€', 'US$', 'GBP'])}</textarea></label>
      <label class="field" data-for="number"><span>Unit (optional, for example h or days)</span>
        <input name="unit" maxlength="12" value="${esc(field?.settings?.unit || '')}"></label>`,
    onSubmit: async form => {
      const name = form.elements.name.value.trim();
      const type = field?.type || form.elements.type.value;
      if (!name) return 'Give the field a name.';
      if (fields.some(f => f.id !== field?.id && f.name.trim().toLowerCase() === name.toLowerCase())) {
        return 'This project already has a field with that name.';
      }
      const settings = settingsFromForm(type, form);
      if ((type === 'choice' || type === 'multi') && !settings.options.length) return 'Add at least one choice.';
      try {
        if (field) await updateField(field.id, { name, settings });
        else {
          const last = Math.max(0, ...fields.map(f => f.position));
          await createField({ campaign_id: campaign.id, name, type, settings, position: last + 1000 });
        }
      } catch (error) {
        return errorMessage(error);
      }
      toast(field ? 'Field saved' : `${name} added`);
      onSaved();
    },
  });
  // Only show the boxes the chosen type uses
  const typeSelect = dialog.querySelector('[name=type]');
  const showFor = () => dialog.querySelectorAll('[data-for]').forEach(box => {
    box.hidden = !box.dataset.for.split(' ').includes(typeSelect.value);
  });
  typeSelect.addEventListener('change', showFor);
  showFor();
}
