# Learner Acquisition & Onboarding

**Status:** Active
**Started:** 2026-07-21
**Informed by:** research/2026-07-20-unified-onboarding-synthesis-and-patterns
**Design system:** independent — 23 tokens hand-copied into `styles.css`. **Settled 2026-07-28: this project will not migrate to `ui-library/`.** Measured cost of migrating: 46 of its 49 classes are absent from `components.css` (gate rule 4 has no project-class exemption), `styles.css` carries 224 raw px and 22 raw hex values (rule 2), and 10 of its 23 token names do not exist upstream — which an overlay may not introduce. That is a rebuild of a working, tested prototype, not a migration. See `.claude/references/design-projects.md`.

## Problem

Learners arrive at the platform with very different amounts of context — some with a
facilitator-issued program code and a destination already decided, some browsing with no
idea what to learn, some returning to an account they already have. One undifferentiated
entry path forces all three through decisions that only apply to one of them, and loses
program attribution along the way. This project defines the single acquisition and
onboarding funnel that serves all three without that cost.

## Files

- `PRD.md` — the decision doc (Shape-Up format, 13 sections + appendices).
- `prototype-web.html` + `styles.css` + `main.js` + `data.js` — the multi-file prototype
  source. Predates the `src/` convention in `.claude/references/design-projects.md`.
- `build-standalone.ps1` — inlines the above into `standalone.html` (gitignored,
  ~3 MB), base64-encoding `img/` and failing loudly on a missing asset.
- `prototype-web.test.ps1` — the prototype's regression suite.

## Status log

| Date | Entry |
|---|---|
| 2026-07-21 | Project started; prototype source authored. |
| 2026-07-23 | `PRD.md` written (Shape-Up, 13 sections + 2 appendices). |
| 2026-07-27 | `README.md` backfilled to the `design-projects.md` contract; `landing.png` / `register.png` downscaled 2528px → 1080px. |
| 2026-07-28 | `SPEC.md` deleted — byte-identical to `PRD.md` apart from line endings in the §7.1 Mermaid block. |
| 2026-07-28 | Stays `Design system: independent` — the spec's Phase 3 migration is dropped, not deferred. Known consequence: `prototype-web.html`'s four external font `<link>` tags mean the committed `standalone.html` would fail `check-prototype.ps1` rule 1, so this prototype is not gate-clean and is not expected to be. |
| 2026-07-28 | **Gender gate reconciled into the PRD.** The screen existed in the prototype but in no requirement. Now documented across §2 (as an explicit *assumption*, not a finding — no study backs it), §7.1/§7.2, Slice 5 (renamed "Age and gender segmentation, and eligibility handling") + 6 ACs, §10, §11 (a new open-question row: Program Ops + Legal/Privacy must confirm purpose and lawful basis, **default = do not collect**), §12.5, and both appendices. The step is flagged provisional and behind its own config flag, so a negative decision removes it without touching the rest of the funnel. |
| 2026-07-28 | Prototype defect pass. Fixed: goal→course map was fully stale (zero key overlap with `data.js`, so every organic learner saw the fallback course); account-creation password gate raised 6→8 per PRD §7.3 (login left at 6 so legacy credentials aren't locked out); modals gained `role="dialog"`/`aria-modal`/accessible names, focus trap, inert background, Escape-to-close, and focus restore; `.modal-overlay` gained `visibility: hidden` so closed modals leave the tab order — which also fixed an `autofocus` firing inside a hidden modal on page load; country-search highlight now escapes the query before building a regex; flag images fail closed instead of showing broken icons; vestigial "at least 15 years old" snackbar copy, four Apple/Telegram handlers for absent elements, and a redundant duplicate back-button registration removed. Suite extended 8 → 12 groups; all pass. |
| 2026-07-28 | Deleted six unreferenced `img/stock-*.webp` (~910 KB) — confirmed zero references project-wide. |
