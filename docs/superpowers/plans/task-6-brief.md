### Task 6: Success Screen Stamp Animation

**Files:**
- Modify: `C:\research-workspace\design\onboarding-solve-edu\prototype-web.html`

**Interfaces:**
- Consumes: `--easing-spring`

- [ ] **Step 1: Write the python patch script for the stamp animation**

```python
# patch-stamp.py
import re

file_path = r'C:\research-workspace\design\onboarding-solve-edu\prototype-web.html'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

stamp_css = '''
    /* S6 Stamp Animation */
    @keyframes springStampIn {
      0% { opacity: 0; transform: scale(1.2); }
      100% { opacity: 1; transform: scale(1); }
    }
    
    #assigned_content.active > h1.title {
      opacity: 0;
      animation: springStampIn 0.5s var(--easing-spring) 0.1s forwards;
    }
    #assigned_content.active > p.subtitle {
      opacity: 0;
      animation: springStampIn 0.5s var(--easing-spring) 0.2s forwards;
    }
    #assigned_content.active > div {
      opacity: 0;
      animation: springStampIn 0.5s var(--easing-spring) 0.3s forwards;
    }
'''

# Insert the stamp_css just before the closing </style> tag
content = content.replace('  </style>', stamp_css + '  </style>')

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Stamp animation added.")
```

- [ ] **Step 2: Run the script**

Run: `python patch-stamp.py`
Expected: Output "Stamp animation added."

- [ ] **Step 3: Verify the changes**

Run: `grep -C 3 "springStampIn" C:\research-workspace\design\onboarding-solve-edu\prototype-web.html`
Expected: Shows the new animation CSS targeting `#assigned_content`.

- [ ] **Step 4: Commit**

```bash
git add C:/research-workspace/design/onboarding-solve-edu/prototype-web.html
git commit -m "feat(success): add staggered stamp animation to assigned content screen"
```
