# Flow — Duolingo home (web and iOS)

**Summary:** the authenticated learner arrives on `Learn`, which *is* the lesson path. On web
the path sits in a centre column between a persistent left nav and a persistent right rail; on
iOS the same path fills the full width with a stats strip above and a tab bar below. On both,
the next action is a node on the path rather than a button in a header.

This is a **layout study**, so the flow below is the scroll-and-navigate path through the home
rather than a task walkthrough. Every system-response claim is **inferred from screen
sequence**, not observed — these are library stills, not a live session.

---

## Web

**1. Arrival — `Learn` is the default destination.**
The page renders in three persistent columns. Left: a vertical nav, 8 items, each an icon plus
a text label — `LEARN`, `LETTERS`, `PRACTICE`, `LEADERBOARDS`, `QUESTS`, `SHOP`, `PROFILE`,
`MORE`. `LEARN` carries the active state as a filled pill with a coloured border; the other
seven are plain. Centre: the lesson path. Right: a stats row and two cards.
*Evidence: reference 01, 03.*

**2. The centre column opens with a unit banner, not a greeting.**
A coloured banner states `SECTION 2, UNIT 1` and the unit name ("Ask for directions"), with a
`GUIDEBOOK` control on its right edge. There is no name, no welcome line, and no readiness
summary. The first thing the learner reads is *where they are in the material*.
*Evidence: reference 01.*

**3. The path below the banner carries the next action as a node.**
A vertical sequence of circular nodes runs down the column, the first marked `START` and
visually raised (larger, coloured, with a pointer label) while later nodes are grey. A
character illustration sits beside the path. There is no separate "start lesson" button
anywhere on the screen — the ranked action *is* the raised node.
*Evidence: reference 01, 03.*

**4. Scrolling the centre column reveals the next unit divider.**
Further down, a horizontal rule labelled "Talk about your hometown" separates units, followed
by a `JUMP HERE?` control. The column is a continuous path rather than a set of blocks.
*Evidence: reference 01 (lower edge), 03 (lower edge).*

**5. The right rail carries progress and competition, and never scrolls out of the crop.**
Top: a horizontal stats strip — language flag, streak count, gem count, and an energy/infinity
symbol. Below it, a `Silver League` card with the learner's rank and a `VIEW LEAGUE` link. Below
that, a `Daily Quests` card with three quests, each a label plus a progress bar plus a chest
icon, and a `VIEW ALL` link. Site footer links (`ABOUT`, `BLOG`, `STORE`, `EFFICACY`, `CAREERS`,
`INVESTORS`, `TERMS`, `PRIVACY`) sit at the rail's foot.
*Evidence: reference 01, 02, 03.*

**6. `PRACTICE` swaps the centre column and leaves both nav and rail intact.**
The centre becomes "Today's Review": a large `Unit Rewind` card with a `START +20 XP` button,
then a "Your collections" group holding `Mistakes` and `Words` cards, each with a count badge.
The left nav's active pill moves to `PRACTICE`. The right rail is unchanged.
*Inferred from screen sequence — reference 01 → 02.*

**7. Progress detail lives on a separate destination, not the home.**
`Statistics` presents four stat tiles (`937 Day streak`, `200994 Total XP`, `Pearl Current
league`, `24 Top 3 finishes`), an "XP this week" line chart comparing the learner against
another user, and an `Achievements` grid of levelled badges. None of this is on `Learn`.
*Evidence: reference 04.*

---

## iOS

**8. Arrival — the same path, full width.**
No sidebar and no rail. A stats strip runs across the top (flag with count, streak, gems, and an
energy symbol), the unit banner sits below it, and the path fills the rest.
*Evidence: reference 05, 06.*

**9. The tab bar carries six destinations, icon-only, with an overflow.**
A fixed bottom bar holds six circular icons and **no text labels**. The last is a `…` overflow.
The first carries the active state as a filled/raised treatment.
*Evidence: reference 05, 06, 07.*

**10. The active lesson is promoted from a node to a card.**
Where web raises the next node with a `START` pointer, iOS renders a full-width card over the
path — a title, `Lesson 4 of 6`, and a `START +25 XP` button. Reference 05 shows the same device
for a video-call lesson (`Video Call: Lily`, `REVIEW +20 XP`).
*Evidence: reference 05, 06.*

**11. Scrolling reveals locked nodes and no further blocks.**
The scrolled position shows greyed nodes continuing down the path with a character illustration
alongside. No secondary section, no rail content, no promotional block appears within the
captured range. The iOS home is **one block, scrolled** — not a stack of blocks.
*Evidence: reference 07.*

---

## Where the two diverge

| | Web | iOS |
|---|---|---|
| Nav | Left sidebar, 8 items, icon **plus label**, ends in `MORE` | Bottom bar, 6 items, **icon only**, ends in `…` |
| Progress | Persistent right rail, always visible | Top strip only; league and quests not on the home |
| Next action | Raised node on the path | Full-width card over the path |
| Home composition | Three columns, path plus two rail cards | One column, path only |

**Not observed, and not inferable:** whether the two are the same build reflowing (they are
not — these are separate native and web products), any timing or transition, and what sits
behind `MORE` or `…` on either platform. Overflow depth is **undetermined** on both, per the
plan's Q1 counting rule.
