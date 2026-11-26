-- 32: Fix creating a portfolio ("You don't have permission to do that")
--
-- 31 checked who sees a portfolio by looking it up by id, but while a new
-- portfolio is being created and read back, that lookup can't find it yet,
-- so creating one failed. These rules now read the portfolio's own row
-- (owner, creator, private, members). Same rules as 31 otherwise.
--
-- Safe to run more than once.

drop policy if exists "portfolios: who can see" on public.portfolios;
create policy "portfolios: who can see" on public.portfolios
  for select to authenticated using (public.is_active_user() and (
    not private or public.is_admin() or owner_id = auth.uid() or created_by = auth.uid()
    or exists (select 1 from public.portfolio_members m where m.portfolio_id = id and m.person_id = auth.uid())));

drop policy if exists "portfolios: editors change" on public.portfolios;
create policy "portfolios: editors change" on public.portfolios
  for update to authenticated using (public.can_edit_work() and (
    not private or public.is_admin() or owner_id = auth.uid() or created_by = auth.uid()
    or exists (select 1 from public.portfolio_members m where m.portfolio_id = id and m.person_id = auth.uid())))
  with check (public.can_edit_work());

-- Check: should say 2
select count(*) as fixed_rules from pg_policies
where tablename = 'portfolios' and policyname in ('portfolios: who can see', 'portfolios: editors change');
