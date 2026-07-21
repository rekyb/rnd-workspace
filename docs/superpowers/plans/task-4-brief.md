### Task 4: 6-Digit Code Input

**Files:**
- Modify: `C:\research-workspace\design\onboarding-solve-edu\prototype-web.html`

**Interfaces:**
- Consumes: `--easing-spring`, `--easing-fast`, `--purple`

- [ ] **Step 1: Write the python patch script for the code input**

```python
# patch-code-input.py
import re

file_path = r'C:\research-workspace\design\onboarding-solve-edu\prototype-web.html'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace .code-digit CSS
old_code_digit = '''    .code-digit {
      width: 56px;
      height: 68px;
      border: 2px solid var(--hair);
      border-radius: 12px;
      font-size: 28px;
      font-weight: 700;
      text-align: center;
      color: var(--ink);
      transition: border-color 0.2s;
    }
    .code-digit:focus {
      border-color: var(--purple);
      outline: none;
    }'''

new_code_digit = '''    .code-digit {
      width: 56px;
      height: 68px;
      border: 2px solid var(--hair);
      border-radius: 12px;
      font-size: 28px;
      font-weight: 700;
      text-align: center;
      color: var(--ink);
      box-shadow: inset 0 3px 6px rgba(0,0,0,0.06);
      transition: transform 0.3s var(--easing-spring), box-shadow 0.3s var(--easing-spring), border-color 0.2s;
    }
    .code-digit:focus {
      border-color: var(--purple);
      outline: none;
      transform: scale(1.05);
      box-shadow: 0 4px 12px rgba(142, 39, 155, 0.15);
    }
    
    @keyframes keystrokePulse { 
      0% { transform: scale(1.05); } 
      50% { transform: scale(0.9); } 
      100% { transform: scale(1.05); } 
    }
    
    .code-digit.pulse { 
      animation: keystrokePulse 0.15s var(--easing-fast) forwards; 
    }'''
content = content.replace(old_code_digit, new_code_digit)

# Patch the JS to add the pulse class
old_js = '''  inputs.forEach((input, index) => {
    input.addEventListener('input', (e) => {
      const val = e.target.value;'''

new_js = '''  inputs.forEach((input, index) => {
    input.addEventListener('input', (e) => {
      // Add pulse animation
      input.classList.remove('pulse');
      void input.offsetWidth; // trigger reflow
      input.classList.add('pulse');
      input.addEventListener('animationend', () => input.classList.remove('pulse'), {once: true});
      
      const val = e.target.value;'''
content = content.replace(old_js, new_js)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Code input revamped.")
```

- [ ] **Step 2: Run the script**

Run: `python patch-code-input.py`
Expected: Output "Code input revamped."

- [ ] **Step 3: Verify the changes**

Run: `grep -C 3 "keystrokePulse" C:\research-workspace\design\onboarding-solve-edu\prototype-web.html`
Expected: Shows the animation CSS.
Run: `grep -C 3 "pulse" C:\research-workspace\design\onboarding-solve-edu\prototype-web.html`
Expected: Shows both the CSS class and the JS logic for the `pulse` class.

- [ ] **Step 4: Commit**

```bash
git add C:/research-workspace/design/onboarding-solve-edu/prototype-web.html
git commit -m "feat(inputs): add tactile hardware slot styling and keystroke pulse to code input"
```
