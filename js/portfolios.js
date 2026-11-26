import { supabase } from './supabase.js';
import { isEmpty } from './fields.js';

// Portfolios (31_portfolios.sql), like Asana's: a portfolio groups projects
// and other portfolios, with its own columns (portfolio_fields) filled in
// per row (portfolio_field_values).

const ITEM_FIELDS = `id, position, campaign_id, child_portfolio_id,
  campaign:campaigns(id, name, status, owner_id, start_date, end_date, planned_hours, private, archived_at, department_id, for_department_id, budget),
  child:child_portfolio_id(id, name, owner_id, private)`;

export async function listPortfolios() {
  const { data, error } = await supabase.from('portfolios').select('*, items:portfolio_items!portfolio_id(count)').order('name');
  if (error) throw error;
  return data.map(p => ({ ...p, count: p.items?.[0]?.count || 0 }));
}

export async function getPortfolio(id) {
  const { data, error } = await supabase.from('portfolios').select('*, members:portfolio_members(person_id)').eq('id', id).maybeSingle();
  if (error) throw error;
  return data;
}

export async function loadItems(portfolioId) {
  const { data, error } = await supabase.from('portfolio_items').select(ITEM_FIELDS).eq('portfolio_id', portfolioId).order('position');
  if (error) throw error;
  return data;
}

// { itemId: { fieldId: value } }
export async function loadValues(itemIds) {
  if (!itemIds.length) return {};
  const { data, error } = await supabase.from('portfolio_field_values').select('item_id, field_id, value').in('item_id', itemIds);
  if (error) throw error;
  const out = {};
  data.forEach(r => { (out[r.item_id] ||= {})[r.field_id] = r.value; });
  return out;
}

export async function saveValue(itemId, fieldId, value) {
  const { error } = isEmpty(value)
    ? await supabase.from('portfolio_field_values').delete().eq('item_id', itemId).eq('field_id', fieldId)
    : await supabase.from('portfolio_field_values').upsert({ item_id: itemId, field_id: fieldId, value }, { onConflict: 'item_id,field_id' });
  if (error) throw error;
}

export async function savePortfolio(values, id = null) {
  const query = id ? supabase.from('portfolios').update(values).eq('id', id) : supabase.from('portfolios').insert(values);
  const { data, error } = await query.select().single();
  if (error) throw error;
  return data;
}

export async function deletePortfolio(id) {
  const { error } = await supabase.from('portfolios').delete().eq('id', id);
  if (error) throw error;
}

// Who a private portfolio is shared with: replace the list
export async function setMembers(portfolioId, personIds) {
  const { error } = await supabase.from('portfolio_members').delete().eq('portfolio_id', portfolioId);
  if (error) throw error;
  if (personIds.length) {
    const { error: addError } = await supabase.from('portfolio_members').insert(personIds.map(person_id => ({ portfolio_id: portfolioId, person_id })));
    if (addError) throw addError;
  }
}

export async function addItems(portfolioId, rows, after = 0) {
  if (!rows.length) return;
  const { error } = await supabase.from('portfolio_items').insert(rows.map((r, i) => ({ portfolio_id: portfolioId, position: after + (i + 1) * 1000, ...r })));
  if (error) throw error;
}

export async function removeItem(itemId) {
  const { error } = await supabase.from('portfolio_items').delete().eq('id', itemId);
  if (error) throw error;
}

// The portfolios a project is in (for its ⋯ menu)
export async function portfoliosOfProject(campaignId) {
  const { data, error } = await supabase.from('portfolio_items').select('id, portfolio_id').eq('campaign_id', campaignId);
  if (error) throw error;
  return data;
}

// For the shared Fields dialog (js/fields-dialog.js)
const fieldsTable = () => supabase.from('portfolio_fields');
export const PORTFOLIO_FIELDS = {
  load: async id => {
    const { data, error } = await fieldsTable().select('*').eq('portfolio_id', id).order('position');
    if (error) throw error;
    return data;
  },
  create: async values => { const { error } = await fieldsTable().insert(values); if (error) throw error; },
  update: async (id, values) => { const { error } = await fieldsTable().update(values).eq('id', id); if (error) throw error; },
  remove: async id => { const { error } = await fieldsTable().delete().eq('id', id); if (error) throw error; },
  ownerKey: 'portfolio_id', sets: false, thing: 'row',
  intro: 'Columns for this portfolio, such as a priority or a status of your own. Each project in it gets a value, filled in right in the table.',
};
