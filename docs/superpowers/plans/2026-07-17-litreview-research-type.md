# `litreview` Research Type Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `litreview` as a third first-class research type on the existing type-aware spine, so the workspace can synthesize evidence from *documents* (journals, reports, government data) — not only observed products — via a new `/gather-evidence` step backed by the `deep-research` harness.

**Architecture:** Additive type + light doc reframe. Benchmark and usability flows are untouched. `/new-research --type litreview` scaffolds a `corpus/` (gitignored) + `sources.md` + `PLAN.md`; the new `/gather-evidence` runs `deep-research` over the plan's questions and writes a verified `evidence.md` + `sources.md`; `/synth-findings` gains a litreview branch (themes → design implications); the rest of the spine (`/review-research`, `/close-research`, `/research-board`, `/publish-research`) becomes type-aware with small branches. Personas are unchanged — only their Mode A/B/P *inputs* extend to litreview.

**Tech Stack:** Markdown command files (`.claude/commands/*.md`) mirrored by Antigravity skill files (`.agents/skills/*/SKILL.md`); the `deep-research` skill (invoked via the Skill tool) as the evidence harness; `.gitignore`; the `CLAUDE.md` / `GEMINI.md` operating guides. No application code, no test framework — verification is structural (grep/tree assertions) plus one real end-to-end dry run.

## Global Constraints

- **Source of truth for the design:** `docs/superpowers/specs/2026-07-16-litreview-research-type-design.md`. Every task below traces to a section of it. Do not add behaviour the spec doesn't call for (YAGNI).
- **Command ↔ skill parity:** Every `.claude/commands/<x>.md` edit MUST be mirrored in `.agents/skills/<x>/SKILL.md`. The skill copy uses bare command names (`gather-evidence`, not `/gather-evidence`) and "browser tools" phrasing, matching the existing divergence between the two trees. Both are edited in the same task and committed together.
- **`corpus/` is never committed.** User-supplied documents live in a gitignored `research/*/corpus/`. Only `sources.md` records what was used. Add `research/*/corpus/` to `.gitignore` before any litreview folder is created.
- **No fabrication.** Every synthesized finding traces to a source in `evidence.md`; refuted/weak claims are quarantined in their own section and never leak into findings; confidence labels are honest; no invented sources.
- **`/gather-evidence` runs only after the `PLAN.md` gate is approved** — same discipline as benchmark capturing only after plan approval (it is expensive: multi-agent adversarial verification).
- **Out of scope (do not build):** no `litreview` branch in `/draft-spec` or `/design-prototype` for v1 (they need only *tolerate* the type — they already read `Type:`); no changes to persona *specs*; no migration of the existing `AUDIENCE-CONTEXT.md`; `survey`/`abtest` stay planned.
- **Researcher byline:** `.claude/` command templates say `Researcher: Claude (acting Senior UI/UX Designer)`; `.agents/` skill templates say `Gemini`. Preserve each tree's existing byline — do not unify them.

---

### Task 1: `/new-research` — `litreview` scaffold + `.gitignore`

Adds `litreview` as an accepted `--type`, scaffolds its folder tree (`corpus/` + litreview `PLAN.md` template), runs the existing Principal Researcher Mode A gate, and directs the user to `/gather-evidence`. Also gitignores `corpus/`.

**Files:**
- Modify: `.gitignore`
- Modify: `.claude/commands/new-research.md`
- Modify: `.agents/skills/new-research/SKILL.md`

**Interfaces:**
- Consumes: the approved-plan gate pattern already in `new-research.md` step 7 (Principal Researcher Mode A via `.claude/personas/principal-researcher.md`).
- Produces: a scaffolded `research/<date>-<slug>/` for `litreview` containing `README.md` (`Type: litreview`), `PLAN.md` (litreview template with `## Key research questions`, `## Provided corpus`, `## Search angles`, `## Inclusion criteria`, `## Success criteria`, `## Principal Researcher review`), `sources.md`, and an empty `corpus/`. Consumed by Task 2 (`/gather-evidence`).

- [ ] **Step 1: Write the failing verification (gitignore)**

Run this assertion — it MUST fail now, proving `corpus/` is not yet ignored:

```bash
cd /c/research-workspace && grep -q 'research/\*/corpus/' .gitignore && echo PASS || echo FAIL
```
Expected: `FAIL`

- [ ] **Step 2: Add `corpus/` to `.gitignore`**

Insert after the existing `raw-data/` block in `.gitignore`:

```gitignore
# Litreview user-supplied source documents (copyright/size/PII — never committed)
research/*/corpus/
```

- [ ] **Step 3: Verify the gitignore assertion passes**

Run:
```bash
cd /c/research-workspace && grep -q 'research/\*/corpus/' .gitignore && echo PASS || echo FAIL
```
Expected: `PASS`

- [ ] **Step 4: Add `litreview` to the accepted types in `new-research.md`**

In `.claude/commands/new-research.md` step 2, replace:

```
   - Accepted values: `benchmark` (default if the flag is absent) and `usability`.
```
with:
```
   - Accepted values: `benchmark` (default if the flag is absent), `usability`, and
     `litreview` (evidence synthesis from documents — see step 5/7 for its scaffold and gate).
```

- [ ] **Step 5: Add the `litreview` scaffold branch to `new-research.md` step 5**

In `.claude/commands/new-research.md` step 5, after the `**usability:**` bullet, add:

```
   - **`litreview` (evidence from documents):** also create
     `research/<...>/corpus/` (empty; user drops supplied PDFs/reports here — it is
     **gitignored**, never committed). Do **not** create `platforms/` or `data/`. The
     verified `evidence.md` is produced later by `/gather-evidence`, not here.
```

- [ ] **Step 6: Add the `litreview` plan/gate branch to `new-research.md` step 7**

In `.claude/commands/new-research.md` step 7, after the usability block, add:

```
   **Litreview** (the plan the Principal Researcher signs off on before any
   evidence gathering — gathering is expensive, so it waits for approval):
   - **Draft `PLAN.md`** (litreview template below): derive the research
     question(s) from the `## Goal`, list any corpus documents the user has already
     provided, propose search angles to fill gaps, and state inclusion criteria
     (what makes a source credible/relevant enough to cite).
   - **Dispatch the Principal Researcher (Mode A)** via the Agent tool
     (`general-purpose`) with `.claude/personas/principal-researcher.md`, the drafted
     `PLAN.md`, and the `README.md`. For litreview it checks: are the questions
     answerable *from literature*? are the search angles + inclusion criteria sound?
     is the provided corpus relevant and credible? It returns must-fixes.
   - **Revise `PLAN.md`** and **present it to the user for approval.** Then tell the
     user the next step is **`/gather-evidence`**, which runs the `deep-research`
     harness over the approved plan and writes the verified `evidence.md` +
     `sources.md`. **Do not** start gathering evidence here.
```

- [ ] **Step 7: Add the litreview `PLAN.md` template to `new-research.md`**

In `.claude/commands/new-research.md`, after the usability `PLAN.md` template block (ends at the `> Next: run /plan-usability …` line), add:

````
PLAN.md template — **litreview**:

```
# Research Plan: <Topic>

- **Status:** Draft (pending Principal Researcher review + user approval)
- **Type:** litreview
- **Goal it serves:** <one line — the confirmed goal from the README>

## Key research questions
- <question 1 derived from the goal — answerable from literature/reports>

## Provided corpus
- <document the user supplied, dropped in corpus/ — or "none yet; all sources to be found">

## Search angles
- <angle 1 — how /gather-evidence should search to fill gaps beyond the provided corpus>

## Inclusion criteria
- <what makes a source credible + relevant enough to cite (recency, venue, methodology, region)>

## Success criteria (what "done" looks like)
- <e.g. "each research question backed by ≥2 independent verified sources in evidence.md">

## Principal Researcher review
<filled in during step 7: critique summary + verdict, then user approval>

> Next: run `/gather-evidence` to run the deep-research harness over this plan and
> write the verified evidence.md + sources.md, before /synth-findings.
```
````

- [ ] **Step 8: Update the README template comment for the litreview section header**

In `.claude/commands/new-research.md`, in the README.md template, replace the section-header comment line:

```
## <Platforms to benchmark | Product & participants>        <!-- benchmark: platforms list; usability: product under test + participant profile -->
```
with:
```
## <Platforms to benchmark | Product & participants | Corpus & questions>   <!-- benchmark: platforms list; usability: product under test + participant profile; litreview: provided corpus + research questions -->
```

Also update the `**Type:**` template line from `<benchmark | usability>` to `<benchmark | usability | litreview>`.

- [ ] **Step 9: Mirror all of the above into the skill file**

Apply Steps 4–8 to `.agents/skills/new-research/SKILL.md` with the skill-tree conventions: bare command names (`gather-evidence`, not `/gather-evidence`), `deep-research` harness phrased the same, and keep the existing `Researcher: Gemini …` byline in its README template. The skill file already has an "Other research aside of platform benchmarks … use `data/`" bullet in its step 5 — leave that bullet intact and add the `litreview` → `corpus/` bullet alongside it.

- [ ] **Step 10: Verify litreview is wired into both files**

Run:
```bash
cd /c/research-workspace && for f in .claude/commands/new-research.md .agents/skills/new-research/SKILL.md; do echo "== $f =="; grep -c 'litreview' "$f"; grep -c 'corpus/' "$f"; done
```
Expected: each file reports a non-zero count for both `litreview` and `corpus/` (at least 4 and 2 respectively).

- [ ] **Step 11: Dry-run the scaffold logic manually**

Simulate a scaffold to confirm the template produces a valid tree (no command runtime exists, so build it by hand from the template and inspect):

```bash
cd /c/research-workspace && mkdir -p /tmp/litreview-dryrun/corpus && \
  printf '# Research Plan: Dry Run\n\n- **Type:** litreview\n\n## Key research questions\n- q1\n\n## Provided corpus\n- none yet\n\n## Search angles\n- a1\n\n## Inclusion criteria\n- c1\n\n## Success criteria\n- s1\n\n## Principal Researcher review\n' > /tmp/litreview-dryrun/PLAN.md && \
  ls -R /tmp/litreview-dryrun && rm -rf /tmp/litreview-dryrun && echo "DRYRUN OK"
```
Expected: shows `PLAN.md` + `corpus/` then `DRYRUN OK`. (This validates the template shape only; the real end-to-end run is Task 6.)

- [ ] **Step 12: Commit**

```bash
cd /c/research-workspace && git add .gitignore .claude/commands/new-research.md .agents/skills/new-research/SKILL.md && \
  git commit -m "feat(litreview): scaffold litreview type in /new-research + gitignore corpus/"
```

---

### Task 2: `/gather-evidence` — the litreview instrument step

Creates the new command + skill. Reads the approved `PLAN.md` and any `corpus/` documents, runs the `deep-research` harness, and writes a verified `evidence.md` + `sources.md`.

**Files:**
- Create: `.claude/commands/gather-evidence.md`
- Create: `.agents/skills/gather-evidence/SKILL.md`

**Interfaces:**
- Consumes: the litreview folder from Task 1 (`PLAN.md` with `## Key research questions` / `## Provided corpus` / `## Search angles` / `## Inclusion criteria`; `README.md` goal; `corpus/` documents). The `deep-research` skill (Skill tool) as the search→fetch→3-vote-verify harness.
- Produces: `sources.md` (every source `S1..Sn`, provenance `provided | found`, date accessed) and `evidence.md` (confirmed claims with `confidence` + `[S#]` IDs in a main section, refuted/weak claims in a separate `## Refuted / weak claims` section). Consumed by Task 3 (`/synth-findings` litreview branch).

- [ ] **Step 1: Write the failing verification**

Run — MUST fail, proving the command doesn't exist yet:

```bash
cd /c/research-workspace && test -f .claude/commands/gather-evidence.md && echo PASS || echo FAIL
```
Expected: `FAIL`

- [ ] **Step 2: Create the `/gather-evidence` command**

Write `.claude/commands/gather-evidence.md`:

````markdown
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
     label (High/Med/Low) and its `[S#]` source ID(s), e.g.
     `- Deferred onboarding lifts D1 activation (confidence: High) [S3][S7]`.
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
````

- [ ] **Step 3: Verify the command file assertion passes**

Run:
```bash
cd /c/research-workspace && test -f .claude/commands/gather-evidence.md && grep -q 'deep-research' .claude/commands/gather-evidence.md && grep -q 'evidence.md' .claude/commands/gather-evidence.md && echo PASS || echo FAIL
```
Expected: `PASS`

- [ ] **Step 4: Create the mirrored skill**

Write `.agents/skills/gather-evidence/SKILL.md` — same behaviour, skill-tree conventions (bare command names, YAML frontmatter `name:` + `description:` like the other SKILL.md files, no `argument-hint`):

````markdown
---
name: gather-evidence
description: (litreview studies) Run the deep-research harness over the approved plan and write a verified evidence.md + sources.md.
---

Gather and fact-check the evidence base for a **litreview** study — the litreview analogue of benchmark capture: the one method-specific step that produces the raw material `synth-findings` reads. It is expensive (multi-agent adversarial verification), so it runs **only after** the `PLAN.md` gate is approved.

Steps:

1. **Locate the study & confirm its type.** Resolve the target study per `.claude/references/active-research.md` (explicit `[folder]` arg, else this terminal's binding, else the sole active study, else ask). Read `README.md` and confirm `Type: litreview`. If it is not litreview, STOP — `gather-evidence` only applies to litreview studies. If the registry is empty, STOP and tell the user to run `new-research --type litreview` first.

2. **Check the plan gate.** Read `PLAN.md`. Confirm its `## Principal Researcher review` records an approved verdict (the Mode A gate from `new-research`). If the plan is still Draft/unapproved, STOP — the harness is expensive and must not run before approval.

3. **Read the inputs.** From `PLAN.md`: the research questions, provided corpus, search angles, inclusion criteria. From `README.md`: the goal. Read any documents in `corpus/` as anchor sources (`provided`; harness-found sources are `found`).

4. **Run the deep-research harness.** Invoke the `deep-research` skill (Skill tool) with a brief assembled from the research question(s) + corpus context + search angles + inclusion criteria. Let it fan out searches, fetch, and 3-vote adversarially verify. Fold `corpus/` documents in as anchor evidence.

5. **Write `sources.md`** — header `# Sources — <topic>`, table: ID | Source | URL | Provenance | Accessed | Notes; one row per `S1..Sn`.

6. **Write `evidence.md`** — `## Verified claims` (each with a confidence label + `[S#]` IDs) and `## Refuted / weak claims` (quarantined; never leak into findings).

7. **Update the README `## Log`** with a dated "evidence gathered" entry (source count, verified-vs-refuted counts).

8. **Report** verified-claim count, refuted/weak count, total sources (provided vs found), the two file paths, and the next step — `synth-findings`.

Never run before the plan gate. Never invent sources or claims. Keep refuted claims quarantined.
````

- [ ] **Step 5: Verify both files exist and parity holds**

Run:
```bash
cd /c/research-workspace && ls .claude/commands/gather-evidence.md .agents/skills/gather-evidence/SKILL.md && \
  for f in .claude/commands/gather-evidence.md .agents/skills/gather-evidence/SKILL.md; do echo "== $f =="; grep -c -e 'evidence.md' -e 'deep-research' -e 'Refuted' "$f"; done
```
Expected: both files listed; each reports non-zero matches.

- [ ] **Step 6: Commit**

```bash
cd /c/research-workspace && git add .claude/commands/gather-evidence.md .agents/skills/gather-evidence/SKILL.md && \
  git commit -m "feat(litreview): add /gather-evidence command + skill (deep-research evidence harness)"
```

---

### Task 3: `/synth-findings` — litreview synthesis branch

Adds the litreview branch to synthesis: read `evidence.md` + `sources.md`, write a themes → design-implications `SYNTHESIS.md`, run Principal Researcher Mode B adapted for a literature base.

**Files:**
- Modify: `.claude/commands/synth-findings.md`
- Modify: `.agents/skills/synth-findings/SKILL.md`

**Interfaces:**
- Consumes: `evidence.md` (`## Verified claims` with `[S#]` IDs + confidence; `## Refuted / weak claims`) and `sources.md` from Task 2; `README.md` (`Type: litreview`, goal).
- Produces: a `SYNTHESIS.md` with sections `## TL;DR`, `## Theme N — <name>` (findings with confidence + `[S#]` cites), `## Design implications` (numbered), `## Refuted / weak claims`, `## Evidence gaps for primary research`, `## Sources table (S1..Sn)`. Consumed by `/review-research`, `/brief-feature`, `/draft-spec` (which already read `Type:`).

- [ ] **Step 1: Write the failing verification**

Run — MUST fail, proving no litreview branch yet:

```bash
cd /c/research-workspace && grep -q 'litreview' .claude/commands/synth-findings.md && echo PASS || echo FAIL
```
Expected: `FAIL`

- [ ] **Step 2: Add the litreview evidence-gathering branch to step 2**

In `.claude/commands/synth-findings.md` step 2 ("Gather the evidence — by type"), after the Usability bullet add:

```
   - **Litreview:** read `README.md`, `sources.md`, and `evidence.md`. If there is no
     `evidence.md`, STOP and tell the user to run `/gather-evidence` first. Use only the
     `## Verified claims` as findings input; keep the `## Refuted / weak claims` aside to
     reproduce in the synthesis's own refuted section — never promote them to findings.
```

- [ ] **Step 3: Add the litreview synthesis template to step 3**

In `.claude/commands/synth-findings.md` step 3, after the Usability template block (before the "For **both** types, end with a `## Gaps & caveats`…" paragraph), add:

```
   **Litreview → themes → design implications.** Lead with a `## TL;DR`, then one
   `## Theme N — <name>` section per theme. Under each theme, list findings as bullets,
   each with a **confidence** label and its `[S#]` citation(s) traced to `evidence.md`,
   e.g. `- Deferred onboarding lifts activation (confidence: High) [S3][S7]`. After the
   themes, add a numbered `## Design implications` section (what each theme means for
   what we build), a `## Refuted / weak claims` section (reproduced from `evidence.md`,
   kept out of the findings), a `## Evidence gaps for primary research` section (what the
   literature could not answer and needs a survey/usability study), and a
   `## Sources table (S1..Sn)` mirroring `sources.md`. Every finding MUST trace to a
   source in `evidence.md`; confidence labels are honest; no generalization beyond what
   the sources support; no fabricated sources or findings.
```

- [ ] **Step 4: Extend the Mode B QA note in step 4 to cover litreview**

In `.claude/commands/synth-findings.md` step 4, in the sentence that hands the Principal Researcher the type's source material, replace:

```
   the type's source material (benchmark: every `platforms/*/notes.md` and
   `platforms/*/flow.md`; usability: `test-plan.md` and every
   `sessions/session-*.md`).
```
with:
```
   the type's source material (benchmark: every `platforms/*/notes.md` and
   `platforms/*/flow.md`; usability: `test-plan.md` and every
   `sessions/session-*.md`; litreview: `evidence.md` and `sources.md`).
```

And in the "Tell it the research **type** so it checks the right required fields" clause, extend it:

```
(the five feature fields, or the four finding fields + severity-ordering, or — for
litreview — every finding tracing to a source in `evidence.md`, honest confidence
labels, refuted claims excluded from findings, and no over-generalization).
```

- [ ] **Step 5: Mirror Steps 2–4 into the skill file**

Apply the same three edits to `.agents/skills/synth-findings/SKILL.md` (bare command names: `gather-evidence`, `review-research`).

- [ ] **Step 6: Verify the branch is wired into both files**

Run:
```bash
cd /c/research-workspace && for f in .claude/commands/synth-findings.md .agents/skills/synth-findings/SKILL.md; do echo "== $f =="; grep -c -e 'litreview' -e 'evidence.md' -e 'Design implications' "$f"; done
```
Expected: each file reports non-zero for all three.

- [ ] **Step 7: Commit**

```bash
cd /c/research-workspace && git add .claude/commands/synth-findings.md .agents/skills/synth-findings/SKILL.md && \
  git commit -m "feat(litreview): add themes->implications synthesis branch to /synth-findings"
```

---

### Task 4: Downstream spine — `/review-research`, `/close-research`, `/research-board`, `/publish-research`

Make the rest of the shared spine type-aware for litreview with the minimal branches the spec calls for.

**Files:**
- Modify: `.claude/commands/review-research.md` + `.agents/skills/review-research/SKILL.md`
- Modify: `.claude/commands/close-research.md` + `.agents/skills/close-research/SKILL.md`
- Modify: `.claude/commands/research-board.md` + `.agents/skills/research-board/SKILL.md`
- Modify: `.claude/commands/publish-research.md` + `.agents/skills/publish-research/SKILL.md`

**Interfaces:**
- Consumes: a litreview `SYNTHESIS.md` (from Task 3) and `evidence.md`/`sources.md` (from Task 2); `README.md` `Type: litreview`.
- Produces: type-aware behaviour — review debate anchored to the evidence base; `/close-research` harvesting *evidence-based design principles* (or nothing) into `PATTERNS.md`; board rendering litreview studies; publish verifying `corpus/` is gitignored.

- [ ] **Step 1: Write the failing verification**

Run — MUST fail, proving none of the four handle litreview yet:

```bash
cd /c/research-workspace && grep -l 'litreview' .claude/commands/review-research.md .claude/commands/close-research.md .claude/commands/publish-research.md 2>/dev/null | wc -l
```
Expected: `0`

- [ ] **Step 2: Add the litreview debate anchor to `/review-research`**

In `.claude/commands/review-research.md`, in the "Anchor the debate to the `Type` + `## Goal`" block that lists benchmark and usability foci, add a litreview bullet:

```
   - **litreview** — does every finding trace to a verified source in `evidence.md`?
     are confidence labels justified by the cited evidence (not overstated)? are
     refuted/weak claims correctly kept out of the findings? do the design
     implications actually follow from the evidence, without over-generalization?
```

Update the evidence-reading line (currently benchmark/usability only) to add: `litreview: `evidence.md` + `sources.md``.

- [ ] **Step 3: Add the litreview principle-harvest note to `/close-research`**

In `.claude/commands/close-research.md` step 3 ("Update the pattern library (Principal Designer)"), append to that step:

```
   For a **litreview** study the Principal Designer harvests **evidence-based design
   principles** into `PATTERNS.md` (not observed UI patterns). It must **not force UI
   patterns where there are none** — a litreview study often has no interface to
   observe. If the synthesis yields no genuine, evidence-grounded principle, it records
   that plainly and adds nothing to `PATTERNS.md`; it never invents a pattern to fill
   the slot.
```

- [ ] **Step 4: Make `/publish-research` verify `corpus/` is gitignored**

In `.claude/commands/publish-research.md`, in the PII/safety-check step, add a litreview guard:

```
   - **Litreview corpus guard:** if the study is `Type: litreview`, confirm `corpus/`
     is not staged (it must stay gitignored via `research/*/corpus/`). If any
     `research/*/corpus/*` file is tracked or staged, STOP and tell the user — supplied
     source documents (copyright/PII) must never be pushed. Only `sources.md` records
     what was used.
```

- [ ] **Step 5: Make `/research-board` tolerate the litreview type**

In `.claude/commands/research-board.md`, wherever it describes deriving a row from each study's `README.md` `Type`, confirm litreview studies render (add `litreview` to any explicit type list; if the board reads `Type:` generically, add a one-line note that `litreview` is a valid type shown like the others). Make the same edit to the skill copy.

- [ ] **Step 6: Mirror Steps 2–5 into the four skill files**

Apply each edit to the corresponding `.agents/skills/<x>/SKILL.md` with bare-command-name conventions.

- [ ] **Step 7: Verify all four commands (and skills) reference litreview**

Run:
```bash
cd /c/research-workspace && grep -c litreview \
  .claude/commands/review-research.md .claude/commands/close-research.md \
  .claude/commands/publish-research.md .claude/commands/research-board.md \
  .agents/skills/review-research/SKILL.md .agents/skills/close-research/SKILL.md \
  .agents/skills/publish-research/SKILL.md .agents/skills/research-board/SKILL.md
```
Expected: every listed file reports `>= 1`.

- [ ] **Step 8: Commit**

```bash
cd /c/research-workspace && git add .claude/commands/review-research.md .claude/commands/close-research.md .claude/commands/publish-research.md .claude/commands/research-board.md .agents/skills/review-research/SKILL.md .agents/skills/close-research/SKILL.md .agents/skills/publish-research/SKILL.md .agents/skills/research-board/SKILL.md && \
  git commit -m "feat(litreview): make review/close/board/publish spine type-aware for litreview"
```

---

### Task 5: Operating guides — `CLAUDE.md` + `GEMINI.md`

Reframe the guides from "two kinds of research" to three, add the `litreview` rows to the type + command tables, and add a Litreview sourcing-standards subsection.

**Files:**
- Modify: `CLAUDE.md`
- Modify: `GEMINI.md`

**Interfaces:**
- Consumes: the finished command/skill behaviour from Tasks 1–4 (the docs describe what now exists).
- Produces: guides that present benchmark / usability / litreview as peers — the "light CLAUDE.md reframe" the spec requires.

- [ ] **Step 1: Write the failing verification**

Run — MUST fail:

```bash
cd /c/research-workspace && grep -q 'litreview' CLAUDE.md && grep -q 'litreview' GEMINI.md && echo PASS || echo FAIL
```
Expected: `FAIL`

- [ ] **Step 2: Reframe the intro line in `CLAUDE.md`**

Replace `CLAUDE.md` line 5:
```
A **UX-research** workspace. It does two kinds of research and turns both into
```
with:
```
A **UX-research** workspace. It does three kinds of research and turns each into
```

If the following clause enumerates the two kinds, extend it to name litreview (evidence synthesis from documents) as the third.

- [ ] **Step 3: Add the `litreview` row to the Research types table in `CLAUDE.md`**

In the `## Research types (the type-aware spine)` table, insert after the `usability` row and before the `survey` row:

```
| `litreview` | `/gather-evidence` runs the `deep-research` harness over the plan | `corpus/` (gitignored) + `evidence.md` | Themes → design implications |
```

- [ ] **Step 4: Note the second method-specific command**

In `CLAUDE.md`, the line "The instrument-design step is the only method-specific command (`/plan-usability` for usability)." — update it to name both:

```
The method-specific instrument steps are `/plan-usability` (usability) and
`/gather-evidence` (litreview); everything else on the spine is shared and type-aware.
```

- [ ] **Step 5: Add rows to the Workflow commands table in `CLAUDE.md`**

Update the `/new-research` row's argument hint to `[--type benchmark\|usability\|litreview]`. Then add a `/gather-evidence` row after the `/plan-usability` row:

```
| `/gather-evidence [folder]` | *(litreview studies)* Runs the `deep-research` harness over the approved `PLAN.md` (research questions + `corpus/`), then writes a verified `evidence.md` (confirmed claims with confidence + `[S#]` IDs; refuted claims quarantined) and `sources.md`. Runs only after the plan gate. |
```

- [ ] **Step 6: Add the Litreview sourcing standards subsection to `CLAUDE.md`**

After the Research types section, add:

```
### Litreview sourcing standards
- User-supplied documents go in the study's `corpus/`, which is **gitignored**
  (`research/*/corpus/`) — copyrighted/PII source files are never committed.
- Every source is logged in `sources.md` with its provenance (`provided` | `found`)
  and access date, as `S1..Sn`.
- Claims are verified via the `deep-research` harness (search → fetch → 3-vote) into
  `evidence.md`; refuted/weak claims are quarantined and never promoted to findings.
- Confidence labels are honest; no fabricated sources or findings; no generalization
  beyond what the cited evidence supports.
```

- [ ] **Step 7: Apply the equivalent edits to `GEMINI.md`**

`GEMINI.md` has the parallel structure (intro, `--type` handling in `new-research`, scaffold-by-type, capture/synthesis sections). Add litreview everywhere its siblings appear:
- the `--type <benchmark | usability>` mentions → add `| litreview`;
- the scaffold-by-type rule → add "`litreview` → `corpus/` (gitignored)" alongside the existing `platforms/` / `data/` / `sessions/` rule;
- add a short "Gathering Evidence (`litreview` Studies)" subsection paralleling the "Capturing Evidence (`benchmark` Studies)" one, describing the `deep-research` harness → `evidence.md` + `sources.md`;
- the synthesis section → add the litreview themes → implications branch.

- [ ] **Step 8: Verify both guides present all three types**

Run:
```bash
cd /c/research-workspace && for f in CLAUDE.md GEMINI.md; do echo "== $f =="; grep -c -e 'litreview' -e 'gather-evidence' -e 'corpus/' "$f"; done
```
Expected: each guide reports non-zero for all three.

- [ ] **Step 9: Commit**

```bash
cd /c/research-workspace && git add CLAUDE.md GEMINI.md && \
  git commit -m "docs(litreview): reframe guides to three research types; document /gather-evidence + sourcing standards"
```

---

### Task 6: End-to-end verification + re-type an existing study

Exercise the whole litreview spine for real against the spec's success criteria, and re-type the active `2026-07-17-certificate-vs-badge-gamification` study (a literature-review-shaped study currently typed `benchmark`) to `litreview` now that the type exists.

**Files:**
- Modify: `research/2026-07-17-certificate-vs-badge-gamification/README.md` (and `PLAN.md`) — re-type to litreview
- (Verification only) the command/skill files from Tasks 1–5

**Interfaces:**
- Consumes: everything built in Tasks 1–5.
- Produces: a confirmed end-to-end litreview run + one real litreview study on disk.

- [ ] **Step 1: Confirm the study's current type and shape**

```bash
cd /c/research-workspace && head -6 research/2026-07-17-certificate-vs-badge-gamification/README.md && ls research/2026-07-17-certificate-vs-badge-gamification/
```
Expected: `Type: benchmark`, files `PLAN.md README.md references.md sources.md` (+ empty `platforms/`). Confirm with the user that re-typing this study to `litreview` is desired before editing it (it is the active study).

- [ ] **Step 2: Re-type the study to litreview**

In `research/2026-07-17-certificate-vs-badge-gamification/README.md`, change `**Type:** benchmark  _(literature review + light platform benchmark)_` to `**Type:** litreview`. In its `PLAN.md`, change the `**Type:**` line to `litreview` and reshape its sections to the litreview `PLAN.md` template (`## Key research questions`, `## Provided corpus`, `## Search angles`, `## Inclusion criteria`, `## Success criteria`, `## Principal Researcher review`), preserving the existing content. Remove the now-unused empty `platforms/` directory; create an empty `corpus/`. Add a dated `## Log` entry: "re-typed benchmark → litreview after type implemented."

- [ ] **Step 3: Verify the study is a valid litreview folder**

```bash
cd /c/research-workspace && d=research/2026-07-17-certificate-vs-badge-gamification && \
  grep -q 'Type:.*litreview' $d/README.md && test -d $d/corpus && ! test -d $d/platforms && echo PASS || echo FAIL
```
Expected: `PASS`

- [ ] **Step 4: Run the live spine end-to-end (with the user)**

Drive the real workflow against this study and confirm each success criterion from the spec:
- `/gather-evidence` on the study → produces a committed-shape `sources.md` + `evidence.md` with refuted claims quarantined. (Confirm `evidence.md` has both `## Verified claims` and `## Refuted / weak claims`.)
- `/synth-findings` → produces a `SYNTHESIS.md` with `## TL;DR`, `## Theme …`, numbered `## Design implications`, `## Evidence gaps for primary research`, and a sources table; passes Mode B.
- Confirm benchmark/usability studies are unaffected: open one existing benchmark study and re-read its `README.md` `Type` and folder shape — unchanged.

```bash
cd /c/research-workspace && d=research/2026-07-17-certificate-vs-badge-gamification && \
  test -f $d/evidence.md && grep -q 'Verified claims' $d/evidence.md && grep -q 'Refuted' $d/evidence.md && \
  test -f $d/SYNTHESIS.md && grep -q 'Design implications' $d/SYNTHESIS.md && echo E2E-PASS || echo E2E-INCOMPLETE
```
Expected (after the live run): `E2E-PASS`.

- [ ] **Step 5: Confirm `corpus/` never gets committed**

```bash
cd /c/research-workspace && printf 'dummy source pdf placeholder\n' > research/2026-07-17-certificate-vs-badge-gamification/corpus/_probe.txt && \
  git status --porcelain research/2026-07-17-certificate-vs-badge-gamification/corpus/ ; echo "--- (expect NO output above = ignored) ---" ; \
  rm research/2026-07-17-certificate-vs-badge-gamification/corpus/_probe.txt
```
Expected: no lines between the command and the `---` marker (the probe file is gitignored).

- [ ] **Step 6: Commit the re-typed study**

```bash
cd /c/research-workspace && git add research/2026-07-17-certificate-vs-badge-gamification/ && \
  git commit -m "chore(research): re-type certificate-vs-badge study benchmark -> litreview; run evidence + synthesis"
```

- [ ] **Step 7: Refresh the board**

Run `/research-board` (or hand-update `BOARD.md`) so the study shows as `litreview`. Confirm `BOARD.md` renders the type. Commit if `BOARD.md` changed:

```bash
cd /c/research-workspace && git add BOARD.md && git commit -m "docs(board): reflect litreview type on certificate-vs-badge study" || echo "no board change"
```

---

## Self-Review

**Spec coverage** (against `2026-07-16-litreview-research-type-design.md`):
- Folder scaffold (corpus/ gitignored, sources.md, evidence.md, SYNTHESIS.md) → Task 1 (scaffold + gitignore) + Task 2 (evidence.md) + Task 3 (SYNTHESIS.md). ✅
- New `/gather-evidence` command (5-step behaviour, deep-research, runs after plan gate) → Task 2. ✅
- Synthesis format (litreview branch: TL;DR / themes / implications / refuted / gaps / sources) → Task 3. ✅
- Quality gates: Mode A (new-research) → Task 1 step 6; Mode B (synth) → Task 3 step 4; Principal Designer principle-harvest (close) → Task 4 step 3. Persona specs unchanged, only inputs extend — honored (no persona files edited). ✅
- Edits to existing commands: `/new-research` → T1; `/synth-findings` → T3; `/research-board`, `/publish-research` → T4; `/brief-feature`/`/draft-spec`/`/design-prototype` "tolerate only, no v1 branch" → explicitly out of scope, no task (correct). ✅
- Doc & config edits: CLAUDE.md reframe + tables + sourcing standards → T5; `.gitignore` corpus → T1. GEMINI.md parallel → T5. ✅
- Success criteria (scaffold+gate; gather-evidence output; synth output; close principles; benchmark/usability unaffected) → Task 6. ✅
- Out of scope items (no draft-spec/design-prototype branch, no persona spec change, no AUDIENCE-CONTEXT migration, survey/abtest stay planned) → respected; none appear as tasks. ✅

**Placeholder scan:** No "TBD"/"handle appropriately"/"similar to Task N" left; the two genuinely new artifacts (`/gather-evidence` command + skill) are written out verbatim; all modification steps quote exact old→new text or the exact block to insert. Verification steps are real runnable commands with expected output. ✅

**Type consistency:** Section names are stable across tasks — `## Key research questions`, `## Provided corpus`, `## Search angles`, `## Inclusion criteria` (PLAN.md, T1) are exactly the inputs `/gather-evidence` reads (T2 step 3); `evidence.md`'s `## Verified claims` / `## Refuted / weak claims` (T2) are exactly what `/synth-findings` consumes and reproduces (T3); `[S#]` source-ID convention is consistent T2→T3→review (T4). ✅
