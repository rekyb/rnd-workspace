# Notes — Uxcel (web)

Analysis. The view-by-view record lives in `flow.md`; this is what the captures mean for our
questions and for `design/onboarding-solve-edu`.

**Standing caveats.** One observed variant of a Mobbin library snapshot accessed 2026-07-28.
Desktop-web viewport; our audience is mobile-first and `PRD.md` §9 Slice 10 requires 320px to
work, so no layout or density claim transfers without testing. **Audience fit is the weakest
in the set**: Uxcel serves Western UX professionals on paid tiers, our PRD serves free-access,
low-context Indonesian youth. `PATTERNS.md` already carries this population caveat twice. The
*structural* rule below transfers; the tone, density, and specific mechanics do not.

---

## Observation 1 — The slot rule (the headline finding)

The matched pair makes Uxcel's zero-state policy legible, and it is a **single consistent
rule** applied slot by slot:

| Slot | Zero state | After one day | Category |
|---|---|---|---|
| Continue learning | Dashed placeholder + "You don't have any active courses" + **Browse courses** | Course card, 6%, "7h left", **Resume course** | progress-derived |
| Getting started | 3 rows, all unchecked | 2 rows checked and greyed, 1 open | progress-derived |
| Streak | "0 day streak" + "Earn 100 PX to start a new streak", dots empty | "1 day streak", one dot checked | progress-derived |
| League | Padlock + "6 days left to join" + "Earn pixels to join this week's league" | Ranked table with PX, viewer's row highlighted | progress-derived |
| Skill graph | Greyed + "Discover your strengths and unlock your personalized learning path" + **Get started** | Score dial (58), "40% reliability", six skill bars | progress-derived |
| Recommended for you | **Populated** | Populated | content-derived |
| Bulletin board | **Populated** | Populated | content-derived |

**The rule:** *progress-derived slots stay present and state the condition that would fill
them; content-derived slots are populated from the first second.* Nothing is hidden and
nothing is fabricated.

Three consequences worth taking:

1. **The layout never shifts.** The dashed placeholder occupies the exact footprint of the
   course card that replaces it. The learner's second visit is recognisably the same page as
   their first, which is what makes the home feel like *theirs* rather than a different
   screen each time.
2. **Empty is stated as a condition, not an absence.** "Earn 100 PX to start a new streak"
   and "Earn pixels to join this week's league" convert a blank widget into a goal. The
   padlock is doing honest work — it says *not yet*, not *not for you*.
3. **A zero-state home need not be an empty home.** Two of seven slots are content-derived
   and full on arrival. The page reads as populated even though the learner has done nothing.

## Observation 2 — This is what our Slice 9 criterion looks like when built

`PRD.md` Slice 9 already requires:

> *"Missing downstream content shows a neutral empty state and recovery action rather than
> fabricated progress."*

Uxcel is a working instance of exactly that, and it sharpens the criterion in a way worth
copying back: our wording implies a **binary** (content or empty state), where Uxcel
demonstrates a **three-way** treatment — *populated* / *empty with a recovery action* /
*locked with a stated unlock condition*. The third case is the one our PRD has no language
for, and it is the one most of a learning home's surface needs.

Our prototype currently does the opposite of all three. It hard-codes a **1-day streak**
(`prototype-web.html:538`) and **150 points** (`:541`) for a learner who has just arrived —
fabricated progress, precisely what the criterion forbids. Duolingo's locked-leaderboard
panel and Uxcel's locked league are now **two independent sightings** of the honest
alternative.

## Observation 3 — The appetite answer: you can design the slot without building the mechanic

This is the finding with the best cost-to-value ratio, and it addresses the plan's
requirement to say which §10 non-goals should **stay** non-goals.

§10 rules out "points, streaks, achievements" for this release, and §6 bounds the work at
10–12 iterations. Uxcel shows those two facts are not in tension: **the locked state of a
gamification slot costs almost nothing to build.** A padlock, a label, and a static unlock
condition require no points engine, no league scheduler, and no streak computation — only a
decision about what the condition *will* be.

So the recommendation is: **keep points, streaks, and leagues as non-goals; add their locked
slots to Slice 9.** That preserves the appetite, removes the fabrications, and leaves the
home honest and legible about where it is heading. Rough cost: well under one iteration.

## Observation 4 — The counter-case: at zero state there is no single next action

At zero state the home presents **Browse courses**, a three-step *Getting started* checklist,
a 25-question career quiz in the bulletin board, and two recommended course cards — none
visually dominant (`reference/01`, `reference/02`).

That runs against `PATTERNS.md`'s *Single recommended next step (goal → first meaningful
action)*, including its "route into practice, not into another browse surface" clause —
Uxcel's most prominent zero-state CTA routes into a **catalogue**. I expected Coursera to be
the study's counter-case; Uxcel is one too, which makes the tension more interesting than a
one-off.

Two honest readings, and the captures cannot separate them:

- **Uxcel has no goal signal to act on.** Its intake is thin, so it genuinely cannot pick one
  course — hence the career quiz offered as a way to *acquire* the signal. Our funnel collects
  a goal before the wall, so we would not be in this position.
- **Or a menu is the right answer at zero state**, and the single-next-step pattern applies
  once there is history to continue.

Our PRD assumes the first reading, and I think it is right — Slice 6 exists precisely so a
goal exists by the time the home renders. But this is worth putting to the peer-review panel
rather than treating as settled, because two of four benchmarked platforms diverge from a
pattern our design leans on.

## Observation 5 — Two smaller details worth stealing

**The checklist names the payoff.** *"Unlock your Aha! moment by working through these quick,
rewarding steps"* — it tells the learner what the reward for finishing is, in their terms.
That is the same construct our `2026-07-17-youth-onboarding-aha-moment` study was built
around, appearing here as literal interface copy. Note also that the panel **persists after
partial completion** rather than vanishing, with done rows greyed and checked, so progress
through it is itself visible.

**Uncertainty is displayed, not hidden.** The skill graph shows *"40% reliability"* beside its
score of 58 — the product tells the learner how much to trust its own assessment. If we ever
surface a recommendation confidence or a placement estimate, this is the honest pattern.

Also minor but real: *"3555 learning this week"* sits directly beside the empty
Continue-learning slot, so the loneliest moment on the page carries social proof.

---

## What this platform does and does not answer

**Answers well:** Q2 (zero state of non-gamification surfaces) — decisively, via the matched
pair. Q5 (which mechanics render before the first earn) — locked league, zero streak, greyed
skill graph, all with stated conditions.

**Answers partially:** Q4 (the first action) — as a counter-case rather than a confirmation.

**Does not answer:** Q1 (the handoff) — this flow contains no account-creation step, so the
transition into the home is absent; Uxcel's separate "Onboarding" flow would be needed.
Q3 (intake payoff) — no intake is visible in these captures. Q6 (cohort) — out of scope for
this platform; its "Accepting an invite" flow was dropped at plan stage as a B2B seat invite.

**Bearing on the Chrome plan:** Q2 no longer depends on first-party capture. Uxcel supplies a
genuine, well-documented zero state from the library. The Chrome pass is now *corroboration*
on the platforms where Mobbin's captures show only progressed accounts — Duolingo and
Brilliant — rather than the sole route to answering the question. See the study README.
