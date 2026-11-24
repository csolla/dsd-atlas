-- 25: Support for the import from Asana
--
-- 1. An import file starts with  set local atlas.importing = 'on';  inside
--    its transaction. While it's on, nobody is notified about the tasks,
--    assignments and comments it adds (notify() below returns early).
-- 2. Imported projects and tasks keep a link to the Asana original
--    (asana_url), shown as "Open in Asana".
--
-- Safe to run more than once.

alter table public.campaigns add column if not exists asana_url text;
alter table public.tasks add column if not exists asana_url text;

-- Same as 16, plus the import switch
create or replace function public.notify(
  p_recipient uuid, p_type text, p_message text, p_task uuid default null, p_actor uuid default null,
  p_dedupe text default null, p_unit text default null, p_month date default null)
returns void language plpgsql security definer set search_path = public as $$
begin
  -- An import from Asana sends no notifications (see the top of this file)
  if current_setting('atlas.importing', true) = 'on' then
    return;
  end if;
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

-- Check: should say true, true, true
select
  exists (select 1 from information_schema.columns where table_name = 'campaigns' and column_name = 'asana_url') as projects_link,
  exists (select 1 from information_schema.columns where table_name = 'tasks' and column_name = 'asana_url') as tasks_link,
  position('atlas.importing' in pg_get_functiondef('public.notify(uuid, text, text, uuid, uuid, text, text, date)'::regprocedure)) > 0 as import_switch;
