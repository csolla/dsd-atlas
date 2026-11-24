-- 20: Personal to-dos
--
-- Each person who works on projects gets one private project, "My to-dos",
-- that only they can see. Not even Admins can open someone else's. It's the
-- first page they see in Atlas. It's made the first time they open it
-- (my_todos() below), and can't be shared, turned into a template or deleted
-- by anyone else.
--
-- Hours logged on it count like any other project's hours; to anyone else
-- the project's name shows as "Private project".
--
-- Safe to run more than once.

alter table public.campaigns
  add column if not exists personal_of uuid references public.people(id) on delete cascade;
create unique index if not exists campaigns_one_personal_each
  on public.campaigns (personal_of) where personal_of is not null;

-- Who can see a project (same as 13, with personal to-dos first: only their
-- person). Keep in step with personCanSee() in js/access.js.
create or replace function public.person_can_see_campaign(p_person uuid, p_campaign uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((
    select case when c.personal_of is not null then c.personal_of = pe.id
      else not c.private
        or pe.role = 'admin'
        or c.owner_id = pe.id
        or c.created_by = pe.id
        or exists (select 1 from public.campaign_access a
                   where a.campaign_id = c.id
                     and (a.person_id = pe.id or (pe.department_id is not null and a.department_id = pe.department_id)))
      end
    from public.campaigns c
    join public.people pe on pe.id = p_person and pe.active
    where c.id = p_campaign), false)
$$;

drop policy if exists "campaigns: active users read" on public.campaigns;
create policy "campaigns: active users read" on public.campaigns
  for select to authenticated using (public.is_active_user() and (
    case when personal_of is not null then personal_of = auth.uid()
    else not private or public.is_admin() or auth.uid() in (owner_id, created_by) or public.has_project_access(id) end));

drop policy if exists "campaigns: admin and members edit" on public.campaigns;
create policy "campaigns: admin and members edit" on public.campaigns
  for update to authenticated using (public.can_edit_work() and (
    case when personal_of is not null then personal_of = auth.uid()
    else not private or public.is_admin() or auth.uid() in (owner_id, created_by) or public.has_project_access(id) end))
  with check (public.can_edit_work());

-- Personal to-dos are only made by my_todos()
drop policy if exists "campaigns: admin and members create" on public.campaigns;
create policy "campaigns: admin and members create" on public.campaigns
  for insert to authenticated with check (public.can_edit_work() and personal_of is null);

drop policy if exists "campaigns: admin deletes" on public.campaigns;
create policy "campaigns: admin deletes" on public.campaigns
  for delete to authenticated using (public.is_admin() and personal_of is null);

-- A personal list stays personal: private, its person's, not a template
create or replace function public.keep_personal_todos()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.personal_of is distinct from old.personal_of
     or (old.personal_of is not null and (not new.private or new.is_template or new.owner_id is distinct from old.owner_id)) then
    raise exception 'A to-do list stays personal: it can''t be shared, given to someone else or made a template';
  end if;
  return new;
end $$;

drop trigger if exists keep_personal_todos on public.campaigns;
create trigger keep_personal_todos
  before update on public.campaigns
  for each row execute function public.keep_personal_todos();

-- Nobody can be added to someone's to-dos
create or replace function public.no_access_to_personal_todos()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if exists (select 1 from public.campaigns where id = new.campaign_id and personal_of is not null) then
    raise exception 'A to-do list is personal and can''t be shared';
  end if;
  return new;
end $$;

drop trigger if exists no_access_to_personal_todos on public.campaign_access;
create trigger no_access_to_personal_todos
  before insert or update on public.campaign_access
  for each row execute function public.no_access_to_personal_todos();

-- Your "My to-dos" project, made the first time you ask for it
create or replace function public.my_todos()
returns uuid language plpgsql security definer set search_path = public as $$
declare
  me public.people;
  found uuid;
begin
  select * into me from public.people where id = auth.uid() and active;
  if me.id is null or not public.can_edit_work() then
    raise exception 'Only people who work on projects have a to-do list';
  end if;

  select id into found from public.campaigns where personal_of = me.id;
  if found is not null then
    return found;
  end if;

  insert into public.campaigns (name, description, department_id, owner_id, created_by, private, personal_of, status)
  values ('My to-dos', 'Your own list. Only you can see it.', me.department_id, me.id, me.id, true, me.id, 'in_progress')
  on conflict (personal_of) where personal_of is not null do nothing
  returning id into found;

  if found is null then
    select id into found from public.campaigns where personal_of = me.id;
  end if;
  return found;
end $$;

revoke execute on function public.my_todos() from public, anon;
grant execute on function public.my_todos() to authenticated;

-- Check: should say true, true, true
select
  exists (select 1 from information_schema.columns
          where table_schema = 'public' and table_name = 'campaigns' and column_name = 'personal_of') as has_personal_column,
  exists (select 1 from pg_proc where proname = 'my_todos') as has_my_todos,
  exists (select 1 from pg_trigger where tgname = 'keep_personal_todos') as has_protection;
