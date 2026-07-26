# Onboarding Standalone Synchronization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild `standalone.html` as an exact self-contained snapshot of the current modular onboarding prototype.

**Architecture:** Add a focused PowerShell build script beside the prototype that reads the modular HTML, CSS, JavaScript, and local images, then emits one offline-capable HTML file. Extend the existing prototype test script with structural and parity assertions so stale or externally local dependencies are detected.

**Tech Stack:** HTML5, CSS, browser JavaScript, PowerShell 5+

## Global Constraints

- Preserve the document structure and body markup from `prototype-web.html`.
- Inline `styles.css`, `data.js`, and `main.js` in that order.
- Convert local image references to MIME-appropriate base64 data URLs.
- Preserve external Google Fonts and Material Symbols references.
- Do not introduce layout, copy, interaction, or data changes.
- Preserve unrelated working-tree changes.

---

### Task 1: Add standalone build assertions and generator

**Files:**
- Create: `design/onboarding-solve-edu/build-standalone.ps1`
- Modify: `design/onboarding-solve-edu/prototype-web.test.ps1`
- Generate: `design/onboarding-solve-edu/standalone.html`

**Interfaces:**
- Consumes: `prototype-web.html`, `styles.css`, `data.js`, `main.js`, and relative image paths rooted at `design/onboarding-solve-edu`
- Produces: `standalone.html`, with local CSS, JavaScript, and image dependencies embedded

- [ ] **Step 1: Add failing standalone assertions**

Append checks to `prototype-web.test.ps1` that:

```powershell
$standalonePath = Join-Path $PSScriptRoot 'standalone.html'
$standalone = Get-Content -LiteralPath $standalonePath -Raw
$styles = Get-Content -LiteralPath $stylesPath -Raw
$data = Get-Content -LiteralPath $dataPath -Raw
$main = Get-Content -LiteralPath $mainPath -Raw

function Assert-Standalone([bool]$Condition, [string]$Message) {
  if (-not $Condition) { throw $Message }
}

Assert-Standalone ($standalone -notmatch 'href=["'']styles\.css["'']') 'Standalone must inline styles.css'
Assert-Standalone ($standalone -notmatch 'src=["''](?:data|main)\.js["'']') 'Standalone must inline local JavaScript'
Assert-Standalone ($standalone -notmatch '(?:src|url\()["'']?(?!data:|https?:|#)[^"'')]+(?:\.png|\.jpe?g|\.gif|\.webp|\.svg)') 'Standalone must embed local images'
Assert-Standalone ($standalone.Contains($styles.Trim())) 'Standalone must contain the current stylesheet'
Assert-Standalone ($standalone.Contains($data.Trim())) 'Standalone must contain the current data script'
Assert-Standalone ($standalone.Contains($main.Trim())) 'Standalone must contain the current main script'
```

- [ ] **Step 2: Run the assertions and verify stale standalone content fails**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File design/onboarding-solve-edu/prototype-web.test.ps1
```

Expected: at least one new standalone parity assertion fails because the current artifact predates the latest modular source.

- [ ] **Step 3: Implement the deterministic builder**

Create `build-standalone.ps1` with:

```powershell
$ErrorActionPreference = 'Stop'

$prototypePath = Join-Path $PSScriptRoot 'prototype-web.html'
$stylesPath = Join-Path $PSScriptRoot 'styles.css'
$dataPath = Join-Path $PSScriptRoot 'data.js'
$mainPath = Join-Path $PSScriptRoot 'main.js'
$outputPath = Join-Path $PSScriptRoot 'standalone.html'

$html = Get-Content -Raw $prototypePath
$styles = Get-Content -Raw $stylesPath
$data = Get-Content -Raw $dataPath
$main = Get-Content -Raw $mainPath

$html = $html.Replace('<link rel="stylesheet" href="styles.css">', "<style>`r`n$styles`r`n</style>")
$html = $html.Replace('<script src="data.js"></script>', "<script>`r`n$data`r`n</script>")
$html = $html.Replace('<script src="main.js"></script>', "<script>`r`n$main`r`n</script>")

$assetPattern = '(?<=["''(])(?<path>(?!data:|https?:|#)[^"''()]+?\.(?:png|jpe?g|gif|webp|svg))(?=["'')])'
$html = [regex]::Replace($html, $assetPattern, {
    param($match)

    $relativePath = $match.Groups['path'].Value
    $assetPath = Join-Path $PSScriptRoot ($relativePath -replace '/', '\')
    if (-not (Test-Path -LiteralPath $assetPath -PathType Leaf)) {
        throw "Local asset not found: $relativePath"
    }

    $extension = [IO.Path]::GetExtension($assetPath).ToLowerInvariant()
    $mime = switch ($extension) {
        '.png'  { 'image/png' }
        '.jpg'  { 'image/jpeg' }
        '.jpeg' { 'image/jpeg' }
        '.gif'  { 'image/gif' }
        '.webp' { 'image/webp' }
        '.svg'  { 'image/svg+xml' }
        default { throw "Unsupported image type: $extension" }
    }

    $bytes = [IO.File]::ReadAllBytes($assetPath)
    "data:$mime;base64,$([Convert]::ToBase64String($bytes))"
})

[IO.File]::WriteAllText($outputPath, $html, [Text.UTF8Encoding]::new($false))
Write-Output "Built $outputPath"
```

- [ ] **Step 4: Generate the standalone artifact**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File design/onboarding-solve-edu/build-standalone.ps1
```

Expected: `Built ...\design\onboarding-solve-edu\standalone.html`.

- [ ] **Step 5: Run all structural and parity tests**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File design/onboarding-solve-edu/prototype-web.test.ps1
```

Expected: all assertions pass and the process exits with code 0.

- [ ] **Step 6: Perform artifact sanity checks**

Run:

```powershell
rg -n 'href="styles\.css"|src="(?:data|main)\.js"|(?:src|url\()["'']?(?:img/|\./img/)' design/onboarding-solve-edu/standalone.html
git diff --check -- design/onboarding-solve-edu/build-standalone.ps1 design/onboarding-solve-edu/prototype-web.test.ps1 design/onboarding-solve-edu/standalone.html
```

Expected: `rg` returns no matches; `git diff --check` reports no whitespace errors.

- [ ] **Step 7: Commit the focused implementation**

```powershell
git add -- design/onboarding-solve-edu/build-standalone.ps1 design/onboarding-solve-edu/prototype-web.test.ps1 design/onboarding-solve-edu/standalone.html
git commit -m "build: synchronize onboarding standalone prototype"
```
