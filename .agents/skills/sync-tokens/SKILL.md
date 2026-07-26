---
name: sync-tokens
description: Sync the production design tokens and component CSS into ui-library/, or check for drift against the upstream source.
---

Sync `ui-library/` from the Solve Education production repo. Read
`.claude/references/design-system.md` first — it carries the marker contract, the
disclosure boundary, and the overlay rule.

1. **Parse arguments.** `--check` reports drift and writes nothing. `--ref <branch|sha>`
   selects the source ref; the default is `main`. `packages/tokens` carries no release
   tags upstream, so `main` is a moving target — prefer a pinned SHA when reproducibility
   matters.

2. **Run the script.**
   - Sync: `powershell -NoProfile -File .claude/scripts/sync-tokens.ps1`
   - Check: `powershell -NoProfile -File .claude/scripts/sync-tokens.ps1 -Check`
   - Pinned: `powershell -NoProfile -File .claude/scripts/sync-tokens.ps1 -Ref <sha>`

3. **Report.** Show the token diff the script prints (added / removed / changed). On a
   `--check` failure, show the drift and stop — do not sync as a "fix" unless the user
   asks, because a sync overwrites local `ui-library/` edits.

4. **Never** commit `manifest.json` or anything from the source repo's `.claude/`. The
   script already refuses to write them; if you see either under `ui-library/`, stop and report a
   disclosure-boundary breach. Path exclusion alone is not enough — the first real sync
   proved that internal notes can leak through comments inside the two permitted files,
   so the script also scrubs `components.css` (strips every CSS comment and any
   external-host `@import`) and `tokens.json` (drops every `$description`) on every run;
   see **Disclosure boundary** in `design-system.md` for what that scrub does and why.

The clone is about 29 MB and goes to the system temp folder, never into the workspace.
It is deleted when the script exits.
