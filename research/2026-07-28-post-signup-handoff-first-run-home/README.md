# Research: Post-Signup Handoff to the First-Run Learning Home

- **Status:** Active
- **Type:** benchmark
- **Started:** 2026-07-28
- **Researcher:** Claude (acting Senior UI/UX Designer)

*No `Coverage:` line yet, by design. Per `docs/superpowers/specs/2026-07-29-coverage-gates-design.md`
§4.4, an active study is not backfilled: it gets its real verdict when `/close-research` runs, derived
from the `## Research questions — coverage` table in `SYNTHESIS.md`. That table reads
**Q2,Q3,Q5 answered · Q1,Q4 partial · Q6 unanswered**.*

## Goal

Benchmark how leading **web** education platforms design the segment that begins the
moment an account is successfully created and ends at the learner's **first real
learning action** — the handoff itself, the first-run state of the authenticated home,
and how the pre-signup intake pays off on that surface.

This is **observation feeding a build decision.** The synthesis directly informs
`design/onboarding-solve-edu`, whose `PRD.md` currently declares this exact territory
out of scope: §7.4 calls Learning Home "included only as the verified handoff," §10
lists "Full Learning Home/dashboard implementation" as a non-goal, and Slice 9 is a
greeting plus one CTA. The prototype reflects that — `learning_home` ships a hard-coded
1-day streak (`prototype-web.html:538`) and a hard-coded 150-point total (`:541`), both
fabricated progress for a learner who has none.

The guiding question:

> *When a learner has just committed — account created, intake spent — what does the
> product owe them in the first thirty seconds, and how does a home surface with
> genuinely zero progress still feel like a beginning rather than an empty shell?*

## Relationship to prior studies

Four prior studies touch this territory, and this study is honest about which of its
questions are new ground and which are narrowed residuals:

- **`2026-07-13-onboarding-activation-education-apps`**, **`2026-07-17-youth-onboarding-aha-moment`**,
  and **`2026-07-20-unified-onboarding-synthesis-and-patterns`** settle the funnel
  **before** the account wall. This study starts where they stop.
- **`2026-07-17-certificate-vs-badge-gamification`** settles which gamification mechanics
  suit this audience and how they work, and holds the repo's only first-party capture of a
  near-first-run home surface.

**New ground:** the handoff composition (Q1), the zero state of non-gamification home
surfaces (Q2), and intake payoff on the home (Q3).

**Narrowed residuals** of patterns already in `research/PATTERNS.md`: the first action's
zero-state composition (Q4), which gamification mechanics render before the first earn
(Q5), and whether cohort context persists to the home after enrolment (Q6).

## Scope

**In scope**

- The post-authentication handoff: what screen, if any, stands between account creation
  and the home rendering, and what it contains.
- The **first-run** authenticated home at genuine zero state — no completed lessons, no
  streak, no history.
- How pre-signup intake (goal, role, interest, level) is reflected back on the home.
- The first learning action: what it is, how dominant, how many clicks from arrival.
- Which gamification affordances render before anything has been earned, and in what
  visual register.
- The **cohort/class-code** variant of the same handoff, as the direct analogue of our
  facilitator-issued program-code path.
- Web viewport only.

**Out of scope**

- Anything before the account wall — entry, intake, goal selection, the wall itself.
- **Timing and motion of the handoff.** Library stills cannot show them; the question is
  deferred to validation rather than guessed at. See `PLAN.md` Risks.
- The steady-state home once progress exists, except as the contrast case that shows what
  the empty state grows into.
- Lesson-player interior, course catalogue, assessment design, certificates.
- Native iOS and Android. Web only, per the study brief.
- Recommendation-algorithm quality. We study what the surface *claims*, not how it was
  computed.

## Platforms to benchmark

- [x] **Duolingo** — *primary* — free, youth-facing, teacher-issued class code; "Creating a
      profile" + "Joining a classroom" (Mobbin)
- [x] **Uxcel** — the most explicit first-run empty state and getting-started checklist (Mobbin)
- [x] **Coursera** — intake payoff on the home, and the catalogue-merchandising counter-case (Mobbin)
- [x] **Brilliant** — single recommended next unit and zero-value counters (Mobbin)
- [x] **Babbel** — added after review for audience fit; matched zero/populated pair (Mobbin)
- [x] ~~Unity Learn~~ — cut for audience fit
- [x] **Khan Academy** — C2 → Chrome. **Captured 2026-07-29** on a genuine new *student*
      account, superseding the 2026-07-28 teacher-account attempt that was abandoned unsaved.
- [x] **CodeSignal** — C2 → Chrome. **Captured 2026-07-29**; user-requested addition, weakest
      audience fit, caveat carried on every finding.
- [ ] **Preply** — *optional, not captured* — locked-award grid; Q5 did not stay thin, so not needed.

## Log

- 2026-07-28 — research created (type: benchmark).
- 2026-07-28 — plan reviewed by the Principal Researcher (verdict: needs revision, ten
  must-fixes); plan revised and platform set rebuilt for audience fit.
- 2026-07-28 — plan approved; capture began.
- 2026-07-28 — **Duolingo captured** (8 screens, 2 flows): `references.md`, `flow.md`,
  `notes.md` written. Two blocking gaps recorded — the captured flow's terminal home is a
  progressed account, not a zero state (Q2), and the classroom flow ends before the home
  (Q6). Both need a `search_screens` pass per the plan's fallback.
- 2026-07-28 — **Uxcel captured** (5 screens, 1 flow): a matched zero-state / one-day pair of
  the same home. **Q2 answered decisively**, Q5 well, Q4 as a counter-case.
- 2026-07-28 — **Chrome plan downgraded.** Uxcel supplies a genuine, well-documented zero
  state from the library, so first-party capture is no longer the only route to Q2. The C3
  Chrome pass becomes *corroboration* on the two platforms whose captures show only
  progressed accounts (Duolingo, Brilliant), not a prerequisite. Trigger stays valid; the
  scope shrinks.
- 2026-07-28 — **Brilliant captured** (7 screens, 2 flows). **Q1 answered decisively** — a
  four-screen handoff, not a direct drop. Second sighting of the slot rule (Q2/Q5), and the
  control case that resolves the Q4 tension Uxcel opened.
- 2026-07-28 — **C2 confirmed for Khan Academy and CodeSignal**: neither has any Mobbin web
  coverage, verified by dedicated named searches logged in `sources.md`. Both move to Chrome.
  CodeSignal added at user request, with a recorded audience-fit caveat.
- 2026-07-28 — **Babbel captured** (3 screens). Third matched pair; contributes the
  default-destination-plus-optional-placement pattern and a useful counter-instance (a zero
  streak with no stated unlock condition).
- 2026-07-28 — **Coursera captured** (2 screens). Best handoff form in the study (in-place
  skeleton on the destination), the clearest intake-payoff instance *and* its most
  instructive failure — goal echoed, content not goal-derived.
- **Mobbin capture complete: 5 platforms.** Q1, Q2, Q4, Q5 answered across ≥2 platforms each;
  Q3 answered by Coursera with Brilliant as a second mechanism.
- 2026-07-29 — **CodeSignal captured** (Chrome, C2; 11 screenshots + `flow.gif`). Conversational
  LLM intake resolving to a named path, and a home that discards it. Contributes the study's only
  instance of a first-run slot **reassigned to promotion** (*My Learning* at zero state is an
  app advertisement), a second counter-instance to the countable unlock condition (`0 days`, no
  condition), and a refinement of the single-next-step axis. **Q1 not answered** — account
  creation was not observed.
- 2026-07-29 — **Khan Academy captured** (Chrome, C2; 10 screenshots + `flow.gif`) on a genuine
  new **student** account, resolving the blocker recorded on 2026-07-28. The study's most
  complete first-party zero state (`0 /1 skill` with a denominator), the top rung of the
  intake-payoff ladder (the chosen courses *are* the home), and the cardinality reading of the
  single-next-step axis. **Q1 not answered** — account creation was not observed.
- **Capture complete: 7 platforms** (5 Mobbin + 2 Chrome).
- 2026-07-29 — **`SYNTHESIS.md` written** (type: benchmark; **8 feature entries**, each with the
  five required fields, plus `## Gaps & caveats`).
- 2026-07-29 — **Principal Researcher QA pass (Mode B) run.** Verdict **revise**, with **13**
  flagged items: 4 evidence/citation, 5 labelling/completeness, 4 rationale-versus-literature.
  Prose auto-fixes applied: 95 em-dashes removed across 43 edits, 8 Mobbin citation labels
  reformatted, no URL altered, 0 AI-slop rewrites needed. Citation integrity verified: all 7
  embedded images resolve on disk and are first-party Chrome captures; zero Mobbin `reference/`
  paths embedded. A study-root `references.md` was created with **10 external sources (R1–R10)**
  validating the feature rationales.
- 2026-07-29 — **All 13 flagged items resolved**, recorded in `SYNTHESIS.md`
  `## Resolutions applied`. Two resolutions changed substance rather than wording: the uncited
  Brilliant age-tooltip claim was **dropped**, and Feature 7's appetite read (3 to 4 iterations
  against an appetite of 10 to 12) **reversed its recommendation** from building a join-later
  surface to recording it as an explicit deferred non-goal. One QA item is left open by design:
  `PLAN.md`'s "`references.md` in every platform folder" criterion predates the Chrome additions
  and should be restated per source type, which is a plan amendment for the panel rather than a
  unilateral edit.
- 2026-07-29 — **Peer review recorded** (`## Peer Review`). Three chained panelists (Skeptic,
  Domain Expert, Evidence Auditor) moderated by the Principal Researcher in Mode C. All three
  returned **revise**; none called for new capture. Verdicts: **1 Robust, 8 Strengthen, 1
  sub-claim Unsupported**. **All 36 actions approved and applied.**
  - **Withdrawn:** Feature 4's three-part intake-cardinality rule, routed to `## Gaps & caveats`
    as an open question. Its operative sentence was false against the study's own screen (Khan
    Academy allowed 43 courses, gated at 1, and showed 3 because 3 were selected), and corrected
    to "selected" it became a restatement rather than a mechanism.
  - **Promoted:** **Feature 9**, the pre-home instrumentation finding (four tour steps stacked
    over a two-step blocking modal, six screens before a usable home). Already analysed in
    `khan-academy/notes.md` Observation 4 with no feature carrying it, and the study's only
    first-party measurement bearing on Q4's "clicks from arrival".
  - **Rebuilt:** Feature 4 now rests on a cold-start reading (a behavioural ranker is empty at
    first run by construction, so the primary action must come from stored intake), grounded in a
    flow record the withdrawn rule never cited.
  - **Recalibrated:** four headline counts restated as observations rather than platforms; the
    Feature 7 appetite estimate attributed as a researcher number because it reversed a
    recommendation; Feature 2's gamification implication split into ship (`0 /1 skill`) and hold
    (locked leaderboard) on motivational and cross-cultural grounds.
  - **References:** R11 to R19 added (9 sources) with per-row retrieval-quality notes; a
    non-retrieval on Indonesian child-consent recorded as a named Legal/Privacy question rather
    than a citation.
  - **Plan amended:** success criterion 3 restated per source type, resolving the Mobbin-only
    assumption that predated the two Chrome platforms.
  - Three new `## Gaps & caveats` entries: conditions of use, facilitator co-present use, and the
    second-visit gap. Next: `/close-research`.

**Two capture-standard deviations recorded on the Chrome platforms**, both documented in the
relevant `flow.md`: CodeSignal screens 01–06 needed injected CSS because the app clips its own
footer below ~576px of viewport height; Khan Academy's `flow.gif` is a **slideshow assembled
from the committed stills**, not a screen recording, because the flow was driven with
programmatic clicks and its modals cannot be re-walked once answered.
