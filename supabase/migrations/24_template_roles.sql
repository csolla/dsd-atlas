-- 24: Roles in templates
--
-- A task in a template can have a role, such as "Account manager" or
-- "Coach". When a project is made from the template, the person picked for
-- each role is given every task with that role (a subtask without its own
-- role follows its main task). Roles not picked keep the template's
-- assignee. p_values gets "roles": {"Account manager": "<person id>"}.
-- The DSD Clinics Onboarding template starts with two roles: Michelle
-- Carpio's tasks are the Account manager's, Lindi Rigo's the Coach's.
--
-- Safe to run more than once.

alter table public.tasks add column if not exists template_role text;
alter table public.tasks drop constraint if exists tasks_template_role_check;
alter table public.tasks add constraint tasks_template_role_check
  check (template_role is null or length(trim(template_role)) between 1 and 60);

-- Same as 16, with roles
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
  role_map jsonb := coalesce(p_values->'roles', '{}');
  t_role text;
  who uuid;
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

  -- Main tasks first, then their subtasks. A task's role (a subtask without
  -- its own uses its main task's) gives it the person picked for that role;
  -- otherwise it keeps the template's assignee. An assignee who can't see
  -- the new project is left out rather than stopping the copy.
  for r in select t.*, coalesce(t.template_role, p.template_role) as effective_role
           from public.tasks t left join public.tasks p on p.id = t.parent_id
           where t.campaign_id = p_source
           order by (t.parent_id is not null), t.position, t.created_at loop
    t_role := r.effective_role;
    who := coalesce(nullif(role_map->>t_role, '')::uuid, r.assignee_id);
    begin
      insert into public.tasks (campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position, template_role)
      values (new_id, (task_map->>r.parent_id::text)::uuid, (section_map->>r.section_id::text)::uuid, r.title, r.description,
              who, r.due_date + shift, 'todo', r.position, r.template_role)
      returning id into nid;
    exception when others then
      insert into public.tasks (campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position, template_role)
      values (new_id, (task_map->>r.parent_id::text)::uuid, (section_map->>r.section_id::text)::uuid, r.title, r.description,
              null, r.due_date + shift, 'todo', r.position, r.template_role)
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

-- DSD Clinics Onboarding: roles from who usually does each task
update public.tasks set template_role = 'Account manager'
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and template_role is null
  and description like 'Usually done by: Michelle Carpio%';
update public.tasks set template_role = 'Coach'
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and template_role is null
  and description like 'Usually done by: Lindi Rigo%';

-- Check: Account manager about 29, Coach about 14
select template_role, count(*) as tasks
from public.tasks
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and template_role is not null
group by template_role order by template_role;
