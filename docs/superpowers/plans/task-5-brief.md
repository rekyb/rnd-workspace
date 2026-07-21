### Task 5: Progress Bar & Screen Transitions

**Files:**
- Modify: `C:\research-workspace\design\onboarding-solve-edu\prototype-web.html`

**Interfaces:**
- Consumes: `--easing-spring`

- [ ] **Step 1: Write the python patch script for progress bar and transitions**

```python
# patch-transitions.py
import re

file_path = r'C:\research-workspace\design\onboarding-solve-edu\prototype-web.html'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update progress bar track (add inset shadow)
old_track = '<div style="flex: 1; max-width: 400px; height: 8px; background: #e0e0e0; border-radius: 4px; overflow: hidden; margin: 0 auto;">'
new_track = '<div style="flex: 1; max-width: 400px; height: 8px; background: #e0e0e0; border-radius: 4px; overflow: hidden; margin: 0 auto; box-shadow: inset 0 2px 4px rgba(0,0,0,0.1);">'
content = content.replace(old_track, new_track)

# 2. Update progress bar fill (use spring easing)
old_fill = '<div id="progress-bar" style="width: 0%; height: 100%; background: var(--purple); transition: width 0.3s ease-out;"></div>'
new_fill = '<div id="progress-bar" style="width: 0%; height: 100%; background: var(--purple); transition: width 0.5s var(--easing-spring);"></div>'
content = content.replace(old_fill, new_fill)

# 3. Update .card.active animation and add springSlideUpIn
old_card_active = '''    .card.active {
      display: flex;
      animation: obFadeInUp 0.4s cubic-bezier(0.2, 0, 0, 1) forwards;
    }'''

new_card_active = '''    .card.active {
      display: flex;
      animation: springSlideUpIn 0.5s var(--easing-spring) forwards;
    }

    @keyframes springSlideUpIn {
      0% { opacity: 0; transform: translateY(40px) scale(0.95); }
      100% { opacity: 1; transform: translateY(0) scale(1); }
    }'''
content = content.replace(old_card_active, new_card_active)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Transitions revamped.")
```

- [ ] **Step 2: Run the script**

Run: `python patch-transitions.py`
Expected: Output "Transitions revamped."

- [ ] **Step 3: Verify the changes**

Run: `grep -C 3 "springSlideUpIn" C:\research-workspace\design\onboarding-solve-edu\prototype-web.html`
Expected: Shows the new animation CSS.

- [ ] **Step 4: Commit**

```bash
git add C:/research-workspace/design/onboarding-solve-edu/prototype-web.html
git commit -m "style(transitions): implement spring physics for progress bar and screen arrivals"
```
