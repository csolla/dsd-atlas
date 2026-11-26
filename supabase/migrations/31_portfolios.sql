-- 31: Portfolios, like Asana's
--
-- A portfolio groups projects (and other portfolios) to follow them
-- together: each row shows the project's status, owner, dates, progress and
-- hours, plus the portfolio's own columns (portfolio_fields, the same types
-- as project fields), filled in per row (portfolio_field_values).
--
-- Who sees a portfolio: everyone, unless it's private; then its owner, its
-- members (portfolio_members) and Admins. A private project inside still
-- only shows to people who can see that project.
-- Who changes it: Admins and team members for a public portfolio; for a
-- private one, its owner, its members and Admins.
--
-- Safe to run more than once.

create table if not exists public.portfolios (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) between 1 and 200),
  description text,
  owner_id uuid references public.people(id) on delete set null,
  private boolean not null default false,
  asana_url text,
  created_by uuid default auth.uid() references public.people(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.portfolio_members (
  portfolio_id uuid not null references public.portfolios(id) on delete cascade,
  person_id uuid not null references public.people(id) on delete cascade,
  primary key (portfolio_id, person_id)
);

-- One row per project or sub-portfolio in a portfolio
create table if not exists public.portfolio_items (
  id uuid primary key default gen_random_uuid(),
  portfolio_id uuid not null references public.portfolios(id) on delete cascade,
  campaign_id uuid references public.campaigns(id) on delete cascade,
  child_portfolio_id uuid references public.portfolios(id) on delete cascade,
  position double precision not null default 0,
  created_at timestamptz not null default now(),
  constraint portfolio_item_one_kind check ((campaign_id is null) <> (child_portfolio_id is null)),
  constraint portfolio_item_not_itself check (child_portfolio_id is distinct from portfolio_id)
);
create unique index if not exists portfolio_items_project on public.portfolio_items (portfolio_id, campaign_id) where campaign_id is not null;
create unique index if not exists portfolio_items_child on public.portfolio_items (portfolio_id, child_portfolio_id) where child_portfolio_id is not null;
create index if not exists portfolio_items_campaign_idx on public.portfolio_items (campaign_id);

create table if not exists public.portfolio_fields (
  id uuid primary key default gen_random_uuid(),
  portfolio_id uuid not null references public.portfolios(id) on delete cascade,
  name text not null check (length(trim(name)) between 1 and 80),
  type text not null check (type in ('text', 'number', 'money', 'date', 'choice', 'multi', 'person')),
  settings jsonb not null default '{}',
  position double precision not null default 0,
  created_at timestamptz not null default now()
);
create index if not exists portfolio_fields_portfolio_idx on public.portfolio_fields (portfolio_id);

create table if not exists public.portfolio_field_values (
  item_id uuid not null references public.portfolio_items(id) on delete cascade,
  field_id uuid not null references public.portfolio_fields(id) on delete cascade,
  value jsonb not null,
  primary key (item_id, field_id)
);

drop trigger if exists portfolios_touch on public.portfolios;
create trigger portfolios_touch before update on public.portfolios
  for each row execute function public.touch_updated_at();

-- A field's type can't change (same as project fields)
create or replace function public.keep_portfolio_field_type()
returns trigger language plpgsql as $$
begin
  if new.type is distinct from old.type then
    raise exception 'A field''s type can''t be changed';
  end if;
  return new;
end $$;
drop trigger if exists keep_portfolio_field_type on public.portfolio_fields;
create trigger keep_portfolio_field_type before update on public.portfolio_fields
  for each row execute function public.keep_portfolio_field_type();

-- Who sees and who changes a portfolio
create or replace function public.can_see_portfolio(p_portfolio uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select public.is_active_user() and coalesce((
    select not p.private or public.is_admin() or p.owner_id = auth.uid() or p.created_by = auth.uid()
      or exists (select 1 from public.portfolio_members m where m.portfolio_id = p.id and m.person_id = auth.uid())
    from public.portfolios p where p.id = p_portfolio), false)
$$;

create or replace function public.can_edit_portfolio(p_portfolio uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select public.can_edit_work() and coalesce((
    select not p.private or public.is_admin() or p.owner_id = auth.uid() or p.created_by = auth.uid()
      or exists (select 1 from public.portfolio_members m where m.portfolio_id = p.id and m.person_id = auth.uid())
    from public.portfolios p where p.id = p_portfolio), false)
$$;

revoke execute on function public.can_see_portfolio(uuid) from public, anon;
revoke execute on function public.can_edit_portfolio(uuid) from public, anon;
grant execute on function public.can_see_portfolio(uuid) to authenticated;
grant execute on function public.can_edit_portfolio(uuid) to authenticated;

alter table public.portfolios enable row level security;
alter table public.portfolio_members enable row level security;
alter table public.portfolio_items enable row level security;
alter table public.portfolio_fields enable row level security;
alter table public.portfolio_field_values enable row level security;
revoke all on public.portfolios, public.portfolio_members, public.portfolio_items,
  public.portfolio_fields, public.portfolio_field_values from anon;
grant select, insert, update, delete on public.portfolios, public.portfolio_members, public.portfolio_items,
  public.portfolio_fields, public.portfolio_field_values to authenticated;

drop policy if exists "portfolios: who can see" on public.portfolios;
create policy "portfolios: who can see" on public.portfolios
  for select to authenticated using (public.can_see_portfolio(id));
drop policy if exists "portfolios: team members create" on public.portfolios;
create policy "portfolios: team members create" on public.portfolios
  for insert to authenticated with check (public.can_edit_work());
drop policy if exists "portfolios: editors change" on public.portfolios;
create policy "portfolios: editors change" on public.portfolios
  for update to authenticated using (public.can_edit_portfolio(id)) with check (public.can_edit_work());
drop policy if exists "portfolios: owner or admin deletes" on public.portfolios;
create policy "portfolios: owner or admin deletes" on public.portfolios
  for delete to authenticated using (public.is_admin() or owner_id = auth.uid() or created_by = auth.uid());

drop policy if exists "portfolio members: who can see" on public.portfolio_members;
create policy "portfolio members: who can see" on public.portfolio_members
  for select to authenticated using (public.can_see_portfolio(portfolio_id));
drop policy if exists "portfolio members: editors change" on public.portfolio_members;
create policy "portfolio members: editors change" on public.portfolio_members
  for all to authenticated using (public.can_edit_portfolio(portfolio_id)) with check (public.can_edit_portfolio(portfolio_id));

drop policy if exists "portfolio items: who can see" on public.portfolio_items;
create policy "portfolio items: who can see" on public.portfolio_items
  for select to authenticated using (public.can_see_portfolio(portfolio_id));
drop policy if exists "portfolio items: editors change" on public.portfolio_items;
create policy "portfolio items: editors change" on public.portfolio_items
  for all to authenticated using (public.can_edit_portfolio(portfolio_id))
  with check (public.can_edit_portfolio(portfolio_id)
    and (campaign_id is null or public.can_see_campaign(campaign_id))
    and (child_portfolio_id is null or public.can_see_portfolio(child_portfolio_id)));

drop policy if exists "portfolio fields: who can see" on public.portfolio_fields;
create policy "portfolio fields: who can see" on public.portfolio_fields
  for select to authenticated using (public.can_see_portfolio(portfolio_id));
drop policy if exists "portfolio fields: editors change" on public.portfolio_fields;
create policy "portfolio fields: editors change" on public.portfolio_fields
  for all to authenticated using (public.can_edit_portfolio(portfolio_id)) with check (public.can_edit_portfolio(portfolio_id));

drop policy if exists "portfolio values: who can see" on public.portfolio_field_values;
create policy "portfolio values: who can see" on public.portfolio_field_values
  for select to authenticated using (exists (select 1 from public.portfolio_items i where i.id = item_id and public.can_see_portfolio(i.portfolio_id)));
drop policy if exists "portfolio values: editors change" on public.portfolio_field_values;
create policy "portfolio values: editors change" on public.portfolio_field_values
  for all to authenticated
  using (exists (select 1 from public.portfolio_items i where i.id = item_id and public.can_edit_portfolio(i.portfolio_id)))
  with check (exists (select 1 from public.portfolio_items i join public.portfolio_fields f on f.portfolio_id = i.portfolio_id
                      where i.id = item_id and f.id = field_id and public.can_edit_portfolio(i.portfolio_id)));

-- Check: should say true, true
select
  exists (select 1 from information_schema.tables where table_name = 'portfolio_items') as portfolios_tables,
  exists (select 1 from pg_proc where proname = 'can_edit_portfolio') as portfolio_rules;
