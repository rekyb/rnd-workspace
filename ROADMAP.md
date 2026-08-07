# Roadmap

Next-step options for the workspace. Last reconciled **2026-08-07**.

- **Current Workspace State:**
  - **Dual-Track Operational Model — Shipped:** Strategic R&D Track (`research/`) and Direct Design Track (`design/`) are fully integrated.
  - **19 Commands Registered & Synced:** All workflow commands, persona specs, and references are synchronized between Claude Code and Google Antigravity (`agy`).
  - **PRD Shape-Up Lifecycle — Shipped:** `/draft-prd` (17-section PRD with vertical slices & 3-persona stakeholder review) and `/design-prototype` (component-driven prototype authoring against `ui-library/`) are live.
  - **README & Architecture Flowchart — Updated:** `README.md` updated with an end-to-end Mermaid workflow diagram.
  - **Active research studies:** None — `.claude/.active-research` is empty. Thirteen studies are closed/archived (see `BOARD.md`).

---

## 🚢 Shipped

### The Dual-Track & PRD Chapter (Shipped 2026-08-07)
- **Shape-Up PRD Lifecycle (`/draft-prd`)** — 17-section decision doc featuring vertical slices, Findings Coverage table (§2.1), solution shape Mermaid flowcharts, and Given/When/Then acceptance criteria per slice.
- **3-Persona Stakeholder Review** — Integrated PM (soundness), Tech Lead (build effort/risk), and Head of Product (Go/No-Go call) review chain into `/draft-prd`.
- **Principal Designer Quality Gates (Modes S & T)** — Hard review gates for PRD traceability (Mode S) and prototype source fidelity (Mode T).
- **Multi-Harness Skill Registration** — PowerShell synchronization script (`sync-agent-skills.ps1`) ensuring 100% parity between `.claude/commands/` and `.agents/skills/` stubs across Claude and Gemini harnesses.
- **Visual README Flowchart** — Added Mermaid diagram and updated sitemap in `README.md`.

### The Litreview & Evidence Chapter (Shipped 2026-07-24)
- **`litreview` research type** — `/gather-evidence` runs the `deep-research` harness over an approved `PLAN.md` and writes a verified `evidence.md` + `sources.md`.
- **Exercised end to end** — `research/2026-07-20-unified-onboarding-synthesis-and-patterns` ran plan → gather → synthesize → peer review → close, populating `PATTERNS.md`.

### The Engine & Multi-Active Research Chapter (Shipped 2026-07-17)
- **Multiple concurrent active studies** — Two-layer model: `.claude/.active-research` registry + per-terminal `.claude/.current-research/<session-id>` bindings, resolved by shared rules.
- **Peer-review debate** — `/review-research` as a 3-persona moderated debate (Skeptic / Domain Expert / Evidence Auditor, moderated by Principal Researcher).

### The Design System Foundation (Shipped 2026-07-26)
- **`ui-library/`** — Production tokens and component CSS synced verbatim from upstream: `tokens.css`, `components.css`, `tokens.json`, `COMPONENTS.md`, and `behaviors.js`.
- **`/sync-tokens [--check]`** — Token refresh with identifier scrubbing and drift detection.
- **Prototype Gate (`check-prototype.ps1`)** — Verifies zero raw styles, valid token variables, component class contracts, and PII lints before prototype export.

---

## 🎯 North Star — From Workspace to Portable **R&D Toolkit**

The current workspace excels at desk research (benchmarking), evaluative planning (usability), PRD drafting, and prototype generation. 

The next milestone expands this codebase into a **portable R&D Toolkit** that can be installed into any project and process raw user data.

```
       DISCOVER               SYNTHESIZE              DECIDE & MAKE               VALIDATE
┌────────────────────┐    ┌─────────────────┐    ┌─────────────────────┐    ┌──────────────────┐
│ Benchmarking /     │ ──►│ SYNTHESIS.md    │ ──►│ PRD.md & Slices     │ ──►│ Standalone HTML  │
│ Primary Data       │    │ (Peer Reviewed) │    │ (Stakeholder Vetted)│    │ Interactive Test │
└────────────────────┘    └─────────────────┘    └─────────────────────┘    └──────────────────┘
```

---

## 🚀 Future Milestones

### A. Portability & Packaging (Plugin Architecture)
- **Decouple Engine from Content**:
  - **Engine (Plugin Bundle):** `.claude/commands/`, `.agents/skills/`, `.claude/personas/`, `.claude/references/`, `.claude/scripts/`.
  - **Content (Project Local):** `research/`, `design/`, `BOARD.md`, `PATTERNS.md`.
- **Package as Plugin**: Create manifest and scaffolding templates for fresh project initialization (`/new-research` in any codebase).

### B. Primary Data Synthesis & Generative Research
- **`/synth-data` (Raw Data Synthesis)**: Ingest CSVs, event analytics, and interview transcripts to generate evidence-graded syntheses with thematic coding.
- **`survey` & `abtest` Types**:
  - `/plan-survey` — Questionnaire design, non-leading items, scale design, and target-N.
  - `/plan-abtest` — Variant design, primary/guardrail metrics, and statistical sample-size calculator.
- **`/plan-interview`**: Discovery interview instrument planner for generative research.

### C. Compounding Knowledge & Closed-Loop Testing
- **Cross-Study Search & Index**: Semantic search over `SYNTHESIS.md` and `PATTERNS.md` for historical evidence lookup.
- **Design-to-Test Loop**: Field usability studies (`--type usability`) directly against generated `/design-prototype` artifacts.

---

## 📋 Recommended Execution Sequence

1. **Exercise End-to-End Usability Study**: Field a real usability test (`/new-research --type usability` → `/plan-usability` → `/synth-findings`) on a built prototype.
2. **Land Theme A (Plugin Packaging)**: Extract core commands, personas, and scripts into a portable plugin manifest.
3. **Build `/synth-data` (Theme B)**: Add quantitative (CSV/event logs) and qualitative transcript synthesis.
