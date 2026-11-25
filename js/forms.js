import { supabase } from './supabase.js';

// Forms (must-have 9, 26_forms.sql). A form belongs to a project; sending it
// makes a task there. Editors manage a project's forms through the forms
// table; everyone else lists, opens and sends them through the database
// functions, which work even for private projects.

// Question types, like Asana's forms
export const QUESTION_TYPES = { text: 'Text', choice: 'Single-select', multi: 'Multi-select', date: 'Date', number: 'Number' };

// Project field types a question of each type can fill
export const FIELDS_FOR_TYPE = { text: ['text'], choice: ['choice'], multi: ['multi'], date: ['date'], number: ['number', 'money'] };

// A question's type; questions saved before types existed get one from
// where their answer goes
export function questionType(q, fields = []) {
  if (q.type) return q.type;
  if (q.target === 'due_date') return 'date';
  if (q.target === 'field') {
    const type = (q.field || fields.find(f => f.id === q.field_id))?.type;
    return type === 'money' ? 'number' : (QUESTION_TYPES[type] ? type : 'text');
  }
  return 'text';
}

// A question shown as an input: its project field, or a stand-in field of
// its own type and choices, so js/fields.js draws and reads it
export const questionField = q => q.field || {
  id: `q-${q.key}`, name: q.label || 'Question', type: questionType(q), settings: { options: q.options || [] },
};

export async function loadProjectForms(campaignId) {
  const { data, error } = await supabase.from('forms').select('*').eq('campaign_id', campaignId).order('name');
  if (error) throw error;
  return data;
}

export async function saveForm(values, id = null) {
  const query = id
    ? supabase.from('forms').update(values).eq('id', id)
    : supabase.from('forms').insert(values);
  const { data, error } = await query.select().single();
  if (error) throw error;
  return data;
}

export async function deleteForm(id) {
  const { error } = await supabase.from('forms').delete().eq('id', id);
  if (error) throw error;
}

export async function listForms() {
  const { data, error } = await supabase.rpc('list_forms');
  if (error) throw error;
  return data;
}

export async function getForm(id) {
  const { data, error } = await supabase.rpc('get_form', { p_form: id });
  if (error) throw error;
  return data;
}

export async function submitForm(id, title, answers) {
  const { data, error } = await supabase.rpc('submit_form', { p_form: id, p_title: title, p_answers: answers });
  if (error) throw error;
  return data;
}

export const formLink = id => `${window.location.origin}${window.location.pathname}#/forms/${id}`;

// A key for a new question, unique within its form
export const newQuestionKey = () => `q${Math.random().toString(36).slice(2, 9)}`;
