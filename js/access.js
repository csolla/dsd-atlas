import { supabase } from './supabase.js';
import { state, isAdmin, canEditWork } from './state.js';
import { departmentName } from './departments.js';

// Private projects (same rules as person_can_see_campaign in SQL): seen by
// the people and departments added to them, their owner and creator, and
// every Admin.

// Who is added to a project: rows of { person_id } or { department_id }
export async function loadAccess(campaignId) {
  const { data, error } = await supabase.from('campaign_access').select('*').eq('campaign_id', campaignId);
  if (error) throw error;
  return data;
}

export function personCanSee(person, campaign, access = []) {
  if (!person || !campaign) return false;
  if (!campaign.private || person.role === 'admin') return true;
  if (person.id === campaign.owner_id || person.id === campaign.created_by) return true;
  return access.some(a => a.person_id === person.id || (a.department_id && a.department_id === person.department_id));
}

// People who can be assigned or mentioned on a project's tasks
export function projectAudience(campaign, access = []) {
  return state.people.filter(p => p.active && p.role !== 'director' && personCanSee(p, campaign, access));
}

// The owner, the creator or an Admin decides who sees a project
export function canManageAccess(campaign) {
  if (!campaign) return isAdmin() || canEditWork();
  return isAdmin() || (canEditWork() && [campaign.owner_id, campaign.created_by].includes(state.me.id));
}

// "Delight, Ana López and 2 more" style list of who's added
export function accessSummary(access = []) {
  const names = [
    ...access.filter(a => a.department_id).map(a => `${departmentName(a.department_id)} (department)`),
    ...access.filter(a => a.person_id).map(a => state.people.find(p => p.id === a.person_id)?.name || 'Someone'),
  ];
  if (!names.length) return 'only its owner and Admins';
  return names.length <= 4 ? names.join(', ') : `${names.slice(0, 3).join(', ')} and ${names.length - 3} more`;
}

// Everyone added, by name: { departments: [...], people: [...] }
export function accessNames(access = []) {
  const byName = (a, b) => a.localeCompare(b);
  return {
    departments: access.filter(a => a.department_id).map(a => departmentName(a.department_id)).sort(byName),
    people: access.filter(a => a.person_id).map(a => state.people.find(p => p.id === a.person_id)?.name || 'Someone').sort(byName),
  };
}

// Save who's added: removes the rows no longer wanted and adds the new ones
export async function saveAccess(campaignId, before, { personIds, departmentIds }) {
  const wanted = new Set([...personIds.map(id => `p:${id}`), ...departmentIds.map(id => `d:${id}`)]);
  const keyOf = a => (a.person_id ? `p:${a.person_id}` : `d:${a.department_id}`);
  const remove = before.filter(a => !wanted.has(keyOf(a))).map(a => a.id);
  const have = new Set(before.map(keyOf));
  const add = [...wanted].filter(k => !have.has(k)).map(k => (k.startsWith('p:')
    ? { campaign_id: campaignId, person_id: k.slice(2) }
    : { campaign_id: campaignId, department_id: k.slice(2) }));
  if (remove.length) {
    const { error } = await supabase.from('campaign_access').delete().in('id', remove);
    if (error) throw error;
  }
  if (add.length) {
    const { error } = await supabase.from('campaign_access').insert(add);
    if (error) throw error;
  }
}
