-- 18_onboarding_owners.sql
-- Who does each task in the DSD Clinics Onboarding template, from the
-- November 2026 version in Asana (read from a project made from it on
-- 13 Nov 2026). People with an Atlas account are assigned; every task also
-- says "Usually done by: ..." for those who aren't in Atlas yet.
-- Assignments in a template send no notifications. Safe to run more than once.

begin;
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('JJ Gomez') or lower(name) like 'jj gomez%') order by (lower(name) = lower('JJ Gomez')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'JJ Gomez' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Designate Account Manager';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Sign the DSD Clinic contract before the client is activated';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Send Welcome email with Payment Forms and Scheduling Link to Client';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Follow up to ensure onboarding has been scheduled';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Approved - To Be Activated -> Activated As Clinic';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Activate Benefits and Offline Payment Method';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Fill out HubSpot DSD Clinic information';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Confirm Consultancies has been completed and, if it hasn''t happened yet, inform the client about its importance during the on-boarding call and follow-ups';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Add to the DSD Clinics Database. See description';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Inform PC of new activation';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Update backend with permissions, clinic fee, and effective date of fee';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Update on backend clinic to MMR DSD Clinic';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Check PC Access with Carol/PM';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Add yearly LTP products included (only if applicable!)';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'During onboarding identify point of contact in clinic';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Provide Access to DSD Online';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Build & send welcome email after ACTIVATION (without CC''s video) + HANDOVER DSD Coach???';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Create DCCP Coaching Ticket on Backend & Hubspot';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Create Whats App Concierge Group';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Update anniversary and birthday calendars';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Carlota Solla Sánchez') or lower(name) like 'carlota solla%') order by (lower(name) = lower('Carlota Solla Sánchez')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Carlota Solla Sánchez' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Clinic plaque design';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Get client assets';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Activate MKT Welcome Pack';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Create a ''Find a Clinic'' page';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Add new Clinic to ''DSD website''';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Carlota Solla Sánchez') or lower(name) like 'carlota solla%') order by (lower(name) = lower('Carlota Solla Sánchez')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Carlota Solla Sánchez' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Prep image assets';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Carlota Solla Sánchez') or lower(name) like 'carlota solla%') order by (lower(name) = lower('Carlota Solla Sánchez')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Carlota Solla Sánchez' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Design MKT Co-Branded assets';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Ricardo Serrano Majano') or lower(name) like 'ricardo serrano%') order by (lower(name) = lower('Ricardo Serrano Majano')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Ricardo Serrano Majano' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'PC Onboarding (if applicable)';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'DSD Coaching ready to start: tag Carmen/Lindi';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Lindi Rigo') or lower(name) like 'lindi rigo%') order by (lower(name) = lower('Lindi Rigo')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Lindi Rigo' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Designate DSD Coach';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Share NEW Welcome/Graduation + Anniversary Canva pack (new assets)';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Onboarding Completed - Create Consultancy ticket';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Lindi Rigo') or lower(name) like 'lindi rigo%') order by (lower(name) = lower('Lindi Rigo')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Lindi Rigo' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'DSD Consultancy booked';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Lindi Rigo') or lower(name) like 'lindi rigo%') order by (lower(name) = lower('Lindi Rigo')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Lindi Rigo' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'DSD Consultancy preparation on track';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Lindi Rigo') or lower(name) like 'lindi rigo%') order by (lower(name) = lower('Lindi Rigo')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Lindi Rigo' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'DSD Consultancy completed';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Lindi Rigo') or lower(name) like 'lindi rigo%') order by (lower(name) = lower('Lindi Rigo')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Lindi Rigo' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'DSD Coaching sessions';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'DSD Clinic Welcome Video (to add to the email)';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Lindi Rigo') or lower(name) like 'lindi rigo%') order by (lower(name) = lower('Lindi Rigo')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Lindi Rigo' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Graduation date (DSD Coaching)';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Lindi Rigo') or lower(name) like 'lindi rigo%') order by (lower(name) = lower('Lindi Rigo')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Lindi Rigo' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Create the DSD Coaching Graduation Certificates';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Lindi Rigo') or lower(name) like 'lindi rigo%') order by (lower(name) = lower('Lindi Rigo')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Lindi Rigo' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Write HubSpot summary + update properties';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Lindi Rigo') or lower(name) like 'lindi rigo%') order by (lower(name) = lower('Lindi Rigo')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Lindi Rigo' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Prepare and send the final Graduation email to the clinic';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Lindi Rigo') or lower(name) like 'lindi rigo%') order by (lower(name) = lower('Lindi Rigo')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Lindi Rigo' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Notify the DSD internal team in Rocket';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Lindi Rigo') or lower(name) like 'lindi rigo%') order by (lower(name) = lower('Lindi Rigo')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Lindi Rigo' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Send to the DSD Clinic the Coaching Feedback Form';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Lindi Rigo') or lower(name) like 'lindi rigo%') order by (lower(name) = lower('Lindi Rigo')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Lindi Rigo' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Update all internal records';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Lindi Rigo') or lower(name) like 'lindi rigo%') order by (lower(name) = lower('Lindi Rigo')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Lindi Rigo' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Add and tag them in the final Asana Coaching task ''FINAL. From ''Being Coached'' to ''Leading Your Own Growth''';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Lindi Rigo') or lower(name) like 'lindi rigo%') order by (lower(name) = lower('Lindi Rigo')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Lindi Rigo' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Update the HubSpot ticket (DSD Coaching Dashboard)';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Build & send welcome email after GRADUATION (+ CC''s video) + link with CERTIFICATES link';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Michelle Carpio') or lower(name) like 'michelle carpio%') order by (lower(name) = lower('Michelle Carpio')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Michelle Carpio' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Onboarding call: Post-Coaching AM check-in CALL';
update public.tasks set assignee_id = coalesce(assignee_id, (select id from public.people where active and role <> 'director' and (lower(name) = lower('Marita Macdonald') or lower(name) like 'marita macdonald%') order by (lower(name) = lower('Marita Macdonald')) desc limit 1)),
  description = case when coalesce(description, '') like 'Usually done by:%' then description
    else 'Usually done by: ' || 'Marita Macdonald' || coalesce(E'\n\n' || description, '') end
where campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and parent_id is null and title = 'Social Media announcement';
commit;

-- Check: who the template's tasks are for
select substring(t.description from 'Usually done by: ([^\n]*)') as usually_done_by,
       count(*) as tasks,
       count(t.assignee_id) as assigned_in_atlas,
       string_agg(distinct p.name, ', ') as atlas_person
from public.tasks t left join public.people p on p.id = t.assignee_id
where t.campaign_id = '4149a72e-28f1-5e61-bb94-9336f70724a4' and t.parent_id is null
group by 1 order by 2 desc;
