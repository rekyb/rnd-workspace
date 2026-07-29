---
description: Design the usability-test instrument (test-plan.md) for the active usability research — tasks, moderator script, metrics — then get a Principal Researcher methodology review before fielding.
---

Design the usability-test **instrument** for the currently active research. This is
the one method-specific step on the type-aware spine: it produces `test-plan.md`
(the analogue of a benchmark capture plan) and gates it through the Principal
Researcher before any sessions are run.

Runs only when the active research is `TYPE: usability`.

Steps:

1. **Locate & type-check.** Resolve the target study per
   `.claude/references/active-research.md` (explicit `[folder]` arg, else this
   terminal's binding, else the sole active study, else ask). If the registry is
   empty, STOP and tell the user to run `/new-research "<topic>" --type usability`
   first. Read the folder's `README.md`; if `TYPE` is not `usability`, STOP and tell
   the user this command only applies to usability research (the resolved study is
   `TYPE: <that type>`).

2. **Read the objectives.** Read `PLAN.md` (objectives + research questions) and the
   `README.md` (goal/scope). These anchor the instrument: **every task must trace
   back to a research question.** If `PLAN.md` has no clear objectives yet, STOP and
   work them out with the user first, don't invent them.

3. **Draft `test-plan.md` WITH the user.** Work through the sections below, asking
   the user where you need real input (participant profile, target N, success
   thresholds). Do not fabricate a participant profile or a success criterion.
   - **Participants** — profile, screener criteria, target N (typically 5–8 for a
     formative test), recruiting note (fielding is external to this workspace).
   - **Method** — moderated / unmoderated, remote / in-person, think-aloud y/n.
   - **Task scenarios (4–6)** — realistic and **non-leading**: describe a goal and
     context, never the UI steps or the feature name that gives away the answer
     ("You want to get back to a lesson you started yesterday" — not "click the
     Continue button"). Each task gets a **success criterion** and an optional max
     time.
   - **Moderator script** — intro + consent, a warm-up, the tasks with **neutral
     probes** ("What are you thinking?", "What did you expect to happen?"), and
     wrap-up questions.
   - **Metrics** — task success rate, time-on-task, error count, a post-task ease
     question (SEQ) and/or SUS, plus the **0–4 severity scale** used to rank issues.
   - **Consent & PII** — session data lives in `sessions/` and is redacted /
     pseudonymized (P01, P02…) before any commit.

   Every task names the `Q#` it serves, and every `Q#` marked `Yes` or `Partial` in
   `PLAN.md` is served by at least one task. A question no task touches will come back
   `Unanswered` at synthesis — better to find that now, while the instrument is still
   editable. See `.claude/references/coverage-contract.md`.

   Use the template at the bottom.

4. **Principal Researcher methodology review (quality gate — before fielding).**
   Dispatch the Principal Researcher as a subagent (Agent tool, `general-purpose`)
   in **Mode A (plan review)**, handing it the persona spec at
   `.claude/personas/principal-researcher.md`, the drafted `test-plan.md`, and the
   `README.md` (goal/scope). Tell it explicitly that this is a **usability
   instrument**, so it should check that: tasks are **non-leading**, the sample and
   method fit the research questions, the moderator script is **unbiased**, every
   success criterion is **measurable**, and the metrics actually answer the
   objectives. It returns must-fixes.
   **Revise `test-plan.md`** to address them (pre-field revisions may be applied
   directly), then **present the plan to the user for approval.** Do not field until
   they approve.

5. **Update the log** in the research `README.md` with a dated "usability test plan
   drafted + Principal Researcher review" entry.

6. **Report** to the user: the task count, the Principal Researcher's verdict and the
   must-fixes addressed, and the next step — **field the sessions externally**, then
   drop one redacted note per participant into `sessions/session-NN.md` (structure
   below), and run `/synth-findings` to synthesize the findings.

---

`test-plan.md` template:

```
# Usability Test Plan — <product / flow under test>

- **Status:** Draft (pending Principal Researcher review + user approval)
- **Goal it serves:** <one line — the confirmed goal from the README>

## Objectives & research questions
- <question 1 the test must answer>
- <question 2 …>

## Participants
- **Profile / screener:** <who qualifies>
- **Target N:** <e.g. 5–8>
- **Recruiting:** external (not fielded from this workspace)

## Method
- [ ] Moderated  [ ] Unmoderated  ·  [ ] Remote  [ ] In-person  ·  Think-aloud: <y/n>

## Task scenarios
| # | Scenario (non-leading) | Serves | Success criterion | Max time |
|---|---|---|---|---|
| 1 | <goal + context, no UI hints> | <Q# from PLAN.md — which research question this task produces evidence for> | <observable pass condition> | <mm:ss> |

## Moderator script
1. **Intro + consent** — purpose, recording, no right/wrong answers, participant may stop anytime.
2. **Warm-up** — 1–2 easy context questions.
3. **Tasks** — read each scenario verbatim; use neutral probes only
   ("What are you thinking?", "What did you expect?"). Do not help unless blocked past the max time.
4. **Wrap-up** — SEQ/SUS, overall impressions, anything confusing.

## Metrics
- Task success rate · time-on-task · error count · SEQ (per task) and/or SUS (overall).
### Severity scale (0–4)
0 not a problem · 1 cosmetic · 2 minor (low priority) · 3 major (high priority) · 4 catastrophe (must fix).

## Consent & PII
Session notes go in `sessions/`. Pseudonymize participants (P01, P02…); redact names,
faces, voices, emails, and identifying quotes before any commit.
```

Per-session note template (`sessions/session-NN.md`, one per participant, PII-redacted):

```
# Session NN — <YYYY-MM-DD>

- **Participant:** P<NN> (pseudonym — no real name/PII)
- **Profile:** <how they match the screener>
- **Setup:** <device / browser, moderated-remote, etc.>

## Task results
| Task | Success (Y / partial / N) | Time | Errors | Notes / quotes (redacted) |
|---|---|---|---|---|

## Observations
- <key moments, friction, confusion, delight — quotes with PII removed>

## Post-task
- SEQ / SUS: <scores>
- Comments: <verbatim, redacted>
```
