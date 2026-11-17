import { personById } from '../state.js';
import { esc, statusPill, fmtDate, errorMessage, TASK_STATUSES } from '../ui.js';
import { forTag } from '../departments.js';
import { toEditorText } from '../comments.js';
import { searchEverything, highlight, snippet, MIN_LENGTH } from '../search.js';

// Search page (#/search?q=...): everything you can see that contains the
// words, grouped into projects, sections, tasks and comments.

export function queryFromHash() {
  const [, query = ''] = window.location.hash.split('?');
  return new URLSearchParams(query).get('q') || '';
}

export function searchHref(q) {
  return `#/search?q=${encodeURIComponent(q.trim())}`;
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
  const q = queryFromHash();
  el.innerHTML = `
    <div class="page-header">
      <div>
        <h1>Search</h1>
        <p class="muted">Projects, sections, tasks and comments you can see, including archived projects.</p>
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
  const total = projects.length + sections.length + tasks.length + comments.length;
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
