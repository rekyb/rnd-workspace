---
name: design-prototype
description: Author a design project's clickable prototype as multi-file source in src/, built from its PRD.md against the shared ui-library/ design system. Gated by the Principal Designer (Mode T); shipped by /export-prototype.
---

The body of this skill lives in `.claude/commands/design-prototype.md`. Read that file and follow it exactly. It is the single source of truth for this workflow and the only copy kept current.

Reading a `.claude/commands/` file as a skill:

- `$ARGUMENTS` means the arguments this skill was invoked with.
- A slashed reference such as `/draft-prd` means the skill `draft-prd` in this tree.
- Paths under `.claude/references/` and `.claude/personas/` are shared by every harness. Read them where they are; there is no second copy.

This file registers the skill. It does not restate the workflow, because a second copy of the body is what let the two trees drift apart. `.claude/scripts/sync-agent-skills.ps1` regenerates this file and fails on any hand-edit.
