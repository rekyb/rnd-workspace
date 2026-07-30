# Research: Learning Home Layout & Information Architecture

- **Status:** Closed
- **Type:** benchmark
- **Started:** 2026-07-29
- **Closed:** 2026-07-30
- **Researcher:** Claude (acting Senior UI/UX Designer)
- **Coverage:** Q1,Q5 answered · Q2,Q3,Q4 partial · Q6 withdrawn (semantic-structure audit routed to `/a11y-audit`)

## Goal

Benchmark how learning platforms **structure** the authenticated home: the navigation
model and its top-level cardinality, the vertical order of blocks on the page, how many
co-equal actions the surface presents, and how that structure transforms between desktop
and narrow viewport.

This is **observation feeding a build decision.** The findings are the evidence base for a
future `design/learning-home` project (to be created via `/new-design` once this study
synthesizes). The home is treated as its own build surface rather than an extension of
`design/onboarding-solve-edu`, whose PRD settles Learning Home as a non-goal (§7.4, §10,
Slice 9 = greeting plus one CTA) and whose stakeholder review already ratified that scope.

The guiding question:

> *When a learner opens the home for the nth time, what does the page's structure tell them
> about where they are, what is available, and what to do next — before they read a single
> word of content?*

## Relationship to prior studies

`2026-07-28-post-signup-handoff-first-run-home` is the immediate neighbour and the boundary
must stay sharp. That study answered what the first-run home **contains** and why: the slot
rule at zero state (F2), intake payoff (F3), where the first-run primary action is computed
from (F4), and the screen count before a usable home (F9).

**It did settle some structure, and this study must not re-derive it.** F2 is a rule about
*which slots render* at zero state; F4 reports the first-run primary action's *presence and
order*; F9 counts the screens before a usable home. What it could not settle is the rest:
visual dominance, nav model, density, and anything at narrow width. Its own Q4 coverage row
records dominance as *"not measurable at the captured viewport (1280 by 495 to 551 CSS px)"*
(`SYNTHESIS.md:79`), and its caveat at `:1146` scopes the narrow-width gap precisely:

> No layout, density, or visual-dominance finding here settles narrow-viewport IA.

`research/PATTERNS.md` likewise carries no pattern for home IA, navigation model, or
dashboard density — verified against all 47 entry titles during the plan gate.

**New ground:** navigation model, cardinality, and current-location signal (Q1); the
web-to-narrow transformation (Q4); where progress sits in the layout (Q5).

**Narrowed residuals** of the neighbour's Q4: block order at a *populated* state (Q2), and
the *ranking device* by which one action is raised above the rest (Q3) — the half that study
could not measure, for which this study is the named validation route.

**Deliberately excluded:** zero-state composition, intake payoff, and first-run-specific
behaviour. Those are answered next door. This study observes **populated, returning-learner
homes**. `SYNTHESIS.md` will carry a `## Boundary with 2026-07-28` table — one row per
finding, naming the nearest neighbour finding and the difference — so the claim is checkable
rather than asserted.

## Scope

**In scope**

- The navigation shell: pattern (persistent sidebar / top bar / bottom tabs / two-tier),
  number of top-level destinations, whether they carry group labels, and how the learner's
  current location is signalled. *(All four sit under Q1; no in-scope item lacks a `Q#`.)*
- The vertical order of home blocks, and which block occupies the first screenful.
- Action density: how many distinct actionable elements the home offers, and by what device
  one is ranked above the rest.
- Where progress, readiness, or mastery signals sit in the layout.
- How the same product's home differs between web and narrow viewport.
- Our own staging home at `staging.solve.education/learner` as the **baseline case**, at
  **desktop width only** — the product has no responsive mobile design yet, so there is no
  narrow-width baseline to observe.

**Out of scope**

- Zero state and first-run composition. Answered by `2026-07-28-post-signup-handoff-first-run-home`.
- The content *inside* the blocks — copy quality, recommendation relevance, lesson design.
  This study reads structure, not substance.
- Visual design: colour, type, spacing. `/extract-tokens` is the lens for that.
- Motion, transitions, and timing. Stills cannot show them, and no C3 trigger is claimed.
- Recommendation-algorithm quality.
- Android. Mobbin covers `ios` and `web` only.

**The baseline is not a benchmarked platform.** Our staging home is the thing the findings
get measured against. No pattern is derived *from* it, and no finding may cite it as
evidence that a structure works.

## Platforms to benchmark

- [ ] **Solve Education (staging)** — *baseline, not a benchmark case* — Chrome, trigger **C1** (the product is ours)
- [x] **Duolingo** — web **and** iOS (Mobbin) — the **overflow** case and **Q4 pair 1**: 8 sidebar items ending in `MORE` on web, 6 tab icons ending in `…` on iOS. **Captured 2026-07-29** (7 screens: 4 web, 3 iOS)
- [x] **Babbel** — web **and** iOS (Mobbin) — the **low-cardinality** case and **Q4 pair 2**: three destinations, **the identical three on both platforms**. **Captured** (9 screens)
- [x] **Codecademy** — web (Mobbin) — 6-item top bar **plus** 6-item sidebar; the **two-tier** case, split by scope. **Captured** (4 screens)
- [x] **Uxcel** — web (Mobbin) — **13** destinations grouped under `LEARN` / `GROW`; the **grouped** case. **Captured** (3 screens)
- [x] **Coursera** — web (Mobbin) — four learner tabs over a global utility bar. **Captured** (3 screens)
- [x] **Mimo** — iOS (Mobbin) — five labelled tabs; home split across `Learn` (path) and `Practice` (stack). **Captured** (4 screens)
- [x] **Speak** — iOS (Mobbin) — five labelled tabs; staggered path, progress on `Profile`. **Captured** (2 screens — thinnest set; corroborates only)
- [x] **Circle** — web (Mobbin) — non-education control. **Trigger fired and captured**: only one learning platform grouped its nav, below the threshold of two. **Captured** (1 screen)
- [ ] ~~Whop / Sketch / Webflow / Expensify~~ — surfaced in search, cut for audience fit (not learning products)

Six learning platforms carry the study; Circle is a conditional control. Every published
alternative to a flat nav list is represented: overflow, two-tier, grouping, and low
cardinality — with a disconfirming clause in `PLAN.md` allowing the typology to fail if a
platform does not fit it.

**Audience caveat, recorded up front.** Five of the six serve Western, self-directed, largely
paying audiences; Duolingo is the partial exception on free access and youth. None is a
low-context, low-bandwidth, Global-South learning product, and nav cardinality is exactly
where that gap bites. Every design implication carries an explicit transfer status.

Duolingo, Coursera, Uxcel, and Babbel also appear in the neighbouring study. Reused
deliberately: same platforms, different lens, different screens — populated home and nav
shell, not zero state.

## Log

- 2026-07-29 — research created (type: benchmark).
- 2026-07-29 — baseline reconnaissance of `staging.solve.education/learner` (11 flat nav
  items, 2 headings on the page, `.nav` wraps rather than collapses at `max-width: 760px`).
  Recorded in `PLAN.md` as **unverified pre-capture** observations; nothing saved to disk,
  pending PII redaction.
- 2026-07-29 — platform set built from four Mobbin searches (3 web, 1 iOS). Web set widened
  to Duolingo, Codecademy, Coursera, Uxcel, Babbel after the education-coverage gap was
  raised; Whop, Sketch, Webflow, and Expensify cut for audience fit. No Khan Academy web
  coverage surfaced, consistent with the C2 finding recorded next door.
- 2026-07-29 — **Plan reviewed by the Principal Researcher (Mode A). Verdict: needs
  revision**, 11 must-fixes and 10 should-fixes. All 11 must-fixes and 9 of 10 should-fixes
  applied. Substantive changes: **Q6 withdrawn** (a semantic-structure audit is an
  `/a11y-audit` question, not a benchmark one); **Q2 and Q3 reclassified** from new ground to
  narrowed residuals of the neighbour's Q4; **Q3 downgraded** `Yes` → `Partial` (per-screen
  counts, not per-home); **Q4's real gap named** (no benchmarked platform supplies a
  responsive *web* home at narrow width) and a convention-claim guard added; a false citation
  to non-existent Duolingo iOS captures **corrected by sourcing them fresh**; audience-transfer
  and Android-absence risks added; four binding baseline-separation rules added; and the
  no-re-derivation claim given a procedure (`## Boundary with 2026-07-28`). One should-fix is
  open by design and assigned to capture: whether Mobbin publishes multi-position or full-page
  screens, which if true would upgrade Q2.
- 2026-07-29 — **Q4 rescoped: the product has no responsive mobile design yet** (confirmed by
  the product owner). No narrow-width baseline capture is attempted and no C3 trigger is
  claimed; the `max-width: 760px` rules are recorded as incidental overflow handling, read as
  confirmation that no mobile layout exists rather than as a description of one. Q4 becomes
  **forward-looking** — design input for a responsive home that does not yet exist, not a
  comparison against a current one — and every Q4 implication is labelled a hypothesis for
  validation.
- 2026-07-29 — **Mobile promoted to an explicit deliverable** at the product owner's
  direction: staging needs mobile design references regardless of there being no mobile build
  yet. Speak promoted from reserve to the capture set, giving **four iOS platforms** and three
  distinct mobile home shapes (Duolingo's path, Babbel's lesson list, Speak's course list plus
  activity log, Mimo's daily task plus stats). New success criterion 7 requires a **mobile home
  reference section** covering nav pattern and tab count, which destinations earn a tab, phone
  block order, and where progress goes without a side rail — every item labelled a hypothesis
  for validation on Android mobile web.
- 2026-07-29 — **plan approved; capture began.**
- 2026-07-29 — **Duolingo captured** (7 screens: 4 web, 3 iOS): `references.md`, `flow.md`,
  `notes.md` written. **Q1 answered decisively for the overflow case** — 8 exposed web items
  ending in `MORE`, 6 exposed iOS icons ending in `…`, both treating the nav as a budget rather
  than an inventory. Also a counter-case worth carrying: Duolingo's nav is **flat and ungrouped**
  like ours, which means flatness alone is not the defect — count and the presence of an
  overflow budget are the variables. **Q4 pair 1 complete.** Q2, Q3, Q5 each have a first
  reading. **Plan gate's open should-fix resolved:** Mobbin stills are fixed crops (web
  768 × 521, iOS 299 × 678), so Q2 stays `Partial`.
- 2026-07-29 — **Babbel captured** (9 screens: 5 web, 4 iOS). **Q4 pair 2 complete.** Its three
  destinations are the *identical three* on web and iOS, against Duolingo's differing 8-and-6:
  two opposite answers to cross-platform IA. Also the study's second Q5 position — Babbel
  **migrates** the goal signal from rail to primary column on mobile where Duolingo **deletes**
  it.
- 2026-07-29 — **Codecademy, Uxcel, Coursera captured** (10 screens). **Q1 answered decisively.**
  The nav-cardinality picture is now complete and the headline is not what the plan assumed:
  Uxcel carries **13** destinations and Codecademy **12**, both more than our eleven, and both
  read cleanly. The variable is the **device**, not the count — our baseline is the only surface
  in the set with a flat, ungrouped, un-budgeted list.
- 2026-07-29 — **Mimo and Speak captured** (6 screens). Mobile-reference set complete at four
  iOS platforms. Q1's mobile reading: **three to five labelled tabs**, and the one platform
  exceeding five (Duolingo, 6) is also the only one that drops its labels and adds an overflow.
- 2026-07-29 — **Circle captured** (1 screen). The plan's conditional trigger **fired**: only
  Uxcel grouped its nav, below the threshold of two, so the control was required rather than
  optional. It establishes that grouping is a **cardinality device, not an education
  convention** — and forced one correction: the four-way typology's arms are **not mutually
  exclusive** (Circle runs two tiers *and* grouping at once), so it is a set of devices, not
  categories. Recorded under the plan's disconfirming clause.
- **Mobbin capture complete: 7 platforms, 33 screens.**
- 2026-07-29 — **Baseline captured** (Chrome, C1; 3 screenshots, desktop only). The account
  holder's name was blurred before saving and the redaction verified in the written PNG. Every
  reconnaissance figure re-derived from the committed capture and confirmed unchanged: 11 nav
  items, 2 headings, 7 actions in `main`, CTA at y≈1001 of 1577. One new measured fact: **no nav
  item carries an active state** (no `aria-current`, no active class, queried live).
- **Capture complete: 8 platforms** (7 Mobbin + 1 Chrome baseline), 36 screens.
- 2026-07-29 — **`SYNTHESIS.md` written** (type: benchmark; **9 feature entries**, each with the
  five required fields, plus the coverage table, the `## Boundary with 2026-07-28` table, the
  mobile home reference, the nav cardinality comparison, and `## Gaps & caveats`).
- 2026-07-29 — **Principal Researcher QA pass (Mode B) run.** Verdict **revise**, **12** flagged
  items: 5 internal consistency, 2 evidence trail, 2 baseline separation, 1 hypothesis labelling,
  1 validation step, 1 plan success criterion. Prose auto-fixes: 39 em-dashes removed across 33
  edits, 0 AI-slop rewrites needed. **Citation integrity clean** — 3 embedded images all resolve
  on disk, all 21 distinct Mobbin screen IDs trace to a `references.md` row, and no gitignored
  `reference/` path is embedded anywhere. A study-root `references.md` was created with **8
  external sources (R1–R8)** validating the rationales; 6 corroborated, 1 calibrated, **1
  challenged**.
- 2026-07-29 — **All 12 flagged items resolved**, recorded in `## Resolutions applied`. The most
  serious was real: `PLAN.md` criterion 6 required a falsifiable **recommendation on the flat
  eleven**, and the synthesis had only described the alternatives. A
  `## Design implications for design/learning-home` section now carries six implications, each with
  a *falsified if* clause. One resolution changed substance rather than wording: external source
  **R1 (Larson & Czerwinski)** found increased depth harms search performance, which is evidence
  against one of the five devices the study had presented as co-equal, so **DI1 explicitly rejects
  Babbel's push-depth-down approach** for our case.
- 2026-07-29 — **Peer review recorded** (`## Peer Review`). Three chained panelists (Skeptic, Domain
  Expert, Evidence Auditor) moderated by the Principal Researcher in Mode C. Verdicts: **2 Robust, 13
  Strengthen, 0 Unsupported.** No finding retracted; no `F#` retired. **All 48 actions approved and
  applied.**
  - **Moderator's own check found the largest defect:** the study benchmarks **seven** learning
    platforms, not six. Every "of six" denominator was wrong, including two coverage-table cells.
    Screen counts (33) unaffected. Swept first, because every other tally depended on it.
  - **F3 was understated, not overstated.** The Skeptic said its rule held 3 of 6, the Domain Expert
    4 of 6; verified against all seven platform folders it holds **6 of 7**, with Codecademy the sole
    dissent. It is the study's strongest finding.
  - **Three grounding defects repaired.** F3's flagship Uxcel citation pointed at a screen that does
    not hold the block it cited, and spliced a **zero-state-only** block into a populated sequence,
    crossing the study's own boundary guard. F4 asserted a universal negative over 33 screens when
    fill was enumerated on four. The `## Mobile home reference` table, a `PLAN.md` criterion-7
    deliverable, asserted three rows the platform notes explicitly disclaim.
  - **Retracted:** F6's remaining-cost-beats-percentage claim (confounded — Uxcel's card carries `6%`
    **and** `7h left`), F7's Duolingo destination-**set** difference (iOS tab identities are
    unreadable, so only counts are claimable), and the nav tally's cardinality-breakpoint clause
    (device presence is not monotonic in cardinality). Three clauses, no finding.
  - **F6 removed from the Q3 coverage row** — it reports resume-control *copy*, which `README.md`
    scopes out, and answers no planned `Q#`. Retained with a scope note rather than deleted.
  - **DI1 split rather than killed.** Both the Skeptic and the Evidence Auditor called it the panel's
    hardest case. The **device** is recommended (supported on the two platforms carrying more
    destinations than we do); the **destination-by-destination mapping** is demoted to a candidate
    conditional on the content inventory the study's own caveat names as the prior question. Added:
    static labels not collapsible groups, card sort in Bahasa, no single-member clusters, and R1
    reported in both arms.
  - **Confidence moved on two coverage rows:** Q1 High → **Medium** (the device typology's boundary is
    unstable), Q2 → **High on the order half**. No `Status` moved.
  - **Q4's reason corrected:** the mobile gap is inherent to **Mobbin**, not to the method. C2 and C5
    authorise a Chrome capture at 360px that would partly close it, and that route was available and
    not taken.
  - **References R9–R19 added** with retrieval status governing use: R9–R11 full text read and citable;
    R12, R13, R15, R17, R19 abstract only and never sole support; **R14, R16, R18 located-but-unreadable
    and cited nowhere.** The Domain Expert's reference-frame challenge to F5/DI5 depends on R16, so it
    is recorded as an open question rather than a citation.
  - **One panelist claim rejected on verification:** the Evidence Auditor reported Circle's active state
    had no observation record; `circle/flow.md` step 1 records it. No edit made.
  - Four new `## Gaps & caveats` entries: what the device typology is actually measuring, localization,
    conditions of use (and that **no workspace lens covers performance**), and facilitator-mediated
    arrival.
- 2026-07-30 — **Research closed.** Pattern library updated by the Principal Designer (Mode P):
  **7 patterns added** in a new `## Navigation, home IA & layout` section of `research/PATTERNS.md`
  (the cardinality device; current-location marking and its tier-disambiguation second job;
  learner-first block order; fill as the ranking device with its feature-singleton precondition;
  progress split by permanence; the phone tab budget with redundant icon-plus-label coding; and the
  phone-home disposal rule). **2 existing entries updated** — the "1 MIN" bite-sized-lesson entry
  extended from *packaging* a lesson to *re-entering* one, and the icon-first intake entry given a
  scope boundary. **1 contradiction flagged**: "icon-first, low-text intake" read carelessly licenses
  an icon-only tab bar, which R13 and 3 of 4 phone platforms contradict; reconciled by surface
  (intake choice cards versus persistent navigation destinations), neither reading flipped.
  **Baseline exclusion honoured** — nothing in the new section derives from
  `platforms/solve-education-staging/`; the section preamble states the exclusion so a later reader
  knows the study's sharpest contrast material is deliberately absent. **Declined**: the five-device
  typology as a standalone taxonomy (unstable boundary), F8's *sought* versus *must-be-seen* rule
  (n=2, folded in as a labelled hypothesis), the retracted cardinality breakpoint, and DI1's specific
  destination mapping (baseline-derived and product-specific).
