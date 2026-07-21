# Dummy Home Section Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a dummy home section that replaces the onboarding UI with a dashboard layout containing a side nav, dynamic course assignment, and a program-specific task list.

**Architecture:** Modifies the existing `prototype-web.html` by transforming `#learning_home` into a dashboard grid layout (`.home-card`). Javascript handles dynamic rendering of user names, course mapping based on `selectedGoal`, and conditional program task lists.

**Tech Stack:** HTML, CSS, JavaScript (Vanilla)

## Global Constraints

- No external frameworks or libraries.
- Edits must be directly applied to C:\research-workspace\design\onboarding-solve-edu\prototype-web.html.

---

### Task 1: HTML & CSS Layout for Home Dashboard

**Files:**
- Modify: `C:\research-workspace\design\onboarding-solve-edu\prototype-web.html`

**Interfaces:**
- Produces: `.home-card`, `.home-sidebar`, `.home-main` structural CSS and DOM elements.

- [ ] **Step 1: Write a Python script to inject CSS for the Home Layout**

Create and run a python script to modify the CSS constraints and add new dashboard styles.

```python
import sys

filepath = r"C:\research-workspace\design\onboarding-solve-edu\prototype-web.html"
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update the max-width constraint to exclude home-card
content = content.replace(
    ".card:not(.landing-card) > * {",
    ".card:not(.landing-card):not(.home-card) > * {"
)

# 2. Add home dashboard CSS styles before </style>
home_css = """
    .home-card {
      max-width: 1000px !important;
      padding: 0 !important;
      display: flex;
      flex-direction: row;
      align-items: stretch;
      background: #f8f9fa;
      border: 1px solid var(--hair);
    }
    .home-sidebar {
      width: 240px;
      background: white;
      border-right: 1px solid var(--hair);
      padding: 32px 24px;
      display: flex;
      flex-direction: column;
      gap: 16px;
    }
    .home-nav-item {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 12px 16px;
      border-radius: 12px;
      color: var(--sub);
      font-weight: 600;
      cursor: pointer;
      transition: background 0.2s, color 0.2s;
    }
    .home-nav-item.active {
      background: var(--purple-bg);
      color: var(--purple);
    }
    .home-nav-item:hover:not(.active) {
      background: var(--bg);
      color: var(--ink);
    }
    .home-main {
      flex: 1;
      padding: 40px;
      display: flex;
      flex-direction: column;
      gap: 24px;
    }
"""

content = content.replace("  </style>", home_css + "\n  </style>")

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print("CSS injected successfully.")
```

- [ ] **Step 2: Write a Python script to restructure `#learning_home` HTML**

Run this script to inject the sidebar and wrap the existing `#learning_home` content.

```python
filepath = r"C:\research-workspace\design\onboarding-solve-edu\prototype-web.html"
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

old_learning_home = """    <div id="learning_home" class="card">
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 32px;">"""

new_learning_home = """    <div id="learning_home" class="card home-card">
      <aside class="home-sidebar">
        <div style="font-weight: 800; font-size: 20px; color: var(--purple); margin-bottom: 24px; display: flex; align-items: center; gap: 8px;">
            <img src="https://solveeducation.org/wp-content/uploads/SE-New-Updated-Logo-Color.png" alt="Logo" style="height: 24px;">
        </div>
        <div class="home-nav-item active"><span class="material-symbols-rounded">home</span> Home</div>
        <div class="home-nav-item"><span class="material-symbols-rounded">school</span> Courses</div>
        <div class="home-nav-item"><span class="material-symbols-rounded">emoji_events</span> Achievements</div>
        <div style="flex: 1;"></div>
        <div class="home-nav-item"><span class="material-symbols-rounded">settings</span> Settings</div>
      </aside>
      <div class="home-main">
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 32px;">"""

content = content.replace(old_learning_home, new_learning_home)

# Close the home-main div right before the learning_home closing div
content = content.replace(
    """      <button class="btn btn-primary" style="font-size: 18px;" onclick="goTo('learning_home')">Start Lesson</button>\n    </div>""",
    """      <button class="btn btn-primary" style="font-size: 18px;" onclick="goTo('learning_home')">Start Lesson</button>\n      </div>\n    </div>"""
)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print("HTML layout updated successfully.")
```

- [ ] **Step 3: Run the Python scripts and verify HTML changes**
Execute the scripts created in Step 1 and 2. Use `git diff` to verify the HTML layout has been injected properly.

- [ ] **Step 4: Commit**
```bash
git add C:/research-workspace/design/onboarding-solve-edu/prototype-web.html
git commit -m "feat(home): add dashboard layout with dummy side nav"
```

---

### Task 2: Hide Top Nav & Render Greeting

**Files:**
- Modify: `C:\research-workspace\design\onboarding-solve-edu\prototype-web.html`

**Interfaces:**
- Consumes: `#global-header`, `#onboarding-header`, `.home-main h1.title`
- Produces: `renderHomeSection()` JS function, logic inside `updateHeaders()`

- [ ] **Step 1: Write Python script to hide top nav**

```python
filepath = r"C:\research-workspace\design\onboarding-solve-edu\prototype-web.html"
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Modify updateHeaders to hide all headers on learning_home
old_update_headers = """      if (screenId === 'landing') {
        globalHeader.style.display = 'flex';
        globalHeader.querySelector('.custom-select').style.display = 'block';
        document.getElementById('header-signup-btn').style.display = 'block';
        onboardingHeader.style.display = 'none';
      }"""

new_update_headers = """      if (screenId === 'learning_home') {
        globalHeader.style.display = 'none';
        onboardingHeader.style.display = 'none';
      } else if (screenId === 'landing') {
        globalHeader.style.display = 'flex';
        globalHeader.querySelector('.custom-select').style.display = 'block';
        document.getElementById('header-signup-btn').style.display = 'block';
        onboardingHeader.style.display = 'none';
      }"""

content = content.replace(old_update_headers, new_update_headers)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print("updateHeaders modified.")
```

- [ ] **Step 2: Write Python script to inject renderHomeSection function**

```python
filepath = r"C:\research-workspace\design\onboarding-solve-edu\prototype-web.html"
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Add a marker id to the title so we can update it
content = content.replace(
    '<h1 class="title" style="margin-bottom: 4px;">Welcome back!</h1>',
    '<h1 id="home_greeting" class="title" style="margin-bottom: 4px;">Welcome back!</h1>'
)

# Insert renderHomeSection JS function before populateProfileSummary
render_logic = """
    function renderHomeSection() {
        const uName = document.getElementById('name_input').value.trim() || 'Learner';
        document.getElementById('home_greeting').innerText = `Hi, ${uName}!`;
    }
"""

content = content.replace(
    "    function populateProfileSummary() {",
    render_logic + "\\n    function populateProfileSummary() {"
)

# Hook it into the goTo function
content = content.replace(
    "      updateHeaders(screenId);",
    "      updateHeaders(screenId);\\n      if (screenId === 'learning_home') renderHomeSection();"
)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print("renderHomeSection logic injected.")
```

- [ ] **Step 3: Run scripts and check diff**
Execute the scripts from Step 1 and 2. Ensure no errors occur.

- [ ] **Step 4: Commit**
```bash
git add C:/research-workspace/design/onboarding-solve-edu/prototype-web.html
git commit -m "feat(home): hide top nav and render personalized greeting"
```

---

### Task 3: Dynamic Course Mapping & Program Tasks

**Files:**
- Modify: `C:\research-workspace\design\onboarding-solve-edu\prototype-web.html`

**Interfaces:**
- Consumes: `selectedGoal`, `entryPath`, `renderHomeSection()`
- Produces: Populated course title, dynamically rendered Program tasks block.

- [ ] **Step 1: Write Python script to inject Course & Program HTML placeholders**

```python
filepath = r"C:\research-workspace\design\onboarding-solve-edu\prototype-web.html"
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update the Up Next section to have an ID
content = content.replace(
    '<div style="font-size: 24px; font-weight: 700; margin: 8px 0 16px;">Workplace Communication</div>',
    '<div id="home_course_title" style="font-size: 24px; font-weight: 700; margin: 8px 0 16px;">Workplace Communication</div>'
)

# 2. Inject the Program Tasks block right below the course block
program_block = """
      <div id="home_program_tasks" style="display: none; background: white; border: 1px solid var(--hair); border-radius: 20px; padding: 24px; margin-bottom: 24px;">
        <div style="font-size: 18px; font-weight: 800; color: var(--ink); margin-bottom: 8px;"><span id="home_program_name">Youth Job Readiness 2026</span> Tasks</div>
        <p style="color: var(--sub); font-size: 14px; margin-bottom: 20px;">Complete these tasks to finish your program requirements.</p>
        <div style="display: flex; flex-direction: column; gap: 16px;">
          <label style="display: flex; align-items: center; gap: 12px; font-size: 15px; font-weight: 500; cursor: pointer;">
            <input type="checkbox" checked disabled style="width: 20px; height: 20px; accent-color: var(--green);"> Complete Registration
          </label>
          <label style="display: flex; align-items: center; gap: 12px; font-size: 15px; font-weight: 500; cursor: pointer;">
            <input type="checkbox" style="width: 20px; height: 20px; accent-color: var(--purple);"> Take the Baseline Assessment
          </label>
          <label style="display: flex; align-items: center; gap: 12px; font-size: 15px; font-weight: 500; cursor: pointer;">
            <input type="checkbox" style="width: 20px; height: 20px; accent-color: var(--purple);"> Complete 3 Modules
          </label>
          <label style="display: flex; align-items: center; gap: 12px; font-size: 15px; font-weight: 500; cursor: pointer;">
            <input type="checkbox" style="width: 20px; height: 20px; accent-color: var(--purple);"> Earn your Certificate
          </label>
        </div>
      </div>
"""

content = content.replace(
    '      <button class="btn btn-primary" style="font-size: 18px;" onclick="goTo(\\'learning_home\\')">Start Lesson</button>',
    program_block + '      <button class="btn btn-primary" style="font-size: 18px;" onclick="goTo(\\'learning_home\\')">Start Lesson</button>'
)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print("HTML placeholders injected.")
```

- [ ] **Step 2: Write Python script to update `renderHomeSection` logic**

```python
filepath = r"C:\research-workspace\design\onboarding-solve-edu\prototype-web.html"
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the simple renderHomeSection with the full logic
old_logic = """    function renderHomeSection() {
        const uName = document.getElementById('name_input').value.trim() || 'Learner';
        document.getElementById('home_greeting').innerText = `Hi, ${uName}!`;
    }"""

new_logic = """    function renderHomeSection() {
        const uName = document.getElementById('name_input').value.trim() || 'Learner';
        document.getElementById('home_greeting').innerText = `Hi, ${uName}!`;
        
        // Course mapping
        const courseMap = {
            'english': 'English for Workplace',
            'math': 'Practical Math Skills',
            'workplace': 'Workplace Communication',
            'digital_literacy': 'Digital Skills for the Modern World',
            'entrepreneurship': 'Start Your Own Business'
        };
        
        const courseTitle = courseMap[selectedGoal] || 'General Skills Mastery';
        document.getElementById('home_course_title').innerText = courseTitle;
        
        // Program tasks conditional logic
        if (typeof entryPath !== 'undefined' && entryPath === 'program') {
            document.getElementById('home_program_tasks').style.display = 'block';
            document.getElementById('home_program_name').innerText = 'Youth Job Readiness 2026';
        } else {
            document.getElementById('home_program_tasks').style.display = 'none';
        }
    }"""

content = content.replace(old_logic, new_logic)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print("renderHomeSection updated with course mapping.")
```

- [ ] **Step 3: Run scripts and check diff**
Execute both scripts and verify the output using `git diff`.

- [ ] **Step 4: Commit**
```bash
git add C:/research-workspace/design/onboarding-solve-edu/prototype-web.html
git commit -m "feat(home): add dynamic course mapping and program task list"
```
