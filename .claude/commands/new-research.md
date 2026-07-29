---
description: Start a new research effort (benchmark, usability, or litreview) — creates a dated folder, scaffolds it by type, and marks it active.
argument-hint: <research topic> [--type benchmark|usability|litreview]
---

You are starting a new UX-research effort. Parse `$ARGUMENTS` for the topic and an
optional `--type` flag.

Follow these steps exactly:

1. **Check the active registry.** Read `.claude/.active-research` (the registry — see
   `.claude/references/active-research.md`). Multiple studies may be active at once, so
   an existing active study is fine and does **not** block a new one. Only if the new
   topic would duplicate an existing active study (same slug) should you warn and
   confirm with the user before proceeding.

2. **Determine the research type.** Look for `--type <value>` in `$ARGUMENTS`.
   - Accepted values: `benchmark` (default if the flag is absent), `usability`, and
     `litreview` (evidence synthesis from documents — see step 5/7 for its scaffold and gate).
   - `survey` and `abtest` are planned but not yet implemented — if asked, tell the
     user those types aren't wired up yet and offer `benchmark` or `usability`.
   - Strip the flag out of the topic string before deriving the slug.

3. **Establish and confirm the goal (required).** The goal drives everything
   downstream — `/review-research` judges the synthesis *against this goal* — so it
   must be explicit before anything else happens.
   - **Benchmark:** the goal is what we want to learn from observing products *and
     why* (e.g. "benchmark X's onboarding to inform our redesign", or "purely
     benchmark how X does Y, no build decision").
   - **Usability:** the goal is what **decision the test informs** and which
     product/flow is under test (e.g. "find where our checkout flow confuses users
     before the redesign ships").
   - **If the goal is vague, implicit, or missing, STOP and ask the user before
     scaffolding.** Do not invent it, and never leave it as `TBD`. Record the
     confirmed goal in the README `## Goal` section.

4. **Derive the slug.** Build it defensively from the topic (after stripping the
   `--type` flag):
   - lowercase everything;
   - strip quotes, apostrophes, brackets, and other punctuation entirely (don't turn
     them into hyphens — `"users' data"` → `users-data`, not `users--data`);
   - replace any run of spaces/remaining separators with a single hyphen;
   - collapse repeated hyphens and trim leading/trailing hyphens;
   - keep it concise — if the topic is a long sentence, use the meaningful head
     (roughly the first 5–6 words / ~50 chars), not the whole thing.

   Get today's date with `date +%F` (or the harness-provided current date if
   available). Folder path = `research/<YYYY-MM-DD>-<slug>/`.

5. **Scaffold the folder — by type.** Every type gets `README.md`, `PLAN.md`, and
   `sources.md`; the middle differs.
   - **Common to all types:**
     - `research/<...>/sources.md` — header `# Sources — <topic>` and a table with
       columns: Source | URL | Accessed | Notes.
     - `research/<...>/README.md` — the research brief (template below; set the
       `TYPE` line to the chosen type).
     - `research/<...>/PLAN.md` — the plan (template below).
   - **`benchmark`:** also create `research/<...>/platforms/` (empty; one subfolder
     per platform gets added during capture).
   - **`usability`:** also create `research/<...>/sessions/` (empty; one
     `session-NN.md` per participant gets added after fielding). The detailed
     instrument (`test-plan.md`) is **not** created here — it is built by
     `/plan-usability` in step 7.
   - **`litreview` (evidence from documents):** also create
     `research/<...>/corpus/` (empty; user drops supplied PDFs/reports here — it is
     **gitignored**, never committed). Do **not** create `platforms/` or `data/`. The
     verified `evidence.md` is produced later by `/gather-evidence`, not here.

6. **Register the study, bind this terminal, and refresh the board.** **Append** the
   folder path (no trailing slash) as a new line in `.claude/.active-research` — do
   **not** overwrite existing lines, so other active studies are preserved. Then bind
   this terminal to it: derive your session id from the scratchpad path and write the
   folder path into `.claude/.current-research/<session-id>` (create the dir if absent).
   See `.claude/references/active-research.md`. Finally refresh `BOARD.md` so the new
   study shows as **Active** — re-derive it from the `research/` folders + the registry
   exactly as `/research-board` does (update the `## Active` and `## Closed & archived`
   tables and the `_Last updated:_` date). Don't print the full board here; just keep
   the file in sync.

7. **Draft the plan and run the quality gate — by type.**

   **Benchmark** (the plan is what the Principal Researcher signs off on before any
   capture):
   - **You need the platforms first.** If the topic names them, draft the plan now; if not,
     **use Mobbin to propose candidates** — `mcp__claude_ai_Mobbin__search_flows` for the
     flow the study is about — and present the shortlist to the user rather than asking cold.
   - **Pick a source per platform.** Mobbin is the default. Chrome requires one of the C1–C5
     triggers from `.claude/references/mobbin-sourcing.md`, and the trigger **must be written
     into `PLAN.md`**. Before claiming C2 ("no Mobbin coverage"), actually search — do not
     assume.
   - **Draft `PLAN.md`:** derive key research questions from the `## Goal`, list the
     platforms with their **Source** and (for Chrome) the trigger, and for each name the
     specific flows/screens to capture, the success criteria, and known risks.
   - **Dispatch the Principal Researcher (Mode A)** via the Agent tool (`general-purpose`)
     with `.claude/personas/principal-researcher.md`, the drafted `PLAN.md`, and the
     `README.md`. It returns must-fixes.
   - **Revise `PLAN.md`** and **present it to the user for approval.** Capture begins only
     after they approve.

   **Usability** (the plan here is the lightweight brief; the detailed instrument
   comes next):
   - **Draft `PLAN.md`** with the objectives + research questions derived from the
     `## Goal`, the product/flow under test, and the intended participant profile at
     a high level. This is the goal-alignment plan, not the full script.
   - **Dispatch the Principal Researcher (Mode A)** with the persona spec, `PLAN.md`,
     and `README.md`, to check the objectives actually serve the goal and are
     answerable by a usability test. Revise and **present to the user for approval.**
   - Then tell the user the next step is **`/plan-usability`**, which designs the
     `test-plan.md` instrument (tasks, script, metrics) and runs its own Principal
     Researcher methodology review before any sessions are fielded. **Do not** start
     designing tasks here.

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

   **Give every research question an ID and an honest `Answerable?` value.** A question
   this study's method cannot answer is not a defect in the question — it is a fact worth
   knowing *before* capture is spent. Mark it `No — deferred to <what would answer it>`
   and either carry it or drop it. The Principal Researcher will not approve a plan with
   an unmarked unanswerable question. See `.claude/references/coverage-contract.md`.

8. **Confirm** to the user: folder created, the type, the confirmed goal, the
   approved plan, and the correct next step for the type (capture via Claude-in-Chrome
   for benchmark; `/plan-usability` for usability).

---

README.md template (set `TYPE`; the `## Goal` is required — never `TBD`; leave other
fields TBD only where genuinely unknown):

```
# Research: <Topic>

- **Status:** Active
- **Type:** <benchmark | usability | litreview>
- **Started:** <YYYY-MM-DD>
- **Researcher:** Claude (acting Senior UI/UX Designer)
- **Coverage:** <written by /close-research from the synthesis coverage table>

## Goal
<the confirmed goal from step 3 — what we want to learn and why. For benchmark,
state whether this is observation only or input to a build decision. For usability,
state which product/flow is under test and what decision the results inform.
/review-research judges the synthesis against this.>

## Scope
<what's in / out of scope>

## <Platforms to benchmark | Product & participants | Corpus & questions>   <!-- benchmark: platforms list; usability: product under test + participant profile; litreview: provided corpus + research questions -->
- [ ] <platform 1, or participant-profile note>
- [ ] <platform 2>

## Log
- <YYYY-MM-DD> — research created (type: <type>).
```

PLAN.md template — **benchmark** (leave the per-platform block as a skeleton if
platforms are not named yet):

```
# Research Plan: <Topic>

- **Status:** Draft (pending Principal Researcher review + user approval)
- **Type:** benchmark
- **Goal it serves:** <one line — the confirmed goal from the README>

## Research questions

Each question gets a stable ID. IDs are never renumbered and never reused — a dropped
question becomes a `Withdrawn` row. See `.claude/references/coverage-contract.md`.

| ID | Question | Method that will answer it | Answerable by this study? |
|---|---|---|---|
| Q1 | <question derived from the goal> | <e.g. Mobbin capture across 4 platforms> | Yes |

## Per-platform capture plan
### <platform 1>
- **Source:** <mobbin | chrome>
- **Chrome trigger (chrome only):** <C1 our own product | C2 no Mobbin coverage, verified by search | C3 live behaviour needed | C4 currency is the question | C5 Android-specific>
- **Flows/screens to capture:** <the specific flows and key screens>
- **What we're looking for:** <the patterns/answers tied to the questions above>
- **Risks:** <paywalls, login/PII, capture blockers — note that Mobbin sourcing removes the paywall and PII risks>

## Success criteria (what "done" looks like)
- <concrete, checkable>

## Principal Researcher review
<filled in during step 7: critique summary + verdict, then user approval>
```

PLAN.md template — **usability**:

```
# Research Plan: <Topic>

- **Status:** Draft (pending Principal Researcher review + user approval)
- **Type:** usability
- **Goal it serves:** <one line — the confirmed goal from the README>

## Objectives & research questions

- <what decision this test informs>

Each question gets a stable ID, carried through to `test-plan.md` tasks and the synthesis
coverage table. See `.claude/references/coverage-contract.md`.

| ID | Question | Method that will answer it | Answerable by this study? |
|---|---|---|---|
| Q1 | <question the test must answer> | <e.g. moderated task 2, think-aloud> | Yes |

## Product / flow under test
- <the specific product and flow participants will attempt>

## Participants (high level)
- **Profile:** <who we want>   **Target N:** <e.g. 5–8>

## Success criteria (what "done" looks like)
- <e.g. "each research question answered by observed behaviour across ≥5 participants">

## Principal Researcher review
<filled in during step 7: goal-alignment critique + verdict, then user approval>

> Next: run `/plan-usability` to design the test-plan.md instrument (tasks,
> moderator script, metrics) and pass its methodology review before fielding.
```

PLAN.md template — **litreview**:

```
# Research Plan: <Topic>

- **Status:** Draft (pending Principal Researcher review + user approval)
- **Type:** litreview
- **Goal it serves:** <one line — the confirmed goal from the README>

## Research questions

Each question gets a stable ID, carried into `evidence.md` claims and the synthesis
coverage table. See `.claude/references/coverage-contract.md`.

| ID | Question | Method that will answer it | Answerable by this study? |
|---|---|---|---|
| Q1 | <question derived from the goal> | <e.g. deep-research over corpus + search angle 2> | Yes |

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

After creating everything, do NOT jump ahead. Complete the type-appropriate plan gate
in step 7 and get the user's approval first. For benchmark, capture begins only after
that; for usability, the next step is `/plan-usability`.
