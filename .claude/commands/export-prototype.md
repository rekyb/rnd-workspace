---
description: Build a design project's src/ into build/standalone.html, run the local design gate, and — with --artifact — publish it to claude.ai after an explicit confirmation.
argument-hint: [project] [--artifact]
---

Turn a design project's **multi-file prototype source** into the **one file** you can
open, share, or publish. Where `/design-prototype` *authors* `src/`, this command
*ships* it: inline, gate, and (optionally) publish.

Splitting the two matters because they fail differently. Authoring fails on design
questions — a missing screen, an unported component. Exporting fails on mechanical ones
— a missing asset, a raw hex value, an unresolved token. Keeping them apart means a gate
failure never sends you back through a whole authoring pass.

## Arguments

- **`[project]`** (optional positional) — a design project slug or path. Resolved per
  `.claude/references/design-projects.md`; naming one adopts this terminal's binding.
- **`--artifact`** — after the gate passes, publish to claude.ai as an Artifact. Omitted,
  the command stops at a built, gate-checked local file.

## Steps

1. **Resolve the project.** Per `.claude/references/design-projects.md`: explicit
   argument (adopt the binding) → this terminal's binding → the sole `Status: Active`
   project → otherwise STOP, list what was found, and ask. Never create a project.

2. **Confirm there is something to export.** The entry file is
   `design/<project>/src/index.html`. If it is missing, STOP and tell the user to run
   `/design-prototype` first — there is no prototype source yet.

3. **Build.** Run:
   `powershell -NoProfile -File .claude/scripts/build-prototype.ps1 -ProjectPath design/<project>`
   On a non-zero exit, relay the builder's message verbatim and STOP. Its failures are
   concrete (a missing asset, an external link) and belong to the source, not to this
   command.

4. **Gate.** Run:
   `powershell -NoProfile -File .claude/scripts/check-prototype.ps1 -Path design/<project>/build/standalone.html`
   Add `-OverlayPath design/<project>/tokens.overlay.css` **if that file exists** —
   without it the overlay's own declarations are read as raw values sitting outside the
   recognised design-system blocks, and **rule 2** fails (`raw hex outside the
   design-system files: #…`). It is not rule 3 that breaks: an overlay may only redefine
   names `tokens.css` already defines, so `var(--x)` still resolves either way.
   Branch on `$LASTEXITCODE`, never on output text. On a non-zero exit, report **every**
   violation (the script collects them all deliberately) and STOP.

   Read rule 2's caveat before declaring a pass: if `tokens.css` or `components.css`
   was not found inlined verbatim, the raw-value rule **did not run**. A gate that
   skipped its own rule is not a green gate — say so plainly rather than reporting
   "passed".

5. **Report the local result.** The built path, its size, and the gate outcome. Without
   `--artifact`, stop here — say where the file is and that it is publishable.

6. **`--artifact` only — PII and impersonation check.** Publishing is outward-facing.
   Re-check the built file for internal specifics (product / program / funder names),
   real people's names, avatars, emails, or account data, and confirm it does not
   impersonate a real organisation (generic-branded only). `check-prototype.ps1` rule 5
   catches email addresses and nothing else — it is a lint, not a guarantee. Anything
   found: STOP and report, do not publish.

7. **`--artifact` only — checkpoint.** Ask for explicit confirmation to publish, naming
   what will be published and that Artifacts start private. Proceed only on a clear yes.

8. **`--artifact` only — publish.** Copy the built file into the session scratchpad, then
   **strip the outer document wrapper from the scratchpad copy** before publishing: remove
   the `<!DOCTYPE>`, `<html …>`, `<head>`/`</head>`, `<body …>`, `</body>`, and `</html>`
   tags, keeping every `<style>` and `<script>` block (wherever it sat) and all body
   content intact and in order. This is required, not tidying: the Artifact tool wraps the
   file it publishes in its own `<!doctype html>…<head></head><body>` skeleton, so a file
   carrying its own document tags nests one document inside another. Do **not** "simplify"
   this back to publishing `standalone.html` directly. `build/standalone.html` itself stays
   a complete, openable document — the stripping happens only on the scratchpad copy.
   Then publish that copy with the **Artifact** tool. Use a **stable file path per
   project** so a later export redeploys the **same URL** rather than minting a new one.
   Title = the project's `README.md` title + " Prototype". Keep the favicon stable across
   redeploys. If the project has been published before, pass its existing `url`.
   *(No design project has been published yet, so this seam is untested — if the publish
   errors, report what it said rather than guessing at a fix.)*

9. **Update the log** in `design/<project>/README.md` with a dated status-log row: built,
   gate result, and the Artifact URL if one was published.

10. **Report** the built path, the gate outcome (including any rule that was skipped),
    and the Artifact URL if published.

## Guardrails

- `build/` is **gitignored** (`.gitignore`, `design/*/build/`). The built file is an
  artifact, not a source of truth — never commit it, and never hand-edit it. Fix `src/`
  and rebuild.
- **Never publish on a failed gate**, and never publish without the step-7 confirmation.
- A gate rule that could not run is **not** a rule that passed. Report the difference.
