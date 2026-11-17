import { state } from '../state.js';
import { esc, avatar, statusPill, toast, formDialog, confirmDialog } from '../ui.js';
import { departmentByKey, forTag } from '../departments.js';

// Design system (Admin, from the menu under your photo): the reference for how the tool looks.
// Everything shown is the real thing (same classes and tokens the app uses),
// so this page is also a quick visual check after any style change.

const TOKENS = [
  { group: 'Surfaces', items: [
    ['--bg', 'App background'], ['--surface', 'Cards, panels, dialogs'], ['--surface-2', 'Table headers, hover, quiet fills'],
    ['--border', 'Hairlines and outlines'],
  ] },
  { group: 'Text', items: [
    ['--text', 'Headings and emphasis'], ['--text-body', 'Running text'], ['--muted', 'Secondary text, labels'],
  ] },
  { group: 'Accent and signal', items: [
    ['--accent', 'Buttons and links'], ['--accent-bright', 'Focus rings, selected states'], ['--accent-soft', 'Selected backgrounds'],
    ['--signal', 'Attention highlights'], ['--danger', 'Destructive actions, errors'], ['--success', 'Confirmations'],
  ] },
  { group: 'Marketing budgets (who a project is for)', items: [
    ['--edu', 'Education'], ['--pc', 'Planning Center'], ['--shared', 'Education + Planning Center'],
  ] },
  { group: 'Charts (validated for colour blindness)', items: [
    ['--series-edu', 'Education series'], ['--series-pc', 'Planning Center series'], ['--series-internal', 'Internal'],
    ['--status-good', 'Within budget'], ['--status-warning', 'Over 80%'], ['--status-critical', 'Budget reached'],
  ] },
];

// A sample "For" tag: Marketing campaigns for Education, Planning Center or
// both, and a Delight campaign for its own department
function example(budget) {
  const key = { education: 'education', planning_center: 'planning_center', other: 'delight' }[budget];
  const dept = departmentByKey(key)?.id;
  return forTag({ budget, department_id: dept, for_department_id: budget === 'shared' ? null : dept });
}

function section(id, title, description, uses, preview) {
  return `
    <section class="card ds-section" id="ds-${id}">
      <h2>${esc(title)}</h2>
      <p class="muted">${description}</p>
      <div class="ds-preview">${preview}</div>
      ${uses ? `<ul class="ds-uses">${uses.map(u => `<li>${u}</li>`).join('')}</ul>` : ''}
    </section>`;
}

export function renderDesignSystem(el) {
  const sample = state.me;
  el.innerHTML = `
    <div class="page-header"><h1>Design system</h1></div>
    <p class="muted tab-intro">How the tool looks, in one place: colours, type and every building block, shown live.
      Follow it when changing or adding anything, so the tool stays consistent. Adapted from the BM design system.</p>

    ${section('colors', 'Colours', 'Every colour is a named token. Pages use the token, never a raw colour, so light and dark mode both work.', null,
      TOKENS.map(g => `
        <h3>${esc(g.group)}</h3>
        <div class="ds-swatches">${g.items.map(([token, use]) => `
          <div class="ds-swatch"><span class="ds-chip" style="background:var(${token})"></span>
            <span><code>${token}</code><br><span class="muted small">${esc(use)}</span><br><span class="muted small" data-token="${token}"></span></span></div>`).join('')}
        </div>`).join(''))}

    ${section('typography', 'Typography', 'Inter for headings and the logo; DM Sans for everything else. Base size 15 px.', [
      'One page title (h1) per page; h2 for sections, h3 inside a section.',
      'Use <span class="muted">muted text</span> for hints and secondary facts, never for anything people must read to act.',
    ], `
      <h1>Page title (h1, Inter 26)</h1>
      <h2>Section heading (h2, Inter 17)</h2>
      <h3>Sub-heading (h3, Inter 15)</h3>
      <p>Body text in DM Sans 15. <strong>Strong text</strong> for key facts and <a href="#/design-system" onclick="return false">links</a> in the accent colour.</p>
      <p class="muted">Muted text for hints and secondary information.</p>
      <p class="small muted">Small text (13) for metadata such as dates and counts.</p>`)}

    ${section('buttons', 'Buttons', 'One primary button per area, for the main action. Others are default; destructive ones are red.', [
      '<strong>Primary:</strong> the main action of a page, form or dialog (Save, Create project).',
      '<strong>Default:</strong> secondary actions (Edit, Add row). <strong>Ghost:</strong> low-key actions (Clear, Back to automatic).',
      '<strong>Danger outline</strong> opens a confirmation; the <strong>Danger</strong> button only appears inside that confirmation.',
    ], `
      <div class="ds-row">
        <button class="btn btn-primary" type="button">Primary</button>
        <button class="btn" type="button">Default</button>
        <button class="btn btn-ghost" type="button">Ghost</button>
        <button class="btn btn-danger-outline" type="button">Delete</button>
        <button class="btn btn-danger" type="button">Delete for good</button>
        <button class="btn btn-primary" type="button" disabled>Disabled</button>
      </div>
      <div class="ds-row">
        <button class="btn btn-small" type="button">Small</button>
        <button class="btn btn-small btn-danger-outline" type="button">Small danger</button>
        <button class="icon-btn" type="button" aria-label="Close">×</button>
      </div>`)}

    ${section('forms', 'Forms', 'A label above every field; one column on phones. Errors appear under the form in red, in plain words.', [
      'Say what to type in the placeholder when the format matters (e.g. "1.5 or 1:30").',
      'Save as you leave a field in panels and tables; use a Save button in dialogs.',
    ], `
      <div class="ds-form">
        <label class="field"><span>Text field</span><input placeholder="Placeholder text"></label>
        <div class="field-row">
          <label class="field"><span>Select</span><select><option>Education</option><option>Planning Center</option></select></label>
          <label class="field"><span>Date</span><input type="date"></label>
        </div>
        <label class="field"><span>Long text</span><textarea rows="2" placeholder="Add more detail"></textarea></label>
        <label class="toggle"><input type="checkbox" checked> Checkbox with label</label>
        <p class="form-error">Error message: say what's wrong and how to fix it.</p>
        <p class="form-success">Success message: confirm what happened.</p>
      </div>`)}

    ${section('task-sections', 'Task sections', 'Group a project\'s tasks into phases in the List view.', [
      'A header row per section (<code>.task-section-row</code>) with its name, task count and, for editors, ↑ ↓, Rename and Delete.',
      'Each section ends with its own <strong>+ Add task</strong>; an empty section says so.',
    ], `
      <div class="table-wrap"><table class="table task-table">
        <tbody>
          <tr class="task-section-row"><th colspan="3"><div class="task-section-head"><h3>Pre-onboarding</h3><span class="muted">2</span><span class="spacer"></span>
            <button class="icon-btn" type="button" disabled aria-label="Move up">↑</button><button class="icon-btn" type="button" aria-label="Move down">↓</button>
            <button class="btn btn-ghost btn-small" type="button">Rename</button><button class="btn btn-ghost btn-small" type="button">Delete</button></div></th></tr>
          <tr><td>Send the welcome pack</td><td>Ana</td><td>To do</td></tr>
          <tr class="task-section-add"><td colspan="3"><span class="btn btn-ghost btn-small column-add-open">+ Add task</span></td></tr>
        </tbody>
        <tbody>
          <tr class="task-section-row"><th colspan="3"><div class="task-section-head"><h3>Graduation</h3><span class="muted">0</span></div></th></tr>
          <tr class="task-section-empty"><td colspan="3" class="muted small">No tasks in this section yet.</td></tr>
        </tbody>
      </table></div>`)}

    ${section('picks', 'Pick lists', 'Choose several items from a longer list, such as who can see a private project.', [
      'A dropdown adds one item at a time; each added item shows as a chip below it, with × to remove it. Items already added leave the dropdown.',
      'Long lists (people) are grouped in the dropdown, by department.',
      'On a page, show what was picked as plain chips with a short label (<code>.access-line</code>).',
    ], `
      <label class="field"><span>Departments</span>
        <select><option>Add a department…</option><option>Corporate</option><option>Education</option></select></label>
      <div class="pick-chips">
        <span class="filter-chip">Delight <button type="button" class="icon-btn" aria-label="Remove Delight">×</button></span>
        <span class="filter-chip">Planning Center <button type="button" class="icon-btn" aria-label="Remove Planning Center">×</button></span>
      </div>
      <div class="access-line"><span class="access-label"><span aria-hidden="true">🔒</span> Who can see it</span>
        <span class="access-group"><span class="access-label">Departments</span> <span class="summary-chip">Delight</span> <span class="summary-chip">Planning Center</span></span></div>
      <p class="ds-gap"><span class="private-flag"><span aria-hidden="true">🔒</span> Private</span></p>`)}

    ${section('tags', 'Tags, statuses and chips', 'Small labels that carry a category or state. Colour always comes with a word or an icon, never alone.', [
      '<strong>"For" tags</strong> wherever a project or entry is listed: Education, Planning Center and both in their budget colours; any other department in neutral.',
      '<strong>Status pills</strong> for project status; <strong>status chips</strong> (icon + label) for budget health.',
    ], `
      <div class="ds-row">${example('education')} ${example('planning_center')} ${example('shared')} ${example('other')} <span class="tag tag-internal">Internal</span></div>
      <div class="ds-row">${statusPill('planned')} ${statusPill('in_progress')} ${statusPill('done')} ${statusPill('on_hold')}</div>
      <div class="ds-row">
        <span class="status-chip status-good"><span aria-hidden="true">✓</span> Within budget</span>
        <span class="status-chip status-warning"><span aria-hidden="true">▲</span> Over 80%</span>
        <span class="status-chip status-critical"><span aria-hidden="true">!</span> Budget reached</span>
        <span class="filter-chip">Education only <button type="button" class="icon-btn" aria-label="Remove">×</button></span>
      </div>`)}

    ${section('toggles', 'Switches and segmented controls', 'Pick one view or period from a few options.', [
      'Use for 2–4 options that change what the page shows (Board / List, Month / Quarter).',
    ], `
      <div class="ds-row">
        <div class="view-switch" role="group" aria-label="Example"><button type="button" aria-pressed="true">Board</button><button type="button" aria-pressed="false">List</button></div>
        <span class="day-picks">${['M', 'T', 'W', 'T', 'F'].map((d, i) => `<label class="day-pick"><input type="checkbox" ${i < 4 ? 'checked' : ''}><span>${d}</span></label>`).join('')}</span>
      </div>`)}

    ${section('cards', 'Cards, tables and empty states', 'Cards group related content; tables list items; empty states say what to do next.', [
      'Tables: units in the column header, numbers right-aligned.',
      'Empty states: one sentence saying why it\'s empty and what to do.',
    ], `
      <div class="table-wrap">
        <table class="table">
          <thead><tr><th>Project</th><th>For</th><th class="num">Hours</th></tr></thead>
          <tbody>
            <tr><td><span class="row-link">Example project</span></td><td>${example('education')}</td><td class="num">12.5 h</td></tr>
            <tr><td><span class="row-link">Another project</span></td><td>${example('shared')}</td><td class="num">4 h</td></tr>
          </tbody>
        </table>
      </div>
      <div class="empty-state ds-gap"><p>No tasks yet. Type a title above and press Enter to add the first one.</p></div>`)}

    ${section('people', 'People and task cards', 'Avatars show a photo or initials; task cards follow the same pattern everywhere.', null, `
      <div class="ds-row"><span class="person">${avatar(sample, 32)}${esc(sample.name)}</span> <span class="person">${avatar({ name: 'Daisy Mason' }, 32)}Initials fallback</span></div>
      <div class="ds-card-sample">
        <article class="task-card"><p class="task-card-title">Write the launch email</p>
          <div class="task-card-meta"><span class="due overdue">3 Nov</span><span class="subcount">✓ 1/3</span><span class="spacer"></span>${avatar(sample, 24)}</div>
        </article>
      </div>`)}

    ${section('feedback', 'Dialogs and messages', 'Dialogs for short forms and confirmations; toasts for quick confirmations that disappear.', [
      'Confirm anything that deletes or can\'t be undone; say exactly what will happen.',
      'Toasts: a few words, past tense ("Project created").',
    ], `
      <div class="ds-row">
        <button class="btn" type="button" data-demo-dialog>Open a dialog</button>
        <button class="btn" type="button" data-demo-confirm>Open a confirmation</button>
        <button class="btn" type="button" data-demo-toast>Show a toast</button>
        <button class="btn" type="button" data-demo-error>Show an error toast</button>
      </div>`)}`;

  // Show the current value of each colour token (changes with light/dark mode)
  const styles = getComputedStyle(document.documentElement);
  el.querySelectorAll('[data-token]').forEach(span => { span.textContent = styles.getPropertyValue(span.dataset.token).trim(); });

  el.querySelector('[data-demo-dialog]').addEventListener('click', () => formDialog({
    title: 'Example dialog',
    body: '<label class="field"><span>Name</span><input placeholder="Type anything"></label>',
    onSubmit: () => { toast('Saved (example only)'); },
  }));
  el.querySelector('[data-demo-confirm]').addEventListener('click', () => confirmDialog({
    title: 'Delete example?', message: 'This is only an example; nothing will be deleted.', confirmLabel: 'Delete', danger: true,
  }));
  el.querySelector('[data-demo-toast]').addEventListener('click', () => toast('Project created'));
  el.querySelector('[data-demo-error]').addEventListener('click', () => toast('Could not reach the server. Try again.', 'error'));
}
