import { personById } from '../state.js';
import { esc, statusPill, fmtDate, errorMessage, avatar, TASK_STATUSES } from '../ui.js';
import { forTag, departmentName } from '../departments.js';
import { friendlyDue, isOverdue } from '../tasks.js';
import { toEditorText } from '../comments.js';
import { searchEverything, highlight, snippet, matchPeople, tasksAssignedTo, MIN_LENGTH } from '../search.js';

// Search page (#/search?q=...): everything you can see that contains the
// words, grouped into projects, sections, tasks and comments.

function hashParams() {
  const [, query = ''] = window.location.hash.split('?');
  return new URLSearchParams(query);
}

export function queryFromHash() {
  return hashParams().get('q') || '';
}

export function searchHref(q) {
  return `#/search?q=${encodeURIComponent(q.trim())}`;
}

// Everything assigned to one person
export function personHref(personId) {
  return `#/search?person=${encodeURIComponent(personId)}`;
}

function personLine(person, q = '') {
  const dept = departmentName(person.department_id);
  return `<span class="search-hit-title person">${avatar(person, 24)}${q ? highlight(person.name, q) : esc(person.name)}</span>
    <span class="search-hit-meta">${dept ? `${esc(dept)} · ` : ''}See their tasks</span>`;
}

const projectHref = id => `#/campaigns/${id}`;
const taskHref = (campaignId, taskId) => `#/campaigns/${campaignId}/tasks/${taskId}`;

function projectFlags(project) {
  return [
    project.private ? '<span class="private-flag"><span aria-hidden="true">🔒</span> Private</span>' : '',
    project.archived_at ? '<span class="private-flag">Archived</span>' : '',
  ].join('');
}

export async function renderSearch(el) {
  const personId = hashParams().get('person');
  if (personId) {
    renderPersonTasks(el, personId);
    return;
  }
  const q = queryFromHash();
  el.innerHTML = `
    <div class="page-header">
      <div>
        <h1>Search</h1>
        <p class="muted">People, projects, sections, tasks and comments you can see, including archived projects. Pick a person to see their tasks.</p>
      </div>
    </div>
    <form class="search-page-form" role="search" data-form>
      <input type="search" name="q" value="${esc(q)}" placeholder="Search everything" aria-label="Search everything" autocomplete="off" maxlength="200">
      <button class="btn btn-primary" type="submit">Search</button>
    </form>
    <div data-results></div>`;

  const form = el.querySelector('[data-form]');
  const input = form.elements.q;
  const results = el.querySelector('[data-results]');
  let latest = 0;

  const run = async words => {
    const mine = ++latest;
    if (words.trim().length < MIN_LENGTH) {
      results.innerHTML = `<p class="muted">Type at least ${MIN_LENGTH} letters.</p>`;
      return;
    }
    results.innerHTML = '<p class="muted">Searching…</p>';
    let found;
    try {
      found = await searchEverything(words);
    } catch (error) {
      if (mine === latest) results.innerHTML = `<p class="form-error">${esc(errorMessage(error))}</p>`;
      return;
    }
    if (mine !== latest) return;
    drawResults(results, found, words);
  };

  // Search as you type (after a short pause), keeping the address in step so
  // Back and shared links work
  let timer = null;
  input.addEventListener('input', () => {
    clearTimeout(timer);
    timer = setTimeout(() => {
      history.replaceState(null, '', searchHref(input.value));
      run(input.value);
    }, 300);
  });
  form.addEventListener('submit', event => {
    event.preventDefault();
    clearTimeout(timer);
    history.replaceState(null, '', searchHref(input.value));
    run(input.value);
  });

  input.focus();
  input.setSelectionRange(input.value.length, input.value.length);
  run(q);
}

function drawResults(container, { projects, sections, tasks, comments }, q) {
  const people = matchPeople(q, 10);
  const total = people.length + projects.length + sections.length + tasks.length + comments.length;
  if (!total) {
    container.innerHTML = `<div class="empty-state"><p>Nothing found for “${esc(q.trim())}”. Try fewer or different words.</p></div>`;
    return;
  }
  const group = (title, items, draw) => (items.length ? `
    <section class="search-group">
      <h2>${esc(title)} <span class="muted">${items.length}</span></h2>
      <ul class="search-hits">${items.map(draw).join('')}</ul>
    </section>` : '');

  container.innerHTML = `
    <p class="muted small">${total} result${total === 1 ? '' : 's'} for “${esc(q.trim())}”. Showing up to 30 of each kind; add words to narrow it down.</p>
    ${group('People', people, p => `
      <li><a class="search-hit" href="${personHref(p.id)}">${personLine(p, q)}</a></li>`)}
    ${group('Projects', projects, p => `
      <li><a class="search-hit" href="${projectHref(p.id)}">
        <span class="search-hit-title">${highlight(p.name, q)}</span>
        <span class="search-hit-meta">${forTag(p)} ${statusPill(p.status)} ${projectFlags(p)}</span>
        ${p.description && p.description.toLowerCase().includes(q.trim().toLowerCase())
          ? `<span class="search-hit-snippet">${highlight(snippet(p.description, q), q)}</span>` : ''}
      </a></li>`)}
    ${group('Sections', sections, s => `
      <li><a class="search-hit" href="${projectHref(s.campaign_id)}">
        <span class="search-hit-title">${highlight(s.name, q)}</span>
        <span class="search-hit-meta">Section in <strong>${esc(s.campaign.name)}</strong> ${projectFlags(s.campaign)}</span>
      </a></li>`)}
    ${group('Tasks', tasks, t => {
      const assignee = personById(t.assignee_id);
      return `
        <li><a class="search-hit" href="${taskHref(t.campaign_id, t.id)}">
          <span class="search-hit-title">${t.parent ? '<span class="subtask-mark" aria-hidden="true">↳</span>' : ''}${highlight(t.title, q)}</span>
          <span class="search-hit-meta">
            ${t.parent ? `Subtask of <strong>${esc(t.parent.title)}</strong> · ` : ''}<strong>${esc(t.campaign.name)}</strong>
            · ${esc(TASK_STATUSES[t.status] || t.status)}${assignee ? ` · ${esc(assignee.name)}` : ''}${t.due_date ? ` · due ${esc(fmtDate(t.due_date))}` : ''}
            ${projectFlags(t.campaign)}
          </span>
          ${t.description && t.description.toLowerCase().includes(q.trim().toLowerCase())
            ? `<span class="search-hit-snippet">${highlight(snippet(t.description, q), q)}</span>` : ''}
        </a></li>`;
    })}
    ${group('Comments', comments, c => {
      const author = personById(c.author_id);
      return `
        <li><a class="search-hit" href="${taskHref(c.task.campaign_id, c.task.id)}">
          <span class="search-hit-snippet">${highlight(snippet(toEditorText(c.body), q), q)}</span>
          <span class="search-hit-meta">${author ? `${esc(author.name)} · ` : ''}${esc(fmtDate(c.created_at.slice(0, 10)))}
            · on <strong>${esc(c.task.title)}</strong> in ${esc(c.task.campaign.name)} ${projectFlags(c.task.campaign)}</span>
        </a></li>`;
    })}`;
}

// Tasks assigned to one person (#/search?person=id), grouped by project
async function renderPersonTasks(el, personId) {
  const person = personById(personId);
  if (!person) {
    el.innerHTML = '<a class="back-link" href="#/search">← Search</a><div class="empty-state"><p>That person wasn\'t found.</p></div>';
    return;
  }
  el.innerHTML = `
    <a class="back-link" href="#/search">← Search</a>
    <div class="page-header">
      <div>
        <h1 class="person">${avatar(person, 36)}${esc(person.name)}</h1>
        <p class="muted">Tasks and subtasks assigned to ${esc(person.name.split(/\s+/)[0])}, in every project you can see. Archived projects are left out.</p>
      </div>
    </div>
    <label class="toggle search-done-toggle"><input type="checkbox" data-done> Show done tasks</label>
    <div data-results><p class="muted">Loading tasks…</p></div>`;
  const results = el.querySelector('[data-results]');
  const draw = async () => {
    const includeDone = el.querySelector('[data-done]').checked;
    let tasks;
    try {
      tasks = await tasksAssignedTo(person.id, { includeDone });
    } catch (error) {
      results.innerHTML = `<p class="form-error">${esc(errorMessage(error))}</p>`;
      return;
    }
    if (!tasks.length) {
      results.innerHTML = `<div class="empty-state"><p>${esc(person.name)} has no ${includeDone ? '' : 'open '}tasks${includeDone ? '' : '. Tick “Show done tasks” to see finished ones'}.</p></div>`;
      return;
    }
    // Projects in the order of their soonest task
    const byProject = new Map();
    tasks.forEach(t => {
      if (!byProject.has(t.campaign_id)) byProject.set(t.campaign_id, { project: t.campaign, tasks: [] });
      byProject.get(t.campaign_id).tasks.push(t);
    });
    results.innerHTML = `
      <p class="muted small">${tasks.length} task${tasks.length === 1 ? '' : 's'} in ${byProject.size} project${byProject.size === 1 ? '' : 's'}.</p>
      ${[...byProject.values()].map(({ project, tasks: list }) => `
        <section class="search-group">
          <h2><a href="#/campaigns/${esc(project.id)}">${esc(project.name)}</a> <span class="muted">${list.length}</span>
            ${project.private ? '<span class="private-flag"><span aria-hidden="true">🔒</span> Private</span>' : ''}</h2>
          <ul class="search-hits">${list.map(t => `
            <li><a class="search-hit" href="#/campaigns/${esc(t.campaign_id)}/tasks/${esc(t.id)}">
              <span class="search-hit-title">${t.parent ? '<span class="subtask-mark" aria-hidden="true">↳</span>' : ''}${esc(t.title)}</span>
              <span class="search-hit-meta">
                ${t.parent ? `Subtask of <strong>${esc(t.parent.title)}</strong> · ` : ''}${esc(TASK_STATUSES[t.status] || t.status)}
                ${t.due_date ? `· <span class="due ${isOverdue(t.due_date, t.status) ? 'overdue' : ''}">${esc(friendlyDue(t.due_date, t.status))}</span>` : '· No due date'}
              </span>
            </a></li>`).join('')}
          </ul>
        </section>`).join('')}`;
  };
  el.querySelector('[data-done]').addEventListener('change', draw);
  draw();
}
