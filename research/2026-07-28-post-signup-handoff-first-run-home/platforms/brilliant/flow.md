# Flow — Brilliant (web)

**Source:** Mobbin, accessed 2026-07-28. One observed variant of a library snapshot, not a
claim about Brilliant's current live behaviour.

**Evidence rule applied throughout:** these are stills. Any statement about what the *system*
did is marked **inferred from screen sequence**. Nothing was observed first-party.

---

## Summary

**Entry point:** the public landing page. **Goal:** reach the first learning action.

Brilliant does **not** drop the learner onto a home after account creation. It spends four
screens converting the signup into a visible, personalised destination first — a labelled
wait, a recommendation to accept or change, a mechanic explainer — and only then renders the
home. This is the richest handoff in the study.

---

## The flow

1. **Landing forks by audience.** *"Learn by doing"* over two buttons: **I'm a learner**
   (filled green) and **I'm a parent or teacher** (outlined). A subject strip runs along the
   bottom (Math, Computer Science, Coding & AI, Data Analysis, Science & Engineering).
   *Evidence: `reference/01-landing-learner-fork.webp`.*
   The audience question is asked before anything else, and the learner path is the visually
   dominant one.

2. **Account creation.** *"Create a free profile to discover your learning path"* — Google, or
   email with password, first and last name, and an **age** field. An adjacent tooltip
   explains why age is collected: it customises the problem-solving experience and keeps the
   product compliant with local regulations. *(Screen viewed during scouting; not cited, so
   not downloaded — see `references.md`.)*
   Note the heading frames the account as the means to *discover your learning path*, not as
   a gate.

3. **A labelled wait.** A spinner over the line **"Loading your learning path
   recommendations"**.
   *Evidence: `reference/02-handoff-loading-labelled.webp`.*
   *Inferred from screen sequence:* recommendations are being computed from the signup inputs.
   The screen exists to say what the delay is *for* — see `notes.md`, Observation 1.

4. **A recommendation, offered rather than imposed.** *"Here's what I recommend. Get started
   with one and switch any time."* Four cards: **Foundations for Algebra** (badged **TOP
   PICK**, pre-selected with a blue border, "LEARNING PATH • 4 COURSES"), **Data Analysis**
   ("LEARNING PATH • 5 COURSES"), **Scientific Thinking** ("1 COURSE"), and **Probability and
   Chance** ("1 COURSE"). A single **Continue** button.
   *Evidence: `reference/03-recommendation-picker-top-pick.webp`.*
   One option is chosen *for* the learner; the other three are visible; switching is stated as
   reversible in the same sentence.

5. **A path map** shows the selected learning path as a horizontal chain of four courses, the
   first badged **START HERE**. *(Viewed during scouting; not cited, so not downloaded.)*

6. **A mechanic explainer.** *"Let's start learning! You'll use keys to unlock lessons — get
   your first keys now"* over a **Continue** button.
   *Evidence: `reference/04-keys-mechanic-explainer.webp`.*
   The product's currency is taught before the learner meets it in the interface.

7. **The home, at zero state.** Header: Home / Courses tabs, a **Go Premium** pill, and two
   counters reading **2 🏅** and **0 ⚡**. Left column, top to bottom:
   - a streak card showing a large **0 ⚡** over **"Solve 3 problems to start a streak"**, with
     five day-initials (Th F S Su M) all greyed;
   - a Premium upsell (*"Unlock all learning with Premium to get smarter, faster"*, **Explore
     Premium**);
   - a **padlocked** card reading **"UNLOCK LEAGUES / 0 of 175 XP"**.

   Right column: a single card labelled **RECOMMENDED**, titled **Arithmetic Thinking**,
   **LEVEL 1**, with an illustration, the lesson name *Finding Half*, and one filled blue
   **Start** button. Beneath it, a row of five small course icons.
   *Evidence: `reference/05-home-zero-state.webp`.*

8. **The same home, populated.** After roughly one day: the streak card reads **1 ⚡** with the
   Thursday marker lit and lightning icons in the corner; the padlocked leagues card is
   replaced by **HYDROGEN LEAGUE — "Top 15 advance · 3 days left"** over a live ranked table
   of learners with XP totals, the viewer's own row highlighted; the top-bar counters read
   **1 🏅 1 ⚡**. The recommended card is unchanged.
   *Evidence: `reference/06-home-populated.webp`.*
   *Inferred from screen sequence:* completing one lesson lit the streak and crossed the
   league's entry threshold.

9. **Inside a course**, lessons render as a vertical chain: the current lesson in colour and
   named, later lessons greyed with muted labels, and a floating **Start** card pinned to the
   active one.
   *Evidence: `reference/07-course-path-locked-lessons.webp`.*

---

## Where friction and delight sit

**Delight.** The handoff never leaves the learner wondering what happens next. The wait is
labelled, the recommendation arrives pre-chosen but reversible, and the home resolves to
exactly one blue button. From landing to first action there is never more than one obvious
thing to do.

**Friction.** A Premium upsell sits in the left column of the zero-state home, above the
locked-leagues card — before the learner has completed anything. And the two top-bar counters
(**2 🏅 0 ⚡**) are unexplained at zero state; the keys explainer covered keys, not these.
