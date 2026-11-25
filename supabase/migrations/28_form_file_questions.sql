-- 28: File questions in forms
--
-- A form can ask for files. They're attached to the task the form makes,
-- like files added in its side panel. The person who sent the form may
-- attach files to that one task for 30 minutes after sending it, even
-- without access to the project; nothing else changes about who sees what.
-- submit_form (same as 27) skips file questions: the browser uploads the
-- files once the task exists, and checks required ones.
--
-- Safe to run more than once.

-- The task was just made by this person (through a form)
create or replace function public.form_files_allowed(p_task uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select public.is_active_user() and exists (
    select 1 from public.tasks t
    where t.id = p_task and t.created_by = auth.uid() and t.created_at > now() - interval '30 minutes')
$$;

create or replace function public.form_files_allowed_folder(p_folder text)
returns boolean language plpgsql stable security definer set search_path = public as $$
begin
  return public.form_files_allowed(p_folder::uuid);
exception when others then
  return false;
end $$;

revoke execute on function public.form_files_allowed(uuid) from public, anon;
revoke execute on function public.form_files_allowed_folder(text) from public, anon;
grant execute on function public.form_files_allowed(uuid) to authenticated;
grant execute on function public.form_files_allowed_folder(text) to authenticated;

-- Same as 13, plus the form sender's files
drop policy if exists "attachments: admin and members add" on public.attachments;
create policy "attachments: admin and members add" on public.attachments
  for insert to authenticated with check (uploaded_by = auth.uid() and kind = 'file' and public.form_files_allowed(task_id)
    or public.can_edit_work() and uploaded_by = auth.uid() and public.can_see_task(task_id));

drop policy if exists "attachment files: upload" on storage.objects;
create policy "attachment files: upload" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'attachments' and (
    public.can_edit_work() and public.can_see_task_folder((storage.foldername(name))[1])
    or public.form_files_allowed_folder((storage.foldername(name))[1])));

-- Same as 27, skipping file questions
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

-- Check: should say true, true
select
  exists (select 1 from pg_proc where proname = 'form_files_allowed') as files_allowed,
  position('form_files_allowed' in pg_get_functiondef('public.submit_form(uuid, text, jsonb)'::regprocedure)) > 0 as submit_skips_files;
