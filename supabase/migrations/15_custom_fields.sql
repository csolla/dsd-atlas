-- 15_custom_fields.sql
-- Must-have 5: custom fields. Each project chooses its own fields, like
-- Asana's (for example the Invoices set: amount, currency, invoice date...).
-- A field has a type: text, number, money, date, choice, multi (several
-- choices) or person. Its choices, currencies or unit are in settings.
-- Values are stored one per task and field. Only main tasks have values;
-- subtasks go with their parent.
-- Deleting a field deletes its values. Safe to run more than once.

create table if not exists public.custom_fields (
  id uuid primary key default gen_random_uuid(),
  campaign_id uuid not null references public.campaigns(id) on delete cascade,
  name text not null check (length(trim(name)) > 0 and length(name) <= 80),
  type text not null check (type in ('text', 'number', 'money', 'date', 'choice', 'multi', 'person')),
  settings jsonb not null default '{}',
  position double precision not null default 0,
  created_by uuid default auth.uid() references public.people(id),
  created_at timestamptz not null default now()
);
create index if not exists custom_fields_campaign_idx on public.custom_fields (campaign_id);

create table if not exists public.task_field_values (
  task_id uuid not null references public.tasks(id) on delete cascade,
  field_id uuid not null references public.custom_fields(id) on delete cascade,
  campaign_id uuid not null references public.campaigns(id) on delete cascade,
  value jsonb not null,
  updated_by uuid default auth.uid() references public.people(id),
  updated_at timestamptz not null default now(),
  primary key (task_id, field_id)
);
create index if not exists task_field_values_campaign_idx on public.task_field_values (campaign_id);
create index if not exists task_field_values_field_idx on public.task_field_values (field_id);

-- A field can't move to another project, and its type can't change once
-- set (its values would no longer fit)
create or replace function public.keep_custom_field_shape()
returns trigger language plpgsql as $$
begin
  if new.campaign_id is distinct from old.campaign_id then
    raise exception 'A field can''t be moved to another project';
  end if;
  if new.type is distinct from old.type then
    raise exception 'A field''s type can''t be changed. Add a new field instead.';
  end if;
  return new;
end $$;

drop trigger if exists keep_custom_field_shape on public.custom_fields;
create trigger keep_custom_field_shape
  before update on public.custom_fields
  for each row execute function public.keep_custom_field_shape();

-- A value belongs to a main task of the field's own project. The project
-- is copied onto the value so a project's values load in one go.
create or replace function public.check_field_value()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  t record;
begin
  select campaign_id, parent_id into t from public.tasks where id = new.task_id;
  if not found then
    raise exception 'Task not found';
  end if;
  if t.parent_id is not null then
    raise exception 'Subtasks don''t have their own fields';
  end if;
  if not exists (select 1 from public.custom_fields where id = new.field_id and campaign_id = t.campaign_id) then
    raise exception 'That field belongs to a different project';
  end if;
  new.campaign_id := t.campaign_id;
  new.updated_at := now();
  new.updated_by := coalesce(auth.uid(), new.updated_by);
  return new;
end $$;

drop trigger if exists check_field_value on public.task_field_values;
create trigger check_field_value
  before insert or update on public.task_field_values
  for each row execute function public.check_field_value();

-- Permission rules: the same as the project's tasks
revoke all on public.custom_fields from anon;
revoke all on public.task_field_values from anon;
grant select, insert, update, delete on public.custom_fields to authenticated;
grant select, insert, update, delete on public.task_field_values to authenticated;
alter table public.custom_fields enable row level security;
alter table public.task_field_values enable row level security;

drop policy if exists "fields: who can see the project reads" on public.custom_fields;
create policy "fields: who can see the project reads" on public.custom_fields
  for select to authenticated using (public.is_active_user() and public.can_see_campaign(campaign_id));
drop policy if exists "fields: admin and members add" on public.custom_fields;
create policy "fields: admin and members add" on public.custom_fields
  for insert to authenticated with check (public.can_edit_work() and public.can_see_campaign(campaign_id));
drop policy if exists "fields: admin and members edit" on public.custom_fields;
create policy "fields: admin and members edit" on public.custom_fields
  for update to authenticated using (public.can_edit_work() and public.can_see_campaign(campaign_id))
  with check (public.can_edit_work() and public.can_see_campaign(campaign_id));
drop policy if exists "fields: admin and members delete" on public.custom_fields;
create policy "fields: admin and members delete" on public.custom_fields
  for delete to authenticated using (public.can_edit_work() and public.can_see_campaign(campaign_id));

drop policy if exists "field values: who can see the task reads" on public.task_field_values;
create policy "field values: who can see the task reads" on public.task_field_values
  for select to authenticated using (public.is_active_user() and public.can_see_task(task_id));
drop policy if exists "field values: admin and members add" on public.task_field_values;
create policy "field values: admin and members add" on public.task_field_values
  for insert to authenticated with check (public.can_edit_work() and public.can_see_task(task_id));
drop policy if exists "field values: admin and members edit" on public.task_field_values;
create policy "field values: admin and members edit" on public.task_field_values
  for update to authenticated using (public.can_edit_work() and public.can_see_task(task_id))
  with check (public.can_edit_work() and public.can_see_task(task_id));
drop policy if exists "field values: admin and members delete" on public.task_field_values;
create policy "field values: admin and members delete" on public.task_field_values
  for delete to authenticated using (public.can_edit_work() and public.can_see_task(task_id));

-- Live updates
do $$
begin
  if not exists (select 1 from pg_publication_tables
                 where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'custom_fields') then
    alter publication supabase_realtime add table public.custom_fields;
  end if;
  if not exists (select 1 from pg_publication_tables
                 where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'task_field_values') then
    alter publication supabase_realtime add table public.task_field_values;
  end if;
end $$;

-- Check: every column should say true
select
  to_regclass('public.custom_fields') is not null as fields_table,
  to_regclass('public.task_field_values') is not null as values_table,
  (select count(*) from pg_policies where schemaname = 'public'
     and tablename in ('custom_fields', 'task_field_values')) = 8 as field_rules,
  exists (select 1 from pg_trigger where tgname = 'check_field_value') as value_check;
