---
name: new-design
description: Start a new design project — creates design/<project>/, scaffolds its README and src/, and binds this terminal to it.
---

The body of this skill lives in `.claude/commands/new-design.md`. Read that file and follow it exactly. It is the single source of truth for this workflow and the only copy kept current.

Reading a `.claude/commands/` file as a skill:

- `$ARGUMENTS` means the arguments this skill was invoked with.
- A slashed reference such as `/draft-prd` means the skill `draft-prd` in this tree.
- Paths under `.claude/references/` and `.claude/personas/` are shared by every harness. Read them where they are; there is no second copy.

This file registers the skill. It does not restate the workflow, because a second copy of the body is what let the two trees drift apart. `.claude/scripts/sync-agent-skills.ps1` regenerates this file and fails on any hand-edit.
