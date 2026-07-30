# Flow — Uxcel (web)

**Source:** Mobbin, accessed 2026-07-28. One observed variant of a library snapshot, not a
claim about Uxcel's current live behaviour.

**Evidence rule applied throughout:** these are stills. Any statement about what the
*system* did is marked **inferred from screen sequence**. Nothing was observed first-party.

**This is not a journey.** Unlike the Duolingo capture, this flow is a set of views of one
screen — the authenticated home — in **two account states**. It is read as a comparison, not
as a sequence, so what follows is organised by state rather than numbered by step.

---

## The two states

Identified by the top-bar counters and the streak panel, which are unambiguous:

| | **Zero state** | **Populated state** |
|---|---|---|
| Top-bar counters | `⚡ 0` and `0` | `⚡ 1` and `2k` |
| Streak panel | "0 day streak" | "1 day streak" |
| Evidence | `reference/01`, `reference/02` | `reference/03`, `reference/04`, `reference/05` |

The populated state represents roughly one day of use — one course begun, 6% complete. It is
the *nearest* step beyond zero, which is what makes the pair useful: the delta is small
enough to isolate what a single action changes.

---

## The home at zero state

**Layout.** A persistent left nav (Home, Bookmarks, Leagues, then LEARN: Courses, Career
Paths, Briefs, Assessments, Tutorials, Arcade, then GROW: Showcase, Certifications, Salary
Explorer, Job Board). A wide main column and a narrower right rail. Top bar carries search,
an Upgrade button, two zero-value counters, an "Earn $50" referral, notifications, avatar.

**Main column, top — "Continue learning".** A dashed-outline placeholder card with a `+`
glyph sits where a course thumbnail would go. Beside it: the label `COURSE`, the heading
**"You don't have any active courses"**, the line *"Select a course and start improving your
skills."*, and a filled **Browse courses** button. Beneath, a small face pile and *"3555
learning this week"*.
*Evidence: `reference/01-home-zero-state-top.webp`.*

The slot is **present and clearly empty** — not hidden, not faked. The placeholder preserves
the layout the populated card will occupy.

**Right rail — "Getting started".** A three-row checklist under the framing *"Unlock your
Aha! moment by working through these quick, rewarding steps:"*. All three rows carry an
empty circle: **Start your first course**, **Complete a lesson quiz**, **Take Uxcel Pulse
test**.
*Evidence: `reference/01-home-zero-state-top.webp`.*

**Right rail — streak.** *"0 day streak"* with a greyed lightning glyph, the line *"Earn 100
PX to start a new streak"*, and seven day-dots (T W T F S S M) all empty.
*Evidence: `reference/01-home-zero-state-top.webp`.*

**Right rail, scrolled — league.** *"Quartz league / 6 days left to join"* over a **padlock**
icon and the line *"Earn pixels to join this week's league"*. No table, no ranks.
*Evidence: `reference/02-home-zero-state-scrolled.webp`.*

**Right rail, scrolled — skill graph.** A greyed hexagon over *"Discover your strengths and
unlock your personalized learning path"* and a **Get started** link. No score.
*Evidence: `reference/02-home-zero-state-scrolled.webp`.*

**Main column, scrolled — "Recommended for you".** **Populated at zero state**: two course
cards, each with title, author, description, difficulty, duration, and a star rating with
review count.
*Evidence: `reference/02-home-zero-state-scrolled.webp`.*

**Main column — "Bulletin board 2".** Two dismissible cards, also populated at zero state: a
career-quiz card (*"NOT SURE WHERE TO START?"*, 20m, 25 questions, **Take our quiz**) and a
certifications card. Each carries a **Mark as read** action.
*Evidence: `reference/01-home-zero-state-top.webp`.*

---

## The home after one day

Same page, same slots, same positions. What changed:

- **Continue learning** now holds a real course card: title, *"Current Lesson: The Anatomy
  of UI Components"*, a **6%** progress bar, **"7h left"**, and a **Resume course** button in
  place of Browse courses. *Evidence: `reference/03-home-populated-top.webp`.*
- **Getting started** — the first two rows now show green checks and are greyed out; the
  third remains open. The panel persists rather than disappearing on partial completion.
  *Evidence: `reference/03-home-populated-top.webp`.*
- **Streak** reads *"1 day streak"* with a lit lightning glyph and one day-dot checked.
  *Evidence: `reference/03-home-populated-top.webp`.*
- **League** loses the padlock and becomes *"Quartz league / Top 20 advance • 4 days left"*,
  then a ranked table of learners with PX totals and the viewer's own row highlighted.
  *Evidence: `reference/04-home-populated-rail.webp`, `reference/05-home-populated-scrolled.webp`.*
- **Skill graph** resolves to a scored dial (**58**), a *"40% reliability"* qualifier, and six
  labelled skill bars. *Evidence: `reference/05-home-populated-scrolled.webp`.*
- **Recommended for you** stays populated, with different courses.
  *Evidence: `reference/05-home-populated-scrolled.webp`.*

*Inferred from screen sequence:* starting one course and completing one quiz is what moved
the first two checklist rows, the streak, and the league eligibility. The screens show the
before and after, not the transition.

---

## Where friction and delight sit

**Delight.** Nothing is hidden and nothing is invented. Every progress-dependent slot holds
its place and states, in plain language, the condition that would fill it. The checklist
names the payoff explicitly — *"Unlock your Aha! moment"*.

**Friction.** At zero state the home offers **no single next action**. Browse courses, a
3-step checklist, a 25-question career quiz, and two recommended courses all compete, none
visually dominant. A learner who has just committed is handed a menu. See `notes.md`,
Observation 4 — this is the study's clearest counter-case to the single-next-step pattern.
