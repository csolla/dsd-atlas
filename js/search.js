import { supabase } from './supabase.js';
import { esc } from './ui.js';

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

const PROJECT = 'id, name, status, private, archived_at, budget, department_id, for_department_id';
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
