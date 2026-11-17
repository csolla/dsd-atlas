import { esc } from './ui.js';
import { suggest, highlight, MIN_LENGTH } from './search.js';
import { searchHref } from './pages/search.js';

// Suggestions under the top bar's search box: matching projects and tasks
// while typing, plus "Search everything". Up/Down move, Enter opens,
// Escape closes. Enter with nothing picked opens the Search page.

export function mountSearchSuggestions(form) {
  const input = form.elements.q;
  const list = document.createElement('ul');
  list.className = 'search-suggest';
  list.id = 'search-suggest';
  list.setAttribute('role', 'listbox');
  list.setAttribute('aria-label', 'Suggestions');
  list.hidden = true;
  form.append(list);
  input.setAttribute('role', 'combobox');
  input.setAttribute('aria-autocomplete', 'list');
  input.setAttribute('aria-controls', list.id);
  input.setAttribute('aria-expanded', 'false');

  let items = [];       // [{ href, html }]
  let active = -1;      // highlighted item, -1 = none
  let timer = null;
  let latest = 0;

  const close = () => {
    list.hidden = true;
    input.setAttribute('aria-expanded', 'false');
    input.removeAttribute('aria-activedescendant');
    active = -1;
  };

  const draw = (found, q) => {
    const flags = p => `${p.private ? ' <span class="private-flag"><span aria-hidden="true">🔒</span> Private</span>' : ''}${p.archived_at ? ' <span class="private-flag">Archived</span>' : ''}`;
    items = [
      ...found.projects.map(p => ({
        group: 'Projects',
        href: `#/campaigns/${p.id}`,
        html: `<span class="suggest-title">${highlight(p.name, q)}</span>${flags(p)}`,
      })),
      ...found.tasks.map(t => ({
        group: 'Tasks',
        href: `#/campaigns/${t.campaign_id}/tasks/${t.id}`,
        html: `<span class="suggest-title">${t.parent_id ? '<span class="subtask-mark" aria-hidden="true">↳</span>' : ''}${highlight(t.title, q)}</span>
          <span class="suggest-meta">${esc(t.campaign.name)}${flags(t.campaign)}</span>`,
      })),
      { group: '', href: searchHref(q), html: `<span class="suggest-all">Search everything for “${esc(q.trim())}”</span>` },
    ];
    let lastGroup = null;
    list.innerHTML = items.map((item, i) => {
      const heading = item.group && item.group !== lastGroup
        ? `<li class="suggest-group" role="presentation">${esc(item.group)}</li>` : '';
      lastGroup = item.group;
      return `${heading}<li role="option" id="suggest-${i}" data-i="${i}" aria-selected="false">${item.html}</li>`;
    }).join('') + (found.projects.length || found.tasks.length ? '' : '<li class="suggest-none" role="presentation">No projects or tasks with that name</li>');
    active = -1;
    list.hidden = false;
    input.setAttribute('aria-expanded', 'true');
  };

  const highlightActive = () => {
    list.querySelectorAll('[role=option]').forEach(li =>
      li.setAttribute('aria-selected', String(Number(li.dataset.i) === active)));
    if (active >= 0) {
      input.setAttribute('aria-activedescendant', `suggest-${active}`);
      list.querySelector(`#suggest-${active}`)?.scrollIntoView({ block: 'nearest' });
    } else {
      input.removeAttribute('aria-activedescendant');
    }
  };

  const go = href => {
    close();
    input.value = '';
    input.blur();
    window.location.hash = href;
  };

  input.addEventListener('input', () => {
    clearTimeout(timer);
    const q = input.value;
    if (q.trim().length < MIN_LENGTH) {
      latest++;
      close();
      return;
    }
    timer = setTimeout(async () => {
      const mine = ++latest;
      let found;
      try {
        found = await suggest(q);
      } catch {
        return;
      }
      // Only show the answer to what's in the box now
      if (mine === latest && input.value === q && document.activeElement === input) draw(found, q);
    }, 200);
  });

  input.addEventListener('keydown', event => {
    if (event.key === 'Escape') {
      if (!list.hidden) {
        event.stopPropagation();
        close();
      } else {
        input.blur();
      }
      return;
    }
    if (list.hidden || !items.length) return;
    if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
      event.preventDefault();
      // Cycles through the items and back to the box itself (-1)
      const last = items.length - 1;
      if (event.key === 'ArrowDown') active = active === last ? -1 : active + 1;
      else active = active === -1 ? last : active - 1;
      highlightActive();
    } else if (event.key === 'Enter' && active >= 0) {
      event.preventDefault();
      go(items[active].href);
    }
  });

  // Click (mousedown, so the box doesn't lose focus and close the list first)
  list.addEventListener('mousedown', event => {
    const li = event.target.closest('[role=option]');
    if (!li) return;
    event.preventDefault();
    go(items[Number(li.dataset.i)].href);
  });
  list.addEventListener('mousemove', event => {
    const li = event.target.closest('[role=option]');
    if (li && Number(li.dataset.i) !== active) {
      active = Number(li.dataset.i);
      highlightActive();
    }
  });
  input.addEventListener('blur', () => setTimeout(close, 100));
  input.addEventListener('focus', () => { if (input.value.trim().length >= MIN_LENGTH) input.dispatchEvent(new Event('input')); });

  // Enter with nothing picked: the Search page (handled by the form)
  form.addEventListener('submit', close);
}
