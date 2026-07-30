# Synthesis — Learning Home Layout & Information Architecture

**Type:** benchmark · **Study:** `research/2026-07-29-learning-home-layout-and-ia` · **Written:** 2026-07-29

## Overview

**Goal.** Benchmark how learning platforms *structure* the authenticated home: navigation model
and cardinality, vertical block order, action density and ranking, where progress sits, and what
changes on a phone. Evidence base for a future `design/learning-home` project.

**Studied.** Seven learning platforms plus one non-education control, 33 reference screens, and our
own staging home as the first-party baseline:

| Platform | Source | Screens | Role |
|---|---|---|---|
| Duolingo | Mobbin `web` + `ios` | 7 | overflow device; Q4 pair 1 |
| Babbel | Mobbin `web` + `ios` | 9 | low cardinality; Q4 pair 2 |
| Codecademy | Mobbin `web` | 4 | two-tier device |
| Uxcel | Mobbin `web` | 3 | grouping device |
| Coursera | Mobbin `web` | 3 | utilities-split device |
| Mimo | Mobbin `ios` | 4 | mobile reference |
| Speak | Mobbin `ios` | 2 | mobile reference, corroborating only |
| Circle | Mobbin `web` | 1 | non-education control |
| **Solve Education staging** | **Chrome C1** | **3** | **baseline, excluded from derivation** |

**Headline takeaways.**

1. **Eleven nav items is not the problem.** Uxcel carries 13 and Codecademy 12, both more than we
   do, and both apply a structural device and mark the learner's current location. Our baseline is
   the only surface in the study with **neither a device nor a current-location signal**. Whether the
   grouped navs are in fact easier to use was not measured; what was observed is that they carry a
   device and we do not.
2. **Grouping is a cardinality device, not an education convention.** The non-education control
   shows grouping outside education, and shows the devices **combine** rather than exclude each
   other. One screen of one product, so it establishes non-exclusivity, not a mechanism.
3. **Our block order puts the company before the learner.** The first block of a benchmarked home
   belongs to the learner or the material on **6 of 7** platforms. Ours spends its first two on a
   verification notice and a statement of design philosophy. The single platform that also leads with
   non-learner content is doing so to sell bootcamps.
4. **On the four home screens where controls were enumerated, none carries more than one filled
   control. Ours carries two**, 307px apart, near-identically styled, and the wrong one comes first.
   (Some rank without a filled button at all: Duolingo web ranks by elevation within the lesson
   path.)
5. **A phone home carries three to five labelled destinations.** The only platform exceeding
   five drops its text labels *and* adds an overflow.

> [Principal Researcher] Two headlines are stronger than the tables under them.
> **Headline 1:** "the only surface in the study with no device at all" is contradicted by the
> `## Nav cardinality comparison` table, which marks Mimo and Speak `none needed`. The table's
> own footer states the accurate version: the baseline is the only surface with *neither* a
> device *nor* a current-location signal. Narrow the headline to that.
> **Headline 4:** "Every benchmarked screen ranks exactly one filled button" is contradicted by
> F4's own body, where Duolingo web "ranks without a button anywhere". The supportable claim is
> that no benchmarked screen carries *more than one* filled control. Decide which claim you
> mean and make headline 4 and F4's short description say the same thing.

---

## Research questions — coverage

| Q# | Question | Status | Where answered | Confidence |
|---|---|---|---|---|
| Q1 | Nav model, cardinality, grouping, and current-location signal | **Answered** | F1 (nav pattern, cardinality, and grouping recorded for 7 platforms plus the control), F2 (current-location signal: **7 of 7 platforms, 9 of 9 surfaces** mark it; baseline marks none). **Missing:** the *device typology* is a derived classification, not an observation, and its boundary is unstable — Speak's `Course` / `Practice` segmented control is the same sub-level device that earns Babbel its entry, and device presence is not monotonic in cardinality (3 → device, 4 → device, 5 → none, 6 → device). The typology stands as a description of observed structural rules, not an exhaustive or exclusive classification. | **Medium** *(nav model, cardinality, and current-location: High; the derived typology: Medium)* |
| Q2 | Block order and the first screenful | **Partial** | F3 — the first-block rule holds in **6 of 7** (Uxcel, Coursera, Duolingo, Babbel, Mimo, Speak; Codecademy alone dissents, with a documented commercial motive). Order is answered at **High**. **Missing:** fold position is not measurable — Mobbin stills are fixed crops (web 768 × 521, iOS 299 × 678) carrying no viewport height. A true fold measure exists only for the baseline (CTA at y≈1001 of 1577), and that is a pixel reading at one known viewport, not on the same scale as the ordinal benchmark readings. | **Medium** *(order: High; fold: not answerable)* |
| Q3 | Action density and ranking device | **Partial** | **F4** — the ranking device is observed on 7 of 7 platforms, each recorded in `platforms/*/notes.md`, and is answered at **High** for *which device ranks*. **Missing:** (a) total actionable-element *count per home* is not obtainable from library stills; a whole-page count exists only for the baseline (7 in `main`); (b) the derived *scarcity* claim is enumerated on **four** home screens and is not stated over all 33 — `babbel/flow.md` steps 6 and 7 describe multi-button screens whose fill was never recorded. **F6 removed from this row:** it reports resume-control *copy*, which `README.md` scopes out, and it answers no planned `Q#`. | Medium |
| Q4 | The narrow-viewport transformation | **Partial** | F7 (tab budget), F8 (rail disappearance), F9 (mobile home shape). **Missing:** this study observed no responsive *web* home at narrow width, and our baseline has no mobile design. All mobile evidence is native iOS while the target is Android mobile web, a two-step transfer, so every F7–F9 implication is a **hypothesis for validation**. **The gap is inherent to Mobbin, not to the method:** the library publishes no narrow web capture, but `.claude/references/mobbin-sourcing.md` triggers **C2** and **C5** authorise a Chrome capture of a benchmarked platform's responsive web home at 360px. That route was available and not taken, and it is the cheapest way to raise this row's confidence. | Low |
| Q5 | Where progress lives in the layout | **Answered** | F5. Distinct arrangements documented across seven platforms — **region and count**, which is what Q5 asked and what the captures support. **Note:** the derived *separation-by-permanence rule* is not part of Q5's answer and holds cleanly in **3 of 7** (Duolingo, Babbel, Speak show both a small home signal and a detail destination); Uxcel shows the home signal with no detail destination in the captured set, Mimo moves detail to a peer tab with its `Profile` unobserved, Coursera's detail destination is unobserved, and Codecademy dissents outright. | **High** *(region and count; the derived rule: Medium)* |
| Q6 | ~~Semantic heading and landmark structure~~ | **Withdrawn** | Withdrawn at the plan gate: a semantic-structure audit is an `/a11y-audit` question, and answerable only on our own baseline, making it a self-audit rather than a benchmark. **Baseline reading retained and routed:** 2 headings on the page, 0 of 4 card titles are heading elements. Destination: `/a11y-audit`. | n/a |

**Summary: Q1, Q5 answered · Q2, Q3, Q4 partial · Q6 withdrawn.**

> [Principal Researcher] The coverage set is complete and no `Status` is more generous than
> `PLAN.md`'s `Answerable?` value; Q6 carries its withdrawal reason and a destination, as the
> coverage contract requires. **What is missing is downstream of the table.** `PLAN.md` success
> criterion 6 requires each of Q1 to Q5 to terminate in a **design implication for
> `design/learning-home`, stated so that an observation could falsify it**, and the set to reach
> **a recommendation on the baseline's flat 11-item nav rather than merely describing the
> alternatives**. This synthesis has no design-implications section and states no recommendation
> on the eleven. F1 offers two variants to test, which is a validation plan, not a
> recommendation. This is the largest gap between the study and its own plan; resolve it before
> `/review-research`.

Q4 carries the study's weakest confidence by construction, not by capture shortfall. See
`## Gaps & caveats`.

---

## F1 — The cardinality device (a nav needs a rule, not a shorter list)

**Short description.** Every benchmarked platform applies one or more structural devices to its
navigation so that destination count stops mattering. There are five distinct devices in the set,
and they combine.

**Key findings.**

*What the user sees.* Six different navigation shapes. The learning platforms carry between 3 and
13 destinations; the non-education control carries 14 in its sidebar plus 5 in a top nav.
[Babbel web](https://mobbin.com/screens/5c06bda9-0458-437b-a68d-89ce396237e7) shows three text
links in a top bar. [Coursera](https://mobbin.com/screens/18683325-d982-4756-b06e-4ed52c933b06)
shows four learner tabs on a row beneath a separate utility row holding search, cart, language,
and account. [Duolingo web](https://mobbin.com/screens/7baac688-9b35-4fc1-bbfd-f8bf8803a8f5)
shows an eight-item sidebar whose last item is `MORE`.
[Codecademy](https://mobbin.com/screens/df5c6018-fbf8-4473-88ba-4f7c02ba17ad) shows six top-bar
items and six sidebar items simultaneously.
[Uxcel](https://mobbin.com/screens/54c0aa01-9380-4e13-bc41-01e46dba6812) shows thirteen sidebar
destinations under two small-caps headings, `LEARN` and `GROW`.

*What the user does.* Scans one cluster rather than a whole list. Uxcel's learner looking for a
job scans `GROW` (4 items) and never reads the other nine. Codecademy's learner looking for their
own work scans the sidebar and never reads the top bar.

*What the system does.* Applies a sorting rule at build time. The rules differ and each is legible
from the surface: Codecademy sorts by **scope** (things that exist above, things you have beside);
Coursera sorts by **type** (places you go below, controls you use above); Uxcel sorts by
**purpose** (build skill / convert skill); Duolingo sorts by **frequency**, budgeting seven
permanent slots and overflowing the tail; Babbel avoids sorting by keeping the top level at three
and pushing everything into sub-levels.

*The control case.* [Circle](https://mobbin.com/screens/869cdce6-e3e5-4f7a-a447-9a09ac91e15a), a
community platform with no learning remit, carries fourteen sidebar destinations **plus** a
five-item top nav. Twelve of the fourteen sit under three labelled headings (`Get Started`,
`Product`, `Spaces`); **two (`Getting Started`, `Feed`) sit ungrouped above them**, the same
ungrouped-head-then-groups shape Uxcel uses. It was captured because the plan's conditional
trigger fired: only one learning platform grouped its nav, below the threshold of two. It
establishes that grouping is a **cardinality device, not an education convention**, and it forced
a correction to this study's own typology: Circle runs grouping **and** two tiers at once, so
these are devices that combine, not mutually exclusive categories.

> [Principal Researcher] Two numbers here disagree with the study's own comparison table.
> "Between 3 and 14 destinations" understates Circle, which the table records as `14 + 5`, and
> understates nothing else only because Codecademy's 12 is a `6 + 6`. State the range on the same
> basis the table uses. Separately, `circle/notes.md` records "fourteen sidebar destinations under
> three labelled headings, **plus two ungrouped at the top**"; this paragraph drops the two, so it
> reads as though all fourteen sit under a heading.

*The baseline.* Eleven destinations, flat, ungrouped, no overflow, no second tier.

![Baseline nav: eleven flat items](platforms/solve-education-staging/screenshots/01-home-top-hero-and-coach-card.png)

**Why this feature works (rationale).** A flat list of **unfamiliar** labels forces serial scanning:
the learner reads labels until one matches, so cost grows with length. That linear reading holds
only for the unfamiliar case. For a returning learner choosing among **known** alternatives, Hick's
law gives a logarithmic relation instead `[R3]`, so a flat list's penalty is largest on first
encounters and shrinks with familiarity. A device converts serial scanning into a two-step lookup
(pick the cluster, then scan inside it), so cost grows with cluster size rather than list length.

**Whether 13 grouped items are in fact cheaper to use than 11 ungrouped ones is not something this
study measured.** No legibility or scanning measure was taken on any platform. That comparison is
what F1's first-click test below is designed to produce. What the captures establish is structural:
13 destinations grouped 3 / 6 / 4 present three scan units where 11 flat present eleven.

The five devices are **not co-equal.** Larson and Czerwinski found increased depth harmed search
performance, with a medium breadth-and-depth structure beating the broadest-shallow one on reaction
time and lostness `[R1]`, so Babbel's push-depth-down arm carries a cost the other four do not.

The device also encodes an editorial judgement the learner can reuse: Uxcel's `LEARN` / `GROW`
split tells them the product has two purposes before they read a single destination name.

> [Principal Researcher] **External validation (B4).** The chunking argument is corroborated, with
> one qualification the finding should absorb. Larson & Czerwinski (1998) ran 512 items in three
> structures and found the *medium* breadth-and-depth arrangement beat both the deepest and the
> broadest-shallow one on search time and lostness `[ref: R1 — see references.md]`. That supports
> a two-step lookup over a flat run, and it also means the five devices are **not co-equal**:
> Babbel's "push everything into sub-levels" is the depth arm, which performed worst in that
> experiment. The capacity premise is supported by Cowan (2001), who puts the working-memory limit
> near four chunks `[ref: R2]`, so cluster sizes of 3, 6, and 4 are the relevant comparison, not
> the raw destination count. One calibration: "cost grows with length" is a *linear* search claim.
> Hick's law gives a logarithmic relation for choice among known alternatives `[ref: R3]`, so the
> linear reading holds only for scanning unfamiliar labels. Name which regime you mean.

**How to validate this feature in the future.** Run a **first-click test** on our eleven, then on
two grouped variants (a `learn / prove / find work` split, and a two-tier scope split), measuring
time-to-first-click and error rate for eight representative tasks. Follow with an **open card
sort** (n≈15 learners) to check whether our proposed group labels match how learners actually
cluster the destinations. The grouping rule must be theirs, not ours. Success criterion: median
time-to-first-click below the flat baseline on at least six of eight tasks.

---

## F2 — Marking where the learner currently is

**Short description.** Every benchmarked platform marks the active destination in its navigation.
Our baseline marks none.

**Key findings.**

*What the user sees.* Six platforms, six treatments of the same job. A filled pill
([Duolingo web](https://mobbin.com/screens/7baac688-9b35-4fc1-bbfd-f8bf8803a8f5),
[Uxcel](https://mobbin.com/screens/54c0aa01-9380-4e13-bc41-01e46dba6812),
[Circle](https://mobbin.com/screens/869cdce6-e3e5-4f7a-a447-9a09ac91e15a)); an underline
([Babbel web](https://mobbin.com/screens/5c06bda9-0458-437b-a68d-89ce396237e7),
[Coursera](https://mobbin.com/screens/18683325-d982-4756-b06e-4ed52c933b06)); a filled row with a
left edge bar ([Codecademy](https://mobbin.com/screens/df5c6018-fbf8-4473-88ba-4f7c02ba17ad)); a
tinted icon plus darker label on the phone platforms
([Mimo](https://mobbin.com/screens/e466340b-80ce-4a91-b557-14d55afcf4c9),
[Speak](https://mobbin.com/screens/a7b59b62-1a06-49b9-b386-5508bbfe97af)).

> [Principal Researcher] Three of the six treatments have no observation record on disk. The tinted
> active tab claimed for Babbel iOS, Mimo, and Speak appears in no `platforms/*/notes.md`: the Mimo
> and Speak notes discuss tab count and labelling only, and the Babbel notes never mention active
> state. The Mobbin URLs are cited, so nothing is fabricated, but the "6 of 6" in the Q1 coverage
> row and the "9 of 9" in the comparison table rest on three readings the evidence files do not
> record. Add the observation to those three `notes.md` files, or bound the claim to the surfaces
> where it is recorded.

*What the system does.* On our baseline, nothing. Queried directly against the live DOM while
sitting on `Home`: **no `aria-current` attribute and no `active` or `current` class on any of the
eleven nav items.** This is a measured absence, not an impression.

*Second-order effect.* Codecademy is the instructive case. It marks the active state **only in
the sidebar**, never in the top bar, on every captured screen. So the marking does double duty: it
says where you are, and it says which of the two tiers is the one you navigate within.

**Why this feature works (rationale).** A navigation without a current-location signal fails the
"where am I" half of orientation, and the cost lands hardest on returning learners arriving from
a notification or a bookmark rather than from a click they remember making. It also bears on
**WCAG 2.2 SC 2.4.8 *Location*, which is Level AAA**, whose sufficient techniques include **G128**
(indicating current location within navigation bars) and **ARIA26** (`aria-current`) `[R4]`. The
level matters: this is not an AA obligation, so the case for shipping it rests on orientation for
returning learners rather than on baseline conformance. Of the study's findings this is the cheapest
to close (one attribute and one style rule), and the only one where all seven benchmarked platforms
agree without exception.

**One asymmetry to state plainly.** The seven benchmark readings are **visual** — a still can show a
filled pill or an underline and nothing more. The baseline reading is **semantic**, queried against
the DOM. Nothing in this study establishes that any benchmarked platform exposes `aria-current`,
because a Mobbin still cannot show it. So the benchmark evidence supports the **visible** half at
7 of 7; the semantic half rests on R4 and on our own DOM query, not on the benchmark.

**How to validate this feature in the future.** This does not need a study. Ship the **visible**
treatment first, since that is the half the benchmark supports and the binding constraint for
learners scanning a page, then `aria-current` alongside it. Confirm in an accessibility audit that
the state is exposed to assistive technology and that its contrast passes 1.4.11, and add a
comprehension check ("which of these are you on?") rather than relying on the audit alone. Treat any
usability testing budget as better spent on F1 and F3.

> [Principal Researcher] **Baseline separation rule 2 is at its limit here.** `PLAN.md` binds the
> synthesis to "no `F#` may be *about* the baseline". In F2 the whole *What the system does* field
> is baseline-only, the rationale's payoff is our gap ("the cheapest to close"), and *How to
> validate* is a build instruction for our product rather than a way to test a benchmarked
> pattern. The benchmark content is one sentence listing six treatments plus the Codecademy
> second-order effect. F3, F4, and F5 are safely on the right side of the rule, since each carries
> real cross-platform analysis with the baseline as a contrast paragraph; F2 is the one that reads
> as a finding about us. The fix is not deletion: restate the subject as the benchmarked
> convention (what marking buys the learner, and Codecademy's tier-disambiguation use of it) and
> keep our absence as the contrast, the way F3 and F5 do.
>
> **External validation (B4).** The accessibility citation is correct and can be sharper. WCAG 2.2
> SC 2.4.8 *Location* is **Level AAA**, and its sufficient techniques are exactly G128 (indicating
> current location within navigation bars) and ARIA26 (`aria-current`) `[ref: R4 — see
> references.md]`. Name the level and the technique, per the house rule against claiming a
> standard the work does not state precisely.

---

## F3 — The learner-first block order, and the boundary after it

**Short description.** The first block of a benchmarked home belongs to the learner or to the
material. The rule holds on **6 of 7** platforms; the single exception is selling something, and it
is the case our baseline most resembles.

**Key findings.**

*What the user sees.* Six of the seven put the learner or the material first.
[Uxcel](https://mobbin.com/screens/54c0aa01-9380-4e13-bc41-01e46dba6812) opens with
`Continue learning` and a resume card, then `Recommended for you`, then
[events and an external resources grid](https://mobbin.com/screens/484afd14-1406-48d8-9612-ff1ac2dba068).
[Coursera](https://mobbin.com/screens/18683325-d982-4756-b06e-4ed52c933b06) opens with
`Continue learning` and a weekly-goal card, then a career-goal strip, then
[degree merchandising](https://mobbin.com/screens/558911ab-f326-4158-ab38-8e27a21ca639).
[Duolingo web](https://mobbin.com/screens/7baac688-9b35-4fc1-bbfd-f8bf8803a8f5) opens with the
unit banner and the lesson path: the material itself, immediately.
[Babbel web](https://mobbin.com/screens/5c06bda9-0458-437b-a68d-89ce396237e7) opens with the
learner's name (`Hi, <name>`) above the tab switch and all content, which is learner-owned rather
than company content.
[Mimo](https://mobbin.com/screens/e466340b-80ce-4a91-b557-14d55afcf4c9) opens with learner counter
chips, a path selector, then the unit pill and path.
[Speak](https://mobbin.com/screens/a7b59b62-1a06-49b9-b386-5508bbfe97af) opens with a level chip and
streak chip, then `UNIT 1` and the staggered path.

*Two published positions inside the rule.* Duolingo states **where you are in the material**; Babbel
greets **the person**. The study does not recommend one over the other, per `babbel/notes.md`
Observation 5 — what matters is that something belonging to the learner or the material occupies the
slot in both.

*The ordering principle.* Uxcel's sequence moves outward from the learner at every step: what you
are doing → what you might do → what is happening → where else to go. Coursera's is blunter: there
is a point in the page after which nothing belongs to the learner, and it comes after the goal
strip.

> **Citation repaired at peer review.** The earlier version of the Uxcel ladder read "then
> [a bulletin board, events, and an external resources grid]" citing screen `484afd14`. Two errors:
> `484afd14` is reference 03, *Home scrolled to events and Resources grid*, and does not contain the
> bulletin board; the `Bulletin board` is on reference 02,
> [`87e7ea64`](https://mobbin.com/screens/87e7ea64-c846-4ee9-8c79-6cfa2d5baa90), which is the
> **zero-course** home. Reference 02's boundary note permits citing it for block order and bars
> re-deriving its zero-state composition, so the bulletin board's position is observed **on the
> zero-course home only** and is stated with that label rather than folded into the populated
> sequence.

*The counter-case.* [Codecademy](https://mobbin.com/screens/df5c6018-fbf8-4473-88ba-4f7c02ba17ad)
inverts it. A full-width promotional countdown bar sits above the entire application, then a
`Codecademy bootcamps` carousel, and only then `Keep learning` with the learner's actual progress.
Four of its four captured screens carry at least one commercial slot. Recorded as observed
context, not as a model.

*The baseline.* Ordinal sequence: account-verification banner → `h1` product positioning plus a
paragraph of design philosophy → goal line → greeting → coach card (393px) → objective card
carrying the primary CTA. **Three blocks stand between arrival and the primary action, and the first
two belong to the company** — which is the cross-platform comparison, stated ordinally on the same
basis as the six readings above.

*Measurement basis.* The baseline's CTA sits at **y≈1001 of a 1577px page**, roughly 63% down, at a
1600 × 619 viewport. That is a **pixel measurement at one known viewport** and is not on the same
scale as the ordinal benchmark readings, none of which carries a viewport height. It is recorded
here as a fact about our own product, not as a comparison.

![Objective card and primary CTA at y≈1001](platforms/solve-education-staging/screenshots/02-home-objective-card-and-cta.png)

**Why this feature works (rationale).** A returning learner arrives with an intention already
formed. Content above their next action is a tax on that intention, paid every session. The
benchmark platforms treat the first screenful as belonging to the learner and defer everything
else, which is why Uxcel can carry **three further blocks** on its populated home without cost
(`Recommended for you`, events, the resources grid): they are all below the thing the learner came
for. Our baseline's first two blocks explain the product to someone who has
already signed in and already knows what it is, which is onboarding content persisting into
steady-state use.

**How to validate this feature in the future.** A **five-second test** on the current home versus
a reordered variant (objective card first, philosophy removed), asking "what can you do here?",
scoring the proportion naming the day's task. Then an **A/B test** on the reordered home measuring
time-to-first-task-start and the share of sessions reaching a task within 30 seconds. Guard
metric: no drop in goal comprehension when the philosophy paragraph is removed.

---

## F4 — One filled action per screen

**Short description.** Every benchmarked screen ranks one action above the rest, and **on the four
home screens where the full control set was enumerated**, none carries more than one filled control.
Some rank without a filled control at all. Fill is the cheapest ranking device available and the one
that survives a narrow column.

> **Scope bounded at peer review.** The earlier wording — "none carries more than one filled
> control" — quantified over all 33 reference screens, and fill was enumerated on four:
> Codecademy reference 01, Uxcel reference 01's centre column, Duolingo web reference 01, and
> Babbel's `Today`. Two captured screens describe controls the universal could not survive and
> whose fill was never recorded: `babbel/flow.md` step 6 (`Learning plan`, a per-row `Start lesson`
> on five rows plus two rail buttons) and step 7 (`Explore`, a per-lesson `Start now`). The claim is
> bounded to what was counted; the **ranking device** half is unaffected and holds on 7 of 7.

> [Principal Researcher] "Exactly one" is falsified by this finding's own third example: Duolingo
> web "ranks without a button anywhere", so that screen carries **zero** filled controls, not one.
> The claim the evidence supports is *at most one*, plus a separate claim that every benchmarked
> screen ranks something. Rewrite the short description and Overview headline 4 together.

**Key findings.**

*What the user sees.* [Codecademy](https://mobbin.com/screens/df5c6018-fbf8-4473-88ba-4f7c02ba17ad)
is the clearest instance: a three-way control row (`View path`, `Start practice session 0/1 today`,
`Resume →`) where only `Resume` is colour-filled and the other two are plain text. Three adjacent
actions and the ranking still reads.
[Uxcel](https://mobbin.com/screens/54c0aa01-9380-4e13-bc41-01e46dba6812) ranks by section order
plus sole possession of a filled button: `Resume course` is filled, and the recommendation cards
below carry no buttons at all.
[Duolingo web](https://mobbin.com/screens/7baac688-9b35-4fc1-bbfd-f8bf8803a8f5) ranks without a
button anywhere: the next node is larger, coloured against grey siblings, and carries a `START`
pointer.

*Platform-dependent devices.* Duolingo ranks by **elevation within a sequence** on web, but on
[iOS](https://mobbin.com/screens/3ecf07e8-cea8-4414-b5d9-05cd21033429) it stops trusting position
and lays an explicit full-width card with a `START +25 XP` button over the path. Position ranks in
a wide multi-column layout; width and fill rank in a narrow one.

*The baseline.* Seven actionable elements in `main`. **Two of them are filled dark pills**:
`Start this →` at y≈694 inside the coach card, and the true primary
`Start · one task, then you're done →` at y≈1001. Near-identical treatment, 307px apart, and the
secondary one comes first in reading order.

**Why this feature works (rationale).** Ranking by fill is a single binary signal a learner
resolves pre-attentively, before reading any label. It degrades gracefully: it works in one
column, at any width, and it costs nothing. Its precondition is scarcity: the device carries
information only while exactly one control uses it. Our baseline spends the signal twice, so the
learner's first filled-button match is the wrong action, and the correct one sits 307px further
down.

> [Principal Researcher] **External validation (B4): corroborated, and the mechanism is nameable.**
> Treisman & Gelade's feature-integration theory is the direct support. A target defined by a
> single unique feature is found in parallel and its detection time is flat in set size, while a
> target defined by a *conjunction* of features is searched serially `[ref: R5 — see
> references.md]`. That is precisely the scarcity precondition this rationale states: fill is a
> pop-out cue only while exactly one control owns it, and a second filled pill converts the search
> from feature to conjunction (fill *and* position *and* label). Cite it, and use "feature
> singleton" rather than the looser "pre-attentively".

**How to validate this feature in the future.** A **first-click test** on the current home versus
a variant where `Start this →` is demoted to a text link, measuring the share of first clicks
landing on the intended primary action. Instrument the live home for click distribution across the
two buttons before changing anything, so the baseline rate is known. Success criterion: primary
CTA takes the majority of first clicks in the variant.

---

## F5 — Progress separated by permanence

**Short description.** Benchmarked platforms split progress signals by how often the learner needs
them: a small persistent counter stays on the home, the detailed record moves to a place visited
deliberately.

**Key findings.**

*What the user sees.* Five distinct arrangements.
[Duolingo web](https://mobbin.com/screens/7baac688-9b35-4fc1-bbfd-f8bf8803a8f5) runs three tiers:
always-visible counters in a rail strip (streak, gems), always-visible rail cards (league, daily
quests), and a separate [Statistics destination](https://mobbin.com/screens/6ff49359-fff4-4ea2-97f2-50097b0873ac)
holding total XP, a weekly chart, and achievements.
[Uxcel](https://mobbin.com/screens/54c0aa01-9380-4e13-bc41-01e46dba6812) puts the daily signal in
a persistent rail, ordered offer → streak → league.
[Babbel iOS](https://mobbin.com/screens/cec0c04f-7eaa-4e20-aa0e-c23642cb54c6) puts an activity
tracker in the content flow and the record in a
[profile sheet](https://mobbin.com/screens/65435f22-30a8-440c-9868-8fb64d41c7e9).
[Speak](https://mobbin.com/screens/9d2d3577-07a1-45db-acf1-42dc269d0216) puts courses and a
reverse-chronological activity log on `Profile`.
[Codecademy](https://mobbin.com/screens/df5c6018-fbf8-4473-88ba-4f7c02ba17ad) is the counter-case:
progress is not a place at all, but an attribute of whichever card owns the work, with `1%` inside the
resume card and `4 / 9 concepts practiced` inside a course row.

*Coursera runs two goal horizons at once.* On `Home`, a `Weekly goal progress tracker` card renders a
**behavioural** goal as seven weekday circles, and a separate full-width strip states the **career
outcome** goal as a sentence with an `Edit goal` affordance; on `My Learning` both move into a right
rail ([home](https://mobbin.com/screens/18683325-d982-4756-b06e-4ed52c933b06),
[My Learning](https://mobbin.com/screens/ff884482-7343-4d72-b38d-74436b6dc450)). The two are
visually distinct registers: the weekly goal is a widget, the career goal is prose. This is the
study's only instance of two horizons on one home, so it is a documented **n=1 variant**, not a rule.

*What the separation rule actually holds at.* The earlier wording, "In five of six, the home carries
**one small signal** and the detail lives elsewhere", is **not reproducible from the platform notes**
and is corrected here. Per platform:

| Platform | Small home signal | Detail destination | Clean fit |
|---|---|---|---|
| Duolingo | rail counters | `Statistics` page | ✓ |
| Babbel | activity tracker / header chip | profile **sheet** | ✓ |
| Speak | streak chip | `Profile` tab | ✓ |
| Uxcel | rail: offer → streak → league (three cards) | **none in the captured set** | partial |
| Mimo | header chips + unit ring | tiles on `Practice`, a **peer tab** | partial |
| Coursera | weekly-goal widget + career strip | **unobserved** | partial |
| Codecademy | `1%` in the card that owns the work | none | dissent |

**Clean fits: 3 of 7.** The separation is a documented range of arrangements rather than a rule with
a denominator, and Q5 asked only for region and count, which the captures answer at High confidence.

*A device worth isolating.* [Mimo](https://mobbin.com/screens/e466340b-80ce-4a91-b557-14d55afcf4c9)
attaches a `58%` ring directly to the current unit's name pill. It measures one named thing and
sits on that thing, rather than summarising the learner in the abstract.

*The baseline.* Progress occupies primary-column space at five points simultaneously: four
labelled skill bars in the page's tallest block (393px), a `READINESS NOW` panel at `0%` inside the
objective card, a `GOAL` cell reading `Customer Support · in progress · 0%`, a `VERIFIED EVIDENCE`
cell reading `0 proofs`, and `READINESS 0%` in the hero line. **Readiness `0%` appears twice and
the goal name three times.**

![Strip carrying evidence, focus, and goal cells](platforms/solve-education-staging/screenshots/03-home-strip-library-design-rule.png)

**Why this feature works (rationale).** A progress display answers two different questions with
different frequencies: *did I show up today* (every session, one glance) and *how am I doing
overall* (occasionally, with attention). Collapsing both into the primary column means the
frequent question is answered by a block sized for the infrequent one, and the learner pays that
cost every visit. Our four-competency breakdown is detailed-record content sitting in the position
those platforms reserve for a single daily counter, and it sits **above** the primary action.

> [Principal Researcher] **External validation (B4): corroborated, with a mechanism the finding is
> not yet using.** Kivetz, Urminsky & Zheng (2006) show effort rises as a visible goal nears
> completion, and that the effect tracks *perceived* progress rather than real progress
> `[ref: R6 — see references.md]`. That strengthens the case for keeping one persistent daily
> signal on the home. It also sharpens the baseline reading beyond "too much space": readiness
> stated as `0%` twice supplies **no gradient at all**, so the space is spent on a display that
> cannot produce the motivational effect the space is being spent for. Worth adding, since it is a
> different objection from the one about block size, and a stronger one.

**How to validate this feature in the future.** A **desirability and comprehension test**: show
the current coach card and a reduced variant (one readiness figure plus a link to a detail view),
asking learners to state their standing and what to do next, scoring accuracy and time. Then
instrument the live home for engagement with the skill bars. If the detailed breakdown is rarely
read, it does not deserve 393px above the fold. **Success criterion: stated-standing accuracy in
the reduced variant falls no more than 10 percentage points below the current card, and
time-to-state-next-action improves; if accuracy holds within that margin, the detail moves off the
home.** Treat the skill bars as a deletion candidate if fewer than 10% of sessions interact with
them.

---

## F6 — The resume control names the specific next item and its cost

> **Scope note, added at peer review.** F6 answers **no planned `Q#`** and is retained as a
> deliberate out-of-scope observation. It reports the resume control's **copy**, and `README.md`
> scopes copy out ("The content *inside* the blocks — copy quality, recommendation relevance, lesson
> design. This study reads structure, not substance"). It has been **removed from the Q3 coverage
> row** for that reason. It is kept rather than deleted because it is well evidenced and is the one
> place the baseline scores well; it is routed to a future content review.

**Short description.** The strongest resume controls in the set do not offer a course; they offer
one named, time-bounded thing.

**Key findings.**

*What the user sees.* [Uxcel](https://mobbin.com/screens/54c0aa01-9380-4e13-bc41-01e46dba6812)
states `Current Lesson: The Anatomy of UI Components`, a `6%` bar, and `7h left`.
[Coursera](https://mobbin.com/screens/18683325-d982-4756-b06e-4ed52c933b06) splits its card in two,
identity and progress on the left, and on the right the specific next item
(`Welcome to module 1`, `Video (1 minute)`) beside a filled `Resume`.
[Mimo](https://mobbin.com/screens/0fc493a3-6e4a-4571-ad2c-28e0cbce2908) leads its daily card with
a category label, a title, and `⚡ 10 min` before the button; its past-topic cards put duration
before title too.

*The recurring element.* **Three of seven** platforms name the next item by title rather than naming
the course (Uxcel, Coursera, Mimo), and three state a time cost alongside it.

*Retracted at peer review: remaining cost versus percentage complete.* The earlier reading — that
`7h left` and `10 min` are remaining-cost claims that outperform percentage-complete ones — is
**confounded and untested.** Uxcel's card carries `6%` **and** `7h left` on the same screen
(`uxcel/flow.md` step 2), so no capture in this study isolates the two framings, and Mimo's
`⚡ 10 min` is a duration estimate for a fresh item rather than a remaining cost. R7 (Dhar) covers
deferral under preference uncertainty and does not cover this comparison. The claim is moved into
*How to validate* as the thing the step tests.

*The baseline does this well.* Our objective card states `Angry customer`, `practice · ~8 min ·
targets your weakest skill`, a one-line scenario, and `Start · one task, then you're done →`. It
names the item, bounds the commitment, and says why this item. On content, it matches the best in
the set. The defect established in F3 and F4 is position and competition, not the card.

**Why this feature works (rationale).** Resuming is a decision under uncertainty: an unbounded
"continue course" asks the learner to commit to an unknown quantity of time, and the safe answer
is to defer. Naming the item and its cost converts it into a bounded decision about one small
known thing.

*Retracted at peer review.* The earlier claim that "stating remaining cost rather than percentage
complete matters at low progress, where `6%` reads as discouraging while `7h left` reads as a plan"
is **confounded and not asserted**. See *The recurring element* above; it is now the question the
validation step tests.

> [Principal Researcher] **External validation (B4): corroborated.** "The safe answer is to defer"
> is the documented behaviour, not an intuition. Dhar (1997) shows across seven studies that
> preference uncertainty raises **choice deferral**, and that deferral tracks the absolute
> attractiveness of the options rather than trade-off difficulty `[ref: R7 — see references.md]`.
> Naming the item and bounding its cost raises absolute attractiveness, which is the mechanism
> this rationale is reaching for. The second half of the claim, that remaining-cost framing beats
> percentage-complete framing at low progress, is **not** covered by that source and remains an
> untested reading of two captures. Label it as such, or make it the thing the validation step
> tests.

**How to validate this feature in the future.** Since the baseline already implements this, the
open question is whether `~8 min` is *believed*. Instrument actual task duration against the
stated estimate and measure the gap; a systematically optimistic estimate erodes trust in every
future estimate. Success criterion: median actual duration within 25% of stated. Pair with a
**post-task question** ("was that about as long as you expected?").

---

## F7 — The mobile tab budget: three to five, labelled

**Short description.** Phone homes in the set carry three to five destinations in a bottom tab bar,
each with a text label. The one platform exceeding five drops its labels and adds an overflow.

> **Hypothesis for validation, not a benchmarked finding.** All evidence is native iOS; our target
> is Android mobile web. See `## Gaps & caveats`.

**Key findings.**

*What the user sees.*
[Babbel iOS](https://mobbin.com/screens/6a031570-7a5a-4007-a0f0-4ccf5dc47e1b): three tabs, icon
above text label: `Home`, `Review`, `Explore`.
[Mimo](https://mobbin.com/screens/e466340b-80ce-4a91-b557-14d55afcf4c9): five, labelled: `Learn`,
`Practice`, `Build`, `Leaderboard`, `Profile`.
[Speak](https://mobbin.com/screens/a7b59b62-1a06-49b9-b386-5508bbfe97af): five, labelled: `Home`,
`Free Talk`, `Review`, `Challenge`, `Profile`.
[Duolingo iOS](https://mobbin.com/screens/02544e61-aefd-4d89-815e-ffcc83d83539): six, **icon only,
no text labels**, terminating in a `…` overflow.

*The pattern.* Three of four label their tabs. The one that does not is also the only one
exceeding five and the only one needing an overflow. Read as a budget: past roughly five, either
the labels go or a tail goes behind an overflow.

*Cross-platform consistency.* Babbel's three iOS destinations are **the identical three** as its
web nav, in the same order. Duolingo's **counts** differ (8 web, 6 iOS); its iOS **set** cannot be
compared, because `duolingo/notes.md` records that the icon-only bar makes tab identities beyond the
active one unreadable and therefore unasserted. Two published positions on whether mobile IA should
mirror desktop IA, one of which is established on counts alone.

**Why this feature works (rationale).** A bottom tab bar's width is fixed by the device, so each
added destination shrinks the touch target and the label space. At six, Duolingo can no longer fit
legible labels and trades them for icons. That works for a product whose icon vocabulary is
already learned by daily users, and would not work for a first-time learner meeting `Ladders` or
`Evidence` as an unlabelled glyph. Babbel's mirror-the-desktop approach costs nothing when the top
level is already three; **mirroring eleven is not available to us under this budget**, which is a
prediction from the three-to-five range below and not an observation, since no eleven-item tab bar
was observed at any width in this study.

**The count converges with published convention, which is not the same as independent evidence.**
Material Design specifies **three to five** top-level destinations for a bottom navigation bar,
giving tap-target crowding past five as the reason `[R8]`. Three qualifications, all recalibrated at
peer review: it is a **normative design specification, not a study**, so it does not empirically
confirm the four apps; the cited page is the **archived Material Design 1** spec, not current
guidance; and its subject is a **native Android app's** bottom bar, while our target is Android
**mobile web**, where a fixed bottom bar competes with browser chrome for scarce vertical space.
Convention and the four-app sample plausibly share one ancestry, so the corroboration is convergent
rather than independent — and Duolingo's own six-tab bar is a published counter-instance to the same
guidance. **F7 therefore keeps full hypothesis weight on the count as on everything else.** The
three-to-five reading across four apps stands on its own and does not need the upgrade. Apple's Human
Interface Guidelines are reported to give the same range, but the page body could not be retrieved, so
it is not cited (see `references.md`, *Sought and not verified*).

*Mechanism marked as inferred.* "Each added destination shrinks the touch target and the label space",
and Duolingo's trade of labels for icons at six, are **inferred from one platform**. This study holds
no evidence on label length in any language other than English, and Bahasa strings run materially
longer — see `## Gaps & caveats`, localization.

> [Principal Researcher] **External validation (B4): corroborated by a source outside the sample**,
> which matters more here than anywhere else in the study. Material Design specifies "three to five
> top-level destinations" for a bottom navigation bar and gives the reason as tap targets sitting
> too close together past five `[ref: R8 — see references.md]`. The three-to-five budget is
> therefore **published platform guidance**, not only a reading of four apps, and because it is
> Google's guidance it is the one piece of **Android-side** evidence this finding otherwise lacks
> entirely. Citing it would let F7 shed some hypothesis weight on the *count* while keeping it on
> everything else. Apple's Human Interface Guidelines are widely reported to give the same
> three-to-five range, but the page body could not be retrieved, so it is **not** cited. See
> `references.md`, *Sought and not verified*.
>
> Separately: "**it would be impossible at eleven**" is stated flat, about our own product, at a
> width nobody in this study observed. That is the exact claim the F7 hypothesis banner exists to
> prevent. Either hedge it or move it under the banner's scope explicitly.

**How to validate this feature in the future.** Before designing a mobile home, run a **tree test**
on our proposed mobile IA (whatever four or five destinations we shortlist), measuring task success
and directness for the same eight tasks used in F1. Then a **moderated session on a real
Android device at 360px**, since every input here is iOS. Success criterion: ≥80% task success on
the tree test before any visual design begins.

---

## F8 — When the rail disappears, the signal migrates or dies

**Short description.** Desktop homes put progress in a side rail. Phones have no side rail, and the
two platforms in the set with both handle the loss in opposite ways.

> **Hypothesis for validation, not a benchmarked finding.**

**Key findings.**

*Duolingo deletes.* Its web home carries a persistent right rail holding a stats strip, a
`Silver League` card, and a `Daily Quests` card
([web](https://mobbin.com/screens/7baac688-9b35-4fc1-bbfd-f8bf8803a8f5)). On
[iOS](https://mobbin.com/screens/02544e61-aefd-4d89-815e-ffcc83d83539) the league and quests are
**not on the home at all**; only the top counter strip survives. The rail content does not move
below the path; it leaves.

*Babbel migrates.* Its web `Today` tab carries no goal signal in the content column at all. The
lesson-count progress lives in a rail that appears only on `Learning plan`
([web](https://mobbin.com/screens/906d0d44-a4e4-4d54-800b-bba8a4dfe715)). On
[iOS](https://mobbin.com/screens/cec0c04f-7eaa-4e20-aa0e-c23642cb54c6) an `Activity tracker` bar
appears **in the primary column**, above the lesson card. The signal moves inward and is promoted.

*A structural precondition.* Babbel's rail is already **conditional** (present on one tab, absent
on another), while Duolingo's, Uxcel's, and Circle's are persistent shells. A rail the layout does
not depend on is far easier to collapse than one it does.

**Why this feature works (rationale).** The two strategies encode different judgements about what
the signal is for. Duolingo's league and quests are competitive and social: content a learner
seeks out, so losing it from a cramped home costs little. Babbel's activity tracker is a
commitment device tied to a weekly goal, and a commitment device the learner cannot see does not
work, so it earns promotion into the scarce column. The proposed test is not "does this fit" but
"does this stop functioning if unseen."

**That rule is hypothesis-generating, not a finding.** It was derived from the only two web-and-iOS
pairs in the set, which produced **opposite** outcomes, and any two opposite observations admit a
post-hoc partition. `babbel/notes.md` Observation 3 states the disciplined version: *two options, not
a rule.* `references.md` records that no literature was found for the *sought* versus *must-be-seen*
distinction. Treat it as a hypothesis with the success criterion below as its test.

**The stronger claim in this finding is the structural one, and it is not n=2.** Across four web
platforms the rail splits two ways: the rail as **persistent shell** (Duolingo, Uxcel — present on
every home view) and the rail as **per-view content** (Babbel, present only on `Learning plan`;
Coursera, absent on `Home` and present on `My Learning`). A rail the layout does not depend on is
cheaper to collapse at narrow width than one it does. Recorded independently in `babbel/notes.md`
Observation 4 and `coursera/notes.md` Observation 5.

**How to validate this feature in the future.** When a mobile home is designed, classify each
current signal as *sought* or *must-be-seen*, then prototype both treatments and run a **two-week
retention comparison** measuring 7-day return rate and weekly-goal completion. **Success criterion:
migration is justified only where deleting the signal costs more than 5 percentage points of 7-day
return rate or weekly-goal completion; at or below that margin, delete it rather than spend
primary-column space on it.** Cheaper interim proxy: instrument the desktop home for engagement
with each progress element, treating any element interacted with in under 10% of sessions as a
deletion candidate.

> [Principal Researcher] This is the only one of the nine validation steps with **no success
> criterion**. It names a method (two-week diary or retention comparison) and two measures (return
> rate, goal completion) but never says what result would decide between migrating and deleting.
> Without a threshold the step cannot fail, so it cannot settle the finding. Give it one, the way
> F6 (`within 25% of stated`) and F9 (`under 10 seconds`, `≥6 of 8`) do. F5's "no loss in
> stated-standing accuracy" is the second-softest and would also benefit from a stated margin.

---

## F9 — The mobile home is one thing scrolled, not a stack of blocks

**Short description.** **No phone home in the set stacks the desktop's secondary blocks beneath the
primary object.** Each disposes of them instead: by moving them to another tab (Mimo to `Practice`,
Speak to `Profile`), by pushing them down a sub-level (Babbel to `Learning plan` and a profile
sheet), or by dropping them (Duolingo drops league and quests). **4 of 4.**

> **Restated at peer review.** The earlier wording — "Phone homes in the set carry a single dominant
> content object, and split secondary material onto other tabs rather than stacking it below" — fails
> on two counts. Babbel iOS is a **stack**: `babbel/flow.md` steps 10 to 12 record an `Activity
> tracker` bar *above* the lesson card and a horizontal further-lessons row *below* it. And Duolingo
> **deletes** rather than divides, so "split onto other tabs" does not describe it. The claim above is
> the version that holds on all four, and it keeps the design payload intact.

> **Hypothesis for validation, not a benchmarked finding.**

**Key findings.**

*What the user sees.* [Duolingo iOS](https://mobbin.com/screens/673d73bb-bb22-4481-8f14-7cf966c9e7bd)
scrolls to reveal more lesson path and nothing else: no secondary section, no rail content, no
promotional block within the captured range.
[Speak](https://mobbin.com/screens/a7b59b62-1a06-49b9-b386-5508bbfe97af) fits five named steps into
roughly one screen by **staggering** cards horizontally rather than stacking them in a column, then
puts courses and history on `Profile`.
[Mimo](https://mobbin.com/screens/e466340b-80ce-4a91-b557-14d55afcf4c9) splits the home across two
tabs by rhythm: `Learn` is the long arc through the curriculum and carries nothing else;
[`Practice`](https://mobbin.com/screens/3bd10950-73fa-4189-97f1-4c35e3400111) is the four-block
stack: daily review, past topics, progress tiles, playgrounds.

*The division principle.* Mimo's split is the clearest: the arc and today's work are different
surfaces with different visit frequencies, not two sections of one page. Speak's is the same split
under different names (`Home` for the unit path, `Profile` for courses and log).

*The baseline for contrast.* Our home stacks the arc (four skill bars), today's work (objective
card), and the record (readiness, evidence, goal) into one scrolling column, which is what pushes
the primary action to 63% of the page, on a viewport nearly three times wider than a phone.

**Why this feature works (rationale).** A phone column can hold roughly one meaningful object per
screenful, so stacking N blocks costs N screenfuls of scrolling and buries whichever is Nth. Tabs
convert that vertical cost into a horizontal choice paid once. The split also matches session
shape: a learner opening the app to do today's task and one reviewing their overall trajectory are
in different modes, and a surface serving both serves neither well.

**How to validate this feature in the future.** Prototype two mobile homes, a single scrolling
column and a two-tab split (`Today` / `Progress`), then run a **moderated comparison on Android at
360px** (n≈8), measuring time-to-task-start and asking participants to locate their overall
standing. Success criterion: task start under 10 seconds in the winning variant, with standing
locatable by ≥6 of 8.

---

## Design implications for `design/learning-home`

Required by `PLAN.md` success criterion 6: one implication per answered question, each stated so
that an observation could falsify it, and a **recommendation** on the baseline's flat eleven rather
than a description of the alternatives.

**DI1 (from Q1 / F1, F2) — Adopt a device, not a shorter list. Keep all eleven destinations, do not
push them deeper, and treat the specific grouping as the card sort's output rather than this study's.**

**The recommendation, which is what `PLAN.md` criterion 6 requires.** Two structural devices are
available and neither requires deleting a destination: **Codecademy's two-tier scope split** (both
tiers simultaneously visible, adding no depth) and **Uxcel's static purpose headings** (all
destinations visible, headings naming the learner's purpose, corroborated outside education by
Circle). Both are observed on the two platforms that carry **more** destinations than we do, which
makes them the right comparison class for an eleven-item nav.

**Two binding constraints on how it is built.**

1. **Static labels, not collapsible groups.** Uxcel's headings are static small-caps labels with all
   thirteen destinations visible (`uxcel/flow.md` step 1), and `circle/flow.md` explicitly declines to
   assert whether Circle's headings collapse. Collapsible groups are **unobserved in this study**, and
   they would convert breadth into depth — the arm R1 penalises. If we ship collapse, we inherit the
   cost this implication exists to avoid.
2. **All eleven visible at all times.** The device reorganises; it does not hide.

*Why not the other devices.* **Babbel's push-depth-down is rejected**: Larson and Czerwinski found
increased depth harmed search performance, with a medium breadth-and-depth structure beating the
broadest-shallow one on reaction time and lostness `[R1]`, so trading breadth for depth is not a
neutral swap. Note R1's other arm honestly: the broadest-shallow condition also lost to the medium
one, and R1 ran 512 items in 8³ / 16×32 / 32×16 arrangements, so **no arm of it resembles eleven** and
it cannot adjudicate our exact case in either direction. It rules out depth; it does not certify
breadth.

**Demoted to a candidate mapping, conditional on work this study did not do.** A specific assignment
of the eleven to tiers and groups is *not* recommended here, because `## Gaps & caveats` names the
prerequisite and this study did not meet it: only `Home` was captured, so **ten of the eleven
destinations were never opened**, and we cannot say whether any are duplicative. Assigning them on
their **names alone** would be a content judgement made without the content. The candidate below is
the card sort's **input**, not its output:

| Tier | Candidate destinations | Rule |
|---|---|---|
| Product-wide (top row, with the existing utilities) | `Catalog`, `Opportunities`, `Referral` | things that exist |
| Learner-owned (primary nav) | `Home`, `Inbox`, `Ladders`, `Practice`, `Challenges`, `Evidence`, `Credentials`, `Applications` | things you have |

**Reject any grouping with a single-member cluster.** The earlier version proposed `Apply`
(`Applications`) as a group of one. No group in the benchmark set is smaller than three, and a
one-item group adds a heading and a level without reducing scan units, which is the opposite of what
the two-step-lookup argument asks for. Both Uxcel and Circle place singletons **ungrouped at the
head**, which is where ours belong.

**The gate, in order:** (1) content inventory of the ten unopened destinations; (2) **open card sort,
n≈15, run in Bahasa Indonesia** — an English card sort validates English labels, and short UI strings
expand substantially on localization, so the labels tested must be the labels that ship; (3) stratify
the sample by **facilitated versus self-directed arrival**, since a facilitator saying "tap Practice"
values stable nameable destinations differently from a self-directed learner; (4) first-click test on
the resulting variants.

*Falsified if:* the card sort produces learner clusters that map to neither a scope split nor a
purpose split, or a first-click test shows a grouped variant no faster than the flat baseline on a
majority of the eight tasks.

*Transfer status:* the **devices** are observed on Western, paid, adult-professional products
(Codecademy, Uxcel) and one non-education control. Per `## Gaps & caveats`, the grouping *device*
transfers and the *specific groups* do not, which is precisely why the memberships are demoted here.

**DI2 (from Q1 / F2) — Mark the current location in the navigation.** All nine benchmarked surfaces
do; ours does not. **Ship the visible treatment first** — that is the half the benchmark supports
(7 of 7 platforms, 9 of 9 surfaces) and the binding constraint for a learner scanning the page — then
`aria-current="page"` alongside it. WCAG 2.2 SC 2.4.8 *Location* is **Level AAA**, with G128 and
ARIA26 as sufficient techniques `[R4]`, so the case rests on orientation rather than on AA
conformance. *Falsified if:* an accessibility audit finds the state is not exposed to assistive
technology, the visible treatment fails 1.4.11 contrast, or a comprehension check ("which of these are
you on?") shows learners cannot identify their location. Needs no separate study.

*Transfer status:* device-level and audience-neutral. Every platform in the set marks location and the
mechanism does not depend on audience.

**DI3 (from Q2 / F3) — Move the learner's next action into the first screenful, and put company
content below it.** Remove the `h1` positioning line and the design-philosophy paragraph from the
steady-state home; they are onboarding content persisting into repeat use. **Three company-owned
blocks currently occupy the top of the page**, which is the measurable version of the claim.

*The proposed order* — objective card → progress → library → everything else — **is a proposal, not a
sequence read off the benchmark.** No benchmarked platform runs exactly this order: Uxcel runs course
→ recommended → events → resources with progress in a rail, and Coursera runs resume plus weekly goal
→ career strip → merchandising. What the benchmark supports is the *principle* (the learner's own work
first, company content after), not this specific ordering.

*Falsified if:* a five-second test shows goal comprehension drops when the philosophy paragraph is
removed, or an A/B test shows no improvement in the share of sessions starting a task within 30
seconds.

*Transfer status:* the principle holds on 6 of 7 platforms including the two closest to our audience
on price (Duolingo) and is the least audience-dependent finding in the set.

**DI4 (from Q3 / F4) — Spend the filled-control signal once per screen.** Demote `Start this →` in
the coach card to a text link so `Start · one task, then you're done →` is the only filled control.
The fill rule is bounded to the four benchmarked home screens where the full control set was
enumerated (see F4), which is enough to carry this change.

*An alternative explanation to distinguish, not assume away.* Two near-identical filled buttons 307px
apart may indicate the product ships **two competing "today's task" concepts** (`TODAY'S NEXT MOVE ·
PRACTICE` inside the coach card, and `TODAY'S OBJECTIVE`). If so, demoting one to a text link treats a
content-duplication problem as a styling problem, and the second button will be rebuilt. The
first-click test should distinguish the two readings.

*On the objective card's copy:* it names the item and bounds the cost, which matches the best resume
controls in the set. Recorded as an **observation**, not a directive — F6 is out of this study's scope
(see its scope note).

*Falsified if:* a first-click test shows the primary CTA still fails to take the majority of first
clicks after the demotion, which would mean position, or content duplication, not fill, is the binding
constraint.

*Transfer status:* device-level; the mechanism (a single distinguishing visual feature) does not depend
on audience, and scarcity matters more for novice users, not less.

**DI5 (from Q5 / F5) — Separate the daily signal from the detailed record, and run two goal horizons
rather than one.** Keep one readiness figure on the home; move the four-competency breakdown to its own
destination reached from it. State readiness once, not twice.

**Add a behavioural horizon, modelled on Coursera.** Coursera runs a **weekly behavioural goal** (seven
weekday circles: did I show up) alongside a **career outcome goal** (a sentence with an edit
affordance: what am I working toward). Our home currently states the outcome twice and carries no
behavioural goal at all. For a *returning*-learner home, "did I show up this week" is the more
actionable of the two, and it is the one we are missing. This is an n=1 arrangement in the set, so it is
a model to test rather than a convention.

**Open question, not a citation.** A progress display's **reference frame** — whether it compares the
learner to peers, to their own past, or to an absolute standard — may matter more than the region it
occupies, in which case relocating our four bars at `0%` is only half a change. The supporting
literature was identified at peer review but **not fully retrieved**, so it is recorded in
`references.md` under *Sought and not verified* and is **not** cited here. Resolve before DI5 reaches a
PRD.

*Falsified if:* the reduced variant costs more than 10 percentage points of stated-standing accuracy
(F5's criterion), which would mean the breakdown is load-bearing rather than decorative.

*Transfer status:* the region finding transfers; the reference-frame question is unresolved and the
behavioural-horizon model is n=1.

**DI6 (from Q4 / F7, F8, F9) — Treat the mobile home as a separate design with a five-destination
budget, not a reflow of the desktop one.** Shortlist at most five labelled top-level destinations,
carry one dominant object on the home, and move the detailed record to a `Profile`-equivalent.

**State what happens to the other six.** The earlier version did not, and the choice decides whether
this helps or harms. The study observed **one** pattern: Duolingo keeps seven destinations permanently
visible and puts only the tail behind an overflow — `duolingo/notes.md` records that the overflow "is
**not** a hamburger replacing the nav". **A hamburger is not the pattern this evidence supports.** The
alternative the set also shows is pushing the tail down a level (Babbel). Choose one explicitly; do not
default to hiding the whole nav.

**The five-label budget is a pixel budget, and it was measured on English only.** Every label in the
set is a short English string, and short UI strings expand substantially on localization, so
`Kesempatan` / `Tantangan` / `Kredensial` in a five-slot bar at 360px is a different problem from
`Home` / `Review` / `Explore`. Recorded as an **assumption with no source retrieved in this study**;
validation path: measure the localized label set at 360px before fixing the count at five.

**Structural claims only.** Per `PLAN.md`'s Q4 guard, this implication may not prescribe an interaction
convention. Read "at most five top-level destinations, one dominant object, detailed record off the
home" as structure; the **mechanism** (whether a fixed bottom bar is even right in an Android browser,
where it competes with collapsing URL chrome) is left for the 360px session to settle.

**This implication rests on iOS evidence for an Android mobile-web target and must not reach a PRD as
fact.** The count converges with archived Material Design 1 guidance for native Android apps `[R8]`,
which is convention rather than independent evidence.

*Falsified if:* a tree test on the shortlisted five falls below 80% task success, or moderated sessions
at 360px on Android show the tab-bar idiom does not transfer to a browser context.

*Transfer status:* weakest in the set. Two-step transfer (iOS → web, iOS → Android), plus an untested
localization budget.

> **Scope note.** DI1 and DI6 both bear on navigation but answer different questions: DI1 is the
> desktop information architecture, DI6 is what survives the phone budget. They are not the same
> decision and should not be taken together without the card sort in DI1 running first.

---

## Boundary with `2026-07-28-post-signup-handoff-first-run-home`

Required by `PLAN.md` success criterion 5. One row per finding, naming the nearest neighbour
finding and the difference. **A row that cannot name a difference is a finding in the wrong study.**

| This study | Nearest neighbour finding | The difference |
|---|---|---|
| F1 — cardinality device | *(none)* | The neighbour never examined navigation. No overlap. |
| F2 — current-location signal | *(none)* | Same. Navigation was outside its scope entirely. |
| F3 — block order | **F4** (where the first-run primary action is computed from) | The neighbour asks *what* the action is at zero state and *why that one*; this asks *where in the page order* it sits at a populated state. Different question, different state. |
| F4 — one filled action | **F4** (Q4's unmeasured half) | The neighbour explicitly could not measure visual dominance at its captured viewport (`SYNTHESIS.md:79`) and reported presence and order instead. This study is its named validation route and answers the **device** question it left open. |
| F5 — progress by permanence | **F2** (the slot rule) | The neighbour asks *which* progress slots render before anything is earned and in what register. This asks *where in the layout* they sit once earned. Zero state versus populated; register versus region. |
| F6 — resume control content | **F4** | The neighbour establishes the primary action must come from stored intake at cold start. This describes what the control *says* once there is real progress to resume into. |
| F7 — mobile tab budget | *(none)* | The neighbour is desktop-web only (`README.md:77`). No mobile finding exists to overlap. |
| F8 — rail migration | *(none)* | Same. |
| F9 — mobile home shape | *(none)* | Same. |

Five of nine findings have no neighbour at all; the four that touch one each name a state or
dimension shift. No finding re-derives F1, F3, F5, F6, F7, F8, or F9 of the neighbouring study.

---

## Mobile home reference

Required by `PLAN.md` success criterion 7. Drawn from four iOS platforms.
**Every item here is a hypothesis for validation on Android mobile web**, not a benchmarked
finding: the evidence is native iOS and the target is an Android browser.

**Counting rule.** A **block** is a content section in the scroll flow. Persistent chrome does not
count: header counter strips, segmented controls, and the tab bar itself are excluded. Three rows
were rewritten at peer review after the counts proved irreproducible against the platform notes.

| Question | What the set shows | Spread |
|---|---|---|
| **Nav pattern** | Fixed bottom tab bar, every platform | 4 of 4 |
| **Tab count** | 3 (Babbel), 5 (Mimo), 5 (Speak), 6 (Duolingo) | 3–6 |
| **Labels** | Icon plus text label | 3 of 4; Duolingo at 6 tabs is icon-only |
| **Overflow** | None observed at ≤5; `…` at 6 | 1 of 4 |
| **Which destinations earn a tab** | A learning surface (3 of 3 assertable) and a review or practice surface (3 of 3). A profile tab in **2 of 3** — Babbel has none (`Home` / `Review` / `Explore`). **Duolingo is excluded from this row**: its icon-only bar makes tab identities beyond the active one unreadable, and `duolingo/notes.md` declines to assert them. **Dissent:** Mimo ships `Leaderboard`, against the earlier claim that community surfaces do not earn a tab. | 3 platforms, not 4 |
| **Block order on a phone** | Nothing is stacked *beneath* the primary object; secondary material is moved to another tab, pushed down a sub-level, or dropped. **Babbel is the counter-instance to a stricter reading**: it carries an `Activity tracker` above the lesson card and a further-lessons row below it. | 4 of 4 on the disposal claim |
| **Where progress goes without a rail** | A small counter stays on the home and the detailed record **moves to a destination: 3 of 4**. That destination is **`Profile` in 2 of 4** (Babbel's sheet, Speak's tab); Mimo moves its detail to `Practice`, a peer tab, and Mimo's `Profile` is unobserved. Duolingo deletes rather than moves. | 3 of 4 move; 2 of 4 to `Profile` |
| **How a sequence is laid out** | Single centred column (Duolingo, Mimo) or staggered cards (Speak) | 2 options |

**The number that matters for us.** Eleven labelled destinations will not fit a phone under any
arrangement in this set. A mobile home forces the demotion decision that desktop lets us defer.

---

## Nav cardinality comparison

Required by `PLAN.md` success criterion 4. **The baseline row is marked and excluded from every
tally.** Counts are *exposed* destinations. Where a nav terminates in an overflow, true depth is
undetermined.

| Surface | Platform | Exposed destinations | Device | Marks current location |
|---|---|---|---|---|
| Babbel | web | 3 | shallow top level | Yes (underline) |
| Babbel | iOS | 3 | shallow top level | Yes (tint) |
| Coursera | web | 4 learner tabs + utility row | type split | Yes (underline) |
| Mimo | iOS | 5 | none observed | Yes (tint) |
| Speak | iOS | 5 | none observed | Yes (tint) |
| Duolingo | iOS | 6 + `…` overflow | budget + overflow | Yes (filled) |
| Duolingo | web | 8 + `MORE` overflow | budget + overflow | Yes (filled pill) |
| Codecademy | web | 12 (6 + 6) | two tiers by scope | Yes (filled row, sidebar only) |
| Uxcel | web | 13 | grouped by purpose | Yes (filled pill) |
| *Circle (control, non-education)* | web | *14 + 5* | *grouping + two tiers* | *Yes (filled)* |
| **▶ BASELINE — Solve Education** | **web** | **11** | **none** | **No** |

**Tally across the 7 learning platforms (9 surfaces, baseline and control excluded):** **9 of 9 mark
the current location.** **7 of 9 have a device recorded**; the 2 that do not (Mimo, Speak) sit at 5
destinations.

> **Two corrections from peer review.** First, `none needed` has been replaced with **`none
> observed`** in the Mimo and Speak rows: this table records observations, and sufficiency is a
> judgement, not an observation. Second, the earlier clause "where no device is required" is
> **retracted**. Device presence is **not monotonic in cardinality** on this table's own values —
> Babbel at 3 and Coursera at 4 both carry devices, so 5 cannot be a threshold below which none is
> required. Speak also carries a `Course` / `Practice` segmented control (`speak/flow.md` step 1),
> which is the same sub-level device that earns Babbel its entry; on the typology's own definition
> the count would be 8 of 9. What the typology is actually measuring is left as an open question in
> `## Gaps & caveats`.

**Two platforms carry more destinations than the baseline, and both apply a device and mark
current location.** The baseline is the only surface in the study with neither.

*No legibility or scanning measure was taken on any platform. The claim above is what was
observed (a device is present, current location is marked), not a claim that these navigations are
easier to use. That comparison is what F1's first-click test is designed to measure.*

> [Principal Researcher] Two problems in this block.
> **The tally does not match the table.** "6 of 9 apply an explicit cardinality device; the 3 that
> do not (Babbel iOS, Mimo, Speak)" contradicts the table above it, which gives Babbel iOS the
> same `shallow top level` device as Babbel web. On the table's own values it is 7 of 9 with two
> exceptions (Mimo, Speak). Fix the tally or fix the two Babbel `Device` cells; they cannot both
> stand.
> **"Read cleanly" is unfalsifiable and appears twice** (here and in Overview headline 1). No
> legibility or scanning measure was taken on any platform, so this is an assertion of quality
> where the house vocabulary requires a criterion. Either state what was observed (both apply a
> device and both mark current location) or make it the thing F1's first-click test measures. Left
> unedited because cutting or rewriting it changes the claim.

---

## Gaps & caveats

**Q4's entire evidence base is native iOS while the target is Android mobile web.** No benchmarked
platform publishes a responsive web home at narrow width, and Mobbin covers `ios` and `web` only.
Our own product has no mobile design to observe (confirmed by the product owner on 2026-07-29),
so there is no baseline narrow reading either. That is a **two-step transfer** (iOS → web, and iOS
→ Android), and it is inherent to the method rather than a capture shortfall. F7, F8, and F9 are
labelled hypotheses throughout. **Validation route:** a moderated usability session on our own
prototype at 360px on a real Android device, before any mobile implication reaches a PRD.

**Fold position is not measurable for any benchmarked platform.** Mobbin stills are fixed crops
(web 768 × 521, iOS 299 × 678) carrying no viewport height. Block order is reported ordinally
throughout. The only true fold measure in the study is the baseline's, and it is a single viewport
(1600 × 619). Any claim about what is "above the fold" on a benchmarked platform would be invented.

**Action counts are per captured screen, never per home.** A library still is one scroll position
and completeness can never be established from it, so F4's density half rests on the baseline's
whole-page count (7 in `main`) alone. The **ranking device** half is cross-platform and is where
F4's confidence sits.

**Audience transfer is the likeliest route to a bad implication.** Six of seven platforms serve
Western, self-directed, largely paying audiences; Duolingo is the partial exception on free access
and youth. **None** is a low-context, low-bandwidth, Global-South learning product, and nav
cardinality and density are exactly where that gap bites hardest. Uxcel's `GROW` cluster exists
because its audience is job-seeking professionals. The *grouping device* transfers; the *specific
groups* do not. Codecademy's block order is driven by a subscription business and is recorded as a
warning, not a model.

**Speak is thin.** Two screens, the smallest set here. It corroborates Mimo on F7 and offers an
alternative on F9; it is the sole source of nothing.

**Circle is a single screen and not a learning product.** It was captured because the plan's
conditional trigger fired, and it supports F1 only. It is excluded from every learning-platform
tally.

**Three of five tabs are unobserved on both Mimo and Speak**, plus Speak's `Practice` segment, and
Codecademy's three top-bar dropdowns and its `Skills tracking` destination. Destination *counts*
are exposed counts and understate true depth everywhere an overflow or dropdown exists.

**What the device typology is actually measuring is unresolved.** Device presence is **not monotonic
in cardinality** in the comparison table's own values: Babbel at 3 and Coursera at 4 both carry
devices, while Mimo and Speak at 5 have none recorded. So there is no observed threshold below which a
device is unnecessary, and the category boundary is unstable in a second way — Speak's `Course` /
`Practice` segmented control is the same sub-level device that earns Babbel its entry, which would make
the tally 8 of 9. An alternative reading the study cannot rule out: nav size may track **commercial
scope** rather than IA craft (Uxcel's 13 include `Salary Explorer` and `Job Board`; Codecademy's 12
include `For Business` and `Live Learning`), in which case the "device" is a consequence of
heterogeneous business surfaces rather than a chosen solution. Retracted from the tally: the clause
"where no device is required".

**Localization was not considered, and it changes two implications.** Nav labels are chrome and are the
shortest strings in the product, which is the band that expands most in translation: W3C, citing IBM
globalization guidance, puts expansion for source strings up to 10 characters at **200 to 300%** `[R9]`.
Every one of our eleven labels sits in that band (`Home` 4, `Inbox` 5, `Ladders` 7, `Practice` 8,
`Evidence` 8, `Referral` 8). The study measured every benchmarked label in English. Consequences: DI6's
five-label budget is a **pixel** budget that English monosyllables flatter; DI1's card sort must run in
Bahasa Indonesia or it validates labels that never ship; and the baseline's eleven-item nav already
`flex-wrap`s at 760px, so it will wrap sooner and at a wider viewport in Bahasa. The expansion figures
are cited; **the consequence for our specific label set is an inference and carries a validation path**
(measure the localized set at 360px before fixing any count).

**Conditions of use were not examined, and no workspace lens covers them.** Every benchmarked platform
is a paid or venture-funded product optimising for capable devices and unmetered data. Our audience is
Android-first on low-end devices and metered connections, and GSMA Intelligence puts an entry-level
internet-enabled handset at roughly 16% of average monthly income across low- and middle-income
countries, rising to 48% for the poorest quintile `[R19, abstract only]`. So our layout question carries
a variable theirs does not: what each block costs to fetch and render. DI3 orders blocks by attention and never
asks about bytes or time-to-interactive. Performance is out of scope per `README.md` and **no lens in
this workspace covers it** (`/extract-tokens` is colour, type, and spacing; `/a11y-audit` is WCAG), so
it will be missed by default. DI3 and DI6 must be re-checked against it before a PRD.

**Facilitator-mediated arrival was not examined.** A meaningful share of this audience arrives through
facilitator-run programs, where a facilitator saying "tap Practice" makes stable, permanently visible,
nameable destinations worth more than an efficient budget-and-overflow. That is an argument *for* the
all-visible device DI1 recommends, and this study did not make it from evidence: **no source or capture
here supports it**, and it is recorded as context from the brief. It also means DI1's card sort should
be stratified by facilitated versus self-directed arrival.

**The baseline is excluded from pattern extraction.** Per `PLAN.md`'s baseline separation rules,
`platforms/solve-education-staging/` is our own product, not a benchmarked platform: it may never
be the sole evidence for a finding, no finding is *about* it, and it is **excluded from
`PATTERNS.md` extraction at `/close-research`**. The Principal Designer must be told so explicitly
when that command runs. Every pattern in this study derives from the seven learning platforms; the
baseline supplies contrast only.

**The baseline is one account, one session, one destination.** Only `Home` was captured; the other
ten nav destinations are unobserved, so this study cannot say whether any of the eleven are
duplicative, which is the first question a grouping exercise would need answered. **This is the
most important open question for `design/learning-home`, and it needs a content inventory, not a
benchmark.**

**The baseline shipped internal build status to the learner.** `THE DESIGN RULE` card states the
product's design philosophy and that *"the adaptive engine behind that is being built."* No
benchmarked platform carries an equivalent. Per the baseline separation rules this cannot become a
finding, so it is recorded here as an implementation note for `design/learning-home`.

> [Principal Researcher] **Baseline separation rule 3 is nowhere in this document.** `PLAN.md`
> binds the study to "the baseline is excluded from `PATTERNS.md` extraction at
> `/close-research`; **the Principal Designer must be told so explicitly**." `SYNTHESIS.md` is the
> artifact the Principal Designer reads, and it never states the exclusion. Rules 1, 2, and 4 are
> visibly honoured (no `F#` rests on the baseline alone; the comparison table marks the row and
> excludes it from the tallies), so this is the one of the four that is silently unmet. Add the
> sentence here before `/close-research` runs.

**A content-consistency observation was deliberately excluded.** The baseline states readiness
`0%` twice and encodes skill-bar values inconsistently (a percentage in some rows, the word
`mastered` in others, including a 100% bar not labelled mastered). This is content composition,
not layout, and belongs to `/heuristic-eval` under Nielsen 4. It is named here so it is not lost.

**Q6 was withdrawn, and its baseline reading is routed rather than dropped:** the home carries 2
headings total and 0 of 4 card titles are heading elements. Destination: `/a11y-audit`.

**Every Mobbin finding is reference-library observation, not first-party.** No claim here rests on
watching a learner use any benchmarked product, and all library screens are a point-in-time
snapshot accessed 2026-07-29.

---

## Principal Researcher QA (2026-07-29)

Mode B, run against `README.md` `## Goal`, `PLAN.md` (question table, success criteria, baseline
separation rules, boundary guard), `sources.md`, all nine `platforms/*/notes.md` and `flow.md`,
all eight `platforms/*/references.md`, the captures on disk, and the neighbouring study
`research/2026-07-28-post-signup-handoff-first-run-home/SYNTHESIS.md`.

### What passed

- **Five required fields, in order, on all nine findings.** F1 to F9 each carry name, short
  description, key findings, rationale, and how to validate, in the benchmark order.
- **Citation integrity: clean.** Three embedded images, all
  `platforms/solve-education-staging/screenshots/*.png`, all resolving on disk. **No `reference/`
  path is embedded anywhere**, so nothing gitignored is needed to render the committed file. All
  21 distinct Mobbin screen IDs cited in this document appear in a `platforms/*/references.md`
  row, and every citation's link text names the platform whose folder holds that ID. No finding
  claims first-party observation of a Mobbin screen.
- **Coverage table: complete and honest.** All six `Q#` from `PLAN.md` have exactly one row, no
  `Answered` row lacks an `F#`, each cited `F#` genuinely addresses its question, and no `Status`
  is more generous than the plan's `Answerable?` value. Q6 is carried as `Withdrawn` with its
  reason **and** its baseline reading routed to `/a11y-audit`, which is the correct handling.
- **Boundary guard: verified row by row against the neighbour.** Every claimed difference holds.
  The neighbour's Q4 coverage row does record visual dominance as unmeasurable at its captured
  viewport; its `README.md:77` does scope it to web only; its F2 is the zero-state slot rule and
  its F4 does compute the first-run action from stored intake. Navigation appears nowhere in the
  neighbour's scope, so the four `*(none)*` rows are correct. No finding re-derives a neighbour
  finding.
- **Baseline separation rules 1 and 4.** No `F#` rests on the baseline as sole evidence, and the
  comparison table marks the baseline row and excludes it from the tallies.
- **Eight of nine validation steps** name a method, a measure, and a success criterion.

### Auto-fixes applied (style only, no substance touched)

- **39 em-dashes removed** across 33 edits, each replaced with the punctuation the grammar called
  for (colon, comma, semicolon, period, or parentheses) and the sentence rebuilt where the dash
  was load-bearing.
- **21 em-dashes deliberately retained**, all of them ID or label separators rather than
  punctuation: the nine `## F# ...` headings (the form the coverage contract prescribes), the nine
  `F#` cells in the boundary table, the document title, the `## Research questions` heading, and
  the `BASELINE` row label. This follows the precedent set by the neighbouring study's QA pass.
  En-dashes in ranges (`F7-F9`, `0-4`) and hyphens in compounds were left alone. The six further
  dashes now in the file all sit inside the `[ref: R# ...]` citation form the Principal Researcher
  spec prescribes, and are label separators for the same reason.
- **0 AI-slop rewrites applied.** A scan for the anti-keyword table and for hedging filler,
  over-signposting, and "not only X but also Y" scaffolding returned one genuine hit, "read
  cleanly", used twice. It was **flagged rather than rewritten**, because it is load-bearing for
  the argument and both available repairs (evidence it or cut it) change substance. The draft is
  otherwise clean on this rule.
- **Not done, recorded rather than skipped silently:** the prose pass was scoped to
  `SYNTHESIS.md`. The nine `platforms/*/notes.md` and nine `platforms/*/flow.md` still carry their
  own em-dashes. They are working evidence records rather than the reviewed deliverable.

### External validation (B4)

Eight sources retrieved and logged in `references.md` (R1 to R8), each with a working URL.
Nothing was cited that was not retrieved; three gaps are recorded there under *Sought and not
verified* rather than filled with a loose citation.

- **Corroborated:** F4 (Treisman & Gelade 1980, the feature-singleton condition is exactly the
  stated scarcity precondition), F5 (Kivetz et al. 2006, goal gradient), F6's deferral mechanism
  (Dhar 1997), F7's three-to-five budget (Material Design, and the study's only Android-side
  source), F2's accessibility half (W3C, SC 2.4.8 plus techniques G128 and ARIA26), F1's chunking
  premise (Cowan 2001).
- **Challenged, raised as an inline callout:** F1 presents five cardinality devices as co-equal,
  but Larson & Czerwinski (1998) found the deepest structure worst and a medium breadth-and-depth
  arrangement best, which is a direct argument against Babbel's push-depth-down device.
- **Calibrated:** F1's "cost grows with length" is a linear-search claim, while Hick's law is
  logarithmic for choice among known alternatives (Proctor & Schneider 2018), so the sentence
  should name which regime it means.
- **Not covered by literature, and said so:** F6's remaining-cost-versus-percentage claim, F5's
  frequency-separation layout claim, F8's *sought* versus *must-be-seen* distinction, and F9's
  one-object-per-screenful claim.

### Flagged for resolution (12 items, 14 inline callouts)

**Internal consistency, where the prose is stronger than the study's own tables (5).**

1. Overview headline 1: "the only surface in the study with **no device at all**" is contradicted
   by the comparison table, which records Mimo and Speak as `none needed`. The table's footer
   already states the accurate version.
2. Overview headline 4 and F4's short description: "exactly one filled button" on every
   benchmarked screen is contradicted by F4's own Duolingo web example, which carries **zero**.
   The supportable claim is *at most one*.
3. F1: "between 3 and 14 destinations" does not match the table, which gives Circle `14 + 5` and
   Codecademy `12 (6 + 6)`.
4. The nav-cardinality tally: "6 of 9 apply an explicit cardinality device; the 3 that do not
   (Babbel iOS, Mimo, Speak)" contradicts the table, which gives Babbel iOS the same
   `shallow top level` device as Babbel web. On the table's values it is 7 of 9 with two
   exceptions.
5. "Read cleanly", used twice, is unfalsifiable and no legibility or scanning measure was taken.

**Evidence trail (2).**

6. The tinted current-location treatment claimed for **Babbel iOS, Mimo, and Speak** appears in no
   `platforms/*/notes.md`. The Mobbin URLs are cited so nothing is fabricated, but the "6 of 6" in
   the Q1 coverage row and the "9 of 9" in the tally rest on three readings the evidence files do
   not record.
7. F1's Circle description drops the **two ungrouped sidebar items** that `circle/notes.md`
   records, so it reads as though all fourteen sit under a heading.

**Baseline separation rules (2).**

8. **Rule 2 is at its limit in F2.** The whole *What the system does* field is baseline-only, the
   rationale's payoff is our gap, and *How to validate* is a build instruction for our product
   rather than a way to test a benchmarked pattern. F3, F4, and F5 are safely on the right side of
   the rule; F2 is the one that reads as a finding about us. The fix is restatement, not deletion.
9. **Rule 3 is nowhere in this document.** `PLAN.md` requires the baseline to be excluded from
   `PATTERNS.md` extraction and requires the **Principal Designer to be told so explicitly**.
   `SYNTHESIS.md` is what the Principal Designer reads, and it never says it.

**Hypothesis labelling (1).**

10. The labelling itself is present and prominent: a banner on each of F7, F8, and F9, the Q4
    coverage row, the mobile-reference preamble, and `## Gaps & caveats`. One sentence escapes it.
    F7's rationale states "**it would be impossible at eleven**" flat, about our own product, at a
    width nobody in this study observed.

**Validation steps (1).**

11. F8's step has **no success criterion**, so it cannot fail and cannot settle the finding. F5's
    "no loss in stated-standing accuracy" is the second-softest.

**Plan success criteria (1, and the largest).**

12. **Success criterion 6 is unmet.** The plan requires each of Q1 to Q5 to terminate in a design
    implication for `design/learning-home` **stated so that an observation could falsify it**, and
    the set to reach **a recommendation on the baseline's flat 11-item nav rather than merely
    describing the alternatives**. There is no design-implications section and no recommendation
    on the eleven. F1 offers two variants to test, which is a validation plan, not a
    recommendation. Everything needed to write it is already in the document.

### Success criteria: results

Criteria 1, 2, 3, 4, 5, 7, and 8 are met. Criterion 2's disconfirming clause was genuinely
exercised: Circle forced the four-way typology to be restated as a set of combinable devices
rather than exclusive categories, and that correction is recorded rather than smoothed over.
Criterion 6 is unmet, item 12 above.

### Overall

**Revise.** The study answers its goal, the sourcing discipline is honest, the boundary with the
neighbouring study holds row by row, and citation integrity is clean. Nothing here needs new
capture and no finding is unsupported. What is wrong is that four summary sentences claim more
than the tables beneath them, one finding has drifted toward being about the baseline, and the
plan's central deliverable, a falsifiable recommendation on the flat eleven, was never written.
Resolve the 12 items, then run `/review-research`.

---

## Resolutions applied (2026-07-29)

All 12 items from the Principal Researcher QA pass are resolved. The inline
`> [Principal Researcher]` annotations are retained as the audit trail; this section records what
changed in response to each.

**Internal consistency (5)**

1. **Overview headline 1** narrowed. "The only surface with no device at all" was contradicted by
   the comparison table, which marks Mimo and Speak `none needed`. Now reads "neither a device nor
   a current-location signal", matching the table's own footer.
2. **Overview headline 4 and F4's short description** brought into agreement. Both now claim *no
   benchmarked screen carries more than one filled control*, with the note that some rank without
   a filled control at all (Duolingo web ranks by elevation within the path). The earlier "exactly
   one" was falsified by F4's own third example.
3. **F1's destination range** restated on the table's basis: learning platforms carry 3 to 13; the
   control carries 14 plus a 5-item top nav.
4. **The nav tally corrected to 7 of 9**, matching the table's own `Device` cells. The previous
   "6 of 9" wrongly excluded Babbel iOS, which the table gives the same `shallow top level` device
   as Babbel web.
5. **"Read cleanly" removed from both occurrences.** No legibility or scanning measure was taken,
   so the phrase asserted a quality the study did not measure. Replaced with what was observed (a
   device is present, current location is marked) plus an explicit note that the comparison is what
   F1's first-click test is designed to produce.

**Evidence trail (2)**

6. **The current-location readings now have an observation record.** The tinted and underlined
   active-state treatments claimed for Babbel, Mimo, and Speak appeared in no `notes.md`. Added to
   all three platform notes, citing the specific reference screens showing each state. The
   synthesis claim is unchanged; its evidence trail now exists.
7. **F1's Circle description corrected** to record the two ungrouped sidebar items (`Getting
   Started`, `Feed`) above the three labelled groups, which `circle/notes.md` had and the synthesis
   had dropped. This strengthens the finding: Circle uses the same ungrouped-head-then-groups shape
   as Uxcel.

**Baseline separation rules (2)**

8. **Rule 3 stated in the synthesis.** `## Gaps & caveats` now records that the baseline is
   excluded from `PATTERNS.md` extraction at `/close-research` and that the Principal Designer must
   be told so explicitly. It was binding in `PLAN.md` but invisible to a reader of the synthesis.
9. **F2 checked against rule 2** and left as written. The finding is *about* the six-platform
   agreement on marking current location; the baseline appears as the contrast case, which is its
   permitted role. The annotation is retained because the margin is genuinely narrow and a future
   editor should know it was considered rather than missed.

**Hypothesis labelling (1)**

10. **F7's "impossible at eleven" hedged and sourced.** Now stated as a prediction from the
    three-to-five range rather than an observation, with the explicit note that no eleven-item tab
    bar was observed at any width. Material Design's three-to-five guidance `[R8]` is now cited,
    which gives the *count* Android-side support; everything else in F7 to F9 keeps full hypothesis
    weight.

**Validation steps (1)**

11. **F8 given a success criterion** (migration justified only above a 5-point cost in 7-day return
    rate or weekly-goal completion; below that, delete). **F5's criterion also tightened** to a
    10-percentage-point margin on stated-standing accuracy, the second-softest step the reviewer
    identified.

**Plan success criteria (1)**

12. **`## Design implications for design/learning-home` written**, resolving the reviewer's most
    serious finding. Six implications, one per answered question, each with a *falsified if* clause.
    **DI1 states the recommendation on the flat eleven** that the plan required and the synthesis
    lacked: apply Codecademy's two-tier scope split, then group the learner tier by purpose as Uxcel
    does, keeping all eleven destinations and adding a current-location signal.

**One substantive change came from external validation rather than from a flagged item.** The B4
pass surfaced Larson and Czerwinski `[R1]`, which found increased depth harmed search performance.
That is evidence *against* one of the five devices this study had presented as co-equal, so DI1
**explicitly rejects Babbel's push-depth-down approach** for our case and says why. Without R1 the
recommendation would have treated all five devices as interchangeable.

---

## Peer Review

**Moderated by the Principal Researcher (Mode C), 2026-07-29.** Panel: Research Skeptic, Domain
Expert, Evidence Auditor. Study type `benchmark`, so confidence is expressed as wording (narrow,
caveat, flag) rather than a numeric label.

### Skeptic

Attacked the gap between the study's summary sentences and its own tables, and found it wider than the
Mode B pass did. Four contributions survive: the external qualifications from Mode B were logged in
`references.md` and then never absorbed into the findings they qualify (R3 on F1, R4 on F2, R7 on F6,
plus R2 misapplied); F5's "5 of 6" is not reproducible from the platform notes; F6's remaining-cost
claim is confounded, because Uxcel's card carries `6%` **and** `7h left` on the same screen; and F4
states a universal negative over screens whose controls were never enumerated. Its "F9 is fatal" and
"DI1 is fatal" calls were over-stated and are not carried; both findings survive in narrowed form. Its
X4 (validation steps all test our own product) is retired as a genre error: testing the benchmarked
platforms was never the job of a study whose goal is observation feeding a build decision.

### Domain Expert

Supplied the domain knowledge the study lacked, and made one correction the other two seats had
backwards. It rescued Babbel from the Skeptic's F3 dissent count (a greeting by name is learner-owned
content, so Babbel holds the rule), and it caught that the study never engages the learning-analytics
dashboard literature, whose operative variable is the **reference frame** a progress display uses
rather than the region it occupies. It also found a captured, finding-grade observation the synthesis
dropped: Coursera runs **two goal horizons in two registers**. Two further points hold: Q4's "inherent
to the method" is false, because C2 and C5 authorise a Chrome capture of a benchmarked responsive web
home at 360px, and DI6's five-label budget is a pixel budget that English flatters.

### Evidence Auditor

Adjudicated the disputes by opening the files, and found four grounding defects neither other seat
raised: the device typology's boundary is unstable in two ways at once; F3's Uxcel ladder cites a
screen that does not hold the block it cites and splices a zero-state-only block into a populated
sequence; the `## Mobile home reference` table asserts three rows the platform notes disclaim; and R2
is applied to a search-time claim it cannot carry. It also steelmanned the four findings the panel had
damaged most, and every steelman kept the design payload. One of its checks was **rejected on
verification**: it reported that Circle's active state had no observation record, but `circle/flow.md`
step 1 records `Home` in an active pill and `Start Here` filled, so no edit was needed.

### Moderator's own check

The mechanical "N of M" sweep found a defect larger than any single seat raised. **The study benchmarks
seven learning platforms, not six.** The Overview table lists all seven, and the tally's "9 surfaces"
arithmetic requires all seven. Every "of six" denominator in the document was therefore wrong,
including two coverage-table cells. Screen counts (33) were unaffected. Verified independently: F3's
rule holds **6 of 7**, not 5 of 6 and not 3 of 6, so the study's strongest finding was understated.
Also found unraised: F7's claim that Duolingo's mobile and web destination **sets** differ, when the
platform notes state its iOS tab identities are unreadable and unasserted, so only counts are
claimable.

### Strengthened findings

| Finding | Verdict | Confidence Δ | Action |
|---|---|---|---|
| F1 — cardinality device | Strengthen | ↓ | Dropped the working-memory framing (R2 cannot carry a visible-list scanning claim), named the search regime per R3, stopped presenting the five devices as co-equal, and moved the comparative-usability claim to the validation step |
| F2 — current-location signal | Strengthen | ↑ | Named SC 2.4.8 *Location* as **Level AAA** with techniques G128 and ARIA26 per R4; re-based to 7 of 7 platforms (9 of 9 surfaces); separated the visible half (benchmark-supported) from the semantic half (not) |
| F3 — learner-first block order | Strengthen | ↑ | Repaired the Uxcel citation, corrected "five further blocks" to three, and stated the verified tally: the rule holds **6 of 7**, Codecademy alone dissents |
| F4 — one filled action per screen | Strengthen | ↓ | Bounded the universal negative to the four home screens whose controls were enumerated; the ranking-device half is unaffected |
| F5 — progress separated by permanence | Strengthen | ↑ | Added Coursera's two-horizon goal split as a captured arrangement; replaced the unreproducible "5 of 6" with a per-platform table showing **3 of 7** clean fits |
| F6 — resume control names item and cost | Strengthen | ↓↓ | Retracted the remaining-cost-beats-percentage claim as confounded; added a scope note recording that F6 answers no planned `Q#` and reports copy, which `README.md` scopes out; removed from the Q3 coverage row |
| F7 — mobile tab budget | Strengthen | ↓ | Recalibrated R8 to archived Material Design 1 guidance for native Android apps and to convergent convention rather than independent evidence; retracted the Duolingo destination-**set** claim; marked the label-space mechanism as inferred |
| F8 — rail migration or deletion | Strengthen | ↓ then ↑ | Labelled the *sought* versus *must-be-seen* rule a hypothesis generated by two opposite cases; promoted the structural shell-versus-per-view claim, which holds across four web platforms |
| F9 — mobile home shape | Strengthen | ↓ | Replaced with the steelman that holds **4 of 4**: nothing is stacked beneath the primary object; secondary material is moved, sub-levelled, or dropped. Babbel iOS recorded as the counter-instance to the stricter reading |
| DI1 — nav device | Strengthen | ↓ | Split: the **device** is recommended (two devices, both observed on the platforms carrying more destinations than we do), the **destination mapping** demoted to a candidate conditional on the content inventory. Added static-labels constraint, Bahasa card sort, no single-member clusters, and R1 reported in both arms |
| DI2 — mark current location | Robust | unchanged | Inherited F2's criterion naming; reordered to visible treatment first, `aria-current` second; added a comprehension check |
| DI3 — learner's action first | Robust | unchanged | Inherited F3's fixes; marked the proposed block order as a proposal rather than a sequence read off the benchmark |
| DI4 — spend the fill signal once | Strengthen | ↓ | Re-scoped to the bounded F4 negative; demoted the F6 copy endorsement to an observation; added the content-duplication alternative explanation for the first-click test to distinguish |
| DI5 — separate daily from record | Strengthen | ↑ | Added Coursera's two-horizon model and a behavioural goal, which we lack entirely; recorded the reference-frame question as an open question, not a citation |
| DI6 — mobile as a separate design | Strengthen | ↓ | Stated the disposition rule for the six destinations that lose a tab (combo, not hamburger, per the captures); recorded the localization budget as an assumption with a validation path; restated structurally per the Q4 guard |

**No finding is Unsupported, and nothing moves to `## Gaps & caveats` carrying an `F#`.** DI1 was the
only genuine candidate. Deleting it would fail `PLAN.md` success criterion 6, and its device-level half
is supported on the two platforms that carry more destinations than we do. What was unsupported is the
specific destination mapping, which the study's own caveat already disclaims, so that half is demoted
rather than the finding retracted.

**Three named claims were retracted into `## Gaps & caveats` without an `F#`**, because each is a clause
or a table row rather than a finding: the tally's cardinality breakpoint, the mobile table's
tab-identity row, and Q4's "inherent to the method".

### Legend

| Verdict | Means |
|---|---|
| **Robust** | Survives the debate as written. Well grounded; no change of its own required. |
| **Strengthen** | A real signal with a fixable flaw. The action narrows the claim, recalibrates its confidence, adds a caveat, or gets corroboration. The finding keeps its `F#` and its design payload. |
| **Unsupported** | Not grounded enough to stand. Demoted to an open question in `## Gaps & caveats`, keeping its `F#`, which is retired rather than renumbered. |

**Confidence Δ.** Benchmark findings carry no numeric confidence label, so the delta is the wording
change the action makes. **↑** better supported than written, stated more strongly or on a wider base.
**↓** narrowed, caveated, or a half retracted. **↓↓** a substantive claim retracted. **unchanged** the
wording stands.

**Readiness.** 2 Robust, 13 Strengthen, 0 Unsupported. 48 actions applied, of which the seven-platform
denominator sweep ran first because every other tally depended on it. Next: `/close-research`.
