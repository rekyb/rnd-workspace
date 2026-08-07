# References — Brilliant (Mobbin-sourced)

Two web flows. Mobbin's flow search returns a flow-level `mobbin_url` plus per-screen UUIDs
rather than per-screen URLs, so the URL column carries the flow link and the position is
given alongside the screen ID.

Images are `.webp` because that is what the Mobbin endpoint serves.

**Flow A — "Onboarding"** (12 screens) · https://mobbin.com/flows/38a82b93-ec50-4c59-9a49-433a979ec59d
**Flow B — "Home"** (2 screens) · https://mobbin.com/flows/f7b6036f-6105-4bf8-a40a-ab1858e3e2d2

Flow B is a matched **zero-state / populated** pair of the same home. Its first screen is the
same asset as Flow A's terminal screen (`d7b78a30`), which is what confirms the zero-state
home is where onboarding lands rather than an unrelated view.

| # | Screen | Mobbin URL | Screen ID | Local file | Accessed |
|---|---|---|---|---|---|
| 01 | Landing — learner / parent-or-teacher fork (Flow A, pos 1) | https://mobbin.com/flows/38a82b93-ec50-4c59-9a49-433a979ec59d | 7556aa28-a154-40e7-9057-262d5e266cdb | reference/01-landing-learner-fork.webp | 2026-07-28 |
| 02 | **Handoff interstitial** — spinner labelled "Loading your learning path recommendations" (Flow A, pos 6) | https://mobbin.com/flows/38a82b93-ec50-4c59-9a49-433a979ec59d | 7d7b831c-bb7f-4337-a625-3483e4bb0216 | reference/02-handoff-loading-labelled.webp | 2026-07-28 |
| 03 | Recommendation picker — four paths, one marked TOP PICK and pre-selected (Flow A, pos 7) | https://mobbin.com/flows/38a82b93-ec50-4c59-9a49-433a979ec59d | da4c4452-1b86-42b7-bab4-de610a9872ca | reference/03-recommendation-picker-top-pick.webp | 2026-07-28 |
| 04 | Mechanic explainer — "You'll use keys to unlock lessons" (Flow A, pos 9) | https://mobbin.com/flows/38a82b93-ec50-4c59-9a49-433a979ec59d | 3e76355e-b6e2-41c0-a690-7cdc8ac147b7 | reference/04-keys-mechanic-explainer.webp | 2026-07-28 |
| 05 | **Home, zero state** — 0 streak, locked leagues, one recommended card (Flow A pos 12 = Flow B pos 1) | https://mobbin.com/flows/f7b6036f-6105-4bf8-a40a-ab1858e3e2d2 | d7b78a30-c1b5-4024-9fc3-e84228de7244 | reference/05-home-zero-state.webp | 2026-07-28 |
| 06 | **Home, populated** — 1-day streak, live league table (Flow B, pos 2) | https://mobbin.com/flows/f7b6036f-6105-4bf8-a40a-ab1858e3e2d2 | 69ca0993-5784-44b6-b0c2-de41614a91fb | reference/06-home-populated.webp | 2026-07-28 |
| 07 | Course path — first lesson active, later lessons greyed and locked (Flow A, pos 11) | https://mobbin.com/flows/38a82b93-ec50-4c59-9a49-433a979ec59d | 45ede6ec-1ebd-498f-9a48-2636087f1be4 | reference/07-course-path-locked-lessons.webp | 2026-07-28 |

## Not downloaded

Flow A positions 2–5 (sign-in modal and two value-proposition screens), 8 (path map), and 10
(lesson interior). Positions 2–5 sit *before* account creation and are out of this study's
scope; position 10 is lesson interior, explicitly out of scope. Position 8 was viewed during
scouting but is not cited, so it is not downloaded — no file without a row, no row without a
citation.

This platform used 7 of its 8-screen ceiling.

## Third-party content

The populated home's league table shows other learners' display names and XP. Committed prose
describes the mechanic generically and reproduces no individual name.
