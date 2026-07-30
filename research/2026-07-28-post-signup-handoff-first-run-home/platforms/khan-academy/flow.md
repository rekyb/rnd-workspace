# Flow — Khan Academy (web)

**Source:** Claude-in-Chrome, first-party capture, accessed **2026-07-29**. Trigger **C2** —
Khan Academy has no Mobbin web coverage, verified by three dedicated named searches on
2026-07-28, all logged in `sources.md`.

**Evidence rule applied throughout:** these screens were operated first-party, so statements
about what the *system* did are **observed**. Anything not seen is labelled **not observed**.

---

## Capture conditions (read before citing any screen)

1. **This is a genuine learner account at genuine first run — the closest the study gets.**
   The 2026-07-28 attempt was abandoned because the only available account was a **teacher**
   account, whose learner side would have been contaminated evidence; nothing was saved then.
   The user has since created a **student** account, and this capture uses it. The account was
   new enough that its **email verification was still pending** — a persistent banner reads
   *"Check your email to finish signing up for …"* (blurred in every capture). Streak 0,
   Level 1, `0 /1 skill`, 0 badges, no username chosen.

2. **Account creation was not observed.** The user created the account. So, as with CodeSignal,
   **Q1's narrow question — what screen stands between the signup submit and the home — is not
   answered.** What *is* observed is the first authenticated state, which turns out to be
   heavily instrumented, and that is reported below on its own terms.

3. **The intake answers are mine.** I chose **Grade 9 / Year 9**, then **Pre-algebra**,
   **Algebra 1**, and **High school geometry**. The *number* I chose (three) matters to the Q4
   reading and is called out where it does.

4. **Viewport** 1280×495–551 CSS px, `devicePixelRatio` 1.5, screenshots 1568px wide (~1.225×).
   No CSS was injected on this platform — Khan Academy rendered its own layout at this viewport
   without clipping, so every screen here is **native**.

**Redaction.** The account-holder display name was derived **structurally** — the string
appearing in both the header account control and the profile heading — then blurred wherever it
occurs; the email-verification banner was matched by email regex; the avatar by image source.
Re-applied via `MutationObserver` on every re-render. All 10 committed PNGs were inspected, plus
a 2× zoom on the banner and profile strip: the banner renders as a blank gradient and the name as
an illegible smear. A DOM sweep for any unredacted element containing the name or an email
returned **zero** matches before capture.

**No payment.** Khan Academy is a nonprofit; the top nav carries **Donate**, not an upgrade
control. Nothing was donated or transacted.

**`flow.gif` here is a slideshow, not a screen recording.** The recorder captures clicks issued
through the pointer tool, and this flow was driven with programmatic clicks for reliability, so
it captured a single frame. Since the grade and course modals are consumed once answered, the
flow cannot be re-walked on this account. `flow.gif` is therefore assembled from the ten
committed stills in order, 1.6s per frame. It shows exactly what the stills show and adds no
motion evidence.

---

## Summary

**Entry point:** the first authenticated view of a newly created learner account.
**Goal:** reach the first learning action.

Khan Academy stacks **two first-run interventions**: a dismissible **4-step feature tour**
layered over a **blocking 2-step personalization modal**. Once the modal is answered, the home is
**constituted by the intake** — the courses chosen *are* the page — with every progress counter
rendered at zero beside a countable condition.

---

## The cited screens

1. **The first authenticated view is a tour on top of a blocker.** A modal titled **"Reach new
   Levels!"** — *"Boost your learning by reaching **Proficient or higher** in as many skills as
   possible. Our new banner tracks your progress for all skills on our site!"* — with a progress
   illustration, **Step 1 of 4**, and **Next**. Behind it sits a second, larger dialog
   (*Personalize Khan Academy*) whose CTA reads **"Choose a grade to continue"**, and behind that
   the home, showing *"Start leveling up and building your weekly streak!"* and `0 /1 skill`.
   *Evidence: `screenshots/01-first-run-tour-step1-levels.png`.*
   *Observed:* two modals are open simultaneously; the tour must be walked or dismissed before
   the blocking modal can be answered.

2. **Step 2 states the streak condition in words.** **"Build weekly streaks!"** — *"Maintain your
   streak by achieving **Proficient or higher** in at least one skill each week to keep your
   streak going!"* **Step 2 of 4**, now with **Previous** and **Next**.
   *Evidence: `screenshots/02-first-run-tour-step2-streak-condition.png`.*
   *Observed:* the condition that would move the streak off zero is stated **here, in a
   dismissible tour** — not on the streak counter itself.

3. **Step 3 explains a control that has nothing to point at yet.** **"Jump back in faster than
   ever!"** — *"Click the button to go directly to your **next suggested skill** on your
   personalized Khan Academy journey."* **Step 3 of 4**.
   *Evidence: `screenshots/03-first-run-tour-step3-jump-back-in.png`.*
   *Observed:* the learner has no history and, at this moment, no courses — the control being
   explained cannot yet do anything.

4. **Step 4 closes the tour.** **"Review progress in recent courses!"** — *"Click the **triangle
   icon** to see your progress in recent courses and navigate between them."*, a **Learn more
   about streaks and leveling up** external link, **Step 4 of 4**, and **Close**.
   *Evidence: `screenshots/04-first-run-tour-step4-recent-courses.png`.*
   *Observed:* all four steps teach the reward and progress system. None mentions choosing or
   starting a course.

5. **The blocking modal: grade first, purpose stated.** **"Personalize Khan Academy"** over a
   banner reading **"What grade are you in?"** / *"We'll gather the right lessons for you"*.
   Three columns — **Primary / Elementary**, **Secondary / High school**, **University / Adult
   learner** — as a scrollable radio list. Footer: **Step 1 of 2**, a two-dot indicator, and a
   **disabled** CTA labelled **"Choose a grade to continue"**.
   *Evidence: `screenshots/05-grade-modal-blocking-cta-disabled.png`.*
   *Observed:* the modal cannot be dismissed to reach the home; the disabled CTA **states the
   requirement in its own label** rather than waiting to raise an error.

6. **Selecting a grade rewrites the CTA.** With **Grade 9 / Year 9** chosen, the CTA becomes an
   enabled **Continue**.
   *Evidence: `screenshots/06-grade-selected-cta-enabled.png`.*
   *Observed:* label change is the only feedback; no error was ever shown, because the disabled
   state prevented the failure instead of reporting it.

7. **Step 2 asks for courses, and its guidance contradicts its constraint.** Banner: **"What
   courses can we help you learn?"** / *"Choose 4–5 and we'll gather the right lessons for you."*
   Below, a **Math** section with a checkbox grid (Pre-algebra, Algebra 1, High school geometry,
   Algebra 2, Trigonometry, Precalculus, …) and a **See all (43)** link. Footer: **Back**,
   **Step 2 of 2**, and a disabled **"Choose 1 course to continue"**.
   *Evidence: `screenshots/07-course-modal-choose-4-5-guidance.png`.*
   *Observed:* the instruction asks for **4–5**; the actual gate is **1**. The two numbers
   disagree on the same screen.

8. **The CTA carries a live count.** With three boxes ticked the CTA reads **"Continue with 3
   courses"**.
   *Evidence: `screenshots/08-course-modal-continue-with-3-courses.png`.*
   *Observed:* the same control does three jobs across the flow — states the requirement while
   blocked, confirms readiness, then reports the selection count.

9. **The home is the intake, rendered.** Top strip: *"Start leveling up and building your weekly
   streak!"*, a flame at **0 week streak**, a triangle control, **Level 1** with an info glyph, a
   progress bar, and **0 /1 skill**. Profile strip: blurred avatar and name, *"Pick a username -
   Add your bio"*, **Edit Profile**, and a badge row reading **0** six times over. Main column:
   **My courses** with **Edit Courses**, then **Algebra 1** (*See all (17)*) and **High school
   geometry** (*See all (9)*) side by side — each a vertical unit list whose **first** unit
   carries a filled **Start** button.
   *Evidence: `screenshots/09-learner-home-after-intake.png`.*
   *Observed:* the three courses chosen in the modal are the page's primary content. Nothing is
   fabricated — every counter reads zero — and nothing that exists is hidden.

10. **Third course, and a way to add more.** Scrolling reveals **Pre-algebra** (*See all (15)*)
    with its own first-unit **Start**, and beside it a dashed tile with a **+** glyph labelled
    **"Add another course"**.
    *Evidence: `screenshots/10-learner-home-third-course-add-another.png`.*
    *Observed:* **three courses produce three co-equal Start buttons** — one per course, none
    ranked above the others.

---

## Where friction and delight sit

**Delight.** The zero state is honest and legible: `0 week streak`, `Level 1`, **`0 /1 skill`**,
`0 badges total`. The `0 /1 skill` form is the countable unlock condition in its purest version
in this study — it names the denominator, so "one skill" is the whole ask. The intake **states
its purpose** on the banner it appears in (*"We'll gather the right lessons for you"*) and then
**visibly keeps that promise**: the courses chosen are the courses on the home. The CTA that
doubles as the requirement (*"Choose a grade to continue"*) prevents the error instead of
reporting it, and **Add another course** leaves the selection open rather than final.

**Friction.** Four, in ascending order of cost:

- **The tour runs before the blocker it sits on top of.** Two modals are open at once, and the
  learner must clear the outer one to answer the inner one.
- **The tour teaches rewards, not the task.** All four steps describe levels, streaks, the
  jump-back control, and recent-course progress — for an account with no courses. Step 3 explains
  a control that has nothing to point at.
- **"Choose 4–5" versus "Choose 1 course to continue."** The guidance and the gate disagree in
  the same footer.
- **The streak condition is stated only in the dismissible tour.** Once the tour is closed,
  `0 week streak` sits on the home with no on-surface statement of what would change it — unlike
  `0 /1 skill`, which carries its denominator with it.

**Dead end.** None reached. Every course exposes a first-unit **Start**, and the catalogue stays
reachable through **Add another course** and **Edit Courses**.

**Not observed.** The signup-to-home transition (the account pre-existed); anything behind the
**Teachers** sidebar item, which is where a class-code cohort would live — reaching it needs a
real teacher-issued code, which per `PLAN.md` this study deliberately does not pursue.
