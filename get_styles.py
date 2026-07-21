import urllib.request
import re
import json

req = urllib.request.Request('https://staging.solve.education/', headers={'User-Agent': 'Mozilla/5.0'})
try:
    html = urllib.request.urlopen(req).read().decode('utf-8')
    print('FONTS:', set(re.findall(r'font-family:[^;]+;', html)))
    print('COLORS:', set(re.findall(r'#[0-9a-fA-F]{3,6}', html)))
    print('CSS FILES:', set(re.findall(r'href=[\'"]([^\'"]+?\.css[^\'"]*)[\'"]', html)))
    
    with open('staging.html', 'w', encoding='utf-8') as f:
        f.write(html)
except Exception as e:
    print(f"Error: {e}")
