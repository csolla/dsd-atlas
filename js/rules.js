import { supabase } from './supabase.js';
import { personById } from './state.js';
import { formatValue } from './fields.js';
import { TASK_STATUSES } from './ui.js';

// Rules (must-have 10, 29_rules.sql): per project, WHEN something happens
// to a task, ONLY IF some things are true, THEN do things. The database
// runs them (run_rules); this file saves them and says them in words.

export const TRIGGERS = {
  task_added: 'A task is added',
  section_changed: 'A task moves to a section',
  field_changed: 'A field changes',
  due_changed: 'The due date changes',
  completed: 'A task is completed',
  assigned: 'A task is assigned',
};

export const CONDITIONS = {
  field: 'A field has a value',
  section: 'It is in a section',
  form: 'It came from a form',
};

export const ACTIONS = {
  assign: 'Assign it to',
  section: 'Move it to section',
  field: 'Set a field',
  due: 'Set the due date',
  status: 'Set the status',
  comment: 'Add a comment',
  subtasks: 'Add subtasks',
  week_section: 'Move it to the "Week of …" section for a date',
  copy: 'Copy it into another project',
};

export async function loadRules(campaignId) {
  const { data, error } = await supabase.from('rules').select('*').eq('campaign_id', campaignId).order('position').order('created_at');
  if (error) throw error;
  return data;
}

export async function saveRule(values, id = null) {
  const query = id ? supabase.from('rules').update(values).eq('id', id) : supabase.from('rules').insert(values);
  const { data, error } = await query.select().single();
  if (error) throw error;
  return data;
}

export async function deleteRule(id) {
  const { error } = await supabase.from('rules').delete().eq('id', id);
  if (error) throw error;
}

// Projects a rule can copy tasks into
export async function copyTargets(exceptId) {
  const { data, error } = await supabase.from('campaigns').select('id, name')
    .is('archived_at', null).eq('is_template', false).is('personal_of', null).neq('id', exceptId).order('name');
  if (error) throw error;
  return data;
}

// A rule in words, for the list: "When a task is added → assign it to Ana"
export function describeRule(rule, { fields = [], sections = [], forms = [], projects = [] } = {}) {
  const field = id => fields.find(f => f.id === id);
  const section = id => sections.find(s => s.id === id)?.name || 'a section that was deleted';
  const value = (id, v) => (v == null ? 'has any value' : `is ${formatValue(field(id) || { type: 'text' }, v)}`);
  const t = rule.trigger || {};
  let when = TRIGGERS[t.type] || 'Something happens';
  if (['task_added', 'section_changed'].includes(t.type) && t.section_id) when += ` to ${section(t.section_id)}`;
  if (t.type === 'field_changed') when = `${field(t.field_id)?.name || 'A field'} changes${'value' in t ? ` to ${formatValue(field(t.field_id) || { type: 'text' }, t.value)}` : ''}`;
  if (t.type === 'assigned' && t.person_id) when += ` to ${personById(t.person_id)?.name || 'someone'}`;
  const ifs = (rule.conditions || []).map(c => {
    if (c.type === 'field') return `${field(c.field_id)?.name || 'a field'} ${value(c.field_id, c.value)}`;
    if (c.type === 'section') return `it's in ${section(c.section_id)}`;
    if (c.type === 'form') return `it came from ${forms.find(f => f.id === c.form_id)?.name || 'a form'}`;
    return '';
  }).filter(Boolean);
  const thens = (rule.actions || []).map(a => {
    switch (a.type) {
      case 'assign': return a.person_id ? `assign to ${personById(a.person_id)?.name || 'someone'}` : 'unassign';
      case 'section': return `move to ${section(a.section_id)}`;
      case 'field': return `set ${field(a.field_id)?.name || 'a field'} to ${a.value == null ? 'empty' : formatValue(field(a.field_id) || { type: 'text' }, a.value)}`;
      case 'due': return `due in ${a.days} day${Number(a.days) === 1 ? '' : 's'}`;
      case 'status': return `set status to ${TASK_STATUSES[a.status] || a.status}`;
      case 'comment': return 'add a comment';
      case 'subtasks': return `add ${(a.titles || []).length} subtask${(a.titles || []).length === 1 ? '' : 's'}`;
      case 'week_section': return `move to its "Week of …" section by ${a.source === 'due' ? 'due date' : field(a.source)?.name || 'a date'}`;
      case 'copy': return `copy into ${projects.find(p => p.id === a.campaign_id)?.name || 'another project'}`;
      default: return '';
    }
  }).filter(Boolean);
  return `When ${when.charAt(0).toLowerCase()}${when.slice(1)}${ifs.length ? `, if ${ifs.join(' and ')}` : ''} → ${thens.join(', ') || 'nothing yet'}`;
}
