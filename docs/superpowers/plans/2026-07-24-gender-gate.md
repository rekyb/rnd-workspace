# Gender Gate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a gender-selection screen to the Solve Education! onboarding prototype, placed immediately after the age gate, for program/funder demographic reporting.

**Architecture:** The prototype is a static multi-screen single-page flow. Every screen is a `.card` div in `prototype-web.html`; selection state lives on the `appState` object in `main.js`; a shared footer Continue button is enabled per-screen by `updateHeaders()` and routed by `handleGlobalContinue()`. The gender gate follows this existing pattern exactly — no new architecture. The only new primitive is a `.gender-card` CSS class that lets `.option-card` styling sit on a real `<button>` element (for free keyboard support), mirroring how `.goal-card` already does it.

**Tech Stack:** Plain HTML / CSS / vanilla JS (no framework, no build step for the modular sources). Tests are PowerShell regex assertions in `prototype-web.test.ps1`. `standalone.html` is a generated single-file build produced by `build-standalone.ps1`.

## Global Constraints

- **Options are exactly three:** `Female` → `'female'`, `Male` → `'male'`, `Prefer not to say` → `'prefer_not_to_say'`. No non-binary option, no free-text "Other".
- **No icons on the gender cards.** Gendered iconography risks stereotyping; cards are text-only.
- **Required gate:** footer Continue stays disabled until one option is selected. "Prefer not to say" is a valid selection, so this never forces disclosure.
- **Title copy:** `How do you identify?` — Subtitle copy: `This helps us understand our program's reach. Prefer not to answer? That's okay.`
- **Screen id is `gender_gate`**; option ids are `gender-btn-female`, `gender-btn-male`, `gender-btn-prefer`; the group wrapper id is `gender_options`.
- **`standalone.html` MUST be rebuilt** (`.\build-standalone.ps1`) before running the test suite in every task — the suite asserts the standalone build contains the current `styles.css`, `data.js`, and `main.js`. Skipping the rebuild produces a spurious failure unrelated to your change.
- **Do NOT `git add standalone.html`.** It is an ~12 MB generated artifact and is currently untracked; keep it that way so the repo stays light.
- **Commits require explicit user go-ahead** per the repo's `CLAUDE.md` ("Commit or push only when the user asks"). If the user has not given it, stop after the passing test step and ask rather than committing.
- **Git identity for this repo:** name `Claude Code`, email `rekybongso@gmail.com`.
- All work is in `C:\research-workspace\design\onboarding-solve-edu\`.

---

## File Structure

| File | Responsibility | Change |
|---|---|---|
| `design/onboarding-solve-edu/prototype-web.html` | Screen markup | Add the `#gender_gate` card after `#age_gate` (currently ends line 368) |
| `design/onboarding-solve-edu/styles.css` | Presentation | Add `.gender-grid` + `.gender-card` rules (button resets, opt-out variant, focus ring, narrow-screen collapse) |
| `design/onboarding-solve-edu/main.js` | State, selection, routing, progress | Add `selectedGender` state, `selectGender()`, `continueFromGender()`; re-point `continueFromAge()`; extend `updateHeaders()` + `handleGlobalContinue()`; rebalance both progress maps |
| `design/onboarding-solve-edu/prototype-web.test.ps1` | Verification | Add assertion blocks per task |
| `design/onboarding-solve-edu/standalone.html` | Generated build | Regenerated via `build-standalone.ps1`; never hand-edited, never committed |

---

## Task 1: Restore a green test baseline

The suite is currently **RED** for reasons unrelated to this feature: `data.js`, `main.js`, and `prototype-web.html` were edited earlier without regenerating `standalone.html`. Fix this first so later failures are meaningful.

**Files:**
- Modify (generated): `design/onboarding-solve-edu/standalone.html`

**Interfaces:**
- Consumes: nothing
- Produces: a green baseline for every later task

- [ ] **Step 1: Confirm the suite currently fails**

Run:
```powershell
Set-Location 'C:\research-workspace\design\onboarding-solve-edu'
.\prototype-web.test.ps1
```
Expected: throws `Standalone must contain the current data script`

- [ ] **Step 2: Rebuild the standalone snapshot**

Run:
```powershell
.\build-standalone.ps1
```
Expected: `Built C:\research-workspace\design\onboarding-solve-edu\standalone.html`

- [ ] **Step 3: Confirm the suite is green**

Run:
```powershell
.\prototype-web.test.ps1
```
Expected, all four lines:
```
PASS: standalone snapshot matches modular sources
PASS: learning-goal card grid structure and behavior
PASS: searchable country combobox structure and behavior
PASS: YouTube embed handles local-file referrer restrictions
```

- [ ] **Step 4: Commit** (only with user go-ahead — see Global Constraints)

```bash
git add design/onboarding-solve-edu/data.js design/onboarding-solve-edu/main.js design/onboarding-solve-edu/prototype-web.html design/onboarding-solve-edu/img/program-digital-heroes.png
git commit -m "fix: correct mojibake and restyle Digital Heroes program card

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01SQRbNbChxPxeiTJW6jKkb8"
```

---

## Task 2: Gender gate markup and styling

Produces the screen itself. It is not yet reachable (Task 4 wires routing) and not yet selectable (Task 3 wires behavior) — that is expected.

**Files:**
- Modify: `design/onboarding-solve-edu/prototype-web.html` (insert after line 368, before the `<!-- S5: Goal Intake (Organic) -->` comment)
- Modify: `design/onboarding-solve-edu/styles.css` (append after the `.goal-card` rules, before `/* Snackbar */` at line 609)
- Test: `design/onboarding-solve-edu/prototype-web.test.ps1`

**Interfaces:**
- Consumes: existing `.option-card`, `.card`, `.title`, `.subtitle` classes
- Produces: DOM ids `gender_gate`, `gender_gate_title`, `gender_options`, `gender-btn-female`, `gender-btn-male`, `gender-btn-prefer`; CSS classes `.gender-grid`, `.gender-card`, `.gender-card-optout`

- [ ] **Step 1: Write the failing tests**

Append to `prototype-web.test.ps1`, at the end of the file:

```powershell
Assert-Matches 'id="gender_gate"[^>]*class="card' 'Gender gate must exist as a card screen.'
Assert-Matches 'id="gender_options"[^>]*role="group"[^>]*aria-labelledby="gender_gate_title"' 'Gender options must expose a labelled choice group.'
Assert-Matches 'id="gender-btn-female"[^>]*aria-pressed="false"[^>]*>Female</button>' 'Female must be a text-only pressable button.'
Assert-Matches 'id="gender-btn-male"[^>]*aria-pressed="false"[^>]*>Male</button>' 'Male must be a text-only pressable button.'
Assert-Matches 'id="gender-btn-prefer"[^>]*aria-pressed="false"[^>]*>Prefer not to say</button>' 'Opt-out must be a text-only pressable button.'
Assert-Matches '\.gender-grid\s*\{[^}]*grid-template-columns:\s*repeat\(2,\s*minmax\(0,\s*1fr\)\)' 'Gender row one must use two columns.'
Assert-Matches '@media\s*\(max-width:\s*420px\)[\s\S]*?\.gender-grid\s*\{[^}]*grid-template-columns:\s*1fr' 'Narrow gender grid must collapse to one column.'
Assert-Matches '\.gender-card\s*\{[^}]*background:\s*var\(--surf\)' 'Gender buttons must reset the native button background.'
Assert-Matches '\.gender-card:focus-visible\s*\{[^}]*outline:' 'Gender buttons must show a visible focus ring.'

Write-Output 'PASS: gender gate structure and styling'
```

- [ ] **Step 2: Run tests to verify they fail**

Run:
```powershell
.\build-standalone.ps1; .\prototype-web.test.ps1
```
Expected: FAIL with `Gender gate must exist as a card screen.`

- [ ] **Step 3: Add the markup**

In `prototype-web.html`, insert between the age gate's closing `</div>` (line 368) and the `<!-- S5: Goal Intake (Organic) -->` comment:

```html
    <!-- S4b: Gender Gate -->
    <div id="gender_gate" class="card text-center">
      <div style="width: 100%; max-width: 900px !important; margin: 0 auto; display: flex; flex-direction: column; align-items: center;">
        <div style="width: 100%;">
          <h1 id="gender_gate_title" class="title" style="margin-top: 0;">How do you identify?</h1>
          <p class="subtitle">This helps us understand our program's reach. Prefer not to answer? That's okay.</p>
        </div>

        <div id="gender_options" role="group" aria-labelledby="gender_gate_title" style="width: 100%; margin-top: 40px;">
          <div class="gender-grid">
            <button type="button" class="option-card gender-card" id="gender-btn-female" aria-pressed="false">Female</button>
            <button type="button" class="option-card gender-card" id="gender-btn-male" aria-pressed="false">Male</button>
          </div>
          <button type="button" class="option-card gender-card gender-card-optout" id="gender-btn-prefer" aria-pressed="false">Prefer not to say</button>
        </div>
      </div>
    </div>
```

- [ ] **Step 4: Add the styles**

In `styles.css`, insert immediately before the `/* Snackbar */` comment (line 609):

```css
/* Gender gate */
.gender-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 24px;
  width: 100%;
}

.gender-card {
  background: var(--surf);
  color: var(--ink);
  font: 700 18px/1.4 var(--font-head);
  width: 100%;
}

.gender-card.gender-card-optout {
  margin-top: 24px;
  font: 400 16px/1.4 var(--font-head);
  color: var(--sub);
}

.gender-card:focus-visible {
  outline: 3px solid color-mix(in srgb, var(--purple) 30%, transparent);
  outline-offset: 2px;
}

@media (max-width: 420px) {
  .gender-grid { grid-template-columns: 1fr; }
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run:
```powershell
.\build-standalone.ps1; .\prototype-web.test.ps1
```
Expected: all five PASS lines, ending with `PASS: gender gate structure and styling`

- [ ] **Step 6: Commit** (only with user go-ahead)

```bash
git add design/onboarding-solve-edu/prototype-web.html design/onboarding-solve-edu/styles.css design/onboarding-solve-edu/prototype-web.test.ps1
git commit -m "feat: add gender gate screen markup and styles

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01SQRbNbChxPxeiTJW6jKkb8"
```

---

## Task 3: Gender selection state and behavior

Makes the three cards selectable, mutually exclusive, and Continue-enabling.

**Files:**
- Modify: `design/onboarding-solve-edu/main.js` (`appState` at lines 1-8; `DOMContentLoaded` block at lines 21-53; new functions after `continueFromAge()`)
- Test: `design/onboarding-solve-edu/prototype-web.test.ps1`

**Interfaces:**
- Consumes: `gender-btn-female` / `gender-btn-male` / `gender-btn-prefer` and `gender_options` from Task 2
- Produces: `appState.selectedGender` (`'female' | 'male' | 'prefer_not_to_say' | null`) and `selectGender(element, gender)` — used by Task 4's `continueFromGender()` and `updateHeaders()`

- [ ] **Step 1: Write the failing tests**

Append to `prototype-web.test.ps1`:

```powershell
Assert-Matches 'selectedGender:\s*null' 'Gender selection state must be initialised.'
Assert-Matches 'function\s+selectGender\s*\(element,\s*gender\)' 'Gender selection handler is required.'
Assert-Matches "function\s+selectGender[\s\S]*?setAttribute\('aria-pressed',\s*'false'\)" 'Selecting a gender must clear the previous selection.'
Assert-Matches "function\s+selectGender[\s\S]*?classList\.remove\('selected'\)" 'Selecting a gender must clear the previous selected style.'
Assert-Matches "function\s+selectGender[\s\S]*?setAttribute\('aria-pressed',\s*'true'\)" 'Selecting a gender must expose the pressed state.'
Assert-Matches "function\s+selectGender[\s\S]*?global-continue-btn'\)\.disabled\s*=\s*false" 'Selecting a gender must enable Continue.'
Assert-Matches "getElementById\('gender-btn-female'\)\?\.addEventListener\('click'" 'Female option must be wired.'
Assert-Matches "getElementById\('gender-btn-male'\)\?\.addEventListener\('click'" 'Male option must be wired.'
Assert-Matches "getElementById\('gender-btn-prefer'\)\?\.addEventListener\('click'" 'Opt-out option must be wired.'
Assert-Matches "selectGender\(this,\s*'prefer_not_to_say'\)" 'Opt-out must record prefer_not_to_say.'

Write-Output 'PASS: gender selection state and behavior'
```

- [ ] **Step 2: Run tests to verify they fail**

Run:
```powershell
.\build-standalone.ps1; .\prototype-web.test.ps1
```
Expected: FAIL with `Gender selection state must be initialised.`

- [ ] **Step 3: Add the state field**

In `main.js`, replace the `appState` object (lines 1-8) with:

```js
const appState = {
  entryPath: 'organic',
  selectedGoal: null,
  selectedAgeCategory: null,
  selectedGender: null,
  selectedCountry: null,
  historyStack: [],
  isNameValid: false
};
```

- [ ] **Step 4: Add the selection handler**

In `main.js`, insert immediately after the closing brace of `continueFromAge()` (currently line 345):

```js
    function selectGender(element, gender) {
      const peers = document.getElementById('gender_options').querySelectorAll('.gender-card');
      peers.forEach(p => {
        p.classList.remove('selected');
        p.setAttribute('aria-pressed', 'false');
      });
      appState.selectedGender = gender;
      element.classList.add('selected');
      element.setAttribute('aria-pressed', 'true');
      document.getElementById('global-continue-btn').disabled = false;
    }
```

- [ ] **Step 5: Wire the click handlers**

In `main.js`, inside the `DOMContentLoaded` callback, add these three lines immediately after the `age-btn-teen` listener (currently line 44):

```js
  document.getElementById('gender-btn-female')?.addEventListener('click', function() { selectGender(this, 'female'); });
  document.getElementById('gender-btn-male')?.addEventListener('click', function() { selectGender(this, 'male'); });
  document.getElementById('gender-btn-prefer')?.addEventListener('click', function() { selectGender(this, 'prefer_not_to_say'); });
```

- [ ] **Step 6: Run tests to verify they pass**

Run:
```powershell
.\build-standalone.ps1; .\prototype-web.test.ps1
```
Expected: all six PASS lines, ending with `PASS: gender selection state and behavior`

- [ ] **Step 7: Commit** (only with user go-ahead)

```bash
git add design/onboarding-solve-edu/main.js design/onboarding-solve-edu/prototype-web.test.ps1
git commit -m "feat: add gender selection state and handlers

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01SQRbNbChxPxeiTJW6jKkb8"
```

---

## Task 4: Route into and out of the gender gate

Makes the screen reachable: age → gender → goal (organic) or save-wall (program).

**Files:**
- Modify: `design/onboarding-solve-edu/main.js` — the `updateHeaders()`, `handleGlobalContinue()`, and `continueFromAge()` functions. **Locate them by name, not line number:** Task 3 inserted lines above them, so any line numbers from the spec have drifted. Each step below shows the exact existing snippet to replace.
- Test: `design/onboarding-solve-edu/prototype-web.test.ps1`

**Interfaces:**
- Consumes: `appState.selectedGender` from Task 3; existing `goTo(screenId)` and `populateProfileSummary()`
- Produces: `continueFromGender()` — terminal, nothing later depends on it

- [ ] **Step 1: Write the failing tests**

Append to `prototype-web.test.ps1`:

```powershell
Assert-Matches "function\s+continueFromAge\s*\(\)\s*\{\s*if\s*\(!appState\.selectedAgeCategory\)\s*return;\s*goTo\('gender_gate'\);\s*\}" 'Age gate must route only to the gender gate.'
Assert-Matches 'function\s+continueFromGender\s*\(\)' 'Gender continue handler is required.'
Assert-Matches "function\s+continueFromGender[\s\S]*?entryPath\s*===\s*'organic'[\s\S]*?goTo\('goal_intake'\)" 'Organic path must continue from gender to goals.'
Assert-Matches "function\s+continueFromGender[\s\S]*?goTo\('save_wall'\)[\s\S]*?populateProfileSummary\(\)" 'Program path must continue from gender to the save wall.'
Assert-Matches "activeCard\s*===\s*'gender_gate'[\s\S]*?continueFromGender\(\)" 'Continue must dispatch to the gender handler.'
Assert-Matches "'age_gate',\s*'gender_gate'" 'Gender gate must show the onboarding footer.'
Assert-Matches "screenId\s*===\s*'gender_gate'[\s\S]*?disabled\s*=\s*!appState\.selectedGender" 'Continue must stay disabled until a gender is chosen.'

Write-Output 'PASS: gender gate routing'
```

- [ ] **Step 2: Run tests to verify they fail**

Run:
```powershell
.\build-standalone.ps1; .\prototype-web.test.ps1
```
Expected: FAIL with `Age gate must route only to the gender gate.`

- [ ] **Step 3: Re-point the age gate and add the gender continue handler**

In `main.js`, replace the whole `continueFromAge()` function with:

```js
    function continueFromAge() {
      if (!appState.selectedAgeCategory) return;
      goTo('gender_gate');
    }

    function continueFromGender() {
      if (!appState.selectedGender) return;
      if (appState.entryPath === 'organic') {
        goTo('goal_intake');
      } else {
        goTo('save_wall');
        populateProfileSummary();
      }
    }
```

Note: `selectGender()` from Task 3 sits after this block; leave it where it is.

- [ ] **Step 4: Dispatch Continue to the new handler**

In `main.js` `handleGlobalContinue()`, replace:

```js
      } else if (activeCard === 'age_gate') {
        continueFromAge();
      } else if (activeCard === 'goal_intake') {
```

with:

```js
      } else if (activeCard === 'age_gate') {
        continueFromAge();
      } else if (activeCard === 'gender_gate') {
        continueFromGender();
      } else if (activeCard === 'goal_intake') {
```

- [ ] **Step 5: Show the footer and gate the Continue button**

In `main.js` `updateHeaders()`, replace this line:

```js
        if (['name_gate', 'country_gate', 'age_gate', 'goal_intake', 'assigned_content'].includes(screenId)) {
```

with:

```js
        if (['name_gate', 'country_gate', 'age_gate', 'gender_gate', 'goal_intake', 'assigned_content'].includes(screenId)) {
```

Then, in the same function, replace:

```js
          } else if (screenId === 'age_gate') {
            btn.disabled = !appState.selectedAgeCategory;
            btn.innerText = 'Continue';
          } else if (screenId === 'goal_intake') {
```

with:

```js
          } else if (screenId === 'age_gate') {
            btn.disabled = !appState.selectedAgeCategory;
            btn.innerText = 'Continue';
          } else if (screenId === 'gender_gate') {
            btn.disabled = !appState.selectedGender;
            btn.innerText = 'Continue';
          } else if (screenId === 'goal_intake') {
```

- [ ] **Step 6: Run tests to verify they pass**

Run:
```powershell
.\build-standalone.ps1; .\prototype-web.test.ps1
```
Expected: all seven PASS lines, ending with `PASS: gender gate routing`

- [ ] **Step 7: Manual smoke check**

Open `standalone.html` in a browser. Verify both paths:
- **Organic:** click `Get started` → name → country → age (pick any) → **gender gate appears** → Continue is disabled → pick an option → Continue enables → lands on the goal screen.
- **Program:** click `I have a program code` → enter `123456` → assigned content → name → country → age → **gender gate** → Continue → lands on the save wall.
- **Back:** from the gender gate, the header back arrow returns to the age gate with the age selection still highlighted.

- [ ] **Step 8: Commit** (only with user go-ahead)

```bash
git add design/onboarding-solve-edu/main.js design/onboarding-solve-edu/prototype-web.test.ps1
git commit -m "feat: route onboarding through the gender gate

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01SQRbNbChxPxeiTJW6jKkb8"
```

---

## Task 5: Rebalance the progress bar

Six bar screens per path, in equal increments, plus the two scoped cleanups from the spec.

**Files:**
- Modify: `design/onboarding-solve-edu/main.js` — the top-level `progressMap` object and the `programProgressMap` object nested inside `updateHeaders()`. **Locate them by name, not line number** (earlier tasks shifted the file).
- Test: `design/onboarding-solve-edu/prototype-web.test.ps1`

**Interfaces:**
- Consumes: the `gender_gate` screen id
- Produces: nothing consumed downstream

- [ ] **Step 1: Write the failing tests**

Append to `prototype-web.test.ps1`:

```powershell
Assert-Matches "'name_gate':\s*10" 'First gate must show a visible progress sliver.'
Assert-Matches "'country_gate':\s*28" 'Organic country step weighting.'
Assert-Matches "'age_gate':\s*46" 'Organic age step weighting.'
Assert-Matches "'gender_gate':\s*64" 'Organic gender step weighting.'
Assert-Matches "'goal_intake':\s*82" 'Organic goal step weighting.'
Assert-Matches "'assigned_content':\s*17" 'Program assigned-content weighting.'
Assert-Matches "'name_gate':\s*33" 'Program name weighting.'
Assert-Matches "'country_gate':\s*50" 'Program country weighting.'
Assert-Matches "'age_gate':\s*67" 'Program age weighting.'
Assert-Matches "'gender_gate':\s*83" 'Program gender weighting.'
Assert-NotMatches "'assigned_content':\s*75" 'Dead organic assigned-content weighting must be removed.'

Write-Output 'PASS: progress bar weighting'
```

- [ ] **Step 2: Run tests to verify they fail**

Run:
```powershell
.\build-standalone.ps1; .\prototype-web.test.ps1
```
Expected: FAIL with `First gate must show a visible progress sliver.`

- [ ] **Step 3: Rebalance the organic map**

In `main.js`, replace the whole top-level `progressMap` object with:

```js
const progressMap = {
  'landing': 0,
  'name_gate': 10,
  'country_gate': 28,
  'age_gate': 46,
  'gender_gate': 64,
  'goal_intake': 82,
  'save_wall': 100,
  'learning_home': 100
};
```

The `'assigned_content': 75` entry is deliberately dropped — it was dead code, since `assigned_content` only ever appears on the program path where `programProgressMap` overrides it.

- [ ] **Step 4: Rebalance the program map**

In `main.js`, inside `updateHeaders()`, replace the whole `programProgressMap` object with:

```js
            const programProgressMap = {
                'assigned_content': 17,
                'name_gate': 33,
                'country_gate': 50,
                'age_gate': 67,
                'gender_gate': 83,
                'save_wall': 100,
                'learning_home': 100
            };
```

- [ ] **Step 5: Run tests to verify they pass**

Run:
```powershell
.\build-standalone.ps1; .\prototype-web.test.ps1
```
Expected: all eight PASS lines, ending with `PASS: progress bar weighting`

- [ ] **Step 6: Manual smoke check**

Open `standalone.html` and walk the organic path. Confirm the bar is visibly non-empty on the name screen and advances in equal-looking steps through country → age → gender → goal → save wall, never jumping backwards.

- [ ] **Step 7: Commit** (only with user go-ahead)

```bash
git add design/onboarding-solve-edu/main.js design/onboarding-solve-edu/prototype-web.test.ps1
git commit -m "feat: rebalance onboarding progress bar for the gender gate

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01SQRbNbChxPxeiTJW6jKkb8"
```

---

## Acceptance criteria (from the spec)

Verify all seven after Task 5:

1. Gender gate appears after age on **both** paths.
2. Continue is disabled on arrival, enabled after any selection.
3. Selection shows the purple `.selected` state; picking another clears the previous (single-select).
4. Continue routes to `goal_intake` (organic) / `save_wall` + populated profile summary (program).
5. Back returns gender → age with the age selection preserved.
6. Progress advances monotonically in equal steps and is visibly non-empty on the first gate.
7. No gendered icons on the gender cards.
