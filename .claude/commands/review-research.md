---
description: Run a research peer-review debate over the active SYNTHESIS.md (Skeptic, Domain Expert, Evidence Auditor, moderated by the Principal Researcher) that strengthens the findings, then on approval records a Peer Review section and applies the agreed strengthenings.
argument-hint: [optional study folder] [optional focus, e.g. "focus on finding 2"]
---

Run a research **peer-review debate** over the **active research's** synthesis to make the
findings stronger, then — only after the user approves — record it in `SYNTHESIS.md` under
`## Peer Review` and apply the agreed strengthenings.

This is a critique-and-strengthen step, not a capture step, and not a build decision (the
build call lives at `/draft-prd`). The panel judges the findings we synthesized; they do
not go browsing the product. Everything they say must trace to what is already in the
research folder or, for the Domain Expert, to a real retrieved scholarly source. **Do not
invent evidence, metrics, findings, or citations.**

## Steps

1. **Locate the research & its synthesis.** Resolve the target study per
   `.claude/references/active-research.md` (explicit `[folder]` arg, else this terminal's
   binding, else the sole active study, else ask). If the registry is empty, STOP and tell
   the user to run `/new-research`. Check that `<folder>/SYNTHESIS.md` exists; if not, STOP
   and tell the user to run `/synth-findings` first — there is nothing to review yet.

2. **Gather the ground truth & note the type.** Read `SYNTHESIS.md` in full, the research
   `README.md` (for `## Goal` and `Type`), **`PLAN.md`**, and the type's evidence — benchmark:
   `platforms/*/notes.md` and `flow.md`; usability: `test-plan.md` + `sessions/*`;
   litreview: `evidence.md` + `sources.md`.

   Hand every persona the study's **`PLAN.md`** alongside the synthesis. Without it the
   panel can only pressure-test the findings that exist; with it, the **Evidence Auditor**
   can also attack the `## Research questions — coverage` table — an `Answered` row whose
   cited `F#` does not really answer the question is exactly the kind of over-claim the
   audit exists to catch, and it is invisible without the plan.

   If the user passed a focus in
   `$ARGUMENTS`, weight the debate toward it but still cover the whole synthesis. If the
   README `## Goal` is vague or missing, STOP and ask the user to state it — the debate is
   only meaningful against an explicit goal.

   **Anchor the debate to the `Type` + `## Goal`.** The debate focus differs by type:
   - **benchmark** — do the observed patterns generalize? does the captured evidence
     actually support each "why it works" rationale?
   - **usability** — signal vs noise at small N; are severity ratings justified; are there
     alternative explanations for the behavior?
   - **litreview** — does every finding trace to a verified source in `evidence.md`?
     are confidence labels justified by the cited evidence (not overstated)? are
     refuted/weak claims correctly kept out of the findings? do the design
     implications actually follow from the evidence, without over-generalization?

3. **Run the debate panel as chained subagents.** Dispatch each persona with the Agent tool
   (`general-purpose`), handing it its spec file plus the ground truth from step 2, and pass
   each later panelist the earlier reviews so they cross-talk. Order and specs:
   1. **Skeptic / Methodologist** — `.claude/personas/research-skeptic.md`. Biggest validity
      threat per finding; fatal or fixable.
   2. **Domain Expert / Contextualist** — `.claude/personas/domain-expert.md`. Corroborate
      or challenge against known literature/context (scoped scholarly web-search allowed);
      evaluate product & research leverage (rejecting trivial button/color/copy recommendations); what is missing. Has read the Skeptic.
   3. **Evidence Auditor / Steelman** — `.claude/personas/evidence-auditor.md`. Grounding +
      confidence honesty; evaluate product & research leverage (explicitly asking: "Does this finding justify a full PRD and engineering investment, or is it a low-leverage tweak that should be dropped?"); steelman weak-but-important findings. Has read both prior reviews.

4. **Moderate with the Principal Researcher (Mode C).** Dispatch the Principal Researcher
   (`general-purpose`) with `.claude/personas/principal-researcher.md`, the three panel
   reviews, `SYNTHESIS.md`, the `README.md` (goal + type), and the type's evidence. Tell it
   the **type** so it calibrates confidence correctly.

   The Principal Researcher applies the **Impact & Leverage Gate** during moderation:
   - Verifies all findings map to a Structural UX Lever (Flow Topology, Cognitive Load, Time-to-Aha, Core Interaction Paradigm);
   - Marks standalone surface-level UI/color/button tweaks as `Unsupported` (moving them to `## Gaps & caveats`);
   - If the synthesis lacks structural UX leverage, issues or confirms the `Readiness: No-Go (Low Leverage)` verdict.

   It returns the `## Peer Review`
   section content (per-panelist summary, a `### Strengthened findings` table [Finding |
   Verdict | Confidence Δ | Action], a `### Actions to apply` list with each original
   wording preserved, and a `### Legend`) plus a one-line readiness note.

5. **Checkpoint — do NOT write yet.** Present the assembled `## Peer Review` block AND the
   list of concrete strengthening actions to the user. Ask for explicit approval to (a) save
   the section and (b) apply the actions into the findings. If they want changes, revise and
   re-present. Only proceed on a clear yes. The user may approve a subset of actions.

6. **On approval, write and apply.**
   a. Append `## Peer Review` to `SYNTHESIS.md`. If one already exists from a prior run,
      replace it (keep only the latest) rather than stacking.
   b. Apply each **approved** action into the relevant finding: recalibrate the confidence
      label (litreview), narrow an over-claim, add a caveat, or add a corroboration TODO.
      The original wording of every changed finding is already preserved verbatim in the
      `### Actions to apply` record, so nothing is lost. Move any **Unsupported** finding
      into `## Gaps & caveats` as an open question rather than deleting it outright. The
      moved entry **keeps its `F#` prefix** and is marked `Unsupported`, in the inline-bold
      form the contract defines for a retracted finding — **not** as a heading, whatever the
      study type, since `## Gaps & caveats` is itself an `##` and an `## F4` under it would
      parse as its sibling and carry the finding back out of the section:
      `**F4 — <name> — Unsupported:** <what the debate could not support>`. This is the third
      form an `F#` takes, and Mode S is taught to read it; if you ever change it, change it
      in the contract and in Mode S together. An `F#` is
      retired in place, never renumbered, reused, or erased: a later `PRD.md` must be able
      to see it and declare it `Retired upstream`, and a finding that vanishes from the
      `F#` set is indistinguishable from one that was silently dropped. See
      `.claude/references/coverage-contract.md`.
   c. If the Domain Expert cited external sources, ensure they are recorded in
      `references.md` (create/extend it).
   d. **Refresh the `## Research questions — coverage` table** for the retractions. Any
      `Q#` whose cited `F#` was marked `Unsupported` no longer has the answer the table
      claims: where every `F#` it cited was retracted, drop its `Status` to `Unanswered`,
      carrying **both** things Vocabulary 2 requires — the retraction as the reason **and**
      `## Gaps & caveats` as the destination. Where only some were retracted, downgrade to
      `Partial` and name what is now missing. Do this here: the Principal Researcher's
      Mode B coverage check runs inside `/synth-findings`, i.e. *before* the debate, so
      nothing else re-checks the table after a finding is retracted.

7. **Update the log** in the research `README.md` with a dated "peer review recorded" entry
   (verdict counts, actions applied).

8. **Report** to the user: the per-finding verdicts in one line each (including leverage assessments and any `No-Go (Low Leverage)` verdict), which strengthenings
   were applied, the file(s) updated, and any finding ruled Unsupported.
