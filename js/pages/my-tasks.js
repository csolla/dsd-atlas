import { supabase } from '../supabase.js';
import { state } from '../state.js';
import { onTasksChanged, onLiveChange } from '../realtime.js';
import { createTask, updateTask, effectiveDue, dueGroup, isOverdue, todayIso, friendlyDue, DUE_GROUPS } from '../tasks.js';
import { weekMinutes, weekStart, addDays } from '../time.js';
import { availability, loadHolidays, loadTimeOff } from '../capacity.js';
import { startTimer } from '../timer.js';
import { esc, fmtDate, fmtHours, toast, errorMessage, TASK_STATUSES } from '../ui.js';
import { unitLine } from '../departments.js';
import { openTaskPanel } from './task-panel.js';

const SHOW_DONE_KEY = 'my-tasks-show-completed';
const COMPLETED_DAYS = 14;

function savedShowDone() {
  try { return localStorage.getItem(SHOW_DONE_KEY) === '1'; } catch { return false; }
}


// Home page: your own to-dos in a box at the top, then everything assigned
// to you (tasks and subtasks) across projects
export async function renderMyTasks(el) {
  const page = { el, items: [], showDone: savedShowDone(), ticking: false, todosId: null };

  el.innerHTML = `
    <div class="page-header my-tasks-header">
      <div>
        <h1>My tasks</h1>
        <p class="task-summary" data-summary></p>
      </div>
      <a class="week-card" href="#/my-time" data-week-card title="Open My time">
        <span class="muted small">Logged this week</span>
        <strong data-week-hours>…</strong>
        <span class="mini-meter" aria-hidden="true"><span data-week-bar style="width:0%"></span></span>
      </a>
    </div>
    <div class="list-toolbar">
      <label class="toggle">
        <input type="checkbox" data-show-done ${page.showDone ? 'checked' : ''}>
        Show completed (last ${COMPLETED_DAYS} days)
      </label>
    </div>
    <section class="card todo-box" aria-labelledby="todo-box-title" data-todo-box hidden>
      <div class="todo-box-head">
        <h2 id="todo-box-title">My to-dos</h2>
        <span class="private-flag"><span aria-hidden="true">🔒</span> Only you can see these</span>
      </div>
      <form class="todo-add" data-todo-add>
        <input class="quick-title" name="title" placeholder="Add a to-do and press Enter" aria-label="New to-do" maxlength="300">
        <input type="date" name="due" aria-label="Due date (optional)">
        <button class="btn btn-primary" type="submit">Add</button>
      </form>
      <ul class="my-task-list todo-list" data-todos></ul>
    </section>
    <h2 class="from-projects-title">From projects</h2>
    <div data-list><p class="muted">Loading your tasks…</p></div>`;

  el.querySelector('[data-todo-add]').addEventListener('submit', event => addTodo(event, page));

  el.querySelector('[data-show-done]').addEventListener('change', event => {
    page.showDone = event.target.checked;
    try { localStorage.setItem(SHOW_DONE_KEY, page.showDone ? '1' : '0'); } catch { /* not saved; fine */ }
    draw(page);
  });

  loadWeekHours(el);
  onLiveChange(el, 'time-changed', () => loadWeekHours(el));
  await load(page);
  onTasksChanged(el, () => load(page), { isBusy: () => page.ticking });
}

// Hours logged this week against the hours you're expected to work
// (your working days, minus bank holidays and time off)
async function loadWeekHours(el) {
  const start = weekStart(todayIso());
  const end = addDays(start, 6);
  try {
    const [minutes, holidays, timeOff] = await Promise.all([
      weekMinutes(state.me.id, start),
      loadHolidays(start, end),
      loadTimeOff({ from: start, to: end, personId: state.me.id }),
    ]);
    const logged = minutes / 60;
    const expected = availability(state.me, start, end, holidays, timeOff).hours;
    el.querySelector('[data-week-hours]').textContent = expected
      ? `${fmtHours(logged)} of ${fmtHours(expected)}` : fmtHours(logged);
    el.querySelector('[data-week-bar]').style.width = `${expected ? Math.min(100, logged / expected * 100) : 0}%`;
  } catch { /* leave the placeholder */ }
}

async function load(page) {
  const [{ data, error }, todos] = await Promise.all([
    supabase
      .from('tasks')
      .select(`id, title, status, due_date, parent_id, position, campaign_id, updated_at,
        campaign:campaigns(id, name, budget, department_id, for_department_id, archived_at, is_template, personal_of),
        parent:parent_id(id, title, due_date)`)
      .eq('assignee_id', state.me.id),
    // Your to-do list's project, made the first time (20_personal_todos.sql)
    page.todosId ? { data: page.todosId } : supabase.rpc('my_todos'),
  ]);
  page.todosId = todos.data || null;
  page.el.querySelector('[data-todo-box]').hidden = !page.todosId;
  if (error) {
    page.el.querySelector('[data-list]').innerHTML = `<p class="form-error">${esc(errorMessage(error))}</p>`;
    return;
  }
  // Tasks of archived projects and templates drop out of My tasks
  page.items = data.filter(item => !item.campaign?.archived_at && !item.campaign?.is_template)
    .map(item => ({ ...item, due: effectiveDue(item, item.parent) }));
  draw(page);
}

function drawSummary(page, open) {
  const count = key => open.filter(i => dueGroup(i.due) === key).length;
  const parts = [
    count('overdue') && `<span class="summary-chip is-danger">${count('overdue')} overdue</span>`,
    count('today') && `<span class="summary-chip">${count('today')} due today</span>`,
    count('week') && `<span class="summary-chip">${count('week')} this week</span>`,
  ].filter(Boolean);
  page.el.querySelector('[data-summary]').innerHTML = parts.length
    ? parts.join('')
    : `<span class="muted">${open.length ? 'Nothing due this week.' : 'Nothing open assigned to you.'}</span>`;
}

// todo: a row in the My to-dos box, which needs no project name
function row(item, todo = false) {
  const done = item.status === 'done';
  const late = isOverdue(item.due, item.status);
  return `
    <li class="my-task ${done ? 'is-done' : ''}" data-id="${esc(item.id)}" tabindex="0">
      <label class="tick" title="${done ? 'Mark as not done' : 'Mark as done'}">
        <input type="checkbox" data-done ${done ? 'checked' : ''} aria-label="Done: ${esc(item.title)}">
      </label>
      <div class="my-task-main">
        <span class="task-title">${item.parent ? '<span class="subtask-mark" title="Subtask" aria-label="Subtask">↳</span>' : ''}${esc(item.title)}</span>
        ${item.parent ? `<span class="parent-line">in ${esc(item.parent.title)}</span>` : ''}
      </div>
      <div class="my-task-campaign">${todo ? '' : `
        <span class="campaign-name">${esc(item.campaign?.name || '')}</span>
        ${item.campaign ? unitLine(item.campaign) : ''}`}
      </div>
      <span class="my-task-status"><span class="status status-task-${item.status}">${esc(TASK_STATUSES[item.status])}</span></span>
      <span class="due ${late ? 'overdue' : ''}" ${item.due ? `title="Due ${esc(fmtDate(item.due))}"` : ''}>${esc(friendlyDue(item.due, item.status))}</span>
      ${done ? '<span></span>' : `<button class="icon-btn row-timer" type="button" data-timer title="Start timer" aria-label="Start timer on ${esc(item.title)}">▶</button>`}
    </li>`;
}

const byDue = (a, b) => (a.due || '9999').localeCompare(b.due || '9999') || a.title.localeCompare(b.title);

function draw(page) {
  const list = page.el.querySelector('[data-list]');
  const since = addDays(todayIso(), -COMPLETED_DAYS);
  const recentlyDone = i => i.status === 'done' && i.updated_at.slice(0, 10) >= since;
  drawSummary(page, page.items.filter(i => i.status !== 'done'));
  drawTodos(page, page.items.filter(i => i.campaign?.personal_of), recentlyDone);

  // Below the box: tasks from projects only
  const items = page.items.filter(i => !i.campaign?.personal_of);
  const open = items.filter(i => i.status !== 'done');
  const done = items.filter(recentlyDone);
  if (!open.length && !(page.showDone && done.length)) {
    list.innerHTML = `<div class="empty-state"><p>${items.length
      ? 'All done. Nothing open is assigned to you in projects.'
      : 'Nothing is assigned to you in projects yet. Tasks assigned to you in any project will show up here.'}</p></div>`;
    return;
  }

  const groups = Object.entries(DUE_GROUPS)
    .map(([key, label]) => ({ key, label, items: open.filter(i => dueGroup(i.due) === key).sort(byDue) }))
    .filter(g => g.items.length);
  if (page.showDone && done.length) {
    groups.push({
      key: 'done',
      label: `Completed in the last ${COMPLETED_DAYS} days`,
      items: done.sort((a, b) => b.updated_at.localeCompare(a.updated_at)),
    });
  }

  list.innerHTML = groups.map(group => `
    <section class="due-group due-group-${group.key}">
      <h2>${esc(group.label)} <span class="muted">${group.items.length}</span></h2>
      <ul class="my-task-list">${group.items.map(item => row(item)).join('')}</ul>
    </section>`).join('');

  wireRows(page, list);
}

// The My to-dos box: open ones soonest first, then recently done ones if shown
function drawTodos(page, todos, recentlyDone) {
  const box = page.el.querySelector('[data-todos]');
  const open = todos.filter(i => i.status !== 'done').sort(byDue);
  const done = page.showDone ? todos.filter(recentlyDone).sort((a, b) => b.updated_at.localeCompare(a.updated_at)) : [];
  box.innerHTML = open.length || done.length
    ? [...open, ...done].map(item => row(item, true)).join('')
    : `<li class="todo-empty">${todos.length ? 'All done.' : 'Nothing on your list yet.'} Add anything you need to do that isn't part of a project.</li>`;
  wireRows(page, box);
}

async function addTodo(event, page) {
  event.preventDefault();
  const form = event.target;
  const title = form.elements.title.value.trim();
  if (!title || !page.todosId) return;
  const due = form.elements.due.value || null;
  const last = Math.max(0, ...page.items.filter(i => i.campaign_id === page.todosId).map(i => i.position || 0));
  form.elements.title.value = '';
  try {
    const task = await createTask({
      campaign_id: page.todosId, title, status: 'todo', position: last + 1000, due_date: due, assignee_id: state.me.id,
    });
    if (!page.items.some(i => i.id === task.id)) {
      page.items.push({ ...task, campaign: { id: page.todosId, personal_of: state.me.id }, parent: null, due: task.due_date });
    }
    draw(page);
  } catch (error) {
    form.elements.title.value = title;
    toast(errorMessage(error), 'error');
  }
  form.elements.title.focus();
}

function wireRows(page, list) {
  list.querySelectorAll('.my-task').forEach(li => {
    const item = page.items.find(i => i.id === li.dataset.id);
    // A subtask opens its main task's panel, with the subtask highlighted
    const openPanel = () => openTaskPanel(item.id);
    li.addEventListener('click', event => { if (!event.target.closest('input, label, button')) openPanel(); });
    li.addEventListener('keydown', event => { if (event.key === 'Enter' && event.target === li) openPanel(); });
    li.querySelector('[data-done]').addEventListener('change', event => tick(page, item, event.target.checked));
    li.querySelector('[data-timer]')?.addEventListener('click', () =>
      startTimer({ campaign_id: item.campaign_id, task_id: item.id }));
  });
}

// Tick done in place, with Undo. Unticking puts back the status it had.
async function tick(page, item, isDone) {
  const before = item.status;
  const next = isDone ? 'done' : (item.statusBeforeDone || 'todo');
  if (isDone) item.statusBeforeDone = before;
  item.status = next;
  page.ticking = true;
  try {
    await updateTask(item.id, { status: next });
    if (isDone) {
      toast(`Done: ${item.title}`, 'success', { action: { label: 'Undo', onClick: () => tick(page, item, false) } });
    }
  } catch (error) {
    item.status = before;
    toast(errorMessage(error), 'error');
  }
  setTimeout(() => {
    page.ticking = false;
    draw(page);
  }, isDone ? 600 : 0);
}
