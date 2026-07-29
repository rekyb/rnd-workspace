---
name: design-prototype
description: Author a design project's clickable prototype as multi-file source in src/, built from its PRD.md against the shared ui-library/ design system. Gated by the Principal Designer (Mode T); shipped by /export-prototype.
---

Produce the **clickable prototype** for a design project: the multi-file source under `design/<project>/src/` that realizes the project's **`PRD.md`** as *something you can click through*. This is the design half's make step — where `draft-prd` writes the maker's *definition* ("here is what to build"), `design-prototype` authors the *artifact* ("here is what it looks and feels like"), for a stakeholder to react to or a designer to build from.

It **authors source; it does not ship it.** `export-prototype` inlines `src/` into `build/standalone.html`, runs the local design gate, and — with `--artifact` — publishes to claude.ai. They are separate because they fail differently: authoring fails on design questions (a missing screen, an unported component), exporting on mechanical ones (a raw hex value, an unresolved token). Publishing is outward-facing and has one owner.

It is an **optional, additive** step (like the benchmark lenses and `draft-prd`), run only when the user asks — not part of the required spine.

The prototype is built **from the shared design system in `ui-library/`** — tokens and component classes only, never an improvised lookalike. A component that `ui-library/COMPONENTS.md` marks `not yet ported` has working CSS but no behavior: the run STOPs and says so rather than substituting something that merely looks close.

**Every screen must trace back to a `PRD.md` vertical slice and its screen entry — do not invent screens, flows, data, or sources** (same non-fabrication guardrail as the rest of the workspace). Where the prototype must extrapolate beyond what the PRD and its cited evidence support, say so explicitly as a flagged **assumption**, exactly as the lenses flag inference.

The gate definitions this skill runs live in `.claude/references/design-gates.md` (the Claude Design Prompt Pack): 14 categories (0–13) and the Definition of Done (G1–G8). Read it when running a gate.

## Arguments

- **`[project]`** (optional positional) — a design project slug or path, resolved per `.claude/references/design-projects.md`. Naming one adopts this terminal's binding.
- **`--fidelity lo|hi`** (default `hi`) — `hi` = full tokens, colour, type, motion, and the complete core spine incl. the DoD audit. `lo` = grayscale wireframe, structure only, reduced gate set (skips colour/motion/delight/pixel-polish).
- **`--gate <name,…>`** (a.k.a. `--deepen`) — run one or more named gate passes against the *existing* `src/`, instead of a full default run.
- **`--scope <moment>`** (optional) — prototype only one slice of the flow (e.g. `landing`) rather than the full arc. Defaults to the full arc.

## Fidelity

| | lo-fi | hi-fi (default) |
|---|---|---|
| Look | Grayscale wireframe, structure only | Full tokens, colour, type, motion |
| Goal | Cheap structural exploration | Pixel-perfect, shareable |
| Auto-runs | context-lock → screens → states → copy → structural a11y → DoD (structure subset) | context-lock → tokens → screens → states → copy → a11y → responsive → DoD G1–G8 audit |
| Skips | colour / motion / delight / pixel-polish | nothing in the core spine |

## À-la-carte gate registry

Named passes for `--gate`. Each operates on the project's current `src/`; re-run `export-prototype` afterwards to rebuild and republish. (Categories 0 context-lock, 2 screen-generation, and 4 wiring are not standalone passes — they live in the core spine.)

| Gate | Pack § | Pass |
|---|---|---|
| `tokens` | 1 | Extract/harden the token set (re-checks every value against `ui-library/tokens.css` and the project overlay) |
| `consistency` | 3 | Cross-screen audit + hardcode/terminology/drift sweep, then fix |
| `states` | 6 | Full loading / empty / error / partial / success pass |
| `copy` | 7 | Rewrite every string to be specific + load-bearing |
| `pixel` | 8 | Spacing / type / edge polish to the grid |
| `a11y` | 9 | WCAG 2.2 AA audit + fixes (contrast, targets, keyboard, focus) |
| `responsive` | 10 | 375 / 768 / 1440 proof, no overflow |
| `qa` | 11 | Full DoD G1–G8 gate table, pass/fail + evidence |
| `friction` | 5 | Skeptical-user friction walk; redesign the top frictions |
| `critique` | 12 | Structured critique (first impression, hierarchy, consistency) |
| `delight` | 13 | Signature moments + personality (hi-fi only) |

The **Definition of Done (G1–G8)** is the acceptance contract, not just a gate: G1 tokens-only, G2 interactive states, G3 data states, G4 no dead-ends, G5 WCAG AA, G6 responsive 375/768/1440, G7 specific copy, G8 real data shape. Any default hi-fi run ends with the `qa` gate table, and the Principal Designer (Mode T) will not pass a prototype that fails a gate unless the failure is declared.

## Steps

1. **Resolve the project.** Per `.claude/references/design-projects.md`: explicit `[project]` argument (adopt the binding) → this terminal's binding → the sole `Status: Active` project → otherwise STOP, list what was found, and ask. Never create a project; `new-design` is the only command that does.

2. **Hard gate on the PRD.** `design/<project>/PRD.md` must exist. If it does not, STOP and tell the user to run `draft-prd` first. This is deliberately harder than the old soft gate: a prototype with no decision doc behind it has nothing to be traceable to, and traceability is the first thing the Principal Designer judges.

3. **À-la-carte fast path.** If `--gate`/`--deepen` is present, run those named passes against the existing `src/`, then STOP after telling the user to run `export-prototype` to rebuild and republish. If `src/index.html` does not exist yet, say so and STOP — there is nothing to deepen.

4. **Read the ground truth.** Read `PRD.md` in full — §7 Solution Shape (the Mermaid flow), §8 vertical slices, §9 acceptance criteria per slice, and the sections carrying **Screens / IA / Empty States**, the **Modal Reference**, the **Data Model**, and the **Prototype Element Dictionary**. **Locate those four by heading name, not by number** — only `draft-prd`'s template puts them at §11/§12/§13; a real PRD may number differently, and where a numbered section does not carry the expected content, fall back to the appendices. (Worked example: `design/onboarding-solve-edu/PRD.md` was revised on 2026-07-29 to the current template, so its screens, modals, and data model now *are* at §11/§12/§13, its Prototype Element Dictionary remains `Appendix A` with one `###` per screen, and its former `Appendix B: Core Data Model` was promoted into §13. Before that revision the same file had §11–§13 as Rabbit Holes / Technical Constraints / Dependencies, which is precisely why this step says to locate by heading name rather than by number.) Read the project `README.md` for the title and `Informed by:`. For each study named there, read its `SYNTHESIS.md` — that is where the *evidence* behind a screen lives, and what lets the prototype cite real findings instead of asserting them.

5. **Context-lock (gates §0.1).** Restate, one line each: **Tokens** — `ui-library/tokens.css`, plus `design/<project>/tokens.overlay.css` if it exists; there is no third source, and a value neither provides means an overlay entry that **redefines an existing token name**, never a new name and never a raw value. **Components** — `ui-library/components.css`, catalogued in `ui-library/COMPONENTS.md`. **Screens** — the screen list from the section step 4 identified, verbatim. **Definition of Done** — G1–G8. If any is missing, ask. Do not guess.

6. **Component availability check — STOP on an unported component.** Cross-check every entry in the PRD's Prototype Element Dictionary against `ui-library/COMPONENTS.md`. Any component whose **Status** is `not yet ported` has working CSS but **no behavior**. STOP. Report which components are unported and offer the three real options: port the behavior into `ui-library/behaviors.js` first, change the PRD to use a ported component, or use `--scope` to prototype only a slice that does *not* include that screen. **Do not improvise a lookalike** — improvisation is what produced the `--sub` / `--mut` divergence this library exists to end (spec §3.3).

7. **Author the source (gates §1–2, 5–7).** Write into `design/<project>/src/`: `index.html`, the screens, linking the design system with relative paths — `<link rel="stylesheet" href="../../../ui-library/tokens.css">`, then `components.css`, then `../tokens.overlay.css` **last** if it exists, so a redefined token wins — and loading the JS the same way, as plain `<script src="…"></script>` tags (`../../../ui-library/behaviors.js` when a ported behavior is used, then `data.js`, then `app.js`), because `build-prototype.ps1` inlines `<link>` and `<script src>` tags only and an ES `import` would survive the build as an unresolvable reference; `app.js`, the behavior, using the ported behaviors `ui-library/behaviors.js` exposes (the global `RndUI`) for any ported component rather than reimplementing it; `data.js`, the sample data shaped per the PRD's data-model section (found by heading name per step 4, not by number); and `img/` for any local images. Tokens and component classes only: no raw hex, no raw px, and **no external URL in any `href`/`src`** — a plain `<a href="https://…">` builds fine and then hard-fails the gate on rule 1 (`external host:`), so link out with `href="#"` or a local anchor instead. Every screen traces to a screen entry (per step 4) and a §8 slice. All states (§6), specific load-bearing copy (§7), no dead-ends. Flag every extrapolation beyond the PRD as an assumption; do not present it as fact. Honour `--scope` and `--fidelity` if set.

8. **Self-audit against the DoD (gates §11.1, §9, §10).** Produce a G1–G8 gate table (pass/fail + evidence) and fix the fails. A hi-fi run includes a11y (§9) and responsive (§10); a lo-fi run runs the structure subset only and says so.

9. **Local gate, as a fast check.** Run `export-prototype` **without** `--artifact` to build and gate the source now. Rule 2 (no raw style values) and rule 3 (every `var(--x)` resolves) will catch mechanical slips far faster than a review pass will. Fix anything it reports and re-run before going further.

10. **Principal Designer review — Mode T.** Dispatch the Principal Designer as a subagent (Agent tool, `general-purpose`) in **Mode T**, handing it `.claude/personas/principal-designer.md`, the authored `src/` files, the gate table, the `check-prototype.ps1` result, `PRD.md`, the project `README.md`, and the `SYNTHESIS.md` of each study in `Informed by:`. It returns **ready / revise / reject**. Address its points; re-run if it said *reject*. Relay the verdict.

11. **PII / guardrail gate.** Re-check the source carries zero internal specifics (product / program / funder / real names) and no un-redacted PII, and that it does not impersonate a real organisation (generic-branded only). Never invent evidence to fill a gap.

12. **Update the log** in `design/<project>/README.md` with a dated status-log row: fidelity, screen count, gates passed/failed, and the Mode T verdict.

13. **Report and hand off.** The screen count, the DoD gate table, the local gate result, the Principal Designer's verdict and what was addressed, and any flagged assumptions. Then tell the user the next step is **`export-prototype --artifact`** to publish. This command does not publish — publishing is outward-facing and has one owner.
