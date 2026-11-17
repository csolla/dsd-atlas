import { esc } from '../ui.js';

// Help: how to use the tool. Everyone sees the same guide, whatever their role.

const SECTIONS = [
  {
    id: 'purpose',
    title: 'Purpose and roles',
    html: `
      <p>DSD Atlas is where every DSD department plans its projects and manages its tasks. It replaces Asana from
        14 December 2026. Marketing also logs its hours here, so directors can see how Marketing's time is spent across
        Education and Planning Center; hours for the other departments come later.</p>
      <div class="table-wrap"><table class="table">
        <thead><tr><th>Role</th><th>Who</th><th>What they can do</th></tr></thead>
        <tbody>
          <tr><td>Admin</td><td>Carlota</td><td>Everything a team member can do, plus Settings (roles, capacity, budgets, bank holidays, everyone's time off), editing anyone's time, deleting projects, Team time and budget alerts</td></tr>
          <tr><td>Team member</td><td>Everyone in a department</td><td>Create and edit projects and tasks, comment and attach files, log their own time, add their own time off, view Dashboards</td></tr>
          <tr><td>Director</td><td>Department directors</td><td>View Dashboards only</td></tr>
        </tbody>
      </table></div>
      <p>Everyone signing in for the first time starts as a Team member. Only the Admin can change someone's role.</p>`,
  },
  {
    id: 'getting-started',
    title: 'Getting started',
    html: `
      <p>You sign in with your DSD email and a link sent to your inbox. There is no password.</p>
      <ol>
        <li>Type your <strong>@digitalsmiledesign.com</strong> email on the sign-in page and click <strong>Send sign-in link</strong>.</li>
        <li>Open the email and click the link. You arrive signed in.</li>
        <li>The first time, click your initials (top right) → <strong>Profile</strong>. Check your name and upload a photo (up to 2 MB).</li>
      </ol>
      <p>You stay signed in on that browser for weeks. To sign out, click your initials → <strong>Sign out</strong>.</p>
      <p>To switch between light and dark, click your initials → <strong>Appearance</strong>: <strong>Light</strong>, <strong>Dark</strong> or <strong>Auto</strong> (follows your computer or phone). Your choice is remembered on that browser.</p>
      <ul>
        <li><strong>Only DSD emails work.</strong> Any other address is refused.</li>
        <li><strong>"Too many sign-in emails":</strong> only a few can be sent per hour. Try again later, or use the last link you received.</li>
        <li><strong>No email arriving:</strong> check spam, then tell Carlota.</li>
      </ul>`,
  },
  {
    id: 'my-tasks',
    title: 'Your daily routine: My tasks',
    html: `
      <p>Start each day on <a href="#/my-tasks">My tasks</a>. It lists every task and subtask assigned to you, across all projects, grouped by due date.</p>
      <div class="table-wrap"><table class="table">
        <thead><tr><th>Group</th><th>What's in it</th></tr></thead>
        <tbody>
          <tr><td>Overdue</td><td>Due before today and not done (in red)</td></tr>
          <tr><td>Today</td><td>Due today</td></tr>
          <tr><td>This week</td><td>Due in the next 7 days, starting tomorrow</td></tr>
          <tr><td>Later</td><td>Due more than 7 days ahead</td></tr>
          <tr><td>No date</td><td>No due date set</td></tr>
        </tbody>
      </table></div>
      <ul>
        <li><strong>Tick the box</strong> to mark something done. Switch on <strong>Show completed</strong> to see done items again.</li>
        <li><strong>Click a row</strong> to open the task's side panel (for a subtask, its main task opens).</li>
        <li>A subtask without its own date uses its main task's due date.</li>
        <li><strong>Hours this week</strong>, under the title, shows your time logged since Monday.</li>
      </ul>`,
  },
  {
    id: 'campaigns',
    title: 'Projects and tasks',
    html: `
      <p>Every piece of work belongs to a project. Every project belongs to one <strong>department</strong> (the team that owns it), and each department to one <strong>business unit</strong>:</p>
      <div class="table-wrap"><table class="table">
        <thead><tr><th>Business unit</th><th>Departments</th></tr></thead>
        <tbody>
          <tr><td>Education</td><td>Education</td></tr>
          <tr><td>DSD Center</td><td>Planning Center, Delight</td></tr>
          <tr><td>Corporate</td><td>Corporate, Marketing</td></tr>
        </tbody>
      </table></div>
      <p>A project also says who the work is <strong>for</strong>. Usually that's its own department. Marketing projects can be for any department, and that decides whose budget Marketing's hours count against:</p>
      <div class="table-wrap"><table class="table">
        <thead><tr><th>Marketing project for</th><th>Hours count against</th></tr></thead>
        <tbody>
          <tr><td>Education</td><td>Education budget</td></tr>
          <tr><td>Planning Center</td><td>Planning Center budget</td></tr>
          <tr><td>Delight</td><td>Planning Center budget</td></tr>
          <tr><td>Education + Planning Center</td><td>Split automatically, 70% Education / 30% Planning Center</td></tr>
          <tr><td>Any other department (Corporate, Marketing…)</td><td>Neither budget. Still counts as project work in Marketing's capacity</td></tr>
        </tbody>
      </table></div>
      <h3>Create a project</h3>
      <ol>
        <li>Go to <a href="#/campaigns">Projects</a> → <strong>New project</strong>.</li>
        <li>Fill in name, description, department, who it's for, status, dates, owner and planned hours. Department starts as yours.</li>
        <li>Click <strong>Create project</strong>. To change it later, open it and click <strong>Edit</strong>.</li>
      </ol>
      <p>Use the filters and the search box on the Projects page to find a project. Hours logged turn red when they pass the planned hours.</p>
      <h3>Add and organise tasks</h3>
      <ol>
        <li>Open the project and type a title in <strong>Add a task and press Enter</strong>. It goes to To do.</li>
        <li>Every project has three views, switched at the top right of its tasks. It opens on <strong>Kanban</strong>.
          <ul>
            <li><strong>Kanban</strong>: columns To do, In progress, In review and Done. Drag cards between them, and up or down to reorder.</li>
            <li><strong>Board</strong>: one column per section. Each card shows its status. Drag a card to another column to change its section.</li>
            <li><strong>List</strong>: a table, grouped by section.</li>
          </ul></li>
        <li><strong>Sections</strong> split a project into phases or groups, like Asana's (for example Pre-onboarding, During coaching, Graduation). Click <strong>+ Add section</strong> at the end of the Board or under the List. In the List, each section has ↑ ↓ to change its place, Rename and Delete. Each section has its own <strong>+ Add task</strong>. You can also change <strong>Section</strong> in a task's side panel. Deleting a section keeps its tasks, under No section.</li>
        <li>In Kanban and List, once a project has sections, a section filter appears next to the person filter. While a section is picked, new tasks go into it.</li>
        <li>Click a card to open its side panel: assignee, due date, section, status and description save as you leave each field.</li>
        <li>Add <strong>subtasks</strong> at the bottom of the panel, each with its own optional assignee and date. Assigning a task doesn't assign its subtasks.</li>
      </ol>
      <h3>Deleting</h3>
      <ul>
        <li>Any team member can delete a task from its panel; its subtasks, comments and attachments go with it.</li>
        <li>Only the Admin can delete a project.</li>
        <li><strong>Private projects</strong> (for Job Scorecards, finance or HR): in the project's form, under <strong>Who can see it</strong>, choose <strong>Only the departments and people I choose</strong>, then add them from the Departments and People dropdowns (× removes one). The project page lists who can see it. Its owner and Admins always see it; nobody else sees it, its tasks, comments or files. Tasks can only be assigned to, and @mentions only reach, people who can see it. Only the owner or an Admin can change who sees it. Its hours still count in Dashboards, without its name.</li>
        <li><strong>Archive</strong> (next to Edit on a project) moves a finished project to the <strong>Archived</strong> tab and takes its tasks off My tasks. Its hours stay in Dashboards, but no new time can be logged on it. <strong>Unarchive</strong> brings it back.</li>
        <li><strong>Anything with hours logged can't be deleted.</strong> Set it to Done or On hold instead.</li>
      </ul>`,
  },
  {
    id: 'search',
    title: 'Searching everything',
    html: `
      <ul>
        <li>Type in the <strong>Search</strong> box at the top (on a phone, tap the magnifying glass). Press <strong>/</strong> anywhere to jump to it.</li>
        <li>After two letters, a list suggests matching projects and tasks. Click one, or use ↑ ↓ and Enter, to open it. <strong>Search everything</strong> at the bottom, or Enter with nothing picked, opens the full results. Esc closes the list.</li>
        <li>It finds projects (by name or description), sections, tasks and subtasks (by title or description) and comments, across every project you can see, including archived ones. The words you typed are highlighted.</li>
        <li>On the Search page, results update as you type. Click a result to open it; a task opens in its project with its side panel open.</li>
        <li>Private projects only show up for the people who can see them.</li>
        <li>It shows up to 30 of each kind. If you don't see what you need, add more words.</li>
      </ul>`,
  },
  {
    id: 'together',
    title: 'Working together on a task',
    html: `
      <p>Keep a task's conversation and files inside the task, at the bottom of its side panel.</p>
      <h3>Comments and @mentions</h3>
      <ol>
        <li>Write in the comment box. Use <strong>B</strong> for bold and <strong>• List</strong> for bullets; links become clickable.</li>
        <li>Type <strong>@</strong> and pick a teammate to mention them. They get a notification.</li>
        <li>Click <strong>Comment</strong>, or press Cmd+Enter (Ctrl+Enter on Windows).</li>
      </ol>
      <p>You can edit or delete only your own comments. Directors can't be mentioned.</p>
      <h3>Attachments and links</h3>
      <ul>
        <li><strong>Files:</strong> drag them onto the box or click it, up to 25 MB each. Click an image thumbnail for a larger view.</li>
        <li><strong>Links:</strong> click <strong>Add a link</strong> for Google Drive, Canva, Figma or any other link. Prefer links for large or changing files.</li>
        <li>Files are private to the tool. The person who added one, or the Admin, can delete it.</li>
      </ul>`,
  },
  {
    id: 'time',
    title: 'Logging your time',
    html: `
      <p>Log every working hour, including meetings and admin, so the dashboards show where Marketing's time really goes. Project time always goes on a task (or subtask); only Internal time has no task.</p>
      <div class="table-wrap"><table class="table">
        <thead><tr><th>Way</th><th>Where</th><th>Best for</th></tr></thead>
        <tbody>
          <tr><td>Weekly grid</td><td><a href="#/my-time">My time</a></td><td>Filling in the week in one go</td></tr>
          <tr><td>Add time</td><td>My time, or <strong>Add time</strong> in a task's panel</td><td>One entry with a note</td></tr>
          <tr><td>Timer</td><td><strong>▶ Start timer</strong> in a task's panel or on My time</td><td>Timing work as you do it</td></tr>
        </tbody>
      </table></div>
      <h3>Weekly grid</h3>
      <ol>
        <li>On My time, use ‹ and › to change week; <strong>This week</strong> jumps back.</li>
        <li>Start the week with <strong>Copy last week's rows</strong> or a <strong>suggested row</strong> (your tasks in progress or due this week). For anything else, click <strong>Add row</strong> and pick the project and its task (or <strong>Internal</strong>, which has no task).</li>
        <li>Type hours as <code>1.5</code> or <code>1:30</code>. It saves straight away; clear a box to delete it. Enter moves down, arrow keys move between days.</li>
        <li>The <strong>Logged this week</strong> card shows your hours against your expected week. Bank holidays and days off are marked in the grid.</li>
      </ol>
      <h3>Timer</h3>
      <ol>
        <li>Click <strong>▶ Start timer</strong> on a task (or ▶ next to a subtask). A red clock shows in the top bar and keeps running even if you close the browser.</li>
        <li>Click <strong>Stop</strong>. The time is rounded to the nearest 5 minutes; check it and click <strong>Save time</strong>.</li>
        <li><strong>Cancel</strong> keeps it running; <strong>Discard timer</strong> throws it away. Only one timer runs at a time.</li>
      </ol>
      <h3>Internal time, and projects for both units</h3>
      <ul>
        <li><strong>Internal</strong> (no project) is for team meetings, admin and training. It counts towards capacity, not against either budget.</li>
        <li>On a Marketing project for <strong>Education + Planning Center</strong> you log one entry; it is split 70% Education / 30% Planning Center behind the scenes.</li>
      </ul>
      <h3>Correcting entries</h3>
      <p>Use <strong>Edit</strong> or <strong>Delete</strong> in <strong>Entries this week</strong> on My time. A grid box with a dashed outline holds several entries; typing a new total merges them.</p>
      <p><strong>Recommended:</strong> log daily and complete the week by Friday afternoon. At 12:00 on Friday the tool reminds anyone under 90% of their working week.</p>`,
  },
  {
    id: 'time-off',
    title: 'Time off',
    html: `
      <p>Add holidays and absences as soon as they're agreed. Time off lowers the team's available hours and that month's budgets.</p>
      <ol>
        <li>Go to <a href="#/my-time">My time</a> → <strong>Time off</strong> tab. The <strong>team calendar</strong> shows who's off when, with each person's bank holidays and non-working days. Click a free day on your row (or use <strong>Add time off</strong>).</li>
        <li>Choose the first and last day (the same day for one day) and the reason: Holiday or Absence.</li>
        <li>Click <strong>Add time off</strong>. Weekends and bank holidays inside the dates aren't counted.</li>
      </ol>
      <ul>
        <li>Full days only. To cancel, click the day off on the calendar, or <strong>Delete</strong> in the list.</li>
        <li>Others see your time off as "Off"; only you and the Admin see whether it's a holiday or an absence.</li>
        <li>Bank holidays for Madrid and England are already in the tool; don't add them as time off.</li>
        <li>Time off still needs approval in Personio as usual; the tool doesn't approve anything.</li>
      </ul>`,
  },
  {
    id: 'notifications',
    title: 'Notifications',
    html: `
      <p>Notifications appear only inside the tool, under the <strong>bell</strong> in the top bar. A red number shows how many you haven't read.</p>
      <div class="table-wrap"><table class="table">
        <thead><tr><th>You're notified when</th><th>When it arrives</th><th>Who gets it</th></tr></thead>
        <tbody>
          <tr><td>Someone assigns you a task or subtask</td><td>Straight away</td><td>The assignee</td></tr>
          <tr><td>Someone @mentions you</td><td>Straight away</td><td>The person mentioned</td></tr>
          <tr><td>Someone comments on your task</td><td>Straight away</td><td>The task's assignee</td></tr>
          <tr><td>A task is due by your next working day</td><td>Weekdays at 8:00 your local time (Friday's covers the weekend and Monday)</td><td>The assignee</td></tr>
          <tr><td>A task has become overdue</td><td>Weekdays at 8:00, once per task</td><td>The assignee</td></tr>
          <tr><td>Your hours are under 90% of your working week</td><td>Fridays at 12:00 your local time</td><td>Everyone counted in team capacity</td></tr>
          <tr><td>A business unit passes 80% or reaches 100% of its monthly budget</td><td>Straight away</td><td>The Admin</td></tr>
        </tbody>
      </table></div>
      <ul>
        <li>Click a notification to open what it's about; it's then marked as read. <strong>Mark all as read</strong> clears the count.</li>
        <li>You're never notified about your own actions. "Local time" is Madrid or UK time, from your holiday calendar.</li>
      </ul>`,
  },
  {
    id: 'dashboards',
    title: 'Dashboards',
    html: `
      <p><a href="#/dashboards">Dashboards</a> show how Marketing's hours compare with each business unit's budget for a month or quarter.</p>
      <p><strong>Choose the period first</strong> with ‹ › or the month box, and switch between <strong>Month</strong> and <strong>This quarter</strong>. Every figure follows that choice. <strong>Both units / Education / Planning Center</strong> narrows the whole page to one unit (clicking a unit's budget bar does the same).</p>
      <p>The <strong>headline figures</strong> at the top answer the main questions at a glance: each unit's budget used, the team's productive time used and projects over plan, with the change since the previous month or quarter. The menu under the controls jumps to each section.</p>
      <div class="table-wrap"><table class="table">
        <thead><tr><th>Section</th><th>What it shows</th></tr></thead>
        <tbody>
          <tr><td>Budget overview</td><td>Hours used against each unit's budget: green within budget, amber over 80%, red at 100% or more. Internal hours shown separately. Click a unit to filter the projects below.</td></tr>
          <tr><td>Trend</td><td>Hours per unit over the last 6 or 12 months, with each month's budget as a dashed line. Hover for exact figures, or use <strong>Show as table</strong>.</td></tr>
          <tr><td>By project</td><td>Projects active in the period: planned hours, hours this period and total so far. <strong>Over plan</strong> flags those past their planned hours.</td></tr>
          <tr><td>Team capacity</td><td>Per person: working hours (after bank holidays and time off), productive hours, project hours logged and % used.</td></tr>
          <tr><td>Upcoming</td><td>Projects starting in the next 1, 2 or 3 months, with planned hours.</td></tr>
        </tbody>
      </table></div>
      <h3>How budgets are calculated</h3>
      <ol>
        <li>Each person's working days × hours per day, minus bank holidays and time off, gives <strong>working hours</strong>.</li>
        <li>80% of that is <strong>productive time</strong>; the other 20% covers internal meetings, admin and non-productive time.</li>
        <li>Productive time is split <strong>70% Education / 30% Planning Center</strong>: that's each unit's budget.</li>
      </ol>
      <p>So a holiday automatically lowers that month's budgets. Internal hours don't count against either budget.</p>
      <h3>Sharing the figures</h3>
      <ul>
        <li><strong>Download Excel</strong>: one sheet per section, each starting with its period. <strong>CSV</strong>: the same in one file.</li>
        <li><strong>Present</strong>: one section per screen for meetings. Step through with <strong>Next / Previous</strong> or the arrow keys; click <strong>Exit present view</strong> when done.</li>
      </ul>`,
  },
  {
    id: 'admin',
    title: 'Admin procedures (Carlota)',
    html: `
      <p>Keep people, capacity and budgets up to date in <a href="#/capacity/people">Capacity</a> (sections <strong>People</strong>, <strong>Departments</strong>, <strong>Team rules</strong>, <strong>Monthly budgets</strong> and <strong>Holidays &amp; time off</strong>). The <strong>Design system</strong> reference is in the menu under your photo.</p>
      <h3>When someone joins</h3>
      <ol>
        <li>In Capacity → People, click <strong>Invite</strong> and enter their DSD email (or ask them to sign in once). They appear as a Team member.</li>
        <li>Click <strong>Edit</strong> on their row and set everything in one place: department, role, hours per day, working days, holiday calendar and whether they count in capacity. New team members still on the starting settings show <strong>Needs setup</strong>.</li>
        <li>For a director: choose <strong>Director</strong> and untick <strong>Counts in team capacity</strong>.</li>
      </ol>
      <h3>When someone leaves</h3>
      <p>In Capacity → People click <strong>Deactivate</strong>: they're signed out and can't sign in; their work is kept. <strong>Reactivate</strong> undoes it. Reassign their open tasks.</p>
      <h3>Capacity settings</h3>
      <div class="table-wrap"><table class="table">
        <thead><tr><th>Setting</th><th>What it changes</th></tr></thead>
        <tbody>
          <tr><td>Team rules: productive time (80%)</td><td>Share of working hours available for project work</td></tr>
          <tr><td>Team rules: budget split (70 / 30)</td><td>How productive hours divide into each unit's monthly budget</td></tr>
          <tr><td>Departments</td><td>The list of departments and the business unit each belongs to. Each person's department is set in <strong>People</strong></td></tr>
          <tr><td>Team rules: split for projects for both (70 / 30)</td><td>How hours on Marketing projects for both Education and Planning Center are divided; changes apply only to hours logged afterwards</td></tr>
          <tr><td>Monthly budgets</td><td>Automatic. Type a number to override a month; <strong>Back to automatic</strong> undoes it</td></tr>
          <tr><td>Holidays &amp; time off</td><td>The team calendar shows each person's bank holidays (Madrid or England) and time off; click a bank holiday to rename or delete it. Bank holidays are loaded to the end of 2027; add new ones in <strong>Bank holidays by year</strong> once the dates are published.</td></tr>
        </tbody>
      </table></div>
      <h3>Weekly routine</h3>
      <ol>
        <li>Monday: check last week's hours in <strong>My time → Team time</strong>; click a person to see their entries.</li>
        <li>Follow up on missing days; you can correct entries yourself if needed.</li>
        <li>Check Projects for anything over its planned hours.</li>
      </ol>
      <h3>Monthly routine</h3>
      <ol>
        <li>Before the month: check holiday calendars, time off and the month's budgets in Capacity.</li>
        <li>After the month: review Dashboards, then <strong>Download Excel</strong> or <strong>Present</strong> for the directors.</li>
        <li>Act on budget alerts in your bell during the month.</li>
      </ol>`,
  },
  {
    id: 'faq',
    title: 'Rules, troubleshooting and FAQ',
    html: `
      <h3>The rules in short</h3>
      <ol>
        <li>Every piece of work sits in a project with the right department and "for"; non-project work is Internal.</li>
        <li>Every task has one assignee and, where there's a deadline, a due date.</li>
        <li>Log all your working hours, daily if possible, complete by Friday afternoon.</li>
        <li>Add your time off as soon as it's agreed.</li>
        <li>Discuss a task in its comments and attach its files there.</li>
        <li>Never delete work with hours logged; set it to Done or On hold.</li>
      </ol>
      <h3>Troubleshooting</h3>
      <div class="table-wrap"><table class="table">
        <thead><tr><th>Problem</th><th>What to do</th></tr></thead>
        <tbody>
          <tr><td>Something looks out of date</td><td>Refresh with Cmd+Shift+R (Ctrl+Shift+R on Windows)</td></tr>
          <tr><td>The sign-in email doesn't arrive</td><td>Check spam; wait if you see "too many sign-in emails"; then tell Carlota</td></tr>
          <tr><td>I can't type in a box on My time</td><td>You may be viewing someone else's week: set <strong>Person</strong> back to yourself</td></tr>
          <tr><td>I can't delete a task or project</td><td>It has hours logged; set it to Done or On hold</td></tr>
          <tr><td>I don't see Settings, or can't edit</td><td>Your role doesn't allow it; ask Carlota</td></tr>
        </tbody>
      </table></div>
      <h3>FAQ</h3>
      <p><strong>Can I see my teammates' hours?</strong> Yes, with the Person picker on My time. Only the Admin can change someone else's entries.</p>
      <p><strong>Do I need to log hours on a specific task?</strong> Yes. Project time always goes on a task or subtask, so every hour can be traced. If no task fits, add one on the project page first. Only Internal time has no task.</p>
      <p><strong>What if I worked on something for both Education and Planning Center?</strong> Use a Marketing project for <strong>Education + Planning Center</strong>: your one entry is split 70 / 30 automatically.</p>
      <p><strong>Does the tool replace Personio?</strong> No. Get holidays approved in Personio as usual, then add them here.</p>`,
  },
];

export function renderHelp(el) {
  const sections = SECTIONS;
  el.innerHTML = `
    <div class="page-header">
      <div>
        <h1>Help</h1>
        <p class="muted">How to use DSD Atlas. Questions this doesn't answer? Ask Carlota.</p>
      </div>
    </div>
    <div class="help">
      <nav class="help-toc" aria-label="Help contents">
        <input type="search" class="search" placeholder="Search help" aria-label="Search help" data-search>
        <ol>${sections.map(s => `<li><button type="button" data-goto="${s.id}">${esc(s.title)}</button></li>`).join('')}</ol>
      </nav>
      <div class="help-body">
        ${sections.map(s => `<section class="card help-section" id="help-${s.id}" data-section="${s.id}"><h2>${esc(s.title)}</h2>${s.html}</section>`).join('')}
        <p class="muted empty-row" data-no-results hidden>Nothing in Help matches that. Try another word.</p>
      </div>
    </div>`;

  // Contents: scroll to a section (the page address is used for navigation)
  el.querySelectorAll('[data-goto]').forEach(button => button.addEventListener('click', () =>
    el.querySelector(`#help-${button.dataset.goto}`).scrollIntoView({ behavior: 'smooth', block: 'start' })));

  // Search: show only sections containing every word typed
  el.querySelector('[data-search]').addEventListener('input', event => {
    const words = event.target.value.toLowerCase().split(/\s+/).filter(Boolean);
    let shown = 0;
    el.querySelectorAll('[data-section]').forEach(section => {
      const match = words.every(w => section.textContent.toLowerCase().includes(w));
      section.hidden = !match;
      el.querySelector(`[data-goto="${section.dataset.section}"]`).parentElement.hidden = !match;
      if (match) shown += 1;
    });
    el.querySelector('[data-no-results]').hidden = shown > 0;
  });
}
