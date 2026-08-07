# Design Spec: High-Impact Research Rigor & Dual-Track Workflow Overhaul

**Date:** 2026-08-07  
**Status:** Approved  
**Topic:** Overhauling Workspace Research Rigor & Eliminating Low-Leverage Research Output  

---

## 1. Executive Summary & Problem Context

Teammates have expressed concern that research and design studies in this workspace take significant time to execute (completing multi-platform benchmarking, flow recordings, 3-persona peer-review debates, and multi-stage PRD gates) only to yield low-impact design changes, such as minor button tweaks or micro-copy edits.

This design resolves the issue by establishing a **Dual-Track Operational Model** and upgrading **Research Quality & Peer Review Gates**:
1. **Direct Design Track (`design/<project>/`)**: Bypasses the `research/` pipeline entirely for minor UI tweaks, component styling, and layout polish, providing a fast lane for rapid execution.
2. **Strategic R&D Track (`research/<study>/`)**: Reserves deep research exclusively for high-leverage structural/architectural UX problems (Information Architecture, mental models, cognitive load reduction, core flow topology).
3. **Elevated Review & Quality Gates**: Mandates that research findings MUST articulate a structural UX shift or output an explicit `"No-Go: Low Research Leverage"` verdict, rejecting surface-level button/color tweaks at the peer review gate.

---

## 2. Dual-Track Workflow & Triage Architecture

The workspace rules (`CLAUDE.md`) and workflow guidance will explicitly define two operational tracks based on task intent:

```
                      ┌─────────────────────────────────────────┐
                      │             New Task Request            │
                      └────────────────────┬────────────────────┘
                                           │
                        Is this a deep/structural UX question?
                                          / \
                                        /     \
                                 YES  /         \  NO
                                    /             \
                                  ▼                 ▼
             ┌───────────────────────────┐   ┌───────────────────────────┐
             │ Strategic R&D Track       │   │ Direct Design Track       │
             │ (research/YYYY-MM-DD-...) │   │ (design/<project>/)       │
             └─────────────┬─────────────┘   └─────────────┬─────────────┘
                           │                               │
                           ▼                               ▼
             • Benchmark / Lit / Usability    • Bypasses research pipeline
             • Structural UX findings ONLY    • Direct PRD or prototype
             • Gated by Impact Review         • Rapid iteration & gate check
```

### 2.1 Track Definitions

1. **Strategic R&D Track (`research/YYYY-MM-DD-<slug>/`)**
   * **Trigger:** Questions regarding Information Architecture (IA), onboarding flow topology, mental model shifts, cognitive friction reduction, strategic feature choices, or competitive UX paradigms.
   * **Workflow:** `/new-research` $\rightarrow$ Fieldwork/Benchmarking $\rightarrow$ `/synth-findings` $\rightarrow$ `/review-research` $\rightarrow$ `/close-research`.
   * **Constraint:** MUST yield high-leverage structural findings or terminate with a `"No-Go: Low Research Leverage"` verdict.

2. **Direct Design Track (`design/<project>/`)**
   * **Trigger:** Button updates, micro-copy polish, visual hierarchy tweaks, minor layout adjustments, component updates, or known UX bug fixes.
   * **Workflow:** `/new-design <project>` $\rightarrow$ `/draft-prd` (or direct prototype) $\rightarrow$ `/design-prototype` $\rightarrow$ `/export-prototype`.
   * **Fast Lane:** Completely bypasses `research/` folders, `SYNTHESIS.md`, and research peer reviews.

---

## 3. High-Impact Research & Synthesis Contract

Updates will be made to `CLAUDE.md`, `.claude/references/coverage-contract.md`, and the `/synth-findings` template:

### 3.1 Structural UX Levers
Every finding ($F_1..F_n$) in `SYNTHESIS.md` MUST explicitly map to at least one of the four **Structural Levers**:
1. **System Architecture & Flow Topology:** Eliminating unnecessary steps, re-ordering user journeys, changing navigation hierarchies.
2. **Cognitive Load & Mental Models:** Transforming how concepts or progress are presented to reduce learner drop-off.
3. **Value Delivery & Time-to-Aha:** Accelerating first-value friction points in onboarding or core features.
4. **Core Interaction Paradigm:** Re-imagining interaction mechanisms (e.g., replacing multi-page modal forms with inline canvas controls).

### 3.2 Prohibition of Surface-Level Findings
Standalone findings that recommend trivial surface-level UI changes (e.g., "change CTA button color", "increase font size", "rename button label from Submit to Continue") are **strictly prohibited** as research findings. Surface observations may only be included as incidental context within a broader structural finding.

### 3.3 Mandatory "No-Go: Low Research Leverage" Verdict
If benchmarking reveals that existing platforms handle the flow optimally or offer no structural UX leverage, the researcher MUST output an explicit **"No-Go: Low Research Leverage"** verdict in `SYNTHESIS.md`. This halts downstream PRD creation, saving team engineering bandwidth.

---

## 4. Upgraded Peer Review & Quality Gates

### 4.1 Principal Researcher (`.claude/personas/principal-researcher.md`)
* **Impact & Leverage Gate:** During synthesis review (`/synth-findings`) and debate moderation (`/review-research`), the Principal Researcher MUST verify:
  1. *Are all findings structural UX shifts rather than cosmetic tweaks?*
  2. *Are surface-level button/color recommendations rejected or consolidated out of the main findings?*
  3. *Is the readiness verdict set to `No-Go (Low Leverage)` if structural leverage is lacking?*

### 4.2 Peer Review Panel (`evidence-auditor.md`, `domain-expert.md`, `research-skeptic.md`)
* The panel MUST evaluate **product & research leverage** alongside empirical evidence truthfulness, explicitly asking: *"Does this finding justify a full PRD and engineering investment, or is it a low-leverage tweak that should be dropped?"*

### 4.3 Principal Designer (`.claude/personas/principal-designer.md` Mode S)
* During `/draft-prd` review, Mode S will **REJECT** any PRD that cites low-leverage findings or attempts to build a full PRD process for minor button/styling changes.

---

## 5. File Modification Plan

The following workspace files will be updated during implementation:

1. **[`CLAUDE.md`](file:///C:/rnd-workspace/CLAUDE.md)**
   * Document Dual-Track Triage rules under "How research is organized".
   * Add the High-Impact Research Mandate under "Your role" and "Guardrails".

2. **[`.claude/references/coverage-contract.md`](file:///C:/rnd-workspace/.claude/references/coverage-contract.md)**
   * Add Structural UX Lever requirements for valid findings $F_1..F_n$.
   * Define the `"No-Go: Low Research Leverage"` verdict criteria.

3. **[`.claude/personas/principal-researcher.md`](file:///C:/rnd-workspace/.claude/personas/principal-researcher.md)**
   * Inject the Impact & Leverage Gate into Mode A (Synthesis Review) and Mode C (Debate Moderation).

4. **[`.claude/personas/domain-expert.md`](file:///C:/rnd-workspace/.claude/personas/domain-expert.md) & [`.claude/personas/evidence-auditor.md`](file:///C:/rnd-workspace/.claude/personas/evidence-auditor.md)**
   * Update review prompts to evaluate recommendation leverage and reject trivial UI findings.

5. **[`.claude/commands/synth-findings.md`](file:///C:/rnd-workspace/.claude/commands/synth-findings.md)**
   * Update synthesis template instructions to enforce structural finding format and No-Go option.

6. **[`.claude/commands/review-research.md`](file:///C:/rnd-workspace/.claude/commands/review-research.md)**
   * Update execution flow to include leverage evaluation during panel cross-talk.

---

## 6. Self-Review Check

- **Placeholders:** None (all rules, contracts, and file paths are fully defined).
- **Internal Consistency:** Alignment between triage rules, synthesis templates, and review persona gates.
- **Scope:** Directly targets the root cause of team dissatisfaction without adding bloated tool tooling.
- **Ambiguity:** Clear boundary defined between Direct Track (`design/`) and R&D Track (`research/`).
