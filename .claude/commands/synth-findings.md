---
description: Synthesize the active research into SYNTHESIS.md, using the template for its Type (add --docx for a Word copy, --visual for a reading copy with Mobbin images inlined).
argument-hint: [--docx] [--visual]
---

Synthesize the currently active research into a design-ready findings document. The
synthesis template is chosen by the research **type**.

Arguments: `$ARGUMENTS` — `--docx` also produces a Word file (written to the study's
gitignored `docx/` folder); `--visual` also produces a gitignored `SYNTHESIS.visual.md`
with Mobbin reference images inlined for reading.

Steps:

1. **Locate the research & read its type.** Resolve the target study per
   `.claude/references/active-research.md` (explicit `[folder]` arg, else this
   terminal's binding, else the sole active study, else ask). If the registry is
   empty, STOP and tell the user to run `/new-research` first. Read the folder's
   `README.md` and note its `Type` (`benchmark`, `usability`, or `litreview`). Everything below
   branches on it.

2. **Gather the evidence — by type.**
   - **All types — read `PLAN.md` first.** Its research-question table is the spine of
     this synthesis: you are writing the answers to those questions, not a tour of
     whatever the capture happened to show. Note every `Q#` and its `Answerable?` value.
     If `PLAN.md` has no question table (a study created before the coverage contract),
     STOP and offer to build one from its prose questions — assigning IDs in the order
     they appear — before continuing.
   - **Benchmark:** read `README.md`, `sources.md`, and every `platforms/*/notes.md` and
     `platforms/*/flow.md`. Note each platform's **source shape**: a `references.md` means
     Mobbin-sourced (cite by URL, no `flow.gif`); a `screenshots/` folder means
     Chrome-sourced (cite by relative image path). If there are no platform notes yet,
     STOP — capture some platforms first.
   - **Usability:** read `README.md`, `test-plan.md`, and every
     `sessions/session-*.md`. If there is no `test-plan.md`, STOP and tell the user
     to run `/plan-usability` first. If there are no session notes yet, STOP — the
     sessions must be fielded and written into `sessions/` before there's anything to
     synthesize.
   - **Litreview:** read `README.md`, `sources.md`, and `evidence.md`. If there is no
     `evidence.md`, STOP and tell the user to run `/gather-evidence` first. Use only the
     `## Verified claims` as findings input; keep the `## Refuted / weak claims` aside to
     reproduce in the synthesis's own refuted section — never promote them to findings.

3. **Write `SYNTHESIS.md`** in the research folder, using the template for the type.

   **First, for every type: the coverage table.** Before writing a single finding, write
   the `## Research questions — coverage` section, placed immediately after the
   overview/TL;DR and *before* the findings. One row per `Q#` in `PLAN.md` — every one,
   including the ones the study failed to answer.

   | Q# | Question | Status | Where answered | Confidence |
   |---|---|---|---|---|
   | Q1 | <short form> | Answered | F1, F3 | High |
   | Q2 | <short form> | Partial | F2 — mechanic observed, effect size not | Medium |
   | Q3 | <short form> | Unanswered | No funnel access; → `## Gaps & caveats` | — |

   `Status` is `Answered` / `Partial` / `Unanswered` / `Withdrawn`, defined in
   `.claude/references/coverage-contract.md`. An `Answered` row must name at least one
   `F#`; a `Partial` row must name the `F#` **and** what is missing; an `Unanswered` row
   must give a reason and a destination.

   **An honest `Unanswered` is a good outcome and costs one line. Omitting the row is the
   failure.** Do not stretch a finding to cover a question it does not answer — that is
   the fabrication guardrail applied to coverage.

   **Then give every top-level entry an `F#`**, as a heading prefix
   (`## F1 — <name>`), numbered in document order. Which entry is top-level depends on the
   type: benchmark → each feature; usability → each finding; litreview → each numbered
   design implication. These IDs are what a `PRD.md` later accounts for one by one.

   **Benchmark → a list of features.** Lead with a short `## Overview` (goal,
   platforms studied, headline takeaways), then the coverage table, then one `## F<n> — <feature name>`
   section per feature. Every
   feature MUST have these five fields, in this order:
   1. **Feature name**
   2. **Short description** — 1–2 sentences.
   3. **Key findings** — what we learned observing it. Cite the platform(s) and evidence.
      **Citation depends on the platform's source:**
      - **Chrome-sourced:** embed the capture directly with relative markdown, e.g.
        `![description](platforms/<platform>/screenshots/filename.png)`.
      - **Mobbin-sourced:** cite the canonical Mobbin URL as a link, e.g.
        `[<platform> — <screen>](https://mobbin.com/screens/<id>)`. **Never embed a Mobbin
        reference image in `SYNTHESIS.md`** — it is gitignored and the file is committed.
        Run `--visual` to read it with images.
   4. **Why this feature works (rationale)** — the UX/product reasoning.
   5. **How to validate this feature in the future** — concrete next steps (usability
      test, prototype, metric, experiment…).

   **Usability → a list of findings, severity-ranked.** Lead with an `## Overview`
   (goal, method, participant count, headline findings) and a `## Metrics summary`
   (task success rates, SEQ/SUS, time-on-task — a small table), then the coverage table.
   Then one `## F<n> — <finding name>` section per finding, **ordered by severity, highest
   first** (so `F1` is the most severe). Every finding MUST have, in
   this order:
   1. **Finding** — the observed problem or insight.
   2. **Evidence** — which sessions/participants, task success/failure counts, and
      **redacted** quotes support it (embed any relevant capture with relative
      markdown). Reference participants by pseudonym (P01…), never real names.
   3. **Severity (0–4)** and the **affected task / usability heuristic**.
   4. **Recommendation** — the concrete design change it implies.
   Then add a `## What worked` section (positive findings worth preserving).

   **Litreview → themes → design implications.** Lead with a `## TL;DR`, then the coverage
   table, then one
   `## Theme N — <name>` section per theme. Under each theme, list findings as bullets,
   each with a **confidence** label and its `[S#]` citation(s) traced to `evidence.md`,
   e.g. `- Deferred onboarding lifts activation (confidence: High) [S3][S7]`. After the
   themes, add a numbered `## Design implications` section where each implication is
   prefixed with its ID (`1. **F<n> — <implication name>:** …`) — the implication, not the theme,
   is the unit a PRD accounts for — a `## Refuted / weak claims` section (reproduced from `evidence.md`,
   kept out of the findings), a `## Evidence gaps for primary research` section (what the
   literature could not answer and needs a survey/usability study), and a
   `## Sources table (S1..Sn)` mirroring `sources.md`. Every finding MUST trace to a
   source in `evidence.md`; confidence labels are honest; no generalization beyond what
   the sources support; no fabricated sources or findings.

   For **all three** types, end with a `## Gaps & caveats` section (methodological limits,
   paywalls, thin evidence, unanswered questions). Be analytical and opinionated as a
   Senior UI/UX Designer. **Do not invent findings, participants, or sources** —
   everything traces to captured evidence or a session note.

4. **Principal Researcher QA pass (quality gate — before `/review-research`).**
   Dispatch the Principal Researcher as a subagent (Agent tool, `general-purpose`) in
   **Mode B (synthesis QA)**, handing it `.claude/personas/principal-researcher.md`,
   the freshly written `SYNTHESIS.md`, the `README.md` (goal/scope/type), and the
   type's source material (benchmark: every `platforms/*/notes.md` and
   `platforms/*/flow.md`; usability: `test-plan.md` and every
   `sessions/session-*.md`; litreview: `evidence.md` and `sources.md`). Tell it the
   research **type** so it checks the right required fields (the five feature fields,
   or the four finding fields + severity-ordering, or — for litreview — every finding
   tracing to a source in `evidence.md`, honest confidence labels, refuted claims
   excluded from findings, and no over-generalization). It will:
   - **review** each entry for its required fields, evidence grounding (no
     fabrication), testable/actionable next steps, and gaps/overlaps;
   - **auto-fix prose** directly in `SYNTHESIS.md` and the source notes — rewrite
     AI-slop and remove em-dashes, changing no findings, numbers, or citations;
   - **flag content problems as inline `> [Principal Researcher] …` annotations**
     (never silently editing substance) and append a dated
     `## Principal Researcher QA (<date>)` record to `SYNTHESIS.md`. The prose rules
     apply to its own annotations and QA record too, not just the synthesis prose.

   Do this **before** the docx export so the cleaned, annotated version is what gets
   exported. Relay the agent's readiness verdict and flagged items to the user.

5. **Optional docx.** If `$ARGUMENTS` contains `--docx`, create the study's gitignored
   `docx/` folder if it doesn't exist, then run:

   ```
   powershell -NoProfile -File .claude/scripts/md_to_docx.ps1 -Source "<research-folder>/SYNTHESIS.md" -Out "<research-folder>/docx/SYNTHESIS.docx"
   ```

   and confirm the `.docx` path to the user. `-Out` is **mandatory** — always write into
   the gitignored `docx/` folder, never the study root, because an export can embed
   `reference/` images into a binary no markdown check can inspect.

6. **If `--visual` was passed**, generate the reading copy:

   ```
   powershell -File .claude/scripts/md_visualize.ps1 -Source <study>/SYNTHESIS.md
   ```

   Report the `swapped N of M` line it prints. The output `SYNTHESIS.visual.md` is
   gitignored — never stage it, and never edit it (it is regenerated from
   `SYNTHESIS.md`). If N is 0 and the study has Mobbin platforms, the `references.md`
   URLs do not match the links in the synthesis — check both before reporting success.

7. **Update the log** in the research `README.md` with a dated "synthesis written"
   entry (note the type, the entry count, and that the Principal Researcher QA pass
   ran with the flagged-item count).

8. **Report** to the user: the type, the coverage line (how many questions answered /
   partial / unanswered, naming the unanswered ones), how many features/findings/themes
   were synthesized, the
   file path(s), the Principal Researcher's readiness verdict, the content items it
   flagged for resolution, and any gaps you noticed (thin evidence, few participants).
