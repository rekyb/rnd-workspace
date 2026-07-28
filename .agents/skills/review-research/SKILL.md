---
name: review-research
description: Run a research peer-review debate over the active SYNTHESIS.md (Skeptic, Domain Expert, Evidence Auditor, moderated by the Principal Researcher) that strengthens the findings, then on approval records a Peer Review section and applies the agreed strengthenings.
---

Run a research **peer-review debate** over the **active research's** synthesis to make the findings stronger, then — only after the user approves — record it in `SYNTHESIS.md` under `## Peer Review` and apply the agreed strengthenings.

This is a critique-and-strengthen step, not a capture step, and not a build decision (the build call lives at `draft-prd`). The panel judges the findings we synthesized; they do not go browsing the product. Everything they say must trace to what is already in the research folder or, for the Domain Expert, to a real retrieved scholarly source. **Do not invent evidence, metrics, findings, or citations.**

## Steps

1. **Locate the research & its synthesis.** Resolve the target study per `.claude/references/active-research.md` (explicit `[folder]` arg, else this terminal's binding, else the sole active study, else ask). If the registry is empty, STOP and tell the user to run `new-research`. Check that `<folder>/SYNTHESIS.md` exists; if not, STOP and tell the user to run `synth-findings` first — there is nothing to review yet.

2. **Gather the ground truth & note the type.** Read `SYNTHESIS.md` in full, the research `README.md` (for `## Goal` and `Type`), and the type's evidence — benchmark: `platforms/*/notes.md` and `flow.md`; usability: `test-plan.md` + `sessions/session-*.md`; litreview: `evidence.md` + `sources.md`. If the user passed a focus argument, weight the debate toward it but still cover the whole synthesis. If the README `## Goal` is vague or missing, STOP and ask the user to state it — the debate is only meaningful against an explicit goal.

   **Anchor the debate to the `Type` + `## Goal`.** The focus differs by type: **benchmark** — do the observed patterns generalize, and does the captured evidence actually support each "why it works" rationale? **usability** — signal vs noise at small N, are severity ratings justified, are there alternative explanations for the behavior? **litreview** — does every finding trace to a verified source in `evidence.md`? are confidence labels justified by the cited evidence (not overstated)? are refuted/weak claims correctly kept out of the findings? do the design implications actually follow from the evidence, without over-generalization?

3. **Run the debate panel as chained subagents.** Dispatch each persona via subagent (`general-purpose`), handing it its spec file plus the ground truth from step 2, and pass each later panelist the earlier reviews so they cross-talk. Order and specs: (1) **Skeptic / Methodologist** — `.claude/personas/research-skeptic.md`, biggest validity threat per finding, fatal or fixable; (2) **Domain Expert / Contextualist** — `.claude/personas/domain-expert.md`, corroborate or challenge against known literature/context (scoped scholarly web-search allowed), what is missing, has read the Skeptic; (3) **Evidence Auditor / Steelman** — `.claude/personas/evidence-auditor.md`, grounding + confidence honesty, steelman weak-but-important findings, has read both prior reviews.

4. **Moderate with the Principal Researcher (Mode C).** Dispatch the Principal Researcher (`general-purpose`) with `.claude/personas/principal-researcher.md`, the three panel reviews, `SYNTHESIS.md`, the `README.md` (goal + type), and the type's evidence. Tell it the **type** so it calibrates confidence correctly. It returns the `## Peer Review` section content (per-panelist summary, a `### Strengthened findings` table [Finding | Verdict | Confidence Δ | Action], a `### Actions to apply` list with each original wording preserved, and a `### Legend`) plus a one-line readiness note.

5. **Checkpoint — do NOT write yet.** Present the assembled `## Peer Review` block AND the list of concrete strengthening actions to the user. Ask for explicit approval to (a) save the section and (b) apply the actions into the findings. If they want changes, revise and re-present. Only proceed on a clear yes. The user may approve a subset of actions.

6. **On approval, write and apply.** (a) Append `## Peer Review` to `SYNTHESIS.md`; if one already exists from a prior run, replace it (keep only the latest) rather than stacking. (b) Apply each **approved** action into the relevant finding: recalibrate the confidence label (litreview), narrow an over-claim, add a caveat, or add a corroboration TODO. The original wording of every changed finding is already preserved verbatim in the `### Actions to apply` record, so nothing is lost. Move any **Unsupported** finding into `## Gaps & caveats` as an open question rather than deleting it. (c) If the Domain Expert cited external sources, ensure they are recorded in `references.md` (create/extend it).

7. **Update the log** in the research `README.md` with a dated "peer review recorded" entry (verdict counts, actions applied).

8. **Report** to the user: the per-finding verdicts in one line each, which strengthenings were applied, the file(s) updated, and any finding ruled Unsupported.
