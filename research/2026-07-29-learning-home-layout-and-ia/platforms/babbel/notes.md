# Notes — Babbel (analysis)

Source: Mobbin reference library, `web` and `ios`, accessed 2026-07-29. Nine screens, listed in
`references.md`. **Reference-library observation, not first-party.**

---

## Observation 1 — three destinations, and the same three on both platforms (Q1, Q4)

Babbel exposes **`Home`, `Review`, `Explore`** on web and **`Home`, `Review`, `Explore`** on
iOS. Not an equivalent set — the identical set, in the identical order. **No overflow control on
either platform**, because with three items there is nothing to overflow.

Set against Duolingo this is the study's sharpest Q1 contrast, and the two platforms disagree
about more than count:

| | Duolingo | Babbel |
|---|---|---|
| Web | 8 exposed + `MORE` | **3, no overflow** |
| iOS | 6 exposed + `…` | **3, no overflow** |
| Web ↔ iOS | Different counts, different sets | **Identical set** |

Duolingo solves cardinality with a budget and an overflow. Babbel solves it by **not having the
problem** — it keeps the top level at three and pushes everything else down a level, into the
`Today` / `Learning plan` sub-tabs and into the `Explore` page's own controls.

That is a second published answer to our eleven, and a structurally cheaper one: it needs no
overflow affordance and no decision about which item is eighth.

**Current-location treatment (added 2026-07-29 during QA, from the same nine screens).** Web marks
the active nav item with an **underline** beneath the label (`Home` in references 01, 02, 03;
`Explore` in reference 05). iOS marks the active tab with a **tinted icon and label** against grey
(`Home` tinted in references 06, 07, 08). Two devices for the same job, one per platform.

## Observation 2 — depth is where the destinations went (Q1)

Babbel's three top-level items are not the whole IA. Beneath `Home` sits a two-tab segmented
control (`Today` / `Learning plan`); beneath `Explore` sits a level selector and an expandable
unit list. So the destination count is low **because the hierarchy is deep**, not because the
product does less.

This is the trade our baseline has not priced. Eleven flat items is one level and no depth;
Babbel is three items and two or three levels. Codecademy's two-tier split is a third position
between them. Whether depth costs more than breadth here is exactly the question a future
`design/learning-home` has to answer, and the study can now put three real options on the table.

*(Guard check: Q1 nav structure. No overlap with F2's slot rule or F4's cold-start rule.)*

## Observation 3 — the daily-goal signal changes region between platforms (Q5)

Web's `Today` tab carries **no goal signal at all** in the content column — the streak sits in
the header cluster, and the lesson-count progress (`0/61 lessons completed`) lives in a right
rail that appears only on `Learning plan`. iOS puts an `Activity tracker` bar **in the content
flow**, directly under the greeting and above the lesson card, showing `0/7` or `10/7`.

So when the rail disappears, the goal signal does not disappear with it — **it moves into the
primary column and gets promoted above the primary action.** That is the opposite of what
Duolingo does (drops league and quests entirely on iOS), and it is the more useful pattern for
us, because it shows a rail-to-column migration path rather than a deletion.

Worth recording precisely because the two platforms in our set disagree. One migrates the
signal, one deletes it. Two options, not a rule.

*(Guard check: region and count only. Mechanic choice and motivational register are settled by
F2 and the named `PATTERNS.md` entries.)*

## Observation 4 — the rail is conditional, not a shell (Q2)

Babbel's right rail appears on `Learning plan` and is absent on `Today`. Uxcel, Coursera, and
Duolingo all treat the rail as a persistent shell present on every home view; Babbel treats it
as **content belonging to one view**.

This matters for a responsive design: a rail that is already conditional is easier to drop at
narrow width than one the whole shell depends on. It is a small structural decision with a
large downstream consequence.

## Observation 5 — the home opens with a name, not a location (Q2)

`Hi, Alex Smith` / `Hi, Jane Doe` is the first thing on the page, above the tab switch and above
any content. Duolingo opens with `SECTION 2, UNIT 1 — Ask for directions`.

Two published positions on the same slot: greet the person, or state where they are. Our
baseline currently does **neither first** — it opens with a product tagline and a paragraph of
design philosophy, and reaches the greeting third. The disagreement between Duolingo and Babbel
means the study should not recommend one; it should record that both are used and that
*something belonging to the learner or the material* occupies the slot in both.

## Observation 6 — the primary slot is state-conditional (Q3)

The same position under the course label holds a **lesson card** (`Dag, Marie! Part 1` +
`Start lesson`) in reference 06 and a **review prompt** (`Time to review` + `Review now`) in
reference 07. One slot, two occupants, chosen by state.

The ranking device is constant across both: large card, photograph or illustration, single dark
button, everything else smaller. Babbel ranks by **size and completeness of the card**, not by
position in a sequence the way Duolingo does.

*(Guard check: this is the ranking **device**, the neighbouring study's unmeasured half. It does
not restate F4's cold-start rule, which concerns where the first-run action is computed from.)*

---

## Caveats carried

- **Reference-library observation.** No first-party use, no live behaviour, no timing.
- **Point-in-time**, accessed 2026-07-29.
- **Web and iOS are separate builds**, not one responsive layout. No reflow claim is made.
- Reference 03 and 05 are **localised** (Italian) or at a different level; structure is cited,
  copy is not compared across them.
- Reference 09 shows a trial-expiry notice, so that account is mid-trial. Not treated as a
  home-structure finding.
- **Audience transfer:** Babbel is a paid consumer subscription product for adult self-directed
  learners. Its three-item nav may be affordable partly because its scope is narrow, which our
  product's is not. Carry this caveat on any implication drawn from Observation 1.
