---
name: close-research
description: Close a research study — verify synthesis exists, extract/merge patterns into PATTERNS.md (type-aware), mark it closed, and remove it from the active registry.
---

Close a research study. This is the official completion step of the research lifecycle: it locks the study, extracts reusable patterns into the workspace pattern library (`PATTERNS.md`), and removes the study from the active registry (`.claude/.active-research`). Other active studies are left untouched.

## Steps

1. **Locate the research.** Resolve which study to close per `.claude/references/active-research.md` (explicit `[folder]` arg, else this terminal's binding, else the sole active study, else ask). If the registry is empty, STOP — there is no active research to close. Read the folder's `README.md` and check its `Type` (`benchmark`, `usability`, or `litreview`).

2. **Verify readiness.**
   - Check that `SYNTHESIS.md` exists inside the research folder. If it does not, STOP and tell the user to run `synth-findings` first (never close an unsynthesized research).
   - Read `SYNTHESIS.md` and check whether it contains a `## Peer Review` section (the peer-review debate from `review-research`), or a legacy `## Agent Review`. If neither is present, warn the user that they are closing research without a recorded review, and ask if they want to proceed anyway or run `review-research` first. Only continue on explicit approval.

3. **Pattern extraction (Principal Designer — Mode P, before closing).** Dispatch the Principal Designer as a subagent (`general-purpose` / `research` or subagent configured with same rules) in **Mode P (pattern extraction)**, handing it `.claude/personas/principal-designer.md`, the study's `SYNTHESIS.md`, and the workspace pattern library `research/PATTERNS.md`. It will extract the reusable design patterns right out of the synthesis (if `Type: benchmark`, `benchmark-observed` patterns; if `Type: usability`, `usability-validated` patterns; if `Type: litreview`, **evidence-based design principles**, not observed UI patterns) and merge them into `PATTERNS.md` — adding new ones and linking back to the closing study on existing ones. It modifies `PATTERNS.md` directly. Tell the user what the Principal Designer extracted / merged.
   - **Tell it the study's per-platform sources (from `PLAN.md`).** Patterns drawn from a Mobbin-sourced platform MUST use **Kind:** `reference-library observed (Mobbin; not first-party captured)` and cite the Mobbin URL — never a `reference/` image path, which is gitignored. Patterns drawn from a Chrome-sourced benchmark platform stay `benchmark-observed`. See `.claude/references/mobbin-sourcing.md`.
   - If `research/PATTERNS.md` does not exist yet, the Principal Designer will create it using the standard pattern library structure.
   - For a **litreview** study, the Principal Designer must **not force UI patterns where there are none** — a litreview study often has no interface to observe. If the synthesis yields no genuine, evidence-grounded principle, it records that plainly and adds nothing to `PATTERNS.md`; it never invents a pattern to fill the slot.

4. **Mark closed.**
   - In `<folder>/README.md`, change `Status: Active` to `Status: Closed` and set `Closed: <YYYY-MM-DD>` (today's date). Add a dated entry to the `## Log` saying the research was closed and patterns extracted into `PATTERNS.md`.
   - **Remove the closed study's line** from `.claude/.active-research`, leaving every other active study's line intact. Then prune per-terminal bindings: delete this terminal's binding if it pointed at the closed study, and remove any file in `.claude/.current-research/` whose path is no longer in the registry. See `.claude/references/active-research.md`.

5. **Refresh the board.** Run the same board-reconciliation logic (`BOARD.md`) as `research-board` does: re-derive `BOARD.md` from the `research/` folders + the updated `.claude/.active-research` registry so the closed study moves from the `## Active` table to the `## Closed & archived` table (most recent first), any other active studies stay in `## Active`, and the `_Last updated:_` date reflects today. Do not print the full board here — just keep `BOARD.md` in sync.

6. **Report** to the user:
   - What research was closed (`<folder>`).
   - Which reusable patterns were added or updated in `research/PATTERNS.md`.
   - That `BOARD.md` was updated (`Active` → `Closed & archived`).
   - That the study was removed from the `.claude/.active-research` registry (and how many studies remain active), and that they can start a new topic anytime with `new-research`.
