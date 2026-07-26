---
description: Close a research study — verify synthesis exists, mark it closed, remove it from the active registry.
---

Close out a research study (one of possibly several active).

Steps:

1. **Locate the research.** Resolve which study to close per
   `.claude/references/active-research.md` (explicit `[folder]` arg, else this
   terminal's binding, else the sole active study, else ask). If the registry is empty,
   tell the user there's no active research and stop.

2. **Check for synthesis.** Confirm `SYNTHESIS.md` exists in the research folder.
   If it does NOT, warn the user and ask whether to run `/synth-findings` first or
   close anyway. Only proceed on their confirmation.

3. **Update the pattern library (Principal Designer).** Dispatch the Principal
   Designer as a subagent (Agent tool, `general-purpose`) in **Mode P**, handing it
   `.claude/personas/principal-designer.md`, the closing study's `SYNTHESIS.md` and
   `README.md` (for `TYPE` + goal), and the current `research/PATTERNS.md` (it creates
   the file if absent). It extracts the study's reusable patterns, dedupes them
   against the library, merges them in, and flags any contradictions with existing
   entries. Relay its summary (patterns added / updated / contradictions). If
   `SYNTHESIS.md` was missing and the user chose to close anyway, skip this step and
   say so.

   - Tell it the study's per-platform sources (from `PLAN.md`). Patterns drawn from a
     Mobbin-sourced platform MUST use
     **Kind:** `reference-library observed (Mobbin; not first-party captured)` and cite the
     Mobbin URL — never a `reference/` image path, which is gitignored. See
     `.claude/references/mobbin-sourcing.md`.

   For a **litreview** study the Principal Designer harvests **evidence-based design
   principles** into `PATTERNS.md` (not observed UI patterns). It must **not force UI
   patterns where there are none** — a litreview study often has no interface to
   observe. If the synthesis yields no genuine, evidence-grounded principle, it records
   that plainly and adds nothing to `PATTERNS.md`; it never invents a pattern to fill
   the slot.

4. **Mark closed.** In the research `README.md`, set `**Status:** Closed`, add a
   `**Closed:** <date from `date +%F`>` line, and append a dated "research closed"
   entry to the Log.

5. **Update the registry & bindings.** Remove the closed study's line from
   `.claude/.active-research`, leaving every other active study's line intact. Delete
   this terminal's binding if it pointed at the closed study, and prune any file in
   `.claude/.current-research/` whose path is no longer in the registry. See
   `.claude/references/active-research.md`.

6. **Refresh the board.** Update `BOARD.md` so the just-closed study moves from
   **Active** to **Closed & archived** while any other active studies remain — re-derive
   it from the `research/` folders + the updated active registry exactly as
   `/research-board` does (update both tables and the `_Last updated:_` date). Keep
   the file in sync; no need to print the full board.

7. **Report** a short closeout summary: research topic and type, what was studied
   (platforms benchmarked / participants tested), number of features or findings
   synthesized, the patterns contributed to `research/PATTERNS.md`, and the location
   of `SYNTHESIS.md` (+ `.docx` if present).
