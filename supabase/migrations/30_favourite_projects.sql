-- 30: Favourite projects
--
-- Each person stars the projects they use most. Favourites show first on
-- the Projects page and in the ★ menu in the top bar. Only you see and
-- change your own; you can only star projects you can see.
--
-- Safe to run more than once.

create table if not exists public.project_favourites (
  person_id uuid not null default auth.uid() references public.people(id) on delete cascade,
  campaign_id uuid not null references public.campaigns(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (person_id, campaign_id)
);

alter table public.project_favourites enable row level security;
revoke all on public.project_favourites from anon;
grant select, insert, delete on public.project_favourites to authenticated;

drop policy if exists "favourites: your own" on public.project_favourites;
create policy "favourites: your own" on public.project_favourites
  for select to authenticated using (person_id = auth.uid());
drop policy if exists "favourites: add your own" on public.project_favourites;
create policy "favourites: add your own" on public.project_favourites
  for insert to authenticated with check (person_id = auth.uid() and public.is_active_user() and public.can_see_campaign(campaign_id));
drop policy if exists "favourites: remove your own" on public.project_favourites;
create policy "favourites: remove your own" on public.project_favourites
  for delete to authenticated using (person_id = auth.uid());

-- Check: should say true
select exists (select 1 from information_schema.tables where table_name = 'project_favourites') as favourites_table;
