# Roadmap

Next-step options for the workspace. Last reconciled **2026-07-27**.

- **PRs #4 and #5:** Both **merged into `main`** (`#4` = `b06a393`, `#5` = `25be809`). The type-aware spine, the **multiple-active-studies** model, and the **peer-review debate** rework are all upstream in `main`.
- **Current Workspace State:**
  - **Working tree:** clean. The legacy `prototype/...` deletions were staged and committed on 2026-07-17.
  - **Active research studies:** none — `.claude/.active-research` is empty. Eleven studies are closed/archived (see `BOARD.md`); the most recent, `2026-07-20-unified-onboarding-synthesis-and-patterns`, closed 2026-07-24.
  - **`litreview` research type — shipped.** `/gather-evidence` exists as both a command and a skill, `litreview` branches through `CLAUDE.md`, `GEMINI.md`, and `/synth-findings`, and the type has been exercised end-to-end by the `2026-07-20` study. The `2026-07-16` study remains typed `benchmark`; it closed before the type existed and is not worth re-typing.
  - **Design-system foundation — on branch.** `feat/rnd-workspace-design-system` carries `ui-library/`, `/sync-tokens`, and `check-prototype.ps1` (Phase 1 of `docs/superpowers/specs/2026-07-26-rnd-workspace-design.md`). Not yet merged to `main`.

## Shipped (the type-aware-spine chapter — done)
- **PR #4 Merged into `main`** — Full expansion of the UX-research workspace including the type-aware research spine, `/draft-spec`, `/design-prototype` workflow, benchmark analysis lenses, and published onboarding benchmark (`2026-07-13`).
- **Type-aware research spine** — one lifecycle (create → design/capture → synthesize
  → review → close → publish) branching on `--type` (`benchmark`, `usability`).
- **Pattern library** (2026-07-13) — `research/PATTERNS.md`, grown by the Principal
  Designer (Mode P) on `/close-research`.
- **Research board** (2026-07-13) — `BOARD.md` + `/research-board`.
- **Benchmark analysis lenses** (2026-07-13) — `/heuristic-eval`, `/a11y-audit`,
  `/extract-tokens`.
- **`/draft-spec`** (2026-07-14) — build-ready `SPEC.md` off a reviewed synthesis;
  Principal Designer **Mode S**.
- **`/design-prototype`** (2026-07-14) — clickable HTML prototype published as a
  claude.ai Artifact, audited against the design gates; Principal Designer **Mode T**.
  `--fidelity lo|hi` + à-la-carte `--gate`.
- **Onboarding & activation benchmark study** (2026-07-15) — 5-platform benchmark
  published to GitHub (PII gate passed on all 38 captures).

### The engine chapter (PR #5, merged 2026-07-17)
- **Multiple concurrent active studies** — two-layer model: a multi-line
  `.claude/.active-research` registry + per-terminal
  `.claude/.current-research/<session-id>` bindings, resolved by the shared rule in
  `.claude/references/active-research.md`; new **`/focus-research`**. Retires the
  `.active-research-2` stopgap and ends the BOARD/pointer drift.
- **Peer-review debate** — `/review-research` becomes a moderated debate
  (Skeptic / Domain Expert / Evidence Auditor, Principal Researcher **Mode C**) that
  strengthens findings and records a `## Peer Review` section. The stakeholder review
  (PM / Tech Lead / Head of Product) moves to `/draft-spec`, whose hard gate now accepts
  `## Peer Review` (or legacy `## Agent Review`).

### The litreview chapter (shipped 2026-07-17 → 2026-07-24)
- **`litreview` research type** — `/gather-evidence` runs the `deep-research` harness
  over an approved `PLAN.md` and writes a verified `evidence.md` + `sources.md`
  (confirmed claims with confidence labels and `[S#]` IDs; refuted claims quarantined).
  `/synth-findings` gained the themes → design-implications template.
- **Exercised end to end** — `research/2026-07-20-unified-onboarding-synthesis-and-patterns`
  (typed `litreview`) ran plan → gather → synthesize → peer review → close, and fed
  `PATTERNS.md` with evidence-based design principles rather than observed UI patterns.

### The design-system chapter (Phase 1, on `feat/rnd-workspace-design-system`)
- **`ui-library/`** — production tokens and component CSS synced verbatim from the
  Solve Education repo: `tokens.css` (166 custom properties), `components.css`
  (239 class selectors), `tokens.json`, plus hand-written `COMPONENTS.md` (42 components:
  4 ported, 19 CSS-only, 19 not yet ported) and a seeded `behaviors.js`.
- **`/sync-tokens [--check] [--ref <branch|sha>]`** — one-directional marker-based
  extraction that scrubs internal identifiers before writing, records provenance, and
  exits non-zero on any drift from source.
- **`.claude/scripts/check-prototype.ps1`** — local ADR-0003 gate (no external hosts,
  no raw styles, no undefined custom properties, no unknown classes, overlay rule).
- **`.claude/references/design-system.md`** — the sync contract and disclosure boundary.

---

## North star — from "research workspace" to **R&D Toolkit**

Today the toolkit is strong on the *back half* of the research arc: **secondary
research** (benchmarking), **evaluative** primary-research planning (usability =
testing something that exists), and **design outputs** (brief / spec / prototype).

The next chapter widens it to a **portable R&D Toolkit** covering the full arc —
**discover → synthesize → design → validate** — that works from *your own data*, not
only observed products, and installs into any project as a plugin. Themes A and B below
map the active ideas; theme C is complementary leverage.

> **Set aside:** a standalone user-flow / IA drafter (an earlier idea) is **not**
> planned — `/draft-spec` already emits both a Mermaid user flow and an IA, so a
> separate drafter would duplicate that source of truth.

## A. Portability & packaging *(user idea 1 — the enabler)*

Repackage the workspace as an installable **Claude Code plugin** ("R&D Toolkit").
The real work is **separating the engine from the content**:

- **Engine (ships in the plugin):** `.claude/commands/`, `.agents/skills/`,
  `.claude/personas/`, `.claude/scripts/`, `.claude/references/`, and the CLAUDE.md /
  GEMINI.md operating guides.
- **Content (stays in the consuming project):** `research/`, `.active-research`,
  `BOARD.md`, `research/PATTERNS.md` — per-project state, never bundled.
- Add a plugin/marketplace **manifest**, semantic **versioning**, and per-`--type`
  **scaffold templates** so `/new-research` works in a fresh project with no research
  history.
- Decide the **rename/scope**: "R&D Toolkit" only earns the name if it spans product /
  market / technical R&D, not just UX. Keep the UX-designer voice as the default
  persona, but make the guardrails and personas configurable per install.

*Do this split first — every capability below then ships cleanly and installs anywhere.*

## B. Primary-research expansion *(user idea 3 + the generative gap)*

Fill the *front half* of the arc. Surveys and A/B tests are already stubbed as planned
`--type`s; formalize them and add generative + data capabilities:

- **`survey` type** — `/plan-survey` instrument (non-leading items, scale design,
  screening/branching, target-n) + a survey-synthesis template. Principal Researcher
  methodology gate, like `/plan-usability`.
- **`abtest` type** — `/plan-abtest`: hypothesis, variants, **primary vs guardrail
  metrics**, a real **power / sample-size / duration** calc, and a read-out template.
- **`/plan-interview`** *(new — closes the biggest gap)* — a generative discovery
  interview guide. The toolkit can plan *evaluative* research (usability) but nothing
  *generative*; this is the missing front door.
- **`/synth-data`** *(user idea 3c — highest-leverage new capability)* — synthesize
  from *raw data the user brings*, not captures:
  - **Quantitative** — ingest CSV / event logs / survey exports; via **pandas** compute
    funnels, cohorts, drop-off, significance → an evidence-graded synthesis.
  - **Qualitative** — interview / transcript synthesis: thematic coding, affinity
    clustering, verbatim evidence (pseudonymized).
  - Strong PII posture: pseudonymize participants (P01…), redact identifiers on ingest,
    keep raw data in the gitignored working dir — same guardrail as capture PII.
- **Persona / JTBD synthesis** *(new)* — derive personas and jobs-to-be-done from that
  primary data as a first-class synthesis output.

## C. Compounding knowledge & loop closure *(complementary leverage)*

- **Instrumentation planner** *(new candidate)* — turn each synthesis's "how to
  validate" field into a concrete event / funnel / metric measurement plan.
- **Cross-study search / index** — semantic search over every `SYNTHESIS.md` +
  `PATTERNS.md`, so accumulated research compounds instead of scattering.
- **Close the design→test loop** — run a **usability study on the `/design-prototype`
  output itself** (the generated prototype becomes the study stimulus): research →
  design → test → iterate, entirely inside the toolkit.
- **Competitive-matrix lens** *(candidate)* — a multi-competitor positioning / feature
  matrix, broader than the current single-feature benchmark teardown.
- **Unified report export** *(candidate)* — one deliverable combining synthesis +
  lenses + spec for a stakeholder handoff.

---

## Current Diagnostics & Architectural Suggestions (2026-07-16 Review)

From our workspace audit on 2026-07-16, four immediate technical debt and architectural stabilization items were identified:

1. **Multiple-Active Study Support & `BOARD.md` Drift:** ✅ *Resolved 2026-07-16; merged to `main` via PR #5 (`25be809`) on 2026-07-17.*
   - The workspace now formally supports several active studies via a two-layer model — a multi-line `.claude/.active-research` **registry** plus per-terminal `.claude/.current-research/<session-id>` bindings, resolved by the shared rule in `.claude/references/active-research.md`. The stopgap `.claude/.active-research-2` pointer is retired and both studies are registered cleanly. See `docs/superpowers/specs/2026-07-16-multiple-active-research-design.md`.
2. **Complete the `litreview` Research Type Implementation:** ✅ *Resolved 2026-07-17; exercised end-to-end 2026-07-24.*
   - `/gather-evidence` shipped as both `.claude/commands/gather-evidence.md` and `.agents/skills/gather-evidence/SKILL.md`; `litreview` branch logic landed in `CLAUDE.md`, `GEMINI.md`, and `/synth-findings`. The `2026-07-20-unified-onboarding-synthesis-and-patterns` study ran the full type. The `2026-07-16` study stays typed `benchmark` — it closed before the type existed, and re-typing a closed study would rewrite the record rather than reflect it.
3. **Clean Up Working Tree & Stale Prototype Artifacts:** ✅ *Resolved 2026-07-17 (deletions), 2026-07-27 (tracked scratch).*
   - The 15 `prototype/...` deletions were staged and committed, and `design/` was tracked. On 2026-07-27 two further batches of committed cruft were untracked and gitignored: `__pycache__/*.pyc` and the per-task subagent scratch under `docs/superpowers/plans/task-*-{brief,report,review.patch}`.
4. **Accelerate Theme A (Engine vs. Content Decoupling):**
   - As more study types and studies accumulate, the coupling between core tooling (`.claude/`, `.agents/`) and data (`research/`) creates friction.
   - **Recommendation:** Prioritize extracting the R&D Toolkit engine into a portable plugin to allow fresh project installs without historical research baggage.

---

## Near-term (independent of the big themes)
- ~~**Complete `litreview` & resolve active-study collision**~~ (done 2026-07-17; exercised 2026-07-24)
- ~~**Stage/commit working tree cleanups** — remove stale `prototype/...` files and track `design/ai-literacy-app/` specs.~~ (done 2026-07-17)
- **Land Phase 2 of the design spec** — the PRD lifecycle (`/new-design`, `/draft-prd`,
  board integration, persona updates). Spec §6 sequenced the repo rename *after* Phase 2,
  but it was executed early (2026-07-26, commit `1584f3c`) and all four moves are done:
  repo renamed, folder renamed, `README.md` updated, memory copied to
  `~/.claude/projects/C--rnd-workspace/`. Phase 2's doc-rewrite scope also shrank on
  2026-07-27, when `CLAUDE.md` / `GEMINI.md` / `README.md` were brought up to date with
  the litreview type and the design system.
- **Migrate the existing prototypes onto `ui-library/` (Phase 3)** — today neither
  `design/onboarding-solve-edu/standalone.html` nor the two `design/ai-literacy-app/`
  HTML files passes `check-prototype.ps1`, and `design/ai-literacy-app/tokens.css` is a
  parallel hand-authored token set rather than a `tokens.overlay.css`. The gate is
  built but currently guards nothing that exists.
- **Run a *real* usability study** — the one lifecycle step never exercised for real
  (fielding needs live participants): `/new-research … --type usability` →
  `/plan-usability` → field externally (P01…) → `/synth-findings` → `/review-research`
  → `/close-research`.
- **Run `/design-prototype`** against the onboarding study to close the
  research → prototype loop for the first time.

## Recommended sequence
1. ~~**Stabilize & Clean Up**~~ (done) — multi-active model shipped, `prototype/` deletions staged, `design/` tracked, `/gather-evidence` built and exercised.
2. **Finish the design chapter (`Immediate`):** land Phase 2 (PRD lifecycle + doc rewrites), then Phase 3 (migrate the two existing prototypes onto `ui-library/` so `check-prototype.ps1` guards something real), then the rename.
3. **Land Theme A (Engine vs. Content Decoupling):** Extract `.claude/` and `.agents/` into a portable R&D Toolkit plugin so fresh projects don't carry previous study data (`research/`). Note this now competes with the design half — spec §7 defers Theme A to a separate toolkit repo.
4. **Expand Capability by Demand (Theme B):** Build **`/synth-data`** if real quantitative/qualitative data is waiting, or **`/plan-interview` + survey/abtest** to open generative discovery research.
5. **Exercise End-to-End on a Real Study:** Run a full usability study fielding or data synthesis pass through the new toolkit.
