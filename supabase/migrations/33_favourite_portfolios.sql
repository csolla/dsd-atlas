-- 33: Favourite portfolios
--
-- Same as favourite projects (30): each person stars the portfolios they
-- use most. They show first on the Portfolios page and in the ★ menu in
-- the top bar. Only you see and change your own.
--
-- Safe to run more than once.

create table if not exists public.portfolio_favourites (
  person_id uuid not null default auth.uid() references public.people(id) on delete cascade,
  portfolio_id uuid not null references public.portfolios(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (person_id, portfolio_id)
);

alter table public.portfolio_favourites enable row level security;
revoke all on public.portfolio_favourites from anon;
grant select, insert, delete on public.portfolio_favourites to authenticated;

drop policy if exists "portfolio favourites: your own" on public.portfolio_favourites;
create policy "portfolio favourites: your own" on public.portfolio_favourites
  for select to authenticated using (person_id = auth.uid());
drop policy if exists "portfolio favourites: add your own" on public.portfolio_favourites;
create policy "portfolio favourites: add your own" on public.portfolio_favourites
  for insert to authenticated with check (person_id = auth.uid() and public.can_see_portfolio(portfolio_id));
drop policy if exists "portfolio favourites: remove your own" on public.portfolio_favourites;
create policy "portfolio favourites: remove your own" on public.portfolio_favourites
  for delete to authenticated using (person_id = auth.uid());

-- Check: should say true
select exists (select 1 from information_schema.tables where table_name = 'portfolio_favourites') as favourite_portfolios;
