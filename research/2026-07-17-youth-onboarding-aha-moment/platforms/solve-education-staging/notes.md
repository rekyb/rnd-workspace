# Notes: solve.education (staging): current onboarding

**Source:** <https://staging.solve.education/> · accessed 2026-07-17 · public entry, no account.
**Pre-capture check (per PLAN):** staging serves a **redesigned career-ladder landing**
("Turn practice into proof employers trust", *LEARN → PROVE → GET HIRED*). This is
**neither** the old funnel flow **nor** the internally-documented activation flow. The observed
live build is: **Landing → Age gate → Signup wall.** Because it differs from the flow the
funnel numbers describe, the funnel is treated as *directional context on the current
wall-first pattern*, not a screen-by-screen match to this capture.

## Key observations (analysis, not a step replay; steps live in flow.md)

### 1. The current onboarding is wall-first, with zero value before signup
The single most important observation: a first-time visitor cannot experience *anything*
of the product before creating an account. Clicking the primary CTA leads to a DOB gate,
then a Name/Email/Password wall. There is no sample task, no ladder preview, no role-play,
no "first win". Every piece of value the landing advertises is post-account. For a product
whose whole pitch is "try job-like role-plays and see them scored", withholding the try
until after signup is the core activation problem.

### 2. There is a promise/experience gap
The landing makes a specific, motivating promise: *"pick a ladder in under a minute"* and
*"job-like role-plays ... Customer Support, Sales, or Remote Ops"*. That promise implies
an immediate, low-effort try. The actual next screens deliver a form and a wall. The gap
between what is promised and what is delivered is exactly the kind of expectation
violation that drives early bounce, and it wastes a genuinely strong value proposition.

### 3. The age gate is well-written but mis-placed
The DOB gate copy is careful and honest: neutral framing, a clear 18+/13–17/under-13
routing rule, and a reassurance that "DOB is not stored unless you complete onboarding".
As child-safety UX the *content* is good. The problem is *position*: it is the first
thing asked, ahead of any value. A DOB request is low-trust and slightly PII-adjacent;
asking for it before earning any interest maximizes its friction cost. (For the 15–36
target, note 18+ is the threshold for job matching / employer visibility, and 13+ is the
floor to use the product at all, so the target audience is not blocked, but they still pay
the friction.)

### 4. No deferred / guest path exists
Duolingo, Brilliant and others let a cold visitor reach a first win before asking for an
account (see the sibling benchmark). Solve's live flow has no equivalent: no guest mode,
no "try one task", no skip. This removes the mechanism most benchmarked learning apps use
to manufacture an early aha and to build the psychological ownership that makes the later
signup ask feel earned rather than imposed.

## Patterns worth synthesizing

- **Move the first "win" ahead of the wall.** The clearest design implication: let a
  visitor sample one job-like role-play (or at least pick a ladder and see a scored
  micro-attempt) *before* the signup ask. That sampled attempt is the candidate **aha
  moment** for this product: "I just did a slice of the actual job and got scored on it."
- **Defer the account ask until after value.** Reframe signup as "save your evidence /
  keep your progress" once the visitor has produced something, using the endowment /
  loss-aversion mechanic (they now have a result they don't want to lose).
- **Reposition (do not remove) the age gate.** Keep the child-safety gate, but trigger it
  at the point PII/persistence is actually needed (account creation), not as the entry
  toll.
- **Close the promise/experience gap.** Either the landing should promise what the flow
  delivers, or (better) the flow should deliver the try the landing promises.

## Evidence in this folder
- `flow.gif`: full motion capture, landing → age gate → signup wall.
- `screenshots/01-landing-hero.png`, `02-landing-3step-explainer.png`, `03-age-gate.png`,
  `04-signup-wall.png`, `05-signup-wall-buttons.png`.

## Caveats
- Desk research, one session, one device/viewport (web, 1568px). No account created, so
  the post-signup flow (ladder pick, role-play, scoring, reward, homepage) is unobserved
  and its friction cannot be assessed here.
- The under-13 / 13–17 routing states were not exercised (only the 18+ adult path was
  followed); their actual screens are unverified.
