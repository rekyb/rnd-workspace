# Research: Learning loop, engagement loop & measuring real upskilling

- **Status:** Closed
- **Type:** benchmark
- **Started:** 2026-07-06
- **Closed:** 2026-07-06
- **Researcher:** Claude (acting Senior UI/UX Designer)
- **Coverage:** unverified (pre-2026-07-29 study)

## Goal
Study how established learning platforms structure two interlocking loops and how
they demonstrate that learning actually happens:

1. **The learning loop** — the core mechanics that build skill/knowledge (present →
   practice → feedback → mastery/retention), and how a session chains into durable
   learning rather than one-off completion.
2. **The engagement loop** — the motivational mechanics that bring users back
   (streaks, goals, progress, rewards, notifications) and how they wrap around the
   learning loop without hollowing it out.
3. **Efficacy measurement** — how the platform *benchmarks/measures whether users
   are genuinely getting smarter/upskilled* (mastery models, proficiency estimates,
   assessments, progress signals shown to the learner), versus merely measuring
   engagement.

This is **input to a build decision**: the findings will inform how we define our
own core learning platform's learning + engagement loops and how we prove efficacy.
Judged on soundness *and* build value. Start with **Khan Academy**; more platforms
may be added in later rounds.

## Scope
- **In scope:** Publicly and account-observable learning surfaces — onboarding &
  placement/diagnostic, the core exercise/lesson player (present → practice →
  feedback), mastery / proficiency mechanics (mastery levels, "mastery points",
  progress bars, unit tests, course challenges), the practice/review loop, the
  engagement layer (streaks, energy points/rewards, goals, daily streaks,
  reminders), and any learner-facing signals that claim "you are improving"
  (mastery %, skill levels, progress dashboards, reports).
- **Out of scope:** Pricing/donation/business model, marketing funnel, teacher/
  district admin tooling except where it exposes the learner efficacy model,
  and anything behind a hard paywall we cannot observe. Desk research only — we
  observe and document; we do not build, and we never pay.

## Platforms to benchmark
- [x] Khan Academy (khanacademy.org) — logged-in account provided by user

## Log
- 2026-07-06 — research created.
- 2026-07-06 — SYNTHESIS.md written (7 features distilled from Khan Academy round 1).
  Principal Researcher QA pass ran (Mode B, incl. new B4 external validation): 0 AI-slop
  rewrites, 42 em-dashes removed, 18-source academic validation (6/7 rationales
  corroborated, 1 citation contradicted by its source, flagged). 6 content issues flagged;
  all 6 resolved directly (attribution/accuracy fixes, no findings invented) incl. the
  material Feature 4 DKR-1999 misattribution. Synthesis ready for /review-research.
- 2026-07-06 — agent review recorded (`SYNTHESIS.md` › Agent Review): PM / Tech Lead /
  Head of Product, build-decision lens. Nothing Rejected or No-Go. F2 Go; F1/F3/F4/F5/F6/F7
  Conditional Go. Sequenced bet: phase 1 = F2 + cheap-F1 + Low-F5 on one mastery-state
  spine; F3 + full F1 estimator deferred behind real cost; F7 (the efficacy differentiator)
  gated on a cheap onboarding-friction test first. Flagged research risk: single platform.
- 2026-07-06 — research published to GitHub (`origin/main`, commit `f613480`).
- 2026-07-06 — research closed.
- 2026-07-06 — PLAN.md drafted and reviewed by Principal Researcher (Mode A):
  verdict "needs revision", 6 must-fixes applied (mastery state-change capture,
  engagement tagging rule, baseline as primary finding, named skill + fallback,
  build-takeaway criterion, decay flagged not-observable). Pending user approval
  before capture.
- 2026-07-06 — plan approved by user. Capture started. User also requested external
  academic sourcing: a cited learning-science evidence base (`references.md`) is
  being compiled to validate findings, and the Principal Researcher persona is being
  extended to find/cite external research going forward.
- 2026-07-06 — `references.md` completed: 18 verified peer-reviewed sources across
  learning-loop mechanics, efficacy measurement, and engagement/its-risks, each with
  a working URL and honest verification flags. Includes 8 "key tensions" to test the
  Khan observations against (e.g. engagement can rise while learning stays flat).
  Principal Researcher persona + CLAUDE.md updated to make external academic
  validation a standing capability (Mode B step B4).
- 2026-07-06 — Khan Academy captured (logged-in **teacher** account; learner surfaces
  traced directly). Core learning-loop recorded on Algebra 1 › "Evaluating expressions"
  (`flow.gif` + `flow.md`), 8 numbered stills (`01`–`08`) covering the course
  mastery model + engagement bar, the question→feedback→graduated-hints→video loop, the
  first-try-correct vs corrected feedback, the **two-mistake "can't reach Proficient"
  mastery gate**, and the before/after mastery change (Not started → Familiar 71%,
  5/7 correct, 475 energy pts). `notes.md` answers Q1–Q5, tags each engagement mechanic
  learning- vs activity-tied, names the **top 3 dual-purpose features** (mastery grid;
  graduated hints + video; end-of-set reward summary), and gives an adopt/adapt/avoid
  build takeaway, all cross-cited to `references.md`. All PII redacted and verified in
  the saved images (account name/avatar blurred by role/position). No paid features
  touched. Key efficacy finding: Khan measures learning as **mastery-state accrual from
  a zero baseline**, with **no forced pre/post diagnostic**.
