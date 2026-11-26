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

    ${section('search', 'Search results', 'The Search page lists matches grouped by kind; the words searched for are highlighted.', [
      'Each result is one link (<code>.search-hit</code>): a title, a muted meta line and, when the match is in longer text, a short snippet.',
      'Matches use <code>&lt;mark&gt;</code>: a soft yellow fill plus an underline and bolder text, so the highlight never relies on colour alone.',
      'While typing in the top bar, a suggestion list (<code>.search-suggest</code>) shows matching projects and tasks under small group labels, ending with "Search everything". The picked row gets a fill and an accent bar.',
    ], `
      <div class="ds-gap" style="position: relative; min-height: 210px;">
        <ul class="search-suggest" role="listbox" aria-label="Example suggestions" style="left: 0; right: auto;">
          <li class="suggest-group" role="presentation">Projects</li>
          <li role="option" aria-selected="true"><span class="suggest-title"><mark>Onb</mark>oarding template</span></li>
          <li class="suggest-group" role="presentation">Tasks</li>
          <li role="option" aria-selected="false"><span class="suggest-title">Send <mark>onb</mark>oarding pack</span><span class="suggest-meta">Onboarding template</span></li>
          <li role="option" aria-selected="false"><span class="suggest-all">Search everything for “onb”</span></li>
        </ul>
      </div>
      <ul class="search-hits">
        <li><a class="search-hit" href="#/design-system">
          <span class="search-hit-title">DSD Clinics <mark>Onboard</mark>ing</span>
          <span class="search-hit-meta"><span class="tag tag-other">Delight</span> <span class="status status-in_progress">In progress</span></span>
          <span class="search-hit-snippet">Full <mark>onboard</mark>ing for the clinic, from contract to first patient.</span></a></li>
        <li><a class="search-hit" href="#/design-system">
          <span class="search-hit-title">Send <mark>onboard</mark>ing pack</span>
          <span class="search-hit-meta"><strong>DSD Clinics Onboarding</strong> · To do · Ana</span></a></li>
      </ul>`)}

    ${section('templates', 'Templates', 'Ready-made projects people copy. Marked wherever they appear, so nobody works in one by mistake.', [
      'A <code>.template-flag</code> label next to the name in lists and search.',
      'On the template itself, a <code>.template-note</code> banner explains what it is and offers <strong>Use this template</strong>.',
    ], `
      <p class="ds-gap"><strong>DSD Clinics Onboarding</strong> <span class="template-flag">Template</span></p>
      <div class="template-note"><p><strong>Template.</strong> Set up its sections, tasks, subtasks and fields here. Nobody works in it.</p>
        <button class="btn btn-primary btn-small" type="button">Use this template</button></div>`)}

    ${section('custom-fields', 'Custom fields', 'A project\'s own fields: managed in the Fields dialog, filled in the task panel, shown as List columns.', [
      'In the Fields dialog, each field is a row (<code>.field-list</code>) with its type, ↑ ↓, Edit and Delete; ready-made sets are cards (<code>.field-set</code>) with an Add button.',
      'In the task panel, fields sit in a two-column grid (<code>.custom-fields-grid</code>); text and several-choice fields take the full width. Money pairs a currency box with the amount (<code>.money-input</code>).',
      'In the List, editors fill fields right in their cells (<code>.field-cell</code>): compact inputs, and several-choice fields open a small tick-box list (<code>.multi-cell</code>). Directors see plain values; numbers and money right-aligned, empty values as a dash.',
      'On cards, filled-in fields are outlined tags (<code>.card-field</code>) under the title, showing only the value; the field name shows when you hover the tag. At most four, then “+N more”.',
    ], `
      <ul class="field-list">
        <li><span class="field-list-name"><strong>Total amount</strong><span class="muted small">Money · €, US$, GBP</span></span>
          <button class="icon-btn" type="button" disabled aria-label="Move up">↑</button><button class="icon-btn" type="button" aria-label="Move down">↓</button>
          <button class="btn btn-ghost btn-small" type="button">Edit</button><button class="btn btn-ghost btn-small" type="button">Delete</button></li>
        <li><span class="field-list-name"><strong>Finance payment</strong><span class="muted small">Choice (pick one) · 3 choices</span></span>
          <button class="icon-btn" type="button" aria-label="Move up">↑</button><button class="icon-btn" type="button" disabled aria-label="Move down">↓</button>
          <button class="btn btn-ghost btn-small" type="button">Edit</button><button class="btn btn-ghost btn-small" type="button">Delete</button></li>
      </ul>
      <div class="task-card-fields ds-gap"><span class="card-field">Done</span><span class="card-field">Wire transfer</span><span class="card-field" title="Total amount: € 550.55">€ 550.55</span><span class="card-field card-field-more">+3 more</span></div>
      <div class="field-set"><div><strong>Invoices</strong><span class="muted small">Amount, invoice date and number, payment and accounting codes.</span></div><button class="btn btn-small" type="button">Add</button></div>
      <div class="custom-fields-grid ds-gap">
        <div class="field"><span>Total amount</span><div class="money-input"><select aria-label="Currency"><option>€</option><option>US$</option></select><input type="number" value="8610.01" aria-label="Total amount"></div></div>
        <div class="field"><span>Finance payment</span><select aria-label="Finance payment"><option>Pending</option><option selected>Done</option></select></div>
        <div class="field field-wide"><span>P&amp;L account</span><div class="multi-choice" role="group" aria-label="P&amp;L account">
          <label class="multi-choice-item"><input type="checkbox" checked> 201.4 - COGS Lab</label><label class="multi-choice-item"><input type="checkbox"> Labour</label></div></div>
      </div>`)}

    ${section('task-sections', 'Task sections', 'Group a project\'s tasks into phases in the List view.', [
      'A header row per section (<code>.task-section-row</code>) with its name, task count and, for editors, ↑ ↓, Rename and Delete.',
      'Each section ends with its own <strong>+ Add task</strong>; an empty section says so.',
      'A <code>.section-toggle</code> ▾ before the name closes a section (<code>tbody.is-closed</code> keeps only its header row); <code>.section-fold-all</code> holds Collapse all / Expand all above the table.',
      'In a template, the role of a task shows as a <code>.tag.role-tag</code> next to its assignee; the New project form asks who plays each role in a <code>.template-roles</code> box.',
      'Field choices show as a <code>.choice-pill</code> with their name, coloured by <code>.choice-&lt;colour&gt;</code> (Asana\'s colour names: red, orange, yellow-orange, yellow, yellow-green, green, blue-green, aqua, blue, indigo, purple, magenta, hot-pink, pink, cool-gray; tokens <code>--choice-*-bg / -fg</code>, at least 4.5:1 in both themes). A choice dropdown takes its current choice\'s colour (<code>select.choice-select</code>).',
      'The task panel lists a task\'s details as <code>.prop-row</code>s (a muted <code>.prop-label</code> and a borderless <code>.prop-value</code> that shows its border on hover), under a <code>.complete-btn</code> (✓ Mark complete, green and pressed when done).',
      'Forms: the editor lists questions as <code>.form-question</code> boxes (wording, help, where the answer goes, required); people fill a form in a <code>.form-page</code> card, with <code>.required-mark</code> asterisks and <code>.form-actions</code>.',
      'Rules: the editor has three <code>.rule-part</code> boxes (When, Only if, Then), each line a <code>.rule-row</code> with its type and details.',
      'Favourites: a <code>.star-btn</code> (☆ / ★ in <code>--signal-ink</code>, with aria-pressed) before a project\'s name, and the <code>.fav-menu</code> ★ in the top bar.',
      'Portfolios reuse the Projects page parts (<code>.projects-head</code>, <code>.campaign-table</code> in a <code>.list-scroll</code>); a sub-portfolio row has a ▤ <code>.portfolio-mark</code> and a Portfolio tag. Pickers of projects or people are a <code>.pick-list</code> of tick boxes with a search box.',
      'Once the project has a number or money field, each section with tasks gets a <code>.task-section-total</code> row (and a <code>.is-grand</code> one for all sections). Money totals are per currency, one <code>.total-line</code> each, never converted.',
      'A project page starts with a one-line <code>.project-head</code>: a <code>.crumb</code> back to Projects, the name, status, owner, hours and progress, then Details, Edit and a <code>.more-menu</code> (⋯, a <code>&lt;details&gt;</code> holding a <code>.menu</code>) for rarer actions. Department, dates and the description open under Details. The toolbar below starts with the view switch and <strong>+ Add task</strong> (which opens the <code>.quick-add-bar</code>); Collapse all / Expand all are <code>.icon-only</code> buttons with a label for screen readers and a tooltip.',
      'Projects have four views in one <code>.view-switch</code>: List, Kanban (status columns), Board (section columns) and Calendar (<code>.cal</code>: a month grid, each task as a <code>.cal-task</code> on its due date; late tasks say "Late" as well as turning red; on phones it becomes a list of the days that have tasks). On the Board, each card shows its status as a <code>.card-status</code> label.',
    ], `
      <div class="ds-gap project-head"><div class="head-line"><div class="head-title"><a class="crumb" href="#/campaigns">Projects</a><span class="crumb-sep" aria-hidden="true">›</span><h1>Spring newsletter</h1><span class="status status-in_progress">In progress</span></div>
        <div class="actions head-actions"><button class="btn btn-ghost btn-small" type="button">Details</button><button class="btn btn-small" type="button">Edit</button>
        <details class="more-menu"><summary class="btn btn-ghost btn-small" aria-label="More project actions">⋯</summary><div class="menu"><button class="menu-item" type="button">Save as template</button><button class="menu-item" type="button">Archive</button></div></details></div></div></div>
      <p class="ds-gap"><span class="view-switch" role="group" aria-label="View"><button type="button" aria-pressed="true">List</button><button type="button">Kanban</button><button type="button">Board</button><button type="button">Calendar</button></span></p>
      <p class="ds-gap" style="max-width:260px"><span class="cal-task"><span class="cal-task-title">Newsletter #48</span></span> <span class="cal-task is-late"><span class="cal-late">Late</span><span class="cal-task-title">Pay Aurion invoice</span></span> <span class="cal-task is-done"><span class="cal-task-title">Book venue</span></span></p>
      <p class="ds-gap"><span class="card-status">In progress</span> <span class="card-status card-status-done">Done</span></p>
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
