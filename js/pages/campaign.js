import Sortable from 'https://cdn.jsdelivr.net/npm/sortablejs@1.15.2/+esm';
import { supabase } from '../supabase.js';
import { state, canEditWork, isAdmin, personById } from '../state.js';
import { onTasksChanged, onLiveChange } from '../realtime.js';
import { loadCampaignHours } from '../time.js';
import {
  loadCampaignTasks, createTask, updateTask, positionBetween, byPosition, tasksDonePct, isOverdue, friendlyDue,
  loadSections, createSection, updateSection, deleteSection,
} from '../tasks.js';
import {
  esc, options, statusPill, avatar, fmtCompactRange, fmtDate, fmtHours, toast, errorMessage,
  confirmDialog, formDialog, TASK_STATUSES,
} from '../ui.js';
import { unitLine } from '../departments.js';
import { loadAccess, projectAudience, accessNames } from '../access.js';
import { openCampaignForm } from './campaigns.js';
import { openTaskPanel } from './task-panel.js';

const DONE_SHOWN = 10;

// Per campaign, for this visit: filters and the quick-add assignee/date
const memory = {};


// openTask: a task to open straight away (from a shared task link)
export async function renderCampaign(el, id, openTask = null) {
  el.innerHTML = '<p class="muted">Loading project…</p>';

  const [campaignResult, tasksResult, sectionsResult] = await Promise.allSettled([
    supabase.from('campaigns').select('*').eq('id', id).maybeSingle(),
    loadCampaignTasks(id),
    loadSections(id),
  ]);
  const error = campaignResult.reason || campaignResult.value?.error || tasksResult.reason || sectionsResult.reason;
  if (error) {
    el.innerHTML = `<p class="form-error">${esc(errorMessage(error))}</p>`;
    return;
  }
  const campaign = campaignResult.value.data;
  if (!campaign) {
    el.innerHTML = `
      <a class="back-link" href="#/campaigns">← Projects</a>
      <div class="empty-state"><p>This project doesn't exist or was deleted.</p></div>`;
    return;
  }

  memory[id] ||= { q: '', person: '', section: '', assignee: '', due: '', showAllDone: false, details: false };
  const page = {
    el, campaign, tasks: tasksResult.value, sections: sectionsResult.value, view: memory[id].view || 'kanban', dragging: false, counts: {}, m: memory[id],
  };
  const owner = personById(campaign.owner_id);
  // On a private project, only people who can see it can be assigned
  const access = campaign.private ? await loadAccess(id).catch(() => []) : [];
  const team = projectAudience(campaign, access);

  el.innerHTML = `
    <a class="back-link" href="#/campaigns">← Projects</a>
    <section class="card campaign-summary">
      <div class="summary-top">
        <div class="summary-title">
          <h1>${esc(campaign.name)}</h1>
          <div class="summary-meta">
            ${unitLine(campaign)}
            ${campaign.private ? '<span class="private-flag"><span aria-hidden="true">🔒</span> Private</span>' : ''}
            ${statusPill(campaign.status)}
            <span>${esc(fmtCompactRange(campaign.start_date, campaign.end_date))}</span>
            ${owner ? `<span class="person">${avatar(owner, 20)}${esc(owner.name)}</span>` : ''}
          </div>
        </div>
        <div class="summary-stats">
          <div class="stat"><span class="stat-label">Hours</span><span data-hours>…</span></div>
          <div class="stat"><span class="stat-label">Tasks done</span><span data-progress></span></div>
        </div>
        <div class="actions">
          <button class="btn btn-ghost btn-small" type="button" data-toggle-details aria-expanded="${page.m.details}">Details</button>
          ${canEditWork() ? `<button class="btn btn-small" type="button" data-edit>Edit</button>
            <button class="btn btn-small btn-ghost" type="button" data-archive>${campaign.archived_at ? 'Unarchive' : 'Archive'}</button>` : ''}
        </div>
      </div>
      ${campaign.private ? accessLine(access) : ''}
      ${campaign.archived_at ? `<p class="archived-note" role="status"><strong>Archived</strong> on ${esc(fmtDate(campaign.archived_at.slice(0, 10)))}${personById(campaign.archived_by) ? ` by ${esc(personById(campaign.archived_by).name)}` : ''}.
        Kept for reference: its hours still count in Dashboards, but no new time can be logged on it.</p>` : ''}
      <div class="campaign-details" data-details ${page.m.details ? '' : 'hidden'}>
        ${campaign.description ? `<p class="description">${esc(campaign.description)}</p>` : '<p class="muted">No description.</p>'}
        <p class="muted small">${esc(fmtDate(campaign.start_date))}${campaign.end_date ? ` to ${esc(fmtDate(campaign.end_date))}` : ''} · Planned ${fmtHours(campaign.planned_hours)}</p>
        ${isAdmin() ? `
          <div class="details-actions">
            <button class="btn btn-small btn-danger-outline" type="button" data-delete hidden>Delete project</button>
            <span class="muted small" data-delete-note hidden>This project has hours logged, so it can't be deleted. Set it to Done or On hold instead.</span>
          </div>` : ''}
      </div>
    </section>
    <section class="section tasks-section">
      ${canEditWork() && !campaign.archived_at ? `
        <form class="quick-add-bar" data-quick-add>
          <input class="quick-title" placeholder="Add a task and press Enter" aria-label="New task title" maxlength="300">
          <select data-qa="assignee" aria-label="Assign new tasks to">
            <option value="">Unassigned</option>
            ${options(Object.fromEntries(team.map(p => [p.id, p.id === state.me.id ? `${p.name} (me)` : p.name])), page.m.assignee)}
          </select>
          <input type="date" data-qa="due" value="${esc(page.m.due)}" aria-label="Due date for new tasks">
          <button class="btn btn-primary" type="submit">Add</button>
        </form>` : ''}
      <div class="tasks-toolbar">
        <input class="search" type="search" placeholder="Find a task" aria-label="Find a task" value="${esc(page.m.q)}" data-find>
        <select data-person aria-label="Show tasks for">
          <option value="">Everyone</option>
          <option value="me" ${page.m.person === 'me' ? 'selected' : ''}>Only mine</option>
          <option value="none" ${page.m.person === 'none' ? 'selected' : ''}>Unassigned</option>
          ${options(Object.fromEntries(team.filter(p => p.id !== state.me.id).map(p => [p.id, p.name])), page.m.person)}
        </select>
        <select data-section-filter aria-label="Show section" hidden></select>
        <span class="spacer"></span>
        <div class="view-switch" role="group" aria-label="View">
          <button type="button" data-view="kanban" title="Columns by status: To do, In progress, In review, Done">Kanban</button>
          <button type="button" data-view="board" title="Columns by section">Board</button>
          <button type="button" data-view="list" title="Tasks grouped by section">List</button>
        </div>
      </div>
      <div data-tasks></div>
    </section>`;

  el.querySelector('[data-toggle-details]').addEventListener('click', event => {
    page.m.details = !page.m.details;
    event.currentTarget.setAttribute('aria-expanded', String(page.m.details));
    el.querySelector('[data-details]').hidden = !page.m.details;
  });
  el.querySelector('[data-edit]')?.addEventListener('click', () =>
    openCampaignForm(campaign, () => renderCampaign(el, id)));
  el.querySelector('[data-delete]')?.addEventListener('click', () => deleteCampaign(page));
  el.querySelector('[data-archive]')?.addEventListener('click', () => toggleArchived(page, () => renderCampaign(el, id)));
  const quick = el.querySelector('[data-quick-add]');
  if (quick) {
    quick.addEventListener('submit', event => quickAdd(event, page));
    quick.querySelectorAll('[data-qa]').forEach(input => input.addEventListener('change', () => {
      page.m[input.dataset.qa] = input.value;
    }));
  }
  el.querySelector('[data-find]').addEventListener('input', event => { page.m.q = event.target.value; drawTasks(page); });
  el.querySelector('[data-person]').addEventListener('change', event => { page.m.person = event.target.value; drawTasks(page); });
  el.querySelector('[data-section-filter]').addEventListener('change', event => { page.m.section = event.target.value; drawTasks(page); });
  el.querySelectorAll('[data-view]').forEach(button => button.addEventListener('click', () => {
    page.view = button.dataset.view;
    page.m.view = page.view;
    drawTasks(page);
  }));

  drawTasks(page);
  loadHours(page);
  loadCounts(page);
  if (openTask) openTaskPanel(openTask);
  onLiveChange(el, ['comments-changed', 'attachments-changed'], () => loadCounts(page), { isBusy: () => page.dragging });
  onLiveChange(el, 'time-changed', () => loadHours(page));

  onTasksChanged(el, async () => {
    try {
      page.tasks = await loadCampaignTasks(id);
      drawTasks(page);
    } catch { /* keep what's shown */ }
  }, { isBusy: () => page.dragging || page.el.contains(document.activeElement) && document.activeElement.matches('.column-add input') });

  onLiveChange(el, 'sections-changed', async () => {
    try {
      page.sections = await loadSections(id);
      drawTasks(page);
    } catch { /* keep what's shown */ }
  }, { isBusy: () => page.dragging });
}

function meter(pct, level) {
  return `<span class="mini-meter meter-${level}" aria-hidden="true"><span style="width:${Math.min(100, pct)}%"></span></span>`;
}

// Hours logged, with the Education / Planning Center split for campaigns for both.
// Campaigns with hours can't be deleted.
async function loadHours(page) {
  const { el, campaign } = page;
  let totals;
  try {
    totals = (await loadCampaignHours(campaign.id))[campaign.id];
  } catch {
    return;
  }
  const hours = Number(totals?.hours || 0);
  const planned = Number(campaign.planned_hours);
  const pct = planned > 0 ? hours / planned * 100 : null;
  const level = pct == null ? 'none' : pct > 100 ? 'critical' : pct >= 80 ? 'warning' : 'good';
  const split = campaign.budget === 'shared' && hours
    ? `<span class="muted small hours-split">${fmtHours(totals.education_hours)} Education · ${fmtHours(totals.planning_center_hours)} Planning Center</span>`
    : '';
  el.querySelector('[data-hours]').innerHTML = `
    <span class="stat-value">${pct == null ? '' : meter(pct, level)}
      <span class="${level === 'critical' ? 'over-plan' : ''}">${fmtHours(hours)}</span>${planned ? ` <span class="muted">of ${fmtHours(planned)}</span>` : ''}</span>${split}`;
  const remove = el.querySelector('[data-delete]');
  if (remove) {
    remove.hidden = hours > 0;
    el.querySelector('[data-delete-note]').hidden = hours === 0;
  }
}

// Filters: words in the task or its subtasks; a person as assignee of the
// task or any of its subtasks
function matches(page, task, subtasks) {
  if (page.m.section && (task.section_id || 'none') !== page.m.section) return false;
  const q = page.m.q.trim().toLowerCase();
  const person = page.m.person === 'me' ? state.me.id : page.m.person;
  const textOk = !q || [task, ...subtasks].some(t => t.title.toLowerCase().includes(q));
  if (!person) return textOk;
  if (person === 'none') return textOk && !task.assignee_id;
  return textOk && [task, ...subtasks].some(t => t.assignee_id === person);
}

function drawTasks(page) {
  const { el, tasks, view } = page;
  const main = tasks.filter(t => !t.parent_id);
  const pct = tasksDonePct(tasks);
  const done = main.filter(t => t.status === 'done').length;
  el.querySelector('[data-progress]').innerHTML = pct == null
    ? '<span class="muted">No tasks yet</span>'
    : `<span class="stat-value">${meter(pct, 'progress')} ${done} of ${main.length} <span class="muted">(${pct}%)</span></span>`;
  el.querySelectorAll('[data-view]').forEach(button =>
    button.setAttribute('aria-pressed', String(button.dataset.view === view)));

  // Views: Kanban (status columns, the default), Board (section columns)
  // and List (grouped by section). The Board already splits by section, so
  // it has no section filter.
  const bySection = view === 'board';
  if (bySection) page.m.section = '';
  drawSectionFilter(page, bySection);
  const container = el.querySelector('[data-tasks]');
  const subtasksOf = id => tasks.filter(t => t.parent_id === id);
  // Board and List always show their sections and + Add section, even
  // before there are tasks
  if ((view === 'list' || bySection) && !page.m.q.trim() && !page.m.person && !page.m.section) {
    if (view === 'list') drawList(page, container, main, subtasksOf);
    else drawSectionBoard(page, container, main, subtasksOf);
    return;
  }
  if (!main.length) {
    container.innerHTML = `<div class="empty-state"><p>No tasks yet.${canEditWork() ? ' Type a title above and press Enter to add the first one.' : ''}</p></div>`;
    return;
  }
  const filtering = Boolean(page.m.q.trim() || page.m.person || page.m.section);
  const shown = main.filter(t => matches(page, t, subtasksOf(t.id)));
  if (!shown.length) {
    container.innerHTML = '<div class="empty-state"><p>No tasks match. Change the person or section, or clear the search.</p></div>';
    return;
  }
  if (view === 'list') drawList(page, container, shown, subtasksOf);
  else if (bySection) drawSectionBoard(page, container, shown, subtasksOf);
  else drawBoard(page, container, shown, subtasksOf, filtering);
}

// Comment and attachment counts for the cards
async function loadCounts(page) {
  const { data, error } = await supabase.from('task_activity_counts')
    .select('task_id, comments, attachments').eq('campaign_id', page.campaign.id);
  if (error) return;
  page.counts = Object.fromEntries(data.map(row => [row.task_id, row]));
  drawTasks(page);
}

const ICONS = {
  comments: '<svg viewBox="0 0 16 16" aria-hidden="true"><path d="M2.5 3.5h11v7h-6l-3 2.5v-2.5h-2z" fill="none" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round"/></svg>',
  attachments: '<svg viewBox="0 0 16 16" aria-hidden="true"><path d="M10.5 5 6 9.5a1.4 1.4 0 0 0 2 2L13 6.5a2.8 2.8 0 0 0-4-4L4 7.5a4.2 4.2 0 0 0 6 6l3.5-3.5" fill="none" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/></svg>',
};

function activityCounts(page, taskId) {
  const counts = page.counts[taskId];
  if (!counts) return '';
  const item = (key, label) => (Number(counts[key])
    ? `<span class="activity-count" title="${counts[key]} ${label}">${ICONS[key]}${counts[key]}</span>` : '');
  return item('comments', 'comments') + item('attachments', 'attachments');
}

function subtaskCount(subtasks) {
  if (!subtasks.length) return '';
  const done = subtasks.filter(s => s.status === 'done').length;
  return `<span class="subcount" title="Subtasks done">✓ ${done}/${subtasks.length}</span>`;
}

function dueLabel(task) {
  if (!task.due_date) return '';
  const late = isOverdue(task.due_date, task.status);
  return `<span class="due ${late ? 'overdue' : ''}" title="Due ${esc(fmtDate(task.due_date))}">${esc(friendlyDue(task.due_date, task.status))}</span>`;
}

function assigneeBadge(task, size = 24) {
  const assignee = personById(task.assignee_id);
  return assignee
    ? `<span title="${esc(assignee.name)}">${avatar(assignee, size)}</span>`
    : `<span class="avatar avatar-empty" style="width:${size}px;height:${size}px" title="Unassigned" aria-label="Unassigned"></span>`;
}

// Board ---------------------------------------------------------------------

// showStatus: on the Board (section columns), each card says its status
function taskCard(page, task, subtasksOf, showStatus = false) {
  return `
    <article class="task-card ${task.status === 'done' ? 'is-done' : ''}" data-id="${esc(task.id)}" tabindex="0">
      <p class="task-card-title">${esc(task.title)}</p>
      <div class="task-card-meta">
        ${showStatus ? `<span class="card-status card-status-${esc(task.status)}">${esc(TASK_STATUSES[task.status] || task.status)}</span>` : ''}
        ${dueLabel(task)}
        ${subtaskCount(subtasksOf(task.id))}
        ${activityCounts(page, task.id)}
        <span class="spacer"></span>
        ${assigneeBadge(task)}
      </div>
    </article>`;
}

// The "+ Add task" box at the bottom of a column
function wireColumnAdd(form, onTitle) {
  const open = form.querySelector('.column-add-open');
  const input = form.querySelector('input');
  const close = () => { input.hidden = true; open.hidden = false; input.value = ''; };
  open.addEventListener('click', () => { open.hidden = true; input.hidden = false; input.focus(); });
  input.addEventListener('keydown', event => { if (event.key === 'Escape') { event.stopPropagation(); close(); } });
  input.addEventListener('blur', () => { if (!input.value.trim()) close(); });
  form.addEventListener('submit', async event => {
    event.preventDefault();
    const title = input.value.trim();
    if (!title) return;
    input.value = '';
    await onTitle(title);
  });
}

// Board with one column per section, like the List. Within a column: by
// status, then board order. Drag a card to another column to change its
// section; its status changes in the card's panel.
function drawSectionBoard(page, container, main, subtasksOf) {
  const { sections } = page;
  const filtering = Boolean(page.m.q.trim() || page.m.person);
  const edit = canEditWork() && !page.campaign.archived_at;
  const known = new Set(sections.map(s => s.id));
  const sorted = [...main].sort((a, b) =>
    STATUS_ORDER.indexOf(a.status) - STATUS_ORDER.indexOf(b.status) || byPosition(a, b));
  const inGroup = id => sorted.filter(t => (known.has(t.section_id) ? t.section_id : '') === id);
  const columns = [
    { id: '', name: 'No section', tasks: inGroup('') },
    ...sections.map(s => ({ id: s.id, name: s.name, tasks: inGroup(s.id) })),
  ].filter(c => (c.id ? !filtering || c.tasks.length : c.tasks.length || !sections.length));

  container.innerHTML = `
    <div class="board board-sections">
      ${columns.map(c => `
        <section class="board-col">
          <header class="board-col-head"><h3>${esc(c.name)}</h3><span class="muted">${c.tasks.length}</span></header>
          <div class="board-cards" data-group="${esc(c.id)}">
            ${c.tasks.map(task => taskCard(page, task, subtasksOf, true)).join('')}
          </div>
          ${edit ? `<form class="column-add" data-column-add="${esc(c.id)}">
            <button class="btn btn-ghost btn-small column-add-open" type="button">+ Add task</button>
            <input placeholder="Task title, then Enter" aria-label="New task in ${esc(c.name)}" maxlength="300" hidden>
          </form>` : ''}
        </section>`).join('')}
      ${canEditWork() && !filtering ? `<div class="board-col-new">
        <button class="btn btn-ghost btn-small" type="button" data-section-new>+ Add section</button></div>` : ''}
    </div>`;

  container.querySelectorAll('.task-card').forEach(card => {
    card.addEventListener('click', () => openTaskPanel(card.dataset.id));
    card.addEventListener('keydown', event => { if (event.key === 'Enter') openTaskPanel(card.dataset.id); });
  });
  container.querySelector('[data-section-new]')?.addEventListener('click', () => openSectionForm(page, null));
  container.querySelectorAll('[data-column-add]').forEach(form => wireColumnAdd(form, async title => {
    const id = form.dataset.columnAdd;
    await addTask(page, title, 'todo', id || null);
    container.querySelector(`[data-column-add="${CSS.escape(id)}"] .column-add-open`)?.click();
  }));
  container.querySelectorAll('.board-cards').forEach(column => Sortable.create(column, {
    group: 'section-board',
    sort: false,
    animation: 150,
    delayOnTouchOnly: true,
    delay: 150,
    ghostClass: 'drag-ghost',
    disabled: !canEditWork(),
    onStart: () => { page.dragging = true; },
    onEnd: event => moveToSection(page, event),
  }));
}

function drawBoard(page, container, main, subtasksOf, filtering) {
  container.innerHTML = `
    <div class="board">
      ${Object.entries(TASK_STATUSES).map(([status, label]) => {
        let column = main.filter(t => t.status === status).sort(byPosition);
        const total = column.length;
        // Done keeps growing: show the most recently finished unless asked for all
        let hidden = 0;
        if (status === 'done' && !filtering && !page.m.showAllDone && total > DONE_SHOWN) {
          const recent = new Set([...column].sort((a, b) => b.updated_at.localeCompare(a.updated_at)).slice(0, DONE_SHOWN).map(t => t.id));
          column = column.filter(t => recent.has(t.id));
          hidden = total - DONE_SHOWN;
        }
        return `
          <section class="board-col">
            <header class="board-col-head"><h3>${esc(label)}</h3><span class="muted">${total}</span></header>
            <div class="board-cards" data-status="${status}">
              ${column.map(task => taskCard(page, task, subtasksOf)).join('')}
            </div>
            ${hidden ? `<button class="btn btn-ghost btn-small column-more" type="button" data-show-done>Show all ${total} done</button>` : ''}
            ${status === 'done' && page.m.showAllDone && total > DONE_SHOWN && !filtering
              ? '<button class="btn btn-ghost btn-small column-more" type="button" data-hide-done>Show only the latest</button>' : ''}
            ${canEditWork() ? `<form class="column-add" data-column-add="${status}">
              <button class="btn btn-ghost btn-small column-add-open" type="button">+ Add task</button>
              <input placeholder="Task title, then Enter" aria-label="New task in ${esc(label)}" maxlength="300" hidden>
            </form>` : ''}
          </section>`;
      }).join('')}
    </div>`;

  container.querySelectorAll('.task-card').forEach(card => {
    card.addEventListener('click', () => openTaskPanel(card.dataset.id));
    card.addEventListener('keydown', event => { if (event.key === 'Enter') openTaskPanel(card.dataset.id); });
  });
  container.querySelector('[data-show-done]')?.addEventListener('click', () => { page.m.showAllDone = true; drawTasks(page); });
  container.querySelector('[data-hide-done]')?.addEventListener('click', () => { page.m.showAllDone = false; drawTasks(page); });

  container.querySelectorAll('[data-column-add]').forEach(form => wireColumnAdd(form, async title => {
    await addTask(page, title, form.dataset.columnAdd);
    // Keep the box open in the same column for the next one
    container.querySelector(`[data-column-add="${form.dataset.columnAdd}"] .column-add-open`)?.click();
  }));

  container.querySelectorAll('.board-cards').forEach(column => Sortable.create(column, {
    group: 'tasks',
    animation: 150,
    delayOnTouchOnly: true,
    delay: 150,
    ghostClass: 'drag-ghost',
    disabled: !canEditWork(),
    onStart: () => { page.dragging = true; },
    onEnd: event => moveTask(page, event),
  }));
}

async function moveTask(page, event) {
  page.dragging = false;
  if (event.from === event.to && event.oldIndex === event.newIndex) return;

  const task = page.tasks.find(t => t.id === event.item.dataset.id);
  const positionOf = node => (node ? page.tasks.find(t => t.id === node.dataset.id)?.position : null);
  const status = event.to.dataset.status;
  const position = positionBetween(positionOf(event.item.previousElementSibling), positionOf(event.item.nextElementSibling));
  const before = { status: task.status, position: task.position };

  Object.assign(task, { status, position });
  setTimeout(() => drawTasks(page), 0);
  try {
    await updateTask(task.id, { status, position });
  } catch (error) {
    Object.assign(task, before);
    drawTasks(page);
    toast(errorMessage(error), 'error');
  }
}

// List ----------------------------------------------------------------------

const STATUS_ORDER = Object.keys(TASK_STATUSES);

// Grouped by section, in the project's section order. Tasks with no section
// come first. Within a section: by status, then board order. Tasks can be
// dragged from one section to another.
function drawList(page, container, main, subtasksOf) {
  const sorted = [...main].sort((a, b) =>
    STATUS_ORDER.indexOf(a.status) - STATUS_ORDER.indexOf(b.status) || byPosition(a, b));
  const { sections } = page;
  const filtering = Boolean(page.m.q.trim() || page.m.person || page.m.section);
  const edit = canEditWork();
  const known = new Set(sections.map(s => s.id));
  const inGroup = id => sorted.filter(t => (known.has(t.section_id) ? t.section_id : '') === id);
  const groups = [
    { id: '', name: 'No section', tasks: inGroup('') },
    ...sections.map(s => ({ id: s.id, name: s.name, tasks: inGroup(s.id) })),
  ].filter(g => (g.id ? !filtering || g.tasks.length : g.tasks.length || !sections.length));

  const row = task => {
    const assignee = personById(task.assignee_id);
    return `
      <tr data-id="${esc(task.id)}" class="clickable ${task.status === 'done' ? 'is-done' : ''}">
        <td class="tick-col"><input type="checkbox" data-done ${task.status === 'done' ? 'checked' : ''} aria-label="Done"></td>
        <td><span class="task-title">${esc(task.title)}</span> ${subtaskCount(subtasksOf(task.id))} ${activityCounts(page, task.id)}</td>
        <td>${assignee ? `<span class="person">${avatar(assignee, 24)}${esc(assignee.name)}</span>` : `<span class="person">${assigneeBadge(task)}<span class="muted">Unassigned</span></span>`}</td>
        <td class="nowrap">${dueLabel(task) || '<span class="muted">—</span>'}</td>
        <td><select data-status aria-label="Status">${options(TASK_STATUSES, task.status)}</select></td>
      </tr>`;
  };
  const head = (g, i) => (sections.length ? `
    <tr class="task-section-row" data-section-head>
      <th colspan="5" scope="colgroup">
        <div class="task-section-head">
          <h3>${esc(g.name)}</h3><span class="muted">${g.tasks.length}</span>
          <span class="spacer"></span>
          ${edit && g.id ? `
            <button class="icon-btn" type="button" data-section-up ${i === firstSection ? 'disabled' : ''} aria-label="Move ${esc(g.name)} up" title="Move up">↑</button>
            <button class="icon-btn" type="button" data-section-down ${i === groups.length - 1 ? 'disabled' : ''} aria-label="Move ${esc(g.name)} down" title="Move down">↓</button>
            <button class="btn btn-ghost btn-small" type="button" data-section-rename>Rename</button>
            <button class="btn btn-ghost btn-small" type="button" data-section-delete>Delete</button>` : ''}
        </div>
      </th>
    </tr>` : '');
  const firstSection = groups.findIndex(g => g.id);

  container.innerHTML = `
    <div class="table-wrap">
      <table class="table task-table">
        <thead>
          <tr><th class="tick-col"><span class="visually-hidden">Done</span></th><th>Task</th><th>Assignee</th><th>Due</th><th>Status</th></tr>
        </thead>
        ${groups.map((g, i) => `
          <tbody data-group="${esc(g.id)}">
            ${head(g, i)}
            ${g.tasks.map(row).join('')}
            ${!g.tasks.length ? `<tr class="task-section-empty" data-placeholder><td colspan="5" class="muted small">${sections.length ? 'No tasks in this section yet.' : 'No tasks yet.'}${edit && sections.length ? ' Drag one here or add one below.' : ''}</td></tr>` : ''}
            ${edit && sections.length && !page.campaign.archived_at ? `
              <tr class="task-section-add" data-placeholder><td colspan="5">
                <form class="column-add" data-section-add="${esc(g.id)}">
                  <button class="btn btn-ghost btn-small column-add-open" type="button">+ Add task</button>
                  <input placeholder="Task title, then Enter" aria-label="New task in ${esc(g.name)}" maxlength="300" hidden>
                </form>
              </td></tr>` : ''}
          </tbody>`).join('')}
      </table>
    </div>
    ${edit && !filtering ? '<button class="btn btn-small task-section-new" type="button" data-section-new>+ Add section</button>' : ''}`;

  container.querySelectorAll('tbody[data-group]').forEach(body => {
    const id = body.dataset.group;
    const section = sections.find(s => s.id === id);
    body.querySelector('[data-section-up]')?.addEventListener('click', () => moveSection(page, section, -1));
    body.querySelector('[data-section-down]')?.addEventListener('click', () => moveSection(page, section, 1));
    body.querySelector('[data-section-rename]')?.addEventListener('click', () => openSectionForm(page, section));
    body.querySelector('[data-section-delete]')?.addEventListener('click', () => removeSection(page, section));
    const form = body.querySelector('[data-section-add]');
    if (form) {
      wireColumnAdd(form, async title => {
        await addTask(page, title, 'todo', id || null);
        container.querySelector(`[data-section-add="${CSS.escape(id)}"] .column-add-open`)?.click();
      });
    }
    if (edit && sections.length) {
      Sortable.create(body, {
        group: 'sections',
        sort: false,
        animation: 150,
        delayOnTouchOnly: true,
        delay: 150,
        draggable: 'tr[data-id]',
        filter: 'input, select',
        preventOnFilter: false,
        ghostClass: 'drag-ghost',
        onStart: () => { page.dragging = true; },
        onEnd: event => moveToSection(page, event),
      });
    }
  });
  container.querySelector('[data-section-new]')?.addEventListener('click', () => openSectionForm(page, null));

  container.querySelectorAll('tbody tr[data-id]').forEach(row => {
    const task = page.tasks.find(t => t.id === row.dataset.id);
    row.addEventListener('click', event => {
      if (!event.target.closest('input, select')) openTaskPanel(task.id);
    });
    row.querySelector('[data-done]').addEventListener('change', event =>
      setStatus(page, task, event.target.checked ? 'done' : 'todo'));
    row.querySelector('[data-status]').addEventListener('change', event => setStatus(page, task, event.target.value));
  });
}

async function setStatus(page, task, status) {
  const before = task.status;
  task.status = status;
  drawTasks(page);
  try {
    await updateTask(task.id, { status });
  } catch (error) {
    task.status = before;
    drawTasks(page);
    toast(errorMessage(error), 'error');
  }
}

// Sections --------------------------------------------------------------------

// The section filter, shown once the project has sections
function drawSectionFilter(page, bySection = false) {
  const select = page.el.querySelector('[data-section-filter]');
  if (page.m.section && page.m.section !== 'none' && !page.sections.some(s => s.id === page.m.section)) page.m.section = '';
  select.hidden = !page.sections.length || bySection;
  select.innerHTML = `<option value="">All sections</option><option value="none">No section</option>
    ${options(Object.fromEntries(page.sections.map(s => [s.id, s.name])), page.m.section)}`;
  select.value = page.m.section;
}

// New tasks go into the section being shown, if one is picked
function shownSectionId(page) {
  return page.m.section && page.m.section !== 'none' ? page.m.section : null;
}

function openSectionForm(page, section) {
  formDialog({
    title: section ? 'Rename section' : 'Add section',
    submitLabel: section ? 'Save' : 'Add section',
    body: `
      <label class="field"><span>Name</span>
        <input name="name" required maxlength="120" value="${esc(section?.name || '')}" placeholder="For example: Pre-onboarding"></label>
      ${section ? '' : '<p class="muted small form-note">It goes at the bottom of the list. Use the arrows to move it.</p>'}`,
    onSubmit: async form => {
      const name = form.elements.name.value.trim();
      if (!name) return 'Give the section a name.';
      try {
        if (section) {
          await updateSection(section.id, { name });
          section.name = name;
        } else {
          const last = Math.max(0, ...page.sections.map(s => s.position));
          page.sections.push(await createSection({ campaign_id: page.campaign.id, name, position: last + 1000 }));
        }
      } catch (error) {
        return errorMessage(error);
      }
      toast(section ? 'Section renamed' : `${name} added`);
      drawTasks(page);
    },
  });
}

// Swap a section with the one above or below it
async function moveSection(page, section, step) {
  const ordered = [...page.sections].sort(byPosition);
  const i = ordered.indexOf(section);
  if (!ordered[i + step]) return;
  [ordered[i], ordered[i + step]] = [ordered[i + step], ordered[i]];
  // Number them again 1000, 2000…, saving only the ones that changed
  const changed = ordered.filter((s, n) => s.position !== (n + 1) * 1000);
  ordered.forEach((s, n) => { s.position = (n + 1) * 1000; });
  page.sections = ordered;
  drawTasks(page);
  try {
    await Promise.all(changed.map(s => updateSection(s.id, { position: s.position })));
  } catch (error) {
    toast(errorMessage(error), 'error');
    page.sections = await loadSections(page.campaign.id).catch(() => page.sections);
    drawTasks(page);
  }
}

async function removeSection(page, section) {
  const count = page.tasks.filter(t => !t.parent_id && t.section_id === section.id).length;
  const ok = await confirmDialog({
    title: `Delete “${section.name}”?`,
    message: count
      ? `Its ${count} task${count === 1 ? '' : 's'} stay in the project, under No section.`
      : 'It has no tasks, so nothing else changes.',
    confirmLabel: 'Delete section',
    danger: true,
  });
  if (!ok) return;
  try {
    await deleteSection(section.id);
  } catch (error) {
    toast(errorMessage(error), 'error');
    return;
  }
  page.sections = page.sections.filter(s => s.id !== section.id);
  page.tasks.forEach(t => { if (t.section_id === section.id) t.section_id = null; });
  toast('Section deleted');
  drawTasks(page);
}

// A task dragged into another section in the list
async function moveToSection(page, event) {
  page.dragging = false;
  if (event.from === event.to) return;
  const task = page.tasks.find(t => t.id === event.item.dataset.id);
  const sectionId = event.to.dataset.group || null;
  const before = task.section_id;
  task.section_id = sectionId;
  setTimeout(() => drawTasks(page), 0);
  try {
    await updateTask(task.id, { section_id: sectionId });
  } catch (error) {
    task.section_id = before;
    drawTasks(page);
    toast(errorMessage(error), 'error');
  }
}

// Adding tasks ----------------------------------------------------------------

// New tasks go to the bottom of their column, with the quick-add
// assignee and due date
async function addTask(page, title, status, sectionId = shownSectionId(page)) {
  const column = page.tasks.filter(t => !t.parent_id && t.status === status);
  const last = Math.max(0, ...column.map(t => t.position));
  try {
    const task = await createTask({
      campaign_id: page.campaign.id,
      section_id: sectionId,
      title,
      status,
      position: last + 1000,
      assignee_id: page.m.assignee || null,
      due_date: page.m.due || null,
    });
    if (!page.tasks.some(t => t.id === task.id)) page.tasks.push(task);
    drawTasks(page);
    return true;
  } catch (error) {
    toast(errorMessage(error), 'error');
    return false;
  }
}

async function quickAdd(event, page) {
  event.preventDefault();
  const input = event.target.querySelector('.quick-title');
  const title = input.value.trim();
  if (!title) return;
  input.value = '';
  if (!(await addTask(page, title, 'todo'))) input.value = title;
  input.focus();
}

// Archive: out of the everyday lists, kept for reference. Unarchive undoes it.
async function toggleArchived(page, onDone) {
  const { campaign } = page;
  const archiving = !campaign.archived_at;
  const ok = await confirmDialog(archiving
    ? {
      title: 'Archive project?',
      message: `“${campaign.name}” moves to the Archived tab and its tasks leave everyone's My tasks. Its hours stay in Dashboards, but no new time can be logged on it. You can unarchive it at any time.`,
      confirmLabel: 'Archive',
    }
    : {
      title: 'Unarchive project?',
      message: `“${campaign.name}” goes back to the project lists, and time can be logged on it again.`,
      confirmLabel: 'Unarchive',
    });
  if (!ok) return;
  const { error } = await supabase.from('campaigns')
    .update(archiving ? { archived_at: new Date().toISOString(), archived_by: state.me.id } : { archived_at: null, archived_by: null })
    .eq('id', campaign.id);
  if (error) {
    toast(errorMessage(error), 'error');
    return;
  }
  toast(archiving ? 'Project archived' : 'Project unarchived');
  onDone();
}

async function deleteCampaign(page) {
  const { campaign, tasks } = page;
  const count = tasks.length;
  const ok = await confirmDialog({
    title: 'Delete project?',
    message: `“${campaign.name}”${count ? ` and its ${count} task${count === 1 ? '' : 's'}` : ''} will be deleted for everyone. This can't be undone.`,
    confirmLabel: 'Delete',
    danger: true,
  });
  if (!ok) return;
  const { error } = await supabase.from('campaigns').delete().eq('id', campaign.id);
  if (error) {
    toast(errorMessage(error), 'error');
    return;
  }
  toast('Project deleted');
  window.location.hash = '/campaigns';
}

// Who can see a private project, shown under its title
function accessLine(access) {
  const { departments, people } = accessNames(access);
  const chips = names => names.map(n => `<span class="summary-chip">${esc(n)}</span>`).join(' ');
  const parts = [
    departments.length && `<span class="access-group"><span class="access-label">${departments.length === 1 ? 'Department' : 'Departments'}</span> ${chips(departments)}</span>`,
    people.length && `<span class="access-group"><span class="access-label">People</span> ${chips(people)}</span>`,
  ].filter(Boolean);
  return `<div class="access-line"><span class="access-label"><span aria-hidden="true">🔒</span> Who can see it</span>
    ${parts.length ? parts.join('') : '<span class="muted small">Nobody added yet</span>'}</div>`;
}
