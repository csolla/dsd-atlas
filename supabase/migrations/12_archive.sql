-- 12_archive.sql
-- Must-have 3: archive old projects. An archived project keeps its status,
-- tasks and hours (dashboards still count them) but leaves the everyday
-- lists, and no new time can be logged on it. Unarchive brings it back.
-- Safe to run more than once.

alter table public.campaigns
  add column if not exists archived_at timestamptz,
  add column if not exists archived_by uuid references public.people(id);

create index if not exists campaigns_archived_idx on public.campaigns (archived_at);

-- No new time on an archived project. Existing entries can still be
-- corrected or deleted.
create or replace function public.block_time_on_archived()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.campaign_id is not null
     and (tg_op = 'INSERT' or new.campaign_id is distinct from old.campaign_id)
     and exists (select 1 from public.campaigns where id = new.campaign_id and archived_at is not null) then
    raise exception 'This project is archived. Unarchive it to log time on it.';
  end if;
  return new;
end $$;

drop trigger if exists block_time_on_archived on public.time_entries;
create trigger block_time_on_archived
  before insert or update of campaign_id on public.time_entries
  for each row execute function public.block_time_on_archived();

-- Check: every column should say true
select
  exists (select 1 from information_schema.columns
          where table_name = 'campaigns' and column_name = 'archived_at') as archived_column,
  exists (select 1 from pg_trigger where tgname = 'block_time_on_archived') as no_time_on_archived;
