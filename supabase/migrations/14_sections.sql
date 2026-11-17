-- 14_sections.sql
-- Must-have 4: sections inside a project, like Asana's ("Pre-Onboarding",
-- "CORE", "NEW"...). A section is a named group of tasks with its own place
-- in the project's order. Tasks with no section show first.
-- Subtasks always go with their parent task, so they have no section.
-- Deleting a section keeps its tasks: they move to "No section".
-- Safe to run more than once.

create table if not exists public.sections (
  id uuid primary key default gen_random_uuid(),
  campaign_id uuid not null references public.campaigns(id) on delete cascade,
  name text not null check (length(trim(name)) > 0),
  position double precision not null default 0,
  created_by uuid default auth.uid() references public.people(id),
  created_at timestamptz not null default now()
);
create index if not exists sections_campaign_idx on public.sections (campaign_id);

alter table public.tasks
  add column if not exists section_id uuid references public.sections(id) on delete set null;
create index if not exists tasks_section_idx on public.tasks (section_id);

-- A task's section must be in the same project; subtasks have none
create or replace function public.check_task_section()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.parent_id is not null then
    new.section_id := null;
  elsif new.section_id is not null
        and not exists (select 1 from public.sections where id = new.section_id and campaign_id = new.campaign_id) then
    raise exception 'That section belongs to a different project';
  end if;
  return new;
end $$;

drop trigger if exists check_task_section on public.tasks;
create trigger check_task_section
  before insert or update of section_id, parent_id, campaign_id on public.tasks
  for each row execute function public.check_task_section();

-- Permission rules: the same as the project's tasks
revoke all on public.sections from anon;
grant select, insert, update, delete on public.sections to authenticated;
alter table public.sections enable row level security;

drop policy if exists "sections: who can see the project reads" on public.sections;
create policy "sections: who can see the project reads" on public.sections
  for select to authenticated using (public.is_active_user() and public.can_see_campaign(campaign_id));

drop policy if exists "sections: admin and members add" on public.sections;
create policy "sections: admin and members add" on public.sections
  for insert to authenticated with check (public.can_edit_work() and public.can_see_campaign(campaign_id));

drop policy if exists "sections: admin and members edit" on public.sections;
create policy "sections: admin and members edit" on public.sections
  for update to authenticated using (public.can_edit_work() and public.can_see_campaign(campaign_id))
  with check (public.can_edit_work() and public.can_see_campaign(campaign_id));

drop policy if exists "sections: admin and members delete" on public.sections;
create policy "sections: admin and members delete" on public.sections
  for delete to authenticated using (public.can_edit_work() and public.can_see_campaign(campaign_id));

-- A section can't move to another project
create or replace function public.keep_section_project()
returns trigger language plpgsql as $$
begin
  if new.campaign_id is distinct from old.campaign_id then
    raise exception 'A section can''t be moved to another project';
  end if;
  return new;
end $$;

drop trigger if exists keep_section_project on public.sections;
create trigger keep_section_project
  before update on public.sections
  for each row execute function public.keep_section_project();

-- Live updates for sections
do $$
begin
  if not exists (select 1 from pg_publication_tables
                 where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'sections') then
    alter publication supabase_realtime add table public.sections;
  end if;
end $$;

-- Check: every column should say true
select
  to_regclass('public.sections') is not null as sections_table,
  exists (select 1 from information_schema.columns
          where table_name = 'tasks' and column_name = 'section_id') as task_section_column,
  (select count(*) from pg_policies where schemaname = 'public' and tablename = 'sections') = 4 as section_rules,
  exists (select 1 from pg_trigger where tgname = 'check_task_section') as section_check;
