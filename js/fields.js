import { supabase } from './supabase.js';
import { announce } from './realtime.js';
import { state, personById } from './state.js';
import { esc, fmtDate } from './ui.js';

// Custom fields (must-have 5): each project chooses its own fields, like
// Asana's. Values belong to main tasks; subtasks go with their parent.
//
// Value shapes, by type:
//   text: "words"            number: 12.5             date: "2026-11-20"
//   money: { amount: 8610.01, currency: "€" }       choice: "Done"
//   multi: ["201.4 - COGS Lab", "Labour"]            person: "<person id>"
// Settings: { options: [...], colors: { option: colour } } for choice and
// multi (colours are CHOICE_COLORS keys, Asana's names); { currencies: [...] }
// for money; { unit: "h" } for number (optional).

export const FIELD_TYPES = {
  text: 'Text',
  number: 'Number',
  money: 'Money',
  date: 'Date',
  choice: 'Choice (pick one)',
  multi: 'Choice (pick several)',
  person: 'Person',
};

const PRIORITY = ['High', 'Medium', 'Low'];

// Ready-made sets, taken from the fields DSD really fills in on Asana
// (analysed 17 Nov 2026). Choices can be edited after adding a set.
export const FIELD_SETS = {
  invoices: {
    name: 'Invoices',
    description: 'Procurement\'s invoice control: amount, invoice date and number, payment, approval and accounting codes.',
    fields: () => [
      { name: 'Total amount', type: 'money', settings: { currencies: ['€', 'US$', 'GBP', 'AUD$', 'CAD$', 'R$', 'ZAR', 'RAND', 'BRL'] } },
      { name: 'Invoice date', type: 'date' },
      { name: 'Invoice nº', type: 'text' },
      { name: 'Invoice', type: 'choice', settings: { options: ['Available', 'Not available'] } },
      { name: 'Payment method', type: 'choice', settings: { options: ['Wire transfer', 'Direct Debit', 'Pleo', 'Bankinter -5371', 'Balance', 'Renting', 'Cash'] } },
      { name: 'Payment due', type: 'date' },
      { name: 'Finance payment', type: 'choice', settings: { options: ['Pending', 'Uploaded', 'Done', 'Info required'] } },
      { name: 'Signed', type: 'choice', settings: { options: ['Yes', 'No'] } },
      { name: 'Department', type: 'choice', settings: { options: ['1.0.0 - Education', '2.0.0 - Lab', '3.0.0 - Corporate'] } },
      { name: 'Sub-department', type: 'choice', settings: { options: ['1.1.0 - Education', '2.1.0 - Lab', '2.1.1 - PC', '2.1.2 - Delight', '3.1.0 - Corporate', '3.1.2 - Marketing'] } },
      { name: 'Departmental big line', type: 'choice', settings: { options: ['100 - COGS', '200 - Labour', '300 - General Expenses', '400 - Dedicated Expenses'] } },
      { name: 'P&L account', type: 'multi', settings: { options: ['201.1 - COGS Growth', '1.Clinics*', '1.3 Planning Center', '1.3.1-Planning', '1.3.2-Lab', 'Balance', '104-Other Income', '201.2 - COGS Delight', '06-Labour', '201.3 - COGS Planning Center', '07-Travels and Meals', '201.4 - COGS Lab', '201.5 - COGS Other Income', 'Labour', '08-Professional Fees', '09-Marketing and Advertising', '202.1 - Labour Growth', '202.2 - Labour Marketing', '10-Office', '11-Information Technology', '202.3 - Labour Planning Center', '12-Research and Development*', '202.4 - Labour Corporate', '202.5 - Labour Delight ROW', '14-Miscellanous', '202.6 - Labour AMEX', '203.1 - Travels & Meals Growth', '203.2 - Travels & Meals Marketing', '203.3 - Travels & Meals Planning Center', '204.4 - Travels & Meals Lab', '203.5 Travels & Meals Corporate', '203.6 - Travels & Meals ROW', '203.7 - Travels & Meals AMEX', '204.1 - Professional Fees Spain', '204.2 - Professional Fees USA', '205.0 - Marketing & Advertising', '206.1 - Office Spain', '206.2 - Office USA', '207.0 - Information Technology', '208.0 - Research and Develpment', '209.1 - Bank and Financial fees SPAIN', '209.2 - Bank and Financial Fees USA', '0000 - Balance Adjustments', '210.0 Miscellanous', 'Financing'] } },
    ],
  },
  requests: {
    name: 'Requests',
    description: 'Requests from other teams: who asked, for which department, how urgent and where it stands.',
    fields: () => [
      { name: 'Requestor', type: 'person' },
      { name: 'Requesting department', type: 'choice', settings: { options: state.departments.map(d => d.name).sort() } },
      { name: 'Request status', type: 'choice', settings: { options: ['Requested', 'Needs info', 'Approved', 'In progress', 'Done', 'Rejected'] } },
      { name: 'Priority', type: 'choice', settings: { options: PRIORITY } },
    ],
  },
  bugs: {
    name: 'Bug tracker',
    description: 'Website or system bugs: who reported it, when, where, how urgent and where the fix stands.',
    fields: () => [
      { name: 'Reported by', type: 'person' },
      { name: 'Date reported', type: 'date' },
      { name: 'URL / page', type: 'text' },
      { name: 'Bug status', type: 'choice', settings: { options: ['Reported', 'Working on fixing', 'Closed'] } },
      { name: 'Priority', type: 'choice', settings: { options: PRIORITY } },
    ],
  },
  estimate: {
    name: 'Estimate',
    description: 'How many hours a task should take, to compare with the hours logged on it.',
    fields: () => [
      { name: 'Estimated time', type: 'number', settings: { unit: 'h' } },
    ],
  },
};

const byPosition = (a, b) => a.position - b.position || a.created_at.localeCompare(b.created_at);

export async function loadFields(campaignId) {
  const { data, error } = await supabase.from('custom_fields').select('*').eq('campaign_id', campaignId);
  if (error) throw error;
  return data.sort(byPosition);
}

// { taskId: { fieldId: value } } for a whole project
export async function loadProjectValues(campaignId) {
  const { data, error } = await supabase.from('task_field_values').select('task_id, field_id, value').eq('campaign_id', campaignId);
  if (error) throw error;
  const out = {};
  data.forEach(row => { (out[row.task_id] ||= {})[row.field_id] = row.value; });
  return out;
}

// { fieldId: value } for one task
export async function loadTaskValues(taskId) {
  const { data, error } = await supabase.from('task_field_values').select('field_id, value').eq('task_id', taskId);
  if (error) throw error;
  return Object.fromEntries(data.map(row => [row.field_id, row.value]));
}

export async function createField(values) {
  const { data, error } = await supabase.from('custom_fields').insert(values).select().single();
  if (error) throw error;
  announce('fields-changed');
  return data;
}

export async function updateField(id, values) {
  const { error } = await supabase.from('custom_fields').update(values).eq('id', id);
  if (error) throw error;
  announce('fields-changed');
}

export async function deleteField(id) {
  const { error } = await supabase.from('custom_fields').delete().eq('id', id);
  if (error) throw error;
  announce('fields-changed');
}

// Adds a ready-made set at the end of the project's fields, skipping any
// field whose name the project already has. Returns how many were added.
export async function addFieldSet(campaignId, setKey, existing) {
  const have = new Set(existing.map(f => f.name.trim().toLowerCase()));
  const last = Math.max(0, ...existing.map(f => f.position));
  const rows = FIELD_SETS[setKey].fields()
    .filter(f => !have.has(f.name.toLowerCase()))
    .map((f, i) => ({ campaign_id: campaignId, name: f.name, type: f.type, settings: f.settings || {}, position: last + (i + 1) * 1000 }));
  if (!rows.length) return 0;
  const { error } = await supabase.from('custom_fields').insert(rows);
  if (error) throw error;
  announce('fields-changed');
  return rows.length;
}

// Saves one value; an empty value removes it
export async function saveValue(taskId, fieldId, value) {
  const { error } = isEmpty(value)
    ? await supabase.from('task_field_values').delete().eq('task_id', taskId).eq('field_id', fieldId)
    : await supabase.from('task_field_values').upsert({ task_id: taskId, field_id: fieldId, value }, { onConflict: 'task_id,field_id' });
  if (error) throw error;
  announce('field-values-changed');
}

export function isEmpty(value) {
  return value == null || value === '' || (Array.isArray(value) && !value.length)
    || (typeof value === 'object' && !Array.isArray(value) && (value.amount == null || value.amount === ''));
}

const fmtNumber = n => Number(n).toLocaleString('en-GB', { maximumFractionDigits: 2 });

// Colours a choice can have, named like Asana's so imported projects keep
// theirs (tokens --choice-<key>-bg / -fg in css/styles.css)
export const CHOICE_COLORS = {
  red: 'Red', orange: 'Orange', 'yellow-orange': 'Yellow orange', yellow: 'Yellow', 'yellow-green': 'Yellow green',
  green: 'Green', 'blue-green': 'Blue green', aqua: 'Aqua', blue: 'Blue', indigo: 'Indigo', purple: 'Purple',
  magenta: 'Magenta', 'hot-pink': 'Hot pink', pink: 'Pink', 'cool-gray': 'Gray',
};

export function choiceColor(field, option) {
  const color = field.settings?.colors?.[option];
  return CHOICE_COLORS[color] ? color : '';
}

// One choice as a coloured pill, with its name
export function choicePill(field, option) {
  const color = choiceColor(field, option);
  return `<span class="choice-pill ${color ? `choice-${color}` : ''}" title="${esc(`${field.name}: ${option}`)}">${esc(option)}</span>`;
}

// A value as HTML: choices as coloured pills, everything else as text
export function formatHtml(field, value) {
  if (isEmpty(value)) return '';
  if (field.type === 'choice') return choicePill(field, value);
  if (field.type === 'multi') return `<span class="choice-pills">${value.map(v => choicePill(field, v)).join('')}</span>`;
  return esc(formatValue(field, value));
}

// A choice dropdown takes the colour of its current choice
const colorsAttr = field => (field.settings?.colors ? `data-choice-colors="${esc(JSON.stringify(field.settings.colors))}"` : '');
document.addEventListener('change', event => {
  const select = event.target;
  if (!select.matches?.('select.choice-select')) return;
  let colors = {};
  try { colors = JSON.parse(select.dataset.choiceColors || '{}'); } catch { /* none */ }
  [...select.classList].filter(c => c.startsWith('choice-') && c !== 'choice-select').forEach(c => select.classList.remove(c));
  const color = colors[select.value];
  if (CHOICE_COLORS[color]) select.classList.add(`choice-${color}`);
});

// A value as plain text for lists and tables ('' when empty)
export function formatValue(field, value) {
  if (isEmpty(value)) return '';
  switch (field.type) {
    case 'number': return `${fmtNumber(value)}${field.settings?.unit ? ` ${field.settings.unit}` : ''}`;
    case 'money': return `${value.currency ? `${value.currency} ` : ''}${Number(value.amount).toLocaleString('en-GB', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
    case 'date': return fmtDate(value);
    case 'multi': return value.join(', ');
    case 'person': return personById(value)?.name || 'Someone who left';
    default: return String(value);
  }
}

// The input for a field (task panel, or a List cell with inline: true).
// Choices no longer offered (an option renamed or removed) are kept for the
// task that has them.
export function fieldInput(field, value, { disabled = false, inline = false } = {}) {
  const attrs = `data-field-id="${esc(field.id)}" aria-label="${esc(field.name)}" ${disabled ? 'disabled' : ''}`;
  const opts = (list, selected) => list.map(o => `<option value="${esc(o)}" ${selected.includes(o) ? 'selected' : ''}>${esc(o)}</option>`).join('');
  switch (field.type) {
    case 'number':
      return `<div class="field-with-unit"><input type="number" step="any" ${attrs} value="${esc(value ?? '')}">${field.settings?.unit ? `<span class="muted">${esc(field.settings.unit)}</span>` : ''}</div>`;
    case 'money': {
      const currencies = field.settings?.currencies?.length ? field.settings.currencies : ['€'];
      const current = value?.currency || currencies[0];
      const list = currencies.includes(current) ? currencies : [...currencies, current];
      return `<div class="money-input">
        <select data-money-currency aria-label="${esc(field.name)} currency" ${disabled ? 'disabled' : ''}>${opts(list, [current])}</select>
        <input type="number" step="0.01" ${attrs} data-money-amount value="${esc(value?.amount ?? '')}"></div>`;
    }
    case 'date':
      return `<input type="date" ${attrs} value="${esc(value || '')}">`;
    case 'choice': {
      const list = field.settings?.options || [];
      const all = value && !list.includes(value) ? [...list, value] : list;
      const color = value ? choiceColor(field, value) : '';
      return `<select class="choice-select ${color ? `choice-${color}` : ''}" ${colorsAttr(field)} ${attrs}><option value="">—</option>${opts(all, [value])}</select>`;
    }
    case 'multi': {
      const list = field.settings?.options || [];
      const chosen = Array.isArray(value) ? value : [];
      const all = [...list, ...chosen.filter(v => !list.includes(v))];
      if (inline) {
        // In a List cell: a compact dropdown of tick boxes
        return `<details class="multi-cell" ${attrs}>
          <summary>${chosen.length ? `<span class="choice-pills">${chosen.map(v => choicePill(field, v)).join('')}</span>` : '<span class="muted">—</span>'}</summary>
          <div class="multi-cell-menu" role="group" aria-label="${esc(field.name)}">${all.map(o => `
            <label class="multi-choice-item"><input type="checkbox" value="${esc(o)}" ${chosen.includes(o) ? 'checked' : ''}> ${esc(o)}</label>`).join('')
            || '<span class="muted small">No choices yet. Add some in Fields.</span>'}</div>
        </details>`;
      }
      return `<div class="multi-choice" ${attrs} role="group">${all.map(o => `
        <label class="multi-choice-item"><input type="checkbox" value="${esc(o)}" ${chosen.includes(o) ? 'checked' : ''} ${disabled ? 'disabled' : ''}> ${esc(o)}</label>`).join('')
        || '<span class="muted small">No choices yet. Add some in Fields.</span>'}</div>`;
    }
    case 'person': {
      const people = state.people.filter(p => (p.active && p.role !== 'director') || p.id === value);
      return `<select ${attrs}><option value="">—</option>${people.map(p =>
        `<option value="${esc(p.id)}" ${p.id === value ? 'selected' : ''}>${esc(p.name)}</option>`).join('')}</select>`;
    }
    default:
      return `<input type="text" maxlength="500" ${attrs} value="${esc(value ?? '')}">`;
  }
}

// Reads a field's value back from its input (the element with
// data-field-id, plus the currency box for money)
export function readFieldInput(field, el) {
  switch (field.type) {
    case 'number': return el.value === '' ? null : Number(el.value);
    case 'money': {
      const amount = el.value === '' ? null : Number(el.value);
      const currency = el.closest('.money-input')?.querySelector('[data-money-currency]')?.value || null;
      return amount == null ? null : { amount, currency };
    }
    case 'multi': return [...el.querySelectorAll('input:checked')].map(i => i.value);
    case 'text': return el.value.trim() || null;
    default: return el.value || null;
  }
}

// Settings from the field form's boxes ("one per line")
export function settingsFromForm(type, form) {
  const lines = name => [...new Set(String(form.elements[name]?.value || '').split('\n').map(s => s.trim()).filter(Boolean))];
  if (type === 'choice' || type === 'multi') {
    const opts = lines('options');
    const colors = {};
    form.querySelectorAll('[data-option-color]').forEach(select => {
      if (select.value && opts.includes(select.dataset.optionColor)) colors[select.dataset.optionColor] = select.value;
    });
    return Object.keys(colors).length ? { options: opts, colors } : { options: opts };
  }
  if (type === 'money') return { currencies: lines('currencies').length ? lines('currencies') : ['€'] };
  if (type === 'number') return form.elements.unit?.value.trim() ? { unit: form.elements.unit.value.trim() } : {};
  return {};
}
