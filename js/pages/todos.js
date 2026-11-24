import { supabase } from '../supabase.js';
import { esc, errorMessage } from '../ui.js';
import { renderCampaign } from './campaign.js';

// My to-dos: each person's own project, only they can see it. The database
// makes it the first time it's opened (my_todos() in 20_personal_todos.sql).
export async function renderTodos(el) {
  el.innerHTML = '<p class="muted">Loading your to-dos…</p>';
  const { data: id, error } = await supabase.rpc('my_todos');
  if (error || !id) {
    el.innerHTML = `<div class="empty-state"><p>Your to-do list couldn't be opened. ${esc(errorMessage(error) || '')}</p>
      <p><a href="#/my-tasks">Go to My tasks</a></p></div>`;
    return;
  }
  return renderCampaign(el, id);
}
