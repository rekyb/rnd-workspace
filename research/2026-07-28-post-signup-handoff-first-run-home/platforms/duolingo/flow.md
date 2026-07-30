# Flow — Duolingo (web)

**Source:** Mobbin, accessed 2026-07-28. One observed variant of a library snapshot, not a
claim about Duolingo's current live behaviour.

**Evidence rule applied throughout:** these are stills. Every statement about what the
*system* did in response to an action is marked **inferred from screen sequence**. Nothing
here was observed first-party.

---

## Flow A — Creating a profile

**Summary:** an already-learning, unregistered user hits a deferred registration wall, gives
their age, then email and password, and lands on the learning-path home.

**Entry point:** mid-session, after the learner has already done some learning without an
account. **Goal:** convert an anonymous session into a saved account.

1. **The wall appears.** The learner sees a full-screen interstitial: an illustration, the
   heading *"Time to create a profile!"*, and the line *"Create a profile to save your
   progress and continue learning for free."* Two stacked buttons: a filled **CREATE A
   PROFILE** and an outlined **LATER**.
   *Evidence: `reference/01-deferred-profile-wall.webp`.*
   Registration is presented as **optional and deferrable** — "LATER" is a real, equally
   reachable exit, not a dimmed afterthought. The value proposition offered is *saving what
   you already have*, not gaining access.

2. **Age is asked first — before name or email.** The next screen asks *"How old are you?"*
   above a single field, with the rationale inline beneath it: *"Providing your age ensures
   you get the right Duolingo experience. For more details, please visit our Privacy
   Policy."* **NEXT** is disabled while the field is empty and enables once a value is
   entered. Google and Facebook alternatives sit below an "OR" divider, with the terms and
   privacy line and a reCAPTCHA notice under those.
   *Evidence: `reference/02-age-gate.webp`.*
   Note the ordering: age precedes any other personal data. See `notes.md` — this bears
   directly on an open decision in our own PRD.

3. **The account form.** *"Create your profile"* over three fields: **Name (optional)**,
   **Email**, **Password**. A filled **CREATE ACCOUNT** button, then the same Google and
   Facebook options. A back arrow sits top-left and a **LOGIN** affordance top-right.
   *Evidence: `reference/03-create-profile-form.webp`.*
   Name is explicitly marked optional. Only email and password are load-bearing.

4. **Submission shows a busy state.** On submit, the CREATE ACCOUNT button's label is
   replaced by an animated three-dot indicator; the fields become non-editable in
   appearance. *Inferred from screen sequence:* the account request is in flight and the
   control is blocking a second submission.
   *Evidence: `reference/04-create-account-submitting.webp`.*

5. **The learner arrives at the learning-path home.** Left rail: LEARN, LETTERS, PRACTICE,
   LEADERBOARDS, QUESTS, SHOP, PROFILE, MORE. Centre: a unit banner reading *SECTION 2,
   UNIT 1 — "Ask for directions"* with a **GUIDEBOOK** button, below it a vertical node path
   whose first node carries a **START** flag and whose following nodes are greyed and
   locked. Right rail, top to bottom: a stat strip (streak, gems, hearts), a *"Try Super for
   free"* promotion, an *"Unlock Leaderboards! Complete 9 more lessons to start competing"*
   panel with a padlock icon, a *"Daily Quests — Earn 20 XP"* panel with a `0 / 20` progress
   bar, and an ad-blocker notice.
   *Evidence: `reference/05-home-progressed-not-zero-state.webp`.*

   **⚠ This terminal screen is not a first-run home.** The stat strip shows a 10-day streak,
   505 gems, and 5 hearts, and the learner is in **Section 2**. Whatever this flow's framing,
   the home it ends on belongs to an account with history. It is evidence about home
   *composition*; it is **not** evidence about the zero state. See `notes.md`, Limitation 1.

**Where friction and delight sit:** the wall's "LATER" is a genuine escape and the "save your
progress" framing earns the ask. The age-first ordering front-loads the one question with a
legal consequence. The home is dense — three promotional or gamified panels compete with the
single START affordance.

---

## Flow B — Joining a classroom

**Summary:** a registered learner enters a teacher-issued six-letter code from account
settings, corrects an invalid attempt, and confirms joining a named class.

**Entry point:** **Settings → "Duolingo for Schools"** — reached from the account area, *not*
from onboarding and *not* from the home. The right-hand settings menu (Account, Manage
Courses, Password, Super Duolingo, Notifications, Edit Daily Goal, **Duolingo for Schools**,
Privacy) is visible throughout, with the current item highlighted. **Goal:** attach an
existing account to a teacher's classroom.

1. **The code screen.** Heading *"Duolingo for Schools"*, section *"Join a classroom"*, and
   the instruction *"Enter the 6-letter code you received from your teacher. Once you join,
   they'll be able to follow your progress, control your account, and give you assignments on
   Duolingo."* A single text field shows the placeholder `ABC123`. **SUBMIT** is rendered
   grey and inactive. A greyed **SAVE CHANGES** button sits top-right, part of the settings
   chrome rather than this task.
   *Evidence: `reference/06-classroom-code-empty.webp`.*
   The consequences of joining are stated **before** the code is entered, not after.

2. **Typing enables submit.** With six characters present, SUBMIT turns solid blue.
   *Inferred from screen sequence:* the control is gated on input length. (Intermediate
   state; see `references.md` "Not downloaded".)

3. **An invalid code is rejected in place.** After submitting an unrecognised code, the
   field gains a red border and the message *"This code does not match any classroom."*
   appears directly beneath it with an error icon. **The entered code remains in the
   field** and SUBMIT stays active. *Inferred from screen sequence:* the code was checked
   server-side and rejected as unrecognised. The screens do not distinguish invalid from
   expired, revoked, or full — only this single message is observable.
   *Evidence: `reference/07-classroom-code-error.webp`.*

4. **A valid code produces a confirmation modal, not an immediate join.** With a different
   six-character code entered, a centred modal appears over a dimmed page: *"Join
   [Teacher]'s Japanese 3 classroom?"* with the body *"[Teacher] will be able to follow your
   progress, control your account, and give you assignments on Duolingo."* Two buttons:
   filled **YES, JOIN** and outlined **NO, DON'T JOIN**.
   *Evidence: `reference/08-classroom-join-confirm.webp`.*
   The teacher's name and the class name are both echoed back, so the learner confirms
   against a resolved identity rather than a code string. The permission sentence is
   repeated verbatim at the point of commitment. The decline option is worded as a full
   sentence, not a bare "Cancel".

**⚠ The flow ends here.** No screen in this flow shows the home *after* joining. Whether
class identity, teacher, or assignments become visible on the learning home is **not
answerable from this capture**. See `notes.md`, Limitation 2.
