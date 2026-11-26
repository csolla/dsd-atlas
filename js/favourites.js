import { supabase } from './supabase.js';
import { state } from './state.js';
import { esc, toast, errorMessage } from './ui.js';

// Favourites: each person's starred projects (30_favourite_projects.sql)
// and portfolios (33_favourite_portfolios.sql), first on the Projects and
// Portfolios pages and in the ★ menu in the top bar. Kept in
// state.favourites (project ids) and state.favouritePortfolios.

const CHANGED = 'atlas-favourites-changed';

// Where each kind is saved and kept
const KINDS = {
  project: { table: 'project_favourites', column: 'campaign_id', key: 'favourites' },
  portfolio: { table: 'portfolio_favourites', column: 'portfolio_id', key: 'favouritePortfolios' },
};

export async function loadFavourites() {
  await Promise.all(Object.values(KINDS).map(async k => {
    const { data, error } = await supabase.from(k.table).select(k.column);
    state[k.key] = new Set(error ? [] : data.map(r => r[k.column]));
  }));
  return state.favourites;
}

export const isFavourite = (id, kind = 'project') => Boolean(state[KINDS[kind].key]?.has(id));

export async function toggleFavourite(id, kind = 'project') {
  const k = KINDS[kind];
  const adding = !isFavourite(id, kind);
  const { error } = adding
    ? await supabase.from(k.table).insert({ [k.column]: id })
    : await supabase.from(k.table).delete().eq(k.column, id).eq('person_id', state.me.id);
  if (error) {
    toast(errorMessage(error), 'error');
    return isFavourite(id, kind);
  }
  state[k.key] ||= new Set();
  if (adding) state[k.key].add(id);
  else state[k.key].delete(id);
  window.dispatchEvent(new CustomEvent(CHANGED));
  return adding;
}

export const onFavouritesChanged = handler => window.addEventListener(CHANGED, handler);

// A star button; wire it with wireStars()
export function starButton(id, name, kind = 'project') {
  const on = isFavourite(id, kind);
  return `<button class="star-btn" type="button" data-star="${esc(id)}" data-star-kind="${kind}" aria-pressed="${on}"
    aria-label="${on ? 'Remove' : 'Add'} ${esc(name)} ${on ? 'from' : 'to'} favourites" title="${on ? 'Remove from favourites' : 'Add to favourites'}">${on ? '★' : '☆'}</button>`;
}

export function wireStars(root) {
  root?.querySelectorAll('[data-star]').forEach(button => button.addEventListener('click', async event => {
    event.preventDefault();
    event.stopPropagation();
    const on = await toggleFavourite(button.dataset.star, button.dataset.starKind || 'project');
    button.setAttribute('aria-pressed', String(on));
    button.textContent = on ? '★' : '☆';
    button.title = on ? 'Remove from favourites' : 'Add to favourites';
    toast(on ? 'Added to favourites' : 'Removed from favourites');
  }));
}

// The ★ menu in the top bar: your favourite projects and portfolios
export function mountFavouritesMenu(slot) {
  if (!slot) return;
  slot.innerHTML = `
    <details class="more-menu fav-menu">
      <summary class="icon-btn" aria-label="Favourites" title="Favourites"><span aria-hidden="true">★</span></summary>
      <div class="menu" data-fav-list></div>
    </details>`;
  const menu = slot.querySelector('details');
  const list = slot.querySelector('[data-fav-list]');
  const draw = async () => {
    const projectIds = [...(state.favourites || [])];
    const portfolioIds = [...(state.favouritePortfolios || [])];
    if (!projectIds.length && !portfolioIds.length) {
      list.innerHTML = '<p class="menu-note">No favourites yet. Click ☆ next to a project\'s or portfolio\'s name to add it here.</p>';
      return;
    }
    const [projects, portfolios] = await Promise.all([
      projectIds.length ? supabase.from('campaigns').select('id, name, archived_at').in('id', projectIds).order('name') : { data: [] },
      portfolioIds.length ? supabase.from('portfolios').select('id, name').in('id', portfolioIds).order('name') : { data: [] },
    ]);
    list.innerHTML = `
      ${(projects.data || []).length ? `<div class="menu-head"><strong>Projects</strong></div>${projects.data.map(c => `
        <a class="menu-item" href="#/campaigns/${esc(c.id)}">${esc(c.name)}${c.archived_at ? ' <span class="muted small">(archived)</span>' : ''}</a>`).join('')}` : ''}
      ${(portfolios.data || []).length ? `<div class="menu-head"><strong>Portfolios</strong></div>${portfolios.data.map(p => `
        <a class="menu-item" href="#/portfolios/${esc(p.id)}">${esc(p.name)}</a>`).join('')}` : ''}`;
  };
  menu.addEventListener('toggle', () => { if (menu.open) draw(); });
  list.addEventListener('click', event => { if (event.target.closest('a')) menu.open = false; });
  document.addEventListener('click', event => { if (menu.open && !menu.contains(event.target)) menu.open = false; });
}
