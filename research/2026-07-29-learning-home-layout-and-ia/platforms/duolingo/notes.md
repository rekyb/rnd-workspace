# Notes — Duolingo (analysis)

Source: Mobbin reference library, `web` and `ios`, accessed 2026-07-29. Seven screens, listed
in `references.md`. **Reference-library observation, not first-party.** No claim here rests on
watching a real learner use the product.

---

## Observation 1 — the overflow control is the answer to cardinality (Q1)

Duolingo exposes **8 nav items on web** and **6 on iOS**, and on both the last slot is an
overflow: `MORE` on web, `…` on iOS. The number of destinations that *exist* is not knowable
from a still, so the honest count is **"8 exposed, plus overflow of undetermined depth"** and
**"6 exposed, plus overflow of undetermined depth"** (per the plan's Q1 counting rule).

The structural point is that Duolingo treats the visible nav as a **budget**, not an inventory.
Something decided which seven earn a permanent slot and which fall behind the eighth. That is
the decision our baseline has not made: 11 items, all permanent, no budget.

Note what does *not* happen: the overflow is not a hamburger replacing the nav. Seven
destinations stay permanently visible and labelled. The overflow absorbs the tail only.

## Observation 2 — the nav is grouped by nothing, and gets away with it

Unlike Uxcel (`LEARN` / `GROW`) or Codecademy (two tiers), Duolingo's eight web items carry **no
group labels**. They are co-equal siblings, exactly as our eleven are.

This matters, because it means **flatness is not by itself the defect**. Eight flat items with
an overflow works; eleven flat items without one does not. The variable is count and the
presence of a budget, not grouping per se. Whether grouping earns its keep is a question for
the Uxcel and Codecademy captures, and this is the counter-case that keeps that question open
rather than assuming the answer.

*(Guard check: this is a Q1 observation about nav structure. It does not restate F2's slot rule
or F4's cold-start rule — neither concerns navigation.)*

## Observation 3 — the primary action is a position, not a button (Q3)

On web the next lesson is ranked by **elevation within a sequence**: the node is larger, coloured
against grey siblings, and carries a `START` pointer label. There is no CTA button in a header
or hero. On iOS the same rank is expressed differently — a full-width card laid over the path
with an explicit `START +25 XP` button.

So the ranking *device* changes with available width while the ranking itself does not. On a
wide screen, position in a visual sequence is enough to rank one action. On a narrow screen,
Duolingo does not trust position alone and adds an explicit card and button.

That is a directly usable reading for our own case: our baseline ranks its primary action with a
button (`Start · one task, then you're done →`) placed two-thirds down a 1577px page. Duolingo's
web treatment suggests the ranking problem is solved by *where the action sits in a sequence*,
not by how the button is styled.

*(Guard check: this addresses the ranking **device**, which is the neighbouring study's
unmeasured half of its Q4, not the settled "rank one action above the rest" pattern already in
`PATTERNS.md`.)*

## Observation 4 — progress is split by permanence, and the split differs by platform (Q5)

Web puts **three tiers of progress signal in three different places**:

1. **Always visible, top of rail** — streak, gems, language, energy. A strip of counters.
2. **Always visible, rail cards** — league standing and daily quests, each with its own progress bar.
3. **A separate destination** — `Statistics` holds the streak record, total XP, weekly XP chart, and achievements.

iOS keeps only tier 1, as a top strip. League and quests are **not on the iOS home at all**
within the captured screens.

The design rule this suggests: *the persistent signal is the one you want acted on today; the
detailed record goes somewhere you visit deliberately.* When width disappears, the detailed
record is what gets cut, not the daily counter.

Directly relevant to our baseline, which currently renders a four-bar skill breakdown plus a
readiness percentage plus a goal line **all in the primary column** — tier-3 content occupying
tier-1 position.

*(Guard check: region and count only. Which mechanics to use, and their motivational register,
are settled by F2 and the three named `PATTERNS.md` entries and are not discussed here.)*

## Observation 5 — the home opens with location, not greeting (Q2)

The first thing in the centre column is a unit banner: `SECTION 2, UNIT 1 — Ask for directions`.
No name, no welcome, no summary of what the product is. The learner is told **where they are in
the material** before anything else.

Our baseline opens with a positioning statement (`One objective. Ed speaks first.`), then a
paragraph of design philosophy, then a greeting, and reaches learning content in the fourth
block. Duolingo reaches it in the first.

Ordinal comparison only — no fold position is measurable from a 768 × 521 crop.

## Observation 6 — the iOS home is one block, the web home is three columns

The clearest Q4 reading. Web composes the home from a path plus two rail cards plus a nav.
iOS composes it from a path, a stats strip, and a tab bar. **The mobile home does not stack the
desktop blocks vertically — it drops most of them.** League and quests do not move below the
path; they leave.

This is the most useful single input for a future mobile home on our side, and it is a
**hypothesis for validation on Android mobile web**, not a benchmarked finding: the evidence is
a native iOS app, and our target is an Android browser.

---

## Caveats carried

- **Reference-library observation.** No first-party use, no live behaviour, no timing.
- **Point-in-time.** A library snapshot accessed 2026-07-29, not a claim about the current product.
- **Overflow depth undetermined** on both platforms; counts are "exposed" counts.
- **iOS tab labels are not readable** — the bar is icon-only, so tab *identities* beyond the
  active home tab are not asserted. Only the count and the presence of the `…` overflow are claimed.
- **Web and iOS are separate products**, not one responsive build. No reflow claim is made.
- **Audience transfer:** Duolingo is the closest in the set to free and youth-facing, and is
  still not a low-bandwidth Global-South product.
