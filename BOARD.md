# R&D Board

A single view of everything in this workspace — the **active** studies, all
**closed / archived** ones, and every **design project**. This is the human-readable
board; `/research-board` renders it to the terminal and refreshes it as studies open
and close and projects are created. The source of truth is each study's own
`README.md` (`Type`, `Started`, `Closed`, `Status`) plus the active registry
`.claude/.active-research` (one active study per line), and each project's own
`README.md` (`Status`, `Started`, `Informed by`, `Design system`). The design half has
no registry by design — see `.claude/references/design-projects.md`.

_Last updated: 2026-08-07_

## Active

No active research — run `/new-research` to start one.

## Closed &amp; archived

Past studies, most recent first.

| Research | Type | Started | Closed | Status |
|---|---|---|---|---|
| [Post-Signup Handoff to the First-Run Learning Home](research/2026-07-28-post-signup-handoff-first-run-home/) | benchmark | 2026-07-28 | 2026-08-07 | Closed — Q2,Q3,Q5 answered · Q1,Q4 partial · Q6 unanswered |
| [Learning Home Layout & Information Architecture](research/2026-07-29-learning-home-layout-and-ia/) | benchmark | 2026-07-29 | 2026-07-30 | Closed — Q1,Q5 answered · Q2,Q3,Q4 partial · Q6 withdrawn |
| [Onboarding Strategy & Patterns](research/2026-07-20-unified-onboarding-synthesis-and-patterns/) | litreview | 2026-07-20 | 2026-07-24 | Closed |
| [Meaningful Youth Onboarding & the Aha Moment (solve.education)](research/2026-07-17-youth-onboarding-aha-moment/) | benchmark | 2026-07-17 | 2026-07-18 | Closed |
| [Certificate of Completion vs Badges as Gamification for Teacher EdTech (Indonesia)](research/2026-07-17-certificate-vs-badge-gamification/) | benchmark _(literature review + light platform benchmark)_ | 2026-07-17 | 2026-07-17 | Closed |
| [AI-Literacy Upskilling for Indonesian Teachers](research/2026-07-14-ai-literacy-upskilling-indonesian-teachers/) | benchmark | 2026-07-14 | 2026-07-17 | Closed |
| [Indonesian Teacher EdTech Onboarding & Activation Literature](research/2026-07-16-indonesian-teacher-onboarding-literature/) | benchmark | 2026-07-16 | 2026-07-17 | Closed |
| [Onboarding & Activation in Education Apps](research/2026-07-13-onboarding-activation-education-apps/) | benchmark | 2026-07-13 | 2026-07-13 | Closed |
| [Benchmark Synthesis For The Learn-To-Hire Loop](research/2026-07-09-benchmark-synthesis-learn-to-hire-loop/) | benchmark | 2026-07-09 | 2026-07-09 | Closed |
| [Learning loop, engagement loop &amp; measuring real upskilling](research/2026-07-06-benchmark-learning-effectiveness-loops/) | benchmark | 2026-07-06 | 2026-07-06 | Closed |
| [Benchmark DataCamp — 3 most valuable learning-experience features](research/2026-07-03-datacamp-learning-experience/) | benchmark | 2026-07-03 | 2026-07-03 | Closed |
| [Benchmark Busuu — 3 most valuable learning-experience features](research/2026-07-03-busuu-learning-experience/) | benchmark | 2026-07-03 | 2026-07-03 | Closed |
| [Briliant — early benchmark notes](research/2026-07-02-briliant/) | benchmark | 2026-07-02 | — | Archived (notes only) |

## Design projects

The MAKE half — long-lived projects, not dated studies. Status lives in each project's
own `README.md`; start one with `/new-design <name>`.

| Project | Status | Started | Informed by | Design system | PRD | Prototype |
|---|---|---|---|---|---|---|
| [Learner Acquisition &amp; Onboarding](design/onboarding-solve-edu/) | Active | 2026-07-21 | [unified-onboarding-synthesis-and-patterns](research/2026-07-20-unified-onboarding-synthesis-and-patterns/) | independent _(settled 2026-07-28; will not migrate)_ | ✓ | ✓ |
