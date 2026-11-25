#!/usr/bin/env python3
"""Save one Asana project as JSON, ready for tools/asana_import.py.

Reads everything in the project, open and done, whatever its age: the
project, its sections and custom fields, every task, every subtask, the
comments on each and the names and links of their files.

The Asana personal access token is read from ~/.asana_token (Carlota made
it for the import; delete it in Asana after go-live). It is never printed
and never written anywhere else.

Usage:
  python3 tools/asana_fetch.py PROJECT_GID FOLDER
"""
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor

API = 'https://app.asana.com/api/1.0'
TOKEN = open(os.path.expanduser('~/.asana_token')).read().strip()

TASK_FIELDS = ','.join([
    'name', 'notes', 'completed', 'completed_at', 'created_at', 'due_on', 'start_on',
    'assignee.name', 'assignee.email', 'memberships.project.gid', 'memberships.section.gid',
    'custom_fields.gid', 'custom_fields.name', 'custom_fields.display_value', 'custom_fields.number_value',
    'custom_fields.text_value', 'custom_fields.enum_value.name', 'custom_fields.multi_enum_values.name',
    'custom_fields.date_value.date', 'custom_fields.people_value.email',
    'num_subtasks', 'permalink_url', 'resource_subtype'])


def get(path, params=None):
    """One Asana API call, retrying politely when Asana asks us to wait."""
    url = f'{API}{path}?{urllib.parse.urlencode(params or {})}'
    for attempt in range(6):
        req = urllib.request.Request(url, headers={'Authorization': f'Bearer {TOKEN}'})
        try:
            with urllib.request.urlopen(req, timeout=60) as r:
                return json.load(r)
        except urllib.error.HTTPError as e:
            if e.code == 429 or e.code >= 500:
                time.sleep(int(e.headers.get('Retry-After', 5)) + attempt)
                continue
            raise SystemExit(f'Asana said {e.code} for {path}: {e.read().decode()[:300]}')
    raise SystemExit(f'Asana kept refusing {path}')


def get_all(path, params):
    """Every page of a list."""
    items, offset = [], None
    while True:
        page = get(path, {**params, 'limit': 100, **({'offset': offset} if offset else {})})
        items += page['data']
        offset = (page.get('next_page') or {}).get('offset')
        if not offset:
            return items


def comments_of(gid):
    stories = get_all(f'/tasks/{gid}/stories', {'opt_fields': 'type,text,created_at,created_by.name,created_by.email'})
    return [{'gid': s['gid'], 'created_at': s['created_at'], 'text': s.get('text') or '',
             'author_name': (s.get('created_by') or {}).get('name'),
             'author_email': (s.get('created_by') or {}).get('email')}
            for s in stories if s.get('type') == 'comment']


def files_of(gid):
    files = get_all('/attachments', {'parent': gid, 'opt_fields': 'name,permanent_url,view_url'})
    return [{'name': f.get('name') or 'File', 'url': f.get('permanent_url') or f.get('view_url')} for f in files]


def main():
    pgid, folder = sys.argv[1], sys.argv[2]
    os.makedirs(folder, exist_ok=True)
    project = get(f'/projects/{pgid}', {'opt_fields': ','.join([
        'name', 'notes', 'created_at', 'permalink_url', 'privacy_setting', 'owner.name', 'owner.email',
        'members.name', 'members.email', 'custom_field_settings.custom_field.name',
        'custom_field_settings.custom_field.type', 'custom_field_settings.custom_field.resource_subtype',
        'custom_field_settings.custom_field.enum_options.name', 'custom_field_settings.custom_field.currency_code',
        'custom_field_settings.custom_field.precision'])})['data']
    project['sections'] = get_all(f'/projects/{pgid}/sections', {'opt_fields': 'name'})
    json.dump({'data': project}, open(os.path.join(folder, 'project.json'), 'w'), ensure_ascii=False)
    print(f"{project['name']}: {len(project['sections'])} sections")

    tasks = get_all(f'/projects/{pgid}/tasks', {'opt_fields': TASK_FIELDS})
    json.dump({'data': tasks}, open(os.path.join(folder, 'tasks.json'), 'w'), ensure_ascii=False)
    print(f'{len(tasks)} tasks ({sum(t["completed"] for t in tasks)} done)')

    with ThreadPoolExecutor(max_workers=4) as pool:
        parents = [t for t in tasks if t.get('num_subtasks')]
        subs = dict(zip([t['gid'] for t in parents],
                        pool.map(lambda t: get_all(f'/tasks/{t["gid"]}/subtasks', {'opt_fields': TASK_FIELDS}), parents)))
        json.dump(subs, open(os.path.join(folder, 'subtasks.json'), 'w'), ensure_ascii=False)
        print(f'{sum(len(v) for v in subs.values())} subtasks')

        everything = [t['gid'] for t in tasks] + [s['gid'] for v in subs.values() for s in v]
        comments = {g: c for g, c in zip(everything, pool.map(comments_of, everything)) if c}
        json.dump(comments, open(os.path.join(folder, 'comments.json'), 'w'), ensure_ascii=False)
        print(f'{sum(len(v) for v in comments.values())} comments on {len(comments)} tasks')

        files = {g: f for g, f in zip(everything, pool.map(files_of, everything)) if f}
        json.dump(files, open(os.path.join(folder, 'attachments.json'), 'w'), ensure_ascii=False)
        print(f'{sum(len(v) for v in files.values())} files on {len(files)} tasks')


if __name__ == '__main__':
    main()
