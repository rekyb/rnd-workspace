# Research Plan: Meaningful Youth Onboarding & the Aha Moment (solve.education)

- **Status:** Draft (pending Principal Researcher review + user approval)
- **Type:** benchmark
- **Goal it serves:** Design a meaningful onboarding that gives youth (15–36) an early
  aha moment on solve.education, grounded in existing benchmark + fresh capture + literature.

## Key research questions

1. **Meaning:** What makes a first onboarding session feel *meaningful* (worth the time)
   to a 15–36-year-old learner, versus a form-filling chore? Which onboarding steps
   create ownership vs. friction?
2. **The aha moment:** What is the specific "aha" for a learning product like ours —
   the moment a learner realizes *"this can actually help me"* — and how do best-in-class
   apps engineer it inside the first session, before the signup wall?
3. **Our current drop-off:** Where and why does our live onboarding lose people? The
   funnel has **two** material drops to explain screen-by-screen: **login → profile
   (~39%)** and **course-visit → reward-visit (~22%)**. What in the actual flow explains
   each? *(Note: the v1 funnel is a **post-login** funnel — its first event is
   `login_success` — so it measures drop-off among people who already crossed the signup
   wall. It cannot measure pre-wall bounce; see the value-before-signup caveat in Q5.)*
4. **Transferable patterns:** Which onboarding mechanics (value-before-signup, guided
   first task, placement-as-value, streak/commitment) from Duolingo and the four reused
   benchmark apps can we adapt for our youth audience?
5. **Timing & psychology:** How do deferred-vs-upfront registration and the
   endowment/loss-aversion findings (from the sibling literature study) apply
   specifically to 15–36-year-olds, and where should our signup wall sit? *(The claim
   "delivering value before signup lifts activation" is framed here as a **hypothesis**
   this study grounds in benchmark + literature; our current post-login funnel data
   cannot confirm it. It is testable only after a redesign ships — captured in each
   feature's "how to validate" field.)*

## Per-platform capture plan

### solve.education (staging) — our baseline
- **Pre-capture check (required before any capture):** confirm which flow staging
  actually serves. The current funnel describes one flow; our internal activation spec
  documents a *different, redesigned* flow. If staging already serves that redesigned
  flow, it is **not** the baseline the funnel numbers describe. In that case relabel the
  capture as the *proposed* flow and source the "before" baseline from the funnel + spec +
  interview notes instead. Record which build staging runs in `notes.md` before proceeding.
- **Flows/screens to capture:** start at the **pre-login landing / value-framing screen**
  (the one the funnel can't see, and precisely where the aha thesis lives), then the
  first-run path: entry → login or register → profile step → course/first activity →
  reward step → homepage. Capture each funnel stage as a real screen so both drops can be
  tied to specific friction.
- **What we're looking for:** where the first meaningful value appears (if at all), how
  early PII/signup is demanded, whether a first "win" or aha exists before commitment,
  the concrete friction behind **both** the login→profile (~39%) and course→reward (~22%)
  drops, and a countable **time-to-value** (taps/screens/seconds to first tangible win).
- **Risks:** requires access to a live/new-visitor session (may need a test account or
  guest path from the user); **PII** on any logged-in surface must be redacted before
  capture; **age-gate** — 15+ is the *floor* of our 15–36 target so it should not block
  target users; capture the under-15 rejection state as evidence but treat it as a normal
  state, not a blocker; no payment anywhere.

### Duolingo — reuse sibling capture as basis, capture only the delta
- **Reuse first:** `research/2026-07-13-onboarding-activation-education-apps/platforms/duolingo/`
  already has a full first-run capture (flow.gif, flow.md, notes.md, screenshots). Read it
  and cite it as the basis — do **not** re-capture the whole first-run from scratch.
- **Fresh capture — only the delta this study needs:** the precise **time-to-first-win
  sequencing** (taps/screens/seconds to the first tangible win) and **exactly where the
  signup ask lands** relative to that win. Capture only what the sibling didn't already
  pin down.
- **What we're looking for:** how fast a learner reaches a first tangible win, how the aha
  is staged, and how signup is deferred until after value is felt.
- **Risks:** web vs. app onboarding differs (note which we capture); Duolingo may push a
  signup/paywall — **free tier only, never pay**; capture publicly observable free flow,
  note anything gated in `notes.md`.

### Reused as basis (no new capture)
- **Brilliant, Datacamp, Busuu, Khan Academy** — pull the onboarding/activation-relevant
  feature write-ups from the prior 4-platform benchmark dataset (internal) and cite them in
  synthesis. No browser capture; treat that dataset as the evidence.

## Literature lens (light)

A focused review to ground *why* the patterns work for youth. The review is **written up
first** into a `lit-review.md` / notes section during the study, so the Principal
Researcher's synthesis-QA step validates *drafted* claims against cited sources (logged in
`references.md`) rather than claims invented at synthesis time. Topics:
- Self-determination theory (autonomy, competence, relatedness) in youth motivation.
- "Time-to-value" / activation "aha moment" theory in product onboarding.
- Deferred vs. upfront registration and psychological ownership (endowment / loss
  aversion) — **reuse and extend** the sibling study
  `2026-07-16-indonesian-teacher-onboarding-literature`, re-reading its findings for the
  youth (not teacher) audience rather than re-deriving them.

## Success criteria (what "done" looks like)

- Each of the 5 research questions answered with cited evidence (live capture, the reused
  benchmark dataset, and/or literature) — no unsupported claims. The value-before-signup claim
  is stated as a hypothesis with a defined post-redesign test, not as a proven result.
- Our current onboarding captured screen-by-screen and **both** funnel drops (login→profile
  ~39% and course→reward ~22%) mapped to a specific, named friction cause each.
- A countable **time-to-value** (taps/screens/seconds to first tangible win) reported for
  our flow and for Duolingo, so the comparison is concrete rather than narrative.
- A concrete, **named aha moment** (or a small ranked set) defined for solve.education's
  onboarding, each with the design mechanic that triggers it and the platform precedent
  it draws from.
- Synthesis written in the benchmark feature-write-up format (5 required fields each),
  PII-safe and confidentiality-safe (see below), ready for `/review-research`.

## Confidentiality & publish safety

Decided at plan time, not at publish time:
- The study **subject is our own product**, so committed prose must respect repo
  confidentiality: keep funnel figures **directional (percentages, not raw counts)** in any
  committed synthesis, and follow repo policy on internal product/metric naming.
- Working notes may hold the raw numbers; the raw-data folder is gitignored.
- **Decision (user, 2026-07-17): this study will be PUBLISHED to GitHub.** Therefore in
  committed prose: funnel figures stay **directional (percentages, not raw counts)**;
  internal program / funder / partner names, ticket IDs, and roadmap detail are kept out
  (per repo confidentiality); PII in captures is redacted before saving. The public
  product/staging URL (`staging.solve.education`) is the acknowledged study subject and
  may be named. Capture target: **whatever the public staging entry shows** (no test
  account).

## Principal Researcher review

**Mode A review — 2026-07-17.** Verdict on first draft: *Plan needs revision* (5 must-fixes).
All five applied in this revision:
1. **Post-login funnel acknowledged.** Q3 now states the v1 funnel is post-login; Q5 reframes
   value-before-signup as a hypothesis the current data can't confirm (testable post-redesign).
2. **Both drops mapped.** Q3 + success criteria now cover the course→reward (~22%) drop, not
   only login→profile (~39%).
3. **Duolingo reuse.** Plan now reuses the sibling's existing Duolingo capture as the basis and
   captures only the time-to-value / signup-placement delta.
4. **Staging pre-capture check added.** Verify whether staging runs the current funnel flow or
   the internally-documented redesign; relabel the capture if it's the redesign.
5. **Confidentiality resolved at plan time.** New subsection: directional figures in committed
   prose, internal-only-vs-published flagged for user confirmation.

Should-fixes also folded in: countable time-to-value, pre-login landing capture, literature
written to `lit-review.md` before synthesis, age-gate treated as a normal state (15+ is the
target floor).

_Status after revision: awaiting user approval before capture begins._
