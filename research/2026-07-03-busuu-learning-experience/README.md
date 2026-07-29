# Research: Benchmark Busuu — 3 most valuable learning-experience features

- **Status:** Closed
- **Type:** benchmark
- **Started:** 2026-07-03
- **Closed:** 2026-07-03
- **Researcher:** Claude (acting Senior UI/UX Designer)
- **Coverage:** unverified (pre-2026-07-29 study)

## Goal
Study how Busuu designs its language-learning experience and identify the **three
most valuable features** that most improve how users learn. For each, capture
evidence (screenshots + a recorded core flow) and articulate the UX/product
reasoning behind why it works, so the findings can inform our own learning-product
design. This is input to a build decision (judged on soundness *and* build value),
mirroring the DataCamp study.

## Scope
- **In scope:** Busuu's publicly observable learning surfaces — onboarding &
  placement, the lesson player (vocabulary, grammar, listening, speaking, writing
  exercises), spaced-repetition / vocabulary review, the study plan & goals,
  community-correction features (Conversations — write/speak, get corrected by
  native speakers), feedback & correction UX, and motivational mechanics
  (streaks, progress, leaderboards, certificates) that shape the learning
  experience.
- **Out of scope:** Pricing/business model, marketing funnel, B2B/Busuu for
  Business admin tooling, and anything behind a hard paywall we cannot observe.
  Desk research only — we observe and document; we do not build, and we never pay.

## Platforms to benchmark
- [x] Busuu (busuu.com)

## Log
- 2026-07-03 — research created.
- 2026-07-03 — PLAN.md reviewed by Principal Researcher (3 must-fixes applied),
  approved by user. Account access: user's existing logged-in Chrome session
  (Google sign-in). Capture started.
- 2026-07-03 — Busuu benchmarked (logged-in free account, English A1). Captured
  core lesson flow (`flow.gif` + written `flow.md`) and 16 numbered screenshots
  spanning the candidate pool: lesson player, instant feedback, match exercises,
  reward loop (Stars/Score, Today's challenges, Blue League), Community/
  Conversations (native-speaker correction), Vocabulary Review (SRS), Speak (AI
  pronunciation), and the freemium/paywall model. `notes.md` + `sources.md`
  written. All PII (account holder + third parties) redacted and verified in the
  saved images. No paid features purchased or trialed.
- 2026-07-03 — synthesis written (`SYNTHESIS.md`): 3 features selected from a 7-feature
  candidate pool. Principal Researcher QA pass ran (Mode B): 0 AI-slop rewrites, 55
  em-dashes removed across SYNTHESIS/notes/flow; 4 content items flagged (audio
  speed-claim, two uncited learning-science claims, native-speaker evidence gap), all
  resolved by softening to observed evidence. Synthesis ready for `/review-research`.
- 2026-07-03 — agent review recorded (`SYNTHESIS.md` › Agent Review): PM / Tech Lead /
  Head of Product, build-decision lens. Verdicts: F1 Go · F2 Conditional Go (viability
  spike) · F3 → XP/streak/challenges Go, Blue League Conditional Go. Nothing No-Go; F2
  and Blue League gated on scale + safety.
- 2026-07-03 — research published to GitHub (`origin/main`, commit `be8250a`).
- 2026-07-03 — research closed.
