# Flow — Babbel (web)

**Source:** Mobbin, accessed 2026-07-28. One observed variant of a library snapshot, not a
claim about Babbel's current live behaviour.

**Evidence rule applied throughout:** these are stills. Any statement about what the *system*
did is marked **inferred from screen sequence**. Nothing was observed first-party.

**This is a comparison, not a journey** — two states of the authenticated home, identified by
the streak counter. There is no account-creation step in this flow, so Q1 is not addressed
here.

---

## The home at zero state

**Chrome.** A slim top bar: `Babbel` wordmark, three tabs (**Home**, Review, Explore), and at
the right a **streak counter reading 0**, a language selector showing the target-language
flag, and an account menu. No sidebar — the whole page is one column.

**Greeting.** *"Hi, [name]"* in a serif display face, then two sub-tabs: **Today** (active)
and **Learning plan**.

**The lesson context line.** Above the carousel, in small grey type: *"Newcomer I (A1.1) -
Unit 1"*, and beneath it in bold: **"Greet people and say goodbye"**.
*Evidence: `reference/01-home-zero-state.webp`.*

This matters — at zero state the learner already has a **named unit and a named topic**. The
product has picked a starting point rather than asking them to.

**The carousel.** Two cards side by side, with pagination dots showing six positions:

1. A full-bleed orange card: **"Answer a few questions to find your level"** with a bar-chart
   illustration and a white **Find level** button.
2. A lesson card: *"Lesson 1"* over a title in the target language, with a photographic
   thumbnail.

*Evidence: `reference/01-home-zero-state.webp`.*

So the first thing offered is an *optional* refinement of the starting point, and the second
is the starting point itself, ready to begin.

**The Courses section.** A heading **Courses** with a **See all** link, and beneath it a wide
grey panel containing a trophy glyph and one line of centred text:
**"Start learning to see your progress here."**
*Evidence: `reference/01-home-zero-state.webp`.*

An explicit, written empty state — the section is present, framed, and says what would fill it.

---

## The home once populated

Same page, same structure. What changed:

- The **streak counter reads 1** and is rendered in colour.
- A new strip appears above the unit line: *"Daily vocab workout / **Time for a quick
  review**"* with a decorative tile.
- The context line advances to *"Newcomer II (A1.2) - Unit 1"* / **"Talk about
  relationships"**, and the carousel now holds numbered lessons with a **Start lesson**
  button.
  *Evidence: `reference/02-home-populated-today.webp`.*
- The **Courses** panel replaces its empty-state line with course entries, each an
  illustrated circular icon and a label.
- A **"Learn with others"** section appears below with a referral block (*"Earn rewards —
  Give your friends the gift of Babbel and earn rewards."*, **Invite friends**).
  *Evidence: `reference/03-home-populated-courses.webp`.*

*Inferred from screen sequence:* completing at least one lesson lit the streak, advanced the
unit pointer, unlocked the review prompt, and filled the Courses panel.

---

## Where friction and delight sit

**Delight.** The learner never faces a blank page or a decision they cannot make. A unit and a
topic are chosen for them, the first lesson is one click away, and the only empty region on
the page says plainly what would fill it. The placement test is offered as an *upgrade* to the
default, not a toll gate before it.

**Friction.** The streak counter sits at 0 in the top bar with no adjacent explanation of what
would move it — the one progress affordance here that does *not* state its own unlock
condition, in contrast to Uxcel, Brilliant, and Duolingo.
