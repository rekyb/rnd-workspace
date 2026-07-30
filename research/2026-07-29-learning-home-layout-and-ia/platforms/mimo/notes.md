# Notes — Mimo (analysis)

Source: Mobbin reference library, `ios`, accessed 2026-07-29. Four screens. **Reference-library
observation, not first-party.** Mobile-reference platform — every implication drawn here is a
**hypothesis for validation on Android mobile web**, not a benchmarked finding.

---

## Observation 1 — five labelled tabs, no overflow (Q1, Q4)

`Learn`, `Practice`, `Build`, `Leaderboard`, `Profile`. Five, each an **icon above a text
label**, no `…` and nothing hidden.

Set against the study's other two phone navs, a pattern emerges about labelling rather than
count:

| Platform | Tabs | Labels | Overflow |
|---|---|---|---|
| Babbel | 3 | Yes | No |
| **Mimo** | **5** | **Yes** | **No** |
| Speak | 5 | Yes | No |
| Duolingo | 6 | **No — icon only** | **Yes, `…`** |

Three of the four label their tabs. The one that does not is also the only one that exceeds five
and the only one needing an overflow. That reads as a **budget of roughly five labelled
destinations** on a phone: past it, either the labels go or a tail goes behind an overflow.

For our eleven that is the sharpest number the study has produced. A phone home cannot carry
eleven labelled destinations; something has to be demoted, and the platforms disagree only about
whether the demotion is to an overflow or to a lower level.

**Current-location treatment (added 2026-07-29 during QA, from the same four screens).** The
active tab is marked by a **filled/solid icon over a darker label**, against outline icons and
grey labels on the inactive four. Visible on all four references: `Learn` active in 01 and 02,
`Practice` active in 03 and 04. A red dot badge appears on `Leaderboard` in 03, which is a
notification marker rather than an active state.

## Observation 2 — the home is split across two tabs, by rhythm (Q2)

`Learn` is a path and nothing else — no cards, no stats, no secondary blocks. `Practice` is a
four-block stack: daily review, past topics, progress tiles, playgrounds.

So Mimo does not choose between "the home is the path" and "the home is a dashboard". It ships
both and separates them by **rhythm**: `Learn` is the long arc through the curriculum,
`Practice` is what you do today and what you have done lately.

This is the most useful structural idea for our own case. Our baseline currently stacks the arc
(skill bars across four competencies), today's task (the objective card), and the record
(readiness) into **one scrolling column**, and the result is that the primary action lands
two-thirds down. Mimo's split suggests those are two different surfaces with different visit
frequencies.

Hypothesis for validation, not a finding: our audience may not have Mimo's session pattern.

*(Guard check: Q2 block order. Does not restate F4's cold-start rule — that concerns where the
first-run action is computed from, not how surfaces are divided by rhythm.)*

## Observation 3 — progress appears at three grains, in three places (Q5)

1. **Header chips** — coin count and droplet count, always visible on `Learn`.
2. **Unit ring** — a circular `58%` beside the current unit name, attached to the thing it measures.
3. **Practice tiles** — `5 Activities done`, `32m Time on tasks`, two large figures on the `Practice` tab.

None of the three is a leaderboard or a streak on the home itself; `Leaderboard` is its own tab.

The device worth noting is the **ring attached to the unit pill**. It measures one named thing
and sits on that thing, rather than summarising the learner in the abstract. Our baseline's four
skill bars measure competencies at the top of the page, detached from any action — the reverse
arrangement.

*(Guard check: region and count only.)*

## Observation 4 — the daily action states its cost before its content (Q3)

The `DAILY REVIEW` card leads with a category label, then the title, then `⚡ 10 min`, then a
full-width `Start now`. The past-topic cards do the same: duration first (`8 min`, `7 min`),
title second.

Duration-before-title recurs across the mobile set (Babbel's cards, Speak's course percentages,
Uxcel's `7h left` on web). On a small screen the ranking device is **the card's width and the
presence of a full-width button**, since there is no room to rank by position in a multi-column
layout.

That is the concrete narrow-viewport lesson: on desktop you can rank by column and position; on
a phone you rank by **width, fill, and order**. Our baseline's desktop CTA styling will not
survive the transition unaltered.

---

## Caveats carried

- **Reference-library observation.** No first-party use, no live behaviour, no timing.
- **Point-in-time**, accessed 2026-07-29.
- **iOS only** — no web counterpart captured, so Mimo contributes to Q4's mobile half but not to
  a pair.
- **Three of five tabs unobserved** (`Build`, `Leaderboard`, `Profile`), so no claim is made
  about what they contain.
- Reference 02 is a **0% locked path**, cited for block order only; zero-state composition is
  settled by `2026-07-28` F2.
- **Audience transfer, and platform transfer.** A paid consumer coding app on native iOS.
  Our target is Android mobile web. Structure transfers; tab-bar idiom does not — per the plan's
  Q4 guard, no interaction-convention claim is made from this evidence.
