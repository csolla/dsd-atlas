import { supabase } from './supabase.js';

// Forms (must-have 9, 26_forms.sql). A form belongs to a project; sending it
// makes a task there. Editors manage a project's forms through the forms
// table; everyone else lists, opens and sends them through the database
// functions, which work even for private projects.

// Where a question's answer goes
export const QUESTION_TARGETS = { text: 'The description', due_date: 'The due date' };

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
