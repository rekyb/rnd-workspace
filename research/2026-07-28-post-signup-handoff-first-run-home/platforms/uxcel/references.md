# References — Uxcel (Mobbin-sourced)

One web flow. Mobbin's flow search returns a flow-level `mobbin_url` plus per-screen UUIDs
rather than per-screen URLs, so the URL column carries the flow link and the position is
given alongside the screen ID.

Images are `.webp` because that is what the Mobbin endpoint serves.

**Flow — "Home"** (7 screens) · https://mobbin.com/flows/67d21fa1-0aba-4f35-9615-35dd8102342d

The flow contains **two distinct account states** of the same home, at several scroll
positions. That pairing is the reason this platform carries Q2. State is identified by the
top-bar counters and the streak panel, not by position order.

| # | Screen | Mobbin URL | Screen ID | Local file | Accessed |
|---|---|---|---|---|---|
| 01 | **Zero state**, top — empty Continue-learning slot, Getting-started 0/3, 0-day streak (pos 1) | https://mobbin.com/flows/67d21fa1-0aba-4f35-9615-35dd8102342d | 6b262155-b270-47fe-9e79-3fc594f4cb32 | reference/01-home-zero-state-top.webp | 2026-07-28 |
| 02 | **Zero state**, scrolled — locked league, greyed skill graph, populated recommendations (pos 4) | https://mobbin.com/flows/67d21fa1-0aba-4f35-9615-35dd8102342d | 3f33c551-e655-4314-b158-06df1a460046 | reference/02-home-zero-state-scrolled.webp | 2026-07-28 |
| 03 | **Populated**, top — active course at 6%, two checklist rows completed, 1-day streak (pos 2) | https://mobbin.com/flows/67d21fa1-0aba-4f35-9615-35dd8102342d | 68933767-f763-41a5-94ed-967cadaac831 | reference/03-home-populated-top.webp | 2026-07-28 |
| 04 | **Populated**, right rail — league showing "Top 20 advance" with a live countdown (pos 3) | https://mobbin.com/flows/67d21fa1-0aba-4f35-9615-35dd8102342d | df8dc721-0de4-417d-8622-4719a72672cf | reference/04-home-populated-rail.webp | 2026-07-28 |
| 05 | **Populated**, scrolled — ranked league table with PX values, skill graph scored (pos 5) | https://mobbin.com/flows/67d21fa1-0aba-4f35-9615-35dd8102342d | 7c84c45e-ae5a-449c-be39-306cead79fa7 | reference/05-home-populated-scrolled.webp | 2026-07-28 |

## Not downloaded

Positions 6 and 7 continue the populated state into **Upcoming events** and a **Resources**
grid (mobile app, Slack, Figma/Notion templates, Discord, Reddit). Both are out of scope —
neither is progress-dependent and neither bears on any research question. Excluded
deliberately, not for budget: this platform used 5 of its 8-screen ceiling.

## Third-party content

The populated league table shows other learners' display names, and the events cards show
public speaker marketing. Committed prose in `flow.md` and `notes.md` describes these
generically and reproduces no individual name — the mechanic is the evidence, not the people
in it.
