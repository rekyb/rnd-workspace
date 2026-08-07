# Flow — Babbel home (web and iOS)

**Summary:** the learner arrives on `Home`, greeted by name, with a two-tab switch between
*Today* (one recommended lesson) and *Learning plan* (the full unit list). Three destinations
exist on both platforms and they are **the same three**. Only the layout changes.

Layout study, so this is the scroll-and-navigate path, not a task walkthrough. System-response
claims are **inferred from screen sequence** — these are library stills.

---

## Web

**1. Arrival — three destinations, named and labelled.**
A top bar holds the wordmark and exactly three nav items: `Home`, `Review` (carrying a dot
badge), `Explore`. `Home` is underlined as the active state. A right-hand cluster holds a
streak chip, a language selector, and a profile menu. There is no sidebar.
*Evidence: reference 01, 02.*

**2. The page opens with the learner's name.**
`Hi, Alex Smith` as the page heading. Under it, a two-tab segmented control: `Today` /
`Learning plan`, with `Today` active.
*Evidence: reference 01, 02. Localised variant confirms the same structure: reference 03 shows
`Great to see you, Alex Smith`.*

**3. A single small banner offers the secondary action.**
`Daily vocab workout — Time for a quick review`, a low-height full-width strip with an
illustration. It sits above the lesson content and is visually quieter than what follows.
*Evidence: reference 01, 02.*

**4. The primary action is a card in a horizontal carousel.**
A label states position in the course (`Newcomer II (A1.2) - Unit 1`) and the unit name
(`Talk about relationships`). Below it, large lesson cards scroll horizontally, each a lesson
number, a title, and a photograph. Only the focused card carries a `Start lesson` button;
neighbours show title only. Pagination dots and prev/next arrows sit beneath.
*Evidence: reference 01 (Lesson 2 focused), 02 (carousel advanced, Lesson 3 focused).*

**5. Scrolling reveals three more blocks, then the footer.**
In order: `Courses` (with `See all`), then `Learn with others` (a referral/reward card), then
a site footer (`The Babbel Method`, `Babbel app`, `Help / FAQ`, `Babbel as a Gift`).
*Evidence: reference 04.*

**6. `Learning plan` swaps the centre and adds a right rail.**
The tab replaces the carousel with a vertical lesson list — Lesson 1 to 4 plus a `Recap`, each
row carrying a title, bullet objectives, and its own `Start lesson` button. A right rail
appears holding a level card (`A1 · Newcomer II (A1.2)`, `0/61 lessons completed`), a
description, and two buttons (`Explore more courses`, `Find your level`).
*Inferred from screen sequence — reference 01 → 03.* **Note: the rail is present on
`Learning plan` and absent on `Today`.** The rail is not a persistent shell.

**7. `Explore` is a different page, not a home block.**
A level heading (`Intermediate (B1)`), a `Choose your level` control, two counters
(`0 lessons`, `0% of level`), and an expandable unit list with per-lesson `Start now` buttons.
*Evidence: reference 05.*

---

## iOS

**8. Arrival — the same three destinations, as a bottom tab bar.**
`Home`, `Review`, `Explore` — three tabs, each an **icon plus a text label**. `Home` is active.
*Evidence: reference 06, 07, 08.*

**9. The same greeting and the same two-tab switch.**
`Hi, Jane Doe` as the heading, a streak chip and profile icon to its right, then the
`Today` / `Learning plan` segmented control. Identical structure to web.
*Evidence: reference 06, 07.*

**10. Where web shows a vocab banner, iOS shows an activity tracker.**
A full-width bar labelled `Activity tracker` with a flag icon and a fraction. Reference 06
shows `0/7` with an empty bar; reference 07 shows `10/7` with a filled bar. A third variant
replaces it with a prompt: `Set your weekly goal!`
*Evidence: reference 06, 07.*

**11. The primary action is one large card, not a carousel.**
Course position (`Newcomer (A1) - Course 1`), then a single tall card with lesson number, title,
photograph, and a `Start lesson` button. Reference 07 shows the same slot occupied by a review
prompt instead (`Time to review` / `Review now`), so the slot is **conditional on state**.
*Evidence: reference 06, 07.*

**12. Scrolling reveals a horizontal row of further lessons.**
Below the large card, smaller cards sit in a horizontal row (`Dag, Marie! Part 2`,
`Dag, Marie! Review`, a third clipped). The tab bar remains fixed.
*Evidence: reference 08.*

**13. Progress detail is a sheet, not a page.**
The profile control opens a `Weekly summary` sheet: an `Activity` block with per-weekday
counts, a `Weekly goal` row with a progress bar and an edit control, a `Continue learning`
button, then a `Reviews` block (`Average score 82%`, `New items 24`, a review-method bar).
*Evidence: reference 09.*

---

## Where the two diverge

| | Web | iOS |
|---|---|---|
| Destinations | 3, top bar, icon-free text | **3, bottom tabs, icon plus label** |
| Nav labels | `Home` / `Review` / `Explore` | **identical three** |
| Sub-switch | `Today` / `Learning plan` tabs | **identical** |
| Primary action | Card in a horizontal carousel | One large card, full width |
| Daily-goal signal | Not on `Today`; lives in the `Learning plan` rail | `Activity tracker` bar, in the content flow |
| Progress detail | Right rail, only on `Learning plan` | Profile **sheet** |
| Further lessons | Carousel neighbours | Horizontal row below |

**Not observed:** whether the web build reflows to narrow width (Mobbin publishes no narrow
web capture), any transition or timing, and what the `Review` badge count reflects.
