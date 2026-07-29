---
description: (litreview studies) Run the deep-research harness over the approved plan and write a verified evidence.md + sources.md.
argument-hint: [folder]
---

Gather and fact-check the evidence base for a **litreview** study. This is the
litreview analogue of benchmark capture: the one method-specific step that produces
the raw material `/synth-findings` reads. It is expensive (multi-agent adversarial
verification), so it runs **only after** the `PLAN.md` gate is approved.

Steps:

1. **Locate the study & confirm its type.** Resolve the target study per
   `.claude/references/active-research.md` (explicit `[folder]` arg, else this
   terminal's binding, else the sole active study, else ask). Read `README.md` and
   confirm `Type: litreview`. If it is **not** litreview, STOP and tell the user
   `/gather-evidence` only applies to litreview studies. If the registry is empty,
   STOP and tell the user to run `/new-research --type litreview` first.

2. **Check the plan gate.** Read `PLAN.md`. Confirm its `## Principal Researcher
   review` section records an approved verdict (the Mode A gate from `/new-research`).
   If the plan is still `Draft` / unapproved, STOP — the harness is expensive and must
   not run before approval. Tell the user to get the plan approved first.

3. **Read the inputs.** From `PLAN.md`: the `## Key research questions`, `## Provided
   corpus`, `## Search angles`, and `## Inclusion criteria`. From `README.md`: the
   `## Goal`. Read any documents present in `corpus/` as anchor sources (these are
   `provided`; sources the harness finds are `found`).

4. **Run the deep-research harness.** Invoke the `deep-research` skill (Skill tool),
   passing a brief assembled from the research question(s) + corpus context + search
   angles + inclusion criteria as its `args`. Let it fan out searches, fetch sources,
   and adversarially verify claims (3-vote). Fold the `corpus/` documents in as anchor
   evidence so provided and found sources are verified on the same footing.

5. **Write `sources.md`.** Header `# Sources — <topic>`. A table with columns:
   ID | Source | URL | Provenance (`provided`/`found`) | Accessed | Notes. One row per
   source `S1..Sn`. Every source the harness used or the user provided appears here.

6. **Write `evidence.md`.** Header `# Evidence base — <topic>`. Two parts:
   - `## Verified claims` — each confirmed claim as a bullet with a **confidence**
     label (High/Med/Low) and its `[S#]` source ID(s). Each verified claim carries
     the `Q#` it addresses alongside its `[S#]` source IDs, e.g.
     `- [Q2] Deferred registration lifts activation (confidence: High) [S3][S7]`. A
     research question that ends with no claim against it is a real finding — it
     becomes an `Unanswered` row at synthesis, not a silence. See
     `.claude/references/coverage-contract.md`.
   - `## Refuted / weak claims` — claims the harness could not confirm or that failed
     verification, kept here so they **never leak into findings**. Note why (refuted,
     single weak source, contradicted).

7. **Update the README `## Log`** with a dated "evidence gathered" entry (note source
   count and verified-vs-refuted counts).

8. **Report** to the user: verified-claim count, refuted/weak count, total sources
   (provided vs found), the two file paths, and the next step — `/synth-findings`
   (which turns `evidence.md` into a themes → design-implications `SYNTHESIS.md`).

Never run before the plan gate. Never invent sources or claims. Keep refuted claims
quarantined in their own section.
