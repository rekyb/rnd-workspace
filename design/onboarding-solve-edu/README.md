# Learner Acquisition & Onboarding

**Status:** Active
**Started:** 2026-07-21
**Informed by:** research/2026-07-20-unified-onboarding-synthesis-and-patterns (litreview, peer-reviewed 2026-07-20; coverage Q1,Q3 answered · Q2 partial), research/2026-07-28-post-signup-handoff-first-run-home (benchmark, peer-reviewed 2026-07-29; coverage Q2,Q3,Q5 answered · Q1,Q4 partial · Q6 unanswered)
**Design system:** independent — 23 tokens hand-copied into `styles.css`. **Settled 2026-07-28: this project will not migrate to `ui-library/`.** Measured cost of migrating: 46 of its 49 classes are absent from `components.css` (gate rule 4 has no project-class exemption), `styles.css` carries 224 raw px and 22 raw hex values (rule 2), and 10 of its 23 token names do not exist upstream — which an overlay may not introduce. That is a rebuild of a working, tested prototype, not a migration. See `.claude/references/design-projects.md`.

## Problem

Learners arrive at the platform with very different amounts of context — some with a
facilitator-issued program code and a destination already decided, some browsing with no
idea what to learn, some returning to an account they already have. One undifferentiated
entry path forces all three through decisions that only apply to one of them, and loses
program attribution along the way. This project defines the single acquisition and
onboarding funnel that serves all three without that cost.

## Files

- `PRD.md` — the decision doc (Shape-Up format, 17 sections + the Prototype Element Dictionary + `## Stakeholder Review`).
- `prototype-web.html` + `styles.css` + `main.js` + `data.js` — the multi-file prototype
  source. Predates the `src/` convention in `.claude/references/design-projects.md`.
- `build-standalone.ps1` — inlines the above into `standalone.html` (gitignored,
  ~3 MB), base64-encoding `img/` and failing loudly on a missing asset.
- `prototype-web.test.ps1` — the flat reference prototype's regression suite (12 groups).
- `src/` — the current build: `onboarding.html` + `home.html` + `main.js` + `home.js` + `data.js`
  + `styles.css` + `img/`, following the `src/` convention in
  `.claude/references/design-projects.md`.
- `src/src-prototype.test.ps1` — the `src/` build's regression suite (38 checks, 8 groups). It
  exists because the flat prototype rendered a 1-day streak, 150 points, a 40% bar and
  "Welcome back!" to a seconds-old account and **no test asserted against any of it**. These
  checks make those unable to return quietly.

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
| 2026-07-29 | **Prototype split into `src/` and extended through the Learning Home.** `prototype-web.html` copied to `src/onboarding.html` with the `learning_home` screen lifted out; new `src/home.html` + `src/home.js` carry the first-run home, the first learning action, and the return. The funnel now ends by writing a handoff (name, entry path, resolved `initialCourseId`, skill total) and navigating to `home.html`, so the course is **stored at finalization** rather than recomputed at render (PRD Slice 13). Cycle 2 realized: first-run greeting (no more "Welcome back!" to a seconds-old account), `0 of N skills` with the countable condition **in the same slot**, no streak pill, no points pill, and an unmapped goal that shows an empty state instead of substituting a course. Completing the first skill returns to the same markup with real values, which demonstrates the Slice 12 rendering invariant. Verified in-browser over `localhost`: organic, program, unmapped, and returning paths all walk end to end. The four fabrications at `prototype-web.html:537-552` and the `|| 'General Skills Mastery'` fallback are gone from the `src/` build. The original flat files are left untouched as the reference. |
| 2026-07-29 | **PRD revised via `/draft-prd` against a second study.** Added `research/2026-07-28-post-signup-handoff-first-run-home` (benchmark, peer-reviewed) to `Informed by:`, and a §2.1 findings-coverage table accounting for all **16** findings across both studies (13 Adopted · 2 Deferred · 1 Contradicted). Brought the document to the current 17-section template: new §10 Users & Roles, §11 Screens/IA/Empty States, §12 Modal Reference, §13 Data Model (promoted from Appendix B); former §§10–13 renumbered to §§14–17. Added **Cycle 2** (Slices 12–13, first-run Learning Home) with its own **5–6 iteration** appetite; Cycle 1's 10–12 is unchanged. **Slice count: 12** (Slices 1–10, 12–13; Slice 11 retired into Slice 12 at review). Amended Slices 3, 5, 6, 9, 10. Recorded two departures from cited research: LR-F1 try-first **deferred** with a numeric reopen trigger (5.2 below 55%), LR-F7 the 15+ age gate **contradicted** because the product serves 13–17s. Fixed Appendix A.5, which had been instructing the build to render the fabricated progress the new §5.3 guardrail blocks release for. Stakeholder chain: PM, Tech Lead, Head of Product — **8 Go/Conditional Go, 1 No-Go** (Slice 11, merged not cut). **Principal Designer Mode S: revise**, 12 items, all applied. |
