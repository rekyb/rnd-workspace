# Gemini Integration Guide (Antigravity CLI)

This is a UX-research and design workspace. It was built for Claude Code, whose workflow
commands live in `.claude/commands/`, and it is registered to run under Gemini in the
Antigravity CLI as well.

**`CLAUDE.md` is the authoritative contract.** It carries what this workspace is, the
guardrails, how research and design are organized, the research types, the capture and
synthesis standards, and the tooling notes. Read it first. Despite the filename it is not
Claude-specific: every rule in it binds any agent operating here, and there is no second
copy of it to consult.

This file covers only what differs when the agent is Gemini. It is short on purpose. It
used to restate all thirteen workflow areas in parallel prose, and that copy fell behind
the workspace it described — by the time the coverage gates landed it referenced none of
them.

---

## How a workflow runs

Every workflow is registered as a skill at `.agents/skills/<name>/SKILL.md`. The stub
carries the frontmatter you match intent against, `name` and `description`, and points at
the body.

**The body lives in `.claude/commands/<name>.md`.** There is exactly one copy of each
workflow and both harnesses read it. Read it and follow it exactly.

Reading a `.claude/commands/` file as a skill:

- `$ARGUMENTS` means the arguments the skill was invoked with.
- A slashed reference such as `/draft-prd` means the skill `draft-prd`.
- Paths under `.claude/references/` and `.claude/personas/` are shared by every harness.
  Read them where they are; there is no second copy.

The `.claude/` prefix is a directory name, not a boundary. The references it holds
(`active-research.md`, `coverage-contract.md`, `design-projects.md`, `design-gates.md`,
`design-system.md`, `mobbin-sourcing.md`, `prompt-vocabulary.md`) and the eight review
personas are the shared spine of this workspace, and the skills have always cited them by
that path.

## The one behavioural difference

`/export-prototype --artifact` publishes to `claude.ai/code/artifacts` through the
Artifact tool, which is a Claude-specific surface. Where that tool is unavailable, hand
over the built `standalone.html` locally and say so explicitly in the report. Everything
ahead of that step is unchanged: the build, the `check-prototype.ps1` gate, the re-check
for internal specifics and un-redacted PII, and the explicit confirmation naming what will
publish.

No other workflow behaves differently. Where a command names a tool you do not have, say
which step you could not run rather than substituting something that looks close.

## Registration

Nineteen commands, nineteen stubs, checked by a script rather than by hand:

```bash
powershell -NoProfile -File .claude/scripts/sync-agent-skills.ps1          # check
powershell -NoProfile -File .claude/scripts/sync-agent-skills.ps1 -Fix     # regenerate
```

Check mode exits non-zero when a stub is missing, hand-edited, or left behind by a deleted
command. Adding a workflow means adding `.claude/commands/<name>.md` and running `-Fix`.

Do not paste a workflow body back into a stub. The duplication is what broke this
integration the first time, and `-Fix` will overwrite it.

## Status of this integration

It is registered and the registration is verified by the script above. It has not been
exercised against a live Gemini run from this repository, so treat the intent-matching
behaviour described here as the intended design rather than an observed result. If you are
the first Gemini to work here and something does not resolve as written, that is worth
reporting rather than working around.
