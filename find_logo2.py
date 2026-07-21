import urllib.request
import re

req = urllib.request.Request('https://solveeducation.org/', headers={'User-Agent': 'Mozilla/5.0'})
try:
    html = urllib.request.urlopen(req).read().decode('utf-8')
    imgs = re.findall(r'<img[^>]+src=[\'"]([^\'"]+)[\'"][^>]*>', html)
    print("ALL IMGS:")
    for img in imgs:
        print(img)
except Exception as e:
    print(f"Error: {e}")
