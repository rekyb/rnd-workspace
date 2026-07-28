# Learner Acquisition & Onboarding

**Status:** Active
**Started:** 2026-07-21
**Informed by:** research/2026-07-20-unified-onboarding-synthesis-and-patterns
**Design system:** independent — 23 tokens hand-copied into `styles.css`; migration to `ui-library/` is pending (spec Phase 3)

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
