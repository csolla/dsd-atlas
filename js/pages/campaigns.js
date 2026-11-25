import { supabase } from '../supabase.js';
import { state, canEditWork, personById } from '../state.js';
import { onTasksChanged, onLiveChange } from '../realtime.js';
import { tasksDonePct, todayIso } from '../tasks.js';
import { loadCampaignHours } from '../time.js';
import { loadTeamSettings } from '../capacity.js';
import {
  esc, options, statusPill, avatar, fmtHours, fmtCompactRange, toast, errorMessage, formDialog,
  CAMPAIGN_STATUSES, fitToScreen,
} from '../ui.js';
import {
  BUSINESS_UNITS, FOR_BOTH, departmentById, departmentByKey, isMarketing, unitLine,
} from '../departments.js';
import { loadAccess, saveAccess, canManageAccess, accessSummary } from '../access.js';
import { isFavourite, starButton, wireStars, onFavouritesChanged } from '../favourites.js';

// Kept between visits so the list looks the same when coming back to it
const filters = { search: '', dept: '', bu: '', owner: '', view: 'active', mine: false, sort: 'start', dir: 'desc' };

const VIEWS = {
  active: { label: 'Active', statuses: ['planned', 'in_progress'] },
  closed: { label: 'Done & on hold', statuses: ['done', 'on_hold'] },
  all: { label: 'All', statuses: null },
  archived: { label: 'Archived', statuses: null, archived: true },
  templates: { label: 'Templates', statuses: null, template: true },
};

// Main tasks (not subtasks) of every campaign, for the "% of tasks done" column
async function loadTaskProgress() {
  const { data, error } = await supabase.from('tasks').select('campaign_id, parent_id, status').is('parent_id', null);
  if (error) throw error;
  const byCampaign = {};
  data.forEach(t => { (byCampaign[t.campaign_id] ||= []).push(t); });
  return Object.fromEntries(Object.entries(byCampaign).map(([id, tasks]) => [id, tasksDonePct(tasks)]));
}

// One header line (title, tabs, New template / New project), the filters,
// then the table, which fills the screen with its column names pinned
// (Carlota, 25 Nov)
export async function renderCampaigns(el) {
  const owners = state.people.filter(p => p.active && p.role !== 'director');
  el.innerHTML = `
    <div class="projects-head">
      <h1>Projects</h1>
      <nav class="tabs" aria-label="Which projects" data-views></nav>
      <span class="spacer"></span>
      ${canEditWork() ? `<div class="page-actions">
        <button class="btn" type="button" data-new-template>New template</button>
        <button class="btn btn-primary" type="button" data-new>New project</button></div>` : ''}
    </div>
    <div class="filters">
      <input class="search" type="search" placeholder="Search projects" aria-label="Search projects" value="${esc(filters.search)}">
      <select data-filter="dept" aria-label="Department">
        <option value="">All departments</option>${options(Object.fromEntries(state.departments.map(d => [d.id, d.name])), filters.dept)}
      </select>
      <select data-filter="bu" aria-label="Business unit">
        <option value="">All business units</option>${options(BUSINESS_UNITS, filters.bu)}
      </select>
      <select data-filter="owner" aria-label="Owner">
        <option value="">All owners</option>${options(Object.fromEntries(owners.map(p => [p.id, p.name])), filters.owner)}
      </select>
      <label class="toggle"><input type="checkbox" data-mine ${filters.mine ? 'checked' : ''}> Only mine</label>
      <button class="btn btn-ghost" type="button" data-clear>Clear</button>
    </div>
    <div data-list><p class="muted">Loading projects…</p></div>`;

  const list = el.querySelector('[data-list]');
  el.querySelector('[data-new]')?.addEventListener('click', () =>
    openCampaignForm(null, saved => { window.location.hash = `/campaigns/${saved.id}`; }));
  el.querySelector('[data-new-template]')?.addEventListener('click', () =>
    openCampaignForm(null, saved => { window.location.hash = `/campaigns/${saved.id}`; }, { asTemplate: true }));

  const [campaignResult, progressResult, hoursResult] = await Promise.allSettled([
    supabase.from('campaigns').select('*').order('name'),
    loadTaskProgress(),
    loadCampaignHours(),
  ]);
  const error = campaignResult.reason || campaignResult.value?.error || progressResult.reason || hoursResult.reason;
  if (error) {
    list.innerHTML = `<p class="form-error">${esc(errorMessage(error))}</p>`;
    return;
  }
  const data = { campaigns: campaignResult.value.data, progress: progressResult.value, hours: hoursResult.value };

  const draw = () => {
    drawViews(el, data, draw);
    drawList(list, data, draw);
  };
  onTasksChanged(el, async () => {
    try {
      data.progress = await loadTaskProgress();
      draw();
    } catch { /* keep what's shown */ }
  });
  onLiveChange(el, 'time-changed', async () => {
    try {
      data.hours = await loadCampaignHours();
      draw();
    } catch { /* keep what's shown */ }
  });
  // Starring moves a project to the top
  onFavouritesChanged(() => { if (el.isConnected) draw(); });
  el.querySelector('.search').addEventListener('input', event => { filters.search = event.target.value; draw(); });
  el.querySelectorAll('[data-filter]').forEach(select =>
    select.addEventListener('change', () => { filters[select.dataset.filter] = select.value; draw(); }));
  el.querySelector('[data-mine]').addEventListener('change', event => { filters.mine = event.target.checked; draw(); });
  el.querySelector('[data-clear]').addEventListener('click', () => {
    Object.assign(filters, { search: '', dept: '', bu: '', owner: '', mine: false });
    el.querySelector('.search').value = '';
    el.querySelector('[data-mine]').checked = false;
    el.querySelectorAll('[data-filter]').forEach(select => { select.value = ''; });
    draw();
  });
  draw();
  const refit = () => (el.isConnected ? fitTable(list) : window.removeEventListener('resize', refit));
  window.addEventListener('resize', refit);
}

function fitTable(list) {
  fitToScreen(list.querySelector('.list-scroll'), list.querySelector('.table-note')?.offsetHeight || 0);
}

// Everything except the Active / Done / All tab
function matchesFilters(campaign) {
  const q = filters.search.trim().toLowerCase();
  return (!filters.dept || campaign.department_id === filters.dept)
    && (!filters.bu || departmentById(campaign.department_id)?.business_unit === filters.bu)
    && (!filters.owner || campaign.owner_id === filters.owner)
    && (!filters.mine || campaign.owner_id === state.me.id)
    && (!q || `${campaign.name} ${campaign.description || ''}`.toLowerCase().includes(q));
}

// Personal to-dos never show here (they're each person's first page).
// Templates only show under Templates; archived projects only under Archived
const inView = (campaign, view) => !campaign.personal_of && (VIEWS[view].template
  ? campaign.is_template
  : !campaign.is_template && Boolean(campaign.archived_at) === Boolean(VIEWS[view].archived)
    && (!VIEWS[view].statuses || VIEWS[view].statuses.includes(campaign.status)));

function drawViews(el, data, draw) {
  const filtered = data.campaigns.filter(matchesFilters);
  const nav = el.querySelector('[data-views]');
  nav.innerHTML = Object.entries(VIEWS).map(([key, v]) => `
    <button type="button" class="tab ${filters.view === key ? 'active' : ''}" data-view="${key}" aria-pressed="${filters.view === key}">
      ${esc(v.label)} <span class="tab-count">${filtered.filter(c => inView(c, key)).length}</span>
    </button>`).join('');
  nav.querySelectorAll('[data-view]').forEach(button => button.addEventListener('click', () => {
    filters.view = button.dataset.view;
    draw();
  }));
}


// Past its end date but not marked Done or On hold
function endedFlag(c) {
  if (!c.end_date || c.status === 'done' || c.status === 'on_hold') return '';
  const today = todayIso();
  if (c.end_date >= today) return '';
  const days = Math.round((new Date(today) - new Date(c.end_date)) / 86400000);
  return `<span class="ended-flag" title="Past its end date but not marked Done">Ended ${days} day${days === 1 ? '' : 's'} ago</span>`;
}

function bar(pct, level) {
  return `<span class="mini-meter meter-${level}" aria-hidden="true"><span style="width:${Math.min(100, pct)}%"></span></span>`;
}

const SORTS = {
  name: c => c.name.toLowerCase(),
  owner: c => personById(c.owner_id)?.name.toLowerCase() || '~',
  start: c => c.start_date || '',
  status: c => Object.keys(CAMPAIGN_STATUSES).indexOf(c.status),
  hours: c => c.hoursPct ?? c.logged / 1000,
  tasks: c => c.tasksPct ?? -1,
};

function drawList(list, data, draw) {
  if (!data.campaigns.length) {
    list.innerHTML = `<div class="empty-state"><p>No projects yet.${canEditWork() ? ' Create the first one with “New project”.' : ''}</p></div>`;
    return;
  }
  const shown = data.campaigns
    .filter(c => matchesFilters(c) && inView(c, filters.view))
    .map(c => {
      const logged = Number(data.hours[c.id]?.hours || 0);
      const planned = Number(c.planned_hours);
      return { ...c, logged, planned, hoursPct: planned > 0 ? logged / planned * 100 : null, tasksPct: data.progress[c.id] ?? null };
    });
  if (!shown.length) {
    if (filters.view === 'templates') {
      list.innerHTML = `<div class="empty-state"><p>No templates match.${canEditWork() ? ' Create one with “New template”, or open a project and use “Save as template”.' : ''}</p></div>`;
      return;
    }
    list.innerHTML = `<div class="empty-state"><p>No ${filters.view === 'all' ? '' : `${VIEWS[filters.view].label.toLowerCase()} `}projects match.
      ${filters.view !== 'all' ? 'Try the <strong>All</strong> tab or clear the filters.' : 'Try clearing the filters.'}</p></div>`;
    return;
  }

  const key = SORTS[filters.sort];
  // Your favourites first, then the chosen order
  shown.sort((a, b) => {
    const fav = Number(isFavourite(b.id)) - Number(isFavourite(a.id));
    if (fav) return fav;
    const x = key(a);
    const y = key(b);
    const order = x < y ? -1 : x > y ? 1 : a.name.localeCompare(b.name);
    return filters.dir === 'asc' ? order : -order;
  });

  const header = (sortKey, label, cls = '') => {
    const active = filters.sort === sortKey;
    const arrow = active ? (filters.dir === 'asc' ? '↑' : '↓') : '';
    return `<th class="${cls}" aria-sort="${active ? (filters.dir === 'asc' ? 'ascending' : 'descending') : 'none'}">
      <button type="button" class="sort-btn" data-sort="${sortKey}">${label} <span aria-hidden="true">${arrow}</span></button></th>`;
  };

  // Keep the reader's place when the list redraws (a live update, a sort)
  const before = list.querySelector('.list-scroll');
  const place = before ? [before.scrollTop, before.scrollLeft] : null;
  list.innerHTML = `
    <div class="table-wrap list-scroll">
      <table class="table campaign-table">
        <thead>
          <tr>
            ${header('name', 'Project')}${header('owner', 'Owner')}${header('start', 'Dates')}${header('status', 'Status')}
            ${header('hours', 'Hours logged / planned', 'meter-head')}${header('tasks', 'Tasks done', 'meter-head')}
          </tr>
        </thead>
        <tbody>
          ${shown.map(c => {
            const owner = personById(c.owner_id);
            const hoursLevel = c.hoursPct == null ? 'none' : c.hoursPct > 100 ? 'critical' : c.hoursPct >= 80 ? 'warning' : 'good';
            return `
              <tr class="clickable" data-href="#/campaigns/${esc(c.id)}">
                <td data-label="Project"><div class="project-cell">
                  ${c.is_template ? '' : starButton(c.id, c.name)}
                  <a class="row-link campaign-link" href="#/campaigns/${esc(c.id)}">${esc(c.name)}</a>
                  ${unitLine(c)}
                  ${c.private ? '<span class="private-flag"><span aria-hidden="true">🔒</span> Private</span>' : ''}
                  ${c.is_template ? '<span class="template-flag">Template</span>' : endedFlag(c)}
                </div></td>
                <td data-label="Owner">${owner ? `<span class="person">${avatar(owner, 24)}${esc(owner.name)}</span>` : '<span class="muted">—</span>'}</td>
                <td data-label="Dates" class="nowrap">${esc(fmtCompactRange(c.start_date, c.end_date))}</td>
                <td data-label="Status">${statusPill(c.status)}</td>
                <td data-label="Hours" class="meter-cell">
                  ${c.hoursPct == null ? '' : bar(c.hoursPct, hoursLevel)}
                  <span class="nowrap ${hoursLevel === 'critical' ? 'over-plan' : ''}">${fmtHours(c.logged)}${c.planned ? ` / ${fmtHours(c.planned)}` : ''}</span>
                </td>
                <td data-label="Tasks done" class="meter-cell">
                  ${c.tasksPct == null ? '<span class="muted">No tasks</span>' : `${bar(c.tasksPct, 'progress')}<span>${c.tasksPct}%</span>`}
                </td>
              </tr>`;
          }).join('')}
        </tbody>
      </table>
    </div>
    <p class="muted small table-note">${shown.length} project${shown.length === 1 ? '' : 's'}. Bars turn amber at 80% of planned hours and red over plan.</p>`;
  fitTable(list);
  const scroller = list.querySelector('.list-scroll');
  if (place) [scroller.scrollTop, scroller.scrollLeft] = place;

  wireStars(list);
  list.querySelectorAll('[data-sort]').forEach(button => button.addEventListener('click', () => {
    if (filters.sort === button.dataset.sort) filters.dir = filters.dir === 'asc' ? 'desc' : 'asc';
    else {
      filters.sort = button.dataset.sort;
      filters.dir = ['name', 'owner', 'status'].includes(filters.sort) ? 'asc' : 'desc';
    }
    draw();
  }));
  // The whole row opens the campaign
  list.querySelectorAll('tr[data-href]').forEach(row => row.addEventListener('click', event => {
    if (!event.target.closest('a, button')) window.location.hash = row.dataset.href.slice(1);
  }));
}

// Who a campaign can be for, as groups of { value: label }. Marketing
// campaigns: Education, Planning Center, Delight (Planning Center budget)
// or both (hours split by the Team rules) count against a budget; any other
// department counts against neither. Any other department's campaign: its own department first.
function forGroups(departmentId, sharedSplit) {
  const own = departmentById(departmentId);
  if (isMarketing(departmentId)) {
    const edu = departmentByKey('education');
    const pc = departmentByKey('planning_center');
    const delight = departmentByKey('delight');
    return [
      ['Counts against a Marketing budget', {
        [edu?.id]: 'Education',
        [pc?.id]: 'Planning Center',
        [delight?.id]: 'Delight (Planning Center budget)',
        [FOR_BOTH]: `Education + Planning Center (hours split ${sharedSplit} / ${100 - sharedSplit})`,
      }],
      ['Other departments (no budget)', Object.fromEntries(state.departments
        .filter(d => ![edu?.id, pc?.id, delight?.id].includes(d.id))
        .map(d => [d.id, d.id === departmentId ? `${d.name} (own department)` : d.name]))],
    ];
  }
  const others = state.departments.filter(d => d.id !== departmentId);
  return [[null, Object.fromEntries([...(own ? [[own.id, `${own.name} (own department)`]] : []), ...others.map(d => [d.id, d.name])])]];
}

const forChoices = (departmentId, sharedSplit) =>
  Object.assign({}, ...forGroups(departmentId, sharedSplit).map(([, choices]) => choices));

function forOptions(departmentId, sharedSplit, selected) {
  return forGroups(departmentId, sharedSplit).map(([label, choices]) => (label
    ? `<optgroup label="${esc(label)}">${options(choices, selected)}</optgroup>`
    : options(choices, selected))).join('');
}

// The "For" value a campaign has now
function currentFor(c) {
  if (c.budget === 'shared') return FOR_BOTH;
  return c.for_department_id || c.department_id;
}

// New campaign (campaign = null) or edit an existing one.
// onSaved receives the saved campaign row.
// A dropdown to add items, with each added one shown as a chip that can be
// removed. Chips carry hidden inputs named `name`, which the form reads.
function setUpPicker(dialog, name, placeholder, items, startIds) {
  const select = dialog.querySelector(`[data-pick="${name}"]`);
  const chips = dialog.querySelector(`[data-chips="${name}"]`);
  const picked = new Set(startIds.filter(id => items.some(i => i.id === id)));
  const byName = (a, b) => a.name.localeCompare(b.name);
  const draw = () => {
    const left = items.filter(i => !picked.has(i.id)).sort(byName);
    const groups = [...new Set(left.map(i => i.group).filter(Boolean))].sort();
    const opt = i => `<option value="${esc(i.id)}">${esc(i.name)}</option>`;
    select.innerHTML = `<option value="">${left.length ? placeholder : 'Everyone is added'}</option>${groups.length
      ? groups.map(g => `<optgroup label="${esc(g)}">${left.filter(i => i.group === g).map(opt).join('')}</optgroup>`).join('')
      : left.map(opt).join('')}`;
    select.disabled = !left.length;
    chips.innerHTML = items.filter(i => picked.has(i.id)).sort(byName).map(i => `
      <span class="filter-chip">${esc(i.name)}<input type="hidden" name="${name}" value="${esc(i.id)}">
        <button type="button" class="icon-btn" data-remove="${esc(i.id)}" aria-label="Remove ${esc(i.name)}">×</button></span>`).join('');
  };
  select.addEventListener('change', () => {
    if (!select.value) return;
    picked.add(select.value);
    draw();
    select.focus();
  });
  chips.addEventListener('click', event => {
    const button = event.target.closest('[data-remove]');
    if (!button) return;
    picked.delete(button.dataset.remove);
    draw();
    select.focus();
  });
  draw();
}

// A template's roles, each with a person picker. Left on "As in the
// template", a role's tasks keep the template's usual person.
async function showRoles(box, templateId) {
  box.hidden = true;
  box.innerHTML = '';
  if (!templateId) return;
  const { data, error } = await supabase.from('tasks').select('template_role, assignee_id')
    .eq('campaign_id', templateId).not('template_role', 'is', null);
  if (error || !data.length || box.closest('form')?.elements.template_id.value !== templateId) return;
  const usual = {};
  data.forEach(t => {
    const counts = (usual[t.template_role] ||= {});
    if (t.assignee_id) counts[t.assignee_id] = (counts[t.assignee_id] || 0) + 1;
  });
  const people = state.people.filter(p => p.active && p.role !== 'director').sort((a, b) => a.name.localeCompare(b.name));
  const roles = Object.keys(usual).sort((a, b) => a.localeCompare(b));
  box.innerHTML = `
    <legend>Roles</legend>
    <p class="muted small">Every task with a role goes to the person you pick for it.</p>
    ${roles.map(role => {
      const [top] = Object.entries(usual[role]).sort((a, b) => b[1] - a[1]);
      const name = top ? personById(top[0])?.name : null;
      return `<label class="field"><span>${esc(role)}</span>
        <select data-role="${esc(role)}">
          <option value="">As in the template${name ? ` (${esc(name)})` : ' (unassigned)'}</option>
          ${options(Object.fromEntries(people.map(p => [p.id, p.name])), '')}
        </select></label>`;
    }).join('')}`;
  box.hidden = false;
}

// Templates people can start a project from
async function loadTemplates() {
  const { data, error } = await supabase.from('campaigns')
    .select('id, name, description, department_id, for_department_id, budget, planned_hours, start_date, end_date, private')
    .eq('is_template', true).is('archived_at', null).order('name');
  if (error) throw error;
  return data;
}

const addDays = (iso, days) => {
  const [y, m, d] = iso.split('-').map(Number);
  const date = new Date(y, m - 1, d + days);
  const pad = n => String(n).padStart(2, '0');
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
};
const daysBetween = (a, b) => Math.round((new Date(b) - new Date(a)) / 86400000);

// New project (campaign = null) or edit one. options.asTemplate makes a new
// template; options.templateId starts a new project from that template.
export async function openCampaignForm(campaign, onSaved, { asTemplate = false, templateId = null } = {}) {
  const isTemplate = campaign ? Boolean(campaign.is_template) : asTemplate;
  const templates = !campaign && !asTemplate ? await loadTemplates().catch(() => []) : [];
  const startFrom = templates.length ? `
      <label class="field template-pick"><span>Start from</span>
        <select name="template_id">
          <option value="">A blank project</option>
          ${templates.map(t => `<option value="${esc(t.id)}" ${t.id === templateId ? 'selected' : ''}>${esc(t.name)}</option>`).join('')}
        </select></label>
      <p class="muted small form-note" data-template-help hidden>Its sections, tasks, subtasks and fields are copied. Task dates move with the start date you choose, and every task starts as To do.</p>
      <fieldset class="field template-roles" data-template-roles hidden></fieldset>` : '';
  const marketing = departmentByKey('marketing');
  const defaultDept = state.me.department_id || marketing?.id;
  const c = campaign || {
    department_id: defaultDept,
    // Marketing work starts as Education, like before; everyone else's is for their own department
    for_department_id: isMarketing(defaultDept) ? departmentByKey('education')?.id : defaultDept,
    status: 'planned', owner_id: state.me.id, planned_hours: 0,
  };
  const settings = await loadTeamSettings().catch(() => ({}));
  const sharedSplit = Number(settings.shared_split_education ?? 70);
  const departments = Object.fromEntries(state.departments.map(d => [d.id, d.name]));
  const owners = state.people.filter(p => (p.active && p.role !== 'director') || p.id === c.owner_id);
  // Who can see it: only the owner, the creator or an Admin changes it
  const manage = canManageAccess(campaign);
  const before = campaign?.private ? await loadAccess(campaign.id).catch(() => []) : [];
  const privacy = manage ? `
      <fieldset class="field privacy-field">
        <legend>Who can see it</legend>
        <select name="visibility" aria-label="Who can see it">
          <option value="everyone" ${c.private ? '' : 'selected'}>Everyone at DSD</option>
          <option value="private" ${c.private ? 'selected' : ''}>Only the departments and people I choose</option>
        </select>
        <div class="private-picks" data-private-picks ${c.private ? '' : 'hidden'}>
          <p class="muted small">Its owner and Admins always see it. Nobody else sees its tasks, comments or files.</p>
          <label class="field"><span>Departments</span>
            <select data-pick="access_dept"></select></label>
          <div class="pick-chips" data-chips="access_dept"></div>
          <label class="field"><span>People</span>
            <select data-pick="access_person"></select></label>
          <div class="pick-chips" data-chips="access_person"></div>
        </div>
      </fieldset>`
    : c.private ? `<p class="muted small form-note">🔒 Private: seen by ${esc(accessSummary(before))}, its owner and Admins. Only its owner or an Admin can change this.</p>` : '';

  const noun = isTemplate ? 'template' : 'project';
  const dialog = formDialog({
    title: campaign ? `Edit ${noun}` : `New ${noun}`,
    submitLabel: campaign ? 'Save changes' : `Create ${noun}`,
    body: `
      ${startFrom}
      ${isTemplate ? '<p class="muted small form-note">A template is a project people copy: add its sections, tasks, subtasks and fields after creating it. Nobody works in a template, and no time is logged on it.</p>' : ''}
      <label class="field"><span>Name</span>
        <input name="name" required maxlength="200" value="${esc(c.name || '')}"></label>
      <label class="field"><span>Description</span>
        <textarea name="description" rows="3">${esc(c.description || '')}</textarea></label>
      <div class="field-row">
        <label class="field"><span>Department</span>
          <select name="department_id" required>${options(departments, c.department_id)}</select></label>
        <label class="field"><span>For</span>
          <select name="for_department_id" required>${forOptions(c.department_id, sharedSplit, currentFor(c))}</select></label>
      </div>
      <p class="muted small form-note" data-for-help></p>
      <label class="field" ${isTemplate ? 'hidden' : ''}><span>Status</span>
        <select name="status">${options(CAMPAIGN_STATUSES, c.status)}</select></label>
      ${isTemplate ? '<p class="muted small form-note">Task due dates in the template count from its start date: a project made from it on another date has every date moved by the same number of days.</p>' : ''}
      <div class="field-row">
        <label class="field"><span>Start date</span>
          <input type="date" name="start_date" required value="${esc(c.start_date || '')}"></label>
        <label class="field"><span>End date</span>
          <input type="date" name="end_date" required value="${esc(c.end_date || '')}"></label>
      </div>
      <div class="field-row">
        <label class="field"><span>Owner</span>
          <select name="owner_id">
            <option value="">No owner</option>
            ${options(Object.fromEntries(owners.map(p => [p.id, p.name])), c.owner_id)}
          </select></label>
        <label class="field"><span>Planned hours</span>
          <input type="number" name="planned_hours" min="0" step="0.5" value="${esc(c.planned_hours ?? 0)}"></label>
      </div>
      <div data-privacy>${privacy}</div>
      <p class="muted small form-note" data-privacy-from-template hidden>Who can see it is copied from the template. You can change it afterwards with Edit.</p>`,
    onSubmit: async form => {
      const f = Object.fromEntries(new FormData(form));
      const values = {
        name: f.name.trim(),
        description: f.description.trim() || null,
        department_id: f.department_id,
        for_department_id: f.for_department_id === FOR_BOTH ? null : f.for_department_id,
        status: f.status,
        start_date: f.start_date || null,
        end_date: f.end_date || null,
        owner_id: f.owner_id || null,
        planned_hours: f.planned_hours === '' ? 0 : Number(f.planned_hours),
      };
      if (manage) values.private = f.visibility === 'private';
      const access = {
        departmentIds: values.private ? [...form.querySelectorAll('[name=access_dept]')].map(i => i.value) : [],
        personIds: values.private ? [...form.querySelectorAll('[name=access_person]')].map(i => i.value) : [],
      };

      if (!values.name) return 'Give the project a name.';
      if (!values.department_id) return 'Choose the department this project belongs to.';
      if (!values.start_date || !values.end_date) return 'Add a start and an end date.';
      if (values.end_date < values.start_date) return 'The end date must be on or after the start date.';
      if (!Number.isFinite(values.planned_hours) || values.planned_hours < 0) return 'Planned hours must be 0 or more.';

      // From a template: the database copies it, with these details
      const fromTemplate = !campaign && f.template_id;
      if (fromTemplate) {
        delete values.private;
        // The person picked for each role gets that role's tasks
        values.roles = Object.fromEntries([...form.querySelectorAll('[data-role]')]
          .filter(select => select.value).map(select => [select.dataset.role, select.value]));
        const { data: newId, error } = await supabase.rpc('copy_project', { p_source: f.template_id, p_values: values, p_as_template: false });
        if (error) return errorMessage(error);
        toast('Project created from the template');
        onSaved?.({ id: newId });
        return;
      }
      if (!campaign && isTemplate) values.is_template = true;
      const query = campaign
        ? supabase.from('campaigns').update(values).eq('id', campaign.id)
        : supabase.from('campaigns').insert(values);
      const { data, error } = await query.select().single();
      if (error) return errorMessage(error);
      if (manage && (values.private || before.length)) {
        try {
          await saveAccess(data.id, before, access);
        } catch (accessError) {
          return `The project was saved, but who can see it wasn't: ${errorMessage(accessError)}`;
        }
      }

      toast(campaign ? `${isTemplate ? 'Template' : 'Project'} updated` : `${isTemplate ? 'Template' : 'Project'} created`);
      onSaved?.(data);
    },
  });

  // "For" follows the department: its choices change, and the note says
  // what the choice means for hours
  const deptSelect = dialog.querySelector('[name=department_id]');
  const forSelect = dialog.querySelector('[name=for_department_id]');
  const help = dialog.querySelector('[data-for-help]');
  const explain = () => {
    help.textContent = isMarketing(deptSelect.value)
      ? 'Marketing hours for Education count against its budget; for Planning Center or Delight, against the Planning Center budget; for both, they are split. Hours for any other department count against neither.'
      : 'Who the work is for. Leave it as the own department unless the work is for another team.';
  };
  if (manage) {
    const visibility = dialog.querySelector('[name=visibility]');
    visibility.addEventListener('change', () => {
      dialog.querySelector('[data-private-picks]').hidden = visibility.value !== 'private';
    });
    setUpPicker(dialog, 'access_dept', 'Add a department…', state.departments.map(d => ({ id: d.id, name: d.name })),
      before.filter(a => a.department_id).map(a => a.department_id));
    // People grouped by their department, so a long list stays easy to scan
    const people = state.people.filter(p => p.active || before.some(a => a.person_id === p.id));
    setUpPicker(dialog, 'access_person', 'Add a person…',
      people.map(p => ({ id: p.id, name: p.name, group: state.departments.find(d => d.id === p.department_id)?.name || 'No department' })),
      before.filter(a => a.person_id).map(a => a.person_id));
  }
  // Picking a template fills in its details; the name, dates and owner stay yours
  const templateSelect = dialog.querySelector('[name=template_id]');
  if (templateSelect) {
    let rolesFor = null;
    const applyTemplate = () => {
      const t = templates.find(x => x.id === templateSelect.value);
      if ((t?.id || null) !== rolesFor) {
        rolesFor = t?.id || null;
        showRoles(dialog.querySelector('[data-template-roles]'), rolesFor);
      }
      dialog.querySelector('[data-template-help]').hidden = !t;
      dialog.querySelector('[data-privacy]').hidden = Boolean(t);
      dialog.querySelector('[data-privacy-from-template]').hidden = !t;
      if (!t) return;
      const form = dialog.querySelector('form');
      form.elements.description.value = t.description || '';
      form.elements.planned_hours.value = t.planned_hours ?? 0;
      deptSelect.value = t.department_id;
      forSelect.innerHTML = forOptions(t.department_id, sharedSplit, currentFor(t));
      explain();
      if (!form.elements.name.value.trim()) form.elements.name.placeholder = t.name.replace(/\s*\(?\b(new\s+)?template\b\)?\s*/ig, ' ').trim();
      const start = form.elements.start_date.value;
      if (start && t.start_date && t.end_date) form.elements.end_date.value = addDays(start, daysBetween(t.start_date, t.end_date));
    };
    templateSelect.addEventListener('change', applyTemplate);
    // A start date sets the end date to match the template's length
    dialog.querySelector('[name=start_date]').addEventListener('change', () => { if (templateSelect.value) applyTemplate(); });
    if (templateSelect.value) applyTemplate();
  }
  deptSelect.addEventListener('change', () => {
    const choices = forChoices(deptSelect.value, sharedSplit);
    const keep = forSelect.value in choices ? forSelect.value
      : isMarketing(deptSelect.value) ? departmentByKey('education')?.id : deptSelect.value;
    forSelect.innerHTML = forOptions(deptSelect.value, sharedSplit, keep);
    explain();
  });
  explain();
}
