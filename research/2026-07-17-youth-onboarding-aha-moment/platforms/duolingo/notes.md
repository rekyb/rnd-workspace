# Duolingo: delta notes (time-to-first-win & signup placement)

**Surface:** desktop web, `duolingo.com` guest session, French course. Captured 2026-07-17.
**This is a delta capture, not a full re-benchmark.** The complete Duolingo onboarding
flow (landing → deferred registration → mascot-guided personalization → placement fork →
first-task guidance → deferred signup wall) is already documented in the sibling study and
is the **basis** for this study:
`research/2026-07-13-onboarding-activation-education-apps/platforms/duolingo/`
(`flow.md`, `notes.md`, `flow.gif`, `screenshots/`).

The sibling capture explicitly **did not reach the first win** ("diverted into placement to
document advanced routing, then exited"). Because *this* study is about the **aha moment**,
the first win is the exact thing we needed to observe. This note captures only that gap.

> A/B caveat: Duolingo heavily A/B-tests onboarding. This session resumed an existing
> guest cookie and entered at the product home (the coach-marked first skill node), so the
> pre-lesson questionnaire was shortened versus a cold first visit. Step logic matches the
> sibling capture; only the entry point differed.

## What we came to pin down

### 1. The first win is a deliberately trivial recognition task (fast, near-guaranteed)
The very first item of the first lesson is a picture-match: **"Which one of these is
'coffee'?"** with three illustrated options (café / croissant / thé). A learner with
**zero French** can get it right by cognate + image. Duolingo engineers the first
interaction to be *won*, not *tested*. Instant feedback follows: a green check and **"Nice
job!"**. The first thing a new learner produces is a success.
- ![first task](screenshots/01-first-task-new-word-coffee.png)
- ![first win "Nice job!"](screenshots/02-first-win-nice-job.png)
- Motion: `flow-first-win-delta.gif`.

### 2. Time-to-first-win is short, and it is reached with no account
From the product home node the path to the first win was: **START → proficiency
self-select ("I'm new to French") → CONTINUE → path fork ("Start from scratch") →
CONTINUE → first question → select café → CHECK → "Nice job!"** ~4 screens / ~7 taps, a
handful of seconds, all inside a **guest session**. From a genuine cold landing the sibling
counted ~9 taps of questionnaire before the lesson; either way the first tangible win lands
in **under ~2 minutes and before any email/password is requested**.

### 3. The signup ask stays behind the win (deferred, loss-aversion framed)
The account wall is **not** encountered on the way to the first win. It sits on the `/learn`
home as a persistent, low-pressure banner: **"Create a profile to save your progress!"** So
the sequence is *value first (a completed correct answer, XP, a streak begun) → then the
signup ask, framed as protecting what you already earned*. This is the exact inverse of the
solve.education staging flow, where the signup wall is reached **before** any value at all.

## Why this matters for solve.education (the transferable point)
The aha we should copy is not "gamification"; it is **the guaranteed early win reached
before the wall**. Duolingo:
- makes the *first* action a near-certain success (recognition, not recall);
- gives *instant* positive feedback on it;
- lets the learner accumulate a little something (XP, a first correct answer) as a
  **guest**;
- and only *then* asks for an account, framed as "save your progress".

solve.education's own equivalent already exists conceptually in its landing promise ("do a
job-like role-play, see it scored into evidence"). The gap is purely **ordering**: today
that win is locked behind the age gate + signup wall. Moving one small, winnable slice of
the role-play ahead of the wall is the single highest-leverage change.

## Sources
- https://www.duolingo.com/learn (guest product home), accessed 2026-07-17
- https://www.duolingo.com/lesson (first lesson, first-win capture), accessed 2026-07-17
- Basis (reused): sibling study `2026-07-13-onboarding-activation-education-apps/platforms/duolingo/`
