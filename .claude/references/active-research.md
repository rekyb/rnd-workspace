# Active-research resolution rule (canonical)

This is the single source of truth for how workflow commands decide **which research
study** to act on. Commands reference this file instead of re-inlining the logic.

The workspace supports **several active studies at once**, worked in parallel across
different terminals. Tracking is two layers:

## Layer 1 — the registry (shared, committed)

`.claude/.active-research` is the **registry**: a list of active study folder paths, one
per line, no trailing slash.

- One line = a single active study (behaves exactly like the old single-pointer model).
- Zero lines / empty file = no active research.
- It is committed to git. `BOARD.md`'s **Active** table is derived from it (one row per line).

## Layer 2 — the per-terminal current binding (local, not committed)

`.claude/.current-research/` is a **gitignored** directory holding one file per terminal:

- **Filename:** the terminal's session id (see below).
- **Contents:** exactly one study folder path, which must be a line in the registry.

This is how a terminal remembers which study it is focused on without colliding with other
terminals. It survives context compaction and `/clear`.

### Deriving the session id

Every session is given a scratchpad path shaped like:

```
…\<temp>\claude\<project-slug>\<SESSION-UUID>\scratchpad
```

The `<SESSION-UUID>` directory segment is the session id. Read it off your own scratchpad
path; create `.claude/.current-research/` if it does not exist before writing a binding.

## The resolution rule

When a command needs a target study, resolve it in this priority order:

1. **Explicit `[folder]` argument** → use it.
   - Spine commands (`synth-findings`, `review-research`, `brief-feature`,
     `publish-research`, `plan-usability`): if the folder is not in the registry, warn — it
     may be a closed study and this may be a mistake.
   - `draft-prd` is **not** on this list: it resolves a *design project*, not a study, and
     follows `.claude/references/design-projects.md` instead. It reads studies only through
     the project's `Informed by:` header.
   - Retrospective lens commands (`heuristic-eval`, `a11y-audit`, `extract-tokens`) may
     legitimately target a **closed** study, so a non-registry folder is allowed there.
2. **This terminal's binding** — read `.claude/.current-research/<session-id>`. If it exists
   and its path is still a line in the registry → use it.
3. **Sole registry entry** — if the registry has exactly one line → use it, and write that
   path to this terminal's binding (adopt it).
4. **Otherwise** (zero or several active, no argument, no usable binding) → **STOP**, print
   the active set (the registry lines), and ask the user which study to act on.
   - Exception: `new-research` treats zero active as normal and just proceeds.

### Stale bindings

A binding file whose path is **not** in the registry (its study was closed or removed) is
**ignored** by step 2 and may be pruned. `close-research` and `research-board` prune stale
bindings opportunistically.

## How the mutating commands touch each layer

- **`new-research`** — appends the new study to the registry and writes this terminal's
  binding to it. Does not block on other active studies.
- **`focus-research <folder>`** — writes this terminal's binding to an existing registry
  study (the explicit re-bind).
- **`close-research`** — removes the closed study's line from the registry, deletes this
  terminal's binding if it pointed there, and prunes other now-stale bindings.
