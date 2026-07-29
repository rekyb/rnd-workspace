# Research: AI-Literacy Upskilling for Indonesian Teachers

- **Status:** Closed
- **Type:** benchmark
- **Started:** 2026-07-14
- **Closed:** 2026-07-17
- **Researcher:** Claude (acting Senior UI/UX Designer)
- **Coverage:** unverified (pre-2026-07-29 study)

## Goal
Benchmark how existing platforms solve the *pieces* of an AI-literacy upskilling
experience for teachers, to ground the design of a **mobile-first course + app** that
(1) builds an Indonesian teacher's **own AI fluency first**, then (2) equips them to
teach students the *proper* use of AI. This is **input to a build decision** — the
observed patterns will drive our module map, learning-loop, assessment/credentialing,
and classroom-transfer design. The design lead is **personal fluency first**
(the teacher must be able to use AI before they can teach it), so the benchmark
weights personal-use onboarding and habit formation above classroom-curriculum
delivery — while still capturing how the strongest platforms teach responsible use.

> [!NOTE]
> **Target user — Indonesian teachers (SD–SMA).** Overwhelmingly **mobile-first,
> Android-first**; live inside a few high-frequency apps led by **WhatsApp**; already use
> the government PD app **Merdeka Mengajar / PMM** (now "Ruang GTK"). General digital
> confidence is real but **uneven** (lower for older/rural teachers), and **AI literacy is
> nascent** — they want **hands-on, tool-specific** help (Canva, ChatGPT), not theory.
> → Design mobile-first Android, light and offline-tolerant, WhatsApp-adjacent, with
> onboarding that assumes mixed confidence.
> Full cited profile + evidence gaps: **[`AUDIENCE-CONTEXT.md`](./AUDIENCE-CONTEXT.md)**.

## Scope
**In scope:** signup → first useful outcome (time-to-value); micro-learning unit
structure and length; how teachers are scaffolded to apply AI to their *own* work
(prompting, worked examples, practice sandbox); how/where responsible use is taught
(verification, bias, hallucination, privacy, academic integrity) and its *sequencing*;
classroom-transfer assets (lesson plans, discussion scripts, student activities,
policies); credentialing / PD-hour recognition; motivation, habit and social/cohort
mechanics; localization & context-fit for Indonesia (Bahasa, mobile-first, bandwidth,
offline).

**Out of scope:** pricing/billing internals and any paid flow (guardrail: never pay);
native-app performance benchmarking; building any feature; live participant research;
back-office/admin tooling.

## Platforms to benchmark
Tiered to stay tractable (core = deep capture; secondary = lighter, targeted passes).

**Core (deep capture — full onboarding + core loop):**
- [x] MagicSchool AI — teacher-facing AI toolkit + educator onboarding ("teacher utilizes AI")
- [x] Khanmigo (Khan Academy) — teacher AI assistant, guided practice, worked examples
- [x] Elements of AI — structured, responsible-use AI-literacy course (curriculum + ethics sequencing)

**Secondary (targeted passes — specific patterns only):**
- [x] Common Sense — AI Literacy — classroom-transfer lessons ("teach students proper use")
- [x] Google AI Essentials — bite-sized responsible-AI upskilling + completion credential
- [x] Platform Merdeka Mengajar (PMM) — Indonesia's govt teacher-PD app — ⚠ **gated (site errored / `belajar.id` login); context-only, externally sourced, no first-hand stills**
- [x] Ruangguru — major Indonesian edtech; local onboarding & engagement patterns

## Log
- 2026-07-14 — research created (type: benchmark).
- 2026-07-15 — plan approved; capture method set to public-surface + external enrichment
  (no account creation / no paid flows).
- 2026-07-15 — core platforms captured: MagicSchool AI, Khanmigo, Elements of AI
  (screenshots + notes.md + flow.md each; PII-safe, gated in-app detail externally cited).
- 2026-07-15 — secondary platforms captured: Common Sense (RQ5), Google AI Essentials (RQ6/RQ2),
  Ruangguru (RQ7, first-hand landing), PMM (RQ6-local/RQ7, context-only — site gated, no stills).
  **Capture phase complete; ready for /synth-findings.**
- 2026-07-15 — SYNTHESIS.md written (type: benchmark; **8 cross-platform features**, 5-field format).
  Principal Researcher QA (Mode B) ran: prose cleaned (~165 em-dashes removed), rationales validated
  against 12 external sources in `references.md` (6 corroborated, 3 challenged), **7 items flagged**.
  Verdict was "resolve first"; the 3 review-blocking flags (F3 scaffolding, F7 spacing, F8 credential
  wording) were resolved by the lead designer. **Now ready for /review-research.**
- 2026-07-15 — `/review-research` run: three stakeholder personas (PM, Tech Lead, Head of Product),
  chained. Verdict recorded in `SYNTHESIS.md` `## Agent Review`. Consensus: fluency-first v1 spine
  (F7→F1→F2 + F4/F6) Go; transfer strand F3/F5 held to phase 2; F8 Conditional Go on primary
  Indonesian-teacher research. No feature is a flat Reject. Also produced `CURRICULUM-MAP.md`
  (content/pedagogy companion: modules, unit loop, per-module exercises + pulse checks).
- 2026-07-15 — `/extract-tokens` lens run: pixel-sampled design tokens for 6 platforms
  (MagicSchool, Khanmigo, Elements of AI, Common Sense, Google AI Essentials, Ruangguru; PMM
  excluded — no screenshots) → `lenses/tokens.md` + a draft `lenses/magicschool-ai-tokens.json`.
  Inferred/unvalidated (small-area CTA colours eyeballed; Ruangguru palette scrim-affected).
- 2026-07-15 — `/heuristic-eval` lens run: Nielsen's 10 over 6 platforms (PMM excluded) →
  `lenses/heuristic-eval.md`. Observable issues: 0 catastrophic, 0 major, 5 minor (sev 2),
  3 cosmetic (sev 1), 15+ exemplary patterns. Interaction-only heuristics (H1/H3/H5/H9) flagged
  as unassessable from static marketing captures.
- 2026-07-15 — `/a11y-audit` lens run (WCAG 2.2 AA) over 6 platforms → `lenses/a11y-audit.md`.
  Measured contrast: 10 pass, **2 fail** (MagicSchool gold card text 2.19:1; Khanmigo grey tool
  desc 3.98:1), 1 marginal (Common Sense nav 4.85:1); target-size/colour-only/label checks Partial;
  keyboard/SR/focus/reflow + mobile-viewport flagged live-only. Three lenses now complete.
- 2026-07-15 — pre-spec brainstorm → `DESIGN-FOUNDATIONS.md` (tokens + language). Locked: Calm &
  credible (deep teal `#0F766E` + warm off-white + amber wins), Plus Jakarta Sans, "Anda" register,
  scaffolded-jargon, medium win-moment, dark mode in v1, clean-neutral UI. A11y contrast fixes baked
  into tokens. Refined: **pill-first components** (pill controls, soft-rounded cards), **SVG icons
  (Lucide), no emoji**, and an explicit **mobile-first layout** section (360–390px canvas, thumb-zone
  nav, offline). Intended input to `/draft-spec`.
- 2026-07-15 — `/draft-spec` run: `SPEC.md` drafted (17 FRs incl. 2 Won't = the review's No-Go
  features; 15 screens; Mermaid flow + IA; traceability matrix). Principal Designer **Mode S:
  revise → must-fixes applied** (offline branch closed; FR-15 deferred/reconciled) → Reviewed.
- 2026-07-15 — `/design-prototype` run (hi-fi, **local HTML** per user choice — not published):
  `prototype.html` — 15 SPEC screens + win overlay, Bahasa, light/dark, pill/SVG design system,
  7-state generator (form/validasi/PII/generating/offline/gate-fail/cached/result). Principal
  Designer **Mode T: revise → all 5 must-fixes applied** (Hook beat added, S8 micro-check added,
  honest first-run hub, gate-fail fallback copy fixed, tab labels tokenized) + routing/a11y
  should-fixes. Declared deviations listed in the prototype's side panel.
- 2026-07-15 — **Gojek voice/copy pass** (targeted, post-synthesis, adds no feature) →
  `platforms/gojek/notes.md`. Public web surfaces + Gojek's first-party UX-writing blog. Finding:
  register is chosen **by audience** — Gojek runs 3 tones (consumer casual `kamu`; driver/merchant
  partner formal), and the partner surface pairs **`Anda` with colloquial rhythm** (`udah`,
  `ningkatin`, `yuk`). **Validates our locked `Anda`**, but shows our copy is too stiff. Their stated
  principles: Clear, Concise, Helpful. Evidence = verbatim strings + URLs, **no stills** (declared).
- 2026-07-15 — **register pass** (29 edits) on `prototype.html`. A `kamu` (casual) rewrite was
  requested, then **rejected by the design lead** once the tension was surfaced; chosen instead:
  **`Anda` + colloquial rhythm** (the Gojek Mitra pattern). Warmth now comes from particles, short
  verbs, and questions-as-headings, not from the pronoun. Codified in `DESIGN-FOUNDATIONS.md` §5
  (register rule + **tone ladder by stakes** + jargon split by surface), so spec and prototype stay
  in sync. `kamu`-vs-`Anda` recorded as **[to validate]** with teachers (ties to the F8 precondition).
  Verified: 0 em-dashes, 0 `kamu`, 55 `Anda` in rendered copy.
- 2026-07-15 — **copy pass** on `prototype.html`: **51 strings** rewritten. All em-dashes removed from
  user-facing copy (0 left; code comments untouched) and wordy strings tightened, applying Gojek's
  *Clear, Concise, Helpful* + the stakes-based tone ladder (warm for offline/wins, plain for errors,
  formal and unadorned for FR-13 student-data warnings). Register (`Anda`) unchanged. Verified in-browser.
- 2026-07-15 — **onboarding revamped** in `prototype.html` (interactive, Duolingo/Brilliant-style):
  welcome + skip → 8-step wizard (segmented progress, one question per screen, guide character with
  speech bubble, big auto-advancing option cards, 2 value interstitials) → animated plan build +
  personalized plan reveal. The FR-13 privacy rule is now **taught by a spot-the-unsafe-prompt choice**
  with right/wrong feedback instead of a passive read. New assumptions declared in-prototype (guide
  character, daily-target & workload steps not in SPEC S1–S3; onboarding answers drive copy only).
  Verified in-browser (light + dark, no console errors). **Pending Principal Designer Mode T re-review.**
- 2026-07-15 — prototype reframed in an **Android device shell** (bezel + side buttons, status bar
  w/ punch-hole + signal/wifi/battery, gesture-nav pill; wifi icon swaps in offline demo; full-bleed
  on real phone viewports).
- 2026-07-16 — **audience-behavior desk research** (deep-research harness; 21 sources, 25 claims
  3-vote verified, 23 confirmed / 2 refuted) → `AUDIENCE-CONTEXT.md` (standalone, self-cited).
  Profiles the target user's device/connectivity + app/platform habits (mobile-first Android;
  WhatsApp-led; PMM incumbent; nascent AI literacy; hands-on/tool-specific preference). Grounds RQ7
  and the **F8 primary-research precondition** externally; flags 4 gaps only primary research can close.
  Kept separate from `SYNTHESIS.md`/`references.md` by design.
- 2026-07-17 — **research closed** (`/close-research`). Principal Designer (Mode P) harvested reusable
  patterns into `research/PATTERNS.md`: **6 added** (form-first "no blank box" generation; bounded
  observed sandbox/Rooms; fluency ladder shield→minimize→teach; ethics-after-first-win sequencing;
  concept→exercise→reflect micro-unit loop; grab-and-go run-tomorrow lessons + dilemma-discussion),
  **5 updated** (productive-struggle remediation w/ Khanmigo Socratic + guided-scaffold caveat;
  institution-recognized credentials; layered motivation stack w/ Starchamps reward-for-speed
  anti-pattern; character-guided icon-first intake; deep localization of onboarding chrome),
  **0 contradictions**. Removed from the active registry.
