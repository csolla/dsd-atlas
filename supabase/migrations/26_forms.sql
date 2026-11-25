-- 26: Forms (must-have 9)
--
-- A form belongs to a project. Everyone signed in to Atlas (directors
-- included) can send it, even when the project is private: sending creates
-- a task in the project without giving access to it.
--
-- The first question is always the task's title (title_label). Each other
-- question (questions jsonb, in order) goes to one of three places:
--   {"key": "q1", "label": "Deadline", "help": "...", "required": true,
--    "target": "due_date" | "text" | "field", "field_id": "<custom field>"}
-- "text" answers are written into the task's description, under their
-- question. The task goes into section_id, assigned to assignee_id; if
-- requestor_field_id is a person field, it's filled with whoever sent it.
--
-- list_forms(), get_form() and submit_form() are how people see and send
-- forms; the forms table itself is only for the project's editors.
--
-- Safe to run more than once.

create table if not exists public.forms (
  id uuid primary key default gen_random_uuid(),
  campaign_id uuid not null references public.campaigns(id) on delete cascade,
  name text not null check (length(trim(name)) between 1 and 120),
  intro text check (intro is null or length(intro) <= 4000),
  title_label text not null default 'What do you need?' check (length(trim(title_label)) between 1 and 200),
  section_id uuid references public.sections(id) on delete set null,
  assignee_id uuid references public.people(id) on delete set null,
  requestor_field_id uuid references public.custom_fields(id) on delete set null,
  questions jsonb not null default '[]' check (jsonb_typeof(questions) = 'array'),
  active boolean not null default true,
  created_by uuid default auth.uid() references public.people(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists forms_campaign_idx on public.forms (campaign_id);

drop trigger if exists forms_touch on public.forms;
create trigger forms_touch before update on public.forms
  for each row execute function public.touch_updated_at();

alter table public.forms enable row level security;
revoke all on public.forms from anon;
grant select, insert, update, delete on public.forms to authenticated;

drop policy if exists "forms: project editors read" on public.forms;
create policy "forms: project editors read" on public.forms
  for select to authenticated using (public.is_active_user() and public.can_see_campaign(campaign_id));
drop policy if exists "forms: project editors write" on public.forms;
create policy "forms: project editors write" on public.forms
  for all to authenticated
  using (public.can_edit_work() and public.can_see_campaign(campaign_id))
  with check (public.can_edit_work() and public.can_see_campaign(campaign_id));

-- Forms people can send: active ones in live projects (not templates,
-- archived projects or personal to-dos)
create or replace function public.list_forms()
returns table (id uuid, name text, intro text, project text, project_id uuid)
language sql stable security definer set search_path = public as $$
  select f.id, f.name, f.intro, c.name, c.id
  from public.forms f join public.campaigns c on c.id = f.campaign_id
  where public.is_active_user() and f.active
    and c.archived_at is null and not c.is_template and c.personal_of is null
  order by f.name
$$;

-- One form, with what its questions need to be shown (field names, types
-- and choices), for anyone signed in
create or replace function public.get_form(p_form uuid)
returns jsonb language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'id', f.id, 'name', f.name, 'intro', f.intro, 'title_label', f.title_label,
    'project', c.name, 'project_id', c.id,
    'questions', coalesce((
      select jsonb_agg(q || case when q->>'target' = 'field' then jsonb_build_object('field',
               (select jsonb_build_object('id', cf.id, 'name', cf.name, 'type', cf.type, 'settings', cf.settings)
                from public.custom_fields cf where cf.id = (q->>'field_id')::uuid and cf.campaign_id = c.id))
             else '{}'::jsonb end order by n)
      from jsonb_array_elements(f.questions) with ordinality as x(q, n)), '[]'::jsonb))
  from public.forms f join public.campaigns c on c.id = f.campaign_id
  where f.id = p_form and f.active and public.is_active_user()
    and c.archived_at is null and not c.is_template and c.personal_of is null
$$;

-- Send a form: makes the task and returns its id. p_answers is
-- {"<question key>": value}; field values in Atlas's shapes (js/fields.js).
create or replace function public.submit_form(p_form uuid, p_title text, p_answers jsonb default '{}')
returns uuid language plpgsql security definer set search_path = public as $$
declare
  f public.forms;
  c public.campaigns;
  q jsonb;
  answer jsonb;
  label text;
  body text := '';
  due date;
  new_id uuid;
  sender text;
  section uuid;
begin
  if not public.is_active_user() then
    raise exception 'Sign in to Atlas to send this form';
  end if;
  select * into f from public.forms where id = p_form and active;
  if not found then
    raise exception 'This form isn''t available any more';
  end if;
  select * into c from public.campaigns where id = f.campaign_id;
  if c.archived_at is not null or c.is_template or c.personal_of is not null then
    raise exception 'This form isn''t available any more';
  end if;
  if coalesce(trim(p_title), '') = '' then
    raise exception 'Please answer "%"', f.title_label;
  end if;

  for q in select value from jsonb_array_elements(f.questions) loop
    answer := p_answers -> (q->>'key');
    label := coalesce(q->>'label', 'Question');
    if answer is null or answer = 'null'::jsonb or answer = '""'::jsonb or answer = '[]'::jsonb then
      if coalesce((q->>'required')::boolean, false) then
        raise exception 'Please answer "%"', label;
      end if;
      continue;
    end if;
    if q->>'target' = 'due_date' then
      due := (answer #>> '{}')::date;
    elsif q->>'target' = 'text' then
      body := body || label || ':' || E'\n' || (answer #>> '{}') || E'\n\n';
    end if;
  end loop;

  select name into sender from public.people where id = auth.uid();
  section := (select id from public.sections where id = f.section_id and campaign_id = c.id);

  insert into public.tasks (campaign_id, section_id, title, description, assignee_id, due_date, status, position, created_by)
  values (c.id, section, left(trim(p_title), 300),
          trim(body || 'Sent by ' || coalesce(sender, 'someone') || ' through the form "' || f.name || '" on '
               || to_char(now() at time zone 'Europe/Madrid', 'DD Mon YYYY') || '.'),
          f.assignee_id, due, 'todo',
          coalesce((select max(position) from public.tasks where campaign_id = c.id and parent_id is null), 0) + 1000,
          auth.uid())
  returning id into new_id;

  -- Field answers, for fields that still belong to this project
  for q in select value from jsonb_array_elements(f.questions) where value->>'target' = 'field' loop
    answer := p_answers -> (q->>'key');
    if answer is not null and answer <> 'null'::jsonb and answer <> '""'::jsonb and answer <> '[]'::jsonb
       and exists (select 1 from public.custom_fields where id = (q->>'field_id')::uuid and campaign_id = c.id) then
      insert into public.task_field_values (task_id, field_id, value)
      values (new_id, (q->>'field_id')::uuid, answer)
      on conflict (task_id, field_id) do update set value = excluded.value;
    end if;
  end loop;

  -- Who sent it, in the project's "Requestor" person field
  if exists (select 1 from public.custom_fields where id = f.requestor_field_id and campaign_id = c.id and type = 'person') then
    insert into public.task_field_values (task_id, field_id, value)
    values (new_id, f.requestor_field_id, to_jsonb(auth.uid()::text))
    on conflict (task_id, field_id) do update set value = excluded.value;
  end if;

  return new_id;
end $$;

revoke execute on function public.list_forms() from public, anon;
revoke execute on function public.get_form(uuid) from public, anon;
revoke execute on function public.submit_form(uuid, text, jsonb) from public, anon;
grant execute on function public.list_forms() to authenticated;
grant execute on function public.get_form(uuid) to authenticated;
grant execute on function public.submit_form(uuid, text, jsonb) to authenticated;

-- Check: should say true, true, true
select
  exists (select 1 from information_schema.tables where table_name = 'forms') as forms_table,
  exists (select 1 from pg_proc where proname = 'submit_form') as submit_function,
  exists (select 1 from pg_proc where proname = 'list_forms') as list_function;
