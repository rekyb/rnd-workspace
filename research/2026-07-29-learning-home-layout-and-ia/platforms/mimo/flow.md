# Flow — Mimo home (iOS)

**Summary:** the home is **split across two tabs**. `Learn` is a path and nothing else;
`Practice` is a stack of blocks that behaves like a dashboard. Five tabs, each icon plus label.

Layout study. System-response claims **inferred from screen sequence**.

**1. Arrival — `Learn`, and it is the path.**
Two counter chips run across the top (a coin count, `240`; a droplet count, `2`), then a
full-width path selector row with a list glyph and the path name (`Full-Stack Developer`).
Below it a pill states the current unit (`Intro to Web Development`) with a circular progress
ring reading `58%`. The rest of the screen is a node path on a dotted background: completed
nodes filled and check-marked, the current node highlighted, later nodes greyed.
*Evidence: reference 01.*

**2. At zero, the same structure renders with the ring at 0% and nodes locked.**
The ring reads `0%` or `1/2`; the first node carries a play glyph or a fraction, and subsequent
nodes show padlocks. Layout is unchanged.
*Evidence: reference 02.* **Cited for block order and node treatment only.**

**3. The bottom bar carries five destinations, each labelled.**
`Learn`, `Practice`, `Build`, `Leaderboard`, `Profile` — icon above a text label. The active tab
is marked by a filled icon and darker label; `Leaderboard` carries a red dot badge in one
capture. **No overflow control.**
*Evidence: reference 01, 02, 03, 04.*

**4. `Practice` replaces the path with a stack of four blocks.**
Top: a `DAILY REVIEW` card on a tinted panel — a title (`Structuring Text with Tags`), a
duration (`⚡ 10 min`), an illustration, and a wide `Start now` button.
*Evidence: reference 03.*

**5. Then a horizontal row of past topics.**
`Practice Past Topics` with a `See all` link, then cards each carrying a duration and a title,
completed ones marked with a filled check.
*Evidence: reference 03, 04.*

**6. Then a two-cell progress block.**
`Your Practice Progress` — two tiles side by side, each a large figure over a label:
`5 / Activities done`, `32m / Time on tasks` (reference 04); `3 / Activities done`,
`20m / Time on tasks` (reference 03).
*Evidence: reference 03, 04.*

**7. Then a creation block, and the page ends.**
`Playgrounds` with a `+ Create new` link, then a card per playground carrying a language icon,
a name (`Python 1`, `Python 2`), a relative timestamp (`1 second ago`), a `PRIVATE` badge, and
an overflow `⋮`.
*Evidence: reference 03, 04.*

---

**Not observed:** `Build`, `Leaderboard`, and `Profile` contents; any web counterpart (Mimo is
captured on iOS only); timing and transitions.
