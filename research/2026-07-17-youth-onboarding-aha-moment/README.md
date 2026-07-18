# Research: Meaningful Youth Onboarding & the Aha Moment (solve.education)

- **Status:** Closed
- **Type:** benchmark
- **Started:** 2026-07-17
- **Closed:** 2026-07-18
- **Researcher:** Claude (acting Senior UI/UX Designer)

## Goal

Design a **meaningful onboarding** for the solve.education platform
(<https://staging.solve.education/>) that delivers an early **aha moment** to youth
learners aged **15–36**, so that first-time visitors feel value *before* they commit,
rather than treating onboarding as a form-filling chore.

This is **observation + literature feeding a build decision.** The synthesis directly
informs how we redesign our own onboarding. The guiding question:

> *What makes the first session feel meaningful to a 15–36-year-old learner, where is
> the "aha" that convinces them this product is worth their time, and how do we
> engineer that moment before the signup wall?*

The study leans on **existing research as its basis** (a prior 4-platform benchmark from
internal working data, plus two closed sibling studies) and adds only the fresh evidence that
gap needs: a capture of our **current live onboarding** and of **Duolingo's** first-run,
plus a youth-motivation / aha-moment literature layer.

## Scope

**In scope**
- Our current onboarding funnel on staging (new visitor → profile → course → reward →
  homepage), captured live as the "before" baseline.
- Duolingo's first-run onboarding (fresh light capture), focused on time-to-value and
  the first aha.
- Reuse of the existing benchmark of **Brilliant, Datacamp, Busuu, Khan Academy**
  (from the prior 4-platform benchmark dataset, internal) as the pattern basis — no new
  capture of those four.
- A literature lens on youth motivation (self-determination theory, time-to-value,
  the activation "aha"), building on the deferred-registration / endowment-effect
  findings from the sibling literature study.
- A design-ready synthesis: named aha moment(s) + the onboarding mechanics that trigger
  them, mapped against our funnel drop-off.

**Out of scope**
- Live participant recruiting or moderated usability testing (this is desk research).
- Post-activation learning loops (S2+), the job-seeker flow, real auth/backend.
- Paying for, upgrading, or trialing any benchmarked platform (see Guardrails).
- Re-benchmarking the four apps already covered in the prior benchmark dataset.

## Platforms to benchmark

- [x] **solve.education (staging)** — current onboarding captured live 2026-07-17
      (landing → age gate → signup wall; wall-first, no pre-signup value).
- [x] **Duolingo** — delta captured 2026-07-17 (time-to-first-win + deferred signup);
      full flow reused from sibling `2026-07-13`.
- [x] **Brilliant, Datacamp, Busuu, Khan Academy** — reused from the prior benchmark
      dataset (basis, no new capture).

## Evidence base (existing research reused)

*(Internal working data below is held in the gitignored `raw-data/` folder and is not
committed; only its directional findings are referenced here.)*

- Prior 4-platform onboarding/loop benchmark dataset (internal).
- Our documented internal activation flow spec.
- Current live onboarding-funnel data (internal): **~39% drop at the first step** (figures
  kept directional per repo confidentiality).
- Learner interview notes (internal) — pain points (e.g. "Start Now" read as an ad;
  Grade-7s needed 1:1 guidance).
- `research/2026-07-13-onboarding-activation-education-apps/` — sibling benchmark +
  activation model (`goal → level → profile → path`).
- `research/2026-07-16-indonesian-teacher-onboarding-literature/` — registration-timing
  and psychological-ownership literature.
- `research/PATTERNS.md` — cross-study reusable UX pattern library.

## Log

- 2026-07-17 — research created (type: benchmark). Scope locked with user: reuse
  existing benchmark + fresh Duolingo capture; capture current staging flow as
  baseline; drive to synthesis first.
- 2026-07-17 — PLAN approved after Principal Researcher (Mode A) review (5 must-fixes
  applied). Confidentiality: study will be published; figures kept directional.
- 2026-07-17 — Captured staging baseline (landing → age gate → signup wall) and the
  Duolingo first-win delta. Key finding: staging onboarding is wall-first with no
  pre-signup value/aha; Duolingo reaches a guaranteed first win before the signup ask.
  Ready for `/synth-findings`.
- 2026-07-17 — SYNTHESIS.md written (benchmark; 6 onboarding features, 5 fields each, with
  embedded captures + a named aha moment + a recommended re-ordered flow). Principal
  Researcher QA (Mode B) ran: 0 AI-slop, 19 em-dashes removed, 4 rationales validated
  against cited external research (references.md created), 0 contradictions, 5 content
  items flagged. All 5 flags resolved post-QA (grounding/citation fixes + age-floor
  reconciliation). Ready for `/review-research`.
- 2026-07-17 — Peer review recorded (`## Peer Review`). Panel debate (Skeptic, Domain
  Expert, Evidence Auditor; moderated by Principal Researcher, Mode C). Verdict: 1 Robust
  (F4), 5 Strengthen (F1, F2, F3, F5, F6), 0 Unsupported. 14 strengthening actions
  (A1–A14) applied on user approval; ~10 new citations folded into references.md (with
  verification caveats). Load-bearing reframe: F2's aha downgraded from asserted to a
  *hypothesized winnable-yet-credible* first slice (score = proof not test; F4 scaffolding
  a hard precondition), and the winnable×credible×ownership-worthy trilemma named as the
  central open design risk. Synthesis is review-strengthened; optional next steps:
  `/draft-spec` or `/design-prototype`.
- 2026-07-17 — SPEC.md drafted (`/draft-spec`), incorporating the internal onboarding product
  direction (a self-serve career-discovery taste-builder + the internal learn-to-hire loop
  spec's rubric/no-pass-fail scored slice). Discovery-first, self-serve only (a facilitator/
  program-entry mode was considered and left out of scope). The internal direction *resolved*
  the peer review's central open risk (winnable-yet-credible trilemma): no-fail taste-builder
  aha + rubric/revise scored slice. Stakeholder review (PM → Tech Lead → Head of Product):
  **Conditional Go** — FR-15 promoted to Must, FR-03 split, Gate-0 pre-build blockers (legal
  sign-off on pre-consent minor data + engine confirmation + guest-identity spike). Principal
  Designer Mode S: **revise → 3 fixes applied → ready.** PII check clean.
- 2026-07-17 — Clickable HTML prototype (`/design-prototype`, hi-fi) built for the v1
  discovery flow and published as a claude.ai Artifact (updated in place):
  <https://claude.ai/code/artifact/76aa0ef8-2a47-4c25-9d22-81fe6aa8ad0a>. 7 screens
  (Landing → fork → taste-builder → plan/aha → rubric-scored slice → ownership signup +
  age gate → home), flow-map rail with screen→FR traceability, DoD table (G1–G7 pass, G8
  partial by design — engines mocked), assumptions panel. Design: dark brand-committed
  product device + gold-only CTA, theme-aware page, SVG icons, no emoji. Principal Designer
  Mode T: **revise → 1 blocker fixed (low-confidence plan now reachable) → ready.** PII
  clean; sign-in simulated; pay indicative with a live "unavailable" state.
- 2026-07-18 — **Research closed** (`/close-research`). Principal Designer (Mode P) harvested
  the study's reusable patterns into `research/PATTERNS.md`: **3 new entries** (pre-signup
  scored "aha" slice as proof-not-test [untested hypothesis]; the winnable × credible-as-proof
  × ownership-worthy *trilemma* [design tension]; reposition the age/DOB gate to the point of
  persistence) and **3 enrichments** (deferred try-first registration + solve staging wall-first
  instance; assessment-as-onboarding sharpened to proof-not-test + scaffolded; three-stage
  sequencing + solve counter-instance). No contradictions. Removed from the active registry.
