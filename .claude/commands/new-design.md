---
description: Start a new design project — creates design/<project>/, scaffolds its README and src/, and binds this terminal to it.
argument-hint: <project name> [--informed-by research/<study> ...]
---

You are starting a new **design project** — the MAKE half of the workspace, downstream
of research. Parse `$ARGUMENTS` for the project name and any `--informed-by` flags.

A design project is **not** a study. A study is point-in-time, so it is dated and
closed; a design project is long-lived and iterates, so it takes a plain slug and a
mutable status. The full contract is `.claude/references/design-projects.md` — read it
before deviating from anything below.

This command creates the **container only**. It does not write `PRD.md` (that is
`/draft-prd`) and it does not write prototype source (that is `/design-prototype`).
Keeping them separate means a project can exist while its PRD is still being argued
about, which is the normal case.

Follow these steps exactly:

1. **Derive the slug.** Build it defensively from the project name (after stripping the
   flags), using the same rules as `/new-research`:
   - lowercase everything;
   - strip quotes, apostrophes, brackets, and other punctuation entirely (don't turn
     them into hyphens);
   - replace any run of spaces/remaining separators with a single hyphen;
   - collapse repeated hyphens and trim leading/trailing hyphens;
   - keep it concise — the meaningful head of the name, not a whole sentence.

   **No date prefix.** Folder path = `design/<slug>/`.

2. **Refuse to clobber.** If `design/<slug>/` already exists, STOP and tell the user.
   If they meant to work on the existing one, naming it explicitly on the next command
   (`/draft-prd <slug>`) both targets it and re-binds this terminal to it — that is why
   there is no separate focus command. Never merge into an existing project folder.

3. **Establish the problem statement (required).** One or two sentences: what problem
   this project exists to solve, and for whom. This is not the PRD — it is the sentence
   the PRD's §1 TL;DR will later expand. **If it is vague, implicit, or missing, STOP
   and ask the user.** Do not invent it and never leave it as `TBD`.

   Phrase it against `.claude/references/prompt-vocabulary.md`: state the user's **job**
   and the observable friction, not an adjective. Its anti-keyword table is the test — a
   problem statement built on "the experience is not intuitive" or "the flow should be
   seamless" cannot be falsified, so it cannot be designed against. Push it to something
   that could fail: which task, for whom, failing how.

4. **Establish `Informed by:` — and be honest about it.** Collect the study folders
   this project draws on, from `--informed-by` flags and/or by asking. Then:
   - **Validate each one.** The folder must exist under `research/` and contain a
     `SYNTHESIS.md`. A study with no synthesis is not yet usable as evidence — warn and
     let the user decide whether to list it anyway.
   - **Zero studies is allowed.** Research is optional but never invisible: record
     `none (assumptions labelled in PRD §2)` and tell the user plainly that `/draft-prd`
     will then require §2 to label its claims as assumptions, and that the Principal
     Designer gate fails a PRD that states unevidenced claims as fact.
   - Never list a study the project does not actually draw on to make the header look
     better. That is the same non-fabrication rule the research half runs on.

5. **Scaffold the folder.** Create:
   - `design/<slug>/README.md` — the project brief (template below).
   - `design/<slug>/src/` — empty; prototype source lands here later.
   Do **not** create `PRD.md`, `tokens.overlay.css`, or `build/`. Each appears only when
   something actually needs it: an empty `PRD.md` reads as "there is a PRD" to every
   downstream command and gate, and an empty overlay file invites hand-edits that belong
   in the PRD discussion instead.

6. **Bind this terminal.** Derive your session id from this session's scratchpad path
   (the `<SESSION-UUID>` directory segment), create `.claude/.current-design/` if it
   does not exist, and write `design/<slug>` (no trailing slash) into
   `.claude/.current-design/<session-id>`. See `.claude/references/design-projects.md`.

   There is **no registry to append to** — the status lives in the project's own
   `README.md` and nowhere else.

7. **Refresh `BOARD.md`.** Re-derive the board's `## Design` table from the
   `design/*/README.md` files exactly as `/research-board` does, and update the
   `_Last updated:_` date. Don't print the whole board here; just keep the file in sync.

8. **Report** to the user: the folder path, the status (`Active`), what it is
   `Informed by:` (or that it starts unevidenced and what that implies), that this
   terminal is now bound to it, and the natural next step — `/draft-prd` to write the
   decision doc.

---

`design/<slug>/README.md` template:

```
# <Project name>

**Status:** Active
**Started:** <YYYY-MM-DD>
**Informed by:** <research/<study>, research/<study>> | none (assumptions labelled in PRD §2)
**Design system:** ui-library/ | independent (<why>)

## Problem

<The one-or-two-sentence problem statement from step 3: what this project solves, and
for whom. The PRD's §1 TL;DR expands this; it does not replace it.>

## Status log

| Date | Entry |
|---|---|
| <YYYY-MM-DD> | Project created. |
```

Notes on the header fields:

- **`Status:`** — `Active` at creation. It becomes `Shipped` or `Archived` by a
  one-line hand-edit to this file; there is deliberately no `/close-design` command.
- **`Informed by:`** — the studies `/draft-prd` will cite in PRD §2. Keep it current: if
  a later study informs the project, add it here as well as in the PRD.
- **`Design system:`** — `ui-library/` unless the project is a genuinely different
  product with a different brand, in which case `independent` plus the reason. See
  `.claude/references/design-system.md`. A project on `ui-library/` may still carry a
  `tokens.overlay.css`, which may redefine an existing token name but never introduce a
  new one.
- **`## Status log`** — the running record. `/draft-prd` and `/design-prototype` append
  a dated row here, the same way the research commands log into a study's `README.md`.
