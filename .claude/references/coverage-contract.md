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

- **Never renumbered. Never reused.** A finding retracted during `/review-research` is
  marked `Unsupported` and remains in the synthesis with its reason; the ID is retired,
  not renumbered. Rationale: as with `Q#`, renumbering after peer review breaks every
  downstream citation. Retiring a finding is legitimate and never fails a gate; only
  silence fails.

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

**Silence is not a disposition** — except for findings marked `Unsupported` in the synthesis,
which need no row. A disposition row is required for every other active `F#` in the studies
cited.

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
