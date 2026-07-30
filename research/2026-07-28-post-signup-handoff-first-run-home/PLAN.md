# Research Plan: Post-Signup Handoff to the First-Run Learning Home

- **Status:** **Approved 2026-07-28** — capture in progress
- **Type:** benchmark
- **Goal it serves:** Specify the segment from account creation to first learning action,
  so `design/onboarding-solve-edu` can extend past the Learning Home boundary its PRD
  currently declares out of scope.

## What is new ground, and what is a residual

Four prior studies touch this territory. Being precise about the boundary is what keeps
this study from re-deriving them:

| Q# | Question | Standing | Answerable? |
|---|---|---|---|
| Q1 | The handoff composition | **New ground** | `Partial` — stills cannot show timing or motion, so composition and sequence only (see Risks) |
| Q2 | Zero state of non-gamification surfaces | **New ground** | `Yes` |
| Q3 | Intake payoff on the home | **New ground** | `Yes` |
| Q4 | The first action | **Residual** — principle settled, composition open | `Yes` |
| Q5 | Zero-state gamification | **Residual** — mechanics settled, render-before-earn open | `Yes` |
| Q6 | The cohort variant | **Residual** — routing settled, post-enrolment home open | `No` — deferred to a moderated usability session on our own prototype (see *Question 6* below) |

> **`Answerable?` column added 2026-07-29** as a coverage-contract retrofit; the study was planned
> before that vocabulary existed. Each value is taken from what this plan already committed to in
> prose, not from hindsight: Q1's `Partial` restates the Risks section's timing exclusion, and Q6's
> `No` restates the *Question 6 — resolved as a gap* decision below. Q4 was planned as `Yes` and
> came back `Partial` at synthesis, which is a permitted downgrade and is explained in the
> synthesis coverage table.

## Key research questions

1. **The handoff.** What screen, if any, stands between the account-creation submit and
   the home, and what does it contain — a confirmation, a celebration, a setup checklist,
   a forced first action, or nothing at all? *Composition and sequence only; timing and
   motion are explicitly out (see Risks).*
2. **The zero state of the non-gamification home.** For the course list, recommendation
   slot, activity/history, and any getting-started checklist: which are hidden entirely,
   which show an empty frame with a recovery action, and which are present but unpopulated?
   *(Gamification widgets belong to Q5, not here.)*
3. **Intake payoff.** Is the pre-signup signal (goal, role, interest, level) visibly
   reflected on the home — named back to the learner, used to pick content, or silently
   consumed? Is it editable from the home, and how is that framed?
4. **The first action — composition residual.** `PATTERNS.md` already establishes *Single
   recommended next step (goal → first meaningful action)* and the "route into practice,
   not into another browse surface" clause. Open: at zero state, how **visually dominant**
   is that action, how many **clicks from arrival**, and is it genuinely singular or a menu
   wearing a primary button?
5. **Zero-state gamification — render residual.** `2026-07-17-certificate-vs-badge-gamification`
   settles which mechanics suit this audience and how they work. Open: which mechanics are
   **rendered at all before the first earn**, and in what **visual register** — suppressed,
   locked with an unlock condition stated, or shown at zero.
6. **The cohort variant — post-enrolment residual.** `2026-07-13` Feature 6 and the
   `PATTERNS.md` entry *Code-first, chrome-free linked entry to assigned content* settle
   routing and attribution. Open: after the join succeeds, does **program identity,
   facilitator, and cohort stay visible on the home**, and how do assigned tasks sit
   against generic content?

## Sourcing decision

**Split source, revised 2026-07-28 after the Duolingo capture.** Mobbin remains the source
for flow structure and composition; **Claude-in-Chrome is used for the zero-state home
under trigger C3**.

### Why the split — what the Duolingo capture proved

The first Mobbin capture failed to answer the study's two most decision-relevant questions,
and it failed the same way twice: both flows terminated on a home belonging to a *progressed*
account (10-day streak, 505 gems, Section 2), and the classroom flow stopped before the home
entirely.

That is **structural, not bad luck**. A Mobbin flow is a curated journey walked by a
capturer whose account already has history. A genuine first-run home is not a step in a
journey — it exists only in the moments after a real account is created. No amount of
further library search reliably produces it.

### C3 trigger — recorded per `.claude/references/mobbin-sourcing.md`

> **C3 — The question needs live behaviour** — validation response, error states, timing,
> "what the system does". *Stills cannot demonstrate system response.*

**Applies to:** questions 2 and 5 (the zero state of the home, and which gamification
mechanics render before the first earn) on all four platforms.

**Reasoning:** the zero state is a *product state*, reachable only by holding a
newly-created account. Library snapshots do not contain it, and inferring it from a
progressed home would be exactly the fabrication this study exists to design away. Chrome
capture also upgrades these findings from *reference-library observed* to **first-party
captured**, which matters for the evidence that will drive Slice 9.

**Does not apply to:** questions 1, 3, 4, and 6, which remain Mobbin-sourced. Question 1
stays composition-only, so timing is still out of scope for the evidence (see Risks).

### Question 6 — resolved as a gap, not a Chrome capture

Reaching a post-enrolment cohort home requires a real teacher-issued class code, obtainable
only by standing up our own teacher and learner accounts. **Decided 2026-07-28: not worth
the setup.** Q6 is a narrowed residual — routing and attribution are already settled by
`2026-07-13` and `PATTERNS.md` — and its open part is a *composition* question we can answer
faster by prototyping two versions of our own program home and testing them. Q6 therefore
becomes a `## Gaps & caveats` entry in the synthesis, naming a **usability session on our own
prototype** as the validation route.

### C2 trigger — Khan Academy and CodeSignal (added 2026-07-28)

> **C2 — Mobbin has no coverage of the platform.** *Verified by search, not assumed.*

**Khan Academy** was named explicitly in three separate Mobbin web queries across 2026-07-28
and returned **zero** results every time. **CodeSignal** was named explicitly in a dedicated
query and returned zero results. Both null searches are logged verbatim in `sources.md` with
their query text, so the determination is auditable.

Both platforms therefore move to **Claude-in-Chrome** capture. This supersedes the earlier
C3-corroboration rationale as the *primary* reason Chrome is in this study: for these two
platforms there is no library alternative at all.

**CodeSignal is a user-requested addition** to the plan, not a reviewer recommendation. Its
audience fit is the weakest in the set — a technical-assessment platform for professional
developers, the same objection that cut Unity Learn at plan stage. It is captured as
requested; its findings carry a heavy audience-transfer caveat and should not outweigh
Duolingo or Babbel on any question about young or low-context learners.

**Captured 2026-07-29.** The caveat is carried on every finding in its `notes.md`. One capture
deviation is recorded in its `flow.md`: at the available viewport the app clips its own footer
CTA (`h-dvh` with an `overflow-hidden` child, below roughly 576px of height), so onboarding
screens 01–06 were captured with that container expanded via injected CSS. The home screens are
native.

**Babbel — candidate, not yet captured.** Surfaced unprompted during the 2026-07-28 searches
with an explicit zero-state message ("Start learning to see your progress here.") beside a
level-finding prompt. Free-tier consumer language learning, so materially better audience fit
than Uxcel or CodeSignal, and fully Mobbin-covered — no account, no Chrome. Recommended as the
next capture.

### Account creation — a boundary, not a step

Chrome capture of Khan Academy and CodeSignal requires authenticated accounts. **Account
creation is performed by the user, never by the assistant**, and no password is entered on
their behalf. The capture picks up from an already-authenticated session.

### Guardrails now live

Chrome capture with real accounts activates two rules that Mobbin sourcing did not:

- **Redact before capture.** A `window.__redact()` helper blurs avatars and masks name and
  email slots **by role and position, not by known string**, re-applied after every
  navigation and re-render, and verified in each captured image before it is saved.
- **No payment, ever.** Duolingo, Uxcel, and Brilliant all surface upgrade prompts from the
  home. They are observed and noted as part of the composition; none is transacted. No
  trial, no upgrade, no card.

## Per-platform capture plan

Each block separates what was **observed while scouting** (to be re-verified and cited
from `references.md` during capture, never carried into the synthesis on the strength of
this plan) from **what the capture tests** (left genuinely open).

### Duolingo — primary

- **Source:** mobbin
- **Flows:** "Creating a profile" (8 screens, `65ea5f1c`), "Joining a classroom"
  (5 screens, `a5ac043e`). Secondary if needed: "Creating a profile" 6-screen variant
  (`eff5c764`).
- **Why it leads the set:** the only platform here that is free, youth-facing, and runs a
  **teacher-issued class code** — the three attributes our PRD's audience actually has.
- **Observed while scouting:** deferred registration ("Time to create a profile!" with
  CREATE A PROFILE / LATER); a post-signup home carrying a unit path with a START node, an
  "Unlock Leaderboards! Complete 9 more lessons to start competing" panel, a "Daily Quests
  / Earn 20 XP / 0 20" progress bar, and a streak, gem, and hearts row. The classroom flow
  shows a six-character code field, a distinct invalid-code error state ("This code does
  not match any classroom"), and a confirmation modal naming the teacher and class and
  stating what the teacher will be able to do.
- **What the capture tests:** Q1, Q2, Q4, Q5, and — via the classroom flow — Q6. The
  confirmation modal is the sharpest available evidence on whether cohort context is
  *stated at join* and whether it *persists to the home*.
- **Risks:** the account in these captures already carries gems and a streak, so it may be
  a seeded rather than a true first-run state. Flag any screen whose zero-ness is ambiguous
  rather than asserting it.

### Uxcel

- **Source:** mobbin
- **Flows:** "Home" (7 screens, `67d21fa1`), "Onboarding" tail (19 screens, `ed454331`).
- **Observed while scouting:** a home showing "You don't have any active courses" beside a
  Browse courses button; a "Getting started (0/4)" checklist naming first actions; a
  "Start your learning streak" panel; a league panel stating an XP threshold. A second,
  populated home screen shows the same slots filled.
- **What the capture tests:** Q2 primarily — this is the most explicit empty-state
  vocabulary in the set, and the empty/populated pair is the clearest available read on
  which slots persist versus appear. Also Q5 and Q3.
- **Risks:** UX-professional audience on paid tiers; upgrade prompts are part of the
  observed composition and stay in the record rather than being edited out. **No payment,
  no upgrade, no trial** — the guardrail is live here.
- **Note:** its "Accepting an invite" flow is **dropped**. A seat invite into a B2B design
  team is a different mechanic from a facilitator-issued cohort code, and the first draft
  overstated it as "the closest analogue." Duolingo's classroom join is the real analogue.

### Coursera

- **Source:** mobbin
- **Flows:** "Onboarding" tail (17 screens, `db5898b3`), "Home" (5 screens, `53a2e3cc`).
- **Observed while scouting:** a four-step intake (goal → roles → … → education level)
  followed by a home carrying a banner that restates the chosen goal with an inline Edit
  goal link, above catalogue rails.
- **What the capture tests:** Q3 primarily — the clearest intake-payoff instance available.
  Also Q4 as a deliberate **counter-case**: a home organised around catalogue merchandising
  rather than a single next action, which is the failure mode Slice 9 should avoid.
- **Risks:** marketplace discovery is a different product problem from assigned or
  goal-directed learning. Keep comparisons structural; do not read surface count as intent.

### Brilliant

- **Source:** mobbin
- **Flows:** "Onboarding" (12 screens, `38a82b93`).
- **Observed while scouting:** a path map shown before the home; a home with one
  recommended unit and a single Start button, a "Solve 3 problems to start a streak" panel,
  and zero-value XP and streak counters.
- **What the capture tests:** Q4 and Q5. The path-map-before-home sequence is also a Q1
  candidate — an interstitial that pre-frames the destination.
- **Risks:** benchmarked in `2026-07-13` for the **pre-signup** funnel. Continuation, not
  duplication — but every Brilliant claim must name which study it comes from.

### Dropped and contingent

- **Unity Learn — cut.** Professional developer academy; weakest audience fit in a set that
  already skewed Western and professional. Its one contribution (an unsoftened
  0 Completed / 0 XP / 0 Badges row) is covered by Duolingo and Brilliant.
- **Khan Academy — contingent, and the contingency fired.** Free, youth-facing, genuine
  class-code cohorts, and `2026-07-13`'s first-party captures stop at the un-routed catalogue,
  so its post-join home is exactly where that study stopped. It did not appear in **three**
  named searches on 2026-07-28, so **C2** was invoked and it moved to Chrome.
  **Captured 2026-07-29** on a genuine new **student** account. The 2026-07-28 attempt was
  abandoned — the only account available then was a **teacher** account, whose learner side
  would have been contaminated evidence regardless of redaction quality, and **nothing was
  saved**. The user subsequently created a student account, which is what this capture uses.
  Q6 remains unanswered by design: reaching a post-enrolment cohort home still needs a real
  teacher-issued class code, and the learner sidebar's **Teachers** item was **not** explored.
- **Preply — optional.** Surfaced while scouting with a pre-first-lesson checklist and an
  "Awards 1/14" grid of locked achievements. A tutoring marketplace, so audience fit is
  poor, but the locked-award grid is a clean Q5 data point if that question stays thin.

## Success criteria (what "done" looks like)

- Questions 1–5 are answered with evidence from **at least two** platforms. **Question 6
  is single-source by construction** (Duolingo's classroom join is the only true cohort
  flow in the set) — its findings must be **labelled single-source** in the synthesis, and
  the Khan Academy contingency above is the remedy if that proves too thin.
- Every platform folder carries `flow.md` and `notes.md`, plus the citation artefact for its
  **source type**:
  - **Mobbin-sourced** platforms carry `references.md`, with every image in the gitignored
    `reference/` folder matched by a `references.md` row.
  - **Chrome-sourced** platforms carry a committed `screenshots/` folder and a row per surface in
    the study-level `sources.md`.

  > **Amended 2026-07-29, after peer review.** This criterion originally read: *"Every platform
  > folder carries `references.md`, `flow.md`, and `notes.md`, with every image in `reference/`
  > matched by a `references.md` row."* That was written when the platform set was Mobbin-only.
  > When Khan Academy and CodeSignal were added under trigger C2 they correctly followed the
  > first-party capture standard instead, so the criterion read as unmet against two platforms
  > that had done the right thing. All three peer-review panelists and the moderator judged this
  > a **plan defect rather than a capture defect**, with no finding affected. Restated here per
  > source type.
- Every `flow.md` system-response claim is explicitly marked **inferred from screen
  sequence** — none asserts observed behaviour.
- **Any question not answerable from the captures gets an explicit `## Gaps & caveats`
  entry naming the validation method that would answer it.** An unanswered question is a
  recorded result, never a quiet omission.
- Every finding is phrased as **one observed variant of a library snapshot accessed
  2026-07-28**, not as the product's current behaviour. Onboarding and home surfaces are
  heavily A/B tested; `PATTERNS.md` already carries this caveat for the 2026-07-13 captures.
- The synthesis names, for each finding, what it implies for `PRD.md` §7.4, §10, and
  Slice 9 — **in both directions**: which non-goals it argues to move **in** scope, and
  which should **stay** non-goals. §6 bounds this work at 10–12 iterations with a kill
  threshold at 15, so each finding carries a rough appetite read. A benchmark that only
  argues for expansion cannot settle a scope decision that was made on appetite grounds.
- Findings route to the owners `PRD.md` §11 already names rather than rediscovering their
  decisions: Q3 belongs to the open "canonical goal taxonomy and goal-to-first-course map"
  decision (Content + Product), and Q2 sharpens or challenges the existing Slice 9
  criterion *"Missing downstream content shows a neutral empty state and recovery action
  rather than fabricated progress."*
- The zero-state answer is concrete enough to replace the prototype's two remaining
  fabrications: the hard-coded 1-day streak (`prototype-web.html:538`) and the hard-coded
  150-point total (`:541`).

## Capture budget

The scouted flows total 73 screens; this study does not need all of them. **Ceiling of 8
downloaded screens per platform**, chosen against the questions rather than for
completeness — the handoff screen, the first-run home, its empty slots, the first-action
surface, and for Duolingo the classroom-join set. If a platform needs more than 8 to answer
its assigned questions, say why in `notes.md` rather than silently exceeding it.

## Risks

- **Timing and motion are out of scope for the evidence, not out of mind.** Q1 was narrowed
  precisely because stills cannot show a loading state, a celebration beat, or a redirect.
  Any timing claim goes to `## Gaps & caveats` as a validation task. If the handoff proves
  to matter mostly *in motion*, that finding — "this needs live observation" — is a
  legitimate result of this study.
- **Audience transfer is the likeliest route to a bad implication reaching the PRD.**
  Coursera, Uxcel, and Brilliant serve Western, self-directed, paying, professional
  audiences; the PRD serves free-access, low-context, mobile-first Indonesian youth.
  `PATTERNS.md` already records this limit twice (the population caveat under *Deferred,
  "try-first" registration*; the collectivist caution under *Time-boxed peer league*).
  Every finding from those three carries it and must say so. Duolingo is the partial
  exception on free-access and youth, not on region.
- **Web-desktop viewport ≠ the PRD's target viewport.** Web-only is the user-confirmed
  scope, so the decision stands — but `PRD.md` §9 Slice 10 requires that at 320px no
  primary task needs horizontal scrolling, and the audience is mobile-first. A desktop-web
  read of a home surface does not settle its narrow-viewport IA. State this as a transfer
  limit on any layout or density finding.
- **Zero state vs. seeded demo state.** Library captures may show staged accounts. Where a
  screen's emptiness is ambiguous — Duolingo's gems and streak are the known case — say so
  rather than asserting it is the zero state.
- **No first-party observation claims.** Per the sourcing standard, no finding may claim we
  watched any of this work.
- **Flow tails may not reach the home.** The plan assumes Uxcel's 19-screen tail and
  Brilliant's 12-screen flow arrive at the post-account home. If either stops at the wall,
  the remedy is a direct `search_screens` pass for that platform's home screen — decided
  now so it does not become an improvisation mid-capture.

## Principal Researcher review

Reviewed 2026-07-28. **Verdict: needs revision** — ten must-fixes, all applied:

1. **Removed a false claim.** The brief stated the prototype's `courseMap` matched none of
   the six goal ids. Verified against disk: it was fixed earlier the same day and now maps
   all six. The claim is deleted from `README.md` and the success criteria drop from three
   fabrications to two.
2. **Resolved the C3 contradiction** on question 1 by narrowing the question to composition
   and deferring timing to validation.
3. **Redrew the Q2/Q5 boundary** so gamification widgets belong to one question only.
4. **Named the missed fourth prior study** (`2026-07-17-certificate-vs-badge-gamification`)
   and narrowed Q5 to its genuine residual.
5. **Restated Q4 and Q6 as residuals** of catalogued `PATTERNS.md` entries.
6. **Rebuilt the platform set for audience fit** — added Duolingo as primary, cut Unity
   Learn, made Khan Academy an explicit contingency with a C2 path, and withdrew the
   overstated Uxcel-invite-as-cohort-analogue claim.
7. **Fixed the unsatisfiable two-platform criterion** and added the gaps-entry requirement.
8. **Split the pre-written findings** into scouted observations and open questions.
9. **Added the audience-transfer and viewport-transfer risks.**
10. **Registered the study** in `.claude/.active-research` and bound this terminal.

Should-fixes applied: appetite read on each finding, routing to the §11 owners, dated
library-variant phrasing, the flow-tail fallback, the capture budget, the negative-search
log in `sources.md`, and the removal of the false binary in question 1.

_Awaiting user approval. Capture begins only after that._
