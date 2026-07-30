# Notes — Speak (analysis)

Source: Mobbin reference library, `ios`, accessed 2026-07-29. **Two screens — the thinnest
coverage in this study.** Reference-library observation, not first-party. Mobile-reference
platform: implications are **hypotheses for validation on Android mobile web**.

---

## Observation 1 — a second five-tab, fully-labelled instance (Q1)

`Home`, `Free Talk`, `Review`, `Challenge`, `Profile`. Five tabs, icon over text label, no
overflow — matching Mimo exactly in shape while differing entirely in content.

This is the **corroborating instance** that makes the mobile nav reading cross-platform rather
than single-source. With Babbel (3, labelled), Mimo (5, labelled), and Speak (5, labelled)
agreeing, and Duolingo (6, unlabelled, with overflow) as the lone exception, the pattern holds
at three of four: **a phone home carries around three to five labelled destinations, and the
one platform that exceeds five drops its labels.**

**Current-location treatment (added 2026-07-29 during QA, from the same two screens).** The active
tab is marked by a **tinted icon and label** against grey for the other four. Reference 02 shows
`Home` tinted; reference 01 shows `Profile` tinted. Same device as Mimo, different hue.

## Observation 2 — the path can stagger, and that is a space decision (Q4)

Duolingo and Mimo run their paths as a **single centred column** of nodes. Speak staggers
its cards horizontally across the width, alternating offsets.

The staggered arrangement fits five named steps into roughly one screen, where a centred column
of the same five would need scrolling. It buys density at the cost of a less obvious reading
order.

Worth carrying as an option rather than a recommendation: our own home has to fit a goal, a
next action, and some sense of the arc into a narrow column, and the study now holds two
published ways to lay out a sequence on a phone.

## Observation 3 — `Profile` is a progress destination, not an account screen (Q5)

Speak's `Profile` tab leads with `Your Courses` and `Your Activity Log`. Account settings are a
single gear glyph in the corner. So the tab named for identity is in practice **where progress
lives**.

That matches Babbel (progress detail in a profile **sheet**) and Duolingo (a separate
`Statistics` destination), against Codecademy (progress attached to each card, no destination)
and Uxcel (progress in a persistent rail).

The mobile pattern across the phone set: **when there is no rail, the detailed record moves to
a destination — often the profile — and only a small daily counter stays on the home.** That is
the single most directly applicable Q5 reading for a future mobile home on our side, and it is
supported by three of the four phone platforms.

*(Guard check: region and count only. Mechanic choice and register are settled by F2 and the
named `PATTERNS.md` entries.)*

## Observation 4 — the activity log is a record of doing, not of scoring (Q5)

`At a Crêperie · Free Talk · 13m ago`, repeated. The log names **what you did and when**, with
no score, no XP, and no rank.

Notable because it is the only instance in the study of a home-adjacent surface presenting
history as **episodes** rather than as counters. Whether that suits our audience is untested;
it is recorded as an option, not an implication.

---

## Caveats carried

- **Two screens only.** The thinnest platform in the study. Speak may not be the sole source of
  any finding; it corroborates Mimo on Q1 and contributes an alternative on Q4 block order.
- **Reference-library observation.** No first-party use, no live behaviour, no timing.
- **Point-in-time**, accessed 2026-07-29.
- **iOS only** — contributes to Q4's mobile half, not to a pair.
- **Three of five tabs unobserved**, plus the `Practice` segment of `Home`.
- **Audience transfer, and platform transfer.** A paid consumer language app with an AI tutor,
  on native iOS; our target is Android mobile web. Structure transfers, tab-bar idiom does not.
