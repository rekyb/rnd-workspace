---
name: design-prototype
description: Turn a synthesized study (ideally via its SPEC.md) into a clickable, self-contained HTML prototype published as a claude.ai Artifact, generated and audited against the design gates. Gated by the Principal Designer (Mode T).
---

Produce the **clickable prototype** for a synthesized research study: a single
self-contained HTML page/flow, published as a **claude.ai Artifact**, that realizes *what we learned* as *something you can click through*. This is the third design-output step — where `brief-feature` makes the stakeholder *narrative* ("should we build this") and `draft-prd` makes the maker's *definition* ("here is what to build"), `design-prototype` makes the *artifact* ("here is what it looks and feels like"), for a stakeholder to react to or a designer to build from.

It is an **optional, additive** step (like the benchmark lenses and `draft-prd`), run only when the user asks — not part of the required spine. The prototype is published to the user's Artifacts gallery at `claude.ai/code/artifacts`: default-private, shareable when they choose, and updated in place at the same URL on later passes.

This is a synthesis-to-deliverable step, not a capture step. **Every screen must trace back to a SPEC requirement or a synthesis finding and its evidence — do not invent screens, flows, data, or sources** (same non-fabrication guardrail as the rest of the workspace). Where the prototype must extrapolate beyond what the research supports, say so explicitly as a flagged **assumption**, exactly as the lenses flag inference.

The gate definitions this skill runs live in `.claude/references/design-gates.md` (the Claude Design Prompt Pack): 14 categories (0–13) and the Definition of Done (G1–G8). Read it when running a gate.

## Arguments

- **Study folder** (optional positional) — defaults to the active research.
- **`--fidelity lo|hi`** (default `hi`) — `hi` = full tokens, colour, type, motion, and the complete core spine incl. the DoD audit. `lo` = grayscale wireframe, structure only, reduced gate set (skips colour/motion/delight/pixel-polish).
- **`--gate <name,…>`** (a.k.a. `--deepen`) — run one or more named gate passes against the *existing* artifact and redeploy the same URL, instead of a full default run.
- **`--scope <moment>`** (optional) — prototype only one slice of the flow (e.g. `landing`) rather than the full arc. Defaults to the full arc.

## Fidelity

| | lo-fi | hi-fi (default) |
|---|---|---|
| Look | Grayscale wireframe, structure only | Full tokens, colour, type, motion |
| Goal | Cheap structural exploration | Pixel-perfect, shareable |
| Auto-runs | context-lock → screens → states → copy → structural a11y → DoD (structure subset) | context-lock → tokens → screens → states → copy → a11y → responsive → DoD G1–G8 audit |
| Skips | colour / motion / delight / pixel-polish | nothing in the core spine |

## À-la-carte gate registry

Named passes for `--gate`. Each operates on the current artifact and redeploys the same URL. (Categories 0 context-lock, 2 screen-generation, and 4 wiring are not standalone passes — they live in the core spine.)

| Gate | Pack § | Pass |
|---|---|---|
| `tokens` | 1 | Extract/harden the token set (prefers `lenses/tokens.md` if present) |
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

1. **Locate the study & its synthesis.** If arguments name a study folder, use it; otherwise resolve it per `.claude/references/active-research.md` (this terminal's binding, else the sole active study, else ask). If nothing resolves, STOP and tell the user to pass a study folder or run `new-research`. Confirm `<folder>/SYNTHESIS.md` exists — if not, STOP and tell the user to run `synth-findings` first (there is nothing to prototype yet).

2. **À-la-carte fast path.** If `--gate`/`--deepen` is present, skip to running those named passes (registry above) against the study's existing prototype Artifact, redeploying the same file path → same URL. If no prototype exists yet, tell the user to run a default `design-prototype` first, then STOP.

3. **Soft gate on the definition doc.** Prefer a design project's **`PRD.md`** — its §8 vertical slices, §11 Screens/IA/Empty States, §12 Modal Reference, and the Prototype Element Dictionary appendix are the source of the screen list, flow, IA, and per-screen states. Falling back, in order: a study's legacy **`SPEC.md`** (same role, FR-based), then `SYNTHESIS.md` alone. If neither a PRD nor a SPEC exists, warn the user that screens will be derived from `SYNTHESIS.md` with weaker traceability, offer to run `draft-prd` first, and suggest `--fidelity lo` for a cheap first pass. Proceed only on the user's yes. *(This command still resolves a **study** folder; running it directly against a design project is the Phase 3 rework.)*

4. **Read the ground truth & note the type.** Read `SPEC.md` (if present) and `SYNTHESIS.md` in full, plus the research `README.md` for the `Type`, the stated `## Goal`, and the study's user types. Note the requested `--fidelity`, `--scope`, and which evidence the research cites (so the prototype can point at real captures).

5. **Context-lock (gates §0.1).** Restate, one line each: the token source (precedence: `lenses/tokens.md` from `extract-tokens` > tokens named in `SPEC.md` > a minimal derived set), the reference screens, the personas/user types, and the Definition of Done. If any is missing, ask — do not guess.

6. **Generate the prototype (gates §1–2, 5–7).** Build the flow's screens grounded in the SPEC/synthesis: tokens-only, all states (§6), specific load-bearing copy (§7), the target flow (§5). Self-contained HTML — inline all CSS/JS, embed any capture stills as `data:` URIs (Artifacts block external hosts). No invented screens or data; flag every extrapolation as an assumption. Honour `--scope` if set.

7. **Self-audit against the DoD (gates §11.1, §9, §10).** Produce a G1–G8 gate table (pass/fail + evidence); fix fails. A hi-fi run includes a11y (§9) and responsive (§10); a lo-fi run runs the structure subset only and says so.

8. **Principal Designer review — Mode T.** Dispatch the Principal Designer as a subagent (Agent tool, `general-purpose`) in **Mode T**, handing it `.claude/personas/principal-designer.md`, the drafted prototype HTML, the gate table, `SYNTHESIS.md`, `SPEC.md` (if present), and the `README.md` (goal + type). It judges traceability, gate compliance, flow completeness, fidelity honesty, and PII-safety, returning **ready / revise / reject**. Revise to address its points, re-run if it said *reject*. Relay the verdict to the user.

9. **PII / guardrail gate.** Re-check the prototype carries zero internal specifics (product / program / funder / real names) and no un-redacted PII, and that it does not impersonate any real organisation (generic-branded only). Never invent evidence to fill a gap. Publishing to claude.ai is outward-facing — treat it like `brief-feature` and `publish-research`.

10. **Checkpoint — get explicit approval to publish.** Present the review-cleared prototype and confirm the user wants it published to claude.ai. Only on a clear yes, write the HTML to the session scratchpad and publish it with the **Artifact** tool (title = study topic + "Prototype"; a stable favicon). Report the returned `claude.ai/code/artifacts` URL. Reuse the same file path on later passes so updates redeploy the same URL.

11. **Update the log** in the study `README.md` with a dated "prototype drafted" entry (fidelity, screen count, gates passed/failed, Principal Designer Mode T verdict, Artifact URL).

12. **Report** to the user: the Artifact URL, the screen count, the DoD gate table, the Principal Designer's verdict and what was addressed, any assumptions flagged, and any PII items caught.
