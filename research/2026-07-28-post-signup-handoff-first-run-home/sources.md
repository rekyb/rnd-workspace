# Sources — Post-Signup Handoff to the First-Run Learning Home

Every screen, flow, and search consulted, with provenance (`mobbin` | `found` | `provided`)
and the date it was accessed. Mobbin-sourced rows are the canonical citation for committed
prose; downloaded images live in each platform's gitignored `reference/` folder and are
never committed.

Negative search results are logged too — they are the evidence that would justify a later
C2 (no Mobbin coverage) trigger, and are worthless if invisible.

## Selected flows

| Source | URL | Accessed | Notes |
|---|---|---|---|
| Mobbin — Duolingo, "Creating a profile" (web, 8 screens) | https://mobbin.com/flows/65ea5f1c-ba09-44ae-9a88-1b4f9a5778e4 | 2026-07-28 | `mobbin` · **Primary.** Deferred registration prompt → profile form → post-signup home with unit path, locked leaderboards, daily quest at 0/20. |
| Mobbin — Duolingo, "Joining a classroom" (web, 5 screens) | https://mobbin.com/flows/a5ac043e-d231-4f6e-a113-8b51e4151fb4 | 2026-07-28 | `mobbin` · **Primary, Q6.** Six-character teacher code, invalid-code error state, and a confirmation modal naming teacher and class and stating what the teacher may do. The true analogue of our program-code path. |
| Mobbin — Duolingo, "Creating a profile" variant (web, 6 screens) | https://mobbin.com/flows/eff5c764-a940-472a-a590-a6cf2a42b61c | 2026-07-28 | `mobbin` · Secondary/backup for the signup→home tail. |
| Mobbin — Uxcel, "Home" (web, 7 screens) | https://mobbin.com/flows/67d21fa1-0aba-4f35-9615-35dd8102342d | 2026-07-28 | `mobbin` · Empty home ("You don't have any active courses", "Getting started 0/4", "Start your learning streak") plus the populated contrast. |
| Mobbin — Uxcel, "Onboarding" (web, 19 screens) | https://mobbin.com/flows/ed454331-47d7-4cbd-8cf3-37e5db6d194d | 2026-07-28 | `mobbin` · Tail only, from account creation onward. |
| Mobbin — Coursera, "Onboarding" (web, 17 screens) | https://mobbin.com/flows/db5898b3-df15-4cce-9532-e9e287058ceb | 2026-07-28 | `mobbin` · Tail only. Goal → roles → education level → home banner restating the goal with an Edit goal link. |
| Mobbin — Coursera, "Home" (web, 5 screens) | https://mobbin.com/flows/53a2e3cc-7c3f-4e4d-9270-f2327d6290f5 | 2026-07-28 | `mobbin` · Shares its first screen with the onboarding tail. |
| Mobbin — Brilliant, "Onboarding" (web, 12 screens) | https://mobbin.com/flows/38a82b93-ec50-4c59-9a49-433a979ec59d | 2026-07-28 | `mobbin` · Signup → path map → home with one recommended unit, single Start, zero counters. |

## Surfaced but not selected

| Source | URL | Accessed | Notes |
|---|---|---|---|
| Mobbin — Uxcel, "Accepting an invite" (web, 7 screens) | https://mobbin.com/flows/8aab1cd9-da8b-45aa-9c33-61cf26618c1b | 2026-07-28 | `mobbin` · **Dropped after review.** A B2B seat invite into a design team, not a facilitator cohort. Duolingo's classroom join replaced it as the Q6 source. |
| Mobbin — Unity Learn, "Home" (web, 11 screens) | https://mobbin.com/flows/b0ad7dfe-41b9-4f9c-86be-5627e7ba9990 | 2026-07-28 | `mobbin` · **Cut after review** for audience fit — professional developer academy. Zero-state stat row (0 Completed / 0 XP / 0 Badges) covered by Duolingo and Brilliant instead. |
| Mobbin — Preply, "Home" (web, 2 screens) | https://mobbin.com/flows/09bde901-6850-4ca7-8697-41eae76c72ce | 2026-07-28 | `mobbin` · **Optional.** Pre-first-lesson checklist and an "Awards 1/14" locked-achievement grid — a clean Q5 data point if that question stays thin. Tutoring marketplace, so weak audience fit. |
| Mobbin — Front Academy, "Taking a course" (web, 5 screens) | https://mobbin.com/flows/d8610432-7664-4866-8655-3df8bbae3cc2 | 2026-07-28 | `mobbin` · Not selected — B2B product academy, no consumer signup→home handoff. |
| Mobbin — Podia, "Accepting an invitation" (web, 5 screens) | https://mobbin.com/flows/36c96106-c54f-432d-94b6-cc4d1f6165f3 | 2026-07-28 | `mobbin` · Not selected — creator-course platform; the invite is a purchase-adjacent enrolment, not a cohort join. |

## Searches run (including null results)

| Query | Platform | Date | Result |
|---|---|---|---|
| "education app sign up then land on a personalized learning dashboard home with recommended course" | web | 2026-07-28 | Returned Coursera, Uxcel ×2, Unity, Brilliant. **No Khan Academy, no Duolingo.** |
| "online learning platform first time user setup after registration reaching course home with progress tracking" | web | 2026-07-28 | Returned Uxcel ×2, Front, Coursera ×2. **No Khan Academy, no Duolingo.** |
| "Khan Academy learner joins a class with a class code and reaches their assigned course dashboard" | web | 2026-07-28 | Returned Uxcel, **Duolingo (classroom join)**, Preply, Podia. **No Khan Academy result despite naming it in the query** — the basis for the contingent C2 path in `PLAN.md`. Not yet treated as proof of absence; a dedicated Khan Academy search is required before invoking C2. |
| "Duolingo create account after placement and arrive at the learning path home screen" | web | 2026-07-28 | Returned four Duolingo web flows: "Creating a profile" ×2, "Adding a new course", "Onboarding" (18 screens, pre-signup). Confirms Duolingo web coverage; **no C2 needed.** |
| "Khan Academy new learner signs up and reaches their personalized dashboard with recommended lessons" | web | 2026-07-28 | **NULL for Khan Academy.** Returned Brilliant ×3, Uxcel, Babbel. This is the *dedicated* search `PLAN.md` required before invoking C2 — the platform is now named explicitly in **three** separate queries across the day with zero Khan Academy results. **C2 confirmed: no Mobbin web coverage.** |
| "CodeSignal account creation then arriving at the practice dashboard with skill paths" | web | 2026-07-28 | **NULL for CodeSignal.** Returned Uxcel ×2, Brilliant, Heidi, Elicit. **C2 confirmed: no Mobbin web coverage.** |

### C2 determination (2026-07-28)

**Khan Academy** and **CodeSignal** have **no Mobbin web coverage**, verified by dedicated
search rather than assumed. Under `.claude/references/mobbin-sourcing.md` trigger **C2**,
both move to Claude-in-Chrome capture. Recorded in `PLAN.md`.

## Additional flows surfaced 2026-07-28 (second search round)

| Source | URL | Accessed | Notes |
|---|---|---|---|
| Mobbin — Brilliant, "Home" (web, 2 screens) | https://mobbin.com/flows/f7b6036f-6105-4bf8-a40a-ab1858e3e2d2 | 2026-07-28 | `mobbin` · **Selected.** A matched zero-state / populated pair of the same home, mirroring Uxcel's. Screen 1 is shared with the Onboarding flow's terminal screen. |
| Mobbin — Brilliant, "Setting up an account" (web, 12 screens) | https://mobbin.com/flows/b85501ce-9a95-4348-aa9f-60b7ae60516e | 2026-07-28 | `mobbin` · Not yet captured; a second Brilliant account-creation variant. Reserve if the Onboarding flow proves thin. |
| Mobbin — Babbel, "Home" (web, 4 screens) | https://mobbin.com/flows/65df3ee2-7df0-42cc-91ac-36a7fa74ec76 | 2026-07-28 | `mobbin` · **Candidate, not yet captured.** Surfaced unprompted with an explicit zero-state message ("Start learning to see your progress here.") beside a level-finding prompt. Better audience fit than Uxcel or CodeSignal. See `PLAN.md`. |
| Mobbin — Uxcel, "Onboarding" (web, 23 screens) | https://mobbin.com/flows/452191b8-996a-4e8e-a17b-691e5c04f042 | 2026-07-28 | `mobbin` · Longer variant of the 19-screen flow. **Its terminal screen is `6b262155` — the same zero-state home already captured as Uxcel `reference/01`.** Confirms that home is where onboarding lands, not an unrelated view. |

## First-party Chrome capture (C2 platforms)

Provenance `chrome` — operated first-party in an authenticated session. Unlike the Mobbin rows
above, screenshots from these sessions **are committed** (`platforms/<p>/screenshots/`), so the
redact-before-capture standard is load-bearing: every committed image was inspected before
saving. Accounts were created by the user; the assistant never created an account or entered a
password.

| Source | URL | Accessed | Notes |
|---|---|---|---|
| CodeSignal — onboarding conversation | https://codesignal.com/learn/onboarding | 2026-07-29 | `chrome` · Authenticated, un-onboarded session. Mascot greeting → consent prompt → three-question LLM intake (motivation / domain / level) resolving to a named path card. **Account creation not observed** — the session was resumed, so Q1 is not answered by this platform. |
| CodeSignal — Paths home (zero progress) | https://codesignal.com/learn/course-paths | 2026-07-29 | `chrome` · `/learn` redirects here. Catalogue surface: app-download promo, six-tile Collections grid, "Find your path" chat offer, Trending rail (INTERMEDIATE/ADVANCED to a declared Beginner). Nav carries a `0 days` streak with no stated unlock condition, plus an **Upgrade** control — observed, not transacted. |
| CodeSignal — My Learning (zero state) | https://codesignal.com/learn/my-learning | 2026-07-29 | `chrome` · At zero progress the entire authenticated content is a mobile-app advertisement followed by the marketing footer. No empty state, no recovery action, no reference to the path just recommended. The study's only instance of a first-run slot **reassigned to promotion**. |
| Khan Academy — first authenticated view (new learner account) | https://www.khanacademy.org/profile/me/courses | 2026-07-29 | `chrome` · Brand-new **student** account, email verification still pending. First authenticated state carries a dismissible 4-step feature tour layered over a blocking 2-step "Personalize Khan Academy" modal. **Account creation not observed** — Q1 not answered. Supersedes the 2026-07-28 teacher-account attempt, which was abandoned with nothing saved. |
| Khan Academy — learner home after intake (zero progress) | https://www.khanacademy.org/profile/me/courses | 2026-07-29 | `chrome` · Post-intake home: `0 week streak`, `Level 1`, **`0 /1 skill`**, six badge counters at 0, "Pick a username - Add your bio". *My courses* renders exactly the three courses chosen in the modal, each with a first-unit **Start**, plus **Add another course**. Nonprofit surface — **Donate**, no upgrade control. |
