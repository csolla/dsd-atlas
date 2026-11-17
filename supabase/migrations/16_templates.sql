-- 16_templates.sql
-- Must-have 6: project templates. A template is a project marked
-- is_template: it has sections, tasks, subtasks and fields like any other
-- project, but it is never worked in. Templates:
--   * only show in the Projects page's Templates tab,
--   * can't have time logged on them,
--   * never send notifications (assignments, comments, due reminders).
-- copy_project() makes a new project from a template (or saves a project as
-- a new template): sections, tasks, subtasks, fields and their values, and
-- who can see it, with every due date moved by the same number of days as
-- the start date. Tasks always start as To do.
-- Safe to run more than once.

alter table public.campaigns
  add column if not exists is_template boolean not null default false;
create index if not exists campaigns_template_idx on public.campaigns (is_template);

-- A project can't become a template, or a template a project, after it's
-- made (a copy is made instead)
create or replace function public.keep_template_flag()
returns trigger language plpgsql as $$
begin
  if new.is_template is distinct from old.is_template then
    raise exception 'A project can''t be turned into a template. Use “Save as template” to make a copy.';
  end if;
  return new;
end $$;

drop trigger if exists keep_template_flag on public.campaigns;
create trigger keep_template_flag
  before update on public.campaigns
  for each row execute function public.keep_template_flag();

-- No time on archived projects (12) or on templates
create or replace function public.block_time_on_archived()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.campaign_id is not null
     and (tg_op = 'INSERT' or new.campaign_id is distinct from old.campaign_id) then
    if exists (select 1 from public.campaigns where id = new.campaign_id and is_template) then
      raise exception 'This is a template. Create a project from it to log time.';
    end if;
    if exists (select 1 from public.campaigns where id = new.campaign_id and archived_at is not null) then
      raise exception 'This project is archived. Unarchive it to log time on it.';
    end if;
  end if;
  return new;
end $$;

-- Notifications (same as 13), never about a task in a template
create or replace function public.notify(
  p_recipient uuid, p_type text, p_message text, p_task uuid default null, p_actor uuid default null,
  p_dedupe text default null, p_unit text default null, p_month date default null)
returns void language plpgsql security definer set search_path = public as $$
begin
  if p_recipient is null or p_recipient = p_actor then
    return;
  end if;
  if not exists (select 1 from public.people where id = p_recipient and active) then
    return;
  end if;
  if p_task is not null and exists (
    select 1 from public.tasks t join public.campaigns c on c.id = t.campaign_id
    where t.id = p_task and c.is_template) then
    return;
  end if;
  if p_task is not null and not exists (
    select 1 from public.tasks t where t.id = p_task and public.person_can_see_campaign(p_recipient, t.campaign_id)) then
    return;
  end if;
  insert into public.notifications (recipient_id, type, task_id, actor_id, business_unit, month, message, dedupe_key)
  values (p_recipient, p_type, p_task, p_actor, p_unit, p_month, p_message, p_dedupe)
  on conflict (recipient_id, dedupe_key) where dedupe_key is not null do nothing;
end $$;

revoke execute on function public.notify(uuid, text, text, uuid, uuid, text, text, date) from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- Copy a project: from a template (p_as_template false) or into a new
-- template (p_as_template true). p_values overrides the copy's details:
-- name, description, department_id, for_department_id, status, start_date,
-- end_date, owner_id, planned_hours, private. Runs with the person's own
-- permissions, so they can only copy what they can see.
-- ---------------------------------------------------------------------------
create or replace function public.copy_project(p_source uuid, p_values jsonb default '{}', p_as_template boolean default false)
returns uuid language plpgsql security invoker set search_path = public as $$
declare
  s public.campaigns;
  new_id uuid;
  new_start date;
  shift integer;
  section_map jsonb := '{}';
  field_map jsonb := '{}';
  task_map jsonb := '{}';
  r record;
  nid uuid;
begin
  if not public.can_edit_work() then
    raise exception 'Only Admins and team members can create projects';
  end if;
  select * into s from public.campaigns where id = p_source;
  if not found then
    raise exception 'That template wasn''t found, or you can''t see it';
  end if;

  new_start := coalesce((p_values->>'start_date')::date, s.start_date);
  shift := coalesce(new_start - s.start_date, 0);

  insert into public.campaigns (name, description, department_id, for_department_id, status, start_date, end_date,
                                owner_id, planned_hours, private, is_template)
  values (
    coalesce(nullif(trim(p_values->>'name'), ''), s.name),
    case when p_values ? 'description' then nullif(trim(p_values->>'description'), '') else s.description end,
    coalesce((p_values->>'department_id')::uuid, s.department_id),
    case when p_values ? 'for_department_id' then (p_values->>'for_department_id')::uuid else s.for_department_id end,
    coalesce(p_values->>'status', 'planned'),
    new_start,
    coalesce((p_values->>'end_date')::date, s.end_date + shift),
    case when p_values ? 'owner_id' then (p_values->>'owner_id')::uuid else auth.uid() end,
    coalesce((p_values->>'planned_hours')::numeric, s.planned_hours),
    coalesce((p_values->>'private')::boolean, s.private),
    p_as_template)
  returning id into new_id;

  -- Who can see it, when private
  insert into public.campaign_access (campaign_id, person_id, department_id)
  select new_id, person_id, department_id from public.campaign_access where campaign_id = p_source;

  for r in select * from public.sections where campaign_id = p_source order by position, created_at loop
    insert into public.sections (campaign_id, name, position) values (new_id, r.name, r.position) returning id into nid;
    section_map := section_map || jsonb_build_object(r.id::text, nid);
  end loop;

  for r in select * from public.custom_fields where campaign_id = p_source order by position, created_at loop
    insert into public.custom_fields (campaign_id, name, type, settings, position)
    values (new_id, r.name, r.type, r.settings, r.position) returning id into nid;
    field_map := field_map || jsonb_build_object(r.id::text, nid);
  end loop;

  -- Main tasks first, then their subtasks. An assignee who can't see the
  -- new project is left out rather than stopping the copy.
  for r in select * from public.tasks where campaign_id = p_source
           order by (parent_id is not null), position, created_at loop
    begin
      insert into public.tasks (campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position)
      values (new_id, (task_map->>r.parent_id::text)::uuid, (section_map->>r.section_id::text)::uuid, r.title, r.description,
              r.assignee_id, r.due_date + shift, 'todo', r.position)
      returning id into nid;
    exception when others then
      insert into public.tasks (campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position)
      values (new_id, (task_map->>r.parent_id::text)::uuid, (section_map->>r.section_id::text)::uuid, r.title, r.description,
              null, r.due_date + shift, 'todo', r.position)
      returning id into nid;
    end;
    task_map := task_map || jsonb_build_object(r.id::text, nid);
  end loop;

  insert into public.task_field_values (task_id, field_id, campaign_id, value)
  select (task_map->>v.task_id::text)::uuid, (field_map->>v.field_id::text)::uuid, new_id, v.value
  from public.task_field_values v
  where v.campaign_id = p_source and task_map ? v.task_id::text and field_map ? v.field_id::text;

  return new_id;
end $$;

revoke execute on function public.copy_project(uuid, jsonb, boolean) from public, anon;
grant execute on function public.copy_project(uuid, jsonb, boolean) to authenticated;

-- Check: every column should say true
select
  exists (select 1 from information_schema.columns
          where table_name = 'campaigns' and column_name = 'is_template') as template_column,
  exists (select 1 from pg_proc where proname = 'copy_project') as copy_function,
  exists (select 1 from pg_trigger where tgname = 'keep_template_flag') as template_flag_kept,
  (select count(*) from public.campaigns where is_template) = 0 as no_templates_yet;
