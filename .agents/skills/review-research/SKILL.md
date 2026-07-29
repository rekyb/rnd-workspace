---
name: review-research
description: Run a research peer-review debate over the active SYNTHESIS.md (Skeptic, Domain Expert, Evidence Auditor, moderated by the Principal Researcher) that strengthens the findings, then on approval records a Peer Review section and applies the agreed strengthenings.
---

The body of this skill lives in `.claude/commands/review-research.md`. Read that file and follow it exactly. It is the single source of truth for this workflow and the only copy kept current.

Reading a `.claude/commands/` file as a skill:

- `$ARGUMENTS` means the arguments this skill was invoked with.
- A slashed reference such as `/draft-prd` means the skill `draft-prd` in this tree.
- Paths under `.claude/references/` and `.claude/personas/` are shared by every harness. Read them where they are; there is no second copy.

This file registers the skill. It does not restate the workflow, because a second copy of the body is what let the two trees drift apart. `.claude/scripts/sync-agent-skills.ps1` regenerates this file and fails on any hand-edit.
