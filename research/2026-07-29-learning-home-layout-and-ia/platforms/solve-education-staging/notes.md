# Notes — Solve Education staging (BASELINE)

First-party Chrome capture, trigger **C1**, 2026-07-29. Three screenshots, PII-redacted.

**Standing.** This is the **baseline**, the surface the benchmark findings get measured against.
Per `PLAN.md`: it may never be the sole evidence for an `F#`; no `F#` may be *about* it; it is
excluded from `PATTERNS.md` extraction at `/close-research`; and it is excluded from every
"N of 5" tally in the comparison table.

---

## Observation 1 — the nav is the only one in the study with no cardinality device

Eleven destinations, flat, no group labels, no overflow, no second tier, no active state.

Against the benchmark set:

| Surface | Destinations | Device |
|---|---|---|
| Babbel | 3 | shallow top level |
| Coursera | 4 learner tabs | utilities lifted to a separate row |
| Duolingo (web) | 8 + `MORE` | budget plus overflow |
| Codecademy | 12 | two tiers split by scope |
| Uxcel | 13 | grouped under purpose labels |
| Circle *(control)* | 14 + 5 | grouping **and** two tiers together |
| **Baseline** | **11** | **none** |

Two platforms carry **more** destinations than we do and read cleanly. So the count is not the
defect. The absence of any device is.

Second, smaller finding, confirmed by direct DOM query rather than by eye: **no nav item marks
the current location.** No `aria-current`, no active class, while sitting on `Home`. Every
benchmarked platform marks it, by pill (Duolingo, Uxcel, Circle), underline (Babbel, Coursera),
or filled row with an edge bar (Codecademy). This is the cheapest gap in the study to close.

## Observation 2 — three blocks stand between arrival and the primary action

Ordinal order: **account banner → hero and philosophy paragraph → greeting → coach card (393px)
→ objective card, carrying the CTA at y≈1001 of 1577.**

The first two blocks belong to the company rather than the learner: an email-verification notice
and a statement of what the product is, followed by a paragraph explaining its design approach.
The learner's own next action is the fourth thing on the page, roughly 63% down.

Compare the benchmark ordering. Uxcel: your course → recommended → community → events →
resources, each step moving further from the learner. Coursera: resume card and weekly goal
first, merchandising strictly after. Duolingo: the unit banner and the path, immediately.
Codecademy is the one platform that puts something else first, and what it puts there is a paid
bootcamp promotion, which the notes for that platform record as a counter-case rather than a
model.

So on block order the baseline is closest to the one benchmark instance the study treats as a
warning, and its motive is not even commercial.

## Observation 3 — `THE DESIGN RULE` card ships internal build status to the learner

The final block states the product's design philosophy and then: *"The adaptive engine behind
that is being built; this screen already runs on your real goal, evidence and readiness."*

No benchmarked platform in the set carries an equivalent. Nothing in Duolingo, Babbel,
Codecademy, Coursera, Uxcel, Mimo, or Speak explains its own design intent to the learner or
discloses what is not yet built.

This is a **baseline-only observation**, so per the separation rules it cannot become an `F#` on
its own. It is recorded here and routed to the synthesis's `## Gaps & caveats` as an
implementation note for `design/learning-home`.

## Observation 4 — the ranking device is present but outcompeted

The primary CTA (`Start · one task, then you're done →`) is a filled dark pill, and its copy
does the thing two benchmark platforms also do: it bounds the commitment. Uxcel states `7h left`;
Coursera names the next item (`Welcome to module 1 · Video (1 minute)`); ours states
`~8 min` and `one task, then you're done`. That is a genuine strength and worth preserving.

What defeats it is competition and position. A second filled dark button (`Start this →`) sits
307px **above** it at y≈694, inside the coach card, with near-identical treatment. A learner
scanning for the filled button finds the wrong one first.

Across the benchmark set, every platform gives exactly one filled button per screen. Codecademy
is the clearest instance: three adjacent controls, one filled, ranking legible at a glance.

## Observation 5 — progress occupies primary-column space at three grains at once

The home carries: four labelled skill bars in the tallest block (393px), a `READINESS NOW` panel
at 0% inside the objective card, a `GOAL` cell showing `Customer Support · in progress · 0%` in
the strip, a `VERIFIED EVIDENCE` cell showing `0 proofs`, and `READINESS 0%` in the hero line.

**Readiness `0%` appears twice and the goal name three times**, all in the primary column.

The benchmark set consistently separates these by permanence. Duolingo: daily counters in a
persistent rail, the full record on a separate `Statistics` page. Babbel: a streak chip in the
header, the record in a profile sheet. Speak and Mimo, on phones: a small counter on the home,
the detail on `Profile`. Uxcel: a rail. Codecademy: progress attached to the card that owns it,
with no dashboard at all.

Ours puts detailed-record content — a four-competency breakdown — in the position those
platforms reserve for the single daily signal, and does so above the primary action.

---

## Caveats carried

- **First-party capture, one account, one session.** Structural measures only; nothing here
  claims anything about learner behaviour.
- **Desktop only, 1600 × 619.** The product has no responsive mobile design yet, so no
  narrow-width capture was attempted and none is inferred.
- **One destination only.** Only `Home` was captured; the other ten nav destinations are
  unobserved, so no claim is made about what they contain or whether they are duplicative.
- **Account progressed between passes** (358 → 506 XP). No structural measure changed.
- **No `flow.gif`**, declared in `PLAN.md` as a deliberate capture-standard deviation.
- **Baseline separation rules apply**, listed at the top of this file.
