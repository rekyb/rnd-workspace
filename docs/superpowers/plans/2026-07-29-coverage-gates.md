# Coverage Gates Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make omission fail as loudly as fabrication already does — every research question must be visibly answered or visibly not, and every finding must be visibly adopted or visibly not.

**Architecture:** Two stable ID schemes (`Q#` for research questions, `F#` for findings) are threaded through the existing pipeline. Each hop gains a table keyed on those IDs, and the two review personas gain a set-comparison criterion against them. No new commands, no new scripts, one new reference file.

**Tech Stack:** Markdown instruction files under `.claude/` (slash-command skills, personas, references) plus `CLAUDE.md`. No application code, no test framework.

**Source spec:** `docs/superpowers/specs/2026-07-29-coverage-gates-design.md`

## How "tests" work in this repo

This workspace has no test runner — the artifacts are markdown instructions read by an
agent at runtime. The honest analogue of a test cycle is a **verification command whose
output is checked against a stated expectation**. Every task below therefore follows:

1. Write the verification command and run it — it must **fail** (the content is absent).
2. Make the edit.
3. Run the same command — it must **pass**.
4. Commit.

Verification commands use `Grep`/`rg` or `Read`. Where a check is a judgment rather than a
string match ("does this instruction actually make sense in context?"), the step says so
explicitly and asks for a read-through instead of pretending a grep covers it.

## Global Constraints

- **Declare-or-block is the governing principle.** An unanswered question or an unadopted finding passes every gate *if recorded with a reason*. Only silence fails. Never write an instruction that blocks an honest `Unanswered` or `Deferred`.
- **`Q#` and `F#` are never renumbered and never reused.** A dropped question becomes a `Withdrawn` row.
- **PRD coverage unit is type-aware:** benchmark → one row per feature; usability → one row per finding; litreview → one row per numbered design implication.
- **No new artifacts** beyond `.claude/references/coverage-contract.md`. No `COVERAGE.md` ledger. No `check-coverage.ps1`.
- **Retrofit is pay-as-you-go.** Closed studies are marked `unverified`; a coverage table is added only when a PRD actually cites the study.
- **Commands and personas reference the contract file; they do not restate its vocabularies.** Duplicated vocabulary is how these drift.
- **Do not touch** `/brief-feature`, `/export-prototype`, `/heuristic-eval`, `/a11y-audit`, `/extract-tokens`, `ui-library/`, or any file under `research/*/` other than the README lines in Task 8.
- **Commit trailer** (every commit in this plan):
  ```
  Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
  Claude-Session: https://claude.ai/code/session_01N3TCfWSa1NRtznkMHwKDdF
  ```
- Git identity for this repo is name `Claude Code`, email `rekybongso@gmail.com`. Do not change it.

---

## Task 0: Branch

**Files:** none

- [ ] **Step 1: Confirm the working tree state**

Run: `git -C C:/rnd-workspace status --short`

Expected: the pre-existing modifications (`.claude/.active-research`, `BOARD.md`, `research/2026-07-28-*/`) and the prompt-vocabulary changes from the prior session. Do **not** revert or commit those — they are unrelated work in progress.

- [ ] **Step 2: Create the branch**

The repo's default branch is `main`. Do not commit this work to `main`.

```bash
git -C C:/rnd-workspace checkout -b feat/coverage-gates
```

Expected: `Switched to a new branch 'feat/coverage-gates'`

---

## Task 1: The coverage contract reference

Everything else in this plan points at this file, so it lands first.

**Files:**
- Create: `.claude/references/coverage-contract.md`

**Interfaces:**
- Produces: the `Q#`/`F#` ID rules; the three vocabularies `Answerable?`, synthesis `Status`, PRD `Disposition`; the `Coverage:` README line format; the `unverified` legacy rule. Every later task cites this file by path rather than repeating these definitions.

- [ ] **Step 1: Verify the file does not exist**

Run: `ls .claude/references/`

Expected: `active-research.md`, `design-gates.md`, `design-projects.md`, `design-system.md`, `mobbin-sourcing.md`, `prompt-vocabulary.md` — and **no** `coverage-contract.md`.

- [ ] **Step 2: Create `.claude/references/coverage-contract.md`**

Write exactly this content:

````markdown
# Coverage contract — how a question reaches an answer, and a finding reaches a build

The workspace's guardrails are all aimed at **fabrication**: never invent a finding, never
invent a source, every screen traces to a slice. They work. What they do not catch is
**omission** — a research question that quietly went unanswered, or a finding that quietly
never reached the product.

This contract is the recall half. It defines two ID schemes and three vocabularies, and one
principle that governs all of them.

## The principle: declare or block

An unanswered question is legitimate research. An unadopted finding is legitimate design.
**Neither fails a gate.** What fails is leaving it out.

- `Unanswered — no funnel access; carried to a future study` → **passes.**
- The question simply missing from the table → **fails.**

Every gate below is a set comparison, not a quality judgment. It asks *is this accounted
for*, never *is this good enough*.

## `Q#` — research question IDs

Assigned in the study's `PLAN.md`. Stable for the life of the study.

- **Never renumbered. Never reused.** A question dropped during plan revision becomes a
  `Withdrawn` row with its reason; it does not disappear.
- Rationale: `SYNTHESIS.md`, the study README's `Coverage:` line, and any citing `PRD.md`
  all refer to questions by ID. Renumbering silently rots every one of those references.

## `F#` — finding IDs

Assigned in the study's `SYNTHESIS.md`, one per top-level item. Which item is top-level
depends on the study type:

| Study type | `F#` attaches to |
|---|---|
| `benchmark` | each feature write-up |
| `usability` | each finding |
| `litreview` | each numbered **design implication** (themes keep their own numbering) |

Implemented as a heading prefix: `## F1 — Value-before-signup (deferred registration)`.

The type-awareness matters: a litreview's themes are analysis, but its design implications
are what a PRD can actually adopt or defer, so the implication is the unit that must be
accounted for.

## Vocabulary 1 — `Answerable?` (in `PLAN.md`)

Set at plan time, before any capture is spent.

| Value | Means |
|---|---|
| `Yes` | The stated method can produce evidence that answers this question. |
| `Partial — <what is missing>` | The method gets part of the way; name the gap. |
| `No — deferred to <what would answer it>` | This study cannot answer it. Name what would. |
| `Withdrawn — <reason>` | Dropped during plan revision. The ID is retired, not reused. |

The Principal Researcher (Mode A) will not approve a plan carrying an unmarked
unanswerable question. Canonical mismatches to catch:

- a causal *why* asked of purely observational capture;
- live system behaviour asked of Mobbin stills (the C1–C5 triggers in
  `mobbin-sourcing.md` are the specific case of this general rule);
- our own product's funnel asked of a benchmark of other products.

## Vocabulary 2 — `Status` (in `SYNTHESIS.md`)

Set at synthesis time, one row per `Q#`.

| Value | Requires |
|---|---|
| `Answered` | at least one `F#` that actually addresses the question |
| `Partial` | an `F#` **and** a statement of what is still missing |
| `Unanswered` | a reason **and** a destination (`## Gaps & caveats`, or `## Evidence gaps for primary research`) |
| `Withdrawn` | carried through from the plan, with its reason |

A `Status` may not be more generous than the plan's `Answerable?` value unless the row says
what changed. A question planned as `No — deferred` that comes back `Answered` is either a
genuine bonus (say so) or an over-claim (the reviewer's job to catch).

## Vocabulary 3 — `Disposition` (in `PRD.md` §2.1)

Set when a PRD cites a study, one row per `F#` of every study in `Informed by:`.

| Value | Requires |
|---|---|
| `Adopted` | names a Slice N that exists in §8 |
| `Deferred` | points at a §Non-Goals entry that carries the reason |
| `Rejected` | a reason — the finding does not apply here, or we disagree with it |
| `Contradicted` | a reason — we deliberately do the opposite |

**Silence is not a disposition.** A finding with no row is the failure the whole contract
exists to catch.

`Contradicted` is deliberately distinct from `Rejected`: rejecting says the finding does not
bear on this build; contradicting says it does and we are going the other way anyway. The
second needs a louder reason, and a reader six months later needs to be able to tell them
apart.

## The `Coverage:` line

Written into the study's `README.md` header by `/close-research`, so the design half never
has to parse a synthesis to learn how conclusive a study was:

```
- **Coverage:** Q1,Q2,Q4 answered · Q3 partial · Q5 unanswered (deferred to primary research)
```

## Legacy studies and the pay-as-you-go retrofit

Studies closed before 2026-07-29 carry:

```
- **Coverage:** unverified (pre-2026-07-29 study)
```

They are **not** retrofitted in bulk, and they are **not** deleted. Their captures are the
expensive, perishable artifact and are not what is defective; `research/PATTERNS.md` traces
every entry to a closed study, so deleting studies would leave the pattern library's
provenance dangling.

Instead, `/draft-prd` enforces the retrofit at the only moment it matters. A PRD citing an
`unverified` study must take one of two paths:

1. **Retrofit** — build that study's coverage table now (roughly 15 minutes: read its
   `PLAN.md` questions, map each to the synthesis sections that answer it), then cite it
   normally; or
2. **Demote** — cite it with the §2 claims that rest on it explicitly labelled assumptions
   with validation paths.

Studies nobody cites cost nothing. A study whose retrofit reveals it answered one question
out of five has just told you something worth knowing, and *that* is when redoing it is an
informed decision rather than a guess.
````

- [ ] **Step 3: Verify the file exists and carries all three vocabularies**

Run:
```bash
rg -c "Answerable\?|^\| `Answered`|^\| `Adopted`" .claude/references/coverage-contract.md
```

Expected: a non-zero count, and a read-through confirming the three vocabulary tables, the `Q#`/`F#` rules, the `Coverage:` line format, and the legacy rule are all present.

- [ ] **Step 4: Commit**

```bash
git -C C:/rnd-workspace add .claude/references/coverage-contract.md
git -C C:/rnd-workspace commit -m "$(cat <<'EOF'
docs: add the coverage contract reference

Defines the Q#/F# ID schemes, the three coverage vocabularies, the
Coverage: README line, and the pay-as-you-go retrofit rule for legacy
studies. Every command and persona edit that follows references this
file rather than restating it.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01N3TCfWSa1NRtznkMHwKDdF
EOF
)"
```

---

## Task 2: `/new-research` — research-question tables in all three PLAN templates

**Files:**
- Modify: `.claude/commands/new-research.md` (three template blocks: benchmark at the `## Key research questions` heading, usability at `## Objectives & research questions`, litreview at `## Key research questions`)

**Interfaces:**
- Consumes: the `Answerable?` vocabulary from `.claude/references/coverage-contract.md`.
- Produces: `Q#` IDs in every new study's `PLAN.md` — the input Task 4 (`/synth-findings`) and Task 3 (Mode A) both rely on.

- [ ] **Step 1: Verify the templates carry no question IDs today**

Run: `rg -n "Q1|Answerable" .claude/commands/new-research.md`

Expected: **no matches.**

- [ ] **Step 2: Replace the benchmark template's question section**

Find:
```
## Key research questions
- <question 1 derived from the goal>
```

Replace with:
```
## Research questions

Each question gets a stable ID. IDs are never renumbered and never reused — a dropped
question becomes a `Withdrawn` row. See `.claude/references/coverage-contract.md`.

| ID | Question | Method that will answer it | Answerable by this study? |
|---|---|---|---|
| Q1 | <question derived from the goal> | <e.g. Mobbin capture across 4 platforms> | Yes |
```

- [ ] **Step 3: Replace the usability template's question section**

Find:
```
## Objectives & research questions
- <what decision this test informs>
- <question 1 the test must answer>
```

Replace with:
```
## Objectives & research questions

- <what decision this test informs>

Each question gets a stable ID, carried through to `test-plan.md` tasks and the synthesis
coverage table. See `.claude/references/coverage-contract.md`.

| ID | Question | Method that will answer it | Answerable by this study? |
|---|---|---|---|
| Q1 | <question the test must answer> | <e.g. moderated task 2, think-aloud> | Yes |
```

- [ ] **Step 4: Replace the litreview template's question section**

Find:
```
## Key research questions
- <question 1 derived from the goal — answerable from literature/reports>
```

Replace with:
```
## Research questions

Each question gets a stable ID, carried into `evidence.md` claims and the synthesis
coverage table. See `.claude/references/coverage-contract.md`.

| ID | Question | Method that will answer it | Answerable by this study? |
|---|---|---|---|
| Q1 | <question derived from the goal> | <e.g. deep-research over corpus + search angle 2> | Yes |
```

- [ ] **Step 5: Add the answerability instruction to the drafting step**

Append this paragraph to **step 7** (`**Draft the plan and run the quality gate — by type.**`, at roughly line 80):

```
   **Give every research question an ID and an honest `Answerable?` value.** A question
   this study's method cannot answer is not a defect in the question — it is a fact worth
   knowing *before* capture is spent. Mark it `No — deferred to <what would answer it>`
   and either carry it or drop it. The Principal Researcher will not approve a plan with
   an unmarked unanswerable question. See `.claude/references/coverage-contract.md`.
```

- [ ] **Step 6: Verify all three templates now carry the table**

Run: `rg -c "Answerable by this study" .claude/commands/new-research.md`

Expected: `3`

Run: `rg -n "coverage-contract" .claude/commands/new-research.md`

Expected: 4 matches (three templates plus the drafting step).

- [ ] **Step 7: Commit**

```bash
git -C C:/rnd-workspace add .claude/commands/new-research.md
git -C C:/rnd-workspace commit -m "$(cat <<'EOF'
feat(new-research): give research questions stable IDs and an answerability check

All three PLAN.md templates now carry a Q#-keyed question table with the
method that will answer each question and whether this study can answer
it at all. Catches an unanswerable question before capture is spent.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01N3TCfWSa1NRtznkMHwKDdF
EOF
)"
```

---

## Task 3: Principal Researcher Mode A — the answerability criterion

**Files:**
- Modify: `.claude/personas/principal-researcher.md` (Mode A, the numbered judgment criteria — `2. **Coverage**` is at roughly line 44)

**Interfaces:**
- Consumes: the `Answerable?` vocabulary (Task 1), `Q#` IDs in `PLAN.md` (Task 2).
- Produces: nothing downstream depends on this; it is a pure gate.

- [ ] **Step 1: Verify Mode A has no answerability criterion**

Run: `rg -n "answerab" .claude/personas/principal-researcher.md`

Expected: **no matches.**

- [ ] **Step 2: Read Mode A's criteria list**

Read `.claude/personas/principal-researcher.md` lines 30–75. Note the numbered criteria (`2. **Coverage**` covers *platforms and flows*, which is a different thing from question answerability) and the verdict format at roughly line 70.

- [ ] **Step 3: Insert the new criterion**

Immediately after the `2. **Coverage**` criterion and before the next numbered item, insert:

```
3. **Answerability** — for each `Q#` in the plan's question table, can the *stated method*
   actually produce evidence that answers it? Flag every mismatch. The recurring ones:
   - a causal **why** asked of purely observational capture (screenshots show what a
     screen does, never why a user left);
   - live system behaviour asked of Mobbin stills — the C1–C5 triggers in
     `.claude/references/mobbin-sourcing.md` are the specific case of this general rule;
   - **our own** product's funnel or drop-off asked of a benchmark of *other* products.

   A mismatch is not a reason to reject the plan. It is a reason to mark the question
   `Partial` or `No — deferred to <what would answer it>` and either carry it to a future
   study or drop it. **You may not return *approve* while an unanswerable question sits
   marked `Yes`.** This is the cheapest point in the whole pipeline to catch it: after
   this, the capture budget is already spent. See
   `.claude/references/coverage-contract.md`.
```

Renumber the subsequent criteria in Mode A accordingly.

- [ ] **Step 4: Verify**

Run: `rg -n "Answerability|coverage-contract" .claude/personas/principal-researcher.md`

Expected: the new criterion heading plus the contract reference.

Then **read Mode A end to end** and confirm the criteria are sequentially numbered with no duplicate or skipped number. A grep cannot check this.

- [ ] **Step 5: Commit**

```bash
git -C C:/rnd-workspace add .claude/personas/principal-researcher.md
git -C C:/rnd-workspace commit -m "$(cat <<'EOF'
feat(principal-researcher): add the answerability criterion to Mode A

The plan review now checks that each question's stated method can
actually produce evidence for it, and cannot approve a plan with an
unanswerable question still marked Yes.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01N3TCfWSa1NRtznkMHwKDdF
EOF
)"
```

---

## Task 4: `/synth-findings` — read the plan, cover the questions, ID the findings

The load-bearing task. Adding a section is cosmetic; making the synthesis *start from the
questions* is what stops it being shaped only by what was found.

**Files:**
- Modify: `.claude/commands/synth-findings.md` (step 2 "Gather the evidence", step 3 "Write `SYNTHESIS.md`" and its three type templates, step 8 "Report")

**Interfaces:**
- Consumes: `Q#` IDs from `PLAN.md` (Task 2), the `Status` vocabulary (Task 1).
- Produces: the `## Research questions — coverage` section and `F#`-prefixed headings that Tasks 5, 7, 9 and 10 all read.

- [ ] **Step 1: Verify `PLAN.md` is not currently an input**

Run: `rg -n "PLAN\.md" .claude/commands/synth-findings.md`

Expected: **no matches.** This is the defect being fixed.

- [ ] **Step 2: Add `PLAN.md` to step 2's gather instruction**

In step 2 (`**Gather the evidence — by type.**`), insert this as the first bullet, before the `- **Benchmark:**` bullet:

```
   - **All types — read `PLAN.md` first.** Its research-question table is the spine of
     this synthesis: you are writing the answers to those questions, not a tour of
     whatever the capture happened to show. Note every `Q#` and its `Answerable?` value.
     If `PLAN.md` has no question table (a study created before the coverage contract),
     STOP and offer to build one from its prose questions — assigning IDs in the order
     they appear — before continuing.
```

- [ ] **Step 3: Add the coverage section to step 3, before the type branches**

In step 3, immediately after the line `3. **Write `SYNTHESIS.md`** in the research folder, using the template for the type.` and before `**Benchmark → a list of features.**`, insert:

```
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
```

- [ ] **Step 4: Update the three type templates to carry `F#`**

In the **Benchmark** paragraph, change:
```
   platforms studied, headline takeaways), then one `##` section per feature. Every
```
to:
```
   platforms studied, headline takeaways), then the coverage table, then one `## F<n> — <feature name>`
   section per feature. Every
```

In the **Usability** paragraph, change:
```
   (task success rates, SEQ/SUS, time-on-task — a small table). Then one `##` section
   per finding, **ordered by severity, highest first.** Every finding MUST have, in
```
to:
```
   (task success rates, SEQ/SUS, time-on-task — a small table), then the coverage table.
   Then one `## F<n> — <finding name>` section per finding, **ordered by severity, highest
   first** (so `F1` is the most severe). Every finding MUST have, in
```

In the **Litreview** paragraph, change:
```
   themes, add a numbered `## Design implications` section (what each theme means for
   what we build),
```
to:
```
   themes, add a numbered `## Design implications` section where each implication is
   prefixed with its ID (`1. **F1 — Architecture:** …`) — the implication, not the theme,
   is the unit a PRD accounts for —
```

- [ ] **Step 5: Update step 8's report line**

In step 8, change:
```
8. **Report** to the user: the type, how many features/findings/themes were synthesized, the
```
to:
```
8. **Report** to the user: the type, the coverage line (how many questions answered /
   partial / unanswered, naming the unanswered ones), how many features/findings/themes
   were synthesized, the
```

- [ ] **Step 6: Verify**

Run: `rg -c "PLAN\.md" .claude/commands/synth-findings.md`

Expected: at least `2` (the gather bullet and the coverage-table instruction).

Run: `rg -n "Research questions — coverage|F<n>|coverage-contract" .claude/commands/synth-findings.md`

Expected: the coverage section heading, three `F<n>` template references, and the contract reference.

Then **read step 3 end to end** and confirm the coverage instruction reads coherently ahead of the three type branches, and that the `--visual` and `--docx` steps still make sense unchanged.

- [ ] **Step 7: Commit**

```bash
git -C C:/rnd-workspace add .claude/commands/synth-findings.md
git -C C:/rnd-workspace commit -m "$(cat <<'EOF'
feat(synth-findings): synthesize from the research questions, not just the captures

PLAN.md becomes a required input and the coverage table is written
before any finding, so a question that went unanswered is visible
instead of absent. Every top-level entry now carries an F# for the PRD
to account for.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01N3TCfWSa1NRtznkMHwKDdF
EOF
)"
```

---

## Task 5: Principal Researcher Mode B — the coverage criterion

**Files:**
- Modify: `.claude/personas/principal-researcher.md` (Mode B — synthesis QA; its input list and its numbered checks)

**Interfaces:**
- Consumes: the coverage table produced by Task 4, `Q#` IDs from Task 2.
- Produces: a readiness verdict that fails on a missing row.

- [ ] **Step 1: Verify Mode B does not take `PLAN.md`**

Run: `rg -n "Mode B" .claude/personas/principal-researcher.md`

Then read Mode B's `Input:` line. Expected: it lists the synthesis, README, and type source material — **not** `PLAN.md`.

- [ ] **Step 2: Add `PLAN.md` to Mode B's inputs**

Append to Mode B's `Input:` sentence:

```
, and the study's `PLAN.md` (for the research-question table — you cannot check coverage
without it)
```

- [ ] **Step 3: Add the coverage check as Mode B's first sub-step**

Mode B is structured as `### B1`…`### B4` under a line reading `Do four things, in this order:`.

**Do NOT renumber B1–B4.** Those labels are cited inside the persona itself (line 11 `see B4`, line 103 `problems from B1`, line 124 `B3-style annotation`) **and in committed QA records across past studies** — `research/2026-07-16-indonesian-teacher-onboarding-literature/SYNTHESIS.md:61-63` and `research/2026-07-13-onboarding-activation-education-apps/REVIEW.md:44,49,265` all say which of B1–B4 they checked. Shifting the labels would silently rewrite what those historical reviews claim to have done.

Add the new check as a stable **`B0`** instead — it reads correctly as the precondition that runs before the quality review, and every existing reference stays valid. Two edits:

1. Change `Do four things, in this order:` to `Do five things, in this order — B0 first:`.
2. Insert this directly above `### B1. Review the synthesis for quality`:

```
### B0. Check question coverage
Compare the `## Research questions — coverage` table against `PLAN.md`'s question table
as a set:
- every `Q#` in the plan has exactly one row (a **missing row fails readiness** — this is
  the one coverage failure that blocks);
- no `Answered` row without at least one `F#`;
- no `Answered` row whose cited `F#` does not actually address that question — read the
  finding and check, do not take the row's word for it;
- no `Status` more generous than the plan's `Answerable?` value without the row saying
  what changed.

**An honest `Unanswered` row passes.** You are checking that the question was *accounted
for*, never that the study succeeded. Flag an over-claimed `Answered` as a content problem
— an inline annotation for the human — exactly as you would a fabricated citation; do not
silently downgrade it yourself. See `.claude/references/coverage-contract.md`.
```

- [ ] **Step 4: Verify**

Run: `rg -n "Research questions — coverage|Answerable" .claude/personas/principal-researcher.md`

Expected: matches inside both Mode A (Task 3) and Mode B.

Run: `rg -n "^### B[0-4]\." .claude/personas/principal-researcher.md`

Expected: exactly five headings, `B0` through `B4`, in order — **B1–B4 unchanged**.

Then **read Mode B end to end** and confirm the auto-fix-prose / flag-substance split still reads correctly with B0 in front of it, and that the intro line now says five things.

- [ ] **Step 5: Commit**

```bash
git -C C:/rnd-workspace add .claude/personas/principal-researcher.md
git -C C:/rnd-workspace commit -m "$(cat <<'EOF'
feat(principal-researcher): check question coverage in Mode B

Mode B now takes PLAN.md and verifies every Q# has a coverage row,
that Answered rows name a finding that genuinely addresses the
question, and that no status over-claims the plan's answerability.
A missing row fails readiness; an honest Unanswered passes.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01N3TCfWSa1NRtznkMHwKDdF
EOF
)"
```

---

## Task 6: `/review-research` — give the panel the plan

**Files:**
- Modify: `.claude/commands/review-research.md` (the step listing what the panel personas receive — roughly line 26)

**Interfaces:**
- Consumes: `PLAN.md` question table (Task 2), coverage table (Task 4).
- Produces: nothing downstream; it strengthens the debate.

- [ ] **Step 1: Verify the panel does not receive the plan**

Run: `rg -n "PLAN\.md" .claude/commands/review-research.md`

Expected: **no matches.**

- [ ] **Step 2: Add `PLAN.md` to the panel's inputs**

In the step listing what each persona is handed (the line beginning `platforms/*/notes.md` and `flow.md`; usability: ...`), prepend `PLAN.md` to the shared inputs and add this sentence after the list:

```
   Hand every persona the study's **`PLAN.md`** alongside the synthesis. Without it the
   panel can only pressure-test the findings that exist; with it, the **Evidence Auditor**
   can also attack the `## Research questions — coverage` table — an `Answered` row whose
   cited `F#` does not really answer the question is exactly the kind of over-claim the
   audit exists to catch, and it is invisible without the plan.
```

- [ ] **Step 3: Verify**

Run: `rg -c "PLAN\.md" .claude/commands/review-research.md`

Expected: at least `2`.

- [ ] **Step 4: Commit**

```bash
git -C C:/rnd-workspace add .claude/commands/review-research.md
git -C C:/rnd-workspace commit -m "$(cat <<'EOF'
feat(review-research): hand the peer-review panel the research plan

The Evidence Auditor can now attack an over-claimed coverage row, which
is invisible when the panel only ever sees the synthesis.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01N3TCfWSa1NRtznkMHwKDdF
EOF
)"
```

---

## Task 7: `/close-research` — block on a missing table, write the verdict

**Files:**
- Modify: `.claude/commands/close-research.md` (step 2 "Check for synthesis", step 4 "Mark closed", step 7 "Report")
- Modify: `.claude/commands/new-research.md` (README template header — add the `Coverage:` field)

**Interfaces:**
- Consumes: the coverage table (Task 4), the `Coverage:` line format (Task 1).
- Produces: the `- **Coverage:**` README line that Task 9 (`/draft-prd`) reads.

- [ ] **Step 1: Verify no coverage check exists at close**

Run: `rg -n "Coverage|coverage" .claude/commands/close-research.md`

Expected: **no matches.**

- [ ] **Step 2: Extend step 2's synthesis check**

In step 2 (`**Check for synthesis.**`), append:

```
   Then confirm `SYNTHESIS.md` carries a `## Research questions — coverage` section with a
   row for every `Q#` in `PLAN.md`. **If it is missing, STOP** and tell the user to re-run
   `/synth-findings` — closing a study without it produces exactly the silent gap the
   coverage contract exists to prevent. If the study predates the contract and its
   `PLAN.md` has no question table, say so and close it as `unverified` (below) rather
   than inventing questions after the fact.
```

- [ ] **Step 3: Extend step 4 to write the verdict line**

In step 4 (`**Mark closed.**`), append:

```
   Also write the study's **coverage verdict** into the README header, directly under
   `- **Researcher:**`, derived from the synthesis coverage table:

   ```
   - **Coverage:** Q1,Q2,Q4 answered · Q3 partial · Q5 unanswered (deferred to primary research)
   ```

   For a study that predates the coverage contract, write exactly:

   ```
   - **Coverage:** unverified (pre-2026-07-29 study)
   ```

   This one line is what `/draft-prd` reads to decide whether the study may be cited as
   settled evidence — the design half must never have to parse a synthesis to find out.
   See `.claude/references/coverage-contract.md`.
```

- [ ] **Step 4: Add the field to the README template**

In `.claude/commands/new-research.md`, in the README template, change:

```
- **Researcher:** Claude (acting Senior UI/UX Designer)
```

to:

```
- **Researcher:** Claude (acting Senior UI/UX Designer)
- **Coverage:** <written by /close-research from the synthesis coverage table>
```

- [ ] **Step 5: Extend step 7's report**

In step 7 (`**Report**`), append: `, and the coverage verdict line as written`.

- [ ] **Step 6: Verify**

Run: `rg -c "Coverage" .claude/commands/close-research.md`

Expected: at least `3`.

Run: `rg -n "Coverage" .claude/commands/new-research.md`

Expected: the README template field.

- [ ] **Step 7: Commit**

```bash
git -C C:/rnd-workspace add .claude/commands/close-research.md .claude/commands/new-research.md
git -C C:/rnd-workspace commit -m "$(cat <<'EOF'
feat(close-research): block on a missing coverage table, write the verdict line

Closing now requires the synthesis to account for every research
question, and writes a one-line Coverage: verdict into the study README
so /draft-prd can read a study's conclusiveness without parsing it.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01N3TCfWSa1NRtznkMHwKDdF
EOF
)"
```

---

## Task 8: Migration — backfill the 11 closed studies

**Files:**
- Modify: the `README.md` of each of these 11 studies (header block only):
  - `research/2026-07-02-briliant/README.md` *(no `SYNTHESIS.md` — still gets the line)*
  - `research/2026-07-03-busuu-learning-experience/README.md`
  - `research/2026-07-03-datacamp-learning-experience/README.md`
  - `research/2026-07-06-benchmark-learning-effectiveness-loops/README.md`
  - `research/2026-07-09-benchmark-synthesis-learn-to-hire-loop/README.md`
  - `research/2026-07-13-onboarding-activation-education-apps/README.md`
  - `research/2026-07-14-ai-literacy-upskilling-indonesian-teachers/README.md`
  - `research/2026-07-16-indonesian-teacher-onboarding-literature/README.md`
  - `research/2026-07-17-certificate-vs-badge-gamification/README.md`
  - `research/2026-07-17-youth-onboarding-aha-moment/README.md`
  - `research/2026-07-20-unified-onboarding-synthesis-and-patterns/README.md`

**Do NOT touch** `research/2026-07-28-post-signup-handoff-first-run-home/README.md` — it is `Active` and gets a real verdict when it closes.

**Interfaces:**
- Consumes: the `unverified` legacy rule (Task 1).
- Produces: the `Coverage:` line Task 9's evidence gate branches on.

- [ ] **Step 1: Confirm the closed set**

Run: `rg -l "Status:\*\* Closed" research/*/README.md`

Expected: exactly the 11 paths listed above. If the set differs, use the command's output, not this list.

- [ ] **Step 2: Verify none carries a Coverage line yet**

Run: `rg -c "Coverage" research/*/README.md`

Expected: **no matches.**

- [ ] **Step 3: Insert the line into each of the 11 READMEs**

For each file, insert directly after its `- **Researcher:**` line (or, if that line is absent, as the last bullet of the header block before the first `##` heading):

```
- **Coverage:** unverified (pre-2026-07-29 study)
```

Change nothing else in these files. No synthesis is rewritten, no capture is redone, no
study is deleted — see the spec's §8 for why.

- [ ] **Step 4: Verify**

Run: `rg -c "Coverage:\*\* unverified" research/*/README.md`

Expected: `1` for each of the 11 closed studies, and **no line at all** for `2026-07-28-post-signup-handoff-first-run-home`.

- [ ] **Step 5: Commit**

**Stage the 11 paths explicitly — never `research/*/README.md`.** The active study
`research/2026-07-28-post-signup-handoff-first-run-home/` is **untracked**, so the glob
would stage it and its whole folder, which this task explicitly must not touch.

```bash
git -C C:/rnd-workspace add \
  research/2026-07-02-briliant/README.md \
  research/2026-07-03-busuu-learning-experience/README.md \
  research/2026-07-03-datacamp-learning-experience/README.md \
  research/2026-07-06-benchmark-learning-effectiveness-loops/README.md \
  research/2026-07-09-benchmark-synthesis-learn-to-hire-loop/README.md \
  research/2026-07-13-onboarding-activation-education-apps/README.md \
  research/2026-07-14-ai-literacy-upskilling-indonesian-teachers/README.md \
  research/2026-07-16-indonesian-teacher-onboarding-literature/README.md \
  research/2026-07-17-certificate-vs-badge-gamification/README.md \
  research/2026-07-17-youth-onboarding-aha-moment/README.md \
  research/2026-07-20-unified-onboarding-synthesis-and-patterns/README.md
git -C C:/rnd-workspace status --short
# Expect exactly 11 staged READMEs. If research/2026-07-28-* appears, unstage and retry.
git -C C:/rnd-workspace commit -m "$(cat <<'EOF'
chore(research): mark the 11 closed studies coverage-unverified

Backfills the Coverage: header line for every study closed before the
coverage contract. No synthesis is rewritten and no capture redone —
retrofit happens pay-as-you-go, enforced at /draft-prd when a study is
actually cited.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01N3TCfWSa1NRtznkMHwKDdF
EOF
)"
```

---

## Task 9: `/draft-prd` — read the verdict, account for the findings

**Files:**
- Modify: `.claude/commands/draft-prd.md` (step 3 "Evidence gate", step 6 drafting bullets, the `PRD.md` template's `## 2. Problem & Evidence` section, step 13 "Report")

**Interfaces:**
- Consumes: the `Coverage:` README line (Tasks 7, 8), `F#` IDs (Task 4), the `Disposition` vocabulary (Task 1).
- Produces: the §2.1 table Task 10 (Mode S) judges.

- [ ] **Step 1: Verify the evidence gate ignores coverage**

Run: `rg -n "Coverage|coverage" .claude/commands/draft-prd.md`

Expected: **no matches.** The gate currently checks only whether a study was *reviewed*.

- [ ] **Step 2: Extend the evidence gate (step 3)**

In step 3, inside the `- **Studies cited**` bullet, after the existing peer-review requirement, add:

```
     Then read each study's **`Coverage:`** line in its `README.md`. Reviewed tells you the
     findings were debated; coverage tells you how much of the study's own question set it
     actually answered — a peer-reviewed study that answered two questions of five passes
     the review check identically to one that answered all five, which is precisely the
     gap this reads.
     - **`unverified`** (a study closed before the coverage contract) → offer the user
       two paths, and do not proceed until one is chosen: **(a) retrofit** — build that
       study's coverage table now from its `PLAN.md` questions and synthesis sections,
       roughly 15 minutes; or **(b) demote** — cite it, but every §2 claim resting on it
       is labelled an assumption with a validation path. This is the pay-as-you-go
       retrofit: you pay only for the studies you actually cite.
     - A claim tracing to a question marked **`Partial`** or **`Unanswered`** must carry
       that qualifier in §2, or be labelled an assumption. Do not launder a partial answer
       into a flat assertion — the same rule that already carries litreview confidence
       labels through verbatim.
```

- [ ] **Step 3: Add the §2.1 drafting instruction to step 6**

In step 6's bullet list (which already covers §2, §6, §7, §8, §9, §14, §15), insert after the `- **§2 Problem & Evidence**` bullet:

```
   - **§2.1 Findings coverage** — one row for **every** `F#` of **every** study in
     `Informed by:`, with a disposition of `Adopted` (names a slice in §8), `Deferred`
     (points at a §14 Non-Goals entry), `Rejected` (reason), or `Contradicted` (reason).
     Silence is not a disposition. Build this table *before* finalizing §8, not after: a
     finding you cannot place is telling you something about the slice set, and the
     cheapest time to hear it is while the slices are still soft.
```

- [ ] **Step 4: Add §2.1 to the `PRD.md` template**

In the template block, immediately after the `## 2. Problem & Evidence` section body and before `## 3. Primary Job to be Done`, insert:

```
### 2.1 Findings coverage

Every finding of every cited study, accounted for. One row per `F#`; silence is not a
disposition. See `.claude/references/coverage-contract.md`.

| F# | Study | Finding | Disposition | Where / why |
|---|---|---|---|---|
| F1 | <study slug> | <short form> | Adopted | Slice 3 |
| F2 | <study slug> | <short form> | Deferred | §14 Non-Goals — <reason> |
| F3 | <study slug> | <short form> | Contradicted | Slice 5 does the opposite — <reason> |

`Adopted` must name a slice that exists in §8. `Deferred` must point at a §14 entry that
carries the reason. `Rejected` says the finding does not bear on this build; `Contradicted`
says it does and we are going the other way anyway — the second needs the louder reason.

If the project cites no study, say so here in one line rather than deleting the section.
```

- [ ] **Step 5: Extend step 13's report**

In step 13, after `the slice count and appetite,` insert:

```
the findings-coverage summary (how many findings adopted / deferred / rejected /
contradicted, naming the contradicted ones),
```

- [ ] **Step 6: Verify**

Run: `rg -c "Coverage:|Findings coverage|coverage-contract" .claude/commands/draft-prd.md`

Expected: at least `4`.

Then **read the template's §2 → §2.1 → §3 sequence** and confirm it flows, and that the section-count language elsewhere in the file ("All 17 sections plus the appendix") is still accurate — §2.1 is a *subsection*, so 17 remains correct. If any sentence implies otherwise, fix it.

- [ ] **Step 7: Commit**

```bash
git -C C:/rnd-workspace add .claude/commands/draft-prd.md
git -C C:/rnd-workspace commit -m "$(cat <<'EOF'
feat(draft-prd): read study coverage and account for every finding

The evidence gate now reads each cited study's Coverage: line and forces
a retrofit-or-demote choice for unverified studies. The PRD gains §2.1,
where every F# of every cited study is adopted, deferred, rejected, or
contradicted — silence is no longer an option.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01N3TCfWSa1NRtznkMHwKDdF
EOF
)"
```

---

## Task 10: Principal Designer Mode S — coverage and implication fidelity

**Files:**
- Modify: `.claude/personas/principal-designer.md` (Mode S — its `Input:` block and numbered criteria 1–6)

**Interfaces:**
- Consumes: §2.1 (Task 9), `F#` IDs (Task 4), the `Coverage:` line (Task 7).
- Produces: a `revise` verdict on a missing row or a narrowed implication.

- [ ] **Step 1: Verify Mode S has no coverage criterion**

Run: `rg -n "coverage|Findings coverage" .claude/personas/principal-designer.md`

Expected: **no matches** (criterion 3 already carries a falsifiability sentence from earlier work, which is related but different).

- [ ] **Step 2: Add the synthesis coverage tables to Mode S's inputs**

In Mode S's `Input:` paragraph, after `each cited study's `SYNTHESIS.md` (with `## Peer Review`)`, add:

```
 — including its `## Research questions — coverage` table and its `F#` headings —
```

- [ ] **Step 3: Extend criterion 1 with implication fidelity**

Append to Mode S's criterion `1. **Traceability — nothing invented.**`:

```
   **Traceability is necessary but not sufficient: also check the implication is
   *faithful*.** §2's "Product implication" column must follow from the finding it cites,
   without silent narrowing. A finding that says the registration wall belongs after the
   primary *value-delivery mechanism*, restated as a wall after *intake*, is a different
   product decision wearing a real citation. Narrowing a finding's scope is a divergence
   and must be declared in §2.1 as `Contradicted` or `Deferred` — never quietly restated.
   This is the one step in the pipeline with no other reviewer.
```

- [ ] **Step 4: Add coverage as a new criterion**

Insert as criterion 2, renumbering the existing 2–6 to 3–7:

```
2. **Findings coverage — nothing dropped.** §2.1 must carry one row for **every** `F#` of
   **every** study in `Informed by:`. Compare it as a set against each synthesis's `F#`
   headings; **any finding with no row is a `revise`.** Then check the rows are real, not
   theatre:
   - an `Adopted` row must name a slice that actually exists in §8;
   - a `Deferred` row must point at a §14 Non-Goals entry that actually carries the reason;
   - `Rejected` and `Contradicted` rows must each give a reason, and `Contradicted` — where
   we knowingly do the opposite — needs the louder one.

   **A `Deferred` or `Contradicted` finding is a legitimate, often correct design call.**
   You are not judging whether the team adopted enough research; you are checking that
   every finding was *confronted*. Silence is the only failure. See
   `.claude/references/coverage-contract.md`.
```

- [ ] **Step 5: Verify**

Run: `rg -n "Findings coverage|faithful|coverage-contract" .claude/personas/principal-designer.md`

Expected: matches in criterion 1 and the new criterion 2.

Then **read Mode S end to end** and confirm criteria run 1..7 with no duplicate or skipped number, and that the closing verdict paragraph still matches the criteria above it.

- [ ] **Step 6: Commit**

```bash
git -C C:/rnd-workspace add .claude/personas/principal-designer.md
git -C C:/rnd-workspace commit -m "$(cat <<'EOF'
feat(principal-designer): judge findings coverage and implication fidelity in Mode S

Mode S now fails a PRD that omits any cited finding from §2.1, and
checks that a §2 product implication follows from the finding it cites
rather than silently narrowing it — the step that previously had no
reviewer at all.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01N3TCfWSa1NRtznkMHwKDdF
EOF
)"
```

---

## Task 11: Mode T and `/design-prototype` — reverse slice traceability

**Files:**
- Modify: `.claude/personas/principal-designer.md` (Mode T — criterion 1)
- Modify: `.claude/commands/design-prototype.md` (step 13 "Report and hand off")

**Interfaces:**
- Consumes: §8 slices from `PRD.md`, the authored `src/`.
- Produces: a `revise` verdict on an unreachable slice. Terminal — nothing consumes it.

- [ ] **Step 1: Verify Mode T checks only screens → slices**

Read Mode T's criterion 1 in `.claude/personas/principal-designer.md`. Expected: it requires every screen to map to a slice, with no converse requirement.

- [ ] **Step 2: Add the reverse check to Mode T criterion 1**

Append to Mode T's criterion `1. **Traceability — nothing invented.**`:

```
   **Then check the converse — nothing dropped.** Every §8 vertical slice must reach at
   least one screen that is actually reachable in the authored `src/`, or be explicitly
   declared outside the run's `--scope`. Forward traceability stops the prototype
   inventing screens; only this stops it quietly shipping eight of the PRD's ten slices.
   A slice with no screen and no `--scope` declaration is a `revise`.
```

- [ ] **Step 3: Add the coverage line to `/design-prototype`'s report**

In step 13 (`**Report and hand off.**`), change `The screen count, the DoD gate table,` to:

```
The screen count, the slice coverage (how many of the PRD's §8 slices are reachable in
this build, naming any left out and why), the DoD gate table,
```

- [ ] **Step 4: Verify**

Run: `rg -n "nothing dropped" .claude/personas/principal-designer.md`

Expected: one match, inside Mode T.

Run: `rg -n "slice coverage" .claude/commands/design-prototype.md`

Expected: one match in step 13.

- [ ] **Step 5: Commit**

```bash
git -C C:/rnd-workspace add .claude/personas/principal-designer.md .claude/commands/design-prototype.md
git -C C:/rnd-workspace commit -m "$(cat <<'EOF'
feat(design-prototype): check slices reach screens, not just screens reach slices

Mode T gains the reverse-traceability check, so a PRD slice that never
got built is a revise instead of a silent omission, and the command
reports slice coverage on hand-off.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01N3TCfWSa1NRtznkMHwKDdF
EOF
)"
```

---

## Task 12: Light touches — `/plan-usability` and `/gather-evidence`

Keeps the `Q#` spine intact for the two non-benchmark study types.

**Files:**
- Modify: `.claude/commands/plan-usability.md` (the `test-plan.md` template's task section)
- Modify: `.claude/commands/gather-evidence.md` (the `evidence.md` claim format)

**Interfaces:**
- Consumes: `Q#` IDs (Task 2).
- Produces: `Q#`-tagged tasks and claims, so Task 4's coverage table has something concrete to cite for these types.

- [ ] **Step 1: Verify neither carries `Q#`**

Run: `rg -n "Q1|Q#" .claude/commands/plan-usability.md .claude/commands/gather-evidence.md`

Expected: **no matches.**

- [ ] **Step 2: Tag usability tasks with the question they serve**

In `.claude/commands/plan-usability.md`, in the `test-plan.md` template's task list, add a `Serves` field to each task entry:

```
- **Serves:** <Q# from PLAN.md — which research question this task produces evidence for>
```

And add this sentence to the drafting step:

```
   Every task names the `Q#` it serves, and every `Q#` marked `Yes` or `Partial` in
   `PLAN.md` is served by at least one task. A question no task touches will come back
   `Unanswered` at synthesis — better to find that now, while the instrument is still
   editable. See `.claude/references/coverage-contract.md`.
```

- [ ] **Step 3: Tag evidence claims with the question they address**

In `.claude/commands/gather-evidence.md`, in the `evidence.md` format description, add `Q#` alongside the existing `[S#]` citation requirement:

```
   Each verified claim carries the `Q#` it addresses alongside its `[S#]` source IDs, e.g.
   `- [Q2] Deferred registration lifts activation (confidence: High) [S3][S7]`. A research
   question that ends with no claim against it is a real finding — it becomes an
   `Unanswered` row at synthesis, not a silence. See
   `.claude/references/coverage-contract.md`.
```

- [ ] **Step 4: Verify**

Run: `rg -c "Q#" .claude/commands/plan-usability.md .claude/commands/gather-evidence.md`

Expected: at least `1` in each.

- [ ] **Step 5: Commit**

```bash
git -C C:/rnd-workspace add .claude/commands/plan-usability.md .claude/commands/gather-evidence.md
git -C C:/rnd-workspace commit -m "$(cat <<'EOF'
feat: carry Q# through usability tasks and litreview evidence claims

Keeps the question spine intact for the two non-benchmark study types,
so an unserved question surfaces while the instrument is still editable.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01N3TCfWSa1NRtznkMHwKDdF
EOF
)"
```

---

## Task 13: Register the contract in `CLAUDE.md` and verify against the spec

**Files:**
- Modify: `CLAUDE.md` (the `## How research is organized` section, and the design-half reference paragraph added earlier)

**Interfaces:**
- Consumes: everything above.
- Produces: the discoverability that makes the contract findable without a grep.

- [ ] **Step 1: Verify `CLAUDE.md` does not mention coverage**

Run: `rg -n "coverage-contract" CLAUDE.md`

Expected: **no matches.**

- [ ] **Step 2: Add a coverage paragraph to `## How research is organized`**

At the end of that section, before `### Principal Researcher (quality gate)`, insert:

```
**Coverage is tracked, not assumed.** A study's `PLAN.md` gives every research question a
stable `Q#`; its `SYNTHESIS.md` opens with a coverage table accounting for every one of
them; `/close-research` distils that into a one-line `Coverage:` verdict in the study
README; and a citing `PRD.md` accounts for every finding `F#` in its §2.1. The governing
principle is **declare or block** — an unanswered question and an unadopted finding both
pass every gate *if recorded with a reason*; only silence fails. The contract is
`.claude/references/coverage-contract.md`.
```

- [ ] **Step 3: Add the contract to the design-half reference list**

In the design-half paragraph that distinguishes `design-projects.md` / `design-gates.md` / `prompt-vocabulary.md`, extend the final sentence:

```
 A fourth, `coverage-contract.md`, answers *what must be accounted for* — it is why
`/draft-prd` reads a study's `Coverage:` line and why Mode S fails a PRD that omits a
cited finding.
```

- [ ] **Step 4: Verify against the spec's acceptance criteria**

Read `docs/superpowers/specs/2026-07-29-coverage-gates-design.md` §12 and check each of the seven conditions against the edited files. Specifically:

Run: `rg -l "coverage-contract" .claude/ CLAUDE.md`

Expected: `coverage-contract.md` itself plus `new-research.md`, `synth-findings.md`, `close-research.md`, `draft-prd.md`, `plan-usability.md`, `gather-evidence.md`, `principal-researcher.md`, `principal-designer.md`, `CLAUDE.md`.

Then run the **spot-check regression** from spec §12.7 by hand: read `design/onboarding-solve-edu/PRD.md` against `research/2026-07-20-unified-onboarding-synthesis-and-patterns/SYNTHESIS.md`'s seven design implications, and confirm the new §2.1 requirement would force rows for implication 1 (try-first → `Deferred`), implication 2 (loss-aversion copy → `Adopted`, Slice 7), and implication 7 (15+ age gate → `Contradicted`). **Do not edit that PRD** — this is a read-only check that the gate would have caught the real misses. Report the result.

- [ ] **Step 5: Commit**

```bash
git -C C:/rnd-workspace add CLAUDE.md
git -C C:/rnd-workspace commit -m "$(cat <<'EOF'
docs: register the coverage contract in CLAUDE.md

States the declare-or-block principle and the Q#/F# spine in the
research section, and adds the contract to the design half's reference
list alongside design-projects, design-gates, and prompt-vocabulary.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01N3TCfWSa1NRtznkMHwKDdF
EOF
)"
```

---

## Self-review record

Checked against the spec on completion of writing:

- **Spec coverage:** §3 ID schemes → Tasks 1, 2, 4. §4.1 plan table → Task 2. §4.2 synthesis coverage → Task 4. §4.3 PRD §2.1 → Task 9. §4.4 README verdict → Tasks 7, 8. §5 command changes → Tasks 2, 4, 6, 7, 9, 11, 12. §6 persona changes → Tasks 3, 5, 10, 11. §7 reference file → Task 1. §8 migration → Task 8. §11 `CLAUDE.md` → Task 13. No spec section is unimplemented.
- **Placeholder scan:** every edit step carries the literal text to insert. No "add appropriate…", no "similar to Task N", no TBD.
- **Naming consistency:** `Q#`, `F#`, `Answerable?`, `Status`, `Disposition`, `Coverage:`, and `## Research questions — coverage` are spelled identically in Tasks 1, 2, 4, 5, 7, 9, 10 and in the spec. The section heading uses an em-dash in all occurrences.
- **Known deviation from the skill's default:** this repo has no test framework, so TDD steps are verification-command cycles rather than unit tests. Stated at the top rather than faked.

Two defects were found and fixed during the review pass:

1. **Task 5 originally renumbered Mode B's `B1`–`B4`.** Those labels are referenced inside the persona *and* in committed QA records across two past studies (`2026-07-16-…/SYNTHESIS.md:61-63`, `2026-07-13-…/REVIEW.md:44,49,265`), which record which sub-steps a past review actually ran. Renumbering would have silently rewritten history. Changed to a stable `B0` inserted ahead of `B1`.
2. **Task 2 Step 5 pointed at "the step that drafts `PLAN.md`" instead of naming it.** That is the placeholder pattern the skill forbids. Changed to the literal step 7 with its heading text and line number.
