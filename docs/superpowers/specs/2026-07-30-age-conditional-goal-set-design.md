# Age-Conditional Learning-Goal Set — Design Spec

**Date:** 2026-07-30
**Component:** `design/onboarding-solve-edu` (PRD + `src/` prototype)
**Status:** Approved, pending implementation plan

## Goal

Make the organic goal-intake option set depend on the learner's declared age band. A
learner who selects **13–17** sees three goals instead of six, and that selection carries
through the existing handoff to the Learning Home unchanged in mechanism.

The screen title stays **"What do you want to get better at?"** for every band. Only the
option set changes.

| Band | Option set |
|---|---|
| `teen` (13–17) | English & Communication · Math & Science · Life skills |
| `young_adult` (18–24) | the existing six, unchanged |
| `adult_25_34` · `adult_35_44` · `adult_45_54` · `adult_55_plus` (25–64+) | the existing six, unchanged |

The existing six are: Data and analysis, Customer service, Project management, Digital
marketing, Communication, Language skills.

## Context

The prototype's organic path is landing → name → country → **age** → gender → **goal** →
save-wall → home. Two facts about the current build govern this change:

- **The goal list is flat and unconditional.** `src/data.js:199` declares one
  `goalOptions` array, exported as `window.goalOptions`. `renderGoalCards()`
  (`src/main.js:438`) iterates it directly. Nothing about the list consults the age band.
- **The band is already stored.** `selectAgeOption()` (`src/main.js:384`) writes
  `appState.selectedAgeCategory`, with `'teen'` as the 13–17 value
  (`src/main.js:42`). The value the conditional needs is already on state at the moment
  the goal screen renders.

Carry-over to the home is a **finalization-time write**, not a render-time lookup.
`finishOnboarding()` (`src/main.js:735`) resolves the goal id against `COURSE_MAP`
(`src/main.js:715`) and writes `initialCourseId`, `courseTitle`, `skillTotal`,
`firstSkillTitle`, and `firstSkillMinutes` into the `se_handoff` session payload.
`home.html` / `home.js` read that payload and never see the goal list. Adding goals
therefore requires **no change to the home surface** — only new `COURSE_MAP` rows.

`COURSE_MAP` deliberately omits `language`, so the home's unmapped empty state is
reachable through a real data path (`src/main.js:731`). That omission is preserved.

## Evidence position

**The three teen categories are an assumption, not a finding.** No finding in any study in
the project's `Informed by:` list proposes them, and the PRD's Mode S gate fails a PRD
that states unevidenced claims as fact.

The **mechanism** — conditioning an intake option set on a declared age band — has a
same-shape precedent in `research/2026-07-28-post-signup-handoff-first-run-home`: Khan
Academy's *Grade 9* branch produced *Pre-algebra, Algebra 1, High school geometry*
(`SYNTHESIS.md:1165`), and that study describes its Primary / Secondary / University
options as "age bands under a different label" (`SYNTHESIS.md:711`).

**That precedent is recorded in the study's gaps section, not adopted as a finding**, and
this spec does not promote it to one. Consequences:

- §2 of the PRD carries the change as an **assumption with a named owner and a validation
  path**, in the register already used for layout F7/F9 ("adopted as labelled
  hypotheses") and for the Slice 5 gender step ("the one intake field with no research
  behind it").
- **§2.1's findings-coverage table gains no row.** No new finding is adopted, so the
  25-row accounting and its `20 Adopted · 4 Deferred · 1 Contradicted` summary stay
  intact.
- The validation path is the `goal_selected` distribution read **by age band**, which is
  why the analytics criterion in §9 gains the band (see *PRD changes* below). Without
  that field the assumption is not falsifiable.

## Approach

**Option sets keyed by age band.** `data.js` exports a band-keyed map plus a resolver;
`renderGoalCards()` asks the resolver for the current band.

Two alternatives were considered and rejected:

- **Tag each goal with eligible bands** (one flat list of nine, rendered by filter).
  Rejected: the sets are decided not to overlap (see *Band switching* below), so the
  flexibility buys nothing, and it makes "which set is this learner in" a computed answer
  rather than a named one.
- **A separate teen goal screen.** Rejected: duplicates the markup, the ARIA wiring, and a
  branch of the state machine for three cards.

## Requirements

### Option sets (`src/data.js`)

`goalOptions` is replaced by `goalOptionsByBand`, with `default` holding the existing six
verbatim and `teen` holding the three new ones:

| id | title | icon | colour |
|---|---|---|---|
| `english` | English & Communication | `record_voice_over` | `var(--blue)` |
| `math_science` | Math & Science | `calculate` | `var(--green)` |
| `life_skills` | Life skills | `self_improvement` | `var(--magenta)` |

Ids follow the existing single-token convention (`data`, `customer`, `project`,
`marketing`, `communication`, `language`) and collide with none of them. Icons are
Material Symbols Rounded names, as the existing six are. Colours reuse tokens already
present in the file; no new token is introduced.

A resolver `goalOptionsFor(band)` returns `goalOptionsByBand[band]` or, for any band with
no entry, `goalOptionsByBand.default`. Both the map and the resolver are exported on
`window`, replacing `window.goalOptions`.

### Rendering (`src/main.js`)

`renderGoalCards()` iterates `goalOptionsFor(appState.selectedAgeCategory)` instead of the
module-level list. Card markup, the `goal-card` class, `aria-pressed`, and the click
binding are unchanged.

**No structural HTML change.** `#goal_grid` (`src/onboarding.html:401`) is populated by JS
and the title at `:398` already reads "What do you want to get better at?". The one edit is
the placeholder comment at `:402`, which names `goalOptions` and would otherwise point at a
symbol that no longer exists.

**No CSS change.** `.goal-grid` is `repeat(3, minmax(0, 1fr))` (`src/styles.css:628`), so
three cards render as a single full row, and the existing 768px (2-col) and 420px (1-col)
queries apply to the teen set without modification.

### Band switching clears the goal

A learner can select 13–17, choose a teen goal, navigate back, and switch to 25–64. The
stored goal would then not exist in the visible set.

**Rule: changing the age band to one that resolves a different option set clears
`appState.selectedGoal`.** Continue's disabled state is already derived from
`selectedGoal` in `updateHeaders()` (`src/main.js:183`), so clearing the goal re-disables
Continue with its stated requirement automatically — no second code path.

Implementation: `selectAgeOption()` routes its two writes to `appState.selectedAgeCategory`
(`src/main.js:388`, `:402`) through a `setAgeCategory(category)` helper that compares
`goalOptionsFor(previous)` against `goalOptionsFor(next)` and clears the goal when they
differ.

The adult branch sets the category to `null` transiently while the sub-range options are
shown (`src/main.js:396`). `goalOptionsFor(null)` resolves to `default`, so choosing
*I am an adult* and then a sub-range never clears twice, and a teen → adult switch clears
exactly once at the first write.

**A goal is never preserved across a set change even if the id exists in both sets.** The
sets share no ids today, so the two rules are indistinguishable in behaviour; the simpler
one is chosen because it is statable as a single criterion.

### Carry-over to the home (`src/main.js` `COURSE_MAP`)

Three rows are added, in the register of the existing five:

| Goal id | Course id | Title | Skills | First skill | Minutes |
|---|---|---|---|---|---|
| `english` | `eng-1` | Everyday English Communication | 5 | Introduce yourself | 6 |
| `math_science` | `msci-1` | Math and Science Foundations | 6 | Read a data table | 8 |
| `life_skills` | `life-1` | Everyday Life Skills | 4 | Plan a weekly budget | 7 |

**These are prototype placeholders, exactly as the existing five are.** The real mapping is
a Program Operations input under the PRD's existing §15 goal-to-course open decision, and
the PRD says so rather than presenting these titles as shipping curriculum.

`language` remains absent from `COURSE_MAP`, and `communication` keeps
`firstSkillMinutes: null`. Both null-path guards stay reachable.

`home.html` and `home.js` are not modified.

## PRD changes (`design/onboarding-solve-edu/PRD.md`)

- **§2 Problem & Evidence** — a new assumption entry stating the three teen categories as
  an owned assumption with Program Operations / curriculum as owner and the by-band
  `goal_selected` distribution as the validation path. It names the Khan Academy
  band-conditioned branch as a same-shape precedent **recorded in a gaps section, not
  adopted as a finding**.
- **§2.1 Findings coverage** — unchanged. No new finding is adopted; the row count and
  summary stand.
- **Slice 6** (`PRD.md:762`) — rewritten from a flat six-item list to an age-conditional
  set, with both lists stated and the shared screen title noted.
- **§9 Slice 6 acceptance criteria** (`PRD.md:957`) — four edits and one criterion left
  deliberately unchanged:
  - "Six localized goal cards render from configuration in the approved order" becomes
    band-conditional (three for 13–17, six for the other bands).
  - "Back navigation preserves the current goal" (`:963`) narrows to *within the same
    option set*.
  - A new criterion: changing the age band to one with a different option set clears any
    stored goal and re-disables Continue with its stated requirement.
  - The `goal_selected` criterion (`:966`) gains the age band that determined the option
    set — the field the §2 validation path depends on. It remains PII-free.
  - The "each configured goal resolves to exactly one first course" criterion (`:962`) is
    unchanged in wording and now governs nine goals.
- **§11 Screens, IA & Empty States** — the goal-screen entry notes the conditional set.
- **§13 Data Model** — no schema change. `goal_id?` is already a free identifier and the
  band that produced it is recoverable from `age_band` on the same record. A note records
  that the goal-id namespace is shared across bands, so ids must stay globally unique.
- **§15 Rabbit Holes & Open Questions** — the open goal-to-course decision is extended to
  cover the three teen goals.
- **Prototype Element Dictionary** — unchanged. The goal card is the same component.

## Test guards (`src/src-prototype.test.ps1`)

Three checks, in the style of the existing suite (assert the rule exists in source, with a
comment recording why):

1. The `teen` set is exactly three ids and shares no id with the `default` set — the
   condition is real, not a copy of the same list under a second key.
2. Every id in the `teen` set has a `COURSE_MAP` entry, so no teen learner reaches the
   home's unmapped state by omission rather than by design. `language` stays deliberately
   absent from the map and is not covered by this check.
3. The band-change clear path exists in `main.js` — the rule is enforced in code, not only
   asserted in the PRD.

## Out of scope

- **The flat root-level prototype.** `design/onboarding-solve-edu/data.js`, `main.js`,
  `prototype-web.html`, `standalone.html`, and `prototype-web.test.ps1` are the reference
  build that predates the `src/` convention and were "left untouched as the reference"
  when the split happened (`README.md:47`). They carry their own `goalOptions` at
  `data.js:199` and their own stale `COURSE_MAP`. **They are not updated by this change**
  and `prototype-web.test.ps1` must stay green without modification. Only `src/` is built.
- The program path. Program learners never see the goal screen (`src/main.js:414`), and
  Slice 6 already excludes them.
- The 18–24 and 25–64 option sets, which are unchanged.
- Any change to `home.html`, `home.js`, `onboarding.html`, or `styles.css`.
- Real curriculum content for the three teen courses. Placeholder rows only, with the real
  mapping recorded as a §15 open decision.
