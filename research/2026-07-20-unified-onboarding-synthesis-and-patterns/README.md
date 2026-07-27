# Research: Onboarding Strategy & Patterns

- **Status:** Closed
- **Type:** litreview
- **Started:** 2026-07-20
- **Closed:** 2026-07-24
- **Researcher:** Gemini (acting Senior UI/UX Designer)

## Goal
Establish the onboarding strategy and reusable UX patterns for solve.education by reviewing education app benchmarks, target-audience literature, and youth onboarding strategies.

## Scope
- In scope: Analyzing onboarding literature, benchmarks, and youth strategy.
- Out of scope: Sourcing new external literature or benchmarking new platforms.

## Corpus & questions
- [ ] `corpus/app-benchmark-synth.md`
- [ ] `corpus/teacher-litreview-synth.md`
- [ ] `corpus/youth-onboarding-synth.md`

## Specs

This study iterated its spec five times. **`SPEC-5.md` is the current one — build from that.**
The earlier four are retained for decision provenance, not for implementation.

| Spec | Status | Note |
|---|---|---|
| `SPEC.md` | Superseded (2026-07-21) | First draft: try-first + placement fork + Lesson 0 |
| `SPEC-2.md` | Deprecated (2026-07-21) | Program-confirmation onboarding |
| `SPEC-3.md` | Deprecated (2026-07-21) | Streamlined try-first; dropped placement fork + Lesson 0 |
| `SPEC-4.md` | Superseded (2026-07-22) | V2-aligned; age gate upfront |
| **`SPEC-5.md`** | **Current** — Reviewed (Mode S: ready) | Prototype-aligned; 9 FRs, 10 screens |

## Log
- 2026-07-20 — research created (type: litreview).
- 2026-07-20 — evidence gathered (3 sources provided, 10 verified claims, 3 refuted/weak claims).
- 2026-07-20 — synthesis written (litreview; 3 themes synthesized. Principal Researcher QA pass run: 2 items flagged).
- 2026-07-20 — peer review recorded (3 Robust, 3 Strengthen, 1 Unsupported; 6 actions applied).
- 2026-07-20 — spec drafted (7 FRs, 5 screens, Principal Designer Mode S verdict: ready after revisions).
- 2026-07-21 — organic onboarding prototype drafted from `SPEC-2.md` (9 clickable screens; local-only; Principal Designer Mode T: LOCAL-READY; G8 live-data binding explicitly not passed).
- 2026-07-21 — `SPEC-2.md` deprecated.
- 2026-07-21 — `SPEC-3.md` drafted (Streamlined Try-First flow, removed placement fork and Lesson 0).
- 2026-07-21 — try-first onboarding prototype drafted from `SPEC-3.md` (7 clickable screens; hi-fi; Principal Designer Mode T: ready; published locally to scratch/prototype.html).
- 2026-07-21 — `SPEC-3.md` deprecated.
- 2026-07-21 — `SPEC-4.md` drafted (aligned with V2 flow structure, added Age Gate upfront, removed Lesson 0 entirely).
- 2026-07-21 — web try-first onboarding prototype drafted from `SPEC-4.md` (9 clickable screens; hi-fi web layout; applied staging styles; Principal Designer Mode T: PASS; published locally to scratch/prototype-web.html).
- 2026-07-22 — `SPEC-5.md` drafted from `design/onboarding-solve-edu/prototype-web.html` (9 FRs, 10 onboarding screens plus product-handoff boundary; `#learning_home` excluded; Principal Designer Mode S: ready).
- 2026-07-24 — research closed. Principal Designer (Mode P) merged patterns into `research/PATTERNS.md`: 2 principles added, 8 entries enriched, 2 contradictions flagged for human resolution (age-gate placement + age floor; placement-fork optionality). Three corrupted UTF-16 Log lines repaired and reordered chronologically during closeout.
