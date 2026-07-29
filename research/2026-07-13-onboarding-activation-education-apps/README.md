# Research: Onboarding & Activation in Education Apps

- **Status:** Closed
- **Type:** benchmark
- **Started:** 2026-07-13
- **Closed:** 2026-07-13
- **Researcher:** Claude (acting Senior UI/UX Designer)
- **Coverage:** unverified (pre-2026-07-29 study)

## Goal
Benchmark how best-in-class education apps design their **onboarding-to-activation**
flow, to inform the onboarding for a new 0-to-1 learning product. This is
**observation feeding a build decision**: the synthesis directly informs our own
onboarding design (planned model: *goal → level → profile → personalized path*).

The guiding question: *how do best-in-class ed apps calibrate a single onboarding
flow so a low-context novice feels guided while an advanced user isn't patronized —
and how much personalization do they extract before the user reaches their first
"win"?* We are designing for three user types at once: **low tech-literacy**,
**low-context** (first-time / no facilitator present), and **advanced** learners.

Grounded in prior internal v1 interviews (kept in gitignored working data, not
committed). The recurring problem shapes worth benchmarking against: the primary CTA
being mistaken for an ad/banner rather than an action; learners who arrive via a
class/program link being dropped into a full catalogue instead of their assigned
course; sign-up requiring an email many young/low-context users don't have;
duplicate accounts from lost sessions; device-level permission prompts (e.g.
microphone) that dead-end novices; and advanced learners disengaging because there's
no way to place into a harder tier.

## Scope
**In:** the onboarding arc from **first touch → first-task activation**, captured
across six moments — (1) value-framing / landing, (2) account creation, (3)
personalization intake, (4) path assignment, (5) first-task guidance, (6)
advanced-user accommodation. Mobile-first capture; desktop noted only where the
onboarding meaningfully differs.

**Emphasis:** the **landing / first-screen value-framing** moment is treated as a
first-class teardown — it directly informs our own landing-page design (the
"CTA-mistaken-for-an-ad" problem above).

**Out:** actually designing our own landing page or onboarding (a downstream step off
this synthesis — e.g. `/brief-feature` or a separate design task); post-activation
retention loops; pricing/paywalled tiers (we never transact — see Guardrails);
primary research (this is a 0-to-1 effort leaning on secondary research; internal
interviews already done).

## Confidentiality
Committed research files stay **product-agnostic**: no internal product/program/funder
names, no internal ticket IDs, no roadmap specifics. Internal grounding lives in the
gitignored `raw-data/` working dir only. `/publish-research` re-checks before any push.

## Platforms to benchmark
- [x] Duolingo — gold-standard onboarding; goal-setting + placement + low friction — **captured**
- [x] Khan Academy — course/path structure closest to ours; grade-level routing & class-code (assigned-course routing) — **captured**
- [x] Brilliant — strong placement + difficulty-tiering onboarding (advanced-user lens) — **captured**
- [x] CodeSignal — skill-assessment / placement onboarding — **captured as gated** (account-first; assessment behind wall, by user decision)
- [x] Elsa Speak — ESL + speaking + emerging-market learners — **captured** (web = marketing + a real web speaking test; app onboarding shown as mockups)

## Log
- 2026-07-13 — research created (type: benchmark).
- 2026-07-13 — plan approved (Principal Researcher passed w/ revisions); capture surface = desktop web (labeled), mobile divergence noted per platform.
- 2026-07-13 — all 5 platforms captured (flow.gif + stills + flow.md + notes.md each; sources logged). Ready for `/synth-findings`.
- 2026-07-13 — SYNTHESIS.md written (benchmark; 10 feature write-ups). Principal Researcher Mode B QA pass: verdict *ready*; 24 em-dashes cleaned, 10/10 rationales externally validated (`references.md`; 8 direct, 2 partial, 0 contradicted), 6 precision items flagged and all resolved by researcher. Ready for `/review-research`.
- 2026-07-13 — heuristic evaluation lens run (`lenses/heuristic-eval.md`): 5 platforms vs Nielsen's 10; 7 violations (3 major, 3 minor, 1 cosmetic) + 12 exemplary patterns.
- 2026-07-13 — agent review recorded (`SYNTHESIS.md` → `## Agent Review`): PM / Tech Lead / Head of Product, chained. Consolidated: 7 Go, 3 Conditional Go, 0 No-Go. Synthesis endorsed to drive the build.
- 2026-07-13 — dual-persona review added (`REVIEW.md`, Principal Researcher + Principal Designer; APPROVED); Stage-2/F5 architecture inconsistency fixed to match the build gates.
- 2026-07-13 — **research closed.** Principal Designer (Mode P) merged patterns into `research/PATTERNS.md`: 10 onboarding patterns added, 2 existing entries strengthened, pre-win-vs-post-win extraction tension flagged. Active pointer cleared.
- 2026-07-14 — **`SPEC.md` drafted** (forward spec off the reviewed synthesis): 13 functional requirements (11 Must / 1 Could / 1 Won't), 8 screens, Mermaid user-flow + IA, traceability matrix. FR-07 and FR-08 promoted to Must (grounded in prior internal onboarding research + the speaking-task first-win decision). Principal Designer Mode S verdict: **revise → all 4 required revisions resolved** (confidentiality genericization, boundary-node labeling, code-path landing, speaking-task assumption flag). Product-agnostic; no internal specifics committed.
- 2026-07-15 — **published** to GitHub via `/publish-research` (PR [#4](https://github.com/rekyb/research-workspace/pull/4)). PII gate passed: prose scanned clean of internal specifics; all 31 screenshots + 7 GIFs (51 sampled frames) visually reviewed — no account-holder or third-party PII; no paid transaction.
- 2026-07-15 — **prototype drafted** (`/design-prototype`, hi-fi, full arc): 8 screens (S1–S8, the guest-first arc + conditional code entry) with an EN/ID i18n toggle, built on the internal design-system tokens, published as a self-contained claude.ai Artifact ([bd9793ec](https://claude.ai/code/artifact/bd9793ec-c320-4fc2-b1d2-473e35674f4f)). DoD: G2–G8 pass, G1 partial (declared — some literal type sizes / brand-logo colours). Principal Designer Mode T: *revise → both required fixes resolved* (org-name genericized for the outward-facing Artifact; restart-path dead-end fixed). Assumptions flagged in-prototype per SPEC §7 (speaking-as-first-task, win-by-completion, recognition cards, boundary nodes, placeholder brand, font/mic degradation).
- 2026-07-15 — **second prototype identified and reviewed — NOT PUBLISH-SAFE, see `REVIEW.md` → `## Prototype Review — v2 Artifact`.** A *separate, later* Artifact — "Onboarding Flow v2 (Guest-first)" ([76aa0ef8](https://claude.ai/code/artifact/76aa0ef8-2a47-4c25-9d22-81fe6aa8ad0a), updated 2026-07-15) — exists alongside the v1 above. It was **not produced by a logged `/design-prototype` run, declared no DoD gate table, and was never gated by Principal Designer Mode T.** Reviewed on request (Principal Designer Mode T: **reject**; Principal Researcher: **revise — blocking**), with structural findings verified in a live browser. **v2 regresses every fix the v1 Mode T gate closed:** the org name is rendered on S1 (v1: genericized to a placeholder wordmark); the save-wall defer path is computed but never rendered, making S7 a hard dead-end (v1: present and working); `:focus-visible`, `prefers-reduced-motion`, and all non-print `@media` are absent (v1: all present); the FR-03 goal-skip is unrendered (v1: present); spec-panel FR ids default to visible on the public URL; and spec-mandated **XP** is replaced by an invented **coins** currency. The v1 entry above is **accurate and unchanged** — v1 remains the compliant artifact. **Treat v1 (`bd9793ec`) as the canonical prototype; do not share or field v2 until the blocking items in `REVIEW.md` are resolved.** Process gap to fix: prototype Artifacts can be published outside the `/design-prototype` gate and leave no trace in this log.
- 2026-07-15 — **synthesis extended + re-reviewed (post-closure augmentation).** Two features added from a practitioner-study lead (["1,460 onboarding flows"](https://www.youtube.com/watch?v=Qsq-Sj_rojU)): **F11 Humanizing touches**, **F12 Contextual just-in-time education**, both **secondary-sourced** (public teardowns / case studies, not first-party captures), grounded with academic refs (Nass 1994; Sweller 1988; Nunes & Drèze 2006; Zeigarnik 1927) and passed a Principal Researcher Mode B QA (revise-light → 2 fixes resolved). **`/review-research` re-run over the full F1–F12 synthesis** (PM / Tech Lead / Head of Product, chained); the `## Agent Review` block now covers all 12 and supersedes the 2026-07-13 one. Consolidated: **8 Go, 3 Conditional Go, 1 split** — F11 → Conditional Go (scalable signed-note at the wall, post-MVP A/B; white-glove rejected); F12 → **Go** on the "no front-loaded tutorial" constraint, **No-Go/defer** on the checklist+tooltip engine (separate post-activation workstream). *Note: study was Closed 2026-07-13; this augmentation post-dates closure.*
- 2026-07-16 — **v2 gated (Principal Designer Mode T: revise → addressed) + SPEC currency fixed.** Per user decision, v2 is being promoted toward canonical, so it was put through the Mode T gate it never had. **First honest DoD table declared in-artifact** (review panel): **G1 fail** (tokens cover surface/brand colours only; type/spacing/radius/shadow are literal), **G2/G3/G5/G6 partial**, **G4 partial** (Assigned reachable only via an out-of-band demo code), **G7 pass**, **G8 n/a** (no data contract exists). SPEC deviation closed: the invented **"coins" currency is now XP** per SPEC S6/§3.3, both locales, including the interpolated loss-framing wall copy. Mode T verdict **revise**; addressed: **T1a** — a real dead-end I introduced (deleted the intro/bridge screens but left their spec-panel jump rows + render keys, so those rows rendered a blank void) now removed; **T2** — six raw `#8E279B` hexes bypassing `--ob-brand` (which broke the EN/ID toggle and code caret in dark mode) swapped to the token, G1 honestly re-declared **fail**; **T3** — the dropped FR-03 "other/skip" affordance declared as a known deviation; **T4** — "Calibrated to:" disclosed as varying by level **band**, not per level (2 bands / 4 level names); **T5** — the level copy no longer promises a recommend-a-foundation corrective that isn't built, and no longer names "Ed" (a character the intake no longer introduces); **T7** — verified CSP-safe (zero external subresources; fonts/icons inlined as data URIs). Should-fixes: generic "John Doe" replaced, dead `code_hint` key (which shipped the demo codes inside the bundle) removed. Demo codes now surfaced **out-of-band** in the artifact description, not on the participant screen. **T6 resolved by user decision (2026-07-16):** Mode T asked for the mascot to be **dropped from S1**; the user chose to **keep it, declared** as unspec'd extrapolation in the prototype's NOTES. **Consequence accepted and recorded:** a 400×225 animated mascot competes with FR-02's "one visually dominant CTA" on the exact screen the F2 first-click test measures, so **any F2 first-click finding from this prototype is confounded and cannot cleanly answer the "CTA-mistaken-for-an-ad" question** (SYNTHESIS §4.1(1) / §F2). Run F2's first-click test on a **mascot-free landing variant** instead, not on this artifact. Still open (non-blocking): social auth cannot fail (SPEC §4 S7 requires social-auth-in-progress + error states); FR-04 AC2's "recommendation, not a gate" remains unimplemented; G5's declared enumeration omits the invisible focus ring on the S8 code input.
- 2026-07-16 — **v2 prototype: blocking items resolved** (supersedes the 2026-07-15 v2 entry below, whose "NOT PUBLISH-SAFE / regresses every fix" standing is **no longer accurate on the correctness items**). The v2 Artifact ([76aa0ef8](https://claude.ai/code/artifact/76aa0ef8-2a47-4c25-9d22-81fe6aa8ad0a)) was fixed against `REVIEW.md` → `## Prototype Review — v2 Artifact` and re-published; every fix **verified live end-to-end in a browser**: spec panel now defaults **off** (closes B3/D11 — FR-ids, the "faux mic" note and the valid demo codes are no longer shown to participants); on-screen demo-code hint removed (B4/D12, restoring the code-entry error rate F6's validation plan measures); **S7 defer path rendered** ("Maybe later" → reachable guest home, closing the FR-09 hard dead-end, C5); `:focus-visible`, `prefers-reduced-motion` and non-print `@media` added (C6 — the G4/G5/G6 gate declarations are now honest); **calibration made real** (tasks keyed by level band, so an Advanced learner receives a genuinely harder item under a now-truthful "Calibrated to:" chip — closes C7/FR-06 and the false-negative risk that made the placement surface decorative); **guide character deferred** per FR-03 (Ed intro + bridge screens removed, intake mascots dropped — ~3 taps saved and the F8 confound removed, C8); **sign-in data-loss fixed** (guest coins/progress preserved instead of zeroed, C9); **merge can now fail** (`taken@…` → "already has an account / sign in to merge", restoring the required S7 conflict state, C10/FR-10); **speaking win made honest** (the 2.6s timer that auto-asserted "You said it" replaced by a self-attested "Done — I read it" tap, so a silent learner is never told they spoke — D13, with FR-13's no-ML discipline intact); dead goal-fabrication code removed (D15).
  **Still open on v2:** it remains **ungated** — no Principal Designer Mode T pass (the review's primary *process* finding stands); the **organisation and product names are intentionally retained** by explicit user decision (2026-07-15), so v2 is for **private/internal use only and must not be shared externally** without genericization (B1/B2 consciously accepted, not fixed); the SPEC's **XP** currency is still rendered as the invented **"coins"**; finding 19 (coded learners hardcoded to "Starting out") is deferred with the shared-device cohort gap; the artifact is still ~6 MB. **v1 ([bd9793ec](https://claude.ai/code/artifact/bd9793ec-c320-4fc2-b1d2-473e35674f4f)) remains the logged canonical prototype pending the v1-vs-v2 decision.**
- 2026-07-15 — **`SPEC.md` updated to reconcile with the F1–F12 review** (`/draft-spec` over the existing spec). FR-14 (Humanizing) → **Could / post-MVP A/B** (Conditional; white-glove out of scope); FR-15 rewritten as **"Contextual-first (no front-loaded tutorial)"** → **Should**, in-MVP (the in-scope half of F12); new **FR-16 (Contextual education engine — checklist + tooltip tours)** → **Won't (this MVP)**, deferred to a post-activation workstream (the No-Go half of F12). Header / MoSCoW intro / traceability matrix / §7 updated to match. Now **16 FRs, 8 screens**. Principal Designer **Mode S: ready** (2 cosmetic polish notes applied — FR-14↔S7 matrix wording, FR-15 cross-cutting annotation). No new captures embedded; FR-14/15/16 cite public teardowns (no PII).
- 2026-07-17 — **Post-closure pattern extraction & sync (`/close-research`).** Principal Designer (`Mode P`) extracted and merged the post-closure `F11 Humanizing touches` and `F12 Contextual just-in-time education` patterns along with our newly codified `Three-Stage UX Sequencing Architecture` directly into `research/PATTERNS.md`.
