-- 22: Hours on personal to-dos are internal time
--
-- Time logged on someone's "My to-dos" (see 20) counts as internal time,
-- like meetings and admin: it never uses up the Education or Planning Center
-- budgets. Reports show internal time as "Corporate" (Marketing's own
-- business unit). Hours already logged on to-dos move to internal too.
--
-- Safe to run more than once.

alter table public.campaigns drop constraint if exists campaigns_budget_check;
alter table public.campaigns add constraint campaigns_budget_check
  check (budget in ('education', 'planning_center', 'shared', 'other', 'internal'));

-- Same as 11, with personal to-dos first
create or replace function public.set_campaign_budget()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  owner_key text;
  for_key text;
begin
  if new.personal_of is not null then
    new.for_department_id := null;
    new.budget := 'internal';
    return new;
  end if;

  select key into owner_key from public.departments where id = new.department_id;

  if owner_key = 'marketing' then
    if new.for_department_id is null then
      new.budget := 'shared';
    else
      select key into for_key from public.departments where id = new.for_department_id;
      if for_key = 'education' then
        new.budget := 'education';
      elsif for_key in ('planning_center', 'delight') then
        new.budget := 'planning_center';
      else
        new.budget := 'other';
      end if;
    end if;
  else
    new.for_department_id := coalesce(new.for_department_id, new.department_id);
    new.budget := 'other';
  end if;
  return new;
end $$;

-- Re-save the to-do lists: their budget becomes internal, and the hours
-- logged on them follow (campaign_unit_changed in 11)
update public.campaigns set budget = budget where personal_of is not null;

-- Check: should say 0, 0
select
  (select count(*) from public.campaigns where personal_of is not null and budget <> 'internal') as todo_lists_not_internal,
  (select count(*) from public.time_entries e join public.campaigns c on c.id = e.campaign_id
   where c.personal_of is not null and e.budget <> 'internal') as todo_hours_not_internal;
