## Global Constraints

- No external frameworks or libraries.
- Edits must be directly applied to C:\research-workspace\design\onboarding-solve-edu\prototype-web.html.

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
