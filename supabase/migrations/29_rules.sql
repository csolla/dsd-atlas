-- 29: Rules (must-have 10), like Asana's
--
-- Each project's editors make rules: WHEN something happens to a task (one
-- trigger), ONLY IF some things are true (optional conditions), THEN do one
-- or more actions. Rules act on main tasks. They don't set off other rules
-- (no loops), and imports run without them.
--
--   trigger    {"type": "task_added" | "section_changed" | "field_changed" | "due_changed"
--                        | "completed" | "assigned", "section_id", "field_id", "value", "person_id"}
--   conditions [{"type": "field", "field_id", "value"} | {"type": "section", "section_id"}
--               | {"type": "form", "form_id"}]       (a missing "value" means "has any value")
--   actions    [{"type": "assign", "person_id"} | {"type": "section", "section_id"}
--               | {"type": "field", "field_id", "value"} | {"type": "due", "days"}
--               | {"type": "status", "status"} | {"type": "comment", "text"}
--               | {"type": "subtasks", "titles": [...]}
--               | {"type": "week_section", "source": "due" | "<date field id>"}
--               | {"type": "copy", "campaign_id", "section_id", "person_id"}]
--
-- Also built in, no rule needed: a new subtask gets its main task's
-- assignee, and when the main task changes hands, its subtasks that were
-- with the old person (or nobody) follow.
--
-- Tasks remember the form that made them (form_id) and the task they were
-- copied from (copied_from).
--
-- Safe to run more than once.

alter table public.tasks add column if not exists form_id uuid references public.forms(id) on delete set null;
alter table public.tasks add column if not exists copied_from uuid references public.tasks(id) on delete set null;

create table if not exists public.rules (
  id uuid primary key default gen_random_uuid(),
  campaign_id uuid not null references public.campaigns(id) on delete cascade,
  name text not null check (length(trim(name)) between 1 and 120),
  active boolean not null default true,
  trigger jsonb not null check (jsonb_typeof(trigger) = 'object'),
  conditions jsonb not null default '[]' check (jsonb_typeof(conditions) = 'array'),
  actions jsonb not null default '[]' check (jsonb_typeof(actions) = 'array'),
  position double precision not null default 0,
  created_by uuid default auth.uid() references public.people(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists rules_campaign_idx on public.rules (campaign_id);

drop trigger if exists rules_touch on public.rules;
create trigger rules_touch before update on public.rules
  for each row execute function public.touch_updated_at();

alter table public.rules enable row level security;
revoke all on public.rules from anon;
grant select, insert, update, delete on public.rules to authenticated;
drop policy if exists "rules: project editors read" on public.rules;
create policy "rules: project editors read" on public.rules
  for select to authenticated using (public.is_active_user() and public.can_see_campaign(campaign_id));
drop policy if exists "rules: project editors write" on public.rules;
create policy "rules: project editors write" on public.rules
  for all to authenticated
  using (public.can_edit_work() and public.can_see_campaign(campaign_id))
  with check (public.can_edit_work() and public.can_see_campaign(campaign_id));

-- Does a field's value match what a rule asks for? No wanted value means
-- "has any value"; several choices match when they include the wanted one.
create or replace function public.rule_value_matches(p_current jsonb, p_wanted jsonb)
returns boolean language sql immutable as $$
  select case
    when p_current is null or p_current = 'null'::jsonb or p_current = '""'::jsonb or p_current = '[]'::jsonb then false
    when p_wanted is null or p_wanted = 'null'::jsonb then true
    when jsonb_typeof(p_current) = 'array' then p_current ? (p_wanted #>> '{}')
    else p_current = p_wanted end
$$;

-- One action on one task
create or replace function public.rule_action(p_task uuid, p_act jsonb, p_rule public.rules)
returns void language plpgsql security definer set search_path = public as $$
declare
  t public.tasks;
  d date;
  monday date;
  week text;
  sid uuid;
  sub_title text;
  n int := 0;
  target public.campaigns;
begin
  select * into t from public.tasks where id = p_task;
  case p_act->>'type'
  when 'assign' then
    update public.tasks set assignee_id = nullif(p_act->>'person_id', '')::uuid where id = p_task;
  when 'section' then
    update public.tasks set section_id = s.id
    from public.sections s where s.id = (p_act->>'section_id')::uuid and s.campaign_id = t.campaign_id and tasks.id = p_task;
  when 'field' then
    if p_act->'value' is null or p_act->'value' = 'null'::jsonb then
      delete from public.task_field_values where task_id = p_task and field_id = (p_act->>'field_id')::uuid;
    elsif exists (select 1 from public.custom_fields where id = (p_act->>'field_id')::uuid and campaign_id = t.campaign_id) then
      insert into public.task_field_values (task_id, field_id, value) values (p_task, (p_act->>'field_id')::uuid, p_act->'value')
      on conflict (task_id, field_id) do update set value = excluded.value;
    end if;
  when 'due' then
    update public.tasks set due_date = (now() at time zone 'Europe/Madrid')::date + coalesce((p_act->>'days')::int, 0) where id = p_task;
  when 'status' then
    update public.tasks set status = p_act->>'status' where id = p_task and p_act->>'status' in ('todo', 'in_progress', 'in_review', 'done');
  when 'comment' then
    if coalesce(trim(p_act->>'text'), '') <> '' then
      insert into public.comments (task_id, author_id, body)
      values (p_task, coalesce(p_rule.created_by, auth.uid()), left('Rule “' || p_rule.name || '”: ' || trim(p_act->>'text'), 10000));
    end if;
  when 'subtasks' then
    for sub_title in select trim(value #>> '{}') from jsonb_array_elements(coalesce(p_act->'titles', '[]')) loop
      continue when sub_title = '';
      n := n + 1;
      insert into public.tasks (campaign_id, parent_id, title, status, position, created_by)
      values (t.campaign_id, p_task, left(sub_title, 300), 'todo',
              coalesce((select max(position) from public.tasks where parent_id = p_task), 0) + 1000, p_rule.created_by);
    end loop;
  when 'week_section' then
    if p_act->>'source' = 'due' then
      d := t.due_date;
    else
      select (value #>> '{}')::date into d from public.task_field_values
      where task_id = p_task and field_id = (p_act->>'source')::uuid and jsonb_typeof(value) = 'string';
    end if;
    if d is not null then
      monday := d - (extract(isodow from d)::int - 1);
      week := 'Week of ' || to_char(monday, 'FMDD Mon YYYY');
      select id into sid from public.sections where campaign_id = t.campaign_id and name = week limit 1;
      if sid is null then
        insert into public.sections (campaign_id, name, position)
        values (t.campaign_id, week, coalesce((select max(position) from public.sections where campaign_id = t.campaign_id), 0) + 1000)
        returning id into sid;
      end if;
      update public.tasks set section_id = sid where id = p_task;
    end if;
  when 'copy' then
    select * into target from public.campaigns where id = (p_act->>'campaign_id')::uuid
      and archived_at is null and not is_template and personal_of is null;
    if target.id is not null and target.id <> t.campaign_id
       and not exists (select 1 from public.tasks where copied_from = p_task and campaign_id = target.id) then
      insert into public.tasks (campaign_id, section_id, title, description, assignee_id, due_date, status, position, created_by, copied_from)
      values (target.id,
              (select id from public.sections where id = nullif(p_act->>'section_id', '')::uuid and campaign_id = target.id),
              t.title, t.description, nullif(p_act->>'person_id', '')::uuid, t.due_date, 'todo',
              coalesce((select max(position) from public.tasks where campaign_id = target.id and parent_id is null), 0) + 1000,
              p_rule.created_by, p_task);
    end if;
  else
    null;
  end case;
end $$;

-- Run a project's rules for one event on one task
create or replace function public.run_rules(p_task uuid, p_event text, p_detail jsonb default '{}')
returns void language plpgsql security definer set search_path = public as $$
declare
  t public.tasks;
  r public.rules;
  cond jsonb;
  act jsonb;
  ok boolean;
begin
  if coalesce(current_setting('atlas.running_rules', true), '') = 'on'
     or coalesce(current_setting('atlas.importing', true), '') = 'on'
     or coalesce(current_setting('atlas.no_rules', true), '') = 'on' then
    return;
  end if;
  select * into t from public.tasks where id = p_task;
  if not found or t.parent_id is not null then
    return;
  end if;
  perform set_config('atlas.running_rules', 'on', true);
  for r in select * from public.rules
           where campaign_id = t.campaign_id and active and trigger->>'type' = p_event
           order by position, created_at loop
    select * into t from public.tasks where id = p_task;
    ok := coalesce(case p_event
      when 'task_added' then nullif(r.trigger->>'section_id', '') is null or t.section_id = (r.trigger->>'section_id')::uuid
      when 'section_changed' then nullif(r.trigger->>'section_id', '') is null or t.section_id = (r.trigger->>'section_id')::uuid
      when 'field_changed' then (r.trigger->>'field_id') = (p_detail->>'field_id')
        and (not (r.trigger ? 'value') or public.rule_value_matches(
          (select value from public.task_field_values where task_id = t.id and field_id = (r.trigger->>'field_id')::uuid), r.trigger->'value'))
      when 'assigned' then nullif(r.trigger->>'person_id', '') is null or t.assignee_id = (r.trigger->>'person_id')::uuid
      else true end, false);
    continue when not ok;
    for cond in select value from jsonb_array_elements(r.conditions) loop
      ok := ok and coalesce(case cond->>'type'
        when 'field' then public.rule_value_matches(
          (select value from public.task_field_values where task_id = t.id and field_id = (cond->>'field_id')::uuid), cond->'value')
        when 'section' then t.section_id is not distinct from nullif(cond->>'section_id', '')::uuid
        when 'form' then t.form_id = (cond->>'form_id')::uuid
        else true end, false);
    end loop;
    continue when not ok;
    for act in select value from jsonb_array_elements(r.actions) loop
      begin
        perform public.rule_action(p_task, act, r);
      exception when others then
        raise warning 'Rule "%" could not % : %', r.name, act->>'type', sqlerrm;
      end;
    end loop;
  end loop;
  perform set_config('atlas.running_rules', 'off', true);
end $$;

revoke execute on function public.run_rules(uuid, text, jsonb) from public, anon, authenticated;
revoke execute on function public.rule_action(uuid, jsonb, public.rules) from public, anon, authenticated;

-- What sets rules off
create or replace function public.rules_on_task_insert()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.parent_id is null then
    perform public.run_rules(new.id, 'task_added');
  end if;
  return null;
end $$;

create or replace function public.rules_on_task_update()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.parent_id is not null then
    return null;
  end if;
  if new.section_id is distinct from old.section_id and new.section_id is not null then
    perform public.run_rules(new.id, 'section_changed');
  end if;
  if new.status = 'done' and old.status <> 'done' then
    perform public.run_rules(new.id, 'completed');
  end if;
  if new.assignee_id is distinct from old.assignee_id and new.assignee_id is not null then
    perform public.run_rules(new.id, 'assigned');
  end if;
  if new.due_date is distinct from old.due_date then
    perform public.run_rules(new.id, 'due_changed');
  end if;
  return null;
end $$;

create or replace function public.rules_on_field_value()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if tg_op = 'INSERT' or new.value is distinct from old.value then
    perform public.run_rules(new.task_id, 'field_changed', jsonb_build_object('field_id', new.field_id));
  end if;
  return null;
end $$;

drop trigger if exists rules_on_task_insert on public.tasks;
create trigger rules_on_task_insert after insert on public.tasks
  for each row execute function public.rules_on_task_insert();
drop trigger if exists rules_on_task_update on public.tasks;
create trigger rules_on_task_update after update of section_id, status, assignee_id, due_date on public.tasks
  for each row execute function public.rules_on_task_update();
drop trigger if exists rules_on_field_value on public.task_field_values;
create trigger rules_on_field_value after insert or update on public.task_field_values
  for each row execute function public.rules_on_field_value();

-- Built in: subtasks go with their main task's assignee
create or replace function public.subtask_takes_parent_assignee()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.parent_id is not null and new.assignee_id is null
     and coalesce(current_setting('atlas.importing', true), '') <> 'on' then
    new.assignee_id := (select assignee_id from public.tasks where id = new.parent_id);
  end if;
  return new;
end $$;

-- Named to run before check_task_assignee_access (triggers run in name order)
drop trigger if exists assign_subtask_from_parent on public.tasks;
create trigger assign_subtask_from_parent before insert on public.tasks
  for each row execute function public.subtask_takes_parent_assignee();

create or replace function public.subtasks_follow_parent()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.parent_id is null and new.assignee_id is distinct from old.assignee_id
     and coalesce(current_setting('atlas.importing', true), '') <> 'on' then
    update public.tasks set assignee_id = new.assignee_id
    where parent_id = new.id and status <> 'done' and (assignee_id is null or assignee_id = old.assignee_id);
  end if;
  return null;
end $$;

drop trigger if exists subtasks_follow_parent on public.tasks;
create trigger subtasks_follow_parent after update of assignee_id on public.tasks
  for each row execute function public.subtasks_follow_parent();

-- Forms: same as 28, remembering the form and running the project's rules
-- once the answers are in
create or replace function public.submit_form(p_form uuid, p_title text, p_answers jsonb default '{}')
returns uuid language plpgsql security definer set search_path = public as $$
declare
  f public.forms;
  c public.campaigns;
  q jsonb;
  answer jsonb;
  label text;
  answer_text text;
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
    -- Files are attached after sending (see form_files_allowed)
    if q->>'type' = 'file' then
      continue;
    end if;
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
      answer_text := case jsonb_typeof(answer)
        when 'array' then (select string_agg(v #>> '{}', ', ') from jsonb_array_elements(answer) v)
        when 'object' then coalesce(answer->>'currency' || ' ', '') || coalesce(answer->>'amount', answer::text)
        else answer #>> '{}' end;
      if q->>'type' = 'date' then
        answer_text := to_char(answer_text::date, 'DD Mon YYYY');
      end if;
      body := body || label || ':' || E'\n' || answer_text || E'\n\n';
    end if;
  end loop;

  select name into sender from public.people where id = auth.uid();
  section := (select id from public.sections where id = f.section_id and campaign_id = c.id);

  -- Rules wait until the answers are in (run_rules at the end)
  perform set_config('atlas.no_rules', 'on', true);
  insert into public.tasks (campaign_id, section_id, title, description, assignee_id, due_date, status, position, created_by, form_id)
  values (c.id, section, left(trim(p_title), 300),
          trim(body || 'Sent by ' || coalesce(sender, 'someone') || ' through the form "' || f.name || '" on '
               || to_char(now() at time zone 'Europe/Madrid', 'DD Mon YYYY') || '.'),
          f.assignee_id, due, 'todo',
          coalesce((select max(position) from public.tasks where campaign_id = c.id and parent_id is null), 0) + 1000,
          auth.uid(), f.id)
  returning id into new_id;

  for q in select value from jsonb_array_elements(f.questions) where value->>'target' = 'field' loop
    answer := p_answers -> (q->>'key');
    if answer is not null and answer <> 'null'::jsonb and answer <> '""'::jsonb and answer <> '[]'::jsonb
       and exists (select 1 from public.custom_fields where id = (q->>'field_id')::uuid and campaign_id = c.id) then
      insert into public.task_field_values (task_id, field_id, value)
      values (new_id, (q->>'field_id')::uuid, answer)
      on conflict (task_id, field_id) do update set value = excluded.value;
    end if;
  end loop;

  if exists (select 1 from public.custom_fields where id = f.requestor_field_id and campaign_id = c.id and type = 'person') then
    insert into public.task_field_values (task_id, field_id, value)
    values (new_id, f.requestor_field_id, to_jsonb(auth.uid()::text))
    on conflict (task_id, field_id) do update set value = excluded.value;
  end if;

  perform set_config('atlas.no_rules', 'off', true);
  perform public.run_rules(new_id, 'task_added', '{}');
  return new_id;
end $$;

revoke execute on function public.submit_form(uuid, text, jsonb) from public, anon;
grant execute on function public.submit_form(uuid, text, jsonb) to authenticated;

-- Check: should say true, true, true, true
select
  exists (select 1 from information_schema.tables where table_name = 'rules') as rules_table,
  exists (select 1 from pg_proc where proname = 'run_rules') as rules_engine,
  exists (select 1 from pg_trigger where tgname = 'rules_on_field_value') as rules_triggers,
  exists (select 1 from pg_trigger where tgname = 'subtasks_follow_parent') as subtasks_follow;
