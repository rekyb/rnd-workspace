# Flow — Coursera (web)

**Source:** Mobbin, accessed 2026-07-28. One observed variant of a library snapshot, not a
claim about Coursera's current live behaviour.

**Evidence rule applied throughout:** these are stills. Any statement about what the *system*
did is marked **inferred from screen sequence**. Nothing was observed first-party.

---

## Summary

**Entry point:** the public landing page. **Goal:** reach a personalised home.

Coursera collects a four-step intake after account creation, then renders the home **chrome
first with its content pending**, and finally resolves to a home carrying a persistent
restatement of the learner's stated goal above generic catalogue rails.

---

## Scouted context (positions 1–15, not cited)

Viewed while scouting; recorded here for sequence, with no finding resting on it:

- A landing page, then account creation.
- A conversational intake opening *"Hello [name]! Tell me a little about yourself so I can
  make the best recommendations. First, what's your goal?"* over four cards — **Start my
  career**, **Change my career**, **Grow in my current role**, **Explore topics outside of
  work**.
- Subsequent steps labelled explicitly **"Step 2 of 4"** (role interest, a searchable field
  with selectable chips) through **"Step 4 of 4"** (highest level of education, a vertical
  list of options), with **Back** and **Next**, and **Finish** on the last step.
- An **Exit** affordance persists in the top right throughout the intake.

Note the explicit *"Step N of 4"* labelling — the progress indicator names the real step count
rather than showing an unlabelled bar.

---

## The cited screens

1. **The handoff renders the destination before its content.** The full home chrome is
   present and real — wordmark, **Explore** menu, search field, the Home / My Learning /
   Online Degrees / Careers tab row, language selector, account avatar. Below it, centred, a
   small mascot glyph beside the line **"Preparing your recommendations"**, and beneath that
   **four skeleton cards** — grey blocks standing in for thumbnail, title, subtitle, and a
   short button.
   *Evidence: `reference/01-home-skeleton-preparing-recommendations.webp`.*
   *Inferred from screen sequence:* recommendations are being computed from the four intake
   answers. The learner is already **on** the home; only the content is pending.

2. **The home resolves with the goal restated at the top.** A full-width bordered banner
   spans the content column: **"Your career goal is to start a career as a Product Designer"**
   followed by a blue inline link, **"Edit goal"**.

   Below the banner, the page is catalogue rails. The first is headed **"Most Popular
   Certificates"** — four cards, each with a photographic thumbnail, a "New AI skills" flag, a
   provider logo, a certificate title, a "Build toward a degree" link, and the label
   "Professional Certificate" — followed by a **Show 8 more** button. The next rail is headed
   **"Explore with a Coursera Plus Subscription"**.
   *Evidence: `reference/02-home-goal-banner.webp`.*

---

## Where friction and delight sit

**Delight.** The wait happens *on the destination*, so there is no extra screen and no
context switch; the chrome the learner is about to use is already in front of them. And the
goal is not merely consumed — it is quoted back in the learner's own framing and left
editable in place.

**Friction.** The rail immediately beneath the personalised banner is headed **"Most
Popular"** — a popularity ordering, not a goal-derived one. The second rail is a subscription
promotion. The home states a goal, then offers content selected by criteria other than that
goal. There is no single next action anywhere on the surface.
