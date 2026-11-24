-- 21: Personal to-dos are always assigned to their person
--
-- Every task and subtask in someone's "My to-dos" (see 20) is assigned to
-- them, however it's added (quick add, a column, the calendar, a subtask, a
-- copy). Notifications don't fire, because nobody is notified about their
-- own actions. Existing to-dos are assigned to their person too.
--
-- Safe to run more than once.

create or replace function public.assign_personal_todos()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  owner uuid;
begin
  select personal_of into owner from public.campaigns where id = new.campaign_id;
  if owner is not null then
    new.assignee_id := owner;
  end if;
  return new;
end $$;

-- Named to run before check_task_assignee_access (triggers run in name order)
drop trigger if exists assign_personal_todos on public.tasks;
create trigger assign_personal_todos
  before insert or update of assignee_id, campaign_id on public.tasks
  for each row execute function public.assign_personal_todos();

update public.tasks t set assignee_id = c.personal_of
from public.campaigns c
where c.id = t.campaign_id and c.personal_of is not null and t.assignee_id is distinct from c.personal_of;

-- Check: should say true, 0
select
  exists (select 1 from pg_trigger where tgname = 'assign_personal_todos') as has_auto_assign,
  (select count(*) from public.tasks t join public.campaigns c on c.id = t.campaign_id
   where c.personal_of is not null and t.assignee_id is distinct from c.personal_of) as todos_not_assigned;
