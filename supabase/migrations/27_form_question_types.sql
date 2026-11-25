-- 27: Form question types, like Asana's
--
-- Questions now have a type: text, choice (single-select), multi
-- (multi-select), date or number, with their own choices ("options") when
-- the answer goes into the description. Answers written into the
-- description read naturally: several choices as "A, B", numbers as typed.
-- Only submit_form changes (same as 26 otherwise).
--
-- Safe to run more than once.

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

  insert into public.tasks (campaign_id, section_id, title, description, assignee_id, due_date, status, position, created_by)
  values (c.id, section, left(trim(p_title), 300),
          trim(body || 'Sent by ' || coalesce(sender, 'someone') || ' through the form "' || f.name || '" on '
               || to_char(now() at time zone 'Europe/Madrid', 'DD Mon YYYY') || '.'),
          f.assignee_id, due, 'todo',
          coalesce((select max(position) from public.tasks where campaign_id = c.id and parent_id is null), 0) + 1000,
          auth.uid())
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

  return new_id;
end $$;

revoke execute on function public.submit_form(uuid, text, jsonb) from public, anon;
grant execute on function public.submit_form(uuid, text, jsonb) to authenticated;

-- Check: should say true
select position('jsonb_typeof(answer)' in pg_get_functiondef('public.submit_form(uuid, text, jsonb)'::regprocedure)) > 0 as question_types;
