# Notes — Brilliant (web)

Analysis. The step-by-step lives in `flow.md`; this is what the captures mean for our
questions and for `design/onboarding-solve-edu`.

**Standing caveats.** One observed variant of a Mobbin library snapshot accessed 2026-07-28.
Desktop-web viewport; our audience is mobile-first and `PRD.md` §9 Slice 10 requires 320px to
work. Audience transfer: Brilliant is a paid-tier STEM product for self-directed Western
learners; our PRD serves free-access, low-context Indonesian youth. The *structure* below
transfers; the subject matter, tone, and price model do not.

**Continuity note.** Brilliant was benchmarked in `2026-07-13-onboarding-activation-education-apps`
for the **pre-signup** funnel. Everything here is post-account-creation, so this is
continuation rather than duplication — but any Brilliant claim in the synthesis must name
which study it came from.

---

## Observation 1 — The handoff is four screens, and each one does work (Q1)

This is the study's best answer to Q1, and it directly contradicts the shape our PRD assumes.

`PRD.md` §7.3 goes: identity created → finalize atomically → *return the destination and
first-action payload for Learning Home*. One step, then the home. Brilliant instead spends
four screens between account creation and the home:

| Screen | What it does |
|---|---|
| Labelled spinner | Says what the wait is *for*: "Loading your learning path recommendations" |
| Recommendation picker | Converts intake into a named destination the learner can accept or change |
| Path map | Shows the shape of the journey before it starts |
| Mechanic explainer | Teaches the product's currency before it appears in the UI |

The **labelled loading state** is the cheapest and most transferable of the four. A spinner
that says *"Loading your learning path recommendations"* converts dead time into evidence
that personalisation is happening — the learner sees their intake being *used*. Our funnel
collects name, country, age band, and goal, then shows the learner a home. Nothing in between
tells them the goal mattered. A labelled wait during finalization is close to free and would
close that gap. (§9 Slice 7 already requires a loading state to prevent duplicate submission;
this costs only the copy.)

The **recommendation picker** is the sharper design question. Brilliant picks one path,
badges it **TOP PICK**, pre-selects it, shows three alternatives, and says *"Get started with
one and switch any time"* in the same breath. Commitment and reversibility are stated
together. Our Slice 6 asks the learner to choose a goal from six equal options with no
recommendation and no stated reversibility, and §10 rules out "editing or switching a
validated program during onboarding". Worth asking whether *"you can switch any time"* should
appear on our goal screen — it costs one line and removes a reason to hesitate.

## Observation 2 — Second independent sighting of the slot rule (Q2, Q5)

Brilliant's zero-state home applies the same rule Uxcel does, on a different product with a
different visual language:

| Slot | Zero state | Populated | Category |
|---|---|---|---|
| Streak | Large **0 ⚡** + "Solve 3 problems to start a streak", day markers greyed | **1 ⚡**, one marker lit | progress-derived |
| Leagues | **Padlock** + "UNLOCK LEAGUES / 0 of 175 XP" | "HYDROGEN LEAGUE — Top 15 advance · 3 days left" + ranked table | progress-derived |
| Recommended card | **Populated** — Arithmetic Thinking, Level 1, *Finding Half*, Start | Unchanged | content-derived |
| Course path | First lesson active, later lessons greyed | (same) | progress-derived |

Same rule: *progress-derived slots stay present and state the condition that would fill them;
content-derived slots are populated from the first second.* Nothing hidden, nothing
fabricated.

With Uxcel this makes **two independent sightings**, which is the plan's two-platform bar for
Q2 and Q5 — and Duolingo's locked-leaderboard panel is a third instance of the locked-slot
device specifically. This is now a finding, not an observation.

Note the quantified threshold: **"0 of 175 XP"** and **"Solve 3 problems"**. Both Uxcel
("Earn 100 PX") and Duolingo ("Complete 9 more lessons") do the same. Across three platforms
the unlock condition is stated as a *countable* target, never as vague encouragement.

## Observation 3 — It resolves the tension Uxcel opened (Q4)

Uxcel's zero-state home offered no single next action — Browse courses, a checklist, a career
quiz, and two course cards, none dominant. That ran against `PATTERNS.md`'s *Single
recommended next step*, and I wrote it up as an open tension with a hypothesis: **Uxcel
diverges because it has no goal signal to act on.**

Brilliant is the control case. It asks the audience question, collects age, computes a
recommendation, has the learner confirm it, and lands them on a home with **exactly one blue
Start button** for a named lesson. Same category of product, opposite outcome — and the
difference is precisely whether intake produced a usable signal.

**The hypothesis holds.** The pattern is not wrong; it is *conditional on having a signal to
act on*. That matters for us because Slice 6 exists to produce exactly that signal before the
home renders, which puts our design on Brilliant's side of the line rather than Uxcel's. Worth
stating explicitly in the synthesis so the peer-review panel can attack it if they disagree.

## Observation 4 — What our prototype's Learning Home should borrow

Our `learning_home` currently shows a fabricated 1-day streak (`prototype-web.html:538`), a
fabricated 150-point total (`:541`), an "Up Next" card at a fabricated 40%, and a Start Lesson
button. Brilliant's zero-state home is the same *shape* — one recommended thing, one button,
gamification in the margin — but every number is honest:

- streak shows **0** with the action that would start it;
- the league is **locked** with its XP threshold named;
- the recommended card carries a real level and a real lesson name.

The gap between our home and Brilliant's is not layout. It is that ours claims progress the
learner has not made. Fixing it needs no new components — only replacing two hard-coded values
with a zero and a stated condition.

## Observation 5 — Two smaller things

**Audience fork before anything else.** *"I'm a learner"* / *"I'm a parent or teacher"* is the
first choice on the landing page. Our funnel forks on *how you arrived* (organic vs. program
code) but never on *who you are*. Not a gap — our program path implies the facilitator
relationship — but worth noting that a facilitator arriving at our landing page has no
signposted route.

**Age carries its rationale, again.** Brilliant's age field has a tooltip explaining that it
customises the experience and keeps them compliant with local regulations. Duolingo does the
same thing with inline copy. **Two of four platforms explain why they want age at the moment
they ask.** Our Slice 5 collects an age band with no stated reason and leaves the
Legal/Privacy question open. Cheap to fix, and it is the field most likely to make a young
learner hesitate.

---

## What this platform does and does not answer

**Answers well:** Q1 (the handoff) — decisively, and as a counter-shape to our PRD's
one-step model. Q2 and Q5 — second sighting of the slot rule with quantified thresholds.
Q4 — the control case that resolves Uxcel's counter-example.

**Answers partially:** Q3 (intake payoff) — the recommendation picker *is* the payoff, made
visible as its own screen rather than as a banner on the home. Different mechanism from
Coursera's persistent goal banner; both worth carrying into the synthesis.

**Does not answer:** Q6 (cohort) — Brilliant has no cohort or code mechanic in these captures.
