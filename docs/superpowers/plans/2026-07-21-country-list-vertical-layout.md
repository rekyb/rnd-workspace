# Country List Vertical Layout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make filtered country options stack vertically while keeping each flag and country name aligned horizontally.

**Architecture:** Add one narrowly scoped CSS rule for `#country_list` and protect it with the existing PowerShell regression suite. Verify the computed browser layout after typing a query with multiple matches.

**Tech Stack:** HTML, CSS, PowerShell, local headless Chrome/CDP

## Global Constraints

- Set `#country_list` to a vertical flex container.
- Keep each individual country option as a horizontal flex row.
- Preserve scrolling, filtering, keyboard behavior, ARIA state, selection, the arrow-free combobox, and the learning-goal card grid.
- Do not change the shared `.select-items div` rule or unrelated prototype behavior.

---

### Task 1: Stack country results vertically

**Files:**
- Modify: `design/onboarding-solve-edu/prototype-web.html`
- Modify: `design/onboarding-solve-edu/prototype-web.test.ps1`

**Interfaces:**
- Consumes: `#country_list` and the country option nodes created by `renderCountryList(filterText)`.
- Produces: a vertical option stack without changing JavaScript behavior.

- [ ] **Step 1: Write the failing layout assertion**

Add before the success output in `prototype-web.test.ps1`:

```powershell
Assert-Matches '#country_list\s*\{[^}]*display:\s*flex;[^}]*flex-direction:\s*column;' 'Country results must stack vertically.'
```

- [ ] **Step 2: Run the test and confirm RED**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File design/onboarding-solve-edu/prototype-web.test.ps1
```

Expected: FAIL with `Country results must stack vertically.`

- [ ] **Step 3: Add the minimal scoped CSS fix**

Add after the existing `.select-items div:hover` rule:

```css
#country_list {
  display: flex;
  flex-direction: column;
}
```

Do not modify `.select-items div`; its horizontal flex layout is still required within each option and by other dropdowns.

- [ ] **Step 4: Run the regression suite and confirm GREEN**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File design/onboarding-solve-edu/prototype-web.test.ps1
```

Expected: both learning-goal and searchable-country PASS lines, exit code 0.

- [ ] **Step 5: Verify computed layout in a browser**

Use headless Chrome/CDP, type a query that returns multiple countries, and assert:

```text
getComputedStyle(country_list).flexDirection === "column"
At least two role=option nodes exist.
Their left coordinates are equal within one pixel.
The second option's top coordinate is greater than the first option's top coordinate.
Each option still has display:flex and flex-direction:row.
```

- [ ] **Step 6: Commit only the owned files**

```powershell
git add -- design/onboarding-solve-edu/prototype-web.html design/onboarding-solve-edu/prototype-web.test.ps1
git commit -m "fix: stack country results vertically"
```
