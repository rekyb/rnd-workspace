# Research Plan: Learning Home Layout & Information Architecture

- **Status:** **Approved 2026-07-29** — capture in progress
- **Type:** benchmark
- **Goal it serves:** Benchmark how learning platforms structure the authenticated home — nav model, block order, action density, and narrow-viewport transformation — as the evidence base for a future `design/learning-home` project.

## What is new ground, and what is a residual

The neighbouring study `2026-07-28-post-signup-handoff-first-run-home` is close enough that
this distinction is load-bearing. It is stated here in the same form that study used.

- **New ground:** Q1 (navigation model and cardinality), Q4 (the narrow-viewport
  transformation), Q5 (where progress sits in the layout).
- **Narrowed residuals:** Q2 and Q3. Both extend the neighbour's **Q4**, whose coverage row
  (`SYNTHESIS.md:79`) records visual dominance as unmeasurable at the captured viewport and
  reports *presence and order* instead. Q3 here is the validation route for the half that
  study could not measure; Q2 asks the same block-order axis at a **populated** state rather
  than a zero one.
- **Withdrawn:** Q6 (see the table).

**The boundary guard.** A Q2, Q3, or Q5 finding may not restate F2's slot rule or F4's
cold-start rule. Where it touches either, it must cite the finding by ID and state the
delta. Naming a `Q#` does not by itself prove a finding is new.

## Research questions

Stable IDs per `.claude/references/coverage-contract.md`. Never renumbered, never reused.

| ID | Question | Method that will answer it | Answerable by this study? |
|---|---|---|---|
| Q1 | **Navigation model, cardinality, and current-location signal.** What nav pattern does an authenticated learning home use (persistent sidebar / top bar / bottom tabs / two-tier), how many top-level destinations does it expose, are they grouped under labels or co-equal siblings, and how is the learner's current location signalled? | Mobbin screen capture across 5 learning platforms (4 web, 3 iOS; Duolingo and Babbel on both) | **Yes** — all four sub-parts are visible in a home still. **Counting rule:** where a nav terminates in an overflow control (`MORE`, `…`) or is clipped by the crop, record "n exposed without interaction, plus overflow of undetermined depth", never a bare n. |
| Q2 | **Block order and the first screenful.** In what vertical order do home blocks appear, which block occupies the top, and where does the primary action sit relative to it? | Mobbin stills, using the library's multiple scroll positions where published | **Partial** — *order* is observable wherever the library publishes more than one scroll position; *fold position* is not measurable, because a still carries no viewport height. Reported as ordinal position, never as a pixel offset, except on the baseline where the real viewport is known. |
| Q3 | **Action density and ranking device.** How many distinct actionable elements does the home present, and by what device (size, colour, position, isolation, label) is one ranked above the rest? | Mobbin stills; record the ranking device per home and count actionable elements per captured screen | **Partial** — the **ranking device** is observable per screen (`Yes`). The **count** is countable per *captured screen* only, never per *home*, because a library still is one scroll position and completeness can never be established from it. A whole-page count exists only for the baseline. |
| Q4 | **The narrow-viewport transformation.** For a product present on both web and iOS, how does the home's nav model and block order differ between them, and what does a learning home look like when it has to fit a phone? | Paired Mobbin capture, same app on `web` and `ios` (**two complete pairs: Duolingo and Babbel**), plus mobile-only capture of **Mimo** and **Speak** for nav-pattern breadth | **Partial** — Mobbin's iOS and web entries are independent snapshots, not one build at two widths, so a pair compares *two designs by one team*, not a responsive layout reflowing. **Purpose, confirmed by the product owner 2026-07-29: this is a deliberate design-reference deliverable**, not a comparison — staging has no mobile design yet, and this study supplies the reference for building one. **Two guards: no Q4 finding may make a platform-interaction-convention claim, only a structural or IA one; and no Q4 finding may describe the baseline's narrow-width behaviour, which is undesigned rather than observed.** |
| Q5 | **Where progress lives.** In what region of the layout does a progress, readiness, streak, or mastery signal sit — primary column, secondary rail, header, nav, or a separate destination — and is it one signal or several? | Mobbin stills across all 5 learning platforms | **Yes**, for region and count. **Guard:** Q5 states region and count only. Mechanic selection, motivational register, and zero-state behaviour are settled by F2 and by the `PATTERNS.md` entries "Progress bar / goal-gradient as the low-risk default motivation mechanic", "Layered motivation stack", and "Time-boxed peer league / leaderboard". Out of bounds here. |
| Q6 | ~~Semantic heading and landmark structure of the home.~~ | — | **Withdrawn — a semantic-structure audit is an `/a11y-audit` lens question, not a benchmark question.** Mobbin stills cannot show semantics, so the only answerable case was our own baseline, which makes it a self-audit of one product rather than a benchmark of how learning platforms structure the home. It therefore does not serve the `## Goal`. The baseline DOM reading is retained below as reconnaissance and is routed to `/a11y-audit`. ID retired, not reused. |

## Per-platform capture plan

### Solve Education (staging) — BASELINE, not a benchmark case
- **Source:** chrome
- **Chrome trigger:** **C1** — the product is ours (`staging.solve.education`).
- **Flows/screens to capture:** `/learner` home, populated, **desktop width only**.
- **No narrow-width baseline capture.** The product has no responsive design for mobile yet (confirmed by the product owner, 2026-07-29). There is nothing to observe at narrow width, so none is attempted and no C3 resize trigger is claimed. The `max-width: 760px` rules found during reconnaissance are **incidental overflow handling, not a mobile layout**, and are recorded as such.
- **What we're looking for:** the baseline reading of Q1, Q2, Q3, Q5.
- **Capture-standard deviation, declared:** **no `flow.gif`.** The workspace standard lists it as required for Chrome-sourced platforms; this study reads static structure, and a recording would add no structural evidence. Declared here so the omission is not read later as an oversight. `flow.md` is still required.
- **`flow.md` definition for a layout study:** the scroll-and-navigate path through the home — arrival, first screenful, scroll sequence with the block order encountered, and which destinations are reachable in one click from the home. System-response claims on Mobbin platforms marked *inferred from screen sequence*.
- **Redaction targets (mandatory, before any capture is saved):** the account holder's name in the H1 region, the avatar, the email address, and any third-party names reachable on the Referral, Applications, Evidence, or Credentials surfaces. Re-apply the `window.__redact()` helper after every navigation and re-render, and verify the redaction *in the saved image* before commit.
- **Risks:** logged-in session with real PII (above). *(The earlier risk about unproven narrow-width capture is resolved and removed: no narrow-width capture is attempted, because there is no mobile design to capture.)*

#### Baseline reconnaissance (unverified, pre-capture)

*These are live DOM readings from an **unsaved** session on 2026-07-29. Every one must be
re-derived from a committed capture before it appears in `SYNTHESIS.md`. If capture does not
happen, none of them is usable as evidence.*

- 11 top-level nav items, no group labels: Home, Inbox, Catalog, Ladders, Practice, Challenges, Evidence, Credentials, Opportunities, Applications, Referral.
- Page carries 2 headings total (one `h1`, one `h2`); all four card titles are styled text, not headings. **Routed to `/a11y-audit`** following Q6's withdrawal.
- At `max-width: 760px` the only nav rule is `.nav { flex-wrap: wrap; order: 3; width: 100%; margin-left: 0 }` — the nav wraps to multiple rows rather than collapsing; no menu control exists at any width. **Read as confirmation that no mobile layout has been designed**, not as a description of one. It is not evidence of narrow-width behaviour and may not be cited as such.
- 7 actionable links in `main`; primary CTA at y≈1001 of a 1577px page.

*(A fifth observation — readiness stated twice, and skill bars encoding the same variable as
a percentage in some rows and the word "mastered" in others — has been **cut from this plan**.
It is a consistency observation about content composition, out of scope per `README.md`, and
`/heuristic-eval` material under Nielsen 4. Its appearance here was the boundary-erosion risk
already operating.)*

#### Baseline separation rules (binding on synthesis and close)

1. The baseline may **never** be the sole evidence for an `F#`.
2. No `F#` may be **about** the baseline.
3. The baseline is **excluded from `PATTERNS.md` extraction** at `/close-research`; the Principal Designer must be told so explicitly.
4. In the criterion-3 comparison table the baseline row is visually marked and **excluded from every "N of 5" tally**.

### Duolingo — web **and** iOS (Q4 pair 1)
- **Source:** mobbin (`web` and `ios`)
- **Flows/screens to capture:** **web** — Learn (lesson path), Practice (Today's Review), three-column layout with left sidebar, primary column, right rail carrying league and Daily Quests. **iOS** — home lesson path with the bottom tab bar.
- **What we're looking for:** Q1 — **the overflow case, on both platforms.** Web exposes 8 sidebar items ending in `MORE`; iOS exposes 6 tab-bar icons ending in `…`. Same product, same overflow strategy, different cardinality: the cleanest available answer to what a flat 11-item list should have done. Also Q3, Q4, Q5.
- **Note:** Duolingo's **Statistics** view is a separate destination, not the home. "Progress lives on its own page" is a legitimate Q5 answer, but it must not be counted as progress placement *on the home*.

### Babbel — web **and** iOS (Q4 pair 2)
- **Source:** mobbin (`web` and `ios`)
- **Flows/screens to capture:** **web** — home, three-item top nav (`Home` / `Review` / `Explore`), `Today` / `Learning plan` segmented control, lesson list plus right rail. **iOS** — home, three-tab bottom bar, activity tracker, lesson cards.
- **What we're looking for:** Q4 primarily — the same product at two widths with the **lowest cardinality in the set**, which is the direct contrast to Duolingo's overflow strategy. Also Q1, Q5.
- **Minimum for the pair:** at least **two screens per side, including one scrolled**. One still per side is not a pair.

### Codecademy — web
- **Source:** mobbin (`web`)
- **Flows/screens to capture:** Dashboard, My learning, Start-learning band — top bar (`My Home`, `Catalog`, `Resources`, `Community`, `Live Learning`, `For Business`) **plus** left sidebar (`Dashboard`, `My learning`, `Skills tracking`, `Events`, `Projects`, `Workspaces`).
- **What we're looking for:** Q1 — **the two-tier case.** 12 destinations total, split across two levels by a rule (account-level and marketing above, learner-level beside). The structural alternative to flattening.
- **Note:** captures carry a promotional countdown bar and an upsell card. Recorded as observed; commercial pressure on the layout is context for Q2, not a finding about learning.

### Coursera — web
- **Source:** mobbin (`web`)
- **Flows/screens to capture:** home and "My Learning" — four-item top-tab nav, continue-learning band, goal tracker, and the scrolled "Earn Your Degree" band.
- **What we're looking for:** Q1 (low-cardinality top tabs), Q2, Q5.

### Uxcel — web
- **Source:** mobbin (`web`)
- **Flows/screens to capture:** authenticated home, populated — sidebar grouped under `LEARN` / `GROW`, "Continue learning", right rail carrying streak and league, resources grid when scrolled.
- **What we're looking for:** Q1 (the grouped case), Q2, Q3, Q5.

### Mimo — iOS
- **Source:** mobbin (`ios`)
- **Flows/screens to capture:** home with five-tab bottom bar (Learn / Practice / Build / Leaderboard / Profile), daily-review card, "Your Practice Progress" stats.
- **What we're looking for:** Q1, Q4, Q5. The five-tab case at the iOS ceiling, and a mobile home that carries both a daily task and a stats block.

### Speak — iOS
- **Source:** mobbin (`ios`)
- **Flows/screens to capture:** home with five-tab bottom bar (Home / Free Talk / Review / Challenge / Profile), course list with per-course progress, activity log.
- **What we're looking for:** Q1 and Q4. Promoted from reserve to the capture set on 2026-07-29 when mobile reference became an explicit deliverable. Contributes a second five-tab instance and a **course-list-plus-activity-log** mobile block order, which differs from Duolingo's path and Babbel's lesson list — three distinct mobile home shapes rather than one.

### Circle — web, optional control, capture last
- **Source:** mobbin (`web`)
- **Trigger to capture:** **only if fewer than two of the five learning platforms show a labelled nav group.** A count, so the decision is checkable rather than a judgement call.
- **What we're looking for:** Q1 grouping evidence from outside education, testing whether grouping is an education convention or a general one.
- **Risk:** not a learning product; an audience-transfer caveat rides on every finding it supports.

## Success criteria (what "done" looks like)

1. **Q1, Q3, Q5** each answered across **≥3 of the 5 learning platforms**. **Q2** answered on ≥3 platforms *each holding at least one scrolled capture*. **Q4** answered on **≥1 complete pair** (two screens per side, one scrolled).
2. Q1's nav-model coverage includes at least one instance each of **overflow** (Duolingo), **two-tier** (Codecademy), **grouped** (Uxcel), and **low-cardinality flat** (Coursera, Babbel). **Disconfirming clause:** record any platform whose nav does not fit this four-way typology, and allow the typology to fail rather than forcing the platform into it.
3. Every Mobbin-sourced platform folder holds `references.md`, `flow.md`, and `notes.md`, with `reference/` gitignored and every image carrying a `references.md` row. Chrome-sourced platforms hold `screenshots/`, `flow.md`, and `notes.md`. *(Stated per source type, following the amendment made to the neighbouring study's plan on 2026-07-29.)*
4. A **nav-cardinality comparison table** covering the 5 learning platforms plus the baseline, with the baseline row marked and excluded from tallies. Cells carry a stated denominator where a count is per-screen rather than per-home.
5. `SYNTHESIS.md` carries a **`## Boundary with 2026-07-28`** table: one row per new `F#`, naming the nearest neighbour finding (F1–F9) and the one-line difference. **A row that cannot name a difference is a finding in the wrong study.** This is the procedure for the no-re-derivation claim.
6. **Each of Q1–Q5 terminates in a design implication for `design/learning-home`, stated so that an observation could falsify it**, and the set of implications reaches a **recommendation on the baseline's flat 11-item nav** rather than merely describing the alternatives.
7. **A mobile home reference section**, since mobile design reference is an explicit deliverable. It must cover, across ≥3 of the 4 iOS platforms: the nav pattern and tab count, which destinations earn a tab and which are demoted, the vertical block order on a phone, and where the progress signal goes when there is no room for a side rail. Every item labelled a **hypothesis for validation on Android mobile web**, not a benchmarked finding — the evidence is iOS-native and the target is Android browser.
8. Every finding resting on a Mobbin still is marked reference-library observation, never first-party.

## Risks

- **Boundary erosion.** The neighbouring study is close enough that a structural finding could drift into composition. *Mitigation:* the boundary guard above, the per-question guards on Q3 and Q5, and criterion 5's boundary table. Naming a `Q#` is not sufficient on its own.
- **The baseline contaminating the benchmark.** Having read our own home first, there is a pull toward finding what indicts it. *Mitigation:* the four baseline separation rules; platform captures written before the comparison table.
- **Audience transfer.** Five of six platforms serve Western, self-directed, largely paying audiences; Duolingo is the single partial exception on free access and youth. **None** is a low-context, low-bandwidth, Global-South learning product, and nav cardinality and density are exactly where low-context users and small screens bite hardest. The neighbouring study rated this *"the likeliest route to a bad implication reaching the PRD"* (`SYNTHESIS.md:1135`). *Mitigation:* every design implication carries an explicit transfer status, and none cites more than the platform set can carry.
- **Android absence.** Mobbin covers `ios` and `web` only. Q4's narrow half is entirely iOS while our audience is Android-first. *Mitigation:* nav-idiom and interaction-convention claims are barred (Q4 guard); only structural and IA claims are permitted from iOS evidence.
- **The mobile reference is iOS-native, and the surface it will inform is Android mobile web.** No benchmarked platform publishes a responsive *web* home at narrow width, and Mobbin covers `ios` and `web` only, so the mobile evidence is entirely native iOS. That is a two-step transfer (iOS → web, **and** iOS → Android), not one. This is inherent to the method rather than a capture shortfall, and the deliverable is still worth having: **what a learning home becomes when it must fit a phone is a structural question, and structure transfers better than interaction idiom.** *Mitigation:* Q4's two guards bar idiom claims; every mobile-reference item is labelled a **hypothesis for validation on Android mobile web**; and `## Evidence gaps` names a narrow-width usability test on our own prototype as the route that would settle it. What must never happen is a mobile implication reaching a PRD as though it were benchmarked fact.
- **Mobbin snapshots are point-in-time**, not claims about current product behaviour.
- **iOS-versus-web is not responsive reflow** — see Q4's `Answerable?` note.

## Principal Researcher review

**Mode A, 2026-07-29 — verdict: needs revision**, 11 must-fixes and 10 should-fixes.

Assessed strong: source justification (one Chrome platform, correct C1, C2 non-result for
Khan Academy web logged rather than assumed); Q2 and Q4 carrying real gaps rather than
decorative hedges; the `PATTERNS.md` gap claim verified against all 47 entry titles; criterion
3's per-source-type split.

**All 11 must-fixes applied:**

1. **MF1** — Q4 cited Duolingo iOS captures from the neighbouring study that do not exist (that study is desktop-web only, `README.md:77`). Duolingo iOS sourced fresh from Mobbin in this study instead; Q4 now has two real pairs.
2. **MF2** — the README over-read `SYNTHESIS.md:1146`, which scopes to narrow-viewport IA, not structure generally. Rewritten to state accurately what the neighbour did settle about structure (F4's presence-and-order, F2's slot rule).
3. **MF3** — Q2 and Q3 reclassified from "new ground" to **narrowed residuals** of the neighbour's Q4, with the boundary guard added.
4. **MF4** — Q3 downgraded `Yes` → `Partial`; the density half is per-screen, not per-home. Criterion 4 now requires a stated denominator.
5. **MF5** — Q4's `Answerable?` extended to name the real gap (no benchmarked platform supplies a narrow *web* home); convention-claim guard added; C3 route recorded.
6. **MF6** — Q6 **withdrawn**; a semantic-structure audit is an `/a11y-audit` question and, answerable on the baseline alone, does not serve the goal. Baseline DOM reading retained as reconnaissance and routed to that lens.
7. **MF7** — baseline block retitled *unverified, pre-capture*, with the re-derivation requirement; the consistency bullet cut as out-of-scope; four binding separation rules added.
8. **MF8** — guards added to Q5 (region and count only) and Q3 (ranking *device*, not the settled "rank one action above the rest").
9. **MF9** — audience transfer and Android absence added as risks with mitigations.
10. **MF10** — criterion 5 gives the no-re-derivation claim a procedure; criterion 1 gives Q2 and Q4 their own counts; criterion 6 ties the study to the build decision with a falsifiability test.
11. **MF11** — current-location signalling folded into Q1 rather than left in scope with no ID.

**Should-fixes applied:** 2 (overflow counting rule), 3 (Duolingo Statistics is a separate
destination), 4 (disconfirming clause on the typology), 5 (Q4 pair minimum), 6 (Circle's
trigger made a count), 7 (`flow.gif` omission declared as a capture-standard deviation),
8 (`flow.md` defined for a layout study), 9 (redaction targets enumerated), 10 (search rows
in `sources.md` annotated).

**Should-fix 1 — RESOLVED at first capture (2026-07-29).** The reviewer challenged the premise
that Mobbin stills are fixed-height crops. Measured on the Duolingo download: **web stills are
768 × 521 px, iOS stills 299 × 678 px, each a fixed crop at one scroll position.** The library
publishes *separate screens* for separate scroll positions (Duolingo iOS references 05 and 07
are the same home at two positions), so block **order** is readable across screens while **fold
position remains unmeasurable**. **Q2 stays `Partial`; no plan amendment needed.** The reviewer
was right that multiple positions exist and wrong that this upgrades Q2 — order was already the
answerable half.

**User approval:** granted 2026-07-29, after two scope amendments made at the product owner's
direction: no narrow-width baseline capture (staging has no mobile design), and mobile
promoted to an explicit design-reference deliverable (Speak added; success criterion 7).
