---
name: research-board
description: Show the board — active and closed research studies, plus every design project — in the terminal, and refresh BOARD.md.
---

Render the **board** to the terminal: every currently active study, every past (closed / archived) one, and every **design project**. Then refresh `BOARD.md` so the committed board never drifts from what's actually on disk.

The **source of truth** is the folders themselves — the `research/` studies and the `design/` projects — never a stale table. Derive everything fresh, then reconcile `BOARD.md` to match.

The command keeps its research-centric name because renaming it would churn every skill file for no functional gain.

Steps:

1. **Find the active studies.** Read `.claude/.active-research` (the registry — see `.claude/references/active-research.md`). **Each line** names an active study; every one is an **Active** row (there may be several). If the file is missing/empty, there is no active study — say so in the Active section. As housekeeping, prune stale per-terminal bindings: delete any file in `.claude/.current-research/` whose path is not a line in the registry, and any file in `.claude/.current-design/` whose folder is missing or is no longer `Status: Active` (see `.claude/references/design-projects.md`).

2. **Enumerate every study.** List the folders under `research/` (ignore `PATTERNS.md` and any non-study file). For each folder, read its `README.md` and extract:
   - **Title** — the first `#` heading (strip a leading `Research:` prefix).
   - **Type** — the `**Type:**` line if present; if absent, treat it as `benchmark` (the workspace default, pre-dating the type-aware spine). `litreview` is a fully valid `Type` value and renders in the tables exactly like `benchmark` or `usability` — no special-casing needed.
   - **Started** — the `**Started:**` date.
   - **Closed** — the `**Closed:**` date if present, else `—`.
   - **Status** — the `**Status:**` value (Active / Closed).
   A folder with **no `README.md`** (e.g. an early notes-only capture) is listed as **Archived (notes only)** with Started taken from its `YYYY-MM-DD-` folder-name prefix and Closed `—`. Never fabricate a status; report what the folder actually shows.

3. **Enumerate every design project.** List the folders under `design/` (ignore any non-project file). For each, read its `README.md` and extract:
   - **Title** — the first `#` heading.
   - **Status** — the `**Status:**` value (`Active` / `Shipped` / `Archived`).
   - **Started** — the `**Started:**` date.
   - **Informed by** — the `**Informed by:**` studies; render `none` as `— (unevidenced)` so an assumption-based project is visible as such rather than looking merely blank.
   - **Design system** — `ui-library/` or `independent`.
   - **PRD** — `✓` if `PRD.md` exists in the folder, else `—`.
   - **Prototype** — `✓` if the folder holds prototype source (`src/`, or a legacy `prototype-*.html` at the project root), else `—`.

   A folder with **no `README.md`** is listed as **Unregistered** with every derived field `—`. Never fabricate a status; report what the folder actually shows. See `.claude/references/design-projects.md` for the folder contract.

4. **Print the board to the terminal**, most recent first within each group:

   - A short header line: total studies (active vs closed/archived) and total design projects (active vs shipped/archived).
   - **Active research** — a table (or "No active research — run `new-research` to start one.") with one row per registry line and columns: Research (title + folder path) · Type · Started · Status.
   - **Closed & archived research** — a table with columns: Research · Type · Started · Closed · Status.
   - **Design projects** — a table (or "No design projects — run `new-design <name>` to start one.") with columns: Project (title + folder path) · Status · Started · Informed by · Design system · PRD · Prototype. Active first, then Shipped, then Archived; most recently started first within each group.

   Keep it skimmable — link each study and project to its folder.

5. **Refresh `BOARD.md`.** Rewrite `BOARD.md` from the same derived data so it matches what you just printed: the `## Active` table, the `## Closed & archived` table (most recent first), and the `## Design projects` table, and update the `_Last updated: <date>_` line. Preserve the file's intro paragraph. If `BOARD.md` is missing, create it with that structure. Only touch `BOARD.md` — do not edit any study's or project's `README.md`.

6. **Report** one line noting whether `BOARD.md` changed (and how — e.g. "moved Khan study from Active to Closed", "added new design project") or was already in sync.

This command is **read-mostly**: it only ever writes `BOARD.md` (and prunes stale per-terminal bindings). It never changes a study's or a project's status, never closes or opens research, and never browses any platform.
