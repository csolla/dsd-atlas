-- 19_template_owners_by_email.sql
-- Assigns template tasks to the person named in their "Usually done by: ..."
-- line, matched by work email (names differ between Asana and Atlas, e.g.
-- "Carlota Solla Sánchez" in Asana is "Carlota" in Atlas). Only people who
-- already have an Atlas account are assigned; tasks that already have an
-- assignee are left alone. Assignments in a template send no notifications.
-- Run it again whenever more people join Atlas.
-- Safe to run more than once.

with owners(asana_name, email) as (values
  ('Carlota Solla Sánchez', 'csolla@digitalsmiledesign.com'),
  ('Michelle Carpio', 'mcarpio@digitalsmiledesign.com'),
  ('Lindi Rigo', 'lindi@digitalsmiledesign.com'),
  ('Marita Macdonald', 'mmacdonald@digitalsmiledesign.com'),
  ('JJ Gomez', 'jj@digitalsmiledesign.com'),
  ('Ricardo Serrano Majano', 'rserrano@digitalsmiledesign.com'),
  ('Elisa Bedin', 'ebedin@digitalsmiledesign.com'),
  ('Valeria Evangelista', 'vevangelista@digitalsmiledesign.com'),
  ('John Coachman', 'john@digitalsmiledesign.com'),
  ('Daisy Mason', 'dmason@digitalsmiledesign.com'),
  ('Stephanie Wrennall', 'swrennall@digitalsmiledesign.com'),
  ('Ángel L. Sánchez Caleya', 'angel@digitalsmiledesign.com'),
  ('Elisabet López San Juan', 'elopez@digitalsmiledesign.com')
),
matches as (
  select t.id as task_id, p.id as person_id
  from public.tasks t
  join public.campaigns c on c.id = t.campaign_id and c.is_template
  join owners o on split_part(t.description, E'\n', 1) = 'Usually done by: ' || o.asana_name
  join public.people p on lower(p.email) = lower(o.email) and p.active and p.role <> 'director'
  where t.assignee_id is null
)
update public.tasks t set assignee_id = m.person_id
from matches m where t.id = m.task_id;

-- Check: per template and person, how many tasks are assigned in Atlas
select c.name as template,
       substring(t.description from 'Usually done by: ([^\n]*)') as usually_done_by,
       count(*) as tasks,
       count(t.assignee_id) as assigned_in_atlas,
       string_agg(distinct p.name, ', ') as atlas_person
from public.tasks t
join public.campaigns c on c.id = t.campaign_id and c.is_template
left join public.people p on p.id = t.assignee_id
where t.description like 'Usually done by:%'
group by 1, 2 order by 1, 3 desc;
