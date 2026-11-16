-- 11_departments.sql
-- Must-have 1: every team as a department.
--
--  * Business units (Education, DSD Center, Corporate) are the broad split.
--  * Departments (Marketing, Education, Planning Center, Delight, Corporate,
--    and any the admin adds) each belong to one business unit.
--  * Every person and every campaign belongs to one department (the owner).
--  * Each campaign also says who the work is FOR. By default that's its own
--    department. Marketing campaigns can be for any department, or for both
--    Education and Planning Center (split by the Team rules setting, 70 / 30),
--    so "Shared" is no longer a label: it's a Marketing campaign for both.
--  * The old campaigns.business_unit and time_entries.business_unit columns
--    are renamed "budget": which of Marketing's budgets the hours count
--    against (education, planning_center, shared, internal, or other =
--    not a Marketing budget). The app sets it; nobody types it.
--  * Marketing's capacity and budgets now count Marketing people only.
--
-- Safe to run more than once.

-- ---------------------------------------------------------------------------
-- Departments
-- ---------------------------------------------------------------------------
create table if not exists public.departments (
  id uuid primary key default gen_random_uuid(),
  -- Fixed name the app uses to recognise the starting departments; empty
  -- for departments added later
  key text unique,
  name text not null unique check (length(trim(name)) > 0),
  business_unit text not null check (business_unit in ('education', 'dsd_center', 'corporate')),
  created_at timestamptz not null default now()
);

insert into public.departments (key, name, business_unit) values
  ('marketing', 'Marketing', 'corporate'),
  ('education', 'Education', 'education'),
  ('planning_center', 'Planning Center', 'dsd_center'),
  ('delight', 'Delight', 'dsd_center'),
  ('corporate', 'Corporate', 'corporate')
on conflict (key) do nothing;

create or replace function public.department_id_for(p_key text)
returns uuid language sql stable security definer set search_path = public as $$
  select id from public.departments where key = p_key
$$;

revoke all on public.departments from anon;
grant select, insert, update, delete on public.departments to authenticated;
alter table public.departments enable row level security;

drop policy if exists "departments: active users read" on public.departments;
create policy "departments: active users read" on public.departments
  for select to authenticated using (public.is_active_user());

drop policy if exists "departments: admin adds" on public.departments;
create policy "departments: admin adds" on public.departments
  for insert to authenticated with check (public.is_admin() and key is null);

drop policy if exists "departments: admin edits" on public.departments;
create policy "departments: admin edits" on public.departments
  for update to authenticated using (public.is_admin()) with check (public.is_admin());

-- The five starting departments can't be deleted (the app relies on them)
drop policy if exists "departments: admin deletes added ones" on public.departments;
create policy "departments: admin deletes added ones" on public.departments
  for delete to authenticated using (public.is_admin() and key is null);

-- The fixed key can't be changed from the app
create or replace function public.protect_department_key()
returns trigger language plpgsql as $$
begin
  if auth.uid() is not null and new.key is distinct from old.key then
    raise exception 'This department''s key can''t be changed';
  end if;
  return new;
end $$;

drop trigger if exists protect_department_key on public.departments;
create trigger protect_department_key
  before update on public.departments
  for each row execute function public.protect_department_key();

-- ---------------------------------------------------------------------------
-- People: each person's department. Everyone already in the tool is on
-- the Marketing team; the admin can change it in Capacity > People.
-- ---------------------------------------------------------------------------
alter table public.people
  add column if not exists department_id uuid references public.departments(id) on delete restrict;

update public.people set department_id = public.department_id_for('marketing') where department_id is null;

-- Only the admin changes someone's department (adds department_id to the 05 rules)
create or replace function public.protect_people_cols()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  -- Changes made in the SQL editor (no signed-in user) are allowed
  if auth.uid() is null then
    return new;
  end if;

  if new.id is distinct from old.id or new.email is distinct from old.email then
    raise exception 'Email cannot be changed';
  end if;

  if new.active is distinct from old.active
     and coalesce(current_setting('app.setting_active', true), '') <> 'on' then
    raise exception 'Use set_person_active to activate or deactivate someone';
  end if;

  if not public.is_admin()
     and (new.role is distinct from old.role
          or new.hours_per_day is distinct from old.hours_per_day
          or new.counts_in_capacity is distinct from old.counts_in_capacity
          or new.holiday_calendar is distinct from old.holiday_calendar
          or new.working_days is distinct from old.working_days
          or new.department_id is distinct from old.department_id) then
    raise exception 'Only the admin can change roles, departments and capacity settings';
  end if;

  if old.id = auth.uid() and old.role = 'admin' and new.role <> 'admin' then
    raise exception 'You can''t remove your own admin access';
  end if;

  return new;
end $$;

-- ---------------------------------------------------------------------------
-- Campaigns: owner department, who it's for, and the Marketing budget
-- ---------------------------------------------------------------------------
alter table public.campaigns
  add column if not exists department_id uuid references public.departments(id) on delete restrict,
  add column if not exists for_department_id uuid references public.departments(id) on delete restrict;

do $$
begin
  if exists (select 1 from information_schema.columns
             where table_schema = 'public' and table_name = 'campaigns' and column_name = 'business_unit') then
    -- Every campaign so far is Marketing's; "for" comes from the old unit
    update public.campaigns
       set department_id = public.department_id_for('marketing'),
           for_department_id = case business_unit
             when 'education' then public.department_id_for('education')
             when 'planning_center' then public.department_id_for('planning_center')
             else null end
     where department_id is null;
    alter table public.campaigns rename column business_unit to budget;
  end if;
end $$;

alter table public.campaigns alter column department_id set not null;
alter table public.campaigns drop constraint if exists campaigns_business_unit_check;
alter table public.campaigns drop constraint if exists campaigns_budget_check;
alter table public.campaigns add constraint campaigns_budget_check
  check (budget in ('education', 'planning_center', 'shared', 'other'));

-- Works out "for" and the budget from the department. No "for" means the
-- campaign's own department, except on Marketing campaigns, where it means
-- both Education and Planning Center. Marketing work for Delight counts
-- against the Planning Center budget (both are DSD Center); for any other
-- department, against neither budget ("other").
create or replace function public.set_campaign_budget()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  owner_key text;
  for_key text;
begin
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

drop trigger if exists set_campaign_budget on public.campaigns;
create trigger set_campaign_budget
  before insert or update on public.campaigns
  for each row execute function public.set_campaign_budget();

create index if not exists campaigns_department_idx on public.campaigns (department_id);

-- ---------------------------------------------------------------------------
-- Time entries: budget column, with "other" for hours that don't count
-- against Marketing's Education / Planning Center budgets
-- ---------------------------------------------------------------------------
do $$
begin
  if exists (select 1 from information_schema.columns
             where table_schema = 'public' and table_name = 'time_entries' and column_name = 'business_unit') then
    alter table public.time_entries rename column business_unit to budget;
  end if;
end $$;

alter table public.time_entries drop constraint if exists time_entries_business_unit_check;
alter table public.time_entries drop constraint if exists time_entries_budget_check;
alter table public.time_entries add constraint time_entries_budget_check
  check (budget in ('education', 'planning_center', 'shared', 'internal', 'other'));

-- The hour columns are worked out by the database. Re-create them so
-- "other" hours count as neither Education nor Planning Center, and add
-- other_hours. The two views that read them are re-created below.
do $$
begin
  if not exists (select 1 from information_schema.columns
                 where table_schema = 'public' and table_name = 'time_entries' and column_name = 'other_hours') then
    drop view if exists public.campaign_hours;
    drop view if exists public.monthly_unit_hours;
    alter table public.time_entries
      drop column if exists education_hours,
      drop column if exists planning_center_hours,
      drop column if exists internal_hours;
    alter table public.time_entries
      add column education_hours numeric(8,4) generated always as (
        case when budget in ('education', 'planning_center', 'shared')
             then round(minutes / 60.0 * coalesce(education_share, 0), 4) else 0 end) stored,
      add column planning_center_hours numeric(8,4) generated always as (
        case when budget in ('education', 'planning_center', 'shared')
             then round(minutes / 60.0 * (1 - coalesce(education_share, 0)), 4) else 0 end) stored,
      add column internal_hours numeric(8,4) generated always as (
        case when budget = 'internal' then minutes / 60.0 else 0 end) stored,
      add column other_hours numeric(8,4) generated always as (
        case when budget = 'other' then minutes / 60.0 else 0 end) stored;
  end if;
end $$;

-- Same rules as 03, reading the campaign's budget. Entries that are
-- already Shared keep the split they were saved with.
create or replace function public.set_time_entry_unit()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  campaign_budget text;
  task_campaign uuid;
  split numeric;
begin
  if new.campaign_id is null then
    if new.task_id is not null then
      raise exception 'Internal time can''t be logged on a task';
    end if;
    new.budget := 'internal';
    new.education_share := null;
  else
    select budget into campaign_budget from public.campaigns where id = new.campaign_id;
    if new.task_id is not null then
      select campaign_id into task_campaign from public.tasks where id = new.task_id;
      if task_campaign is distinct from new.campaign_id then
        raise exception 'That task belongs to a different campaign';
      end if;
    end if;

    if campaign_budget = 'shared' then
      if tg_op = 'UPDATE' and old.budget = 'shared' and old.education_share is not null then
        new.education_share := old.education_share;
      else
        select shared_split_education / 100.0 into split from public.team_settings limit 1;
        new.education_share := coalesce(split, 0.7);
      end if;
    elsif campaign_budget = 'education' then
      new.education_share := 1;
    elsif campaign_budget = 'planning_center' then
      new.education_share := 0;
    else
      new.education_share := null;
    end if;
    new.budget := campaign_budget;
  end if;

  if tg_op = 'UPDATE' then
    new.updated_at := now();
  end if;
  return new;
end $$;

-- When a campaign's budget changes (new department or "for"), its entries
-- follow. No column list: the budget is set by set_campaign_budget, not
-- typed, so "update of budget" would never fire.
create or replace function public.campaign_unit_changed()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  update public.time_entries set budget = budget where campaign_id = new.id;
  return new;
end $$;

drop trigger if exists campaign_unit_changed on public.campaigns;
create trigger campaign_unit_changed
  after update on public.campaigns
  for each row when (old.budget is distinct from new.budget)
  execute function public.campaign_unit_changed();

-- ---------------------------------------------------------------------------
-- Totals views (same as 03 and 04). Internal hours in the monthly trend
-- are Marketing people's only.
-- ---------------------------------------------------------------------------
create or replace view public.campaign_hours with (security_invoker = true) as
  select campaign_id,
         sum(hours) as hours,
         sum(education_hours) as education_hours,
         sum(planning_center_hours) as planning_center_hours
  from public.time_entries
  where campaign_id is not null
  group by campaign_id;

create or replace view public.monthly_unit_hours with (security_invoker = true) as
  select date_trunc('month', e.entry_date)::date as month,
         sum(e.education_hours) as education_hours,
         sum(e.planning_center_hours) as planning_center_hours,
         coalesce(sum(e.internal_hours) filter (where p.department_id = public.department_id_for('marketing')), 0) as internal_hours
  from public.time_entries e
  join public.people p on p.id = e.person_id
  group by 1;

revoke all on public.campaign_hours, public.monthly_unit_hours from anon;
grant select on public.campaign_hours, public.monthly_unit_hours to authenticated;

-- ---------------------------------------------------------------------------
-- Marketing's automatic budget counts Marketing people only (same as
-- capacityPeople in js/capacity.js)
-- ---------------------------------------------------------------------------
create or replace function public.unit_month_budget(p_month date, out education numeric, out planning_center numeric)
language plpgsql stable security definer set search_path = public as $$
declare
  first_day date := date_trunc('month', p_month)::date;
  last_day date := (date_trunc('month', p_month) + interval '1 month - 1 day')::date;
  team_hours numeric;
  s record;
  typed record;
begin
  select coalesce(sum(public.person_working_hours(id, first_day, last_day)), 0) into team_hours
  from public.people
  where active and counts_in_capacity and department_id = public.department_id_for('marketing');
  select productive_pct, budget_split_education into s from public.team_settings limit 1;
  select education_hours, planning_center_hours into typed from public.monthly_budgets where month = first_day;

  education := coalesce(typed.education_hours,
    team_hours * coalesce(s.productive_pct, 80) / 100.0 * coalesce(s.budget_split_education, 70) / 100.0);
  planning_center := coalesce(typed.planning_center_hours,
    team_hours * coalesce(s.productive_pct, 80) / 100.0 * (100 - coalesce(s.budget_split_education, 70)) / 100.0);
end $$;

revoke execute on function public.unit_month_budget(date) from public, anon;

-- ---------------------------------------------------------------------------
-- Friday timesheet reminder: Marketing people only for now (same job as 06,
-- only the hours-reminder condition changes). Other departments start
-- logging hours with must-have 11.
-- ---------------------------------------------------------------------------
create or replace function public.run_scheduled_notifications(p_now timestamptz default now())
returns void language plpgsql security definer set search_path = public as $$
declare
  p record;
  t record;
  local_time timestamp;
  today date;
  dow int;
  next_working date;
  week_start date;
  expected numeric;
  logged numeric;
begin
  for p in select * from public.people where active and role in ('admin', 'member') loop
    local_time := p_now at time zone case p.holiday_calendar when 'England' then 'Europe/London' else 'Europe/Madrid' end;
    today := local_time::date;
    dow := extract(isodow from local_time);
    continue when dow > 5;

    if extract(hour from local_time) = 8 then
      -- Due by the next working day (Friday covers the weekend and Monday)
      next_working := today + case when dow = 5 then 3 else 1 end;
      for t in
        select tk.id, tk.title, coalesce(tk.parent_id, tk.id) as open_task,
               coalesce(tk.due_date, parent.due_date) as due
        from public.tasks tk
        left join public.tasks parent on parent.id = tk.parent_id
        where tk.assignee_id = p.id and tk.status <> 'done'
          and coalesce(tk.due_date, parent.due_date) > today
          and coalesce(tk.due_date, parent.due_date) <= next_working
      loop
        perform public.notify(p.id, 'due_tomorrow',
          format('“%s” is due %s', t.title,
            case when t.due = today + 1 then 'tomorrow' else 'on ' || trim(to_char(t.due, 'FMDay FMDD Mon')) end),
          t.open_task, null, 'due:' || t.id || ':' || t.due);
      end loop;

      -- Became overdue (sent once per task; the last 7 days only)
      for t in
        select tk.id, tk.title, coalesce(tk.parent_id, tk.id) as open_task,
               coalesce(tk.due_date, parent.due_date) as due
        from public.tasks tk
        left join public.tasks parent on parent.id = tk.parent_id
        where tk.assignee_id = p.id and tk.status <> 'done'
          and coalesce(tk.due_date, parent.due_date) < today
          and coalesce(tk.due_date, parent.due_date) >= today - 7
      loop
        perform public.notify(p.id, 'overdue',
          format('“%s” is overdue (it was due %s)', t.title, trim(to_char(t.due, 'FMDay FMDD Mon'))),
          t.open_task, null, 'overdue:' || t.id || ':' || t.due);
      end loop;
    end if;

    -- Friday 12:00: logged under 90% of this week's working hours
    if dow = 5 and extract(hour from local_time) = 12 and p.counts_in_capacity
       and p.department_id = public.department_id_for('marketing') then
      week_start := today - (dow - 1);
      expected := public.person_working_hours(p.id, week_start, week_start + 6);
      select coalesce(sum(minutes), 0) / 60.0 into logged
      from public.time_entries where person_id = p.id and entry_date between week_start and week_start + 6;
      if expected > 0 and logged < expected * 0.9 then
        perform public.notify(p.id, 'hours_reminder',
          format('Remember to complete your timesheet: you''ve logged %s of %s h this week', round(logged, 1), round(expected, 1)),
          null, null, 'hours:' || week_start);
      end if;
    end if;
  end loop;
end $$;

-- ---------------------------------------------------------------------------
-- Check: every column should say true
-- ---------------------------------------------------------------------------
select
  (select count(*) from public.departments where key is not null) = 5 as five_departments,
  not exists (select 1 from public.people where department_id is null) as everyone_has_a_department,
  not exists (select 1 from public.campaigns where department_id is null) as every_campaign_has_a_department,
  (select count(*) from public.campaigns where budget = 'shared') as campaigns_for_both,
  exists (select 1 from information_schema.columns
          where table_name = 'time_entries' and column_name = 'other_hours') as other_hours_column,
  to_regclass('public.campaign_hours') is not null and to_regclass('public.monthly_unit_hours') is not null as totals_views,
  exists (select 1 from pg_trigger where tgname = 'set_campaign_budget') as campaign_budget_rule,
  (select count(*) from pg_policies where schemaname = 'public' and tablename = 'departments') = 4 as permission_rules;
