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
