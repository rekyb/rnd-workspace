# Design: Coverage gates for the research → design pipeline

**Date:** 2026-07-29
**Status:** Approved, pending implementation plan
**Scope:** `.claude/` commands, personas, and references; `CLAUDE.md`

---

## 1. Problem

Two reported symptoms:

1. A study's research is not good enough to answer the question it was set.
2. A prototype misses findings the research produced.

They are one defect. **Every gate in the workspace is a precision gate; none is a recall
gate.** The whole chain is built against fabrication — never invent a finding, never invent
a source, every screen traces to a slice — and it works. But each check runs forward only,
so *omission* is invisible.

Audited evidence (2026-07-29):

| Observation | Source |
|---|---|
| 10 of 12 studies carry a research-questions section in `PLAN.md` | `research/*/PLAN.md` |
| All 10 studies that have a `SYNTHESIS.md` reference those questions **zero** times | `research/*/SYNTHESIS.md` |
| `/synth-findings` never reads `PLAN.md` — it is not an input | `.claude/commands/synth-findings.md` |
| `/review-research` never reads `PLAN.md` | `.claude/commands/review-research.md` |
| `/close-research` reads `PLAN.md` only for the sources list | `.claude/commands/close-research.md:28` |
| Principal Researcher reads `PLAN.md` in Mode A only, not Mode B (synthesis QA) | `.claude/personas/principal-researcher.md:37` |
| Principal Designer mentions plan, gaps, or coverage in no mode | `.claude/personas/principal-designer.md` |

The research plan is written once, then orphaned when capture starts.

Design-side spot-check, `design/onboarding-solve-edu` against its single cited study
(`research/2026-07-20-unified-onboarding-synthesis-and-patterns`, 5 themes + 7 design
implications):

- **Theme 2 (loss aversion / progress ownership)** appears in no PRD section — not §2, not
  a slice, not Non-Goals. Silently dropped.
- **Design implication 1** — *"the registration wall must sit after the primary
  value-delivery mechanism"* — became *"Keep the account wall after path-specific
  **intake**"* (`design/onboarding-solve-edu/PRD.md:31`). The slice order confirms no
  learning interaction occurs before the Slice 7 account wall.
- **Design implication 7** (hard 15+ age gate) is contradicted by Slice 5's
  policy-configured bands, defensibly, but the divergence is never stated as one.
- **Design implication 3's placement fork is handled correctly** — Non-Goals says
  *"Baseline assessment before account creation; reviewed research recommends it, but the
  current approved prototype scope does not define assessment content…"*.

That last line is the fix already existing in the repo, done once by hand because nothing
required it. This design makes it required, everywhere.

## 2. Locked decisions

| Decision | Choice |
|---|---|
| Gate strictness | **Silence fails, declaration passes.** An unanswered question or an unadopted finding is legitimate *if recorded with a reason*. Omitting it is the failure. |
| PRD coverage unit | **One row per top-level synthesis item, type-aware** — benchmark → feature, usability → finding, litreview → design implication. ~6–15 rows per PRD. |
| Prevention | **Yes** — answerability is checked at plan time, before capture is spent. |
| Architecture | **Stable IDs threaded through the pipeline, built with a minimal footprint** — no new artifacts beyond one reference file. |
| Retrofit | **Pay-as-you-go.** Closed studies are marked `unverified`; a table is added only when a study is actually cited by a PRD. |

## 3. The two ID schemes

**`Q1…Qn` — research questions.** Assigned in `PLAN.md` at study creation. Stable for the
life of the study.

- Numbers are **never renumbered and never reused.**
- A question dropped during plan revision becomes a `Withdrawn` row with its reason; it
  does not vanish.
- Rationale: every downstream citation is by ID, so renumbering silently rots the chain.

**`F1…Fn` — findings.** Assigned in `SYNTHESIS.md`, one per top-level item, type-aware:

| Study type | F# attaches to |
|---|---|
| `benchmark` | each feature write-up |
| `usability` | each finding |
| `litreview` | each numbered **design implication** (themes keep their existing numbering) |

Implemented as a heading prefix — `## F1 — Value-before-signup (deferred registration)`.

These two IDs surviving each hop *is* the design. Every gate below is a set comparison
against them.

## 4. Artifact changes

### 4.1 `PLAN.md` — research questions become a table

Replaces the current free-prose numbered list. Required for all three study types.

```markdown
## Research questions

| ID | Question | Method that will answer it | Answerable by this study? |
|---|---|---|---|
| Q1 | … | Benchmark capture (Mobbin, 4 platforms) | Yes |
| Q2 | … | Benchmark capture + cited literature | Partial — no live system behaviour |
| Q3 | … | — | No — needs funnel analytics + moderated sessions; carried to a future study |
```

`Answerable?` vocabulary: `Yes` · `Partial — <what is missing>` · `No — deferred to <what
would answer it>` · `Withdrawn — <reason>`.

A question marked `No` must be explicitly carried or withdrawn. It may not sit in the plan
unmarked.

### 4.2 `SYNTHESIS.md` — required coverage section

Placed immediately after the overview/TL;DR and **before** the findings, in all three
templates.

```markdown
## Research questions — coverage

| Q# | Question | Status | Where answered | Confidence |
|---|---|---|---|---|
| Q1 | … | Answered | F1, F3 | High |
| Q2 | … | Partial | F2 — mechanic observed, effect size not | Medium |
| Q3 | … | Unanswered | No funnel access; → `## Gaps & caveats` | — |
| Q4 | … | Withdrawn | Dropped at plan review 2026-07-05 | — |
```

Rules:

- **Every `Q#` in `PLAN.md` has exactly one row.** A missing row is the gate failure.
- `Answered` must name at least one `F#`.
- `Partial` must name the `F#` **and** state what is missing.
- `Unanswered` must give a reason and a destination (`## Gaps & caveats` or
  `## Evidence gaps for primary research`).
- Status may not be more generous than the plan's `Answerable?` value without saying what
  changed.

### 4.3 `PRD.md` — new §2.1 Findings coverage

A subsection of §2 Problem & Evidence, **not an appendix** — it is the evidence accounting
and must be confronted, not skimmed. It forward-references slice numbers defined in §8;
that is accepted.

```markdown
### 2.1 Findings coverage

| F# | Study | Finding | Disposition | Where / why |
|---|---|---|---|---|
| F1 | unified-onboarding | Try-first: wall after value delivery | Deferred | §10 Non-Goals — no lesson player in scope |
| F2 | unified-onboarding | Loss-aversion CTA framing | Adopted | Slice 7 |
| F7 | unified-onboarding | Hard 15+ age gate | Contradicted | Slice 5 uses policy config; SEA minimums vary |
```

Disposition vocabulary — four values, and **silence is not one of them**:

| Disposition | Requires |
|---|---|
| `Adopted` | names a Slice N that exists in §8 |
| `Deferred` | points at a §Non-Goals entry carrying the reason |
| `Rejected` | a reason (the finding does not apply here, or we disagree) |
| `Contradicted` | a reason (we deliberately do the opposite) |

Every `F#` of every study named in `Informed by:` gets a row.

### 4.4 Study README — the portable coverage verdict

One line in the header block, written by `/close-research`:

```
Coverage: Q1,Q2,Q4 answered · Q3 partial · Q5 unanswered (deferred to primary research)
```

Legacy studies closed before this design get exactly:

```
Coverage: unverified (pre-2026-07-29 study)
```

This applies to all **11 closed studies**, including `2026-07-02-briliant`, which has no
`SYNTHESIS.md` at all. The one `Active` study (`2026-07-28-post-signup-handoff-first-run-home`)
is not backfilled — it gets a real verdict when `/close-research` runs.

This line is the portable summary `/draft-prd` reads. It exists so the design half never
has to parse a synthesis to learn how conclusive a study was.

## 5. Command changes

| Command | Change |
|---|---|
| `/new-research` | `PLAN.md` template carries the §4.1 research-questions table with `Answerable?`. |
| `/plan-usability` | Each task in `test-plan.md` names the `Q#` it serves. Light touch. |
| `/gather-evidence` | Each claim in `evidence.md` carries the `Q#` it addresses, alongside its `[S#]`. Light touch. |
| `/synth-findings` | **`PLAN.md` becomes a required input.** Draft the §4.2 coverage table *first*, then write the findings. Assign `F#` to every top-level item. STOP if `PLAN.md` has no question table (legacy study) and offer to build one from its prose questions. |
| `/review-research` | `PLAN.md` added to the panel's inputs, so the Evidence Auditor can attack an over-claimed `Answered`. |
| `/close-research` | Block on a missing coverage table. Write the §4.4 `Coverage:` line into the study README. |
| `/draft-prd` | Evidence gate extended: read each cited study's `Coverage:` line. `unverified` → offer (a) retrofit the study's coverage table now, or (b) cite it with §2 claims demoted to labelled assumptions. A claim tracing to a `Partial`/`Unanswered` question must carry the qualifier or be labelled an assumption. Template gains §2.1. |
| `/design-prototype` | Report the slice→screen coverage result in step 13. Light touch; the judgment is Mode T's. |

The `/synth-findings` change is the load-bearing one. Adding a section is cosmetic; making
the synthesis *start from the questions* is what stops it being shaped only by what was
found.

## 6. Persona changes

### Principal Researcher — Mode A (plan review)

New criterion, **answerability**: flag any question whose stated method cannot produce the
evidence it demands. Canonical failures:

- a causal "why" asked of purely observational capture;
- live-system behaviour asked of Mobbin stills (already partly covered by the C1–C5
  sourcing rules — this generalizes it);
- our own product's funnel asked of a benchmark of other products.

Verdict may not be *approve* while an unanswerable question sits unmarked. The fix is
re-scope, add a method, or mark it `No — deferred`.

### Principal Researcher — Mode B (synthesis QA)

`PLAN.md` added to inputs. New criterion, **coverage**: every `Q#` has a row; no `Answered`
without an `F#`; no `Answered` whose cited `F#` does not actually address the question.
Readiness verdict fails on a missing row — not on an honest `Unanswered`.

### Principal Designer — Mode S (PRD review)

Two additions:

1. **Coverage** — every `F#` of every cited study has a §2.1 row; any missing row is
   `revise`. An `Adopted` row must name a slice that exists; a `Deferred` row must point at
   a real Non-Goals entry.
2. **Implication fidelity** — the §2 "Product implication" must follow from the cited
   finding without silent narrowing. Narrowing a finding's scope is a divergence and must
   be declared as `Contradicted` or `Deferred`, not quietly restated.

Criterion 2 is the step with no reviewer today, and it is where "value delivery" became
"intake".

### Principal Designer — Mode T (prototype review)

New reverse-traceability criterion: every §8 slice reaches a screen in `src/`, or is
explicitly declared outside `--scope`. Mode T currently checks screens → slices only.

## 7. New reference file

`.claude/references/coverage-contract.md` — single source for:

- the `Q#` / `F#` schemes and their stability rules;
- the three status/disposition vocabularies (`Answerable?`, synthesis `Status`, PRD
  `Disposition`);
- the legacy `unverified` rule and the pay-as-you-go retrofit path;
- the declare-or-block principle, stated once.

Commands and personas **reference** it rather than restating it, matching how
`design-projects.md` and `design-gates.md` are used today. `CLAUDE.md` registers it
alongside those.

## 8. Migration

The entire migration is one line per closed study:

```
Coverage: unverified (pre-2026-07-29 study)
```

No synthesis is rewritten, no capture is redone, no study is deleted. Rationale:

- The captures are the expensive, perishable artifact and they are not what is defective;
  the defect is the question → finding index.
- `research/PATTERNS.md` (122 KB) traces every entry to a closed study. Deleting studies
  would leave every pattern's provenance dangling — unfalsifiable in exactly the way the
  workspace forbids.
- Which studies deserve redoing cannot be known until a coverage table exists. The table is
  the instrument that informs that call, so it must come first.

Retrofit happens only when a study is actually cited by a PRD, enforced at `/draft-prd`.
Studies nobody cites cost nothing.

## 9. Out of scope

- **`check-coverage.ps1`** — deferred. Markdown table parsing is brittle and the personas
  carry this fine at current volume. The `Q#`/`F#` scheme is what leaves the door open; a
  name-matched design would have closed it permanently.
- Retrofitting the 10 closed studies (see §8).
- A separate `COVERAGE.md` ledger — it would split a finding from its coverage status,
  which is the same drift this design exists to end, and would contradict the design half's
  rule that status lives in the README and nowhere else.
- `/brief-feature`, `/export-prototype`, and the three benchmark lenses are untouched.

## 10. Failure modes designed against

| Failure mode | Defence |
|---|---|
| ID rot when a plan is revised | Never renumber, never reuse; dropped questions become `Withdrawn` rows |
| Over-claiming `Answered` | Mode B checks the cited `F#` addresses the question; the Evidence Auditor gets `PLAN.md` and can attack it in the peer-review debate |
| Table theatre — rows filled in without substance | `Adopted` must name a slice that exists (Mode S); that slice must reach a screen (Mode T). The chain closes. |
| Gate becomes friction and gets bypassed | Declaration always passes. An honest `Unanswered` or `Deferred` costs one line and never blocks. |
| Legacy studies block all work | `unverified` is citable; it only forces assumption-labelling at the point of use |

## 11. Files touched

**New (2):**
- `.claude/references/coverage-contract.md`
- `docs/superpowers/specs/2026-07-29-coverage-gates-design.md` *(this file)*

**Edited (11):**
- `.claude/commands/new-research.md`
- `.claude/commands/synth-findings.md`
- `.claude/commands/review-research.md`
- `.claude/commands/close-research.md`
- `.claude/commands/draft-prd.md`
- `.claude/commands/design-prototype.md` *(light)*
- `.claude/commands/plan-usability.md` *(light)*
- `.claude/commands/gather-evidence.md` *(light)*
- `.claude/personas/principal-researcher.md`
- `.claude/personas/principal-designer.md`
- `CLAUDE.md`

Eight commands, two personas, and `CLAUDE.md`. The implementation plan should sequence
`coverage-contract.md` first, since every other edit points at it, and the three
light-touch method commands last, since nothing depends on them.

## 12. Acceptance

This design is correctly implemented when:

1. A new study's `PLAN.md` carries `Q#` IDs with a method and an `Answerable?` value each,
   and Mode A refuses to approve a plan with an unmarked unanswerable question.
2. `/synth-findings` opens `PLAN.md`, and the resulting `SYNTHESIS.md` carries a coverage
   row for every `Q#` before its first finding.
3. `/close-research` refuses to close a study with no coverage table, and writes a
   `Coverage:` line into its README.
4. `/draft-prd` reads that line, and a PRD citing an `unverified` study either retrofits it
   or demotes its §2 claims to labelled assumptions.
5. A PRD omitting any cited study's `F#` from §2.1 gets `revise` from Mode S.
6. A prototype with a §8 slice that reaches no screen gets `revise` from Mode T.
7. Re-running the `onboarding-solve-edu` spot-check surfaces F1 (deferred), F2 (adopted),
   and F7 (contradicted) as explicit rows rather than silence.
