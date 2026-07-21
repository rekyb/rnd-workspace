import json
import re

file_path = r'C:\Users\rekyb\Downloads\Onboarding Flow v2 - Standalone.html'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

m = re.search(r'<script type="__bundler/template">(.*?)</script>', content, re.DOTALL)
if m:
    template = json.loads(m.group(1))
    with open('extracted_template.html', 'w', encoding='utf-8') as out_f:
        out_f.write(template)
    print("Template extracted to extracted_template.html")
else:
    print("No template found")
