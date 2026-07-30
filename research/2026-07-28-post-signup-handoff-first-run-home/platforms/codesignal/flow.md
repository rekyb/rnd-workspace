# Flow — CodeSignal (web)

**Source:** Claude-in-Chrome, first-party capture, accessed **2026-07-29**. Trigger **C2** —
CodeSignal has no Mobbin web coverage (null search logged in `sources.md`, 2026-07-28).

**Evidence rule applied throughout:** unlike this study's five Mobbin platforms, these screens
were operated first-party, so statements about what the *system* did are **observed**, not
inferred. Where something was *not* observed it is labelled **not observed** and no finding
rests on it.

---

## Capture conditions (read before citing any screen)

Three conditions bound what these captures can support:

1. **Account creation was not observed.** The account was created by the user in an earlier
   session; this capture resumed an already-authenticated session that had **not yet completed
   onboarding** (it landed on `/learn/onboarding`). The account carried genuine zero progress —
   `0 days` streak, an empty *My Learning*. So the **zero-state** questions (Q2, Q5) are
   answered first-party, but **Q1 — what stands between the account-creation submit and the
   home — is not answered by this platform.** Marked *not observed* throughout.

2. **The intake answers are mine, and they shape the payoff.** I answered *Start a new career*
   → *Software Engineering* → *Beginner* (the last typed as free text). A different path
   through the intake would produce different recommendations. Findings about *whether the home
   reflects intake at all* hold regardless of the branch; findings about *which* content was
   recommended do not generalise.

3. **Viewport, and one injected-CSS intervention.** Captured at a **1280×495–551 CSS px**
   viewport (`devicePixelRatio` 1.5; screenshots are 1568px wide at ~1.225×). CodeSignal locks
   its onboarding layout to `h-dvh` with an `overflow-hidden` child; below roughly **576px** of
   viewport height the footer CTA row is **not painted at all** — it is clipped, not scrollable.
   Screens **01–06** were therefore captured with `div.h-dvh` pinned to 600px and `html/body`
   overflow unlocked, so the app's own footer would render. Proportions inside the content area
   are otherwise untouched. Screens **07–11** are **native** — the full page load on navigating
   to `/learn` cleared the injected CSS.

   This limits Q4: at this viewport I can report **what** is on the surface and **in what
   order**, but a claim about visual dominance measured against a full desktop fold is not
   supported.

**Redaction.** A `window.__redact()` helper blurred the account avatar by source role
(S3 profile-content host) and masked email- and name-shaped slots, re-applied via
`MutationObserver` after every re-render and re-injected after each full page load. All 11
committed PNGs and all 9 GIF frames were inspected before saving; every avatar slot renders as
a flat blurred square, and no name, email, or face appears in any frame.

**No payment.** An **Upgrade** control sits in the top nav on every authenticated screen and is
recorded as part of the composition. Nothing was purchased, trialled, or upgraded.

---

## Summary

**Entry point:** an authenticated but un-onboarded session at `/learn/onboarding`.
**Goal:** reach the first learning action.

CodeSignal runs its intake as a **conversational exchange with an LLM persona** ("Cosmo") that
resolves to a **named path with a dominant Start path CTA inside the conversation**. Leaving
that conversation for the home discards the result: `/learn` redirects to a **catalogue**, and
*My Learning* — the surface that should hold the learner's own path — is at zero state an
**app-download advertisement**.

---

## The cited screens

1. **The intake opens with a mascot greeting, not a task.** Full-bleed dark space scene; the
   Cosmo mascot beside a speech bubble: *"Hi! I'm Cosmo, your guide on this journey through the
   universe of skills. 🙌"*. The footer row carries a secondary **Skip for now** and a primary
   **Continue →**.
   *Evidence: `screenshots/01-onboarding-greeting-and-cta.png`.*
   *Observed:* the greeting text renders with a typewriter animation; a capture taken 1.5s after
   the click caught it mid-word (*"Befo"*), so the copy is revealed progressively rather than at
   once.

2. **A consent step precedes the questions.** *"Before we take off, can you answer a few
   questions to help me chart an optimal learning path just for you? ✨"* The footer becomes
   **Skip for now** / **Let's go!**.
   *Evidence: `screenshots/02-intake-consent-prompt.png`.*
   The intake is **asked for, not assumed** — and it states its purpose ("chart an optimal
   learning path") before spending the learner's effort. Two screens pass before any question.

3. **Question 1 — motivation, as chips over a free-text field.** The layout switches to a chat
   transcript: a **Cosmo** avatar and name, the question *"Let's start with motivation - what is
   motivating you to learn? ✨"*, four quick-reply chips — **Start a new career**, **Boost my
   career**, **Just for fun**, **Prepare for interviews** — and beneath them a persistent
   **"Type your response…"** input with a send control.
   *Evidence: `screenshots/03-intake-motivation-chips-and-freetext.png`.*
   *Observed:* both affordances are live for the same question. The chips give recognition over
   recall; the free-text field accepts anything.

4. **Question 2 — domain, with the previous answer acknowledged.** The chosen chip renders as a
   right-aligned user message; the reply reads *"That is a bold and exciting mission! 🚀 To help
   you find the right orbit, what kind of role or domain are you most interested in exploring?"*
   over four chips: **Generative AI**, **Software Engineering**, **Data Science**, **Business and
   Leadership**.
   *Evidence: `screenshots/04-intake-domain-question.png`.*

5. **Question 3 — level, answered before it is asked.** The reply *"A stellar choice! To find
   the best starting point, what is your current level of experience with programming? 🧠"* is
   followed **immediately, in the same turn**, by a full recommendation card: a **BEGINNER**
   badge, **Introduction to Programming with Python**, *5 courses · 121 practices*, a filled
   primary **Start path** and an outlined secondary **Learn more**.
   *Evidence: `screenshots/05-intake-level-with-path-card.png`.*
   *Observed:* the system recommends a beginner path **while still asking** for the level that
   would determine it. No chips are offered for this question — only the free-text field.

6. **The recommendation changes when the question is answered.** I typed **Beginner**. The reply
   — *"Since you're just starting out, I recommend the path 'JavaScript Programming for
   Beginners.' It's a fantastic way to build a solid foundation in one of the most popular
   languages for software engineering! 🎯"* — carries a **second** card: **BEGINNER**,
   **JavaScript Programming for Beginners**, *7 courses · 184 practices*, again **Start path** /
   **Learn more**.
   *Evidence: `screenshots/06-recommendation-drift-python-to-js.png`, showing both cards in one
   frame.*
   *Observed:* two different first paths were recommended for the same declared profile inside a
   single exchange, and the answer that resolved the ambiguity ("Beginner") **matched the level
   the first card had already assumed**. Both cards stay in the transcript, both with an equally
   weighted **Start path**. The learner is left choosing between them with no stated basis.

7. **`/learn` does not resolve to a personalised home.** Navigating to `/learn` redirects to
   **`/learn/course-paths`**, titled *"Explore paths"*. Top nav: **Paths** (active) · **My
   Learning** · **Assessments** · **Profile**, then a flame glyph reading **0 days**, a
   notification bell with a green dot, a blue **Upgrade** button, and the account avatar
   (blurred). The content column opens with the H1 **"Learning paths"** and a **See all paths →**
   control; immediately beneath, the largest element on the surface is a light-blue
   **app-download promotion** — *"Turn screen time into skills time / Chat with Cosmo, build real
   skills, and learn in a whole new way"* — with App Store and Google Play badges, a QR code, and
   a phone mockup.
   *Evidence: `screenshots/07-home-paths-top-app-promo.png`.*
   *Observed:* neither the JavaScript path nor the Python path appears anywhere on this surface.
   The intake result is not carried to the home.

8. **Below the promo: a six-tile catalogue and an offer to redo the intake.** A **Collections**
   grid — *Generative AI*, *Business & Leadership*, *Interview Prep*, *AI & Machine Learning*,
   *Learn to Code*, *Data Science & Engineering* — then a Cosmo panel headed **"Not sure where to
   start?"** with *"Let's chat, and I'll recommend the best path for you!"* and a **Find your
   path** control.
   *Evidence: `screenshots/08-home-collections-and-chat-offer.png`.*
   *Observed:* the home offers to run the recommendation conversation the learner **has just
   completed**, with no acknowledgement that it already ran.

9. **The Trending rail serves levels the learner did not declare.** Headed **Trending**, with
   horizontal scroll controls: **INTERMEDIATE** *Full-Stack Engineering with JavaScript*,
   **ADVANCED** *Advanced Coding Interview…*, **ADVANCED** *Advanced Interview Prep for…*.
   *Evidence: `screenshots/09-home-trending-level-mismatch.png`.*
   *Observed:* the first three cards on the rail are Intermediate or Advanced, shown to an
   account that declared **Beginner** minutes earlier. The ordering is trend-based, not
   level-filtered.

10. **`My Learning` at zero state is an advertisement.** The tab that should hold the learner's
    own path renders a single full-width panel: **"Start learning in the Cosmo app!"**, *"Build
    real skills in just 5 minutes per day."*, App Store and Google Play badges, a QR code, and a
    phone mockup showing a mocked-up in-app lesson.
    *Evidence: `screenshots/10-my-learning-zero-state-app-ad.png`.*
    *Observed:* there is **no empty state** here in the usual sense — no message naming what is
    missing, no recovery action pointing back at the catalogue, and no reference to the path just
    recommended. The slot is not empty; it has been **given to a cross-sell**.

11. **Nothing follows it.** Scrolling *My Learning* to the end reaches the site-wide marketing
    footer — Company / Collections / Platform / Roles / Resources, *Copyright © 2025 CodeSignal*.
    *Evidence: `screenshots/11-my-learning-footer-nothing-below.png`.*
    *Observed:* the app promotion is the entire authenticated content of the surface.

---

## Where friction and delight sit

**Delight.** The intake asks permission before spending effort (screen 2) and states what the
questions are for. Each answer is acknowledged in the learner's own terms before the next
question, and the exchange resolves to a **named unit with a course and practice count** rather
than a category — the specific-enough-to-route-on condition this study's other platforms split
along. Offering chips and a free-text field for the same question supports recognition without
capping the answer space.

**Friction.** Three things, in ascending order of cost:

- The level question is **asked after** its answer has been assumed, and answering it **changes**
  the recommendation. Two equally weighted **Start path** buttons remain in the transcript.
- The home **discards the intake result**. The recommended path appears on no home surface, and
  the home instead offers to run the same conversation again.
- **`My Learning` at zero state is an app advertisement**, and the Trending rail serves
  Intermediate and Advanced content to a self-declared Beginner. A learner who leaves the
  conversation and lands on the home has no route back to their own recommendation except
  redoing the intake.

**Dead end.** Between the conversation and the home there is no continuity: the transcript is
the only place the recommendation exists, and no home surface links to it. *Not observed:*
whether the recommendation persists in the transcript across sessions.
