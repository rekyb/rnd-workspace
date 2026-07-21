import json
import base64
import re
import gzip

file_path = r'C:\Users\rekyb\Downloads\Onboarding Flow v2 - Standalone.html'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

m = re.search(r'<script type="__bundler/manifest">(.*?)</script>', content, re.DOTALL)
if m:
    manifest = json.loads(m.group(1))
    code = ""
    for k, v in manifest.items():
        mime = v.get("mime", "")
        if "text/" in mime or "application/javascript" in mime or "application/json" in mime:
            try:
                decoded_bytes = base64.b64decode(v["data"])
                if v.get("compressed"):
                    decoded_bytes = gzip.decompress(decoded_bytes)
                decoded = decoded_bytes.decode("utf-8", errors="ignore")
                code += f"\n\n/* ----- Asset: {k} (MIME: {mime}) ----- */\n\n"
                code += decoded
            except Exception as e:
                code += f"// Could not decode {k}: {e}\n"
    
    with open('extracted_react.jsx', 'w', encoding='utf-8') as out_f:
        out_f.write(code)
    print("Code extracted to extracted_react.jsx")
else:
    print("No manifest found")
