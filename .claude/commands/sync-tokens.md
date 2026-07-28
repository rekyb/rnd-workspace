---
description: Sync the production design tokens and component CSS into ui-library/, or check for drift.
argument-hint: [--check] [--ref <branch|sha>]
---

Sync `ui-library/` from the upstream production repo. Read
`.claude/references/design-system.md` first — it carries the marker contract, the
disclosure boundary, and the overlay rule.

1. **Parse arguments.** `--check` reports drift and writes nothing. `--ref <branch|sha>`
   selects the source ref; the default is `main`. `packages/tokens` carries no release
   tags upstream, so `main` is a moving target — prefer a pinned SHA when reproducibility
   matters.

2. **Ask the user for the upstream repo URL — every run.** The URL is deliberately **not
   stored anywhere in this repo**, so there is no default to fall back on and you must not
   guess one, reuse one from an earlier session, or read one out of git history. STOP and
   ask the user to paste the clone URL, then pass it as `-RepoUrl`. The script fails with a
   clear message if it is missing.
   - Do **not** echo the URL back into any file the repo commits — not `TOKENS.md`, not a
     commit message, not a report. It is used for the clone and then discarded.
   - If the user already supplied a local checkout path, use `-SourcePath <path>` instead
     and skip the URL entirely — that path needs no clone.

3. **Run the script.**
   - Sync: `powershell -NoProfile -File .claude/scripts/sync-tokens.ps1 -RepoUrl <url>`
   - Check: `powershell -NoProfile -File .claude/scripts/sync-tokens.ps1 -RepoUrl <url> -Check`
   - Pinned: `powershell -NoProfile -File .claude/scripts/sync-tokens.ps1 -RepoUrl <url> -Ref <sha>`
   - Local checkout (no URL needed): `… -SourcePath <path>`

4. **Report.** Show the token diff the script prints (added / removed / changed). On a
   `--check` failure, show the drift and stop — do not sync as a "fix" unless the user
   asks, because a sync overwrites local `ui-library/` edits.

5. **Never** commit `manifest.json` or anything from the source repo's `.claude/`. The
   script already refuses to write them; if you see either under `ui-library/`, stop and report a
   disclosure-boundary breach. Path exclusion alone is not enough — the first real sync
   proved that internal notes can leak through comments inside the two permitted files,
   so the script also scrubs `components.css` (strips every CSS comment and any
   external-host `@import`) and `tokens.json` (drops every `$description`) on every run;
   see **Disclosure boundary** in `design-system.md` for what that scrub does and why.

The clone is about 29 MB and goes to the system temp folder, never into the workspace.
It is deleted when the script exits.
