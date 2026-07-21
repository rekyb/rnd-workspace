# Micro-Interactions Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Phase 1 of the Tangible & Magnetic micro-interactions (new CSS variables and 3D button press physics) into the onboarding prototype.

**Architecture:** We are updating the monolithic `prototype-web.html` CSS block. We'll inject new tokens into `:root` and update the `.btn` and related button classes to use physical `translateY` transforms instead of flat hover states.

**Tech Stack:** Vanilla HTML/CSS/JS

## Global Constraints

- No external frameworks or libraries.
- Edits must be directly applied to `C:\research-workspace\design\onboarding-solve-edu\prototype-web.html`.

---

### Task 1: CSS Foundation Variables

**Files:**
- Modify: `C:\research-workspace\design\onboarding-solve-edu\prototype-web.html`

**Interfaces:**
- Produces: CSS variables `--easing-spring`, `--easing-fast`, `--hair-dark`, `--purple-dark` in `:root`.

- [ ] **Step 1: Write the python patch script for CSS variables**

```python
# patch-css-vars.py
import re

file_path = r'C:\research-workspace\design\onboarding-solve-edu\prototype-web.html'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

new_vars = '''      --hair: #e5e5e5;
      
      --easing-spring: cubic-bezier(0.34, 1.56, 0.64, 1);
      --easing-fast: cubic-bezier(0.2, 0, 0, 1);
      --hair-dark: #d5d5d5;
      --purple-dark: #64156d;'''

content = content.replace('--hair: #e5e5e5;', new_vars)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("CSS variables injected.")
```

- [ ] **Step 2: Run the script**

Run: `python patch-css-vars.py`
Expected: Output "CSS variables injected."

- [ ] **Step 3: Verify the changes**

Run: `grep -C 2 "--easing-spring" C:\research-workspace\design\onboarding-solve-edu\prototype-web.html`
Expected: Shows the new variables properly inserted in `:root`.

- [ ] **Step 4: Commit**

```bash
git add C:/research-workspace/design/onboarding-solve-edu/prototype-web.html
git commit -m "style: add micro-interaction easing and depth tokens"
```

---

### Task 2: Refactor Primary and Secondary Buttons

**Files:**
- Modify: `C:\research-workspace\design\onboarding-solve-edu\prototype-web.html`

**Interfaces:**
- Consumes: `--easing-fast`, `--purple-dark`

- [ ] **Step 1: Write the python patch script for buttons**

```python
# patch-buttons.py
import re

file_path = r'C:\research-workspace\design\onboarding-solve-edu\prototype-web.html'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Base button transition
content = content.replace(
    'transition: background 0.2s, transform 0.1s;',
    'transition: transform 0.2s var(--easing-fast), box-shadow 0.2s var(--easing-fast), background 0.2s;'
)

# Primary button normal state
old_primary = '''    .btn-primary {
      background: var(--pri);
      color: var(--charcoal);
    }
    .btn-primary:hover {
      background: var(--pri-hover);
    }'''

new_primary = '''    .btn-primary {
      background: var(--pri);
      color: var(--charcoal);
      box-shadow: 0 6px 0 var(--purple-dark);
    }
    .btn-primary:hover {
      background: var(--pri-hover);
      transform: translateY(-2px);
      box-shadow: 0 8px 0 var(--purple-dark);
    }
    .btn-primary:active {
      transform: translateY(6px);
      box-shadow: 0 0px 0 var(--purple-dark);
      transition: transform 0.05s, box-shadow 0.05s;
    }'''
content = content.replace(old_primary, new_primary)

# Secondary button normal state
old_secondary = '''    .btn-secondary {
      background: var(--surf);
      color: var(--purple);
      border: 2px solid var(--purple);
    }
    .btn-secondary:hover {
      background: var(--purple-bg);
    }'''

new_secondary = '''    .btn-secondary {
      background: var(--surf);
      color: var(--purple);
      border: 2px solid var(--purple);
      box-shadow: 0 6px 0 var(--purple-dark);
    }
    .btn-secondary:hover {
      background: var(--purple-bg);
      transform: translateY(-2px);
      box-shadow: 0 8px 0 var(--purple-dark);
    }
    .btn-secondary:active {
      transform: translateY(6px);
      box-shadow: 0 0px 0 var(--purple-dark);
      transition: transform 0.05s, box-shadow 0.05s;
    }'''
content = content.replace(old_secondary, new_secondary)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Buttons revamped.")
```

- [ ] **Step 2: Run the script**

Run: `python patch-buttons.py`
Expected: Output "Buttons revamped."

- [ ] **Step 3: Verify the changes**

Run: `grep -C 3 "translateY(6px)" C:\research-workspace\design\onboarding-solve-edu\prototype-web.html`
Expected: Shows the `.btn-primary:active` and `.btn-secondary:active` blocks.

- [ ] **Step 4: Commit**

```bash
git add C:/research-workspace/design/onboarding-solve-edu/prototype-web.html
git commit -m "style: implement tangible 3D button press physics"
```
