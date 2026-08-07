# High-Impact Research Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish Dual-Track Workflow Triage and elevate Research Quality & Peer Review Gates in the workspace to eliminate low-leverage research outputs (such as simple button changes) and accelerate execution for small UI tweaks.

**Architecture:** Update system rules in `CLAUDE.md`, contract rules in `coverage-contract.md`, review persona prompts in `.claude/personas/`, and workflow command scripts in `.claude/commands/` so that small tasks bypass research entirely and deep research mandates structural UX findings.

**Tech Stack:** Markdown contracts, Claude persona prompts, PowerShell sync scripts.

## Global Constraints

- Preserve all existing file structure standards and harness sync conventions (`sync-agent-skills.ps1`).
- Maintain exact backwards compatibility with active research registration and design project resolution.
- Never weaken existing safety/PII or sync guardrails in `CLAUDE.md`.

---

### Task 1: Update Core Workspace Guidelines & Triage Rules in `CLAUDE.md`

**Files:**
- Modify: `CLAUDE.md`

**Interfaces:**
- Consumes: Design Spec `docs/superpowers/specs/2026-08-07-high-impact-research-workflow-design.md`
- Produces: Dual-Track triage rules and High-Impact research mandate in workspace documentation.

- [ ] **Step 1: Inspect target sections in `CLAUDE.md`**

View `CLAUDE.md` around "Your role" (lines 23-38) and "How research is organized" (lines 84-138).

- [ ] **Step 2: Edit `CLAUDE.md` to add Dual-Track Triage & Strategic R&D Mandate**

In `CLAUDE.md`, update "Your role" to state that standalone research findings must yield structural UX overhauls, and update "How research is organized" to explicitly define the **Direct Design Track (`design/<project>/`)** (which bypasses `research/` for button/copy/styling tweaks) vs the **Strategic R&D Track (`research/<study>/`)**.

- [ ] **Step 3: Verify changes in `CLAUDE.md`**

Ensure formatting is intact and all rules read clearly.

- [ ] **Step 4: Commit changes**

```bash
git add CLAUDE.md
git commit -m "docs: add dual-track triage and high-impact research mandate to CLAUDE.md"
```

---

### Task 2: Elevate Finding Requirements & No-Go Verdict in `coverage-contract.md`

**Files:**
- Modify: `.claude/references/coverage-contract.md`

**Interfaces:**
- Consumes: Section 3 of `docs/superpowers/specs/2026-08-07-high-impact-research-workflow-design.md`
- Produces: Formal Structural Lever criteria for $F_1..F_n$ findings and `"No-Go: Low Research Leverage"` definition.

- [ ] **Step 1: Inspect `.claude/references/coverage-contract.md`**

Read the finding declaration and synthesis gate rules in `coverage-contract.md`.

- [ ] **Step 2: Add Structural UX Lever rule and No-Go definition**

Add requirements that every finding $F_1..F_n$ MUST map to at least one Structural Lever (Flow Topology, Cognitive Load, Time-to-Aha, Core Interaction Paradigm). Prohibit standalone surface-level button/color tweaks. Add the specification for `"No-Go: Low Research Leverage"`.

- [ ] **Step 3: Commit changes**

```bash
git add .claude/references/coverage-contract.md
git commit -m "docs(contract): mandate structural levers and No-Go leverage verdict in coverage-contract.md"
```

---

### Task 3: Update Review Persona Prompts (`principal-researcher`, `domain-expert`, `evidence-auditor`)

**Files:**
- Modify: `.claude/personas/principal-researcher.md`
- Modify: `.claude/personas/domain-expert.md`
- Modify: `.claude/personas/evidence-auditor.md`

**Interfaces:**
- Consumes: Section 4 of `docs/superpowers/specs/2026-08-07-high-impact-research-workflow-design.md`
- Produces: Persona review instructions that evaluate leverage and reject trivial findings.

- [ ] **Step 1: Update `principal-researcher.md`**

Inject the **Impact & Leverage Gate** into Mode A (Synthesis Review) and Mode C (Debate Moderation). Mandate rejection of low-leverage research findings and enforcement of the No-Go verdict when leverage is lacking.

- [ ] **Step 2: Update `domain-expert.md` and `evidence-auditor.md`**

Add checks requiring reviewers to challenge trivial button/copy recommendations and ensure findings focus on structural product levers.

- [ ] **Step 3: Commit changes**

```bash
git add .claude/personas/principal-researcher.md .claude/personas/domain-expert.md .claude/personas/evidence-auditor.md
git commit -m "feat(personas): add leverage check and structural finding mandate to review personas"
```

---

### Task 4: Update Workflow Commands (`synth-findings` & `review-research`) and Sync Harness Skills

**Files:**
- Modify: `.claude/commands/synth-findings.md`
- Modify: `.claude/commands/review-research.md`
- Run: `.claude/scripts/sync-agent-skills.ps1 -Fix`

**Interfaces:**
- Consumes: Updated personas and contracts from Tasks 1-3.
- Produces: Executable workflow commands and synced agent skill stubs.

- [ ] **Step 1: Update `.claude/commands/synth-findings.md`**

Update prompt rules to require structural levers for each feature/finding and add instructions for generating the `"No-Go: Low Research Leverage"` outcome.

- [ ] **Step 2: Update `.claude/commands/review-research.md`**

Update execution flow so the Principal Researcher and panel personas explicitly evaluate leverage during debate rounds.

- [ ] **Step 3: Run sync-agent-skills.ps1 -Fix to ensure `.agents/skills/` are updated**

Run: `powershell -NoProfile -File .claude/scripts/sync-agent-skills.ps1 -Fix`

- [ ] **Step 4: Verify sync script output**

Expected: Clean exit code 0, all skills verified.

- [ ] **Step 5: Commit changes**

```bash
git add .claude/commands/ .agents/skills/
git commit -m "feat(commands): integrate high-impact leverage gates into synth-findings and review-research commands"
```
