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
old_js_1 = '''  inputs.forEach((input, index) => {
    input.addEventListener('input', (e) => {
      const val = e.target.value;'''

old_js_2 = '''    inputs.forEach((input, index) => {
      input.addEventListener('input', (e) => {
        if (e.target.value.length === 1'''

new_js_pulse = '''    inputs.forEach((input, index) => {
      input.addEventListener('input', (e) => {
        // Add pulse animation
        input.classList.remove('pulse');
        void input.offsetWidth; // trigger reflow
        input.classList.add('pulse');
        input.addEventListener('animationend', () => input.classList.remove('pulse'), {once: true});
        
        if (e.target.value.length === 1'''

if old_js_1 in content:
    new_js = '''  inputs.forEach((input, index) => {
    input.addEventListener('input', (e) => {
      // Add pulse animation
      input.classList.remove('pulse');
      void input.offsetWidth; // trigger reflow
      input.classList.add('pulse');
      input.addEventListener('animationend', () => input.classList.remove('pulse'), {once: true});
      
      const val = e.target.value;'''
    content = content.replace(old_js_1, new_js)
elif old_js_2 in content:
    content = content.replace(old_js_2, new_js_pulse)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Code input revamped.")
