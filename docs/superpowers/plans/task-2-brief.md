## Global Constraints

- No external frameworks or libraries.
- Edits must be directly applied to C:\research-workspace\design\onboarding-solve-edu\prototype-web.html.

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
