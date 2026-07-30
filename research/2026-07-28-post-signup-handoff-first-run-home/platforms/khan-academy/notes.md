# Notes — Khan Academy (web)

Analysis. The step-by-step lives in `flow.md`.

**Standing caveats.** First-party Chrome capture, **2026-07-29**, trigger C2 (no Mobbin web
coverage, verified by three dedicated named searches). Desktop-web viewport, 1280×495–551 CSS px;
`PRD.md` §9 Slice 10 requires no horizontal scrolling at 320px, and a desktop read does not
settle narrow-viewport IA. **Audience fit is the best in the study alongside Duolingo** — free,
youth-facing, grade-based, and nonprofit: the top nav carries **Donate**, not an upgrade control,
so none of the merchandising pressure visible at Uxcel, Coursera, and CodeSignal is acting on
this surface. Region still differs from ours. Account creation was not observed (see `flow.md`).

**This capture closes the gap the 2026-07-28 session recorded as blocked.** That session
abandoned Khan Academy because only a **teacher** account existed, and saved nothing rather than
publish contaminated evidence. A **student** account now exists, so the platform the plan called
*"exactly where `2026-07-13` stopped"* is captured at genuine first run.

---

## Observation 1 — The best zero state in the study, and the one to copy (Q2, Q5)

Every progress affordance renders, at zero, with nothing invented:

| Affordance | Zero-state rendering | Condition stated? |
|---|---|---|
| Weekly streak | `0 week streak` | **No** — only in the dismissible tour |
| Level | `Level 1` + progress bar | Implicit in the bar |
| Skills | **`0 /1 skill`** | **Yes — countable, with denominator** |
| Badges | Six counters at `0`, `0 badges total` | No |
| Profile | *"Pick a username - Add your bio"* | Yes — names the action |

`0 /1 skill` is the sharpest instance of the study's countable-condition pattern, because it
carries its **denominator**. *"0 of 175 XP"* and *"Complete 9 more lessons"* tell a learner how
far; `0 /1 skill` tells them the whole ask is **one**. For an audience deciding in the first
thirty seconds whether this is worth starting, a denominator of 1 is the strongest available
answer.

**But the streak breaks the pattern, and how it breaks it is the useful part.** The condition
*is* stated — *"achieving Proficient or higher in at least one skill each week"* — in **tour step
2**, which is dismissible and never returns. Once closed, `0 week streak` sits on the home
unexplained, exactly like Babbel's and CodeSignal's bare zeros.

That splits a distinction the synthesis has not yet drawn: **stating the condition in onboarding
is not the same as stating it in the slot.** Only the second survives the learner's second
session. `0 /1 skill` survives; `0 week streak` does not.

**So what.** This is the concrete replacement for our prototype's two fabrications — the
hard-coded 1-day streak (`prototype-web.html:538`) and 150 points (`:541`). Not "show 0" — show
**0 against a denominator, in the slot itself**. `PRD.md` §9 Slice 9's criterion should say the
condition lives on the surface, not in an onboarding pass. Appetite: copy change plus one
denominator value, well inside §6's 10–12 iterations.

## Observation 2 — Intake payoff, done properly, and it is cheap (Q3)

The study now has a complete three-rung ladder on the same question, which is more useful than
any single instance:

| Rung | Platform | Intake result | On the home |
|---|---|---|---|
| Best | **Khan Academy** | 3 named courses | **The courses are the page** |
| Middle | Coursera | Career goal | Goal restated + editable; content by popularity |
| Worst | CodeSignal | 1 named path | **Nothing** — offers to redo the intake |

Khan's home does not *echo* the intake, it is **constituted** by it: *My courses* lists exactly
the three courses chosen in the modal, each with its unit sequence, plus **Edit Courses** to
revise. There is no separate "here's what you told us" banner because none is needed — the
learner's answer **is** the content.

That is the strongest argument the study can make for the open §11 decision (*canonical goal
taxonomy and goal-to-first-course map*, Content + Product). Khan does this with a **43-item**
course catalogue and no recommender: a selection screen writes a list, the home renders the list.
Our six-goal manually approved map is a smaller version of exactly this. The mechanism is a
stored selection, not a personalisation system.

**Disconfirming evidence, recorded:** Khan gets to skip the hard part. It asks the learner to
*pick courses directly*, so no mapping from goal to content is required at all. Our funnel asks
for a **goal**, which still has to be mapped. So Khan proves the *rendering* half is cheap; it
does **not** prove the mapping half is. Do not let this observation be read as evidence that the
§11 decision is easy.

## Observation 3 — A third mode for the single-next-step axis (Q4)

The axis after five platforms: intake resolving to a named unit predicts one dominant action
(Brilliant, Babbel); intake that does not predicts a menu (Uxcel, Coursera); CodeSignal showed
the result must also **reach** the surface that renders it.

Khan adds the fourth case, and it is a *quantity* effect rather than a kind. Its intake resolves
to named units — three of them, because it **invited** 4–5 — and the home renders **three
co-equal Start buttons**, one per course, none ranked. Not a menu of browse surfaces: every
button routes into practice, satisfying the `PATTERNS.md` clause. But not a single next step
either.

> The number of next steps on the home equals the number of units the intake was allowed to
> select. Singularity is a property of the **intake's cardinality**, not of the home's layout.

Uxcel and Coursera return a menu because intake selected nothing specific; Khan returns three
because intake selected three. Same mechanism, different input.

**So what, and it is favourable to us:** our Slice 6 produces **one** goal identifier. On this
reading we get the single Start for free — provided §11 maps one goal to **one** first course
rather than a shortlist. If the map ever returns "here are the 4 courses for your goal", we
reproduce Khan's dilution. That is a one-line constraint worth writing into Slice 9 now, while it
costs nothing.

## Observation 4 — First-run instrumentation, stacked in the wrong order (Q1-adjacent)

Q1's narrow question is not answered here — the signup submit was not observed. What *is*
observed is what the product puts in front of a new learner before the home is usable: a
**4-step feature tour layered over a blocking 2-step personalization modal**. Two dialogs open at
once.

Both interventions are individually defensible. Stacked, the order is backwards:

- The tour explains **levels, streaks, a jump-back control, and recent-course progress** — four
  reward mechanics — to an account with **no courses**. Step 3 describes a control that has
  nothing to point at (`screenshots/03-…`).
- The blocking modal that would *give* the learner content sits **underneath** it.

Teaching the reward system before the thing being rewarded inverts the sequence. `PATTERNS.md`
already carries *route into practice, not into another browse surface*; this is the same
principle one step earlier — **route into content before explaining the scoreboard**.

**So what.** Our funnel has an equivalent temptation: Slice 9's Learning Home is where a tour
would naturally be added. The evidence says a first-run tour of gamification mechanics is spent
too early. If we ship one, it belongs **after** the first learning action, and it should explain
the mechanic the learner has just triggered.

## Observation 5 — Two reusable microcopy patterns, and one defect (Slice 10)

Worth carrying:

- **The CTA label is the requirement.** Disabled, it reads **"Choose a grade to continue"** —
  the constraint stated on the control that enforces it. Choosing enables it and it becomes
  **Continue**. No error message is ever generated, because the failure cannot occur. This is
  error *prevention* rather than error *recovery*, and it costs one conditional label.
- **The CTA label is the receipt.** With three boxes ticked it reads **"Continue with 3
  courses"** — the same control confirming what is about to be submitted.

The defect, on the same screen: the banner instructs **"Choose 4–5"** while the CTA gate is
**"Choose 1 course to continue"** (`screenshots/07-…`). A learner who follows the instruction
does four times the work the product requires. Cheap to get wrong and cheap to fix — and worth
naming because our Slice 10 criterion about progress reflecting *"the actual configured step
count"* is the same class of defect: **the interface must not state a number the system does not
enforce.**

---

## What this platform does and does not answer

**Answers well:** **Q2** — the study's most complete first-party zero state, and the
tour-versus-slot distinction on where a condition must live. **Q3** — the top rung of the
intake-payoff ladder, with its own disconfirming caveat. **Q5** — the countable condition in its
strongest form (`0 /1 skill`, with denominator).

**Answers partially:** **Q4** — adds the cardinality reading of the axis rather than a fourth
data point. **Q1** — the signup-to-home transition is **not observed**; what is reported is the
first authenticated state, labelled as such, and no Q1 finding rests on it.

**Does not answer:** **Q6** — a **Teachers** item exists in the learner sidebar, but reaching a
post-enrolment cohort home needs a real teacher-issued class code. Per `PLAN.md` this stays a
documented gap with a usability session on our own prototype as the validation route; **do not
infer cohort behaviour from the existence of the nav item.**

**Observed and not transacted:** a **Donate** control in the top nav. No paid surface exists on
this product.
