import { supabase } from '../supabase.js';
import { state, canEditWork, isAdmin, personById } from '../state.js';
import {
  esc, options, avatar, statusPill, fmtCompactRange, fmtHours, toast, errorMessage, formDialog, confirmDialog, fitToScreen,
} from '../ui.js';
import { tasksDonePct } from '../tasks.js';
import { loadCampaignHours } from '../time.js';
import { fieldInput, readFieldInput, formatHtml } from '../fields.js';
import { openFieldsDialog } from '../fields-dialog.js';
import { hasAllWords } from '../search.js';
import {
  listPortfolios, getPortfolio, loadItems, loadValues, saveValue, savePortfolio, deletePortfolio, setMembers,
  addItems, removeItem, portfoliosOfProject, PORTFOLIO_FIELDS,
} from '../portfolios.js';

// Portfolios (#/portfolios, #/portfolios/<id>), like Asana's: follow a group
// of projects (and other portfolios) together, with the portfolio's own
// columns. Directors can look; admins and team members change them.

const editors = () => state.people.filter(p => p.active && p.role !== 'director').sort((a, b) => a.name.localeCompare(b.name));
const privateFlag = '<span class="private-flag"><span aria-hidden="true">🔒</span> Private</span>';

export async function renderPortfolios(el) {
  el.innerHTML = `
    <div class="projects-head">
      <h1>Portfolios</h1>
      <span class="spacer"></span>
      ${canEditWork() ? '<div class="page-actions"><button class="btn btn-primary" type="button" data-new>New portfolio</button></div>' : ''}
    </div>
    <div class="filters"><input class="search" type="search" placeholder="Find a portfolio" aria-label="Find a portfolio" data-find></div>
    <div data-list><p class="muted">Loading portfolios…</p></div>`;
  el.querySelector('[data-new]')?.addEventListener('click', () => openPortfolioForm(null, saved => { window.location.hash = `/portfolios/${saved.id}`; }));
  const list = el.querySelector('[data-list]');
  let portfolios;
  try {
    portfolios = await listPortfolios();
  } catch (error) {
    list.innerHTML = `<p class="form-error">${esc(errorMessage(error))}</p>`;
    return;
  }
  const find = el.querySelector('[data-find]');
  const draw = () => {
    const shown = portfolios.filter(p => !find.value.trim() || hasAllWords([p.name, p.description], find.value));
    list.innerHTML = shown.length ? `
      <div class="table-wrap list-scroll"><table class="table campaign-table">
        <thead><tr><th>Portfolio</th><th>Owner</th><th>Items</th></tr></thead>
        <tbody>${shown.map(p => {
          const owner = personById(p.owner_id);
          return `<tr class="clickable" data-href="#/portfolios/${esc(p.id)}">
            <td><div class="project-cell"><a class="row-link" href="#/portfolios/${esc(p.id)}">${esc(p.name)}</a>${p.private ? privateFlag : ''}</div></td>
            <td>${owner ? `<span class="person">${avatar(owner, 24)}${esc(owner.name)}</span>` : '<span class="muted">—</span>'}</td>
            <td>${p.count}</td></tr>`;
        }).join('')}</tbody></table></div>`
      : `<div class="empty-state"><p>${portfolios.length ? 'No portfolio matches.' : `No portfolios yet.${canEditWork() ? ' Create one with “New portfolio” to follow a group of projects together.' : ''}`}</p></div>`;
    list.querySelectorAll('tr[data-href]').forEach(row => row.addEventListener('click', event => {
      if (!event.target.closest('a, button')) window.location.hash = row.dataset.href.slice(1);
    }));
    fitToScreen(list.querySelector('.list-scroll'));
  };
  find.addEventListener('input', draw);
  draw();
}

export async function renderPortfolio(el, id) {
  el.innerHTML = '<p class="muted">Loading portfolio…</p>';
  let portfolio;
  try {
    portfolio = await getPortfolio(id);
  } catch (error) {
    el.innerHTML = `<p class="form-error">${esc(errorMessage(error))}</p>`;
    return;
  }
  if (!portfolio) {
    el.innerHTML = '<a class="back-link" href="#/portfolios">← Portfolios</a><div class="empty-state"><p>This portfolio doesn\'t exist, or it\'s private.</p></div>';
    return;
  }
  const memberIds = (portfolio.members || []).map(m => m.person_id);
  const edit = canEditWork() && (!portfolio.private || isAdmin() || [portfolio.owner_id, portfolio.created_by, ...memberIds].includes(state.me.id));
  const owner = personById(portfolio.owner_id);
  const page = { el, portfolio, edit, items: [], fields: [], values: {}, progress: {}, hours: {} };

  el.innerHTML = `
    <section class="project-head">
      <div class="head-line">
        <div class="head-title">
          <a class="crumb" href="#/portfolios">Portfolios</a><span class="crumb-sep" aria-hidden="true">›</span>
          <h1>${esc(portfolio.name)}</h1>
          ${portfolio.private ? privateFlag : ''}
          ${owner ? `<span class="person head-owner" title="Owner">${avatar(owner, 22)}${esc(owner.name)}</span>` : ''}
        </div>
        ${edit ? `<div class="actions head-actions">
          <button class="btn btn-small" type="button" data-edit>Edit</button>
          ${isAdmin() || [portfolio.owner_id, portfolio.created_by].includes(state.me.id) ? `<details class="more-menu" data-more>
            <summary class="btn btn-ghost btn-small" aria-label="More portfolio actions" title="More">⋯</summary>
            <div class="menu"><button class="menu-item menu-item-danger" type="button" data-delete>Delete portfolio…</button></div>
          </details>` : ''}
        </div>` : ''}
      </div>
      ${portfolio.description ? `<p class="muted portfolio-description">${esc(portfolio.description)}</p>` : ''}
    </section>
    <div class="tasks-toolbar">
      ${edit ? `<button class="btn btn-small btn-primary" type="button" data-add-project>+ Add project</button>
        <button class="btn btn-small" type="button" data-add-portfolio>+ Add portfolio</button>` : ''}
      <span class="spacer"></span>
      ${edit ? '<div class="toolbar-tools"><button class="btn btn-ghost btn-small" type="button" data-fields title="This portfolio\'s own columns, such as a priority">Fields</button></div>' : ''}
    </div>
    <div data-items><p class="muted">Loading…</p></div>`;

  el.querySelector('[data-edit]')?.addEventListener('click', () => openPortfolioForm(portfolio, () => renderPortfolio(el, id)));
  el.querySelector('[data-delete]')?.addEventListener('click', async () => {
    const ok = await confirmDialog({
      title: 'Delete portfolio?',
      message: `“${portfolio.name}” will be deleted for everyone. Its projects aren't touched; they just leave the portfolio.`,
      confirmLabel: 'Delete', danger: true,
    });
    if (!ok) return;
    try {
      await deletePortfolio(id);
      toast('Portfolio deleted');
      window.location.hash = '/portfolios';
    } catch (error) {
      toast(errorMessage(error), 'error');
    }
  });
  el.querySelector('[data-fields]')?.addEventListener('click', () => openFieldsDialog({ id, name: portfolio.name }, {
    store: PORTFOLIO_FIELDS,
    countValues: fieldId => Object.values(page.values).filter(v => v[fieldId] !== undefined).length,
    onChanged: fields => { page.fields = fields; drawItems(page); },
  }));
  el.querySelector('[data-add-project]')?.addEventListener('click', () => openAddItems(page, 'project'));
  el.querySelector('[data-add-portfolio]')?.addEventListener('click', () => openAddItems(page, 'portfolio'));
  await loadAll(page);
  const refit = () => (el.isConnected ? fitToScreen(el.querySelector('.list-scroll')) : window.removeEventListener('resize', refit));
  window.addEventListener('resize', refit);
}

async function loadAll(page) {
  const box = page.el.querySelector('[data-items]');
  try {
    const [items, fields, hours] = await Promise.all([
      loadItems(page.portfolio.id), PORTFOLIO_FIELDS.load(page.portfolio.id), loadCampaignHours().catch(() => ({})),
    ]);
    Object.assign(page, { items, fields, hours });
    const projectIds = items.filter(i => i.campaign).map(i => i.campaign_id);
    const [values, progress] = await Promise.all([loadValues(items.map(i => i.id)), loadProgress(projectIds)]);
    Object.assign(page, { values, progress });
  } catch (error) {
    box.innerHTML = `<p class="form-error">${esc(errorMessage(error))}</p>`;
    return;
  }
  drawItems(page);
}

// Share of main tasks done, per project
async function loadProgress(projectIds) {
  if (!projectIds.length) return {};
  const { data, error } = await supabase.from('tasks').select('campaign_id, status').is('parent_id', null).in('campaign_id', projectIds);
  if (error) throw error;
  const by = {};
  data.forEach(t => { (by[t.campaign_id] ||= []).push(t); });
  return Object.fromEntries(Object.entries(by).map(([cid, tasks]) => [cid, tasksDonePct(tasks)]));
}

function drawItems(page) {
  const { el, items, fields, values, edit } = page;
  const box = el.querySelector('[data-items]');
  const shown = items.filter(i => i.campaign || i.child);
  const hidden = items.length - shown.length;
  if (!shown.length) {
    box.innerHTML = `<div class="empty-state"><p>${hidden ? `This portfolio has ${hidden} item${hidden === 1 ? '' : 's'} you can't see.` : 'Nothing in this portfolio yet.'}
      ${edit ? ' Add projects or other portfolios with the buttons above.' : ''}</p></div>`;
    return;
  }
  const cell = (item, f) => {
    const value = values[item.id]?.[f.id];
    if (edit) return `<td class="field-cell field-${esc(f.type)}" data-item="${esc(item.id)}">${fieldInput(f, value, { inline: true })}</td>`;
    return `<td class="field-col">${value == null ? '<span class="muted">—</span>' : formatHtml(f, value)}</td>`;
  };
  const before = box.querySelector('.list-scroll');
  const place = before ? [before.scrollTop, before.scrollLeft] : null;
  box.innerHTML = `
    <div class="table-wrap list-scroll">
      <table class="table campaign-table portfolio-table">
        <thead><tr><th class="task-col">Name</th><th>Status</th><th>Owner</th><th>Dates</th><th>Tasks done</th><th>Hours</th>
          ${fields.map(f => `<th class="field-col">${esc(f.name)}</th>`).join('')}${edit ? '<th><span class="visually-hidden">Remove</span></th>' : ''}</tr></thead>
        <tbody>${shown.map(item => {
          if (item.child) {
            return `<tr data-row="${esc(item.id)}">
              <td><div class="project-cell"><span class="portfolio-mark" aria-hidden="true">▤</span>
                <a class="row-link" href="#/portfolios/${esc(item.child.id)}">${esc(item.child.name)}</a><span class="tag">Portfolio</span>${item.child.private ? privateFlag : ''}</div></td>
              <td></td><td>${personById(item.child.owner_id) ? `<span class="person">${avatar(personById(item.child.owner_id), 22)}${esc(personById(item.child.owner_id).name)}</span>` : ''}</td>
              <td></td><td></td><td></td>
              ${fields.map(f => cell(item, f)).join('')}
              ${edit ? `<td><button class="icon-btn" type="button" data-remove="${esc(item.id)}" aria-label="Remove ${esc(item.child.name)} from this portfolio" title="Remove from this portfolio">×</button></td>` : ''}</tr>`;
          }
          const c = item.campaign;
          const ownerP = personById(c.owner_id);
          const pct = page.progress[c.id];
          const hours = Number(page.hours[c.id]?.hours || 0);
          return `<tr data-row="${esc(item.id)}">
            <td><div class="project-cell"><a class="row-link" href="#/campaigns/${esc(c.id)}">${esc(c.name)}</a>${c.private ? privateFlag : ''}${c.archived_at ? '<span class="tag">Archived</span>' : ''}</div></td>
            <td>${statusPill(c.status)}</td>
            <td>${ownerP ? `<span class="person">${avatar(ownerP, 22)}${esc(ownerP.name)}</span>` : '<span class="muted">—</span>'}</td>
            <td class="nowrap">${esc(fmtCompactRange(c.start_date, c.end_date))}</td>
            <td class="nowrap">${pct == null ? '<span class="muted">No tasks</span>' : `<span class="mini-meter meter-progress" aria-hidden="true"><span style="width:${pct}%"></span></span> ${pct}%`}</td>
            <td class="nowrap">${fmtHours(hours)}${Number(c.planned_hours) ? ` / ${fmtHours(c.planned_hours)}` : ''}</td>
            ${fields.map(f => cell(item, f)).join('')}
            ${edit ? `<td><button class="icon-btn" type="button" data-remove="${esc(item.id)}" aria-label="Remove ${esc(c.name)} from this portfolio" title="Remove from this portfolio">×</button></td>` : ''}</tr>`;
        }).join('')}</tbody>
      </table>
    </div>
    <p class="muted small table-note">${shown.length} item${shown.length === 1 ? '' : 's'}${hidden ? `, plus ${hidden} you can't see (private)` : ''}.</p>`;
  const scroller = box.querySelector('.list-scroll');
  fitToScreen(scroller, box.querySelector('.table-note')?.offsetHeight || 0);
  if (place) [scroller.scrollTop, scroller.scrollLeft] = place;

  // Several-choice cells open their menu under the cell (as in the List)
  box.querySelector('table').addEventListener('toggle', event => {
    const cell = event.target;
    if (!cell.matches?.('details.multi-cell') || !cell.open) return;
    box.querySelectorAll('details.multi-cell[open]').forEach(other => { if (other !== cell) other.open = false; });
    const rect = cell.querySelector('summary').getBoundingClientRect();
    const menu = cell.querySelector('.multi-cell-menu');
    menu.style.top = `${Math.round(rect.bottom + 4)}px`;
    menu.style.left = `${Math.round(Math.min(rect.left, window.innerWidth - 300))}px`;
  }, true);

  // Columns are filled right in the table, saving as you go
  box.querySelector('table').addEventListener('change', async event => {
    const td = event.target.closest('td[data-item]');
    const input = td?.querySelector('[data-field-id]');
    const field = fields.find(f => f.id === input?.dataset.fieldId);
    if (!field) return;
    const value = readFieldInput(field, input);
    const row = (page.values[td.dataset.item] ||= {});
    const before = row[field.id];
    if (value == null || (Array.isArray(value) && !value.length)) delete row[field.id];
    else row[field.id] = value;
    try {
      await saveValue(td.dataset.item, field.id, value);
    } catch (error) {
      if (before === undefined) delete row[field.id];
      else row[field.id] = before;
      toast(errorMessage(error), 'error');
      drawItems(page);
    }
  });
  box.querySelectorAll('[data-remove]').forEach(button => button.addEventListener('click', async () => {
    try {
      await removeItem(button.dataset.remove);
      page.items = page.items.filter(i => i.id !== button.dataset.remove);
      drawItems(page);
      toast('Removed from the portfolio');
    } catch (error) {
      toast(errorMessage(error), 'error');
    }
  }));
}

// Pick projects (or portfolios) to add, with a search box
async function openAddItems(page, kind) {
  const { portfolio, items } = page;
  let choices;
  try {
    if (kind === 'project') {
      const { data, error } = await supabase.from('campaigns').select('id, name, archived_at')
        .eq('is_template', false).is('personal_of', null).order('name');
      if (error) throw error;
      const have = new Set(items.map(i => i.campaign_id));
      choices = data.filter(c => !have.has(c.id)).map(c => ({ id: c.id, name: c.name, note: c.archived_at ? 'Archived' : '' }));
    } else {
      const have = new Set(items.map(i => i.child_portfolio_id));
      choices = (await listPortfolios()).filter(p => p.id !== portfolio.id && !have.has(p.id)).map(p => ({ id: p.id, name: p.name, note: `${p.count} items` }));
    }
  } catch (error) {
    toast(errorMessage(error), 'error');
    return;
  }
  const dialog = formDialog({
    title: kind === 'project' ? 'Add projects' : 'Add portfolios',
    submitLabel: 'Add',
    body: `
      <input class="search" type="search" placeholder="Find…" aria-label="Find" data-pick-find>
      <div class="pick-list" data-pick-list>${choices.map(c => `
        <label class="multi-choice-item" data-name="${esc(c.name)}"><input type="checkbox" value="${esc(c.id)}"> ${esc(c.name)}${c.note ? ` <span class="muted small">${esc(c.note)}</span>` : ''}</label>`).join('')
        || `<p class="muted">Every ${kind} you can see is already in this portfolio.</p>`}</div>`,
    onSubmit: async form => {
      const ids = [...form.querySelectorAll('[data-pick-list] input:checked')].map(i => i.value);
      if (!ids.length) return `Tick at least one ${kind}.`;
      try {
        const last = Math.max(0, ...items.map(i => i.position));
        await addItems(portfolio.id, ids.map(id => (kind === 'project' ? { campaign_id: id } : { child_portfolio_id: id })), last);
      } catch (error) {
        return errorMessage(error);
      }
      toast(`${ids.length} added`);
      loadAll(page);
    },
  });
  dialog.querySelector('[data-pick-find]').addEventListener('input', event => {
    dialog.querySelectorAll('[data-pick-list] [data-name]').forEach(label => {
      label.hidden = Boolean(event.target.value.trim()) && !hasAllWords([label.dataset.name], event.target.value);
    });
  });
}

// New portfolio, or edit one: name, description, owner, private + members
function openPortfolioForm(portfolio, onSaved) {
  const people = editors();
  const members = new Set((portfolio?.members || []).map(m => m.person_id));
  formDialog({
    title: portfolio ? 'Edit portfolio' : 'New portfolio',
    submitLabel: portfolio ? 'Save' : 'Create portfolio',
    body: `
      <label class="field"><span>Name</span><input name="name" required maxlength="200" value="${esc(portfolio?.name || '')}" placeholder="For example: Key Projects 2027"></label>
      <label class="field"><span>Description (optional)</span><textarea name="description" rows="2">${esc(portfolio?.description || '')}</textarea></label>
      <label class="field"><span>Owner</span><select name="owner_id"><option value="">No owner</option>${options(Object.fromEntries(people.map(p => [p.id, p.name])), portfolio?.owner_id || state.me.id)}</select></label>
      <label class="checkbox-line"><input type="checkbox" name="private" ${portfolio?.private ? 'checked' : ''} data-private> Private: only its owner, the people below and Admins see it</label>
      <div class="pick-list" data-members ${portfolio?.private ? '' : 'hidden'}>${people.map(p => `
        <label class="multi-choice-item"><input type="checkbox" value="${esc(p.id)}" ${members.has(p.id) ? 'checked' : ''}> ${esc(p.name)}</label>`).join('')}</div>`,
    onSubmit: async form => {
      const name = form.elements.name.value.trim();
      if (!name) return 'Give the portfolio a name.';
      const isPrivate = form.elements.private.checked;
      try {
        const saved = await savePortfolio({
          name, description: form.elements.description.value.trim() || null,
          owner_id: form.elements.owner_id.value || null, private: isPrivate,
        }, portfolio?.id);
        await setMembers(saved.id, isPrivate ? [...form.querySelectorAll('[data-members] input:checked')].map(i => i.value) : []);
        toast(portfolio ? 'Portfolio saved' : `${name} created`);
        onSaved(saved);
      } catch (error) {
        return errorMessage(error);
      }
    },
  }).querySelector('[data-private]').addEventListener('change', event => {
    event.target.closest('form').querySelector('[data-members]').hidden = !event.target.checked;
  });
}

// From a project's ⋯ menu: tick the portfolios it should be in
export async function openProjectPortfolios(campaign) {
  let all;
  let current;
  try {
    [all, current] = await Promise.all([listPortfolios(), portfoliosOfProject(campaign.id)]);
  } catch (error) {
    toast(errorMessage(error), 'error');
    return;
  }
  const inIt = new Map(current.map(c => [c.portfolio_id, c.id]));
  formDialog({
    title: `Portfolios for ${campaign.name}`,
    submitLabel: 'Save',
    body: all.length ? `<p class="muted small">Tick the portfolios this project belongs to.</p>
      <div class="pick-list">${all.map(p => `
        <label class="multi-choice-item"><input type="checkbox" value="${esc(p.id)}" ${inIt.has(p.id) ? 'checked' : ''}> ${esc(p.name)}${p.private ? ' 🔒' : ''}</label>`).join('')}</div>`
      : '<p class="muted">No portfolios yet. Create one on the Portfolios page.</p>',
    onSubmit: async form => {
      const want = new Set([...form.querySelectorAll('.pick-list input:checked')].map(i => i.value));
      try {
        for (const p of all) {
          if (want.has(p.id) && !inIt.has(p.id)) await addItems(p.id, [{ campaign_id: campaign.id }], Date.now() / 1000);
          if (!want.has(p.id) && inIt.has(p.id)) await removeItem(inIt.get(p.id));
        }
      } catch (error) {
        return errorMessage(error);
      }
      toast('Portfolios saved');
    },
  });
}
