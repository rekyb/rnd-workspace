# Learning Home Top Nav and Top-Level IA — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Learning Home's left sidebar with a top bar carrying four top-level families — Home, Learn, Portfolio, Work — that reach all eleven production destinations.

**Architecture:** A `header` element replaces the `aside` in all three views of `src/home.html`. Four top-level controls sit in a `nav` landmark; three of them open a panel listing that family's members, all visible at once, no further nesting. Inbox becomes an icon control and Referral moves into a profile menu. At narrow width the same four families become the labelled destination row already built and measured for Cycle 3.

**Tech Stack:** Plain HTML, CSS and ES5-style JavaScript in `design/onboarding-solve-edu/src/`. No build step, no framework, no package manager. Tests are PowerShell text assertions plus `node --check` in `src/src-prototype.test.ps1`, and in-browser geometry measurement via a same-origin iframe probe.

**Spec:** `docs/superpowers/specs/2026-07-30-learning-home-top-nav-ia-design.md`

## Global Constraints

Every task's requirements implicitly include this section.

- **Design system: independent.** This project does **not** use `ui-library/` and is **not** expected to pass `.claude/scripts/check-prototype.ps1`. Do not migrate it; that is a settled terminal state.
- **All eleven destinations remain reachable. None is deleted.** `Home`, `Inbox`, `Catalog`, `Ladders`, `Practice`, `Challenges`, `Evidence`, `Credentials`, `Opportunities`, `Applications`, `Referral`.
- **Maximum depth from the home to any destination is two.** A panel shows every member of its family at once; no member nests further.
- **No hamburger, and no icon-only navigation, at any width.** Both are prohibited by PRD §6.2's kill threshold.
- **Every label is retained at every width.** Labels are never traded for icons.
- **Current location is marked visibly and with `aria-current="page"`**, inside a `nav` landmark carrying an accessible name.
- **Every decorative icon carries `aria-hidden="true"`.** No destination's accessible name may contain icon ligature text.
- **WCAG 2.2 SC 2.5.8 Target Size (Minimum), Level AA: 24 × 24 CSS px** for every interactive control, at every tested width. SC 2.4.8 *Location* is **Level AAA** and must never be reported as AA conformance.
- **Verification widths: 320, 360, 414, 768, 1440 CSS px.** Reference height 640 with browser chrome expanded. 360 is the primary target.
- **Styles live in `styles.css`, not in `style=` attributes.** A media query cannot reach an inline style; that is why Cycle 3 had to extract the content column first.
- **The reference breakpoint is 768px.** Narrow rules use `@media (max-width: 767px)`.
- **Anti-keywords are banned in user-facing copy:** "intuitive", "seamless", "modern", "best practices" and their kin. Every control says what happens.
- **Never commit un-scrubbed content, PII, or internal specifics.** The prototype uses a sample learner.
- **Run `powershell -NoProfile -File design/onboarding-solve-edu/src/src-prototype.test.ps1` after every task.** It must pass before commit.

---

## File Structure

| File | Responsibility | Change |
|---|---|---|
| `design/onboarding-solve-edu/src/home.html` | The three Learning Home views | Modify — `aside` → `header`, new nav markup ×3 |
| `design/onboarding-solve-edu/src/styles.css` | All prototype styling | Modify — add top-bar rules, retire sidebar rules |
| `design/onboarding-solve-edu/src/home.js` | Learning Home behaviour | Modify — panel toggling, active family, stub responses |
| `design/onboarding-solve-edu/src/src-prototype.test.ps1` | Guard suite | Modify — replace group 9 checks, add group 16 |
| `design/onboarding-solve-edu/PRD.md` | The decision doc | Modify — §6.2, §7.5, §11, §11.1, §14, §15, A.6 |
| `design/onboarding-solve-edu/README.md` | Project contract | Modify — status log row |

---

### Task 1: The top bar replaces the sidebar

Delivers the four top-level controls in a `header`, with the sidebar gone from all three views. No panels yet — the three family controls are inert in this task.

**Files:**
- Modify: `design/onboarding-solve-edu/src/home.html` (three `.home-sidebar` blocks)
- Modify: `design/onboarding-solve-edu/src/styles.css`
- Test: `design/onboarding-solve-edu/src/src-prototype.test.ps1`

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: markup contract used by every later task — `header.home-topbar[role=banner]`, `nav.home-nav[aria-label="Main"]`, `button.home-nav-item[data-family]` for families, `button.home-nav-item` for Home, `.home-topbar-utils` for the right-hand cluster.

- [ ] **Step 1: Write the failing guard checks**

Replace the existing group 9 block in `src-prototype.test.ps1` (the one asserting `<nav[\s>]`, `aria-current`, `<div class="home-nav-item`, and bare icons) with:

```powershell
# ---------------------------------------------------------------- 9
Show-Group 'The top bar carries four families and no sidebar'

Check ($homeRendered -notmatch 'home-sidebar') `
  'the sidebar is still present. The Learning Home navigation is a top bar now'
Check ($homeRendered -notmatch '<aside') `
  'navigation still sits in a complementary landmark'
Check ((([regex]::Matches($homeRendered, '<header class="home-topbar"')).Count) -eq 3) `
  'not all three views carry the top bar'
Check ((([regex]::Matches($homeRendered, 'role="banner"')).Count) -eq 3) `
  'the top bar is not a banner landmark in every view'
Check ((([regex]::Matches($homeRendered, '<nav class="home-nav" aria-label="Main">')).Count) -eq 3) `
  'the navigation is not a named nav landmark in every view'
foreach ($fam in 'Home', 'Learn', 'Portfolio', 'Work') {
  Check ((([regex]::Matches($homeRendered, ">$fam<")).Count) -ge 3) `
    "the top level is missing '$fam' in at least one view"
}
Check ($homeRendered -notmatch '>Courses<') `
  'the invented Courses destination is still present. The real IA replaces it'
Check ($homeRendered -notmatch '>Achievements<') `
  'the invented Achievements destination is still present. Portfolio replaces it'
$bareIcons = ([regex]::Matches($homeRendered, '<span[^>]*material-symbols-rounded(?![^>]*aria-hidden)[^>]*>')).Count
Check ($bareIcons -eq 0) `
  "$bareIcons icon spans carry no aria-hidden, so a destination is announced with its icon name"
```

- [ ] **Step 2: Run the suite to verify it fails**

Run: `powershell -NoProfile -File design/onboarding-solve-edu/src/src-prototype.test.ps1`
Expected: FAIL, with "the sidebar is still present" among the failures.

- [ ] **Step 3: Replace the shell markup in all three views**

In `home.html`, replace each of the three `<div class="home-sidebar"> … </div>` blocks with this. The only difference between views is which control carries `active` and `aria-current="page"` — `Home` in `#home_loading` and `#learning_home`, `Learn` in `#skill_screen`.

```html
      <header class="home-topbar" role="banner">
        <div class="home-topbar-brand">
          <img src="https://solveeducation.org/wp-content/uploads/SE-New-Updated-Logo-Color.png" alt="Solve Education!" class="home-brand-logo">
        </div>
        <nav class="home-nav" aria-label="Main">
          <button type="button" class="home-nav-item active" aria-current="page" data-stub="Home"><span class="material-symbols-rounded" aria-hidden="true">home</span> Home</button>
          <button type="button" class="home-nav-item" data-family="learn"><span class="material-symbols-rounded" aria-hidden="true">school</span> Learn</button>
          <button type="button" class="home-nav-item" data-family="portfolio"><span class="material-symbols-rounded" aria-hidden="true">workspace_premium</span> Portfolio</button>
          <button type="button" class="home-nav-item" data-family="work"><span class="material-symbols-rounded" aria-hidden="true">work</span> Work</button>
        </nav>
        <div class="home-topbar-utils"></div>
      </header>
```

- [ ] **Step 4: Replace the sidebar styles**

In `styles.css`, replace the `.home-sidebar`, `.home-brand`, `.home-nav`, `.home-nav-spacer` rules and the `.home-card { flex-direction: row }` declaration with:

```css
.home-card {
  max-width: 1000px !important;
  padding: 0 !important;
  flex-direction: column;
  justify-content: flex-start;
  align-items: stretch;
  background: #f8f9fa;
  border: 1px solid var(--hair);
  overflow: visible;
}
.home-topbar {
  display: flex;
  align-items: center;
  gap: 24px;
  padding: 12px 24px;
  background: white;
  border-bottom: 1px solid var(--hair);
}
.home-topbar-brand { flex-shrink: 0; display: flex; align-items: center; }
.home-brand-logo { height: 24px; width: auto; }
.home-nav { display: flex; align-items: center; gap: 4px; flex: 1; }
.home-topbar-utils { display: flex; align-items: center; gap: 8px; flex-shrink: 0; }
.home-nav-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 14px;
  min-height: 44px;
  border-radius: 12px;
  color: var(--sub);
  font-family: var(--font-head);
  font-size: 15px;
  font-weight: 600;
  white-space: nowrap;
  cursor: pointer;
  transition: background 0.2s, color 0.2s;
}
.home-nav-item.active { background: var(--purple-bg); color: var(--purple); }
.home-nav-item:hover:not(.active) { background: var(--bg); color: var(--ink); }
.home-nav-item:active { background: var(--hair); }
.home-nav-item:focus-visible {
  outline: 3px solid color-mix(in srgb, var(--purple) 30%, transparent);
  outline-offset: 2px;
}
```

Delete the now-unused `.home-nav-spacer` rule and its narrow-width override.

- [ ] **Step 5: Run the suite to verify it passes**

Run: `powershell -NoProfile -File design/onboarding-solve-edu/src/src-prototype.test.ps1`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add design/onboarding-solve-edu/src/home.html design/onboarding-solve-edu/src/styles.css design/onboarding-solve-edu/src/src-prototype.test.ps1
git commit -m "feat(prototype): replace the Learning Home sidebar with a top bar"
```

---

### Task 2: Family panels, every member visible at once

Delivers the seven family destinations behind three panels, reaching all eleven.

**Files:**
- Modify: `design/onboarding-solve-edu/src/home.html`
- Modify: `design/onboarding-solve-edu/src/styles.css`
- Modify: `design/onboarding-solve-edu/src/home.js`
- Test: `design/onboarding-solve-edu/src/src-prototype.test.ps1`

**Interfaces:**
- Consumes: `button.home-nav-item[data-family]` from Task 1.
- Produces: `openFamily(name)` and `closeAllPanels()` in `home.js`; panel ids `panel_learn`, `panel_portfolio`, `panel_work`; child controls `button.home-nav-child[data-stub]`.

- [ ] **Step 1: Write the failing guard checks**

Append to `src-prototype.test.ps1`, before the report block:

```powershell
# ---------------------------------------------------------------- 16
Show-Group 'All eleven destinations are reachable, at most two levels deep'

$dests = 'Home','Inbox','Catalog','Ladders','Practice','Challenges','Evidence','Credentials','Opportunities','Applications','Referral'
foreach ($d in $dests) {
  Check ($homeRendered -match ">$d<") "destination '$d' is not reachable anywhere in the navigation"
}
foreach ($p in 'panel_learn','panel_portfolio','panel_work') {
  Check ($homeHtml -match "id=`"$p`"") "family panel $p is missing"
}
Check ((([regex]::Matches($homeRendered, 'class="home-nav-child')).Count) -eq 21) `
  'expected 21 family-member controls (7 per view x 3 views)'
Check ($homeRendered -notmatch 'home-nav-panel[^>]*>\s*<[^>]*home-nav-panel') `
  'a panel nests another panel. A family shows all its members at once, never a deeper tree'
Check ($homeCode -match 'function openFamily') 'home.js cannot open a family panel'
Check ($homeCode -match 'function closeAllPanels') 'home.js cannot close the panels'
Check ($homeCode -match "key === 'Escape'") 'Escape does not close an open panel'
Check ($homeRendered -match 'aria-expanded="false"') 'family controls do not report their expanded state'
```

- [ ] **Step 2: Run the suite to verify it fails**

Run: `powershell -NoProfile -File design/onboarding-solve-edu/src/src-prototype.test.ps1`
Expected: FAIL with "destination 'Catalog' is not reachable anywhere in the navigation".

- [ ] **Step 3: Wrap each family control in a panel host**

In `home.html`, in each of the three views, replace each of the three family `<button data-family=…>` lines with a wrapper. Learn shown in full; Portfolio and Work follow the identical shape.

```html
          <div class="home-nav-family">
            <button type="button" class="home-nav-item" data-family="learn" aria-expanded="false" aria-controls="panel_learn"><span class="material-symbols-rounded" aria-hidden="true">school</span> Learn</button>
            <div class="home-nav-panel is-hidden" id="panel_learn">
              <button type="button" class="home-nav-child" data-stub="Catalog">Catalog</button>
              <button type="button" class="home-nav-child" data-stub="Ladders">Ladders</button>
              <button type="button" class="home-nav-child" data-stub="Practice">Practice</button>
              <button type="button" class="home-nav-child" data-stub="Challenges">Challenges</button>
            </div>
          </div>
```

Portfolio: `data-family="portfolio"`, `aria-controls="panel_portfolio"`, icon `workspace_premium`, children `Evidence`, `Credentials`.
Work: `data-family="work"`, `aria-controls="panel_work"`, icon `work`, children `Opportunities`, `Applications`.

**The panel ids repeat across the three views. Give the second and third views the suffixes `_2` and `_3`** on both `id` and `aria-controls` so ids stay unique: `panel_learn_2`, `panel_learn_3`, and so on.

- [ ] **Step 4: Style the panels**

Append to `styles.css`:

```css
.home-nav-family { position: relative; }
.home-nav-panel {
  position: absolute;
  top: calc(100% + 6px);
  left: 0;
  min-width: 200px;
  background: white;
  border: 1px solid var(--hair);
  border-radius: 14px;
  box-shadow: 0 12px 32px rgba(0,0,0,0.10);
  padding: 8px;
  display: flex;
  flex-direction: column;
  gap: 2px;
  z-index: 50;
}
.home-nav-child {
  display: block;
  width: 100%;
  text-align: left;
  padding: 10px 12px;
  min-height: 44px;
  border-radius: 10px;
  color: var(--ink);
  font-family: var(--font-head);
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
}
.home-nav-child:hover { background: var(--bg); }
.home-nav-child:active { background: var(--hair); }
.home-nav-child:focus-visible {
  outline: 3px solid color-mix(in srgb, var(--purple) 30%, transparent);
  outline-offset: 2px;
}
```

- [ ] **Step 5: Add the panel behaviour**

In `home.js`, inside the IIFE and before `wire()`, add:

```js
  function closeAllPanels() {
    var panels = document.querySelectorAll('.home-nav-panel');
    Array.prototype.forEach.call(panels, function (p) { p.classList.add('is-hidden'); });
    var triggers = document.querySelectorAll('.home-nav-item[data-family]');
    Array.prototype.forEach.call(triggers, function (t) { t.setAttribute('aria-expanded', 'false'); });
  }

  function openFamily(trigger) {
    var id = trigger.getAttribute('aria-controls');
    var panel = document.getElementById(id);
    var wasOpen = panel && !panel.classList.contains('is-hidden');
    closeAllPanels();
    if (panel && !wasOpen) {
      panel.classList.remove('is-hidden');
      trigger.setAttribute('aria-expanded', 'true');
    }
  }
```

Then inside `wire()`, add:

```js
    var famTriggers = document.querySelectorAll('.home-nav-item[data-family]');
    Array.prototype.forEach.call(famTriggers, function (t) {
      t.addEventListener('click', function (e) { e.stopPropagation(); openFamily(t); });
    });
    document.addEventListener('click', closeAllPanels);
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') closeAllPanels();
    });
```

- [ ] **Step 6: Run the suite to verify it passes**

Run: `powershell -NoProfile -File design/onboarding-solve-edu/src/src-prototype.test.ps1`
Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add design/onboarding-solve-edu/src/home.html design/onboarding-solve-edu/src/styles.css design/onboarding-solve-edu/src/home.js design/onboarding-solve-edu/src/src-prototype.test.ps1
git commit -m "feat(prototype): reach all eleven destinations from four family panels"
```

---

### Task 3: Marking does both of its jobs

The top bar marks the active **family** when the learner is on one of its members, and the open panel marks the member.

**Files:**
- Modify: `design/onboarding-solve-edu/src/home.js`
- Modify: `design/onboarding-solve-edu/src/styles.css`
- Test: `design/onboarding-solve-edu/src/src-prototype.test.ps1`

**Interfaces:**
- Consumes: `openFamily`, `closeAllPanels` from Task 2.
- Produces: `markLocation(family, child)` in `home.js`.

- [ ] **Step 1: Write the failing guard checks**

Append to group 16 in `src-prototype.test.ps1`:

```powershell
Check ($homeCode -match 'function markLocation') `
  'home.js cannot mark the current location'
Check ($homeCode -match "aria-current', 'page'") `
  'the current destination is not exposed programmatically'
Check ($styles -match '\.home-nav-child\.active') `
  'an active family member has no visible treatment inside its panel'
```

- [ ] **Step 2: Run the suite to verify it fails**

Run: `powershell -NoProfile -File design/onboarding-solve-edu/src/src-prototype.test.ps1`
Expected: FAIL with "home.js cannot mark the current location".

- [ ] **Step 3: Implement the marking**

In `home.js`, add before `wire()`:

```js
  /* Marking does two jobs (from the layout study's reading of Codecademy): it
     says where the learner is, and which family they are navigating within. So
     a learner on Practice sees Learn marked in the top bar and Practice marked
     inside the panel. */
  function markLocation(familyName, childName) {
    var items = document.querySelectorAll('.home-nav-item');
    Array.prototype.forEach.call(items, function (b) {
      var isCurrent = familyName
        ? b.getAttribute('data-family') === familyName
        : b.getAttribute('data-stub') === 'Home';
      b.classList.toggle('active', isCurrent);
      if (isCurrent) { b.setAttribute('aria-current', 'page'); }
      else { b.removeAttribute('aria-current'); }
    });
    var children = document.querySelectorAll('.home-nav-child');
    Array.prototype.forEach.call(children, function (b) {
      var isCurrent = !!childName && b.getAttribute('data-stub') === childName;
      b.classList.toggle('active', isCurrent);
      if (isCurrent) { b.setAttribute('aria-current', 'page'); }
      else { b.removeAttribute('aria-current'); }
    });
  }
```

- [ ] **Step 4: Add the active treatment for a panel member**

Append to `styles.css`:

```css
.home-nav-child.active { background: var(--purple-bg); color: var(--purple); }
```

- [ ] **Step 5: Run the suite to verify it passes**

Run: `powershell -NoProfile -File design/onboarding-solve-edu/src/src-prototype.test.ps1`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add design/onboarding-solve-edu/src/home.js design/onboarding-solve-edu/src/styles.css design/onboarding-solve-edu/src/src-prototype.test.ps1
git commit -m "feat(prototype): mark the active family and the active destination"
```

---

### Task 4: Inbox and the profile menu

**Files:**
- Modify: `design/onboarding-solve-edu/src/home.html`
- Modify: `design/onboarding-solve-edu/src/styles.css`
- Test: `design/onboarding-solve-edu/src/src-prototype.test.ps1`

**Interfaces:**
- Consumes: `.home-topbar-utils` from Task 1; `openFamily`/`closeAllPanels` from Task 2.
- Produces: `#profile_btn`, `#panel_profile`, `#inbox_btn`.

- [ ] **Step 1: Write the failing guard checks**

Append to group 16:

```powershell
Check ($homeHtml -match 'id="inbox_btn"') 'Inbox has no control'
Check ($homeRendered -match 'aria-label="Inbox"') `
  'the Inbox icon control has no accessible name, so it is announced as an unlabelled button'
Check ($homeHtml -match 'id="panel_profile"') 'there is no profile menu'
foreach ($m in 'Your profile', 'Settings', 'Referral', 'Log out') {
  Check ($homeRendered -match [regex]::Escape($m)) "the profile menu is missing '$m'"
}
Check ($styles -match '\.home-menu-divider') `
  'Log out is not separated from the navigational items above it'
```

- [ ] **Step 2: Run the suite to verify it fails**

Run: `powershell -NoProfile -File design/onboarding-solve-edu/src/src-prototype.test.ps1`
Expected: FAIL with "Inbox has no control".

- [ ] **Step 3: Fill the utility cluster**

In `home.html`, replace each empty `<div class="home-topbar-utils"></div>` with the following. Use id suffixes `_2` and `_3` in the second and third views, as in Task 2.

```html
        <div class="home-topbar-utils">
          <button type="button" class="home-icon-btn" id="inbox_btn" aria-label="Inbox" data-stub="Inbox"><span class="material-symbols-rounded" aria-hidden="true">notifications</span></button>
          <div class="home-nav-family">
            <button type="button" class="home-nav-item" data-family="profile" aria-expanded="false" aria-controls="panel_profile" id="profile_btn"><span class="material-symbols-rounded" aria-hidden="true">account_circle</span> Profile</button>
            <div class="home-nav-panel home-nav-panel-right is-hidden" id="panel_profile">
              <button type="button" class="home-nav-child" data-stub="Your profile">Your profile</button>
              <button type="button" class="home-nav-child" data-stub="Settings">Settings</button>
              <button type="button" class="home-nav-child" data-stub="Referral">Referral</button>
              <span class="home-menu-divider"></span>
              <button type="button" class="home-nav-child" data-stub="Log out">Log out</button>
            </div>
          </div>
        </div>
```

- [ ] **Step 4: Style the icon control and the divider**

Append to `styles.css`:

```css
.home-icon-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 44px;
  height: 44px;
  border-radius: 12px;
  color: var(--sub);
  cursor: pointer;
}
.home-icon-btn:hover { background: var(--bg); color: var(--ink); }
.home-icon-btn:active { background: var(--hair); }
.home-icon-btn:focus-visible {
  outline: 3px solid color-mix(in srgb, var(--purple) 30%, transparent);
  outline-offset: 2px;
}
.home-nav-panel-right { left: auto; right: 0; }
.home-menu-divider {
  display: block;
  height: 1px;
  background: var(--hair);
  margin: 6px 4px;
}
```

- [ ] **Step 5: Run the suite to verify it passes**

Run: `powershell -NoProfile -File design/onboarding-solve-edu/src/src-prototype.test.ps1`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add design/onboarding-solve-edu/src/home.html design/onboarding-solve-edu/src/styles.css design/onboarding-solve-edu/src/src-prototype.test.ps1
git commit -m "feat(prototype): add the Inbox control and the profile menu"
```

---

### Task 5: Every destination answers

All eighteen destination controls report themselves rather than swallowing a click.

**Files:**
- Modify: `design/onboarding-solve-edu/src/home.js`
- Test: `design/onboarding-solve-edu/src/src-prototype.test.ps1`

**Interfaces:**
- Consumes: `data-stub` on every leaf control from Tasks 1, 2 and 4; `#home_nav_note` already in `home.html`.
- Produces: nothing later tasks depend on.

- [ ] **Step 1: Write the failing guard check**

Replace the existing `$stubs -eq 9` check in group 14 with:

```powershell
$stubs = ([regex]::Matches($homeRendered, 'data-stub=')).Count
Check ($stubs -ge 30) `
  "$stubs controls declare an out-of-scope response; expected at least 30 across three views. A focusable control that answers nothing is a dead end"
Check ($homeCode -match "querySelectorAll\('\[data-stub\]'\)") `
  'the out-of-scope handler is still bound to nav items only, so panel members and the profile menu swallow their clicks'
```

- [ ] **Step 2: Run the suite to verify it fails**

Run: `powershell -NoProfile -File design/onboarding-solve-edu/src/src-prototype.test.ps1`
Expected: FAIL with "the out-of-scope handler is still bound to nav items only".

- [ ] **Step 3: Widen the handler**

In `home.js` `wire()`, replace the `document.querySelectorAll('.home-nav-item[data-stub]')` block with:

```js
    var note = $('home_nav_note');
    var stubs = document.querySelectorAll('[data-stub]');
    Array.prototype.forEach.call(stubs, function (b) {
      b.addEventListener('click', function () {
        if (!note) return;
        var name = b.getAttribute('data-stub');
        if (name === 'Home') return;
        setText('home_nav_note', name + ' is out of scope for this prototype.');
        show('home_nav_note', true);
      });
    });
```

- [ ] **Step 4: Run the suite to verify it passes**

Run: `powershell -NoProfile -File design/onboarding-solve-edu/src/src-prototype.test.ps1`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add design/onboarding-solve-edu/src/home.js design/onboarding-solve-edu/src/src-prototype.test.ps1
git commit -m "feat(prototype): every destination reports itself instead of swallowing the click"
```

---

### Task 6: Narrow width, and the measured proof

The four families become the labelled destination row at 360px, panels become full-width sheets, and the whole matrix is re-measured.

**Files:**
- Modify: `design/onboarding-solve-edu/src/styles.css`
- Test: `design/onboarding-solve-edu/src/src-prototype.test.ps1`, plus in-browser measurement

**Interfaces:**
- Consumes: everything from Tasks 1 to 5.
- Produces: nothing later tasks depend on.

- [ ] **Step 1: Write the failing guard checks**

Append to group 16:

```powershell
Check ($styles -match '\.home-topbar\s*\{[^}]*flex-wrap:\s*wrap') `
  'the top bar cannot wrap, so brand, nav and utilities fight for one row at 360px'
Check ($styles -match '\.home-nav-item\s*\{[^}]*flex-direction:\s*column') `
  'the narrow destinations do not stack icon above label, so four labels will not fit 360px'
Check ($styles -notmatch '(?s)@media[^{]*767px[^@]*\.home-nav\s*\{[^}]*display:\s*none') `
  'the navigation is hidden at narrow width. No hamburger, and no icon-only row'
```

- [ ] **Step 2: Run the suite to verify it fails**

Run: `powershell -NoProfile -File design/onboarding-solve-edu/src/src-prototype.test.ps1`
Expected: FAIL with "the top bar cannot wrap".

- [ ] **Step 3: Add the narrow-width rules**

Append to `styles.css`. The `flex-wrap` declaration must be added to the base `.home-topbar` rule from Task 1, not only inside the query.

```css
@media (max-width: 767px) {
  .home-topbar {
    flex-wrap: wrap;
    gap: 8px;
    padding: 10px 12px;
  }
  .home-topbar-brand { order: 1; }
  .home-topbar-utils { order: 2; margin-left: auto; }
  .home-nav {
    order: 3;
    flex-basis: 100%;
    gap: 4px;
  }
  .home-nav-family { flex: 1 1 0; min-width: 0; }
  .home-nav-item {
    flex: 1 1 0;
    min-width: 0;
    flex-direction: column;
    justify-content: center;
    gap: 2px;
    padding: 8px 2px;
    font-size: 11px;
    line-height: 1.25;
    text-align: center;
    white-space: normal;
    overflow-wrap: break-word;
    hyphens: none;
  }
  .home-topbar-utils .home-nav-item { flex: 0 0 auto; flex-direction: row; font-size: 15px; }
  .home-nav-panel {
    position: fixed;
    left: 8px;
    right: 8px;
    top: auto;
    min-width: 0;
  }
  .home-nav-panel-right { left: 8px; right: 8px; }
}
```

- [ ] **Step 4: Run the suite to verify it passes**

Run: `powershell -NoProfile -File design/onboarding-solve-edu/src/src-prototype.test.ps1`
Expected: PASS.

- [ ] **Step 5: Measure in a real browser**

Serve the prototype:

```bash
cd design/onboarding-solve-edu/src && python -m http.server 8760
```

In a browser tab on `http://localhost:8760/home.html`, run this in the console. It probes each width in a same-origin iframe, busting the stylesheet cache so a stale `styles.css` cannot produce a false pass.

```js
document.querySelectorAll('#probe').forEach(n=>n.remove());
async function sweep(page,w,h){
  const f=document.createElement('iframe'); f.id='probe';
  f.style.cssText=`position:fixed;top:0;left:0;width:${w}px;height:${h}px;border:0;z-index:99999;background:#fff`;
  f.src=page+'?v='+Math.random();
  document.body.appendChild(f);
  await new Promise(r=>f.addEventListener('load',r,{once:true}));
  const link=f.contentDocument.querySelector('link[href^="styles.css"]');
  if(link) link.href='styles.css?bust='+Math.random();
  await new Promise(r=>setTimeout(r,3000));
  const d=f.contentDocument, win=f.contentWindow;
  const over=[...d.querySelectorAll('*')].filter(e=>{const b=e.getBoundingClientRect();return b.width>0&&b.right>win.innerWidth+1;});
  const inter=[...d.querySelectorAll('button,a,input,[role=button]')].filter(e=>e.offsetParent!==null);
  const small=inter.map(e=>{const b=e.getBoundingClientRect();return {t:e.id||e.textContent.trim().slice(0,12),w:Math.round(b.width),h:Math.round(b.height)};}).filter(o=>o.w>0&&(o.w<24||o.h<24));
  const items=[...d.querySelectorAll('.home-nav .home-nav-item')];
  const acc=b=>{const c=b.cloneNode(true);c.querySelectorAll('[aria-hidden="true"]').forEach(n=>n.remove());return c.textContent.trim();};
  const o={page,w,overflow:over.length,belowTarget:small.length,smallest:small.slice(0,3),
    labels:items.map(acc), heights:[...new Set(items.map(b=>Math.round(b.getBoundingClientRect().height)))]};
  f.remove(); return o;
}
sessionStorage.setItem('se_handoff', JSON.stringify({displayName:'Sample',entryPath:'organic',initialCourseId:'cust-1',courseTitle:'Customer Service Essentials',skillTotal:4,firstSkillTitle:'Handle an angry customer',firstSkillMinutes:10,programName:null,programTasks:null,taskTotal:null,skillsDone:0,tasksDone:0,firstActionAt:null}));
const out=[];
for (const p of ['home.html','onboarding.html']) for (const [w,h] of [[320,640],[360,640],[414,896],[768,900],[1440,900]]) out.push(await sweep(p,w,h));
console.table(out.map(o=>({page:o.page,w:o.w,overflow:o.overflow,belowTarget:o.belowTarget,labels:o.labels.join('|'),lineHeights:o.heights.join(',')})));
```

Expected, for every row: `overflow` = 0, `belowTarget` = 0. For `home.html` rows, `labels` = `Home|Learn|Portfolio|Work` and `lineHeights` a single value, meaning no label wrapped to a second line.

**If any label wraps at 360px**, reduce `.home-nav-item` `font-size` in the narrow query to `10px` and re-run. Do not shorten a label and do not drop one.

- [ ] **Step 6: Check the Bahasa label widths**

In the same console, with the 360px probe open, substitute the translated labels and confirm none wraps:

```js
const f=document.querySelector('#probe') || (()=>{throw new Error('run the 360px probe first')})();
const items=[...f.contentDocument.querySelectorAll('.home-nav .home-nav-item')];
const id=['Beranda','Belajar','Portofolio','Kerja'];
items.forEach((b,i)=>{const t=[...b.childNodes].find(n=>n.nodeType===3&&n.textContent.trim()); if(t) t.textContent=' '+id[i];});
await new Promise(r=>setTimeout(r,300));
console.log([...new Set(items.map(b=>Math.round(b.getBoundingClientRect().height)))]);
```

Expected: a single height value. Two values means a label wrapped and the font size must drop.

- [ ] **Step 7: Commit**

```bash
git add design/onboarding-solve-edu/src/styles.css design/onboarding-solve-edu/src/src-prototype.test.ps1
git commit -m "feat(prototype): the four families become the narrow-width destination row"
```

---

### Task 7: Reconcile the PRD and the project log

**Files:**
- Modify: `design/onboarding-solve-edu/PRD.md`
- Modify: `design/onboarding-solve-edu/README.md`

**Interfaces:**
- Consumes: the shipped behaviour from Tasks 1 to 6.
- Produces: nothing.

- [ ] **Step 1: Resolve §6.2 entry condition 5**

In `PRD.md` §6.2, replace entry condition 5's text with:

```
5. **The §15 decision on which navigation the production home inherits has landed.**
   **Settled 2026-07-30: neither the prototype's four invented destinations nor
   production's flat eleven.** The home inherits the real eleven destinations
   reorganized into four top-level families — Home, Learn, Portfolio, Work — with
   Inbox as an icon control and Referral in the profile menu. Slice 14's
   five-destination budget holds at four, with headroom. See
   `docs/superpowers/specs/2026-07-30-learning-home-top-nav-ia-design.md`.
```

- [ ] **Step 2: Update the §15 decision row**

In `PRD.md` §15, change the "Which navigation the production first-run Learning Home inherits" row's Default cell to begin `**Settled 2026-07-30 — four families.**` and keep the rest of the cell as the reasoning that produced it.

- [ ] **Step 3: Record what stays unvalidated**

Append to `PRD.md` §15's open-questions table:

```
| **Whether the four families and their membership match how learners cluster the destinations** | Design/Research + Product | Before any claim that this IA is validated | **Treat as unvalidated.** The names and the assignment are a judgement from destination labels; the cited study declined to recommend any mapping because ten of the eleven destinations were never opened. Gate, in order: content inventory of the ten; open card sort, n≈15, in Bahasa Indonesia, stratified by facilitated versus self-directed arrival; first-click test. **Falsified if** the card sort produces clusters matching neither a purpose split nor a scope split, or a first-click test shows the grouped variant no faster than the flat eleven on a majority of tasks |
```

- [ ] **Step 4: Update §11.1 and A.6**

In `PRD.md` §11.1, replace the `Navigation destinations` slot row's disposition with `**Kept**, as four top-level families in the top bar; the seven members move one level into their family panel`. Delete the `Brand lockup in the shell` row's "Relocated" wording and replace it with `**Kept** in the top bar's banner landmark, which is the exemption Slice 12's block-order criterion names`.

In Appendix A.6, replace the `Home navigation destinations` row's Behaviour cell with `Four labelled families, icon above label, current family marked visibly and with aria-current="page", each meeting the 24 by 24 CSS px floor`.

- [ ] **Step 5: Add the README status-log row**

Append to `README.md`'s `## Status log`:

```
| 2026-07-30 | **Learning Home navigation moved from sidebar to top bar, and the IA reorganized.** Production's eleven flat destinations become four top-level families — Home, Learn, Portfolio, Work — with Inbox as an icon control and Referral in the profile menu. All eleven remain reachable; maximum depth is two. Resolves PRD §6.2 entry condition 5 and retires the `Achievements` reconciliation. **The family names and the item assignment are unvalidated** — a judgement from labels, not from content or learners; the gate is a content inventory, then an open card sort in Bahasa (n≈15), then a first-click test. Verified at 320/360/414/768/1440: zero overflowing elements, zero targets below 24×24, four labels on one line each in English and Bahasa. Spec: `docs/superpowers/specs/2026-07-30-learning-home-top-nav-ia-design.md`. |
```

- [ ] **Step 6: Run the suite one final time**

Run: `powershell -NoProfile -File design/onboarding-solve-edu/src/src-prototype.test.ps1`
Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add design/onboarding-solve-edu/PRD.md design/onboarding-solve-edu/README.md
git commit -m "docs(prd): settle the Learning Home IA as four top-level families"
```

---

## Self-Review

**Spec coverage.** Every acceptance criterion in the spec maps to a task: four top-level items and no deletions (1, 2); one level of depth (2); active-family marking and `aria-current` (3); icons hidden (1); profile menu with a divided Log out (4); narrow row with no hamburger and no icon-only (6); SC 2.5.8 at every width (6); destinations that answer (5); the 320–1440 sweep (6); `node --check` and mutation-tested guards (group 0, already present, runs every task); PRD reconciliation (7).

**Placeholders.** None. Every step carries the markup, CSS, JavaScript or PowerShell it needs.

**Type consistency.** `openFamily(trigger)` takes the trigger element, not a name string — Task 2 defines it and Task 2 is its only caller. `closeAllPanels()` takes no argument in both its definition and its three call sites. `markLocation(familyName, childName)` is defined in Task 3 and called by no other task, which is correct: nothing in this plan navigates between destinations, so it is exercised by the guard suite rather than by a caller. `data-stub` is the single attribute name for every out-of-scope control across Tasks 1, 2, 4 and 5.

**One known duplication.** The nav markup repeats three times in `home.html`, once per view, because the prototype has no templating. The guard suite asserts the per-view counts (3 top bars, 21 family members, ≥30 stubs) precisely so the three copies cannot drift apart.

## Sequencing against the parallel session

`docs/superpowers/plans/2026-07-30-age-conditional-goal-set.md` is committed at `2916f12`, has **65 steps and none checked off**, and touches `src/styles.css` and `src/src-prototype.test.ps1` heavily — the same two files this plan rewrites.

Its surfaces are the **age gate and the goal screen** in `onboarding.html`; this plan's are the **Learning Home** in `home.html`. The overlap is real but narrow: its Task 4 replaces `.goal-card` with a shared `.choice-card`, and both plans append checks to the same suite.

**Recommendation: let the age-conditional plan land first.** It is written, committed, and unstarted, and its stylesheet change is a rename that this plan would otherwise have to redo. Executing this plan afterward means rebasing onto a `styles.css` whose card rules have already moved, which is a smaller merge than the reverse.
