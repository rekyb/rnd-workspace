# Searchable Country Combobox Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Repair the country screen with an accessible dropdown that opens only after typing and supports mouse and keyboard selection.

**Architecture:** Keep the prototype self-contained and reuse `allCountries` and `selectedCountry`. Replace the broken plain input with a combobox/listbox pair, reconcile the existing country functions around that markup, and extend the existing PowerShell regression test with structural behavior assertions.

**Tech Stack:** HTML, CSS, vanilla JavaScript, PowerShell, local headless Chrome/CDP for runtime verification

## Global Constraints

- Preserve the existing `allCountries` dataset, onboarding navigation, selected-country state, and card-based learning-goal selector.
- Keep the dropdown closed while the input is empty; open it only after one or more typed characters.
- Filter case-insensitively by a substring match anywhere in the country name.
- Support click, Arrow Up/Down, Enter, Escape, and outside-click closure.
- Reset selection and disable Continue whenever a selected value is edited or cleared.
- Use combobox/listbox/option roles and keep `aria-expanded`, `aria-selected`, and `aria-activedescendant` accurate.
- Remove the undefined `validateCountry()` call and avoid unrelated prototype restructuring.

---

### Task 1: Implement and verify the searchable country combobox

**Files:**
- Modify: `design/onboarding-solve-edu/prototype-web.html:915-925`
- Modify: `design/onboarding-solve-edu/prototype-web.html:1380-1435`
- Modify: `design/onboarding-solve-edu/prototype-web.html:1699-1781`
- Modify: `design/onboarding-solve-edu/prototype-web.test.ps1`

**Interfaces:**
- Consumes: `allCountries: Array<{ name: string, code: string }>` and `selectedCountry: { name: string, code: string } | null`.
- Produces: `handleCountryInput(): void`, `handleCountryKeydown(event: KeyboardEvent): void`, `renderCountryList(filterText: string): void`, `selectCountry(country: { name: string, code: string }): void`, and `closeCountryDropdown(): void`.

- [ ] **Step 1: Extend the regression test with failing country-combobox assertions**

Append before the final success output in `prototype-web.test.ps1`:

```powershell
Assert-Matches 'id="country_search"[^>]*role="combobox"[^>]*aria-autocomplete="list"[^>]*aria-controls="country_list"[^>]*aria-expanded="false"' 'Country input must expose collapsed combobox semantics.'
Assert-Matches 'id="country_dropdown"[^>]*class="[^\"]*select-hide[^\"]*"[^>]*role="listbox"' 'Country results must start hidden and expose listbox semantics.'
Assert-Matches 'function\s+handleCountryInput\s*\(' 'Country input handler is required.'
Assert-Matches 'if\s*\(!query\)' 'Empty country queries must keep results closed.'
Assert-Matches 'function\s+handleCountryKeydown\s*\(event\)' 'Country keyboard handler is required.'
Assert-Matches "event\.key\s*===\s*'ArrowDown'" 'Country results must support Arrow Down.'
Assert-Matches "event\.key\s*===\s*'ArrowUp'" 'Country results must support Arrow Up.'
Assert-Matches "event\.key\s*===\s*'Enter'" 'Country results must support Enter selection.'
Assert-Matches "event\.key\s*===\s*'Escape'" 'Country results must support Escape closure.'
Assert-Matches "setAttribute\('aria-activedescendant'" 'Keyboard-active country must be exposed.'
Assert-Matches 'function\s+selectCountry\s*\(country\)' 'Country selection helper is required.'
Assert-Matches 'selectedCountry\s*=\s*null[\s\S]*?global-continue-btn[\s\S]*?disabled\s*=\s*true' 'Editing country text must clear selection and disable Continue.'
Assert-Matches 'No countries found' 'Empty country results require feedback.'
Assert-NotMatches 'validateCountry\s*\(' 'Broken validateCountry handler must be removed.'
```

- [ ] **Step 2: Run the regression test and confirm the expected RED state**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File design/onboarding-solve-edu/prototype-web.test.ps1
```

Expected: FAIL with `Country input must expose collapsed combobox semantics.`

- [ ] **Step 3: Replace the broken country field with combobox/listbox markup**

Use this country control inside `country_gate` and remove the stray extra closing `</div>` immediately after the card:

```html
<div id="country_combobox" class="custom-select" style="width: 100%; text-align: left; position: relative;">
  <div class="input-field" style="display: flex; align-items: center; gap: 12px; margin-bottom: 0; background: var(--surf);">
    <img id="country_select_flag" class="flag-icon" src="" alt="" style="display: none; width: 24px; height: 18px;">
    <input type="text" id="country_search" role="combobox" aria-autocomplete="list" aria-controls="country_list" aria-expanded="false" autocomplete="off" placeholder="Type your country here" oninput="handleCountryInput()" onkeydown="handleCountryKeydown(event)" style="flex: 1; min-width: 0; border: 0; outline: 0; background: transparent; font: inherit; color: var(--ink);">
    <span class="material-symbols-rounded" aria-hidden="true" style="color: var(--sub);">expand_more</span>
  </div>
  <div id="country_dropdown" class="select-items select-hide" role="listbox" style="width: 100%; max-height: 300px; top: 100%; left: 0; position: absolute; overflow-y: auto; z-index: 100; margin-top: 8px; padding: 0;">
    <div id="country_list"></div>
  </div>
</div>
```

- [ ] **Step 4: Implement filtering, rendering, and selection reset**

Replace the obsolete country rendering/filtering functions with:

```javascript
let activeCountryIndex = -1;
let filteredCountries = [];

function handleCountryInput() {
  const input = document.getElementById('country_search');
  const query = input.value.trim();
  selectedCountry = null;
  document.getElementById('country_select_flag').style.display = 'none';
  document.getElementById('global-continue-btn').disabled = true;
  activeCountryIndex = -1;

  if (!query) {
    closeCountryDropdown();
    document.getElementById('country_list').innerHTML = '';
    return;
  }

  renderCountryList(query);
  const dropdown = document.getElementById('country_dropdown');
  dropdown.classList.remove('select-hide');
  input.setAttribute('aria-expanded', 'true');
}

function renderCountryList(filterText) {
  const list = document.getElementById('country_list');
  const query = filterText.toLowerCase();
  filteredCountries = allCountries.filter(country =>
    country.name.toLowerCase().includes(query)
  );
  list.innerHTML = '';

  if (filteredCountries.length === 0) {
    list.innerHTML = '<div style="padding: 12px 16px; color: var(--sub); text-align: center;">No countries found</div>';
    return;
  }

  filteredCountries.forEach((country, index) => {
    const option = document.createElement('div');
    option.id = `country-option-${index}`;
    option.setAttribute('role', 'option');
    option.setAttribute('aria-selected', (index === activeCountryIndex).toString());
    option.style.cssText = 'padding:12px 16px;display:flex;align-items:center;gap:12px;cursor:pointer;';
    if (index === activeCountryIndex) option.style.background = 'var(--purple-bg)';
    option.innerHTML = `<img class="flag-icon" src="https://flagcdn.com/w20/${country.code}.png" alt=""><span>${country.name}</span>`;
    option.addEventListener('mousedown', event => {
      event.preventDefault();
      selectCountry(country);
    });
    list.appendChild(option);
  });
}

function selectCountry(country) {
  selectedCountry = country;
  const input = document.getElementById('country_search');
  const flag = document.getElementById('country_select_flag');
  input.value = country.name;
  flag.src = `https://flagcdn.com/w20/${country.code}.png`;
  flag.alt = '';
  flag.style.display = 'block';
  document.getElementById('global-continue-btn').disabled = false;
  closeCountryDropdown();
}

function closeCountryDropdown() {
  const input = document.getElementById('country_search');
  document.getElementById('country_dropdown').classList.add('select-hide');
  input.setAttribute('aria-expanded', 'false');
  input.removeAttribute('aria-activedescendant');
  activeCountryIndex = -1;
}
```

- [ ] **Step 5: Implement keyboard control and outside-click closure**

Add:

```javascript
function handleCountryKeydown(event) {
  if (document.getElementById('country_dropdown').classList.contains('select-hide')) return;

  if (event.key === 'ArrowDown') {
    event.preventDefault();
    activeCountryIndex = Math.min(activeCountryIndex + 1, filteredCountries.length - 1);
  } else if (event.key === 'ArrowUp') {
    event.preventDefault();
    activeCountryIndex = Math.max(activeCountryIndex - 1, 0);
  } else if (event.key === 'Enter' && activeCountryIndex >= 0) {
    event.preventDefault();
    selectCountry(filteredCountries[activeCountryIndex]);
    return;
  } else if (event.key === 'Escape') {
    closeCountryDropdown();
    return;
  } else {
    return;
  }

  renderCountryList(document.getElementById('country_search').value.trim());
  const optionId = `country-option-${activeCountryIndex}`;
  document.getElementById('country_search').setAttribute('aria-activedescendant', optionId);
  document.getElementById(optionId)?.scrollIntoView({ block: 'nearest' });
}
```

Reconcile the existing document click listener to call `closeCountryDropdown()` only when the click target is outside `#country_combobox`. Remove calls to the obsolete toggle/filter display implementation, and do not render the full country list when entering the country screen.

- [ ] **Step 6: Run both structural regression checks**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File design/onboarding-solve-edu/prototype-web.test.ps1
```

Expected: `PASS: learning-goal card grid structure and behavior` followed by a country-combobox PASS line added to the test output.

- [ ] **Step 7: Run a browser-level interaction probe**

Use local headless Chrome/CDP against the exact working file and verify:

```text
Country screen opens with no results visible.
Typing "nesia" opens results containing Indonesia.
Arrow Down establishes aria-activedescendant.
Enter selects Indonesia, closes results, and enables Continue.
Editing the selected value clears selectedCountry and disables Continue.
Typing a non-match displays "No countries found".
Escape and outside click close results.
Selecting Indonesia and pressing Continue opens age_gate.
The learning-goal screen still shows the six-card selector.
```

- [ ] **Step 8: Commit only the owned implementation files**

```powershell
git add -- design/onboarding-solve-edu/prototype-web.html design/onboarding-solve-edu/prototype-web.test.ps1
git commit -m "fix: restore searchable country dropdown"
```
