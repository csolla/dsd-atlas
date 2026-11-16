-- 13_private_projects.sql
-- Must-have 7: projects only some people can see (Job Scorecards, finance,
-- HR). A private project is seen only by:
--   * the people and departments added to it (campaign_access),
--   * its owner and whoever created it,
--   * every Admin.
-- Everyone else can't see the project, its tasks, comments or files, even
-- with a link. Its hours still count in Marketing's budget totals, without
-- the project's name.
-- Safe to run more than once.

alter table public.campaigns
  add column if not exists private boolean not null default false;

-- Who is added to a private project: one person or one department per row
create table if not exists public.campaign_access (
  id uuid primary key default gen_random_uuid(),
  campaign_id uuid not null references public.campaigns(id) on delete cascade,
  person_id uuid references public.people(id) on delete cascade,
  department_id uuid references public.departments(id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint access_person_or_department check ((person_id is null) <> (department_id is null)),
  unique (campaign_id, person_id),
  unique (campaign_id, department_id)
);
create index if not exists campaign_access_campaign_idx on public.campaign_access (campaign_id);

-- ---------------------------------------------------------------------------
-- Who can see what. security definer so the checks don't loop back
-- through the permission rules they are part of.
-- ---------------------------------------------------------------------------
create or replace function public.person_can_see_campaign(p_person uuid, p_campaign uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((
    select not c.private
        or pe.role = 'admin'
        or c.owner_id = pe.id
        or c.created_by = pe.id
        or exists (select 1 from public.campaign_access a
                   where a.campaign_id = c.id
                     and (a.person_id = pe.id or (pe.department_id is not null and a.department_id = pe.department_id)))
    from public.campaigns c
    join public.people pe on pe.id = p_person and pe.active
    where c.id = p_campaign), false)
$$;

create or replace function public.can_see_campaign(p_campaign uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select public.person_can_see_campaign(auth.uid(), p_campaign)
$$;

create or replace function public.can_see_task(p_task uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((select public.can_see_campaign(campaign_id) from public.tasks where id = p_task), false)
$$;

-- Files are stored under "<task id>/..."
create or replace function public.can_see_task_folder(p_folder text)
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((select public.can_see_campaign(campaign_id) from public.tasks where id::text = p_folder), false)
$$;

revoke execute on function public.person_can_see_campaign(uuid, uuid) from public, anon, authenticated;
revoke execute on function public.can_see_campaign(uuid) from public, anon;
revoke execute on function public.can_see_task(uuid) from public, anon;
revoke execute on function public.can_see_task_folder(text) from public, anon;
grant execute on function public.can_see_campaign(uuid), public.can_see_task(uuid), public.can_see_task_folder(text) to authenticated;

-- ---------------------------------------------------------------------------
-- Permission rules: the same as before, plus "can see the project"
-- ---------------------------------------------------------------------------
-- Checked on the row itself (not by looking the project up), so a project
-- can be read back in the same step that creates it
create or replace function public.has_project_access(p_campaign uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.campaign_access a
                 join public.people pe on pe.id = auth.uid()
                 where a.campaign_id = p_campaign
                   and (a.person_id = pe.id or (pe.department_id is not null and a.department_id = pe.department_id)))
$$;
revoke execute on function public.has_project_access(uuid) from public, anon;
grant execute on function public.has_project_access(uuid) to authenticated;

drop policy if exists "campaigns: active users read" on public.campaigns;
create policy "campaigns: active users read" on public.campaigns
  for select to authenticated using (public.is_active_user() and (
    not private or public.is_admin() or auth.uid() in (owner_id, created_by) or public.has_project_access(id)));

drop policy if exists "campaigns: admin and members edit" on public.campaigns;
create policy "campaigns: admin and members edit" on public.campaigns
  for update to authenticated using (public.can_edit_work() and (
    not private or public.is_admin() or auth.uid() in (owner_id, created_by) or public.has_project_access(id)))
  with check (public.can_edit_work());

drop policy if exists "campaigns: admin deletes" on public.campaigns;
create policy "campaigns: admin deletes" on public.campaigns
  for delete to authenticated using (public.is_admin());

drop policy if exists "tasks: active users read" on public.tasks;
create policy "tasks: active users read" on public.tasks
  for select to authenticated using (public.is_active_user() and public.can_see_campaign(campaign_id));

drop policy if exists "tasks: admin and members create" on public.tasks;
create policy "tasks: admin and members create" on public.tasks
  for insert to authenticated with check (public.can_edit_work() and public.can_see_campaign(campaign_id));

drop policy if exists "tasks: admin and members edit" on public.tasks;
create policy "tasks: admin and members edit" on public.tasks
  for update to authenticated using (public.can_edit_work() and public.can_see_campaign(campaign_id))
  with check (public.can_edit_work() and public.can_see_campaign(campaign_id));

drop policy if exists "tasks: admin and members delete" on public.tasks;
create policy "tasks: admin and members delete" on public.tasks
  for delete to authenticated using (public.can_edit_work() and public.can_see_campaign(campaign_id));

drop policy if exists "comments: active users read" on public.comments;
create policy "comments: active users read" on public.comments
  for select to authenticated using (public.is_active_user() and public.can_see_task(task_id));

drop policy if exists "comments: admin and members write" on public.comments;
create policy "comments: admin and members write" on public.comments
  for insert to authenticated with check (public.can_edit_work() and author_id = auth.uid() and public.can_see_task(task_id));

drop policy if exists "attachments: active users read" on public.attachments;
create policy "attachments: active users read" on public.attachments
  for select to authenticated using (public.is_active_user() and public.can_see_task(task_id));

drop policy if exists "attachments: admin and members add" on public.attachments;
create policy "attachments: admin and members add" on public.attachments
  for insert to authenticated with check (public.can_edit_work() and uploaded_by = auth.uid() and public.can_see_task(task_id));

drop policy if exists "attachment files: read" on storage.objects;
create policy "attachment files: read" on storage.objects
  for select to authenticated
  using (bucket_id = 'attachments' and public.is_active_user() and public.can_see_task_folder((storage.foldername(name))[1]));

drop policy if exists "attachment files: upload" on storage.objects;
create policy "attachment files: upload" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'attachments' and public.can_edit_work() and public.can_see_task_folder((storage.foldername(name))[1]));

-- Who's added: visible to anyone who can see the project; changed by the
-- project's owner, its creator or an Admin
revoke all on public.campaign_access from anon;
grant select, insert, delete on public.campaign_access to authenticated;
alter table public.campaign_access enable row level security;

create or replace function public.can_manage_access(p_campaign uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select public.is_admin() or (public.can_edit_work() and exists (
    select 1 from public.campaigns where id = p_campaign and auth.uid() in (owner_id, created_by)))
$$;
revoke execute on function public.can_manage_access(uuid) from public, anon;
grant execute on function public.can_manage_access(uuid) to authenticated;

drop policy if exists "project access: who can see the project reads" on public.campaign_access;
create policy "project access: who can see the project reads" on public.campaign_access
  for select to authenticated using (public.is_active_user() and public.can_see_campaign(campaign_id));

drop policy if exists "project access: owner or admin adds" on public.campaign_access;
create policy "project access: owner or admin adds" on public.campaign_access
  for insert to authenticated with check (public.can_manage_access(campaign_id));

drop policy if exists "project access: owner or admin removes" on public.campaign_access;
create policy "project access: owner or admin removes" on public.campaign_access
  for delete to authenticated using (public.can_manage_access(campaign_id));

-- Only the owner, the creator or an Admin can make a project private or
-- public, or change its owner
create or replace function public.protect_campaign_privacy()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then
    return new;
  end if;
  if (new.private is distinct from old.private or (old.private and new.owner_id is distinct from old.owner_id))
     and not public.can_manage_access(old.id) then
    raise exception 'Only the project''s owner or an Admin can change who sees it';
  end if;
  return new;
end $$;

drop trigger if exists protect_campaign_privacy on public.campaigns;
create trigger protect_campaign_privacy
  before update on public.campaigns
  for each row execute function public.protect_campaign_privacy();

-- A task in a private project can only be assigned to someone who can see it
create or replace function public.check_task_assignee_access()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.assignee_id is not null
     and (tg_op = 'INSERT' or new.assignee_id is distinct from old.assignee_id)
     and not public.person_can_see_campaign(new.assignee_id, new.campaign_id) then
    raise exception '% can''t see this private project. Add them to it first.', public.person_name(new.assignee_id);
  end if;
  return new;
end $$;

drop trigger if exists check_task_assignee_access on public.tasks;
create trigger check_task_assignee_access
  before insert or update of assignee_id on public.tasks
  for each row execute function public.check_task_assignee_access();

-- Notifications about a task only go to people who can see it (same as 06,
-- plus that check)
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
  if p_task is not null and not exists (
    select 1 from public.tasks t where t.id = p_task and public.person_can_see_campaign(p_recipient, t.campaign_id)) then
    return;
  end if;
  insert into public.notifications (recipient_id, type, task_id, actor_id, business_unit, month, message, dedupe_key)
  values (p_recipient, p_type, p_task, p_actor, p_unit, p_month, p_message, p_dedupe)
  on conflict (recipient_id, dedupe_key) where dedupe_key is not null do nothing;
end $$;

revoke execute on function public.notify(uuid, text, text, uuid, uuid, text, text, date) from public, anon, authenticated;

-- Live updates for who's added
do $$
begin
  if not exists (select 1 from pg_publication_tables
                 where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'campaign_access') then
    alter publication supabase_realtime add table public.campaign_access;
  end if;
end $$;

-- Check: every column should say true
select
  exists (select 1 from information_schema.columns
          where table_name = 'campaigns' and column_name = 'private') as private_column,
  to_regclass('public.campaign_access') is not null as access_table,
  (select count(*) from public.campaigns where private) = 0 as nothing_private_yet,
  (select count(*) from pg_policies where schemaname = 'public' and tablename = 'campaign_access') = 3 as access_rules,
  exists (select 1 from pg_trigger where tgname = 'check_task_assignee_access') as assignee_rule;
