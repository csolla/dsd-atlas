import { supabase } from './supabase.js';
import { state } from './state.js';
import { esc } from './ui.js';

// Business units are the broad split; each department belongs to one.
export const BUSINESS_UNITS = {
  education: 'Education',
  dsd_center: 'DSD Center',
  corporate: 'Corporate',
};

// Which of Marketing's budgets a campaign's hours count against. Set by
// the database from the campaign's department and who it's for.
export const BUDGETS = {
  education: 'Education',
  planning_center: 'Planning Center',
  shared: 'Education + Planning Center',
  other: 'Other departments',
};

// "For" value meaning both Education and Planning Center (Marketing only)
export const FOR_BOTH = 'both';

export async function loadDepartments() {
  const { data, error } = await supabase.from('departments').select('*').order('name');
  if (error) throw error;
  state.departments = data;
  return data;
}

export const departmentById = id => state.departments.find(d => d.id === id) || null;
export const departmentByKey = key => state.departments.find(d => d.key === key) || null;
export const departmentName = id => departmentById(id)?.name || 'No department';
export const isMarketing = departmentId => Boolean(departmentId) && departmentId === departmentByKey('marketing')?.id;
export const isMarketingPerson = person => isMarketing(person?.department_id);

// Who the work is for, in words
export function forLabel(campaign) {
  if (!campaign) return '';
  if (campaign.budget === 'shared') return BUDGETS.shared;
  return departmentName(campaign.for_department_id || campaign.department_id);
}

// Owner department, plus who it's for when that's someone else
export function departmentLine(campaign) {
  const owner = departmentName(campaign.department_id);
  const ownWork = campaign.budget === 'other' && (!campaign.for_department_id || campaign.for_department_id === campaign.department_id);
  return ownWork ? owner : `${owner} · for ${forLabel(campaign)}`;
}

// Coloured dot plus the department line, as shown under a campaign name
export function unitLine(campaign) {
  return `<span class="unit-line"><span class="unit-dot unit-dot-${esc(campaign.budget)}" aria-hidden="true"></span>${esc(departmentLine(campaign))}</span>`;
}

// Tag for who a campaign is for (Education / Planning Center colours on
// Marketing campaigns, neutral for everything else)
export function forTag(campaign) {
  return `<span class="tag tag-${esc(campaign.budget)}">${esc(forLabel(campaign))}</span>`;
}

// Fields to ask for whenever a campaign is embedded in another query
export const CAMPAIGN_UNIT_FIELDS = 'budget, department_id, for_department_id, archived_at';
