# First-Run Learning Home

**Status:** Active
**Started:** 2026-07-29
**Informed by:** research/2026-07-28-post-signup-handoff-first-run-home, research/2026-07-20-unified-onboarding-synthesis-and-patterns
**Design system:** ui-library/

## Problem

When a learner finishes onboarding and reaches the Learning Home for the first time, they have
completed nothing, so every progress surface on that screen is either empty or filled with numbers
they did not earn. The existing prototype renders a **1-day streak**, a **150-point total**, a
**40% progress bar**, and the greeting **"Welcome back!"** to an account created seconds earlier
(`design/onboarding-solve-edu/prototype-web.html:537-552`), and its regression suite asserts against
none of it. This project builds that first-run state honestly: every progress affordance renders at
zero against a countable condition stated **in the same slot**, no slot is reassigned to promotional
content, and the primary action is computed from the learner's **stored intake** rather than from
behaviour they do not yet have.

The test is observable rather than aesthetic: **a value rendered on this screen either derives from
durable learner data or it does not**, and a first-run home either states what would move a zero or
it leaves the learner guessing.

## Relationship to `design/onboarding-solve-edu`

That project owns the **acquisition and onboarding funnel** and stays `Design system: independent`,
a terminal state settled 2026-07-28. This project owns the **first-run Learning Home surface only**,
and is built on `ui-library/` from the start, so it is gate-clean by construction rather than by
migration. Nothing here re-attempts that project's migration, and nothing here weakens the gate.

The decision doc for this surface already exists as **Cycle 2 (Slices 12 and 13) of
`design/onboarding-solve-edu/PRD.md`**, together with its §2.1 findings coverage, its §11 screen
entries, and the Prototype Element Dictionary row set in Appendix A.5. This project's own `PRD.md`
is scoped to what differs here: the `ui-library/` element dictionary and the component constraints
that follow from it.

## Scope note: why this project is the Learning Home and not the funnel

`/design-prototype` **stops** on a component `ui-library/COMPONENTS.md` marks `not yet ported`,
rather than improvising a lookalike. The onboarding funnel needs six that are unported, and they are
the intake mechanic itself rather than decoration:

| Component | Needed for | Status |
|---|---|---|
| Input | name, email, password, program code | `not yet ported` |
| RadioGroup | age band, gender, goal, the recognition-based single-choice pattern | `not yet ported` |
| Select / Command | the country combobox | `not yet ported` |
| Checkbox | consent capture | `not yet ported` |
| PasswordInput | account creation and login | `not yet ported` |
| Progress | the step indicator with its text equivalent | `not yet ported` |

The first-run Learning Home needs none of them. It composes from CSS-only components (Text, Card,
Row, Button, Stat, StrengthMeter, EmptyState, LoadingState, List), which is what makes this surface
buildable on the library today while the funnel is not.

## Status log

| Date | Entry |
|---|---|
| 2026-07-29 | Project created. Scoped to the first-run Learning Home after a component-availability check found six unported components blocking a full-funnel build on `ui-library/`. |
| 2026-07-29 | **Scope widened to the full journey, and four components ported to unblock it.** `RadioGroup`, `Checkbox`, `PasswordInput` and `Select` were ported into `ui-library/behaviors.js` against their published class contracts, and `COMPONENTS.md` updated (ported 4 → 8, not-yet-ported 19 → 15). `Input` stays `not yet ported` and that is accurate: its contract is `.input` plus an `.input.err` modifier with no interactive behaviour, so a native input satisfies it without JavaScript. This is the "port on demand" path `/design-prototype` names first, not a workaround for its stop. |
| 2026-07-29 | **Prototype rebuilt as a real journey**, replacing a state gallery with a switcher. Eleven screens: landing → program code → program preview → name → country → age → goal → account wall → labelled handoff → Learning Home → first skill. Completing the first skill returns to the same home with `first_action_at` set, so the first-run and returning states are the same markup with different data, which demonstrates the Slice 12 rendering invariant rather than asserting it. Progress derives from one configured step list per entry path (5 organic, 6 program), so the bar and its "Step N of M" text cannot disagree. `check-prototype.ps1`: **PASSED**. Principal Designer Mode T reviewed the earlier state-gallery build and returned **revise**; its component-contract findings were applied, but **the current build has not been re-reviewed**. |
