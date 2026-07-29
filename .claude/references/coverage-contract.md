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

Implemented as an **ID prefix on the item itself**. The markup carrying that prefix takes
three forms, because the item varies by type and because a finding can move:

- `benchmark` and `usability` → a **section heading** prefix:
  `## F1 — Value-before-signup (deferred registration)`.
- `litreview` → a **numbered list item** prefix inside `## Design implications`:
  `1. **F1 — Architecture:** …`. The implications are a numbered list, not sections, so
  there is no `F#` heading anywhere in a litreview synthesis.
- **any type, once retracted** → an **inline bold** prefix inside `## Gaps & caveats`:
  `**F4 — <name> — Unsupported:** …`, written by `/review-research` step 6b. A heading
  cannot be used here whatever the study type: `## Gaps & caveats` is itself an `##`, so
  an `## F4` under it would parse as its *sibling* and carry the retracted finding out of
  the section it was moved into.

**The comparison is over IDs, not over markup.** Anything that compares `F#` as a set —
Mode S's §2.1 check above all — collects every `F#` the synthesis defines, in whichever of
these forms happens to carry it. Implementing that as a search for one shape is the failure
this list exists to prevent: matching only headings yields an empty set for a litreview
study, and matching only headings and list items drops every retracted finding, which is
exactly the finding a `Retired upstream` row has to account for.

Adding a fourth form means updating this list **and** every `F#` forms row of *Where these
vocabularies and forms are restated*.

The type-awareness matters: a litreview's themes are analysis, but its design implications
are what a PRD can actually adopt or defer, so the implication is the unit that must be
accounted for.

- **Never renumbered. Never reused.** A finding retracted during `/review-research` is
  marked `Unsupported` and remains in the synthesis with its reason; the ID is retired,
  not renumbered. Rationale: as with `Q#`, renumbering after peer review breaks every
  downstream citation. Retiring a finding is legitimate and never fails a gate; only
  silence fails.

`Unsupported` is a **finding-level** marker in the synthesis, not a value in Vocabulary 2
(which is strictly question-level). When every `F#` answering a question is marked
`Unsupported`, that question's `Status` in Vocabulary 2 drops to `Unanswered` — carrying
**both** of the things Vocabulary 2 requires of an `Unanswered` row: the retraction as its
reason **and** `## Gaps & caveats` as its destination, which is where `/review-research`
moves the retracted finding. That refresh happens in `/review-research` step 6d; nothing
downstream re-checks the table, because the Principal Researcher's Mode B coverage pass
runs inside `/synth-findings`, before the debate.

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
| `Retired upstream` | names where the synthesis retracted it (e.g. "peer review marked Unsupported, 2026-08-14") |

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

1. **Retrofit** — **assign the IDs first, then build the table.** A legacy study has
   neither scheme: its `PLAN.md` holds prose questions with no `Q#`, and its
   `SYNTHESIS.md` has no `F#` prefixes, so a coverage table built straight away has
   nothing to key rows to and no `F#` for an `Answered` row to name. In order (roughly
   15 minutes total):
   1. write a `Q#` against each prose question in its `PLAN.md`, **in the order they
      already appear**;
   2. give every top-level item in its `SYNTHESIS.md` an `F#` in document order, per the
      type table above;
   3. build the `## Research questions — coverage` table, mapping each `Q#` to the `F#`s
      that answer it;
   4. write the `- **Coverage:**` verdict line into its `README.md`, replacing
      `unverified`.

   All four steps **write back to the study**, so a retrofit is paid **once per study, not
   once per citation** — the second PRD to cite it finds it already verified. Then cite it
   normally; or
2. **Demote** — cite it with the §2 claims that rest on it explicitly labelled assumptions
   with validation paths.

Studies nobody cites cost nothing. A study whose retrofit reveals it answered one question
out of five has just told you something worth knowing, and *that* is when redoing it is an
informed decision rather than a guess.

## Where these vocabularies and forms are restated

The three vocabularies above, and the `F#` form list, are **deliberately duplicated** into
the commands and personas that apply them. Prompts have no include mechanism, and a bare cross-reference is often not
traversed by the agent reading it — a failure that is silent, because the agent proceeds
with a plausible invented vocabulary instead of stopping. Restating the values at the point
of use is the cheaper failure mode.

The cost is that this file is no longer the only place a change lands. **This is the
checklist**: change a value, add a disposition, add an `F#` form, or reword a requirement
here, and walk every row below. Anything not listed here is a passing mention, not a
restatement.

| What | File | Where |
|---|---|---|
| 1 — `Answerable?` | `.claude/personas/principal-researcher.md` | Mode A criterion 3 — the mismatch list and the "not `Plan is sound` while a question sits marked `Yes` or left blank" rule |
| 1 | `.claude/commands/new-research.md` | Step 7's "honest `Answerable?` value" note, and the `Answerable by this study?` column in all **three** `PLAN.md` templates (benchmark, usability, litreview) |
| 1 | `.claude/commands/plan-usability.md` | Step 3 — every `Q#` marked `Yes` or `Partial` must be served by a task |
| 2 — `Status` | `.claude/commands/synth-findings.md` | Step 3 — the coverage-table example plus the per-value requirements (`Answered` names an `F#`; `Partial` names the `F#` and the gap; `Unanswered` gives a reason and a destination) |
| 2 | `.claude/personas/principal-researcher.md` | Mode B0 — the coverage set-comparison checks, incl. "no `Status` more generous than the plan's `Answerable?`" |
| 2 | `.claude/commands/review-research.md` | Step 2 (the Evidence Auditor attacks the table) and step 6d (the post-retraction refresh to `Unanswered` / `Partial`) |
| 2 | `.claude/commands/draft-prd.md` | Step 3 — a claim tracing to a `Partial` or `Unanswered` question must carry the qualifier |
| 2 | `.claude/commands/gather-evidence.md` | Step 6 — a question with no claim becomes an `Unanswered` row |
| 2 | `.claude/commands/close-research.md` | Step 4 — the `Coverage:` line, derived from the table's statuses |
| 3 — `Disposition` | `.claude/commands/draft-prd.md` | Step 6's §2.1 bullet (all five values), the `PRD.md` template's §2.1 table **and** the prose under it, and step 13's report line (adopted / deferred / rejected / contradicted / retired upstream) |
| 3 | `.claude/personas/principal-designer.md` | Mode S criterion 2 — the per-value row checks and the "a `Deferred`, `Rejected`, `Contradicted`, or `Retired upstream` finding is legitimate" statement |
| `F#` forms | `.claude/personas/principal-designer.md` | Mode S criterion 2 — the three-form list the set comparison reads, and the consequence of missing each |
| `F#` forms | `.claude/commands/review-research.md` | Step 6b — the inline-bold retracted form, and why it is not a heading |

The `F#` form rows are here because their absence already cost us once. `/review-research`
introduced the retracted inline-bold form while Mode S still enumerated two, and nothing
pointed from one to the other; the gap shipped and was caught only on a later read. A form
list restated in two files is a restatement like any other.

The `Q#` / `F#` ID rules are likewise restated in `new-research.md` (the never-renumbered
note under the question table), `synth-findings.md` (step 3's `F#` assignment by type),
`review-research.md` (step 6b's retire-in-place rule), and `draft-prd.md` (step 3's legacy
retrofit).
