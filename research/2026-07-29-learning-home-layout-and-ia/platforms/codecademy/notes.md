# Notes — Codecademy (analysis)

Source: Mobbin reference library, `web`, accessed 2026-07-29. Four screens. **Reference-library
observation, not first-party.**

---

## Observation 1 — twelve destinations, split by scope, not by count (Q1)

Codecademy carries **12 top-level destinations** — more than our eleven — and does not feel
crowded, because they sit in two tiers divided by a legible rule:

| Tier | Items | What they have in common |
|---|---|---|
| **Top bar** | `My Home`, `Catalog ▾`, `Resources ▾`, `Community ▾`, `Live Learning`, `For Business` | The **product**: what exists, what you could buy, who else is here |
| **Left sidebar** | `Dashboard`, `My learning`, `Skills tracking`, `Events`, `Projects`, `Workspaces` | The **learner**: your work, your progress, your things |

The rule is possessive. Sidebar items are things you *have*; top-bar items are things that
*exist*. A learner looking for their own work never scans the top bar.

This is the third published answer to cardinality in the set, and the one that most directly
fits our situation, because **it does not require deleting anything.** Duolingo's answer needs a
budget and an overflow; Babbel's needs a shallow scope; Codecademy's needs only a rule for
sorting what already exists into two groups.

Applied to our eleven: `Catalog`, `Opportunities`, and `Referral` describe things that exist;
`Inbox`, `Ladders`, `Practice`, `Challenges`, `Evidence`, `Credentials`, and `Applications`
are largely the learner's own. That split is available to us without removing a single
destination. **Stated as an observation about the benchmark's rule, not as a recommendation —
the recommendation belongs in the synthesis, tested against the other four platforms.**

## Observation 2 — the sidebar is where the active state lives (Q1)

The current location is marked only in the **sidebar** — a filled row with a left edge bar. The
top bar carries no active state on any captured screen, including `My Home`. So the two tiers
differ in function as well as content: the sidebar is *where you are*, the top bar is *where you
could go*.

Our baseline has one tier and, from reconnaissance, no observed active-state treatment on it —
a gap to confirm at baseline capture.

## Observation 3 — commercial slots outrank the learner's work in the block order (Q2)

Reading down the page in order: **promotional countdown bar** (above everything), then the
**bootcamp promo carousel**, and only then `Keep learning` with the learner's actual progress.
The sidebar's foot carries a further promotional card (`Explore job opportunities`, or a
free-trial upsell).

So on a populated home for an active learner, the first two blocks are both selling, and the
resume action is third. Four of the captured screens carry at least one commercial slot.

Recorded as **observed context, not as a finding about learning design** — this is a
subscription business making a business decision, and our product is not selling anything.
Its value to us is as a **counter-case for block order**: it demonstrates what it costs when the
top of the page belongs to something other than the learner's next action. Our own baseline
spends its first two blocks on a product tagline and a design-philosophy paragraph, which is
structurally the same mistake with a non-commercial motive.

## Observation 4 — the resume card offers three actions and ranks only one (Q3)

`Keep learning` ends in a three-way control row: `View path`, `Start practice session 0/1
today`, `Resume →`. Only `Resume` is colour-filled; the other two are plain text on white.
So the ranking device is **fill against no-fill within a single row**, the cheapest possible
device, and the one that survives a narrow column best.

Note the honest counter to our baseline's problem: three actions sit adjacent here and the
ranking still reads, because exactly one is filled. Our baseline offers **seven** actionable
links across the page with the primary one two-thirds down. The defect is not the count of
actions but that none of them is ranked by a visible device.

*(Guard check: ranking **device**, the neighbouring study's unmeasured half of its Q4.)*

## Observation 5 — progress is a bar plus a counter, in the card that owns it (Q5)

`1%` on a thin bar inside the `Keep learning` card; `4 / 9 concepts practiced` inside the
course row on `My learning`. There is **no rail, no dashboard block, and no dedicated
statistics destination** in the captured screens — apart from a `Skills tracking` sidebar item
that was not captured.

So Codecademy is the set's counter-case for Q5: progress is not a *place*, it is an attribute
of whichever card the work lives in. Compare Duolingo (persistent rail plus separate page),
Uxcel (rail), Babbel (header chip plus conditional rail plus profile sheet).

*(Guard check: region and count only.)*

---

## Caveats carried

- **Reference-library observation.** No first-party use, no live behaviour, no timing.
- **Point-in-time**, accessed 2026-07-29.
- **`Skills tracking` was not captured**, so any claim that Codecademy has no progress
  destination is bounded to the four screens held. It carries a `New` badge and may well be one.
- Three top-bar items are **dropdowns**; their contents are unobserved, so the "12 destinations"
  count is *exposed* items and understates true depth.
- **Audience transfer:** a paid, adult, career-changer product in a Western market, with heavy
  commercial pressure on the layout. The two-tier rule transfers; the block order should not be
  copied.
