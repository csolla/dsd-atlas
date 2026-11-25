import { supabase } from '../supabase.js';
import { state, canEditWork } from '../state.js';
import { onTasksChanged, onLiveChange } from '../realtime.js';
import { createTask, updateTask, deleteTask, byPosition, loadSections, isoDate } from '../tasks.js';
import { loadFields, loadTaskValues, saveValue, fieldInput, readFieldInput } from '../fields.js';
import { loadTasksHours } from '../time.js';
import { startTimer } from '../timer.js';
import { esc, options, fmtHours, toast, errorMessage, confirmDialog, formDialog, TASK_STATUSES } from '../ui.js';
import { loadAccess, projectAudience } from '../access.js';
import { setMentionAudience } from '../comments.js';
import { openTimeEntryForm } from './time-entry-form.js';
import { mountAttachments, mountComments } from './task-discussion.js';

// The task side panel. One at a time, opened from the campaign board/list
// and from My tasks. Every field saves when you leave it.
let current = null;

// highlight: a subtask to point out once the panel is open
export async function openTaskPanel(taskId, { highlight = null } = {}) {
  closeTaskPanel();

  const backdrop = document.createElement('div');
  backdrop.className = 'panel-backdrop';
  const panel = document.createElement('aside');
  panel.className = 'panel';
  panel.setAttribute('role', 'dialog');
  panel.setAttribute('aria-label', 'Task');
  panel.innerHTML = '<p class="muted panel-loading">Loading task…</p>';
  document.body.append(backdrop, panel);
  requestAnimationFrame(() => panel.classList.add('open'));
  backdrop.addEventListener('click', closeTaskPanel);

  current = { taskId, panel, backdrop, task: null, subtasks: [], highlight };
  const mine = current;

  let data;
  try {
    data = await loadTask(taskId);
  } catch (error) {
    panel.innerHTML = `<p class="form-error">${esc(errorMessage(error))}</p>`;
    return;
  }
  if (current !== mine) return;
  if (!data) {
    closeTaskPanel();
    toast("That task doesn't exist, or it's in a private project you can't see.", 'error');
    return;
  }
  // Subtasks open in their parent task's panel
  if (data.task.parent_id) {
    openTaskPanel(data.task.parent_id, { highlight: data.task.id });
    return;
  }

  Object.assign(current, data);
  setMentionAudience(projectAudience(data.task.campaign, data.access));
  render();
  onTasksChanged(panel, refresh, { delay: 300 });
  onLiveChange(panel, 'sections-changed', refresh, { delay: 300 });
  onLiveChange(panel, ['fields-changed', 'field-values-changed'], refresh, { delay: 300 });
  onLiveChange(panel, 'time-changed', loadHours, { delay: 300 });
  loadHours();
}

export function closeTaskPanel() {
  if (!current) return;
  const { panel, backdrop } = current;
  current = null;
  setMentionAudience(null);
  // Opened from a task link: go back to the campaign's own address (no reload)
  if (/^#\/campaigns\/[0-9a-f-]{36}\/tasks\//.test(window.location.hash)) {
    history.replaceState(null, '', window.location.hash.replace(/\/tasks\/[0-9a-f-]{36}$/, ''));
  }
  panel.classList.remove('open');
  backdrop.remove();
  setTimeout(() => panel.remove(), 200);
}

document.addEventListener('keydown', event => {
  if (event.key === 'Escape' && current && !document.querySelector('dialog[open]')) closeTaskPanel();
});
window.addEventListener('hashchange', closeTaskPanel);

// The roles used in a template's tasks, A to Z
export async function templateRoles(campaignId) {
  const { data, error } = await supabase.from('tasks').select('template_role')
    .eq('campaign_id', campaignId).not('template_role', 'is', null);
  if (error) throw error;
  return [...new Set(data.map(t => t.template_role))].sort((a, b) => a.localeCompare(b));
}

async function loadTask(taskId) {
  const { data: task, error } = await supabase
    .from('tasks').select('*, campaign:campaigns(id, name, budget, department_id, for_department_id, archived_at, private, owner_id, created_by, is_template, personal_of)').eq('id', taskId).maybeSingle();
  if (error) throw error;
  if (!task) return null;
  const { data: subtasks, error: subError } = await supabase.from('tasks').select('*').eq('parent_id', taskId);
  if (subError) throw subError;
  const access = task.campaign.private ? await loadAccess(task.campaign_id) : [];
  // Only main tasks have a section; subtasks go with their parent
  const sections = task.parent_id ? [] : await loadSections(task.campaign_id).catch(() => []);
  // The project's own fields and this task's values in them
  const [fields, values] = task.parent_id ? [[], {}] : await Promise.all([
    loadFields(task.campaign_id).catch(() => []),
    loadTaskValues(task.id).catch(() => ({})),
  ]);
  // In a template: the roles already used, to suggest them
  const roles = task.campaign.is_template ? await templateRoles(task.campaign_id).catch(() => []) : [];
  return { task, subtasks: subtasks.sort(byPosition), access, sections, fields, values, roles };
}

// People who can be assigned work (on a private project, only those who
// can see it), plus whoever is assigned already
function assigneeOptions(selectedId) {
  // Personal to-dos are always their person's (the database makes sure)
  if (current.task.campaign.personal_of) {
    const me = state.people.find(p => p.id === current.task.campaign.personal_of);
    return options({ [me?.id || '']: me?.name || 'Me' }, me?.id);
  }
  const audience = projectAudience(current.task.campaign, current.access);
  const people = state.people.filter(p => audience.includes(p) || p.id === selectedId);
  return `<option value="">Unassigned</option>${options(Object.fromEntries(people.map(p => [p.id, p.name])), selectedId)}`;
}

function render() {
  const { panel, task } = current;
  panel.innerHTML = `
    <header class="panel-header">
      <button class="btn btn-small complete-btn" type="button" data-complete aria-pressed="false">✓ Mark complete</button>
      <div class="panel-actions">
        ${task.asana_url ? `<a class="btn btn-small btn-ghost" href="${esc(task.asana_url)}" target="_blank" rel="noopener" title="This task was imported from Asana: see the original, with its full history">Open in Asana</a>` : ''}
        <button class="btn btn-small btn-ghost" type="button" data-copy-link title="Copy a link to this task">Copy link</button>
        ${canEditWork() && !task.parent_id ? '<button class="btn btn-small btn-ghost" type="button" data-duplicate title="Make a copy of this task and its subtasks, for example for the next edition">Duplicate</button>' : ''}
        <button class="btn btn-small btn-danger-outline" type="button" data-delete>Delete</button>
        <button class="icon-btn" type="button" data-close aria-label="Close">×</button>
      </div>
    </header>
    <div class="panel-body">
      <input class="panel-title" data-field="title" aria-label="Task title" maxlength="300">
      <div class="panel-props">
        <div class="prop-row"><label class="prop-label" for="tp-assignee">Assignee</label>
          <div class="prop-value"><select id="tp-assignee" data-field="assignee_id"></select></div></div>
        <div class="prop-row"><label class="prop-label" for="tp-due">Due date</label>
          <div class="prop-value"><input id="tp-due" type="date" data-field="due_date"></div></div>
        <div class="prop-row"><span class="prop-label">Project</span>
          <div class="prop-value prop-project">
            <span class="project-swatch" aria-hidden="true"></span>
            <a href="#/campaigns/${esc(task.campaign.id)}">${esc(task.campaign.name)}</a>
            <span class="section-pick" data-section-field hidden><select data-field="section_id" aria-label="Section" title="Section"></select></span>
            ${task.copied_from ? '<span class="muted small copied-from" data-copied-from>Copied by a rule from another project</span>' : ''}
          </div></div>
        <div class="prop-row"><label class="prop-label" for="tp-status">Status</label>
          <div class="prop-value"><select id="tp-status" data-field="status">${options(TASK_STATUSES, task.status)}</select></div></div>
        ${task.campaign.is_template ? `<div class="prop-row" title="Who does this task in each project made from the template: pick the person for each role when creating the project">
          <label class="prop-label" for="tp-role">Role</label>
          <div class="prop-value"><input id="tp-role" data-field="template_role" list="template-role-options" maxlength="60" placeholder="${task.parent_id ? 'Same as its main task' : 'For example: Account manager'}">
          <datalist id="template-role-options">${(current.roles || []).map(r => `<option value="${esc(r)}"></option>`).join('')}</datalist></div></div>` : ''}
        <div class="panel-props-fields" data-custom-fields hidden></div>
      </div>
      <section class="panel-description">
        <label class="panel-section-title" for="tp-description">Description</label>
        <textarea id="tp-description" data-field="description" rows="5" placeholder="What is this task about?"></textarea>
      </section>
      <section class="time-box" ${task.campaign.is_template ? 'hidden' : ''}>
        <h3>Time</h3>
        <div class="time-box-row">
          <span data-hours class="muted">Loading hours…</span>
          <span class="spacer"></span>
          <button class="btn btn-small" type="button" data-start-timer>▶ Start timer</button>
          <button class="btn btn-small" type="button" data-add-time>Add time</button>
        </div>
      </section>
      <section class="subtasks">
        <h3>Subtasks <span class="muted" data-subcount></span></h3>
        <ul class="subtask-list" data-subtasks></ul>
        <form class="subtask-add" data-add-subtask>
          <input placeholder="Add a subtask and press Enter" aria-label="New subtask" maxlength="300">
        </form>
      </section>
      <section class="attachments" data-attachments></section>
      <section class="comments" data-comments></section>
    </div>`;

  fillFields();
  renderCustomFields();
  renderSubtasks();
  if (current.highlight) {
    const row = panel.querySelector(`[data-subtasks] li[data-id="${CSS.escape(current.highlight)}"]`);
    if (row) {
      row.classList.add('is-highlight');
      setTimeout(() => row.scrollIntoView({ block: 'center', behavior: 'smooth' }), 250);
    }
  }

  panel.querySelector('[data-close]').addEventListener('click', closeTaskPanel);
  panel.querySelector('[data-delete]').addEventListener('click', removeTask);
  panel.querySelector('[data-copy-link]').addEventListener('click', () => copyTaskLink(task));
  panel.querySelector('[data-duplicate]')?.addEventListener('click', duplicateTask);
  // A copy made by a rule links to its original, if you can see it
  if (task.copied_from) {
    supabase.from('tasks').select('id, title, campaign_id, campaign:campaigns(name)').eq('id', task.copied_from).maybeSingle()
      .then(({ data }) => {
        const box = panel.querySelector('[data-copied-from]');
        if (data && box) box.innerHTML = `Copied from <a href="#/campaigns/${esc(data.campaign_id)}/tasks/${esc(data.id)}">“${esc(data.title)}” in ${esc(data.campaign?.name || 'another project')}</a>`;
      });
  }
  // Mark complete / reopen, like Asana's button: changes the Status box
  panel.querySelector('[data-complete]').addEventListener('click', () => {
    const status = panel.querySelector('[data-field="status"]');
    status.value = current.task.status === 'done' ? 'todo' : 'done';
    saveField(status);
  });
  panel.querySelectorAll('[data-field]').forEach(input => input.addEventListener('change', () => saveField(input)));
  panel.querySelector('[data-add-subtask]').addEventListener('submit', addSubtask);
  panel.querySelector('[data-custom-fields]').addEventListener('change', event => saveCustomField(event.target));
  panel.querySelector('[data-start-timer]').addEventListener('click', () =>
    startTimer({ campaign_id: task.campaign_id, task_id: task.id }));
  panel.querySelector('[data-add-time]').addEventListener('click', () =>
    openTimeEntryForm({ defaults: { campaign_id: task.campaign_id, task_id: task.id } })
      .catch(error => toast(errorMessage(error), 'error')));

  const list = panel.querySelector('[data-subtasks]');
  list.addEventListener('change', event => saveSubtaskField(event.target));
  list.addEventListener('click', event => {
    const id = event.target.closest('li')?.dataset.id;
    if (event.target.closest('[data-remove]')) removeSubtask(id);
    if (event.target.closest('[data-sub-timer]')) startTimer({ campaign_id: task.campaign_id, task_id: id });
  });
  mountAttachments(panel.querySelector('[data-attachments]'), task);
  mountComments(panel.querySelector('[data-comments]'), task);
  panel.querySelector('[data-close]').focus();
}

// Put the task's values into the fields, skipping the one being edited
function fillFields() {
  const { panel, task } = current;
  const complete = panel.querySelector('[data-complete]');
  if (complete) {
    const done = task.status === 'done';
    complete.setAttribute('aria-pressed', String(done));
    complete.textContent = done ? '✓ Completed' : '✓ Mark complete';
    complete.title = done ? 'Done. Click to reopen it' : 'Mark this task as done';
  }
  panel.querySelectorAll('[data-field]').forEach(input => {
    if (input === document.activeElement) return;
    if (input.dataset.field === 'assignee_id') input.innerHTML = assigneeOptions(task.assignee_id);
    if (input.dataset.field === 'section_id') {
      input.innerHTML = `<option value="">No section</option>${options(Object.fromEntries(current.sections.map(s => [s.id, s.name])), task.section_id)}`;
      input.closest('[data-section-field]').hidden = !current.sections.length;
    }
    input.value = task[input.dataset.field] ?? '';
  });
}

// The project's own fields (Fields button on the project page)
// The project's fields, as label / value rows under the task's details
function renderCustomFields() {
  const { panel, fields, values } = current;
  const box = panel.querySelector('[data-custom-fields]');
  box.hidden = !fields.length;
  box.innerHTML = fields.map(f => `
    <div class="prop-row ${f.type === 'multi' ? 'prop-row-top' : ''}">
      <span class="prop-label">${esc(f.name)}</span>
      <div class="prop-value">${fieldInput(f, values[f.id])}</div>
    </div>`).join('');
}

async function saveCustomField(target) {
  const el = target.closest('[data-field-id]') || target.closest('.money-input')?.querySelector('[data-field-id]');
  if (!el) return;
  const mine = current;
  const field = mine.fields.find(f => f.id === el.dataset.fieldId);
  if (!field) return;
  const value = readFieldInput(field, el);
  if (field.type === 'number' || field.type === 'money') {
    const amount = field.type === 'money' ? value?.amount : value;
    if (amount != null && !Number.isFinite(amount)) {
      toast('Type a number.', 'error');
      return;
    }
  }
  const before = mine.values[field.id];
  if (value == null) delete mine.values[field.id];
  else mine.values[field.id] = value;
  try {
    await saveValue(mine.task.id, field.id, value);
  } catch (error) {
    toast(errorMessage(error), 'error');
    if (before === undefined) delete mine.values[field.id];
    else mine.values[field.id] = before;
    if (current === mine) renderCustomFields();
  }
}

function renderSubtasks() {
  const { panel, subtasks } = current;
  const list = panel.querySelector('[data-subtasks]');
  const done = subtasks.filter(s => s.status === 'done').length;
  panel.querySelector('[data-subcount]').textContent = subtasks.length ? `${done}/${subtasks.length}` : '';

  list.innerHTML = subtasks.map(s => `
    <li class="subtask ${s.status === 'done' ? 'is-done' : ''}" data-id="${esc(s.id)}">
      <input type="checkbox" data-sub="status" ${s.status === 'done' ? 'checked' : ''} aria-label="Done">
      <input class="subtask-title" data-sub="title" value="${esc(s.title)}" aria-label="Subtask title" maxlength="300">
      <select class="subtask-assignee" data-sub="assignee_id" aria-label="Subtask assignee">${assigneeOptions(s.assignee_id)}</select>
      <input class="subtask-due" type="date" data-sub="due_date" value="${esc(s.due_date || '')}" aria-label="Subtask due date">
      <button class="icon-btn subtask-timer" type="button" data-sub-timer aria-label="Start timer on this subtask" title="Start timer">▶</button>
      <button class="icon-btn" type="button" data-remove aria-label="Remove subtask">×</button>
    </li>`).join('');
}

// A link that opens the campaign with this task open
async function copyTaskLink(task) {
  const url = `${window.location.origin}${window.location.pathname}#/campaigns/${task.campaign_id}/tasks/${task.id}`;
  try {
    await navigator.clipboard.writeText(url);
    toast('Link copied. Paste it in Slack or an email.');
  } catch {
    window.prompt('Copy this link:', url);
  }
}

// Hours on the task and its subtasks. Tasks with hours can't be deleted.
async function loadHours() {
  const mine = current;
  if (!mine?.task) return;
  let hours;
  try {
    hours = await loadTasksHours([mine.task.id, ...mine.subtasks.map(s => s.id)]);
  } catch {
    return;
  }
  if (current !== mine) return;
  mine.hours = hours;
  mine.panel.querySelector('[data-hours]').textContent = hours
    ? `${fmtHours(hours)} logged${mine.subtasks.length ? ' (including subtasks)' : ''}`
    : 'No hours logged yet';
  const remove = mine.panel.querySelector('[data-delete]');
  remove.disabled = hours > 0;
  remove.title = hours > 0 ? "This task has hours logged, so it can't be deleted. Set it to Done instead." : '';
}

// Someone (maybe you, in another view) changed a task: reload what's shown
async function refresh() {
  if (!current?.task) return;
  const mine = current;
  let data;
  try {
    data = await loadTask(mine.taskId);
  } catch {
    return;
  }
  if (current !== mine) return;
  if (!data) {
    closeTaskPanel();
    toast('This task was deleted.');
    return;
  }
  data.task.campaign = mine.task.campaign;
  Object.assign(current, data);
  fillFields();
  if (!mine.panel.querySelector('[data-custom-fields]').contains(document.activeElement)) renderCustomFields();
  // Wait to redraw subtasks while one is being edited
  if (!mine.panel.querySelector('[data-subtasks]').contains(document.activeElement)) renderSubtasks();
  loadHours();
}

async function saveField(input) {
  const field = input.dataset.field;
  let value = input.value;
  if (field === 'title') {
    value = value.trim();
    if (!value) {
      input.value = current.task.title;
      return;
    }
  } else if (field === 'description' || field === 'template_role') {
    value = value.trim() || null;
  } else if (field === 'assignee_id' || field === 'due_date' || field === 'section_id') {
    value = value || null;
  }
  if (value === current.task[field]) return;

  const mine = current;
  try {
    const saved = await updateTask(mine.task.id, { [field]: value });
    Object.assign(mine.task, saved, { campaign: mine.task.campaign });
    if (field === 'status' && current === mine) fillFields();
  } catch (error) {
    toast(errorMessage(error), 'error');
    input.value = mine.task[field] ?? '';
  }
}

async function saveSubtaskField(input) {
  const field = input.dataset.sub;
  if (!field) return;
  const id = input.closest('li').dataset.id;
  const subtask = current.subtasks.find(s => s.id === id);
  let value;
  if (field === 'status') value = input.checked ? 'done' : 'todo';
  else if (field === 'title') {
    value = input.value.trim();
    if (!value) {
      input.value = subtask.title;
      return;
    }
  } else value = input.value || null;

  try {
    Object.assign(subtask, await updateTask(id, { [field]: value }));
    if (field === 'status') renderSubtasks();
  } catch (error) {
    toast(errorMessage(error), 'error');
    renderSubtasks();
  }
}

async function addSubtask(event) {
  event.preventDefault();
  const input = event.target.querySelector('input');
  const title = input.value.trim();
  if (!title) return;
  const mine = current;
  const last = mine.subtasks[mine.subtasks.length - 1];
  input.value = '';
  try {
    const subtask = await createTask({
      campaign_id: mine.task.campaign_id,
      parent_id: mine.task.id,
      title,
      position: last ? last.position + 1000 : 1000,
    });
    if (current !== mine) return;
    mine.subtasks.push(subtask);
    renderSubtasks();
  } catch (error) {
    input.value = title;
    toast(errorMessage(error), 'error');
  }
}

async function removeSubtask(id) {
  const mine = current;
  try {
    await deleteTask(id);
    mine.subtasks = mine.subtasks.filter(s => s.id !== id);
    if (current === mine) renderSubtasks();
  } catch (error) {
    toast(errorMessage(error), 'error');
  }
}

// A copy of this task: same project, section, assignee, description, role
// and fields, plus its subtasks, all as To do, placed just after it. A new
// due date moves the subtasks' dates by the same number of days. Comments,
// files and time stay with the original.
const shiftDate = (iso, days) => {
  if (!iso) return null;
  const [y, m, d] = iso.split('-').map(Number);
  return isoDate(new Date(y, m - 1, d + days));
};

function duplicateTask() {
  const { task, subtasks, values } = current;
  const subs = subtasks.length;
  formDialog({
    title: 'Duplicate task',
    submitLabel: 'Duplicate',
    body: `
      <label class="field"><span>Title</span>
        <input name="title" required maxlength="300" value="${esc(task.title)}"></label>
      <label class="field"><span>Due date</span>
        <input type="date" name="due" value="${esc(task.due_date || '')}"></label>
      <p class="muted small form-note">Copies its description, section, assignee and fields${subs ? `, and its ${subs} subtask${subs === 1 ? '' : 's'}` : ''}, all as To do.${task.due_date && subs ? ' Subtask dates move by as many days as the due date.' : ''} Comments, files and time aren't copied.</p>`,
    onSubmit: async form => {
      const title = form.elements.title.value.trim();
      if (!title) return 'Give the copy a title.';
      const due = form.elements.due.value || null;
      const days = task.due_date && due ? Math.round((new Date(due) - new Date(task.due_date)) / 86400000) : 0;
      let copy;
      try {
        copy = await createTask({
          campaign_id: task.campaign_id, section_id: task.section_id, title, description: task.description,
          assignee_id: task.assignee_id, due_date: due, status: 'todo', position: Number(task.position) + 1,
          template_role: task.template_role ?? null,
        });
        for (const s of subtasks) {
          await createTask({
            campaign_id: task.campaign_id, parent_id: copy.id, title: s.title, description: s.description,
            assignee_id: s.assignee_id, due_date: shiftDate(s.due_date, days), status: 'todo', position: s.position,
            template_role: s.template_role ?? null,
          });
        }
        for (const [fieldId, value] of Object.entries(values || {})) await saveValue(copy.id, fieldId, value);
      } catch (error) {
        return copy ? `The task was copied, but not completely: ${errorMessage(error)}` : errorMessage(error);
      }
      toast(`Duplicated: ${title}`, 'success');
      openTaskPanel(copy.id);
    },
  });
}

async function removeTask() {
  const { task, subtasks } = current;
  const ok = await confirmDialog({
    title: 'Delete task?',
    message: `“${task.title}”${subtasks.length ? ` and its ${subtasks.length} subtask${subtasks.length === 1 ? '' : 's'}` : ''} will be deleted for everyone. This can't be undone.`,
    confirmLabel: 'Delete',
    danger: true,
  });
  if (!ok) return;
  try {
    await deleteTask(task.id);
    closeTaskPanel();
    toast('Task deleted');
  } catch (error) {
    toast(errorMessage(error), 'error');
  }
}
