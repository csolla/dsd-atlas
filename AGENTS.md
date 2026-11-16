# DSD Atlas

DSD's project management tool: campaigns (projects), tasks, time logging and director dashboards. Built for the Marketing team as the Marketing PM Tool and renamed DSD Atlas on 16 November 2026; it replaces Asana for every DSD department from go-live on 14 December 2026 (plan: https://claude.ai/artifact/Q9jZ9Rvc3mx7iCKN9cUytS).

- **Live app:** https://csolla.github.io/dsd-atlas/ (GitHub repo `csolla/dsd-atlas`).
- **The old Atlas is retired.** The earlier tool also called Atlas (repo `csolla/dsd-projects`, now archived, folder `../archive/atlas-old`) is switched off. Don't change it, analyse it or compare against it.

- **Stack:** plain HTML, CSS and JavaScript (no build step), hosted on GitHub Pages, with a new, dedicated Supabase project for the database, login, file storage and live updates.
- **Owner:** Carlota (csolla@digitalsmiledesign.com), who is not technical. Explain each step in plain language.
- **SQL:** Carlota runs database changes by hand in the Supabase SQL editor. Save each one as a numbered file under `supabase/migrations/` and put it on her clipboard with `pbcopy`.

## Build history

All five build milestones are complete (October 2026). The original PRD, milestone prompts and milestone logs were moved out of this folder to `../archive/marketing-pm-tool-build-plan/`. They are a historical record, not current documentation: the code has moved past some of their decisions, and nothing in the code depends on them. The milestone logs are still the best summary of why things were built the way they were.

- Database changes so far: `supabase/migrations/01` to `11`. The next one is `12`.
- **Departments (must-have 1, `11_departments.sql`):** business units are Education, DSD Center and Corporate; each department (Marketing, Education, Planning Center, Delight, Corporate, plus any the admin adds) belongs to one. Every person and campaign has a `department_id`; a campaign's `for_department_id` says who the work is for (own department by default). Marketing campaigns can be for any department; empty `for_department_id` = both Education and Planning Center, split by `team_settings.shared_split_education`. Marketing work for Delight counts against the Planning Center budget; for any other department, against neither budget (`budget = 'other'`) but still counts as campaign work in Marketing's capacity. Procurement is part of Corporate, not a separate department. There is no "Shared" label any more.
- The old `business_unit` columns on `campaigns` and `time_entries` are now `budget` (education / planning_center / shared / internal / other), set by the database, never typed. `other` = not one of Marketing's budgets. Capacity, budgets, Team time, Dashboards and the Friday timesheet reminder are Marketing-only until must-have 11 (hours for every team). Helpers live in `js/departments.js`.
- Campaign time must always be on a task (constraint `campaign_time_needs_task`); only Internal time has no task.
- Capacity rules exist twice and must be kept in step: `js/capacity.js` (`availability`, `monthBudget`, `capacityPeople`) and the SQL functions `person_working_hours` / `unit_month_budget` (both count active Marketing people who count in capacity).
- When embedding a subtask's parent task in a Supabase request, name it by column (`parent:parent_id(...)`), not by constraint name.

<!-- bm-design-system:start -->
## Design system

The tool's look is defined once, adapted from the BM design system (the BM skill itself needs React + Tailwind, which this tool doesn't use). The live reference is **Design system** in the menu under your photo (Admin only; `#/design-system`, `js/pages/design-system.js`).

- **Tokens only.** Colours, fonts, radius and shadows are CSS custom properties at the top of `css/styles.css`, with a dark-mode block. Never hard-code a colour in a page or component; add a token (with its dark value) if one is missing.
- **Fonts:** Inter for headings (`--font-display`), DM Sans for everything else (`--font`), loaded in `index.html`.
- **Accent:** `--accent` (`#0e7490` light / `#22d3ee` dark) for buttons and links, because BM's `#0891b2` is under 4.5:1 for text. `--accent-bright` (BM cyan) is only for focus rings, selected states and meters.
- **Reuse the existing building blocks** (`.btn` variants, `.field`, `.table`, `.card`, `.tag`, `.status`, `.status-chip`, `.view-switch`, `.empty-state`, `formDialog` / `confirmDialog` / `toast` in `js/ui.js`) rather than creating new ones. A new block gets added to the Design system page too.
- **Chart colours** (`--series-*`, `--status-*`) were validated for colour blindness with the dataviz palette script; re-run it before changing them.
- Colour never carries meaning alone: pair it with a word or icon.
<!-- bm-design-system:end -->
