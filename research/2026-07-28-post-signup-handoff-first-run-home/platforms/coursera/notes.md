# Notes — Coursera (web)

Analysis. The step-by-step lives in `flow.md`.

**Standing caveats.** One observed variant of a Mobbin library snapshot accessed 2026-07-28.
Desktop-web viewport. Audience transfer: Coursera serves adult professionals in a
credential **marketplace** — a different product problem from ours (assigned or goal-directed
learning for low-context youth). Comparisons here are structural only; surface count and
merchandising density do not transfer.

---

## Observation 1 — The best handoff pattern in the study (Q1)

Two of four platforms label the wait between account creation and a usable home. They do it
differently, and Coursera's version is the one I would copy:

| | Brilliant | Coursera |
|---|---|---|
| Form | Full-screen interstitial | **In-place skeleton on the destination** |
| Copy | "Loading your learning path recommendations" | "Preparing your recommendations" |
| Chrome | None — a bare screen | **Real home chrome already rendered** |
| Cost | An extra screen in the flow | No extra screen |

Coursera renders the actual home — wordmark, nav tabs, search, account menu — and fills only
the content region with four skeleton cards. The learner is *already there*; nothing is
pending except the personalisation. Brilliant's interstitial does the same communicative work
but spends a screen to do it.

**For our funnel this is close to free.** `PRD.md` §7.3 already performs one atomic
finalization call before routing to Learning Home, and §9 Slice 7 already requires a loading
state to prevent duplicate submission. Rendering the Learning Home shell with a skeleton and
the line *"Preparing your first course"* reuses machinery that must exist anyway. It costs
the copy and a skeleton component.

Why it matters beyond polish: our funnel asks for name, country, age band, and a goal, then
shows a home. **Nothing currently tells the learner their answers were used.** A labelled wait
is the cheapest possible proof that the intake mattered — and it lands at the exact moment
the learner is most likely to wonder.

## Observation 2 — The goal is echoed, but the content is not goal-derived (Q3)

Coursera was selected as the study's clearest intake-payoff case, and the top of the page
delivers: a persistent bordered banner reading **"Your career goal is to start a career as a
Product Designer"** with an inline **Edit goal** link. Three things right about it:

1. **Restated in the learner's framing**, as a sentence about them, not a chip or a tag.
2. **Persistent**, not a one-time confirmation toast.
3. **Editable in place**, so a mis-set goal is a one-click fix rather than a support problem.

**But the rail directly beneath it is headed "Most Popular Certificates"** — ordered by
popularity, not by the goal just stated. The next rail is a subscription promotion. The page
announces a goal and then serves content chosen by other criteria.

This is the study's most useful cautionary finding, and it lands squarely on an open PRD
decision. §11 assigns *"Canonical goal taxonomy and goal-to-first-course map"* to Content +
Product, with the default *"use the six prototype identifiers and manually approved
mappings"*. Coursera demonstrates the failure mode that decision exists to prevent:
**echoing the goal is not the same as acting on it**, and a learner who reads their goal at
the top and generic popularity below has been told their answer mattered while being shown
that it did not.

Our advantage is that a manually approved six-goal map is *far* easier to honour than a
marketplace-scale recommender. The bar to clear is low; the point is to actually clear it.
Worth stating in the synthesis that the goal-to-course mapping is not a nice-to-have — it is
what makes the intake honest.

## Observation 3 — The intake names its real step count (Slice 10)

The intake labels steps explicitly — **"Step 2 of 4"**, **"Step 4 of 4"** — rather than
showing an unlabelled progress bar, and keeps a persistent **Exit** affordance.

`PRD.md` §9 Slice 10 requires:

> *"Progress reflects the actual configured step count for the current entry path and exposes
> equivalent text such as 'Step 3 of 5.'"*

Coursera is a working instance. Our prototype currently shows a **percentage-width bar only**
(`main.js` `progressMap` / `programProgressMap`, driving `#progress-bar`), with no text
equivalent — so it does not yet satisfy the criterion it was written against. Small, concrete,
and independently verifiable.

## Observation 4 — Second counter-case on the single next action (Q4)

The home has no dominant next action: two catalogue rails, a "Show 8 more" control, and a
subscription promotion, with the banner carrying no CTA of its own.

With Uxcel that is **two of five platforms** diverging from `PATTERNS.md`'s *Single
recommended next step*. Both are the platforms whose intake did **not** yield a usable
routing signal — Uxcel collects almost none, and Coursera collects a broad career intent
rather than a specific first course. Brilliant and Babbel, which both resolve intake to a
named unit, both land on a single Start.

That is a clean four-platform split along one axis, and it strengthens the hypothesis I
opened in the Uxcel notes and tested against Brilliant: **the single-next-step pattern is
conditional on intake producing something specific enough to act on.** Our Slice 6 produces a
goal identifier; whether that is specific enough depends entirely on the §11 goal-to-course
map — which ties this observation back to Observation 2.

---

## What this platform does and does not answer

**Answers well:** Q1 — the best handoff form in the study. Q3 — the clearest intake-payoff
instance, *and* its most instructive failure.

**Answers partially:** Q4 — as a second counter-case, completing the four-platform split.

**Does not answer:** Q2 and Q5 — no zero-state home is visible in these captures (the cited
home belongs to an account with a completed intake, and Coursera surfaces almost no
gamification). Q6 — no cohort mechanic.
