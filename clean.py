import re

with open('extracted_template.html', 'r', encoding='utf-8') as f:
    html = f.read()

html = re.sub(r'<style>.*?</style>', '', html, flags=re.DOTALL)
html = re.sub(r'</?helmet>', '', html)

with open('clean_template.html', 'w', encoding='utf-8') as f:
    f.write(html)
