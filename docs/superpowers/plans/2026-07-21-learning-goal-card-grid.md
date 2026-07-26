# Learning Goal Card Grid Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the learning-goal dropdown with an accessible six-card selector arranged as a responsive 3×2 grid.

**Architecture:** Keep the prototype self-contained in `prototype-web.html` and continue using the existing `goalOptions` array as the single source of truth. Add a small PowerShell regression test that reads the HTML and asserts its structure and behavior without requiring external packages.

**Tech Stack:** HTML, CSS, vanilla JavaScript, PowerShell

## Global Constraints

- Preserve all six existing goal IDs, titles, icons, and colors.
- Preserve `selectedGoal`, the global Continue-button behavior, and navigation to `save_wall`.
- Use three columns by default, two columns at widths up to 768 px, and one column at widths up to 420 px.
- Use native buttons with `aria-pressed` for keyboard and assistive-technology support.
- Remove the obsolete dropdown, search field, filtering behavior, and related event handlers.

---

### Task 1: Replace the dropdown with a responsive card selector

**Files:**
- Create: `design/onboarding-solve-edu/prototype-web.test.ps1`
- Modify: `design/onboarding-solve-edu/prototype-web.html:933`
- Modify: `design/onboarding-solve-edu/prototype-web.html:1278`

**Interfaces:**
- Consumes: `goalOptions: Array<{ id: string, title: string, icon: string, color: string }>` and `selectedGoal: string | null`.
- Produces: `renderGoalCards(): void` and `selectGoal(goalId: string): void`.

- [ ] **Step 1: Write the failing structural and behavior test**

Create `design/onboarding-solve-edu/prototype-web.test.ps1`:

```powershell
$ErrorActionPreference = 'Stop'
$prototypePath = Join-Path $PSScriptRoot 'prototype-web.html'
$html = Get-Content -LiteralPath $prototypePath -Raw

function Assert-Matches([string]$Pattern, [string]$Message) {
  if ($html -notmatch $Pattern) { throw $Message }
}

function Assert-NotMatches([string]$Pattern, [string]$Message) {
  if ($html -match $Pattern) { throw $Message }
}

Assert-Matches 'id="goal_grid"[^>]*role="group"' 'Goal grid must expose a labelled choice group.'
Assert-Matches '\.goal-grid\s*\{[^}]*grid-template-columns:\s*repeat\(3,\s*minmax\(0,\s*1fr\)\)' 'Desktop goal grid must use three columns.'
Assert-Matches '@media\s*\(max-width:\s*768px\)[\s\S]*?\.goal-grid\s*\{[^}]*grid-template-columns:\s*repeat\(2,\s*minmax\(0,\s*1fr\)\)' 'Tablet/mobile goal grid must use two columns.'
Assert-Matches '@media\s*\(max-width:\s*420px\)[\s\S]*?\.goal-grid\s*\{[^}]*grid-template-columns:\s*1fr' 'Narrow goal grid must use one column.'
Assert-Matches 'function\s+renderGoalCards\s*\(' 'Goal cards must render from goalOptions.'
Assert-Matches 'function\s+selectGoal\s*\(goalId\)' 'Goal selection handler is required.'
Assert-Matches "setAttribute\('aria-pressed',\s*isSelected\.toString\(\)\)" 'Cards must expose their selected state.'
Assert-Matches "document\.getElementById\('global-continue-btn'\)\.disabled\s*=\s*false" 'Selecting a goal must enable Continue.'
Assert-NotMatches 'id="goal_dropdown"|id="goal_search"|function\s+toggleGoalDropdown|function\s+filterGoals' 'Obsolete dropdown and search behavior must be removed.'

$goalIds = @('data', 'customer', 'project', 'marketing', 'communication', 'language')
foreach ($goalId in $goalIds) {
  Assert-Matches "id:\s*'$goalId'" "Missing goal option: $goalId"
}

Write-Output 'PASS: learning-goal card grid structure and behavior'
```

- [ ] **Step 2: Run the test and verify it fails for the missing grid**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File design/onboarding-solve-edu/prototype-web.test.ps1
```

Expected: FAIL with `Goal grid must expose a labelled choice group.`

- [ ] **Step 3: Add the responsive goal-card styles**

Add near the existing `.grid-options` and `.option-card` rules in `prototype-web.html`:

```css
.goal-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 16px;
  width: 100%;
  margin: 32px auto;
}

.goal-card {
  min-height: 144px;
  border: 2px solid var(--hair);
  border-radius: 16px;
  padding: 24px 16px;
  background: var(--surf);
  color: var(--ink);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 12px;
  text-align: center;
  transition: border-color 0.2s, background 0.2s, transform 0.1s;
}

.goal-card:hover,
.goal-card:focus-visible {
  border-color: var(--purple);
  background: var(--purple-bg);
}

.goal-card:focus-visible {
  outline: 3px solid color-mix(in srgb, var(--purple) 30%, transparent);
  outline-offset: 3px;
}

.goal-card.selected {
  border-color: var(--purple);
  background: var(--purple-bg);
}

.goal-card .material-symbols-rounded { font-size: 36px; }
.goal-card-title { font: 600 16px/1.4 var(--font-head); }

@media (max-width: 768px) {
  .goal-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
}

@media (max-width: 420px) {
  .goal-grid { grid-template-columns: 1fr; }
}
```

- [ ] **Step 4: Replace the dropdown markup with the empty card-grid mount point**

Replace the current `goal_custom_select` block with:

```html
<div id="goal_grid" class="goal-grid" role="group" aria-labelledby="goal_intake_title">
  <!-- Populated from goalOptions by JS -->
</div>
```

Add `id="goal_intake_title"` to the existing “What do you want to get better at?” heading.

- [ ] **Step 5: Replace dropdown rendering and filtering with card rendering and selection**

Remove `renderGoalList`, `toggleGoalDropdown`, `filterGoals`, and the `DOMContentLoaded` call to `renderGoalList`. Add:

```javascript
function renderGoalCards() {
  const grid = document.getElementById('goal_grid');
  if (!grid) return;

  grid.innerHTML = '';
  goalOptions.forEach(goal => {
    const card = document.createElement('button');
    const isSelected = selectedGoal === goal.id;
    card.type = 'button';
    card.className = `goal-card${isSelected ? ' selected' : ''}`;
    card.setAttribute('aria-pressed', isSelected.toString());
    card.innerHTML = `
      <span class="material-symbols-rounded" style="color: ${goal.color};">${goal.icon}</span>
      <span class="goal-card-title">${goal.title}</span>
    `;
    card.addEventListener('click', () => selectGoal(goal.id));
    grid.appendChild(card);
  });
}

function selectGoal(goalId) {
  selectedGoal = goalId;
  renderGoalCards();
  document.getElementById('global-continue-btn').disabled = false;
}

document.addEventListener('DOMContentLoaded', renderGoalCards);
```

- [ ] **Step 6: Run the regression test and verify it passes**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File design/onboarding-solve-edu/prototype-web.test.ps1
```

Expected: `PASS: learning-goal card grid structure and behavior`

- [ ] **Step 7: Verify the rendered interaction at desktop and narrow widths**

Open `design/onboarding-solve-edu/prototype-web.html`, navigate through organic onboarding to the goal screen, and verify:

```text
Desktop: six cards form 3 columns × 2 rows.
Width 768 px or less: cards form 2 columns.
Width 420 px or less: cards form 1 column.
Mouse click and keyboard activation select exactly one card.
Selected card is highlighted and exposes aria-pressed="true".
Continue begins disabled, enables after selection, and opens save_wall.
```

- [ ] **Step 8: Commit the implementation**

```powershell
git add -- design/onboarding-solve-edu/prototype-web.html design/onboarding-solve-edu/prototype-web.test.ps1
git commit -m "feat: replace goal dropdown with card grid"
```
