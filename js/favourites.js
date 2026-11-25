import { supabase } from './supabase.js';
import { state } from './state.js';
import { esc, toast, errorMessage } from './ui.js';

// Favourite projects (30_favourite_projects.sql): each person's starred
// projects, first on the Projects page and in the ★ menu in the top bar.
// Kept in state.favourites (a Set of project ids) once loaded.

const CHANGED = 'atlas-favourites-changed';

export async function loadFavourites() {
  const { data, error } = await supabase.from('project_favourites').select('campaign_id');
  state.favourites = new Set(error ? [] : data.map(r => r.campaign_id));
  return state.favourites;
}

export const isFavourite = id => Boolean(state.favourites?.has(id));

export async function toggleFavourite(id) {
  const adding = !isFavourite(id);
  const { error } = adding
    ? await supabase.from('project_favourites').insert({ campaign_id: id })
    : await supabase.from('project_favourites').delete().eq('campaign_id', id).eq('person_id', state.me.id);
  if (error) {
    toast(errorMessage(error), 'error');
    return isFavourite(id);
  }
  state.favourites ||= new Set();
  if (adding) state.favourites.add(id);
  else state.favourites.delete(id);
  window.dispatchEvent(new CustomEvent(CHANGED));
  return adding;
}

export const onFavouritesChanged = handler => window.addEventListener(CHANGED, handler);

// A star button; wire it with wireStars()
export function starButton(id, name) {
  const on = isFavourite(id);
  return `<button class="star-btn" type="button" data-star="${esc(id)}" aria-pressed="${on}"
    aria-label="${on ? 'Remove' : 'Add'} ${esc(name)} ${on ? 'from' : 'to'} favourites" title="${on ? 'Remove from favourites' : 'Add to favourites'}">${on ? '★' : '☆'}</button>`;
}

export function wireStars(root) {
  root.querySelectorAll('[data-star]').forEach(button => button.addEventListener('click', async event => {
    event.preventDefault();
    event.stopPropagation();
    const on = await toggleFavourite(button.dataset.star);
    button.setAttribute('aria-pressed', String(on));
    button.textContent = on ? '★' : '☆';
    button.title = on ? 'Remove from favourites' : 'Add to favourites';
    toast(on ? 'Added to favourites' : 'Removed from favourites');
  }));
}

// The ★ menu in the top bar: your favourite projects, one click away
export function mountFavouritesMenu(slot) {
  if (!slot) return;
  slot.innerHTML = `
    <details class="more-menu fav-menu">
      <summary class="icon-btn" aria-label="Favourite projects" title="Favourite projects"><span aria-hidden="true">★</span></summary>
      <div class="menu" data-fav-list></div>
    </details>`;
  const menu = slot.querySelector('details');
  const list = slot.querySelector('[data-fav-list]');
  const draw = async () => {
    const ids = [...(state.favourites || [])];
    if (!ids.length) {
      list.innerHTML = '<p class="menu-note">No favourites yet. Click ☆ next to a project\'s name to add it here.</p>';
      return;
    }
    const { data } = await supabase.from('campaigns').select('id, name, archived_at').in('id', ids).order('name');
    list.innerHTML = `<div class="menu-head"><strong>Favourites</strong></div>${(data || []).map(c => `
      <a class="menu-item" href="#/campaigns/${esc(c.id)}">${esc(c.name)}${c.archived_at ? ' <span class="muted small">(archived)</span>' : ''}</a>`).join('')}`;
  };
  menu.addEventListener('toggle', () => { if (menu.open) draw(); });
  list.addEventListener('click', event => { if (event.target.closest('a')) menu.open = false; });
  document.addEventListener('click', event => { if (menu.open && !menu.contains(event.target)) menu.open = false; });
}
