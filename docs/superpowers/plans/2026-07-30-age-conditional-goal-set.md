# Age-Conditional Goal Set, and One Shared Choice Card — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A learner who selects the 13–17 age band sees three learning goals instead of six, that choice carries through to the Learning Home, and the age gate and goal screen render one shared card component that is keyboard-operable.

**Architecture:** `data.js` replaces its flat `goalOptions` array with a band-keyed map plus a resolver; `renderGoalCards()` asks the resolver for the current band. A new `.choice-card` CSS class replaces `.goal-card` and absorbs the age gate's inline styles, so both screens render one component. The age gate's seven `div` controls become `button`s. Carry-over to the home is unchanged in mechanism — three new rows in the existing `COURSE_MAP`, which `finishOnboarding()` already resolves into the `se_handoff` payload.

**Tech Stack:** Plain HTML/CSS/ES5-style JS (no build step, no framework, no package manager). Tests are text-pattern assertions in PowerShell (`src-prototype.test.ps1`). Browser verification via the Claude-in-Chrome MCP tools against `python -m http.server`.

**Spec:** `docs/superpowers/specs/2026-07-30-age-conditional-goal-set-design.md`

## Global Constraints

- **`src/` only.** Never edit `design/onboarding-solve-edu/data.js`, `main.js`, `prototype-web.html`, `standalone.html`, or `prototype-web.test.ps1`. Those are the reference build, deliberately frozen at the `src/` split (`README.md:47`). Everything in this plan is under `design/onboarding-solve-edu/src/`.
- **Run the suite from inside `src/`.** It resolves paths with `$PSScriptRoot`: `cd design/onboarding-solve-edu/src && powershell -NoProfile -File src-prototype.test.ps1`.
- **Baseline is 83 checks, 15 groups, PASSED.** Measured 2026-07-30 before this work. Every task must leave it passing with a higher count.
- **The group count is hard-coded** in the final report line (`src-prototype.test.ps1`, last 6 lines): `"src-prototype.test.ps1 PASSED - $($script:Checks) checks, 15 groups"`. Task 5 adds a 16th group and must update that string, or the suite reports a lie while passing.
- **No new design token.** Colours must be `var(--…)` names already present in `styles.css`.
- **No em-dashes in prototype copy.** House vocabulary rule, `.claude/references/prompt-vocabulary.md`.
- **Goal ids are stable keys.** `english`, `math_science`, `life_skills`. Never the display label.
- **`language` stays absent from `COURSE_MAP`** and `communication` keeps `firstSkillMinutes: null`. Both are live null-path guards asserted by the suite at the `firstSkillMinutes:\s*null` check; deleting either makes an existing test unreachable-but-green.
- **`.option-card` stays on the three age primary cards.** `main.js:386` and `:391` select `.option-card` inside the two age containers to deselect peers. Removing the class silently breaks deselection with no test failure.
- **PowerShell test strings:** the suite's `Check` messages are single-quoted PowerShell strings. A literal `'` inside one must be doubled (`''`), and `$` is safe in single quotes. Prefer wording that avoids apostrophes.
- **Baseline counts, measured 2026-07-30 against the current files.** Every "expected N" in this plan derives from these, so re-measure before assuming a mismatch is a bug in your edit: `onboarding.html` holds **6** `!important` declarations (only the age and goal ones are removed here), the age-gate block holds **23** `style=` attributes and **7** `option-card` divs, and `main.js` writes `aria-pressed` in **3** places and `appState.selectedAgeCategory` in **3**.

---

## File Structure

| File | Responsibility | Tasks |
|---|---|---|
| `src/data.js` | Static config only. Owns the band-keyed goal sets and the resolver. No DOM, no state. | 1 |
| `src/main.js` | Funnel state machine, screen rendering, and the finalization handoff. | 1, 2, 3, 4, 5 |
| `src/styles.css` | All presentation. Gains `.choice-card` + `.card-wide` + the age-grid classes; loses `.goal-card`. | 4, 5 |
| `src/onboarding.html` | Funnel markup. Age gate loses its inline styles and its `div` controls. | 5 |
| `src/src-prototype.test.ps1` | The regression suite. Gains checks in Tasks 1–5 and a new group in Task 5. | 1, 2, 3, 4, 5 |
| `design/onboarding-solve-edu/PRD.md` | The decision doc. | 7 |
| `design/onboarding-solve-edu/README.md` | Status log. | 7 |

`src/home.html` and `src/home.js` are **not** modified by any task. The home reads the `se_handoff` payload, never the goal list.

---

### Task 1: Age-conditional goal option sets

**Files:**
- Modify: `design/onboarding-solve-edu/src/data.js:199-209`
- Modify: `design/onboarding-solve-edu/src/main.js:438-456` (`renderGoalCards`)
- Modify: `design/onboarding-solve-edu/src/onboarding.html:402` (stale comment)
- Test: `design/onboarding-solve-edu/src/src-prototype.test.ps1`

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces:
  - `window.goalOptionsByBand` — object keyed by age-band string, each value an array of `{ id, title, icon, color }`. Keys: `teen`, `default`.
  - `window.goalOptionsFor(band)` — `(string|null) => Array<{id,title,icon,color}>`. Returns `goalOptionsByBand[band]` when present, otherwise `goalOptionsByBand.default`. Task 2 calls this to compare sets.

- [ ] **Step 1: Write the failing tests**

Append a new group to `src/src-prototype.test.ps1`, immediately before the `# ---------------------------------------------------------------- report` line:

```powershell
# ---------------------------------------------------------------- 16
Show-Group 'The goal set is conditioned on the declared age band'

# A 13-to-17 learner is offered a different set of goals from an adult. The
# three teen categories are a labelled assumption in PRD section 2, not a
# finding, and the by-band goal_selected read is what would falsify them.
$dataJs = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'data.js') -Raw
$dataCode = Remove-Comments $dataJs

Check ($dataCode -match 'goalOptionsByBand') `
  'data.js still declares one flat goal list, so every age band sees the same six options'
Check ($dataCode -match 'function goalOptionsFor') `
  'there is no resolver, so the render path has to know the shape of the band map'
Check ($dataCode -notmatch 'window\.goalOptions\s*=') `
  'the old flat export survives. Two sources for one list is how they drift apart'
foreach ($id in @('english', 'math_science', 'life_skills')) {
  Check ($dataCode -match "id:\s*'$id'") "the teen set is missing the $id goal"
}
Check ($mainCode -match 'goalOptionsFor\(appState\.selectedAgeCategory\)') `
  'renderGoalCards does not consult the age band, so the conditional set is unreachable'
Check ($mainCode -notmatch 'goalOptions\.forEach') `
  'renderGoalCards still iterates the flat list'

# The condition has to be real. A teen key holding a copy of the same six, or
# sharing ids with them, passes every check above while changing nothing.
$teenBlock = ''
if ($dataCode -match '(?s)teen:\s*\[(.*?)\]') { $teenBlock = $Matches[1] }
$teenIds = [regex]::Matches($teenBlock, "id:\s*'([a-z_]+)'") | ForEach-Object { $_.Groups[1].Value }
Check ($teenIds.Count -eq 3) `
  "the teen set holds $($teenIds.Count) goals; expected 3"
$sharedIds = $teenIds | Where-Object { @('data','customer','project','marketing','communication','language') -contains $_ }
Check ($sharedIds.Count -eq 0) `
  "the teen set reuses $($sharedIds -join ', ') from the default set. Identifiers must be unique across bands"
```

- [ ] **Step 2: Run the tests to verify they fail**

```bash
cd design/onboarding-solve-edu/src && powershell -NoProfile -File src-prototype.test.ps1
```

Expected: `FAILED`, with all 10 new checks listed. Two fail because the old code is still there (`notmatch 'goalOptions\.forEach'`, `notmatch 'window\.goalOptions'`); the rest fail because the new code does not exist yet. The two `$teenIds` checks report `0` and `0` respectively, since the isolation regex finds no `teen:` key.

- [ ] **Step 3: Replace the flat list in `data.js`**

Replace `src/data.js` lines 199–209 (from `const goalOptions = [` through `window.goalOptions = goalOptions;`) with:

```javascript
/* The presented goal set depends on the declared age band. The three teen
   categories are a labelled assumption in PRD section 2 with Program
   Operations as owner, not a research finding: no study in the project's
   Informed by list proposes them. The by-band goal_selected distribution is
   what would validate or kill them. */
const goalOptionsByBand = {
  teen: [
    { id: 'english',      title: 'English & Communication', icon: 'record_voice_over', color: 'var(--blue)' },
    { id: 'math_science', title: 'Math & Science',          icon: 'calculate',         color: 'var(--green)' },
    { id: 'life_skills',  title: 'Life skills',             icon: 'self_improvement',  color: 'var(--magenta)' }
  ],
  default: [
    { id: 'data', title: 'Data and analysis', icon: 'bar_chart', color: 'var(--blue)' },
    { id: 'customer', title: 'Customer service', icon: 'support_agent', color: 'var(--magenta)' },
    { id: 'project', title: 'Project management', icon: 'assignment', color: 'var(--green)' },
    { id: 'marketing', title: 'Digital marketing', icon: 'campaign', color: 'var(--red)' },
    { id: 'communication', title: 'Communication', icon: 'forum', color: 'var(--purple)' },
    { id: 'language', title: 'Language skills', icon: 'language', color: 'var(--blue)' }
  ]
};

/* Any band with no entry of its own gets the default set. The adult branch
   parks selectedAgeCategory at null while its sub-ranges are open, and that
   null must resolve to the same set the sub-ranges will, or switching into
   the adult branch would read as a set change and clear the goal twice. */
function goalOptionsFor(band) {
  return goalOptionsByBand[band] || goalOptionsByBand.default;
}

window.allCountries = allCountries;
window.goalOptionsByBand = goalOptionsByBand;
window.goalOptionsFor = goalOptionsFor;
```

Note the existing `window.allCountries = allCountries;` line sits inside this replaced block — it is reproduced above and must not be lost.

- [ ] **Step 4: Point `renderGoalCards` at the resolver**

In `src/main.js`, replace line 443 (`goalOptions.forEach(goal => {`) with:

```javascript
      goalOptionsFor(appState.selectedAgeCategory).forEach(goal => {
```

Nothing else in the function changes. It stays a `<button type="button">` with `aria-pressed`, and the `card.className` line is left alone in this task — Task 4 changes it.

- [ ] **Step 5: Fix the stale comment**

In `src/onboarding.html` line 402, replace:

```html
        <!-- Populated from goalOptions by JS -->
```

with:

```html
        <!-- Populated by renderGoalCards from the band-resolved goal set -->
```

- [ ] **Step 6: Run the tests to verify they pass**

```bash
cd design/onboarding-solve-edu/src && powershell -NoProfile -File src-prototype.test.ps1
```

Expected: `PASSED - 93 checks`. The report still says `15 groups` — that string is hard-coded and Task 5 corrects it. If Group 0 (`The scripts actually parse`) fails, `data.js` has a syntax error: check the brace/bracket balance of the replaced block.

- [ ] **Step 7: Commit**

```bash
git add design/onboarding-solve-edu/src/data.js design/onboarding-solve-edu/src/main.js design/onboarding-solve-edu/src/onboarding.html design/onboarding-solve-edu/src/src-prototype.test.ps1
git commit -m "feat(prototype): condition the goal set on the declared age band

A 13-to-17 learner is offered English & Communication, Math & Science and
Life skills; every other band keeps the existing six. data.js replaces its
flat goalOptions array with a band-keyed map and a resolver, so the set
boundary is named in one place rather than computed at the call site.

The three teen categories are a labelled assumption owned by Program
Operations, not a finding. No study in the project's Informed by list
proposes them.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 2: Changing the age band clears the goal

**Files:**
- Modify: `design/onboarding-solve-edu/src/main.js:384-407` (`selectAgeOption`)
- Test: `design/onboarding-solve-edu/src/src-prototype.test.ps1`

**Interfaces:**
- Consumes: `goalOptionsFor(band)` from Task 1.
- Produces: `setAgeCategory(category)` — `(string|null) => void`. The single writer of `appState.selectedAgeCategory`. Clears `appState.selectedGoal` when the resolved option set changes.

**Why this exists:** a learner can pick 13–17, choose "Math & Science", press Back, and switch to 25–64. Without this, the stored goal is one the goal screen never showed them, and `finishOnboarding()` would resolve a course from it.

- [ ] **Step 1: Write the failing tests**

Append to the Group 16 block created in Task 1, after the existing checks:

```powershell
# Slice 6: back navigation preserves the goal within an option set, but a band
# switch that changes the set discards it. Continue re-disables for free,
# because updateHeaders derives its disabled state from selectedGoal.
Check ($mainCode -match 'function setAgeCategory') `
  'the age category is written directly, so nothing can notice that the option set changed'
Check ($mainCode -match 'appState\.selectedGoal = null') `
  'switching age band leaves a goal selected that the new set does not contain'
$rawWrites = ([regex]::Matches($mainCode, 'appState\.selectedAgeCategory\s*=')).Count
Check ($rawWrites -eq 1) `
  "$rawWrites places write selectedAgeCategory; expected 1, inside setAgeCategory. A second writer bypasses the clear"
```

- [ ] **Step 2: Run the tests to verify they fail**

```bash
cd design/onboarding-solve-edu/src && powershell -NoProfile -File src-prototype.test.ps1
```

Expected: `FAILED` with 3 new failures, including `3 places write selectedAgeCategory; expected 1` — the three assignments at `main.js:388`, `:396`, and `:402`, measured against the current file.

- [ ] **Step 3: Add the helper and route both writes through it**

In `src/main.js`, insert this function immediately before `function selectAgeOption` (currently line 384):

```javascript
    /* The one writer of selectedAgeCategory. A band whose option set differs
       from the outgoing one invalidates any goal already chosen, because that
       goal is not in the set the learner is about to see. Clearing it here is
       enough to re-disable Continue: updateHeaders derives the disabled state
       from selectedGoal, so there is no second code path to keep in step.
       Compared by resolved set, not by raw category, so opening the adult
       branch (which parks the category at null) does not read as a change. */
    function setAgeCategory(category) {
      if (goalOptionsFor(appState.selectedAgeCategory) !== goalOptionsFor(category)) {
        appState.selectedGoal = null;
      }
      appState.selectedAgeCategory = category;
    }
```

Then replace the three assignments inside `selectAgeOption`:

- line 388, `appState.selectedAgeCategory = category;` → `setAgeCategory(category);`
- line 396, `appState.selectedAgeCategory = null;` → `setAgeCategory(null);`
- line 402, `appState.selectedAgeCategory = category;` → `setAgeCategory(category);`

The identity comparison (`!==`) is correct here and is the point: `goalOptionsFor` returns the *same array object* for every band that maps to `default`, so adult → adult-sub-range compares equal and teen → adult does not.

- [ ] **Step 4: Run the tests to verify they pass**

```bash
cd design/onboarding-solve-edu/src && powershell -NoProfile -File src-prototype.test.ps1
```

Expected: `PASSED - 96 checks`.

If `$rawWrites` still reads 4, the `setAgeCategory` body itself contains one assignment (correct, it should be exactly 1) plus three un-replaced call sites — recheck lines 388, 396, and 402.

- [ ] **Step 5: Verify the behaviour in a browser**

```bash
cd design/onboarding-solve-edu/src && python -m http.server 8765
```

Open `http://localhost:8765/onboarding.html`, then: Get started → name → country → **I am a teen** → Continue → gender → Continue → pick **Math & Science** → press the onboarding Back button twice to reach the age gate → pick **I am an adult** → **25-34** → Continue → gender → Continue.

Expected on arriving at the goal screen: six cards, **none selected**, and Continue **disabled**. Then press Back to the age gate, re-pick **I am an adult** → **35-44**, and confirm a goal chosen before that sub-range switch is still selected (both sub-ranges resolve the same set, so nothing is cleared).

- [ ] **Step 6: Commit**

```bash
git add design/onboarding-solve-edu/src/main.js design/onboarding-solve-edu/src/src-prototype.test.ps1
git commit -m "fix(prototype): clear the goal when the age band changes its option set

A learner could pick 13-17, choose a teen goal, go back, switch to 25-64 and
finalize on a goal the screen never showed them. All writes to
selectedAgeCategory now route through setAgeCategory, which compares the
resolved option sets and clears the goal when they differ.

Continue re-disables with no second code path, because updateHeaders already
derives its disabled state from selectedGoal. Opening the adult branch parks
the category at null, which resolves to the default set, so it does not read
as a set change.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 3: Carry the teen goals through to the Learning Home

**Files:**
- Modify: `design/onboarding-solve-edu/src/main.js:715-721` (`COURSE_MAP`)
- Test: `design/onboarding-solve-edu/src/src-prototype.test.ps1`

**Interfaces:**
- Consumes: the goal ids `english`, `math_science`, `life_skills` from Task 1.
- Produces: nothing new. `finishOnboarding()` already reads `COURSE_MAP[goal]` and writes `initialCourseId`, `courseTitle`, `skillTotal`, `firstSkillTitle`, and `firstSkillMinutes` onto the `se_handoff` payload.

- [ ] **Step 1: Write the failing tests**

Append to the Group 16 block:

```powershell
# Slice 6 requires each configured goal to resolve to exactly one first course.
# language is deliberately unmapped so the home unmapped state stays reachable
# through real data, so this asserts the teen ids only, not every id.
foreach ($id in @('english', 'math_science', 'life_skills')) {
  Check ($mainCode -match "'$id':\s*\{") `
    "the $id goal has no course, so a teen learner reaches the unmapped home state by omission rather than by design"
}
Check ($mainCode -notmatch "'language':\s*\{") `
  'language gained a course. The unmapped path is then unreachable through real data and its guard passes vacuously'
```

- [ ] **Step 2: Run the tests to verify they fail**

```bash
cd design/onboarding-solve-edu/src && powershell -NoProfile -File src-prototype.test.ps1
```

Expected: `FAILED` with 3 new failures naming `english`, `math_science`, and `life_skills`.

- [ ] **Step 3: Add the three rows**

In `src/main.js`, inside the `COURSE_MAP` object literal, add three entries after the `'communication'` row (line 720). The trailing `'communication'` line currently has no comma — add one:

```javascript
    'communication': { id: 'comm-1',    title: 'Workplace Communication',        skills: 4, firstSkill: 'Ask a clarifying question',   firstSkillMinutes: null },
    /* The teen set. Placeholder titles in the same register as the five above:
       the real goal-to-course mapping is a Program Operations input under the
       PRD section 15 open decision, not a curriculum claim made here. */
    'english':       { id: 'eng-1',     title: 'Everyday English Communication', skills: 5, firstSkill: 'Introduce yourself',          firstSkillMinutes: 6 },
    'math_science':  { id: 'msci-1',    title: 'Math and Science Foundations',   skills: 6, firstSkill: 'Read a data table',           firstSkillMinutes: 8 },
    'life_skills':   { id: 'life-1',    title: 'Everyday Life Skills',           skills: 4, firstSkill: 'Plan a weekly budget',        firstSkillMinutes: 7 }
```

- [ ] **Step 4: Run the tests to verify they pass**

```bash
cd design/onboarding-solve-edu/src && powershell -NoProfile -File src-prototype.test.ps1
```

Expected: `PASSED - 100 checks`.

- [ ] **Step 5: Verify the handoff end to end in a browser**

With `python -m http.server 8765` running in `src/`, walk: Get started → name → country → **I am a teen** → gender → **Life skills** → create an account.

Expected on `home.html`: the primary action names **Plan a weekly budget** with a **7 min** bound, and the skills line reads **0 of 4 skills**. No streak pill, no points pill, no unmapped empty state.

Then repeat choosing **English & Communication** and confirm **Introduce yourself** / **6 min** / **0 of 5 skills**.

- [ ] **Step 6: Commit**

```bash
git add design/onboarding-solve-edu/src/main.js design/onboarding-solve-edu/src/src-prototype.test.ps1
git commit -m "feat(prototype): map the three teen goals to first courses

Each configured goal must resolve to exactly one first course (Slice 6), so
the three teen goals get COURSE_MAP rows and the handoff carries a named,
time-bounded first skill for them like every other goal.

Placeholder titles in the register of the existing five. The real mapping is
a Program Operations input under the PRD section 15 open decision.

language stays unmapped so the home unmapped state is still reachable through
real data, and communication keeps a null duration so the omit-rather-than-
default path stays reachable too.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 4: One shared `.choice-card`, replacing `.goal-card`

**Files:**
- Modify: `design/onboarding-solve-edu/src/styles.css:628-694`
- Modify: `design/onboarding-solve-edu/src/main.js:447` (`card.className`)
- Modify: `design/onboarding-solve-edu/src/onboarding.html:397, 401`
- Test: `design/onboarding-solve-edu/src/src-prototype.test.ps1`

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: CSS classes `.choice-card`, `.choice-card-icon`, `.choice-card-title`, `.choice-card-support`, `.card-wide`. Task 5 applies all five to the age gate.

**Why the width matters:** `styles.css:169` caps every direct child of a `.card` at 520px, and `#goal_grid` is a direct child — so the goal grid renders at 520px today, about 162px per column. The age gate escapes that with an inline `max-width: 900px !important`. A 48px icon and a 20px/800 title do not fit in 162px, so the width has to travel with the card.

- [ ] **Step 1: Write the failing tests**

Append to the Group 16 block:

```powershell
# The age gate and the goal screen always rendered one visual idea at two
# scales, with the age half expressed as inline styles a media query cannot
# reach. One class now carries both.
Check ($styles -match '\.choice-card\s*\{') `
  'there is no shared card class, so the two screens are still two implementations of one component'
Check ($styles -notmatch '\.goal-card') `
  'goal-card survives somewhere in the stylesheet. Two card systems is the duplication this removes'
Check ($mainCode -notmatch 'goal-card') `
  'renderGoalCards still emits the retired class, so the goal cards render unstyled'
Check ($styles -match '\.card-wide') `
  'nothing overrides the 520px cap on line 169, so the enlarged goal cards render about 162px wide'
Check ($styles -match '(?s)\.card:not\(\.landing-card\):not\(\.home-card\)\s*>\s*\.card-wide') `
  'card-wide is declared at too low a specificity to beat the 520px cap and would need !important'
Check ($styles -notmatch '\.card-wide[^{]*\{[^}]*!important') `
  'card-wide wins by !important rather than by specificity'
# Scoped to the goal screen only. The age gate still carries its own inline
# 900px override at this point; Task 5 removes that one and asserts globally.
$goalScreen = ''
if ($onboarding -match '(?s)id="goal_intake"(.*?)id="assigned_content"') { $goalScreen = $Matches[1] }
Check ($goalScreen.Length -gt 0) 'could not isolate the goal_intake markup'
Check ($goalScreen -notmatch '!important') `
  'the goal screen still overrides the 520px cap inline instead of by specificity'
Check ($goalScreen -match 'id="goal_grid"[^>]*card-wide') `
  'the goal grid is not widened, so the enlarged cards render inside the 520px cap'
```

- [ ] **Step 2: Run the tests to verify they fail**

```bash
cd design/onboarding-solve-edu/src && powershell -NoProfile -File src-prototype.test.ps1
```

Expected: `FAILED` with 7 new failures (`could not isolate the goal_intake markup` should **not** be among them — the isolation works against the current markup too).

- [ ] **Step 3: Replace the card CSS**

In `src/styles.css`, replace the whole block from line 628 (`.goal-grid {`) through line 694 (the closing `}` of the 420px media query) with:

```css
.goal-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 24px;
  width: 100%;
  margin: 32px auto;
}

/* Line 169 caps every direct child of a .card at 520px. Both wide surfaces
   used to escape it with inline `max-width: 900px !important`. This wins on
   specificity instead: repeating the :not() chain scores (0,4,0) against that
   rule's (0,3,0), so no !important is needed. A bare .card-wide would score
   (0,1,0) and lose, which is what the !important was compensating for. */
.card:not(.landing-card):not(.home-card) > .card-wide {
  max-width: 900px;
}

/* The shared recognition card, used by the age gate and the goal screen.
   The support line is optional: the age bands carry one, the goals do not. */
.choice-card {
  min-height: 144px;
  border: 2px solid var(--hair);
  border-radius: 16px;
  padding: 40px 16px;
  background: var(--surf);
  color: var(--ink);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 16px;
  text-align: center;
  cursor: pointer;
  box-shadow: 0 4px 0 var(--hair-dark);
  transition: transform 0.2s var(--easing-fast), box-shadow 0.2s var(--easing-fast), border-color 0.2s, background 0.2s;
}

.choice-card:focus-visible {
  outline: 3px solid color-mix(in srgb, var(--purple) 30%, transparent);
  outline-offset: 3px;
}

.choice-card.selected {
  border-color: var(--purple);
  background: var(--purple-bg);
  box-shadow: 0 4px 0 var(--purple-dark);
}

.option-card:hover, .choice-card:hover, .choice-card:focus-visible {
  border-color: var(--purple);
  background: var(--purple-bg);
  transform: translateY(-4px);
  box-shadow: 0 8px 0 var(--hair-dark), 0 12px 24px rgba(0,0,0,0.08);
}

.option-card.selected:hover, .choice-card.selected:hover, .choice-card.selected:focus-visible {
  box-shadow: 0 8px 0 var(--purple-dark), 0 12px 24px rgba(0,0,0,0.08);
}

.option-card:active, .choice-card:active {
  transform: translateY(4px);
  box-shadow: 0 0px 0 var(--hair-dark);
  transition: transform 0.05s, box-shadow 0.05s;
}

.option-card.selected:active, .choice-card.selected:active {
  box-shadow: 0 0px 0 var(--purple-dark);
}

.choice-card-icon { font-size: 48px; }
.choice-card-title { display: block; font: 800 20px/1.3 var(--font-head); }
.choice-card-support { display: block; margin-top: 8px; font-size: 14px; opacity: 0.8; }

@media (max-width: 768px) {
  .goal-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
}

@media (max-width: 420px) {
  .goal-grid { grid-template-columns: 1fr; }
}
```

- [ ] **Step 4: Emit the new classes from `renderGoalCards`**

In `src/main.js`, replace line 447:

```javascript
        card.className = `goal-card${isSelected ? ' selected' : ''}`;
```

with:

```javascript
        card.className = `choice-card${isSelected ? ' selected' : ''}`;
```

and replace the `card.innerHTML` template at lines 449–452:

```javascript
        card.innerHTML = `
          <span class="material-symbols-rounded choice-card-icon" aria-hidden="true" style="color: ${goal.color};">${goal.icon}</span>
          <span class="choice-card-title">${goal.title}</span>
        `;
```

The inline `color` stays: it is per-goal data from the config, not layout, and no media query needs to reach it. `aria-hidden="true"` is added because the icon sits next to a visible label and would otherwise be announced as part of the button name.

- [ ] **Step 5: Widen the goal screen**

In `src/onboarding.html`, replace line 397:

```html
      <div class="text-center" style="margin-top: 16px; max-width: 900px !important; width: 100%;">
```

with:

```html
      <div class="text-center card-wide goal-intake-head">
```

and line 401:

```html
      <div id="goal_grid" class="goal-grid card-wide" role="group" aria-labelledby="goal_intake_title">
```

Then add the replaced inline properties to `src/styles.css`, directly after the `.card-wide` rule:

```css
.goal-intake-head { margin-top: 16px; width: 100%; }
```

- [ ] **Step 6: Run the tests to verify they pass**

```bash
cd design/onboarding-solve-edu/src && powershell -NoProfile -File src-prototype.test.ps1
```

Expected: `PASSED - 107 checks`.

- [ ] **Step 7: Verify in a browser**

With the server running, walk to the goal screen on the adult path. Expected: six cards in two rows of three, each with a 48px icon above a 20px bold title, spanning ~900px rather than ~520px. Hover lifts the card; click gives it the purple selected treatment; `Tab` moves between cards and shows the focus ring.

- [ ] **Step 8: Commit**

```bash
git add design/onboarding-solve-edu/src/styles.css design/onboarding-solve-edu/src/main.js design/onboarding-solve-edu/src/onboarding.html design/onboarding-solve-edu/src/src-prototype.test.ps1
git commit -m "refactor(prototype): one choice-card for the age gate and the goal screen

goal-card is retired into a shared .choice-card at the age gate's scale: a
48px icon, a 20px/800 title, and an optional support line. The two screens
rendered one visual idea as two declarations.

The width travels with the card. styles.css line 169 caps every direct child
of a .card at 520px and #goal_grid is one, so the goal grid rendered about
162px per column, which does not hold a 48px icon. .card-wide lifts it to
900px by specificity rather than by the !important the inline override used.

Goal icons gain aria-hidden: they sit beside a visible label and were being
read into the button name.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 5: The age gate becomes keyboard-operable and loses its inline styles

**Files:**
- Modify: `design/onboarding-solve-edu/src/onboarding.html:331-371`
- Modify: `design/onboarding-solve-edu/src/main.js:372-407` (`showAdultOptions`, `hideAdultOptions`, `selectAgeOption`)
- Modify: `design/onboarding-solve-edu/src/styles.css` (append the age-gate classes)
- Modify: `design/onboarding-solve-edu/src/src-prototype.test.ps1` (new group + the hard-coded group count)
- Test: `design/onboarding-solve-edu/src/src-prototype.test.ps1`

**Interfaces:**
- Consumes: `.choice-card`, `.choice-card-icon`, `.choice-card-title`, `.choice-card-support`, `.card-wide` from Task 4; `setAgeCategory` from Task 2.
- Produces: nothing later tasks depend on.

**Why now:** the three primary cards (`:336`, `:344`, `:352`) and the four adult sub-ranges (`:364`–`:367`) are `<div>`s with click handlers, no `tabindex`, and no `role` — not focusable, not announced as controls. The gender cards at `:387`–`:389` are already buttons and so are the goal cards. This is the same seven elements the inline-style removal rewrites, so it costs one edit instead of two.

- [ ] **Step 1: Write the failing tests**

Insert a **new group** into `src/src-prototype.test.ps1`, immediately before the `# ---------------------------------------------------------------- report` line:

```powershell
# ---------------------------------------------------------------- 17
Show-Group 'The age gate is operable by keyboard, like every screen beside it'

# Seven controls on this screen were divs with click handlers, no tabindex and
# no role, while the gender cards directly below them were already buttons.
# PRD Slice 10 makes keyboard operation an acceptance requirement for every
# slice, and the same rule is asserted for the home destinations in group 9.
$ageGate = ''
if ($onboarding -match '(?s)id="age_gate"(.*?)id="gender_gate"') { $ageGate = $Matches[1] }
Check ($ageGate.Length -gt 0) 'could not isolate the age_gate markup'

Check ($ageGate -notmatch '<div[^>]*class="[^"]*option-card') `
  'an age option is still a non-semantic div. It must be operable by keyboard, not merely clickable'
$ageButtons = ([regex]::Matches($ageGate, '<button[^>]*class="[^"]*option-card')).Count
Check ($ageButtons -eq 7) `
  "$ageButtons age options are buttons; expected 7 (three bands plus four adult sub-ranges)"
$agePressed = ([regex]::Matches($ageGate, 'aria-pressed')).Count
Check ($agePressed -eq 7) `
  "$agePressed age options expose a pressed state; expected 7. A visual highlight tells assistive technology nothing"
Check ($ageGate -notmatch 'style=') `
  'the age gate still carries inline styles, which no media query can reach'
$ageGroups = ([regex]::Matches($ageGate, 'role="group"')).Count
Check ($ageGroups -eq 2) `
  "$ageGroups age containers declare a group; expected 2. Without it seven buttons are announced as seven unrelated controls"
$ageBareIcons = ([regex]::Matches($ageGate, '<span[^>]*material-symbols-rounded(?![^>]*aria-hidden)[^>]*>')).Count
Check ($ageBareIcons -eq 0) `
  "$ageBareIcons age icons carry no aria-hidden, so a band is announced as 'backpack I am a teen'"
Check ($mainCode -notmatch "getElementById\('age-adult-options'\)\.style\.display") `
  'the sub-range group is shown by writing an inline display, which is the state a media query cannot reach'
# Counted, not matched. Three places already write aria-pressed (two in
# selectGender, one in renderGoalCards), so a bare -match passes before
# selectAgeOption writes it at all, and a check that is green before the change
# gates nothing. Those three plus four from selectAgeOption: the two peer
# sweeps, the sub-range sweep, and the selected element.
$pressedWrites = ([regex]::Matches($mainCode, "setAttribute\('aria-pressed'")).Count
Check ($pressedWrites -eq 7) `
  "$pressedWrites places write aria-pressed; expected 7. selectAgeOption sets a class but not the pressed state the markup declares"
```

**No global `!important` check.** `onboarding.html` carries six, on the name, country, age, gender, goal, and program-preview wrappers; this work removes exactly two of them (age and goal). A whole-file assertion would fail permanently. The age half is covered by the `style=` check above, which is stricter, and the goal half by Task 4's scoped check.

- [ ] **Step 2: Run the tests to verify they fail**

```bash
cd design/onboarding-solve-edu/src && powershell -NoProfile -File src-prototype.test.ps1
```

Expected: `FAILED` with 8 of the 9 new checks failing. Verified against the current files: `7` divs carry `option-card`, `0` buttons do, `0` expose `aria-pressed`, the block holds `23` `style=` attributes, `0` containers declare a group, `3` icons lack `aria-hidden`, and `3` places write `aria-pressed`. Only `could not isolate the age_gate markup` should pass — the isolation regex works against the current markup (3023 characters captured).

- [ ] **Step 3: Add the age-gate CSS**

Append to `src/styles.css`, after the `.choice-card-support` rule:

```css
/* Age gate. Every one of these values was an inline style attribute, which
   put the whole screen out of reach of a media query — the same condition the
   Cycle 3 Learning Home work had to undo before it could lay out at 360px. */
.age-gate-inner {
  width: 100%;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.age-gate-heading { width: 100%; }
.age-gate-heading .title { margin-top: 0; }

.age-option-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 24px;
  margin-top: 48px;
  width: 100%;
}

.age-subrange-group {
  display: none;
  flex-direction: column;
  gap: 16px;
  margin-top: 32px;
  width: 100%;
}

.age-subrange-group.is-open { display: flex; }

.age-subrange-heading {
  font-size: 20px;
  font-weight: 700;
  margin-bottom: 8px;
}

.age-subrange-row {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  justify-content: center;
  gap: 16px;
  width: 100%;
}

.age-subrange-card {
  flex: 1;
  min-width: 120px;
  padding: 24px 16px;
}

/* The three band icon colours. Classes rather than inline style attributes,
   because the age gate must carry no style= at all: the goal cards can take
   their colour inline since it arrives as per-goal config data, but these
   three are fixed and belong in the stylesheet with everything else here. */
.age-icon-teen { color: var(--blue); }
.age-icon-young-adult { color: var(--green); }
.age-icon-adult { color: var(--magenta); }
```

- [ ] **Step 4: Rewrite the age-gate markup**

In `src/onboarding.html`, replace lines 331–371 in full (from `<div id="age_gate" class="card text-center">` through its closing `</div>`) with:

```html
    <!-- S3: Age Gate -->
    <div id="age_gate" class="card text-center">
      <div class="age-gate-inner card-wide">
        <div class="age-gate-heading"><h1 class="title" id="age_gate_title">How would you describe yourself?</h1></div>

        <div id="age-primary-options" class="age-option-grid" role="group" aria-labelledby="age_gate_title">
          <button type="button" class="option-card choice-card" id="age-btn-teen" aria-pressed="false">
            <span class="material-symbols-rounded choice-card-icon age-icon-teen" aria-hidden="true">backpack</span>
            <span>
              <span class="choice-card-title">I am a teen</span>
              <span class="choice-card-support">(13-17 years old)</span>
            </span>
          </button>

          <button type="button" class="option-card choice-card" id="age-btn-young-adult" aria-pressed="false">
            <span class="material-symbols-rounded choice-card-icon age-icon-young-adult" aria-hidden="true">school</span>
            <span>
              <span class="choice-card-title">I am a young adult</span>
              <span class="choice-card-support">(18-24 years old)</span>
            </span>
          </button>

          <button type="button" class="option-card choice-card" id="age-btn-adult" aria-pressed="false">
            <span class="material-symbols-rounded choice-card-icon age-icon-adult" aria-hidden="true">work</span>
            <span>
              <span class="choice-card-title">I am an adult</span>
              <span class="choice-card-support">(25-64 years old)</span>
            </span>
          </button>
        </div>

        <div id="age-adult-options" class="age-subrange-group" role="group" aria-labelledby="age_subrange_title">
          <h2 class="age-subrange-heading" id="age_subrange_title">Which range fits best?</h2>
          <div class="age-subrange-row">
            <button type="button" class="option-card age-subrange-card" id="age-btn-adult-25" aria-pressed="false">25-34</button>
            <button type="button" class="option-card age-subrange-card" id="age-btn-adult-35" aria-pressed="false">35-44</button>
            <button type="button" class="option-card age-subrange-card" id="age-btn-adult-45" aria-pressed="false">45-54</button>
            <button type="button" class="option-card age-subrange-card" id="age-btn-adult-55" aria-pressed="false">55+</button>
          </div>
        </div>
      </div>
    </div>
```

`.choice-card-title` and `.choice-card-support` are wrapped in a bare `<span>` so the card's 16px flex `gap` separates the icon from the text block, not each line from the next. Both already carry `display: block` from Task 4, so they stack inside that wrapper.

**No `style=` attribute may remain anywhere in this block.** The Step 1 check asserts that for the whole age gate, and the three band colours are the reason it would otherwise fail — they moved to `.age-icon-*` classes in Step 3.

- [ ] **Step 5: Toggle a class, not an inline display**

In `src/main.js`, replace `showAdultOptions` and `hideAdultOptions` (lines 372–381) with:

```javascript
    function showAdultOptions() {
      document.getElementById('age-adult-options').classList.add('is-open');
      setTimeout(() => {
        document.getElementById('age-adult-options').scrollIntoView({ behavior: 'smooth', block: 'end' });
      }, 50);
    }

    function hideAdultOptions() {
      document.getElementById('age-adult-options').classList.remove('is-open');
    }
```

- [ ] **Step 6: Keep `aria-pressed` in sync**

In `src/main.js`, inside `selectAgeOption`, every place that clears peers must clear the pressed state too, and the selected element must set it. Replace the body of `selectAgeOption` (lines 385–407, keeping the signature) with:

```javascript
      if (isAdultSubOption) {
        const peers = document.getElementById('age-adult-options').querySelectorAll('.option-card');
        peers.forEach(p => { p.classList.remove('selected'); p.setAttribute('aria-pressed', 'false'); });
        setAgeCategory(category);
        document.getElementById('global-continue-btn').disabled = false;
      } else {
        const peers = document.getElementById('age-primary-options').querySelectorAll('.option-card');
        peers.forEach(p => { p.classList.remove('selected'); p.setAttribute('aria-pressed', 'false'); });

        if (category === 'adult') {
          showAdultOptions();
          setAgeCategory(null);
          document.getElementById('global-continue-btn').disabled = true;
          const subPeers = document.getElementById('age-adult-options').querySelectorAll('.option-card');
          subPeers.forEach(p => { p.classList.remove('selected'); p.setAttribute('aria-pressed', 'false'); });
        } else {
          hideAdultOptions();
          setAgeCategory(category);
          document.getElementById('global-continue-btn').disabled = false;
        }
      }
      element.classList.add('selected');
      element.setAttribute('aria-pressed', 'true');
```

- [ ] **Step 7: Update the hard-coded group count**

In `src/src-prototype.test.ps1`, in the report block at the end, change:

```powershell
  Write-Host "src-prototype.test.ps1 PASSED - $($script:Checks) checks, 15 groups"
```

to:

```powershell
  Write-Host "src-prototype.test.ps1 PASSED - $($script:Checks) checks, 17 groups"
```

- [ ] **Step 8: Run the tests to verify they pass**

```bash
cd design/onboarding-solve-edu/src && powershell -NoProfile -File src-prototype.test.ps1
```

Expected: `PASSED - 116 checks, 17 groups`.

If `the age gate still carries inline styles` fails, a `style=` attribute survives in the block — find it and move the declaration into one of the `.age-*` classes from Step 3. Do not relax the check: it is the whole point of the task, and the age gate is the screen that proved an inline style cannot be reached by a media query.

- [ ] **Step 9: Verify keyboard operation in a browser**

With the server running, reach the age gate. Then, **using only the keyboard**:

- `Tab` reaches each of the three band cards in order and shows a focus ring on each.
- `Enter` or `Space` on **I am an adult** opens the sub-range group; `Tab` then reaches all four sub-ranges.
- `Enter` on **35-44** selects it and enables Continue.
- `Tab` reaches Continue and `Enter` advances to the gender gate.

Confirm in the browser's accessibility inspector that the selected card reports `pressed: true` and the other two `pressed: false`, and that the icons do not appear in any button's accessible name.

- [ ] **Step 10: Commit**

```bash
git add design/onboarding-solve-edu/src/onboarding.html design/onboarding-solve-edu/src/main.js design/onboarding-solve-edu/src/styles.css design/onboarding-solve-edu/src/src-prototype.test.ps1
git commit -m "fix(prototype): make the age gate operable by keyboard and reachable by CSS

Seven controls on this screen were divs with click handlers, no tabindex and
no role: three bands and four adult sub-ranges. They were not focusable and
were not announced as controls, while the gender cards directly below them
were already buttons and so were the goal cards. All seven are now buttons
with aria-pressed kept in sync on selection, both containers declare a
labelled group, and the band icons are hidden from the accessible name.

Every inline style on the screen moved into CSS, including the sub-range
group's show and hide, which wrote display directly. Inline styles are the
exact condition Cycle 3 had to undo before the Learning Home could lay out at
narrow width.

Suite gains a 17th group; the hard-coded group count in the report line is
updated, since a suite that miscounts its own groups reports a lie while
passing.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 6: Re-measure the responsive guardrail

**Files:**
- Modify: `design/onboarding-solve-edu/README.md` (status log entry only)

**Interfaces:**
- Consumes: the finished prototype from Tasks 1–5.
- Produces: a measured number for Task 7's PRD entry.

**Why:** the Cycle 3 work recorded **0 overflowing elements and 0 targets below 24×24 at 320/360/414/768/1440 on both pages** (`README.md:50`). Tasks 4 and 5 enlarge every goal card from a 36px icon to a 48px one, widen the goal grid from 520px to 900px, raise the grid gap, and move the age grid out of inline styles. Any of those can invalidate that measurement. A restyle that quietly breaks a measured guardrail is the failure this project's suite exists to prevent.

- [ ] **Step 1: Serve the prototype**

```bash
cd design/onboarding-solve-edu/src && python -m http.server 8765
```

- [ ] **Step 2: Measure at each width**

For each of 320, 360, 414, 768, and 1440 CSS px, on **both** `onboarding.html` (walked to the age gate, then to the goal screen on the teen path and again on the adult path) and `home.html`, run this in the page console via the Chrome MCP `javascript_tool`:

```javascript
(() => {
  const overflow = [...document.querySelectorAll('body *')]
    .filter(el => el.getBoundingClientRect().right > document.documentElement.clientWidth + 1)
    .map(el => el.tagName + '.' + el.className);
  const small = [...document.querySelectorAll('button, a, [role="button"]')]
    .filter(el => el.offsetParent !== null)
    .map(el => ({ el: el.id || el.className, w: Math.round(el.getBoundingClientRect().width), h: Math.round(el.getBoundingClientRect().height) }))
    .filter(x => x.w < 24 || x.h < 24);
  return JSON.stringify({ width: window.innerWidth, overflow, small }, null, 2);
})()
```

Expected at every width: `overflow: []` and `small: []`.

- [ ] **Step 3: Fix anything the measurement finds**

The likely failure is the goal grid at 421–768px: two columns of the enlarged card with a 24px gap and a wrapping 20px/800 title. If a card overflows, lower the 420px single-column breakpoint rather than shrinking the card — the card scale is the point of this change. Re-run Step 2 after any fix.

- [ ] **Step 4: Record the measurement**

Append a row to the status-log table in `design/onboarding-solve-edu/README.md`:

```markdown
| 2026-07-30 | **Age-conditional goal set, one shared choice card, and the age gate made keyboard-operable.** A 13-to-17 learner is offered English & Communication, Math & Science and Life skills; every other band keeps the six. `data.js` carries a band-keyed map plus a resolver, `setAgeCategory` clears a goal whose option set no longer contains it, and three `COURSE_MAP` rows carry the teen goals through the handoff. `.goal-card` retired into a shared `.choice-card` at the age gate's scale, with `.card-wide` lifting the goal grid off the 520px cap on `styles.css:169` by specificity rather than `!important`. The age gate's seven `div` controls became buttons with `aria-pressed`, both containers gained a labelled `role="group"`, and every inline style on the screen moved into CSS. **Re-measured at 320/360/414/768/1440 on both pages: 0 overflowing elements, 0 targets below 24x24.** Suite extended 83 -> 116 checks, 15 -> 17 groups. Flat reference files untouched and still green. |
```

Correct `83 -> 116` to whatever the suite actually reports, and correct the two measured numbers if Step 2 found anything. **Do not copy either through unverified** — a measurement claim that was never run is the fabrication class this project's suite exists to catch.

- [ ] **Step 5: Confirm the reference build is still green**

```bash
cd design/onboarding-solve-edu && powershell -NoProfile -File prototype-web.test.ps1
```

Expected: `PASSED`. No task in this plan touches the flat build; this confirms it.

- [ ] **Step 6: Commit**

```bash
git add design/onboarding-solve-edu/README.md
git commit -m "docs(prototype): record the re-measured responsive guardrail

Enlarging every goal card, widening the grid from 520px to 900px and moving
the age grid out of inline styles can all invalidate the Cycle 3 measurement,
so it is re-measured rather than assumed: 0 overflowing elements and 0 targets
below 24x24 at 320/360/414/768/1440 on both pages.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 7: Reconcile the PRD

**Files:**
- Modify: `design/onboarding-solve-edu/PRD.md` — §2, Slice 6 (`:762`), §9 Slice 5 (`:940`), §9 Slice 6 (`:957`), §11, §13, §15, Appendix A.3

**Interfaces:**
- Consumes: the built behaviour from Tasks 1–6.
- Produces: nothing.

**Why the PRD moves at all:** the prototype is built *from* the PRD, and Slice 6 currently hard-lists six goals for every learner. Leaving it would make the prototype contradict its own decision doc, which the Principal Designer Mode T gate checks for.

- [ ] **Step 1: Add the assumption to §2**

After the existing `### Where this PRD departs from its own cited research` block and before `### 2.1 Findings coverage`, add:

```markdown
### The teen goal taxonomy is an assumption, not a finding

**Claim:** a 13-to-17 learner is better served by three broad categories (English &
Communication, Math & Science, Life skills) than by the six work-oriented goals offered to
adults.

**No study in `Informed by:` proposes these three categories.** They are a Program
Operations and curriculum input, recorded here as an assumption with a validation path, in
the same register as layout F7 and F9 (adopted as labelled hypotheses) and the Slice 5
gender step.

**A same-shape precedent exists and is deliberately not promoted to evidence.** The
2026-07-28 study observed Khan Academy conditioning its content set on a declared grade
band (*Grade 9* returning *Pre-algebra, Algebra 1, High school geometry*), and describes its
Primary / Secondary / University options as "age bands under a different label". That
sighting sits in the study's gaps-and-caveats section, not in a finding, so it supports the
*mechanism* of conditioning on a band and says nothing about *these three categories*.
§2.1 gains no row: no new finding is adopted.

**Validation path:** the `goal_selected` distribution read by age band, which Slice 6's
analytics criterion now carries. If 13-to-17 selection concentrates on one category or
spreads evenly with no signal, the taxonomy is wrong and this is what shows it. Owner:
Program Operations, jointly with whoever owns the §15 goal-to-course decision.
```

- [ ] **Step 2: Rewrite Slice 6 (`:762`)**

Replace the six-item list under `### Slice 6 — Organic learning-goal selection` with:

```markdown
Organic learners choose exactly one configured goal. **The offered set depends on the age
band declared in Slice 5**; the screen title is the same for every band.

Learners aged 13 to 17:

- English & Communication
- Math & Science
- Life skills

Learners aged 18 and over:

- Data and analysis
- Customer service
- Project management
- Digital marketing
- Communication
- Language skills

Both sets are configuration-backed and localized, and their identifiers share one namespace.
A selection enables Continue and becomes the initial recommendation signal. The three teen
categories are an assumption, not a finding — see §2. Program learners skip this slice
because their validated assignment already supplies routing context.
```

- [ ] **Step 3: Add the missing Slice 5 criterion (`:940`)**

In `## 9. Acceptance Criteria per Slice`, under `### Slice 5`, add immediately after the *"Selecting Adult reveals 25–34…"* criterion:

```markdown
- [ ] Each age option is a real control that is reachable and operable by keyboard, exposes its selected state via `aria-pressed` or radio semantics, shows a visible focus ring, and sits in a group with a programmatic label. *(The gender step below carries this criterion and the age step did not, which is how the age options shipped as non-semantic `div`s while the gender options beside them shipped as buttons.)*
```

- [ ] **Step 4: Amend the Slice 6 criteria (`:957`)**

Replace the first criterion:

```markdown
- [ ] The goal cards render from configuration for the learner's declared age band: three for 13–17, six for 18 and over, in the approved order for that set.
```

Replace the back-navigation criterion (`:963`):

```markdown
- [ ] Back navigation preserves the current goal **within the same option set**.
```

Add two criteria:

```markdown
- [ ] Changing the age band to one that resolves a different option set clears any stored goal and returns Continue to its disabled state with its stated requirement.
- [ ] Goal identifiers are unique across every band's set, so a stored identifier is unambiguous without also reading the band.
```

Extend the analytics criterion (`:966`):

```markdown
- [ ] `goal_selected` includes the stable goal identifier, the locale, and **the age band that determined the option set**, and no profile PII. The band is what makes §2's validation path readable.
```

Leave the *"Each configured goal resolves to exactly one first course"* criterion (`:962`) unchanged in wording. It now governs nine goals.

- [ ] **Step 5: Touch §11, §13, §15, and Appendix A.3**

- **§11** — on the goal-screen row, note that the presented option set is conditioned on the declared age band.
- **§13** — no schema change. Add a note under the `OnboardingSession` block: *"`goal_id` values are unique across every band's option set, so the band is not needed to disambiguate a stored goal. The band that produced it remains recoverable from `age_band` on the same record."*
- **§15** — extend the open goal-to-course decision to name the three teen goals.
- **Appendix A.3** — on the **Goal** row, change the captured value to *"Organic personalization choice, from the set configured for the declared age band"*. The durable representation stays *"Stable goal identifier"*.

- [ ] **Step 6: Check §2.1 was not disturbed**

```bash
grep -c '^| F[0-9]' design/onboarding-solve-edu/PRD.md
```

Expected: `25`. The coverage table must still account for 25 findings with the `20 Adopted · 4 Deferred · 1 Contradicted` summary intact. No new finding was adopted, so any change here is a mistake.

- [ ] **Step 7: Commit**

```bash
git add design/onboarding-solve-edu/PRD.md
git commit -m "docs(prd): make Slice 6 age-conditional and close the Slice 5 a11y gap

Slice 6 offers three goals to 13-to-17 learners and six to everyone else,
with the option set named as configuration and the identifiers required
unique across bands. Its criteria narrow back-navigation preservation to
within one option set, add the clear-on-band-change rule, and add the age
band to goal_selected, which is what makes the assumption falsifiable.

Section 2 records the three teen categories as an owned assumption with a
validation path, not a finding. The Khan Academy band-conditioned sighting
supports the mechanism only and sits in its study's gaps section, so 2.1
gains no row and its 25-finding accounting is unchanged.

Slice 5 gains the criterion it never had: age options must be keyboard-
operable, expose a pressed state and sit in a labelled group. The gender step
below it carried that criterion and the age step did not, which is how seven
non-semantic divs shipped next to three buttons.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Verification checklist

Run after Task 7, before considering the work done.

- [ ] `cd design/onboarding-solve-edu/src && powershell -NoProfile -File src-prototype.test.ps1` reports `PASSED`, 17 groups, 116 checks.
- [ ] `cd design/onboarding-solve-edu && powershell -NoProfile -File prototype-web.test.ps1` reports `PASSED` — the frozen reference build is untouched.
- [ ] `git status` shows no modification to `design/onboarding-solve-edu/data.js`, `main.js`, `prototype-web.html`, `standalone.html`, or `prototype-web.test.ps1`.
- [ ] `git diff --stat 872f143..HEAD -- design/onboarding-solve-edu/src/home.html design/onboarding-solve-edu/src/home.js` is empty. `872f143` is the spec commit, the last commit before this plan's work — comparing against `main` would wrongly show the earlier Cycle 2 and 3 changes to those files.
- [ ] Teen path walked end to end in a browser: three goal cards, correct course on the home.
- [ ] Adult path walked end to end: six goal cards, unchanged behaviour.
- [ ] `Language skills` still produces the unmapped empty state on the home.
- [ ] Age gate fully operable with the keyboard alone.
- [ ] Responsive measurement re-run and recorded at five widths on both pages.
