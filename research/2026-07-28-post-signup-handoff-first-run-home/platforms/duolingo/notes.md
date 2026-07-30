# Notes — Duolingo (web)

Analysis. The step-by-step lives in `flow.md`; this is what the captures mean for our
questions and for `design/onboarding-solve-edu`.

**Standing caveats.** One observed variant of a Mobbin library snapshot accessed
2026-07-28, not Duolingo's current behaviour — onboarding and home surfaces are heavily
A/B tested. Desktop-web viewport; our audience is mobile-first and `PRD.md` §9 Slice 10
requires 320px to work, so no layout or density claim here transfers without testing.
Duolingo matches our audience on *free access* and *youth*, not on region.

---

## Observation 1 — The class code is a settings action, not an entry path

This is the sharpest divergence from our design, and it inverts the assumption the PRD is
built on.

Our funnel treats the program code as an **entry path**: it is offered on the landing page
("I have a program code"), validated *before* registration, and carried through intake into
finalization (`PRD.md` §7.1, §7.2, Slice 3). Duolingo does the opposite. Its class-code
field lives at **Settings → Duolingo for Schools**, reachable only by an
already-registered learner, alongside Password and Notifications
(`reference/06-classroom-code-empty.webp`). Joining a class is account *administration*,
performed after identity exists.

Neither order is self-evidently right, and the captures cannot tell us which converts
better. But the trade is legible:

- **Code-first (ours)** preserves program attribution from the very first touch and lets a
  facilitator hand out one link. Cost: the code must survive an anonymous session all the
  way to finalization, which is the machinery §7.2 and Slice 8 exist to build.
- **Code-after (Duolingo's)** needs no anonymous-session plumbing at all, because there is
  always an account to attach to. Cost: attribution for a learner who never returns to
  settings is simply lost, and the facilitator's code does no acquisition work.

For a program where a facilitator is standing in the room, ours is likely the better call.
Worth noting the option exists as a *second* path though: our PRD has no way for an
existing learner to join a program later, and Duolingo shows what that surface looks like.
**This is a genuine gap in our design, not a difference of opinion** — §10 lists "Editing or
switching a validated program during onboarding" as a non-goal, but never addresses joining
a program *after* onboarding at all.

## Observation 2 — Consequences are stated before the code, and again at commitment

The instruction above the empty field already says the teacher *"will be able to follow your
progress, control your account, and give you assignments"*. The confirmation modal then
repeats that sentence verbatim, with the teacher and class resolved by name
(`reference/08-classroom-join-confirm.webp`).

Two things worth taking:

1. **Confirm against a resolved identity, not a code string.** The learner approves
   "[Teacher]'s Japanese 3 classroom", not "XBMWDM". Our Slice 3 already requires a program
   preview showing name and organization, so we are aligned — but our preview is a *screen*
   and this is a *modal with an explicit decline*. The decline is worded "NO, DON'T JOIN",
   a full sentence rather than a bare Cancel.
2. **Name the powers being granted.** Our program preview tells the learner what they are
   joining; it does not tell them what the facilitator will be able to see or do. For a
   product serving minors — our Slice 5 admits 13–17-year-olds — that omission is worth
   raising with Legal/Privacy rather than leaving to the PRD's consent-version machinery.

## Observation 3 — Age is asked first, and carries its rationale inline

Duolingo asks *"How old are you?"* **before** name or email, with the reason stated under
the field: *"Providing your age ensures you get the right Duolingo experience."*
(`reference/02-age-gate.webp`). Name, when it is finally asked, is marked **optional**
(`reference/03-create-profile-form.webp`).

`PRD.md` Slice 5 flags exactly this as an unresolved question:

> *"This order intentionally follows the approved prototype (Name → Country → Age). Because
> that means limited profile data is collected before eligibility is known, Legal/Privacy
> must approve the temporary-session handling before launch. If they require eligibility
> before personal-data collection, Age moves before Name for both entry paths."*

So this is **direct evidence on an open decision the PRD has already assigned an owner and a
deadline**. A comparable youth-facing product resolved it the other way: eligibility first,
identity second, and the least-sensitive field (name) made optional entirely. That does not
decide it for us, but Legal/Privacy should see it before ruling.

## Observation 4 — The error preserves the entered code

The invalid-code state keeps the typed value in the field and leaves Submit active
(`reference/07-classroom-code-error.webp`). That satisfies our own Slice 3 criterion —
*"preserve the entered code for correction or retry"* — so it is confirmation rather than
news.

What Duolingo does **not** do is distinguish failure modes. Slice 3 requires that "invalid,
expired, exhausted, inactive, and technical errors use distinct localized messages"; the
capture shows one message for the one failure it demonstrates. Whether that is a deliberate
simplification or just the limit of what a five-screen library flow shows is not knowable
from stills. Do not read it as an argument against our five distinct states.

## Observation 5 — Registration is deferred and framed as saving, not unlocking

*"Time to create a profile! / Create a profile to save your progress and continue learning
for free"*, with **LATER** given equal visual weight
(`reference/01-deferred-profile-wall.webp`).

This corroborates the *Deferred, "try-first" registration* pattern already in
`research/PATTERNS.md` and the account-wall framing our PRD adopted, where the wall's job is
to make an account feel like *saving* something. It is not new ground — logging it as
corroboration, not a finding.

## Observation 6 — The home is dense, and the single next action competes for attention

The captured home puts one START affordance on the path against three right-rail panels: a
Super upsell, a locked-leaderboard panel, and a daily-quest bar — plus an ad-blocker notice
(`reference/05-home-progressed-not-zero-state.webp`).

The **locked-leaderboard panel is the transferable idea**: rather than hiding leaderboards
until they are earned or showing an empty one, it shows the mechanic locked *with the unlock
condition stated as a countable task* — "Complete 9 more lessons to start competing". That
is a direct answer to Q5's render-before-earn question, and it converts an unearned
gamification slot into a goal. `PATTERNS.md` already records the equivalent from the
2026-07-17 Duolingo capture (Daily Quest at 0/10, leaderboard locked behind 3 more lessons),
so this is a **second sighting of the same device at a different threshold**, which
strengthens it.

Contrast with our prototype, which fabricates a *1-day streak* and *150 points* for a
learner who has done nothing (`prototype-web.html:538`, `:541`). Duolingo never claims
progress that does not exist; it shows zeros and locks, and states what would unlock them.

---

## Limitations — what these captures cannot answer

**1. This flow's terminal home is not a zero state.** The stat strip shows a 10-day streak,
505 gems, 5 hearts, and Section 2. It is evidence about home *composition* only. **Q2 (the
zero state of non-gamification surfaces) is not answered by this platform yet.** Remedy,
per the plan's pre-decided fallback: a `search_screens` pass for a Duolingo first-run or
Section 1 home. Two candidate screens surfaced during planning showing *Section 1: Rookie*
with a START node and all later nodes locked; they were not part of either captured flow
and must be sourced and cited properly before any zero-state claim rests on them.

**2. The classroom flow never reaches the home.** It ends at the confirmation modal, so
**the core of Q6 — whether program identity, facilitator, and assigned tasks persist onto
the home after enrolment — is unanswered.** This is the single most decision-relevant thing
we wanted from this platform, since `learning_home` in our prototype hard-codes a "Digital
Heroes Tasks" panel with no evidence behind its shape. Remedy: a `search_screens` pass for a
Duolingo for Schools learner home, and if that returns nothing, this becomes a
`## Gaps & caveats` entry naming live observation or a usability session as the validation
route. **Do not infer the post-join home from the pre-join modal.**

**3. No timing or motion.** Per the plan, Q1 is composition-only. The submitting state
(`reference/04-create-account-submitting.webp`) shows *that* a busy state exists, not how
long it lasts or what follows it.

**4. Single-source on Q6 by construction.** Duolingo is the only true cohort flow in the
platform set. Any Q6 finding must be labelled single-source in the synthesis, per the plan's
success criteria.
