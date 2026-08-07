# Age-Conditional Goal Set, and One Shared Choice Card — Design Spec

**Date:** 2026-07-30
**Component:** `design/onboarding-solve-edu` (PRD + `src/` prototype)
**Status:** Approved, pending implementation plan

## Goal

Three changes to the organic funnel, in one pass because they touch the same two screens'
markup:

1. **The goal-intake option set depends on the declared age band.** A learner who selects
   **13–17** sees three goals instead of six, and that selection carries through the
   existing handoff to the Learning Home unchanged in mechanism.
2. **The age gate and the goal screen render one shared card component**, at the age
   gate's larger scale. Today they are two implementations of one visual idea, and the age
   gate's half is inline styles.
3. **The age gate's seven controls become real buttons.** They are non-semantic `div`s
   today, so the screen is not keyboard-operable.

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
save-wall → home. Four facts about the current build govern this change:

- **The goal list is flat and unconditional.** `src/data.js:199` declares one
  `goalOptions` array, exported as `window.goalOptions`. `renderGoalCards()`
  (`src/main.js:438`) iterates it directly. Nothing about the list consults the age band.
- **The band is already stored.** `selectAgeOption()` (`src/main.js:384`) writes
  `appState.selectedAgeCategory`, with `'teen'` as the 13–17 value
  (`src/main.js:42`). The value the conditional needs is already on state at the moment
  the goal screen renders.
- **The age gate is styled inline.** Its grid (`:335`) and all three primary cards
  (`:336`, `:344`, `:352`) carry `style` attributes, so no media query can reach them —
  the same condition the Cycle 3 Learning Home work had to undo before it could lay the
  home out at narrow width.
- **The age gate is not keyboard-operable.** Those three cards and the four adult
  sub-ranges (`:364`–`:367`) are `div`s with click handlers, no `tabindex`, and no `role`.
  The gender cards at `:387`–`:389` are already buttons, so this is a gap in one screen,
  not a project-wide convention.

Carry-over to the home is a **finalization-time write**, not a render-time lookup.
`finishOnboarding()` (`src/main.js:735`) resolves the goal id against `COURSE_MAP`
(`src/main.js:715`) and writes `initialCourseId`, `courseTitle`, `skillTotal`,
`firstSkillTitle`, and `firstSkillMinutes` into the `se_handoff` session payload.
`home.html` / `home.js` read that payload and never see the goal list. Adding goals
therefore requires **no change to the home surface** — only new `COURSE_MAP` rows.

`COURSE_MAP` deliberately omits `language`, so the home's unmapped empty state is
reachable through a real data path (`src/main.js:731`). That omission is preserved.

## Evidence position

**Both halves of this change are assumptions, not findings:** conditioning an intake option
set on a declared age band, and the three teen categories themselves. No finding in any
study in the project's `Informed by:` list proposes either, and the PRD's Mode S gate fails
a PRD that states unevidenced claims as fact.

**What the cited research supports, from a finding.** `research/2026-07-28-post-signup-handoff-first-run-home`
records under **F6** that Khan Academy asks an age-band proxy question with its payoff on the
modal, *"What grade are you in? / We'll gather the right lessons for you"*, and reads that
screen's Primary / Secondary / University options as "age bands under a different label"
(`SYNTHESIS.md:711`, inside F6, which opens at `SYNTHESIS.md:691`). That supports **asking**
a band question and telling the learner it will shape their content. It says nothing about
varying the option set by band.

**What it does not support, and the correction that matters.** An earlier draft of this
section cited Khan Academy's *Grade 9 → Pre-algebra, Algebra 1, High school geometry* walk
(`SYNTHESIS.md:1165`) as a same-shape precedent for the conditioning mechanism. That is
wrong twice over. The line sits in `## Gaps & caveats` (opens at `SYNTHESIS.md:1056`) and
reads "Intake branches are mine on both Chrome platforms": the grade and the three courses
were **the researcher's own selections, not system output**, and the same caveat states that
"findings about *which* content was recommended do not generalise". It is not evidence for
the mechanism, and the "age bands under a different label" quote it was fused with is not in
the gaps section at all. Consequences:

- §2 of the PRD carries **both** claims as assumptions with a named owner and a validation
  path, in the register already used for the Slice 5 gender step ("the one intake field
  with no research behind it"). The comparison to layout F7/F9 is dropped: those are
  adopted study findings labelled as hypotheses, and borrowing their register for a claim
  with no study behind it flatters it.
- **§2.1's findings-coverage table gains no row.** No new finding is adopted, so the
  25-row accounting and its `20 Adopted · 4 Deferred · 1 Contradicted` summary stay
  intact.
- The validation path is the `goal_selected` distribution read **by age band**, which is
  why the analytics criterion in §9 gains the band (see *PRD changes* below). Without
  that field the assumption is not falsifiable. The **pass** condition, a share threshold
  and a minimum teen sample, is not invented here: it is a named §15 open decision owned by
  Program Operations and Product with Data. §2 states the two failure shapes it can already
  recognise and stops there.

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

**One shared card class rather than restyling `.goal-card` up to match.** Copying the age
gate's scale into `.goal-card` would produce the same picture from two declarations, and
would leave the age gate's inline styles in place — so the next responsive change has to be
made twice and can drift. Converging on one class costs the same edit and removes the
duplication, and it is the reason the a11y fix below is cheap: the seven age controls are
already being rewritten.

The rejected direction was the reverse — moving the age gate down to `.goal-card`'s compact
treatment. It de-inlines equally well but shrinks the age gate instead of enlarging the goal
screen.

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
module-level list. The element stays a `<button type="button">` with `aria-pressed` and the
same click binding; only the class it emits changes, from `goal-card` to `choice-card`
(see *Shared card component*).

`#goal_grid` (`src/onboarding.html:401`) is populated by JS and the title at `:398` already
reads "What do you want to get better at?", so neither changes. The placeholder comment at
`:402` names `goalOptions` and is updated, since that symbol no longer exists.

The grid keeps its column rules: `.goal-grid` stays `repeat(3, minmax(0, 1fr))`
(`src/styles.css:628`), so three cards render as a single full row and six render as two,
and the existing 768px (2-col) and 420px (1-col) queries apply to the teen set without
modification. Two properties change: `gap` 16px → 24px, and the width cap.

**The width cap is not cosmetic.** `styles.css:169` sets
`.card:not(.landing-card):not(.home-card) > * { max-width: 520px }`, and `#goal_grid` is a
direct child of `#goal_intake`, so the goal grid renders at **520px** — three columns of
roughly 162px. The age gate escapes that cap with `max-width: 900px !important` inline on
its wrapper, which is why its cards have room for a 48px icon and a 20px/800 title. Putting
the larger card into a 520px grid would cramp it, so the width travels with the card.

A `.card-wide` class carries it, applied to the age wrapper, the goal heading wrapper, and
`#goal_grid`:

```css
.card:not(.landing-card):not(.home-card) > .card-wide { max-width: 900px; }
```

The selector repeats the `:not()` chain deliberately. At `(0,4,0)` it outranks the `(0,3,0)`
cap on line 169; a bare `.card-wide` at `(0,1,0)` would lose, which is what the existing
`!important` was compensating for. No `!important` is needed and none is added.

### Shared card component

The age gate and the goal screen converge on one class, at the age gate's scale. They
already share the border, radius, `0 4px 0` shadow, and the hover/active/selected rule
groups (`src/styles.css:664`–`:683`); what differs is scale, and the age half is expressed
as inline `style` attributes rather than CSS.

A new `.choice-card` carries the large treatment — the flex-column centring, `40px 16px`
padding, and a 16px internal gap — with `.choice-card-icon` at 48px, `.choice-card-title`
at 20px/800, and an **optional** `.choice-card-support` at 14px/0.8 opacity. Single-dash
child names, matching the file's existing `.goal-card-title`, `.option-title`, and
`.option-icon`; the file uses no BEM double underscore anywhere.

| Screen | Markup today | After |
|---|---|---|
| Age primary (`:336`, `:344`, `:352`) | `option-card` + inline styles, 48px icon, 20px/800 title, support line | `option-card choice-card`, inline styles deleted, support line kept |
| Goal cards (`main.js:447`) | `goal-card`, 36px icon, 16px/600 title, no support line | `choice-card`, no support line |

Two constraints the implementation must respect:

- **`.option-card` stays on the age cards.** The peer-deselection queries at
  `src/main.js:386` and `:391` select `.option-card` within the two age containers.
  Keeping the class means the selection JS needs no change; removing it would silently
  break deselection.
- **`.goal-card` is retired into `.choice-card`,** which means `.choice-card` must be added
  to the existing hover, active, focus-visible, and `.selected` selector lists rather than
  redeclaring them. The `.goal-card` rules at `:636`–`:686` are removed once nothing
  references them.

**Goal cards get no support line.** The class makes it optional and the goal set has no
second line of copy today; inventing one-line descriptions for nine goals is new product
copy, not a restyle, and is out of scope.

The age gate's own grid (`auto-fit, minmax(220px, 1fr)`, inline at `:335`) moves into CSS
with the card, since a media query cannot reach an inline style — the same reason recorded
for the Cycle 3 Learning Home work.

### Age-gate control semantics

Seven controls on the age gate are `<div class="option-card">` with click handlers, no
`tabindex`, and no `role`: the three primary cards (`:336`, `:344`, `:352`) and the four
adult sub-ranges (`:364`–`:367`). They are not keyboard-focusable and are not announced as
controls. The gender cards directly below them (`:387`–`:389`) are already
`<button type="button" aria-pressed>`, and so are the goal cards, so the age gate is the
one screen that was missed.

All seven become `<button type="button">` carrying `aria-pressed`, kept in sync on
selection exactly as `selectGender()` already does (`src/main.js:424`). The three primary
cards additionally get `.choice-card`; the four sub-range chips keep `.option-card` alone,
since they are text-only and not the large treatment.

The icons are decorative next to a visible text label, so they take `aria-hidden="true"` —
consistent with the Cycle 3 navigation work.

`#age-primary-options` and `#age-adult-options` gain `role="group"` with an `aria-labelledby`
pointing at the heading each already sits under — the `h1` at `:333` and the "Which range
fits best?" `h2` at `:362`. Both the gender options (`:380`) and the goal grid (`:401`)
already do this; without it the seven buttons are announced as seven unrelated controls.
Slice 5 names a programmatic group label for the gender step and this makes the age step
match.

This is folded in here rather than deferred because it is the same seven elements' markup
that the inline-style removal already rewrites. PRD Slice 10 makes keyboard operation an
acceptance requirement for every slice, and `src/src-prototype.test.ps1:185` already
asserts the rule for the Learning Home's destinations.

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
- **§9 Slice 5 acceptance criteria** (`PRD.md:940`) — one new criterion, mirroring the one
  the gender step already carries at `:951`: each age option exposes its selected state via
  `aria-pressed` or radio semantics and shows a visible focus ring. **The absence of this
  parallel criterion is why the age gate shipped as `div`s while the gender step beside it
  shipped as buttons**, so the fix is written into the criteria, not only into the markup.
- **§11 Screens, IA & Empty States** — the goal-screen entry notes the conditional set.
- **§13 Data Model** — no schema change. `goal_id?` is already a free identifier and the
  band that produced it is recoverable from `age_band` on the same record. A note records
  that the goal-id namespace is shared across bands, so ids must stay globally unique.
- **§15 Rabbit Holes & Open Questions** — the open goal-to-course decision is extended to
  cover the three teen goals.
- **Prototype Element Dictionary** — Appendix A.3 is value-addressed rather than
  component-addressed, so the shared card class does not reach it. Its **Goal** row gains a
  note that the presented option set is conditioned on the age band while the durable
  representation stays a stable goal identifier.

**The shared card component itself needs no PRD change.** The PRD specifies behaviour and
requirements, not class names, and the visual treatment of a recognition-based option was
never pinned to a scale in it. Only the a11y criterion above is a requirement change.

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
4. The age gate carries **no clickable `div`** — every control in `#age-primary-options` and
   `#age-adult-options` is a `button`, and both containers carry a `role="group"` with a
   label. This is the `:185` rule applied to the second screen that needed it.
5. `#age_gate` carries **no `style=` attribute**, so the inline layout cannot creep back and
   put the age gate out of reach of a media query again.
6. `.goal-card` no longer appears in `styles.css` or in `main.js` — the retirement is
   complete rather than leaving two card systems where the spec claims one.

### Re-measurement, not just assertion

The Cycle 3 work recorded a measured result: **0 overflowing elements and 0 targets below
24×24 at 320/360/414/768/1440 on both pages**. Enlarging every goal card from a 36px icon
to a 48px one, widening the grid gap, and moving the age grid out of inline styles can all
break that. The claim is re-measured at the same five widths and the number restated, or
corrected. A restyle that quietly invalidates a measured guardrail is the failure this
project's suite exists to prevent.

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
- Any change to `home.html` or `home.js`. The home reads the handoff, not the goal list,
  and the shared card class is not used on that surface.
- **The gender gate's cards.** They are already buttons with `aria-pressed` at equal visual
  weight, and Slice 5 requires the opt-out to sit at the same weight as the other two.
  Promoting them to the large `.choice-card` treatment would be a third screen's redesign
  and could disturb that criterion.
- **Support-line copy for the goal cards.** The shared class supports one; writing nine of
  them is new product copy.
- Real curriculum content for the three teen courses. Placeholder rows only, with the real
  mapping recorded as a §15 open decision.
