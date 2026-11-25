#!/usr/bin/env python3
"""Turn one Asana project, saved as JSON, into an Atlas import file (SQL).

Asana import (must-have 8). Carlota lists the projects; Claude saves each
one from Asana into a folder, runs this script, and Carlota runs the SQL it
writes in the Supabase SQL editor.

The folder holds what the Asana connector returned:
  project.json     get_project: name, notes, permalink_url, privacy_setting,
                   owner.email, members (name, email), custom_field_settings,
                   sections
  tasks*.json      get_tasks pages for the project (every task, done or not)
  subtasks.json    optional: {"<parent gid>": [task, ...]} with the same
                   fields as tasks
  comments.json    optional: {"<task gid>": [{"created_at", "text",
                   "author_name", "author_email"}, ...]}
  attachments.json optional: {"<task gid>": [{"name", "url"}, ...]}

Everything in the project moves, open and done, whatever its age.
IDs are uuid5 of the Asana gid, so running a file twice adds nothing new.
While it runs, nobody is notified (25_asana_import_support.sql).

Usage:
  python3 tools/asana_import.py FOLDER --dept marketing --for both --out FILE.sql
  (--for: education, planning_center, delight, ..., or both; Marketing only)
"""
import argparse
import glob
import json
import os
import uuid

NS = uuid.uuid5(uuid.NAMESPACE_URL, 'dsd-atlas/asana-import')
FALLBACK_AUTHOR = 'csolla@digitalsmiledesign.com'
MONTHS = 'Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec'.split()


def uid(kind, gid):
    return str(uuid.uuid5(NS, f'{kind}:{gid}'))


def q(value):
    if value is None:
        return 'null'
    return "'" + str(value).replace("'", "''") + "'"


def person(email):
    """An active Atlas person (not a director) by work email, or null."""
    if not email:
        return 'null'
    return (f"(select id from public.people where lower(email) = lower({q(email)}) "
            f"and active and role <> 'director' limit 1)")


def day(iso):
    if not iso:
        return ''
    y, m, d = iso[:10].split('-')
    return f'{int(d)} {MONTHS[int(m) - 1]} {y}'


def load(folder, name, default):
    path = os.path.join(folder, name)
    return json.load(open(path)) if os.path.exists(path) else default


FIELD_TYPES = {'text': 'text', 'number': 'number', 'enum': 'choice', 'multi_enum': 'multi',
               'date': 'date', 'people': 'person'}


def field_type(cf):
    kind = cf.get('resource_subtype') or cf.get('type')
    if kind == 'currency' or (kind == 'number' and cf.get('currency_code')):
        return 'money'
    return FIELD_TYPES.get(kind)


def field_settings(cf, ftype):
    if ftype in ('choice', 'multi'):
        opts = [o for o in cf.get('enum_options', []) if o.get('name', '').strip()]
        settings = {'options': [o['name'].strip() for o in opts]}
        # Asana's colour names are the ones Atlas uses (CHOICE_COLORS in js/fields.js)
        colors = {o['name'].strip(): o['color'] for o in opts if o.get('color') and o['color'] != 'none'}
        if colors:
            settings['colors'] = colors
        return settings
    if ftype == 'money':
        return {'currencies': [cf.get('currency_code') or '€']}
    return {}


def field_value(c, ftype, cf):
    """(sql jsonb expression or None) for one task's value in one field."""
    if ftype == 'text' and c.get('text_value'):
        return f"to_jsonb({q(c['text_value'])}::text)"
    if ftype == 'number' and c.get('number_value') is not None:
        return f"to_jsonb({c['number_value']}::numeric)"
    if ftype == 'money' and c.get('number_value') is not None:
        cur = cf.get('currency_code') or '€'
        return q(json.dumps({'amount': c['number_value'], 'currency': cur})) + '::jsonb'
    if ftype == 'choice' and c.get('enum_value'):
        return f"to_jsonb({q(c['enum_value']['name'].strip())}::text)"
    if ftype == 'multi' and c.get('multi_enum_values'):
        names = [v['name'].strip() for v in c['multi_enum_values']]
        return q(json.dumps(names, ensure_ascii=False)) + '::jsonb'
    if ftype == 'date' and (c.get('date_value') or {}).get('date'):
        return f"to_jsonb({q(c['date_value']['date'])}::text)"
    if ftype == 'person' and c.get('people_value'):
        email = c['people_value'][0].get('email')
        return f"to_jsonb({person(email)}::text)" if email else None
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('folder')
    ap.add_argument('--dept', required=True, help='department key in Atlas, e.g. marketing')
    ap.add_argument('--for', dest='for_dept', default=None, help='department key, or "both" (Marketing only)')
    ap.add_argument('--out', required=True, help='file name; long imports become name-1.sql, name-2.sql, ...')
    ap.add_argument('--max-kb', type=int, default=300, help='largest part, so the Supabase editor copes')
    a = ap.parse_args()

    project = load(a.folder, 'project.json', None)['data']
    tasks = [t for path in sorted(glob.glob(os.path.join(a.folder, 'tasks*.json')))
             for t in json.load(open(path))['data']]
    subtasks = load(a.folder, 'subtasks.json', {})
    comments = load(a.folder, 'comments.json', {})
    attachments = load(a.folder, 'attachments.json', {})

    pgid = project['gid']
    cid = uid('project', pgid)
    fields = {}  # asana field gid -> (atlas id, type, asana field)
    for i, s in enumerate(project.get('custom_field_settings', []), 1):
        cf = s['custom_field']
        ftype = field_type(cf)
        if ftype:
            fields[cf['gid']] = (uid('field', f"{pgid}:{cf['gid']}"), ftype, cf, i * 1000)

    out = []

    # The project
    for_sql = 'null'
    if a.for_dept and a.for_dept != 'both':
        for_sql = f"public.department_id_for({q(a.for_dept)})"
    elif a.dept != 'marketing':
        for_sql = f"public.department_id_for({q(a.dept)})"
    private = project.get('privacy_setting') not in (None, 'public_to_workspace', 'public_to_domain')
    owner_email = (project.get('owner') or {}).get('email')
    out.append('-- Project')
    out.append(
        "insert into public.campaigns (id, name, description, department_id, for_department_id, status, "
        "start_date, owner_id, created_by, planned_hours, private, asana_url, created_at)\n"
        f"values ({q(cid)}, {q(project['name'])}, {q(project.get('notes') or None)}, "
        f"public.department_id_for({q(a.dept)}), {for_sql}, 'in_progress', {q(project['created_at'][:10])}, "
        f"{person(owner_email)}, {person(owner_email)}, 0, {str(private).lower()}, "
        f"{q(project.get('permalink_url'))}, {q(project['created_at'])})\n"
        "on conflict (id) do nothing;")
    if private:
        for m in project.get('members', []):
            if m.get('email'):
                out.append(
                    "insert into public.campaign_access (campaign_id, person_id)\n"
                    f"select {q(cid)}, p.id from public.people p where lower(p.email) = lower({q(m['email'])}) and p.active\n"
                    f"  and not exists (select 1 from public.campaign_access x where x.campaign_id = {q(cid)} and x.person_id = p.id);")

    out.append('\n-- Sections')
    for i, s in enumerate(project.get('sections', []), 1):
        out.append(f"insert into public.sections (id, campaign_id, name, position) values "
                   f"({q(uid('section', s['gid']))}, {q(cid)}, {q(s['name'].strip() or 'Untitled section')}, {i * 1000}) "
                   "on conflict (id) do nothing;")

    out.append('\n-- Fields')
    for gid, (fid, ftype, cf, pos) in fields.items():
        out.append(f"insert into public.custom_fields (id, campaign_id, name, type, settings, position) values "
                   f"({q(fid)}, {q(cid)}, {q(cf['name'])}, {q(ftype)}, "
                   f"{q(json.dumps(field_settings(cf, ftype), ensure_ascii=False))}::jsonb, {pos}) "
                   "on conflict (id) do nothing;")

    def task_sql(t, position, parent_gid=None):
        tid = uid('task', t['gid'])
        section = None
        if not parent_gid:
            for m in t.get('memberships', []):
                if (m.get('project') or {}).get('gid') in (pgid, None) and m.get('section'):
                    section = uid('section', m['section']['gid'])
        # Anything Atlas has no place for goes at the end of the description
        extra = []
        for c in t.get('custom_fields', []):
            if c['gid'] not in fields and c.get('display_value'):
                extra.append(f"{c.get('name') or 'Estimate'} (old Asana field): {c['display_value']}")
        if len(t.get('memberships', [])) > 1:
            extra.append('Also in other Asana projects; it lives here in Atlas.')
        if t.get('resource_subtype') == 'milestone':
            extra.append('Milestone in Asana.')
        if t.get('resource_subtype') == 'approval':
            extra.append('Approval in Asana: whoever is assigned approves or asks for changes in a comment.')
        files = attachments.get(t['gid'], [])
        if files:
            extra.append('Files in Asana:\n' + '\n'.join(f"- {f['name']}: {f.get('url') or f.get('permanent_url') or ''}" for f in files))
        description = (t.get('notes') or '').strip()
        if extra:
            description = (description + '\n\n' if description else '') + '\n'.join(extra)
        assignee = t.get('assignee') or {}
        who = person(assignee.get('email'))
        desc_sql = q(description or None)
        if assignee.get('name'):
            # Not in Atlas yet: say who it was, so it can be reassigned
            note = q(f"Asana assignee: {assignee['name']}")
            desc_sql = (f"case when {who} is null then {note} || coalesce(E'\\n\\n' || {q(description or None)}, '') "
                        f"else {q(description or None)} end")
        status = 'done' if t.get('completed') else 'todo'
        updated = t.get('completed_at') or t.get('created_at')
        return (
            "insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, "
            "due_date, status, position, asana_url, created_at, updated_at)\n"
            f"values ({q(tid)}, {q(cid)}, {q(uid('task', parent_gid)) if parent_gid else 'null'}, {q(section)}, "
            f"{q((t.get('name') or '').strip() or 'Untitled task')}, {desc_sql}, {who}, {q(t.get('due_on'))}, "
            f"{q(status)}, {position}, {q(t.get('permalink_url'))}, {q(t.get('created_at'))}, {q(updated)})\n"
            "on conflict (id) do nothing;")

    out.append('\n-- Tasks')
    for i, t in enumerate(tasks, 1):
        out.append(task_sql(t, i * 1000))
    if subtasks:
        out.append('\n-- Subtasks')
        for parent_gid, subs in subtasks.items():
            for j, s in enumerate(subs, 1):
                out.append(task_sql(s, j * 1000, parent_gid))

    out.append('\n-- Field values (main tasks only)')
    for t in tasks:
        for c in t.get('custom_fields', []):
            if c['gid'] not in fields:
                continue
            fid, ftype, cf, _ = fields[c['gid']]
            value = field_value(c, ftype, cf)
            if value:
                out.append(f"insert into public.task_field_values (task_id, field_id, value) "
                           f"select {q(uid('task', t['gid']))}, {q(fid)}, {value} "
                           f"where {value} is not null on conflict do nothing;")

    if comments:
        out.append('\n-- Comments, as text, with who wrote them and when in Asana')
        for task_gid, items in comments.items():
            for c in items:
                if not (c.get('text') or '').strip():
                    continue
                body = f"From Asana · {c.get('author_name') or 'Someone'} · {day(c.get('created_at'))}\n\n{c['text'].strip()}"[:10000]
                author = f"coalesce({person(c.get('author_email'))}, {person(FALLBACK_AUTHOR)})"
                out.append(f"insert into public.comments (id, task_id, author_id, body, created_at) values "
                           f"({q(uid('comment', c['gid']))}, {q(uid('task', task_gid))}, {author}, {q(body)}, "
                           f"{q(c.get('created_at'))}) on conflict (id) do nothing;")

    check = ['-- Check: what arrived in Atlas',
            "select c.name as project,\n"
            f"  (select count(*) from public.sections where campaign_id = {q(cid)}) as sections,\n"
            f"  (select count(*) from public.custom_fields where campaign_id = {q(cid)}) as fields,\n"
            f"  (select count(*) from public.tasks where campaign_id = {q(cid)} and parent_id is null) as tasks,\n"
            f"  (select count(*) from public.tasks where campaign_id = {q(cid)} and parent_id is not null) as subtasks,\n"
            f"  (select count(*) from public.tasks where campaign_id = {q(cid)} and status = 'done') as done,\n"
            f"  (select count(*) from public.task_field_values where campaign_id = {q(cid)}) as field_values,\n"
            f"  (select count(*) from public.comments m join public.tasks t on t.id = m.task_id where t.campaign_id = {q(cid)}) as comments\n"
            f"from public.campaigns c where c.id = {q(cid)};", '']

    # Split into parts small enough for the SQL editor. Each part is one
    # transaction with notifications off; parts run in order (tasks before
    # their subtasks, field values and comments).
    parts, current, size = [], [], 0
    for statement in out:
        if current and size + len(statement) > a.max_kb * 1024 and not statement.startswith('\n--'):
            parts.append(current)
            current, size = [], 0
        current.append(statement)
        size += len(statement)
    parts.append(current)
    base = a.out[:-4] if a.out.endswith('.sql') else a.out
    names = [a.out] if len(parts) == 1 else [f'{base}-{i}.sql' for i in range(1, len(parts) + 1)]
    for i, (name, body) in enumerate(zip(names, parts), 1):
        head = [f"-- Import from Asana: {project['name']}"
                + (f' (part {i} of {len(parts)}, run them in order)' if len(parts) > 1 else ''),
                f"-- {project.get('permalink_url', '')}",
                f"-- {len(tasks)} tasks, {sum(len(v) for v in subtasks.values())} subtasks, "
                f"{sum(len(v) for v in comments.values())} comments in all. Made by tools/asana_import.py.",
                "-- Safe to run more than once: anything already imported is left as it is.",
                '', 'begin;', "set local atlas.importing = 'on';", '']
        tail = ['', 'commit;', ''] + (check if i == len(parts) else
                                      [f'-- Next: part {i + 1} of {len(parts)}', "select 'part done' as status;"])
        open(name, 'w').write('\n'.join(head + body + tail))
    print('Wrote', ', '.join(os.path.basename(n) for n in names))
    print(f"{a.out}: {len(tasks)} tasks, {sum(len(v) for v in subtasks.values())} subtasks, "
          f"{len(fields)} fields, {sum(len(v) for v in comments.values())} comments")


if __name__ == '__main__':
    main()
