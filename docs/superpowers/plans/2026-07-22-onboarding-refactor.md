# Onboarding Prototype Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor a single-file prototype into a modular, responsive vanilla web app by separating HTML, CSS, and JS, fixing undefined variables, and applying modern CSS grid/flexbox for responsiveness.

**Architecture:** Vanilla HTML/CSS/JS with separated concerns (`index.html`, `styles.css`, `main.js`, `data.js`). Mobile-first responsive design. Centralized state management in JS.

**Tech Stack:** HTML5, CSS3, Vanilla ES6 JavaScript

## Global Constraints

- No frontend frameworks (React, Vue, etc.) or build tools (Webpack, Vite) are allowed. Must remain vanilla.
- Use `rem` for typography.
- Max-width of `1200px` on main layout containers.
- No inline styles or inline `onclick` handlers in HTML.

---

### Task 1: Data Separation

**Files:**
- Create: `design/onboarding-solve-edu/data.js`
- Modify: `design/onboarding-solve-edu/prototype-web.html`

**Interfaces:**
- Consumes: None
- Produces: `allCountries` array, `goalOptions` array on the global `window` object.

- [ ] **Step 1: Create data file with countries and goals**

```javascript
// design/onboarding-solve-edu/data.js
const allCountries = [
  { name: "Afghanistan", code: "af" },
  { name: "United States of America", code: "us" },
  { name: "Indonesia", code: "id" }
  // (Include the full list from the original prototype-web.html)
];

const goalOptions = [
  { id: 'english', title: 'English for Workplace' },
  { id: 'math', title: 'Practical Math Skills' },
  { id: 'workplace', title: 'Workplace Communication' },
  { id: 'digital_literacy', title: 'Digital Skills for the Modern World' },
  { id: 'entrepreneurship', title: 'Start Your Own Business' }
];

window.allCountries = allCountries;
window.goalOptions = goalOptions;
```

- [ ] **Step 2: Link script in HTML and remove old array**

```html
<!-- In prototype-web.html, before the main script block -->
<script src="data.js"></script>
```
*(Remove the inline `const allCountries = [...]` from `prototype-web.html`)*

- [ ] **Step 3: Run test to verify it passes**

Run: Open `design/onboarding-solve-edu/prototype-web.html` in browser.
Expected: Open console and type `allCountries`. It should output the array without errors.

- [ ] **Step 4: Commit**

```bash
git add design/onboarding-solve-edu/data.js design/onboarding-solve-edu/prototype-web.html
git commit -m "refactor: extract data to data.js"
```

---

### Task 2: CSS Extraction & Responsive Foundation

**Files:**
- Create: `design/onboarding-solve-edu/styles.css`
- Modify: `design/onboarding-solve-edu/prototype-web.html`

**Interfaces:**
- Consumes: None
- Produces: `styles.css` containing all styles.

- [ ] **Step 1: Extract inline CSS to file**

Copy all contents inside `<style>...</style>` from `prototype-web.html` into `design/onboarding-solve-edu/styles.css`.

- [ ] **Step 2: Implement responsive constraints in styles.css**

```css
/* Add to styles.css */
.main-container {
  max-width: 1200px;
  margin: 0 auto;
  width: 100%;
}

@media (min-width: 768px) {
  .card-flex {
    flex-direction: row;
  }
}
```

- [ ] **Step 3: Update HTML to use external stylesheet**

Remove the `<style>` block from `prototype-web.html` and add:
```html
<link rel="stylesheet" href="styles.css">
```

- [ ] **Step 4: Run test to verify it passes**

Run: Open `prototype-web.html` in browser.
Expected: Styles apply correctly, and content centers with a max-width on large screens.

- [ ] **Step 5: Commit**

```bash
git add design/onboarding-solve-edu/styles.css design/onboarding-solve-edu/prototype-web.html
git commit -m "refactor: extract css to styles.css and add max-width"
```

---

### Task 3: JavaScript Logic & State Management

**Files:**
- Create: `design/onboarding-solve-edu/main.js`
- Modify: `design/onboarding-solve-edu/prototype-web.html`

**Interfaces:**
- Consumes: `window.allCountries`, `window.goalOptions`
- Produces: Core interaction logic handling state.

- [ ] **Step 1: Define centralized state in main.js**

```javascript
// design/onboarding-solve-edu/main.js
const appState = {
  entryPath: 'organic',
  selectedGoal: null,
  selectedAgeCategory: null,
  selectedCountry: null
};

// Navigation functions
function goTo(cardId) {
  document.querySelectorAll('.card').forEach(c => c.classList.remove('active'));
  document.getElementById(cardId).classList.add('active');
}

function startOrganic() {
  appState.entryPath = 'organic';
  goTo('onboarding'); // Assuming 'onboarding' is the next card ID
}

function startProgram() {
  appState.entryPath = 'program';
  goTo('onboarding'); 
}

function openSignInModal() {
  const modal = document.getElementById('signin-modal'); // Assuming this exists
  if(modal) modal.classList.add('show');
}
```

- [ ] **Step 2: Remove inline onclicks and add event listeners**

In `prototype-web.html`, remove `onclick="startOrganic()"` and add IDs (e.g., `id="btn-start-organic"`).
In `main.js`:
```javascript
document.addEventListener('DOMContentLoaded', () => {
  const btnOrganic = document.getElementById('btn-start-organic');
  if (btnOrganic) {
    btnOrganic.addEventListener('click', startOrganic);
  }
  // Add others here...
});
```

- [ ] **Step 3: Move remaining JS from HTML to main.js**

Move the remaining script block (dropdown logic, country rendering) from `prototype-web.html` to `main.js`. Ensure it references `appState.selectedCountry` instead of global `selectedCountry`. Link `main.js` in HTML:
```html
<script src="main.js"></script>
```

- [ ] **Step 4: Run test to verify it passes**

Run: Open `prototype-web.html` in browser. Click "Get started".
Expected: No "undefined function" errors in console. View transitions to onboarding.

- [ ] **Step 5: Commit**

```bash
git add design/onboarding-solve-edu/main.js design/onboarding-solve-edu/prototype-web.html
git commit -m "refactor: extract JS and implement missing navigation logic"
```
