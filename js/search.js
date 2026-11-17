import { supabase } from './supabase.js';
import { esc } from './ui.js';
import { state } from './state.js';

// Search across everything you can see: projects, sections, tasks (and
// subtasks) and comments. The database's permission rules decide what comes
// back, so private projects only appear for the people who can see them.

export const MIN_LENGTH = 2;
const LIMIT = 30;

// A pattern for "contains", with %, _ and \ in the words taken literally
function containsPattern(q) {
  return `%${q.replace(/[\\%_]/g, '\\$&')}%`;
}

async function rows(query) {
  const { data, error } = await query;
  if (error) throw error;
  return data;
}

// Rows from several queries, once each, in the order the queries were given
function unique(lists) {
  const seen = new Set();
  return lists.flat().filter(row => !seen.has(row.id) && seen.add(row.id));
}

const PROJECT = 'id, name, status, private, archived_at, is_template, budget, department_id, for_department_id';
const TASK = `id, title, description, status, due_date, assignee_id, parent_id, campaign_id,
  campaign:campaigns(${PROJECT}), parent:parent_id(id, title)`;

export async function searchEverything(q) {
  const words = q.trim();
  if (words.length < MIN_LENGTH) return { projects: [], sections: [], tasks: [], comments: [] };
  const like = containsPattern(words);
  const [projectNames, projectDescriptions, sections, taskTitles, taskDescriptions, comments] = await Promise.all([
    rows(supabase.from('campaigns').select(`${PROJECT}, description`).ilike('name', like).order('created_at', { ascending: false }).limit(LIMIT)),
    rows(supabase.from('campaigns').select(`${PROJECT}, description`).ilike('description', like).order('created_at', { ascending: false }).limit(LIMIT)),
    rows(supabase.from('sections').select(`id, name, campaign_id, campaign:campaigns(${PROJECT})`).ilike('name', like).limit(LIMIT)),
    rows(supabase.from('tasks').select(TASK).ilike('title', like).order('updated_at', { ascending: false }).limit(LIMIT)),
    rows(supabase.from('tasks').select(TASK).ilike('description', like).order('updated_at', { ascending: false }).limit(LIMIT)),
    rows(supabase.from('comments').select(`id, body, created_at, author_id, task_id,
      task:tasks(id, title, parent_id, campaign_id, campaign:campaigns(${PROJECT}))`).ilike('body', like).order('created_at', { ascending: false }).limit(LIMIT)),
  ]);
  return {
    projects: unique([projectNames, projectDescriptions]),
    sections: sections.filter(s => s.campaign),
    tasks: unique([taskTitles, taskDescriptions]).filter(t => t.campaign),
    comments: comments.filter(c => c.task?.campaign),
  };
}

// The text, escaped, with every match of the words marked
export function highlight(text, q) {
  const value = String(text ?? '');
  const words = q.trim();
  if (!words) return esc(value);
  const lower = value.toLowerCase();
  const needle = words.toLowerCase();
  let out = '';
  let from = 0;
  for (let at = lower.indexOf(needle); at !== -1; at = lower.indexOf(needle, from)) {
    out += `${esc(value.slice(from, at))}<mark>${esc(value.slice(at, at + needle.length))}</mark>`;
    from = at + needle.length;
  }
  return out + esc(value.slice(from));
}

// A short piece of a long text around the first match, as plain text
export function snippet(text, q, around = 70) {
  const value = String(text ?? '').replace(/\s+/g, ' ').trim();
  const at = value.toLowerCase().indexOf(q.trim().toLowerCase());
  if (value.length <= around * 2 || at === -1) return value.length > around * 2 ? `${value.slice(0, around * 2)}…` : value;
  const start = Math.max(0, at - around);
  const end = Math.min(value.length, at + q.trim().length + around);
  return `${start > 0 ? '…' : ''}${value.slice(start, end)}${end < value.length ? '…' : ''}`;
}

// People whose name (or email) contains the words: active people who can be
// given tasks. The people list is already loaded, so no query is needed.
export function matchPeople(q, limit = 5) {
  const lower = q.trim().toLowerCase();
  if (lower.length < MIN_LENGTH) return [];
  const starts = p => p.name.toLowerCase().split(/\s+/).some(word => word.startsWith(lower)) ? 0 : 1;
  return state.people
    .filter(p => p.active && p.role !== 'director'
      && (p.name.toLowerCase().includes(lower) || String(p.email || '').toLowerCase().split('@')[0].includes(lower)))
    .sort((a, b) => starts(a) - starts(b) || a.name.localeCompare(b.name))
    .slice(0, limit);
}

// Tasks and subtasks assigned to someone, in every project you can see
// (archived projects left out), soonest due first
export async function tasksAssignedTo(personId, { includeDone = false } = {}) {
  let query = supabase.from('tasks').select(TASK).eq('assignee_id', personId);
  if (!includeDone) query = query.neq('status', 'done');
  const data = await rows(query.order('due_date', { ascending: true, nullsFirst: false }).limit(500));
  return data.filter(t => t.campaign && !t.campaign.archived_at && !t.campaign.is_template);
}

// A few quick matches by name for the top bar's suggestions: projects and
// tasks whose name contains the words, the ones that start with them first
export async function suggest(q, { projects = 4, tasks = 5 } = {}) {
  const words = q.trim();
  if (words.length < MIN_LENGTH) return { projects: [], tasks: [] };
  const like = containsPattern(words);
  const [projectRows, taskRows] = await Promise.all([
    rows(supabase.from('campaigns').select('id, name, private, archived_at, is_template').ilike('name', like)
      .order('archived_at', { ascending: false, nullsFirst: true }).order('created_at', { ascending: false }).limit(20)),
    rows(supabase.from('tasks').select('id, title, status, parent_id, campaign_id, campaign:campaigns(id, name, private, archived_at, is_template)')
      .ilike('title', like).order('updated_at', { ascending: false }).limit(20)),
  ]);
  const lower = words.toLowerCase();
  // Starts with the words first, then live before archived, then as returned
  const rank = (name, archived) => (String(name).toLowerCase().startsWith(lower) ? 0 : 2) + (archived ? 1 : 0);
  const byRank = (key, archivedOf) => (a, b) => rank(a[key], archivedOf(a)) - rank(b[key], archivedOf(b));
  return {
    projects: [...projectRows].sort(byRank('name', p => p.archived_at)).slice(0, projects),
    tasks: taskRows.filter(t => t.campaign).sort(byRank('title', t => t.campaign.archived_at)).slice(0, tasks),
  };
}
