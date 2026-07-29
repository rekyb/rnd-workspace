# Research: Certificate of Completion vs Badges as Gamification for Teacher EdTech (Indonesia)

- **Status:** Closed
- **Type:** benchmark  _(literature review + light platform benchmark)_
- **Started:** 2026-07-17
- **Closed:** 2026-07-17
- **Researcher:** Claude (acting Senior UI/UX Designer)
- **Coverage:** unverified (pre-2026-07-29 study)

## Goal
Understand the **effect of "certificate of completion" versus "badges"** as gamification
mechanics in edtech apps, specifically for the **teacher-in-Indonesia** context, and
**recommend other simple gamification tools** that could work for the same audience.

This is **input to a design/build decision**: which gamification mechanic(s) an edtech
product for Indonesian teachers should adopt, and why. The study answers it two ways that
reinforce each other:
- a **literature review** of what published research says about the motivational and
  learning effects of completion certificates vs digital badges (with attention to
  professional / adult / low-to-middle-income and Indonesian teacher contexts); and
- a **light benchmark** of how real platforms (Indonesian teacher edtech, global
  teacher-PD platforms, and gamification-heavy edtech) actually implement each mechanic.

`/review-research` will judge the synthesis against this goal.

## Scope
**In scope**
- Certificate-of-completion mechanics (what they are, how shown, motivational/credential effect).
- Digital badge mechanics (micro-credentials, achievement badges, how shown/earned).
- The two head-to-head: which drives engagement/completion/perceived value, for whom, when.
- Teacher-specific and Indonesia-specific factors (extrinsic credential culture, PD/
  certification incentives, mobile-first, connectivity, language).
- A shortlist of **other simple gamification tools** (progress bars, streaks, points/XP,
  leaderboards, levels, checklists, etc.) with a fit assessment for this audience.

**Out of scope**
- Building or prototyping any feature (this study informs, it does not build).
- Full competitive teardown of any single platform (this is a *light* benchmark).
- Deep quantitative meta-analysis; we synthesize existing findings, we do not run new stats.
- Live participant research (no recruiting/running of teachers from here).

## Platforms to benchmark
Anchored across the three families the user selected. Final selection confirmed in `PLAN.md`.
- [x] **Indonesian teacher edtech** — Platform Merdeka Mengajar → **Rumah Pendidikan (Ruang GTK)** (in-app cert flow SSO-gated; Play listing captured)
- [x] **Global teacher-PD platforms** — **Coursera** (paid-credential framing) + **Google for Education** (free tiered educator credentials)
- [x] **Gamification-heavy edtech** — **Duolingo** (streak/XP/quests/progress/badges, anonymous guest session)

## Log
- 2026-07-17 — research created (type: benchmark; method: litreview + light benchmark).
- 2026-07-17 — PLAN.md reviewed (Principal Researcher Mode A, revised) and user-approved; literature review started.
- 2026-07-17 — literature review complete (deep-research: 24 sources, 23 confirmed / 2 refuted claims). Evidence base written to `references.md`; URLs logged in `sources.md`. Next: light platform benchmark.
- 2026-07-17 — light platform benchmark complete: Coursera, Google for Education, Duolingo, Rumah Pendidikan/PMM (SSO-gated, Play listing only). Redacted, committable captures under `platforms/` (screenshots + flow.gif + flow.md + notes.md each). PII verified. Next: `/synth-findings`.
- 2026-07-17 — `SYNTHESIS.md` written (type: benchmark; 8 feature write-ups: cert, badges, tiered credentials + ranked shortlist of 5 simple tools). Principal Researcher Mode B QA ran: 22 em-dashes removed, 5 core mechanism claims corroborated / 0 contradicted, 5 content items flagged (geography/citation qualifiers). Verdict: **ready for `/review-research`**.
- 2026-07-17 — **Peer review recorded** (`/review-research`): Skeptic + Domain Expert + Evidence Auditor, moderated by Principal Researcher (Mode C). Verdict **2 Robust, 8 Strengthen, 0 Unsupported** — nothing cut. All strengthenings applied on approval: split "certificate" into 3 constructs, relabelled F3/F5 rationales as hypotheses, dropped "competence" from F4, relabelled the shortlist a "reasoned priority order", cited F6/F8 premises (5 new context sources verified + logged in `references.md`), added **Feature 9 (prosocial/collective framing)** and offline-first/PPG-hook/WhatsApp to Gaps. `## Peer Review` section appended.
- 2026-07-17 — **research closed** (`/close-research`). Principal Designer (Mode P) harvested patterns into `research/PATTERNS.md`: 4 added (badge-as-in-loop-recognition, tiered credential [hypothesis], progress-bar/goal-gradient default, prosocial framing), 3 updated (institution-credential driver, layered motivation stack, peer-league), 1 contradiction flagged (individual leaderboards: positive in prior Western studies vs cautioned here for low-individualism audience). Removed from active registry.
