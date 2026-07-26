# rnd-workspace Design System Foundation (Phase 1) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bring the production design tokens and component CSS into this repo as a shared `ui/` library, synced by a drift-checkable command, with a local gate that enforces ADR-0003 on any prototype built against it.

**Architecture:** `globals.css` from the production repo carries a `TOKENS:START`/`TOKENS:END` marker pair. `sync-tokens.ps1` shallow-clones the source, slices the raw text at those markers, and writes the two halves to `ui/tokens.css` (the 166 custom properties) and `ui/components.css` (the 239 class selectors) byte-exactly. Nothing is regenerated or reinterpreted, so upstream generator changes never need tracking here. `check-prototype.ps1` then validates any built prototype against those two files.

**Tech Stack:** Windows PowerShell 5.1 (no PowerShell 7 features), git CLI, dependency-free `*.Tests.ps1` harnesses matching `.claude/scripts/md_visualize.Tests.ps1`.

## Global Constraints

- Source repo: `https://gitlab.solveeducation.org/solveearn/solveeducation.git`, default ref `main`.
- Source file: `apps/web/app/(frontend)/globals.css`. **The path contains parentheses** — always use `Join-Path` and `-LiteralPath`, never `-Path` with wildcard expansion.
- Marker detection is by **prefix**, not full string: a line whose trimmed start is `/* TOKENS:START` and a line whose trimmed start is `/* TOKENS:END`. The full START marker text mentions `build.mjs` and contains an em-dash; matching it verbatim would be brittle.
- `ui/tokens.css` must be **byte-identical** to the source lines lying strictly between the two marker lines. Preserve the source's existing line endings — do not normalize.
- All files are written as **UTF-8 without BOM** via `[IO.File]::WriteAllText($path, $text, (New-Object System.Text.UTF8Encoding($false)))`. PS 5.1's `Set-Content -Encoding utf8` emits a BOM and must not be used for these outputs.
- All reads use `[IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)`. PS 5.1's `Get-Content` without `-Encoding` falls back to the system ANSI codepage on BOM-less files and mangles non-ASCII.
- **Disclosure boundary (hard):** the sync may write only inside `ui/`. It must never copy `packages/tokens/manifest.json`, anything from the source repo's `.claude/`, or anything under `apps/` other than the two slices of `globals.css`.
- The clone goes to the session scratchpad, never inside the workspace, and is deleted afterwards.
- No PowerShell chain operators (`&&`, `||`), no ternary, no `??` — PS 5.1 does not have them. Use `;` and `if`.
- Commits use `-c user.email=rekybongso@gmail.com -c user.name="Claude Code"` and end with the standard `Co-Authored-By` trailer.

### Verified upstream facts (measured 2026-07-26, commit `155341cd32d89de0e10eeaa5c2209ddf6bd80d1c`)

| Fact | Value |
|---|---|
| START marker line | 22 |
| END marker line | 194 |
| Custom properties strictly between | **166** |
| `components.css` lines | **2515** |
| `components.css` unique class selectors | **239** |
| `components.css` custom-property definitions | **0** |
| `tokens.json` leaf tokens | **133** |

Class-selector counting must use an explicit `[A-Za-z]` character class. A `[a-zA-Z]` range collates differently under some locales and inflates the count to 250.

---

### Task 1: Marker extraction core

**Files:**
- Create: `.claude/scripts/sync-tokens.ps1`
- Test: `.claude/scripts/sync-tokens.Tests.ps1`

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: `sync-tokens.ps1` accepting `-SourcePath <dir>` (a checkout root), `-UiRoot <dir>` (output root), and writing `tokens.css` and `components.css` into `-UiRoot`. Tasks 2 and 3 extend this same script with `-Check`, `-RepoUrl`, and `-Ref`.

- [ ] **Step 1: Write the failing test**

Create `.claude/scripts/sync-tokens.Tests.ps1`:

```powershell
# Dependency-free test harness for sync-tokens.ps1
$ErrorActionPreference = 'Stop'
$script:Failures = 0
$ScriptUnderTest = Join-Path $PSScriptRoot 'sync-tokens.ps1'

function Assert-Equal {
    param([string]$Expected, [string]$Actual, [string]$Because)
    if ($Expected -ne $Actual) {
        Write-Host "FAIL: $Because" -ForegroundColor Red
        Write-Host "  expected: <$Expected>"
        Write-Host "  actual:   <$Actual>"
        $script:Failures++
    } else {
        Write-Host "PASS: $Because" -ForegroundColor Green
    }
}

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# Builds a fake upstream checkout. $Globals is the full globals.css text.
function New-SourceFixture {
    param([string]$Globals)
    $root = Join-Path ([System.IO.Path]::GetTempPath()) ("synctok_" + [guid]::NewGuid().ToString('N'))
    $frontend = Join-Path $root 'apps\web\app\(frontend)'
    $tokens   = Join-Path $root 'packages\tokens'
    New-Item -ItemType Directory -Force -Path $frontend | Out-Null
    New-Item -ItemType Directory -Force -Path $tokens | Out-Null
    [IO.File]::WriteAllText((Join-Path $frontend 'globals.css'), $Globals, $Utf8NoBom)
    [IO.File]::WriteAllText((Join-Path $tokens 'tokens.json'), '{"color":{"pri":{"$value":"#ffcb1d"}}}', $Utf8NoBom)
    [IO.File]::WriteAllText((Join-Path $tokens 'manifest.json'), '{"projectId":"SECRET-DO-NOT-COPY"}', $Utf8NoBom)
    return $root
}

function New-UiRoot {
    $p = Join-Path ([System.IO.Path]::GetTempPath()) ("uiroot_" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Force -Path $p | Out-Null
    return $p
}

$GOOD = @"
/* header comment */
.pre { color: red; }
/* TOKENS:START (generated from packages/tokens/tokens.json by build.mjs — do not edit by hand) */
:root {
  --pri: #ffcb1d;
  --ink: #1d1826;
}
:root[data-theme="dark"] {
  --ink: #f5f2fa;
}
/* TOKENS:END */
.post { color: blue; }
"@

# --- Test 1: tokens.css is exactly the lines strictly between the markers
$src = New-SourceFixture -Globals $GOOD
$ui  = New-UiRoot
& powershell -NoProfile -File $ScriptUnderTest -SourcePath $src -UiRoot $ui | Out-Null
$tokensOut = [IO.File]::ReadAllText((Join-Path $ui 'tokens.css'), [System.Text.Encoding]::UTF8)
$expectedTokens = @"
:root {
  --pri: #ffcb1d;
  --ink: #1d1826;
}
:root[data-theme="dark"] {
  --ink: #f5f2fa;
}
"@
Assert-Equal $expectedTokens $tokensOut 'tokens.css is the lines strictly between the markers'

# --- Test 2: components.css is the file minus that block minus both marker lines
$compOut = [IO.File]::ReadAllText((Join-Path $ui 'components.css'), [System.Text.Encoding]::UTF8)
$expectedComp = @"
/* header comment */
.pre { color: red; }
.post { color: blue; }
"@
Assert-Equal $expectedComp $compOut 'components.css is the source minus the token block and both markers'

# --- Test 3: no custom properties leak into components.css
Assert-Equal '0' ([string]([regex]::Matches($compOut, '(?m)^\s*--[A-Za-z0-9-]+\s*:').Count)) 'components.css contains no custom-property definitions'

# --- Test 4: outputs are UTF-8 with NO BOM
$bytes = [IO.File]::ReadAllBytes((Join-Path $ui 'tokens.css'))
$hasBom = ($bytes.Count -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
Assert-Equal 'False' ([string]$hasBom) 'tokens.css is written without a BOM'

# --- Test 5: non-ASCII in a BOM-less source survives the round trip
$srcNonAscii = $GOOD.Replace('/* header comment */', '/* café — em-dash */')
$src5 = New-SourceFixture -Globals $srcNonAscii
$ui5  = New-UiRoot
& powershell -NoProfile -File $ScriptUnderTest -SourcePath $src5 -UiRoot $ui5 | Out-Null
$comp5 = [IO.File]::ReadAllText((Join-Path $ui5 'components.css'), [System.Text.Encoding]::UTF8)
Assert-Equal 'True' ([string]($comp5 -match 'café — em-dash')) 'BOM-less non-ASCII source survives extraction'

# --- Test 6: CRLF line endings are preserved, not normalized
$crlf = $GOOD -replace "`r?`n", "`r`n"
$src6 = New-SourceFixture -Globals $crlf
$ui6  = New-UiRoot
& powershell -NoProfile -File $ScriptUnderTest -SourcePath $src6 -UiRoot $ui6 | Out-Null
$tok6 = [IO.File]::ReadAllText((Join-Path $ui6 'tokens.css'), [System.Text.Encoding]::UTF8)
Assert-Equal 'True' ([string]($tok6.Contains("`r`n"))) 'CRLF source keeps CRLF endings in tokens.css'

# --- Test 7: a missing END marker fails loudly and writes nothing
$noEnd = $GOOD -replace '/\* TOKENS:END \*/', '/* nothing here */'
$src7 = New-SourceFixture -Globals $noEnd
$ui7  = New-UiRoot
$out7 = & powershell -NoProfile -File $ScriptUnderTest -SourcePath $src7 -UiRoot $ui7 2>&1
Assert-Equal 'True' ([string]($LASTEXITCODE -ne 0)) 'missing END marker exits non-zero'
Assert-Equal 'True' ([string]([string]$out7 -match 'TOKENS marker')) 'missing END marker reports the marker contract'
Assert-Equal 'False' ([string](Test-Path -LiteralPath (Join-Path $ui7 'tokens.css'))) 'missing END marker writes no tokens.css'

# --- Test 8: a missing START marker fails loudly
$noStart = $GOOD -replace '/\* TOKENS:START[^\r\n]*', '/* nothing here */'
$src8 = New-SourceFixture -Globals $noStart
$ui8  = New-UiRoot
& powershell -NoProfile -File $ScriptUnderTest -SourcePath $src8 -UiRoot $ui8 2>&1 | Out-Null
Assert-Equal 'True' ([string]($LASTEXITCODE -ne 0)) 'missing START marker exits non-zero'

foreach ($d in @($src,$ui,$src5,$ui5,$src6,$ui6,$src7,$ui7,$src8,$ui8)) { Remove-Item -Recurse -Force $d -ErrorAction SilentlyContinue }
if ($script:Failures -gt 0) { Write-Host "`n$($script:Failures) failure(s)" -ForegroundColor Red; exit 1 }
Write-Host "`nAll tests passed" -ForegroundColor Green
exit 0
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `powershell -NoProfile -File .claude/scripts/sync-tokens.Tests.ps1`
Expected: FAIL — the script does not exist, so every invocation errors.

- [ ] **Step 3: Write the minimal implementation**

Create `.claude/scripts/sync-tokens.ps1`:

```powershell
<#
.SYNOPSIS
  Sync the production design tokens and component CSS into this repo's ui/ folder.

.DESCRIPTION
  Slices apps/web/app/(frontend)/globals.css from the Solve Education production repo
  at its TOKENS:START / TOKENS:END markers. The lines strictly between the markers
  become ui/tokens.css (the design tokens); the rest of the file, minus both marker
  lines, becomes ui/components.css (the component classes). Both are byte-exact copies
  of the source text — nothing is regenerated, so upstream generator changes never need
  tracking here.

.EXAMPLE
  powershell -File sync-tokens.ps1 -SourcePath C:\tmp\checkout -UiRoot C:\repo\ui
#>
[CmdletBinding()]
param(
    [string]$SourcePath,
    [string]$UiRoot
)

$ErrorActionPreference = 'Stop'

$StartPrefix = '/* TOKENS:START'
$EndPrefix   = '/* TOKENS:END'

function Read-Utf8Text {
    param([string]$Path)
    return [IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Write-Utf8NoBom {
    param([string]$Path, [string]$Text)
    $enc = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($Path, $Text, $enc)
}

# Slice raw text at the two whole-line markers. Returns a hashtable with Tokens and
# Components. Operating on the raw string (never a line array) keeps the output
# byte-identical, including the source's original line endings.
function Split-TokenBlock {
    param([string]$Raw, [string]$SourceLabel)

    $startRx = [regex]::Escape($StartPrefix)
    $endRx   = [regex]::Escape($EndPrefix)

    $m1 = [regex]::Match($Raw, "(?m)^[ \t]*$startRx[^\r\n]*")
    if (-not $m1.Success) {
        throw "TOKENS marker not found in $SourceLabel : no line starting with '$StartPrefix'. The upstream marker contract changed; refusing to write a partial file."
    }
    $m2 = [regex]::Match($Raw, "(?m)^[ \t]*$endRx[^\r\n]*", $m1.Index + $m1.Length)
    if (-not $m2.Success) {
        throw "TOKENS marker not found in $SourceLabel : no line starting with '$EndPrefix' after the START marker. The upstream marker contract changed; refusing to write a partial file."
    }

    $nl1 = $Raw.IndexOf("`n", $m1.Index + $m1.Length)
    if ($nl1 -lt 0) { throw "TOKENS marker not found in $SourceLabel : START marker is the last line." }
    $tokensStart = $nl1 + 1
    $tokensEnd   = $m2.Index

    $nl2 = $Raw.IndexOf("`n", $m2.Index + $m2.Length)
    if ($nl2 -lt 0) { $afterEnd = $Raw.Length } else { $afterEnd = $nl2 + 1 }

    return @{
        Tokens     = $Raw.Substring($tokensStart, $tokensEnd - $tokensStart)
        Components = $Raw.Substring(0, $m1.Index) + $Raw.Substring($afterEnd)
    }
}

if (-not $SourcePath) { throw "-SourcePath is required." }
if (-not $UiRoot)     { throw "-UiRoot is required." }

$globals = Join-Path $SourcePath 'apps\web\app\(frontend)\globals.css'
if (-not (Test-Path -LiteralPath $globals)) { throw "globals.css not found at $globals" }

$raw   = Read-Utf8Text -Path $globals
$split = Split-TokenBlock -Raw $raw -SourceLabel $globals

if (-not (Test-Path -LiteralPath $UiRoot)) { New-Item -ItemType Directory -Force -Path $UiRoot | Out-Null }

Write-Utf8NoBom -Path (Join-Path $UiRoot 'tokens.css')     -Text $split.Tokens
Write-Utf8NoBom -Path (Join-Path $UiRoot 'components.css') -Text $split.Components

$propCount  = [regex]::Matches($split.Tokens, '(?m)^\s*--[A-Za-z0-9-]+\s*:').Count
$classCount = ([regex]::Matches($split.Components, '(?m)^\.[A-Za-z][A-Za-z0-9_-]*') | ForEach-Object { $_.Value } | Sort-Object -Unique).Count
Write-Host "tokens.css: $propCount custom properties"
Write-Host "components.css: $classCount unique class selectors"
exit 0
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `powershell -NoProfile -File .claude/scripts/sync-tokens.Tests.ps1`
Expected: PASS — all 10 assertions green, "All tests passed", exit 0.

- [ ] **Step 5: Commit**

```bash
git add .claude/scripts/sync-tokens.ps1 .claude/scripts/sync-tokens.Tests.ps1
git -c user.email=rekybongso@gmail.com -c user.name="Claude Code" commit -m "feat: add marker-based token extraction core

Slices globals.css at its TOKENS:START/END markers into tokens.css and
components.css, byte-exactly and without normalizing line endings.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 2: tokens.json, provenance, and the --check drift guard

**Files:**
- Modify: `.claude/scripts/sync-tokens.ps1`
- Modify: `.claude/scripts/sync-tokens.Tests.ps1`

**Interfaces:**
- Consumes: `Split-TokenBlock`, `Read-Utf8Text`, `Write-Utf8NoBom` from Task 1.
- Produces: `-Check` switch; `ui/tokens.json`; `ui/TOKENS.md` carrying a generated block between `<!-- PROVENANCE:START -->` and `<!-- PROVENANCE:END -->`. Task 3 supplies the real commit SHA via `-SourceSha`.

- [ ] **Step 1: Write the failing tests**

Append to `.claude/scripts/sync-tokens.Tests.ps1`, immediately before the final `foreach ($d in ...)` cleanup line (and add the new temp dirs to that cleanup list):

```powershell
# --- Test 9: tokens.json is copied, manifest.json is NEVER copied
$src9 = New-SourceFixture -Globals $GOOD
$ui9  = New-UiRoot
& powershell -NoProfile -File $ScriptUnderTest -SourcePath $src9 -UiRoot $ui9 -SourceSha ('a' * 40) | Out-Null
Assert-Equal 'True'  ([string](Test-Path -LiteralPath (Join-Path $ui9 'tokens.json')))   'tokens.json is copied into ui/'
Assert-Equal 'False' ([string](Test-Path -LiteralPath (Join-Path $ui9 'manifest.json'))) 'manifest.json is NEVER copied into ui/'

# --- Test 10: provenance block records the SHA between its markers
$prov = [IO.File]::ReadAllText((Join-Path $ui9 'TOKENS.md'), [System.Text.Encoding]::UTF8)
Assert-Equal 'True' ([string]($prov -match '<!-- PROVENANCE:START -->')) 'TOKENS.md has a PROVENANCE:START marker'
Assert-Equal 'True' ([string]($prov -match ('a' * 40)))                  'TOKENS.md records the resolved commit SHA'
Assert-Equal 'True' ([string]($prov -match '166|\d+ custom properties')) 'TOKENS.md records a token count'

# --- Test 11: hand-written prose outside the provenance markers survives a re-sync
$withProse = $prov + "`n## My hand-written notes`nKeep me.`n"
[IO.File]::WriteAllText((Join-Path $ui9 'TOKENS.md'), $withProse, $Utf8NoBom)
& powershell -NoProfile -File $ScriptUnderTest -SourcePath $src9 -UiRoot $ui9 -SourceSha ('b' * 40) | Out-Null
$prov2 = [IO.File]::ReadAllText((Join-Path $ui9 'TOKENS.md'), [System.Text.Encoding]::UTF8)
Assert-Equal 'True'  ([string]($prov2 -match 'Keep me\.'))  'hand-written prose survives a re-sync'
Assert-Equal 'True'  ([string]($prov2 -match ('b' * 40)))   'provenance block is refreshed with the new SHA'
Assert-Equal 'False' ([string]($prov2 -match ('a' * 40)))   'the previous SHA is replaced, not appended'

# --- Test 12: --check exits 0 and writes nothing when ui/ matches the source
$before = (Get-ChildItem -LiteralPath $ui9 -File | ForEach-Object { "$($_.Name):$($_.Length)" }) -join '|'
& powershell -NoProfile -File $ScriptUnderTest -SourcePath $src9 -UiRoot $ui9 -SourceSha ('b' * 40) -Check | Out-Null
Assert-Equal '0' ([string]$LASTEXITCODE) '--check exits 0 when ui/ is in sync'
$after = (Get-ChildItem -LiteralPath $ui9 -File | ForEach-Object { "$($_.Name):$($_.Length)" }) -join '|'
Assert-Equal $before $after '--check writes nothing when in sync'

# --- Test 13: --check exits non-zero and reports drift when tokens.css differs
[IO.File]::WriteAllText((Join-Path $ui9 'tokens.css'), ":root {`n  --pri: #000000;`n}`n", $Utf8NoBom)
$drift = & powershell -NoProfile -File $ScriptUnderTest -SourcePath $src9 -UiRoot $ui9 -SourceSha ('b' * 40) -Check 2>&1
Assert-Equal 'True' ([string]($LASTEXITCODE -ne 0))          '--check exits non-zero on drift'
Assert-Equal 'True' ([string]([string]$drift -match 'pri'))  '--check names the drifted token'

# --- Test 14: --check writes nothing even when it detects drift
$stillDrifted = [IO.File]::ReadAllText((Join-Path $ui9 'tokens.css'), [System.Text.Encoding]::UTF8)
Assert-Equal 'True' ([string]($stillDrifted -match '#000000')) '--check leaves the drifted file untouched'
```

Add `$src9,$ui9` to the cleanup `foreach` list at the end of the file.

- [ ] **Step 2: Run the tests to verify they fail**

Run: `powershell -NoProfile -File .claude/scripts/sync-tokens.Tests.ps1`
Expected: FAIL — `-SourceSha` and `-Check` are not parameters yet, so PowerShell rejects the invocation.

- [ ] **Step 3: Extend the implementation**

In `.claude/scripts/sync-tokens.ps1`, replace the `param(...)` block with:

```powershell
param(
    [string]$SourcePath,
    [string]$UiRoot,
    [string]$SourceSha = '(local)',
    [switch]$Check
)
```

Add these functions after `Write-Utf8NoBom`:

```powershell
# Parse "--name: value;" declarations into an ordered map for diff reporting.
function Get-TokenMap {
    param([string]$Css)
    $map = New-Object 'System.Collections.Specialized.OrderedDictionary'
    foreach ($m in [regex]::Matches($Css, '(?m)^\s*(--[A-Za-z0-9-]+)\s*:\s*([^;]+);')) {
        $name = $m.Groups[1].Value
        $val  = $m.Groups[2].Value.Trim()
        if (-not $map.Contains($name)) { $map[$name] = $val }
    }
    return $map
}

function Compare-TokenMaps {
    param($Old, $New)
    $lines = @()
    foreach ($k in $New.Keys) {
        if (-not $Old.Contains($k))      { $lines += "  + $k = $($New[$k])" }
        elseif ($Old[$k] -ne $New[$k])   { $lines += "  ~ $k : $($Old[$k]) -> $($New[$k])" }
    }
    foreach ($k in $Old.Keys) {
        if (-not $New.Contains($k))      { $lines += "  - $k (was $($Old[$k]))" }
    }
    return $lines
}

# Replace the generated region of TOKENS.md, preserving all hand-written prose.
function Update-ProvenanceBlock {
    param([string]$Path, [string]$Block)
    $start = '<!-- PROVENANCE:START -->'
    $end   = '<!-- PROVENANCE:END -->'
    $new   = "$start`n$Block`n$end"
    if (Test-Path -LiteralPath $Path) {
        $existing = Read-Utf8Text -Path $Path
        $rx = [regex]::Escape($start) + '.*?' + [regex]::Escape($end)
        if ([regex]::IsMatch($existing, $rx, 'Singleline')) {
            return [regex]::Replace($existing, $rx, { param($m) $new }, 'Singleline')
        }
        return $new + "`n`n" + $existing
    }
    return @"
# ui/tokens.css — provenance

$new

## What this is

Design tokens extracted verbatim from the Solve Education production repo. Do not
hand-edit tokens.css or components.css — run ``/sync-tokens`` instead. Per-project
brand divergence belongs in ``design/<project>/tokens.overlay.css``, which may
redefine an existing token name but never introduce a new one.
"@
}
```

Replace everything from `$raw   = Read-Utf8Text -Path $globals` to the final `exit 0` with:

```powershell
$raw   = Read-Utf8Text -Path $globals
$split = Split-TokenBlock -Raw $raw -SourceLabel $globals

$tokensJsonSrc = Join-Path $SourcePath 'packages\tokens\tokens.json'
if (-not (Test-Path -LiteralPath $tokensJsonSrc)) { throw "tokens.json not found at $tokensJsonSrc" }
$tokensJson = Read-Utf8Text -Path $tokensJsonSrc

$propCount  = [regex]::Matches($split.Tokens, '(?m)^\s*--[A-Za-z0-9-]+\s*:').Count
$classCount = ([regex]::Matches($split.Components, '(?m)^\.[A-Za-z][A-Za-z0-9_-]*') | ForEach-Object { $_.Value } | Sort-Object -Unique).Count

$tokensPath = Join-Path $UiRoot 'tokens.css'
$compPath   = Join-Path $UiRoot 'components.css'
$jsonPath   = Join-Path $UiRoot 'tokens.json'

if ($Check) {
    $drift = @()
    if (-not (Test-Path -LiteralPath $tokensPath)) {
        $drift += "tokens.css is missing from $UiRoot"
    } else {
        $current = Read-Utf8Text -Path $tokensPath
        if ($current -ne $split.Tokens) {
            $drift += "tokens.css differs from the source:"
            $drift += (Compare-TokenMaps -Old (Get-TokenMap $current) -New (Get-TokenMap $split.Tokens))
        }
    }
    if (-not (Test-Path -LiteralPath $compPath)) {
        $drift += "components.css is missing from $UiRoot"
    } elseif ((Read-Utf8Text -Path $compPath) -ne $split.Components) {
        $drift += "components.css differs from the source"
    }
    if (-not (Test-Path -LiteralPath $jsonPath)) {
        $drift += "tokens.json is missing from $UiRoot"
    } elseif ((Read-Utf8Text -Path $jsonPath) -ne $tokensJson) {
        $drift += "tokens.json differs from the source"
    }

    if ($drift.Count -gt 0) {
        Write-Host "DRIFT detected against $SourceSha" -ForegroundColor Red
        $drift | ForEach-Object { Write-Host $_ }
        exit 1
    }
    Write-Host "in sync with $SourceSha ($propCount custom properties, $classCount class selectors)" -ForegroundColor Green
    exit 0
}

if (-not (Test-Path -LiteralPath $UiRoot)) { New-Item -ItemType Directory -Force -Path $UiRoot | Out-Null }

$previous = $null
if (Test-Path -LiteralPath $tokensPath) { $previous = Get-TokenMap (Read-Utf8Text -Path $tokensPath) }

Write-Utf8NoBom -Path $tokensPath -Text $split.Tokens
Write-Utf8NoBom -Path $compPath   -Text $split.Components
Write-Utf8NoBom -Path $jsonPath   -Text $tokensJson

$stamp = (Get-Date).ToString('yyyy-MM-dd')
$block = @"
- **Source repo:** https://gitlab.solveeducation.org/solveearn/solveeducation.git
- **Commit:** ``$SourceSha``
- **Synced:** $stamp
- **tokens.css:** $propCount custom properties
- **components.css:** $classCount unique class selectors
"@
Write-Utf8NoBom -Path (Join-Path $UiRoot 'TOKENS.md') -Text (Update-ProvenanceBlock -Path (Join-Path $UiRoot 'TOKENS.md') -Block $block)

Write-Host "tokens.css: $propCount custom properties"
Write-Host "components.css: $classCount unique class selectors"
if ($previous) {
    $changes = Compare-TokenMaps -Old $previous -New (Get-TokenMap $split.Tokens)
    if ($changes.Count -gt 0) { Write-Host "token changes:"; $changes | ForEach-Object { Write-Host $_ } }
    else { Write-Host "token changes: none" }
}
exit 0
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `powershell -NoProfile -File .claude/scripts/sync-tokens.Tests.ps1`
Expected: PASS — all assertions green, exit 0.

- [ ] **Step 5: Commit**

```bash
git add .claude/scripts/sync-tokens.ps1 .claude/scripts/sync-tokens.Tests.ps1
git -c user.email=rekybongso@gmail.com -c user.name="Claude Code" commit -m "feat: add tokens.json copy, provenance block, and --check drift guard

--check compares ui/ against the source, reports per-token differences,
and writes nothing. Hand-written prose in TOKENS.md survives re-syncs.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 3: Clone wiring and the first real sync

**Files:**
- Modify: `.claude/scripts/sync-tokens.ps1`
- Create: `ui/tokens.css`, `ui/components.css`, `ui/tokens.json`, `ui/TOKENS.md` (all produced by running the script)

**Interfaces:**
- Consumes: everything from Tasks 1 and 2.
- Produces: `-RepoUrl` and `-Ref` parameters; when `-SourcePath` is absent the script clones, resolves the SHA, syncs, and deletes the clone.

- [ ] **Step 1: Add clone support**

In `.claude/scripts/sync-tokens.ps1`, extend `param(...)`:

```powershell
param(
    [string]$RepoUrl = 'https://gitlab.solveeducation.org/solveearn/solveeducation.git',
    [string]$Ref = 'main',
    [string]$SourcePath,
    [string]$UiRoot,
    [string]$SourceSha = '(local)',
    [switch]$Check
)
```

Immediately after the `$ErrorActionPreference = 'Stop'` line, add:

```powershell
$script:TempClone = $null

# Default -UiRoot to <repo-root>/ui so the command works with no arguments.
if (-not $UiRoot) { $UiRoot = Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) 'ui' }
```

Replace the `if (-not $SourcePath) { throw "-SourcePath is required." }` line with:

```powershell
if (-not $SourcePath) {
    $base = $env:TEMP
    if (-not $base) { $base = [System.IO.Path]::GetTempPath() }
    $script:TempClone = Join-Path $base ("setokens_" + [guid]::NewGuid().ToString('N'))
    Write-Host "cloning $RepoUrl ($Ref) — about 29 MB, this takes a minute..."
    $env:GIT_TERMINAL_PROMPT = '0'
    & git clone --depth 1 --branch $Ref $RepoUrl $script:TempClone 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "git clone failed for $RepoUrl ($Ref). Anonymous read access may have been revoked. The committed ui/ files are unaffected; only refresh is blocked."
    }
    $SourcePath = $script:TempClone
    $SourceSha  = (& git -C $script:TempClone rev-parse HEAD).Trim()
}
```

Add this function immediately after `Write-Utf8NoBom`:

```powershell
function Remove-TempClone {
    if ($script:TempClone -and (Test-Path -LiteralPath $script:TempClone)) {
        Remove-Item -Recurse -Force $script:TempClone -ErrorAction SilentlyContinue
    }
}
```

Then insert `Remove-TempClone` as the line immediately before **each of the three** `exit` statements: `exit 1` on drift and `exit 0` when in sync (both inside the `if ($Check)` branch), and the final `exit 0` of the sync path.

Errors need covering too, since `$ErrorActionPreference = 'Stop'` means any `throw` skips those lines. Wrap everything from the clone block to the end of the script in `try { … } finally { Remove-TempClone }`. A 29 MB clone left behind after a mid-run failure is the exact failure mode this guards against.

- [ ] **Step 2: Verify the existing tests still pass**

Run: `powershell -NoProfile -File .claude/scripts/sync-tokens.Tests.ps1`
Expected: PASS — all assertions green. The tests all pass `-SourcePath`, so the clone branch is never entered and no network access occurs.

- [ ] **Step 3: Run the real sync**

Run: `powershell -NoProfile -File .claude/scripts/sync-tokens.ps1`
Expected: clone progress, then `tokens.css: 166 custom properties` and `components.css: 239 unique class selectors`.

- [ ] **Step 4: Verify the acceptance criteria**

Run each and confirm the stated value:

```bash
grep -cE '^\s*--[A-Za-z0-9-]+\s*:' ui/tokens.css                          # expect 166
grep -oE '^\.[A-Za-z][A-Za-z0-9_-]*' ui/components.css | sort -u | wc -l   # expect 239
wc -l < ui/components.css                                                  # expect 2515
grep -cE '^\s*--[A-Za-z0-9-]+\s*:' ui/components.css                       # expect 0
grep -oE '\b[0-9a-f]{40}\b' ui/TOKENS.md                                   # expect a 40-char SHA
ls ui/manifest.json 2>/dev/null || echo "manifest.json correctly absent"
grep -c 'data-theme="dark"' ui/tokens.css                                  # expect 1
```

If any value differs, stop and report — do not adjust the expected numbers to match the output.

- [ ] **Step 5: Confirm the clone was cleaned up**

Run: `ls "$TEMP" | grep setokens_ || echo "no clone left behind"`
Expected: `no clone left behind`.

- [ ] **Step 6: Commit**

```bash
git add .claude/scripts/sync-tokens.ps1 ui/tokens.css ui/components.css ui/tokens.json ui/TOKENS.md
git -c user.email=rekybongso@gmail.com -c user.name="Claude Code" commit -m "feat: sync production design tokens and component CSS into ui/

166 custom properties and 239 class selectors extracted verbatim from the
production globals.css. manifest.json and the source repo's .claude/ are
excluded per the disclosure boundary.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 4: check-prototype.ps1

**Files:**
- Create: `.claude/scripts/check-prototype.ps1`
- Test: `.claude/scripts/check-prototype.Tests.ps1`

**Interfaces:**
- Consumes: `ui/tokens.css` and `ui/components.css` from Task 3.
- Produces: `check-prototype.ps1 -Path <html> [-UiRoot <dir>] [-OverlayPath <css>]`, exit 0 when every rule passes and exit 1 listing each violation.

- [ ] **Step 1: Write the failing tests**

Create `.claude/scripts/check-prototype.Tests.ps1`:

```powershell
# Dependency-free test harness for check-prototype.ps1
$ErrorActionPreference = 'Stop'
$script:Failures = 0
$ScriptUnderTest = Join-Path $PSScriptRoot 'check-prototype.ps1'
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Assert-Equal {
    param([string]$Expected, [string]$Actual, [string]$Because)
    if ($Expected -ne $Actual) {
        Write-Host "FAIL: $Because" -ForegroundColor Red
        Write-Host "  expected: <$Expected>"
        Write-Host "  actual:   <$Actual>"
        $script:Failures++
    } else {
        Write-Host "PASS: $Because" -ForegroundColor Green
    }
}

$root = Join-Path ([System.IO.Path]::GetTempPath()) ("protochk_" + [guid]::NewGuid().ToString('N'))
$ui   = Join-Path $root 'ui'
New-Item -ItemType Directory -Force -Path $ui | Out-Null

$TOKENS = ":root {`n  --pri: #ffcb1d;`n  --ink: #1d1826;`n  --sp-md: 16px;`n}`n"
$COMP   = ".btn {`n  background: var(--pri);`n}`n.card {`n  color: var(--ink);`n}`n"
[IO.File]::WriteAllText((Join-Path $ui 'tokens.css'), $TOKENS, $Utf8NoBom)
[IO.File]::WriteAllText((Join-Path $ui 'components.css'), $COMP, $Utf8NoBom)

# Build a standalone.html the way the real inliner does: tokens.css verbatim, then
# components.css, then the markup.
function New-Prototype {
    param([string]$Name, [string]$ExtraCss = '', [string]$Body)
    $html = "<!doctype html><html><head><style>`n$TOKENS`n$COMP`n$ExtraCss`n</style></head><body>`n$Body`n</body></html>"
    $p = Join-Path $root $Name
    [IO.File]::WriteAllText($p, $html, $Utf8NoBom)
    return $p
}

function Invoke-Check {
    param([string]$Path)
    $out = & powershell -NoProfile -File $ScriptUnderTest -Path $Path -UiRoot $ui 2>&1
    return @{ Code = $LASTEXITCODE; Out = [string]$out }
}

# --- Test 1: a clean prototype passes
$clean = New-Prototype -Name 'clean.html' -Body '<button class="btn">Go</button><div class="card">Hi</div>'
$r = Invoke-Check -Path $clean
Assert-Equal '0' ([string]$r.Code) 'rule set passes a clean prototype'

# --- Test 2: rule 1 — external host in an @import
$ext = New-Prototype -Name 'ext.html' -ExtraCss '@import url("https://fonts.googleapis.com/css2?family=Open+Sans");' -Body '<button class="btn">Go</button>'
$r = Invoke-Check -Path $ext
Assert-Equal 'True' ([string]($r.Code -ne 0))             'external @import fails'
Assert-Equal 'True' ([string]($r.Out -match 'external'))  'external @import is reported as an external-host violation'

# --- Test 3: rule 1 — external host in a src attribute
$extSrc = New-Prototype -Name 'extsrc.html' -Body '<img src="https://cdn.example.com/a.png"><button class="btn">Go</button>'
$r = Invoke-Check -Path $extSrc
Assert-Equal 'True' ([string]($r.Code -ne 0)) 'external src attribute fails'

# --- Test 4: rule 2 — a raw hex outside the token block
$hex = New-Prototype -Name 'hex.html' -ExtraCss '.custom { color: #ff0000; }' -Body '<button class="btn">Go</button>'
$r = Invoke-Check -Path $hex
Assert-Equal 'True' ([string]($r.Code -ne 0))            'raw hex outside tokens.css fails'
Assert-Equal 'True' ([string]($r.Out -match '#ff0000'))  'the offending hex value is named'

# --- Test 5: rule 2 — a raw px outside the token block
$px = New-Prototype -Name 'px.html' -ExtraCss '.custom { padding: 13px; }' -Body '<button class="btn">Go</button>'
$r = Invoke-Check -Path $px
Assert-Equal 'True' ([string]($r.Code -ne 0)) 'raw px outside tokens.css fails'

# --- Test 6: rule 3 — an undefined custom property
$undef = New-Prototype -Name 'undef.html' -ExtraCss '.custom { color: var(--nope); }' -Body '<button class="btn">Go</button>'
$r = Invoke-Check -Path $undef
Assert-Equal 'True' ([string]($r.Code -ne 0))          'undefined var(--x) fails'
Assert-Equal 'True' ([string]($r.Out -match '--nope')) 'the undefined property is named'

# --- Test 7: rule 4 — a class absent from components.css
$badClass = New-Prototype -Name 'badclass.html' -Body '<button class="btn ghost-nonexistent">Go</button>'
$r = Invoke-Check -Path $badClass
Assert-Equal 'True' ([string]($r.Code -ne 0))                            'unknown class fails'
Assert-Equal 'True' ([string]($r.Out -match 'ghost-nonexistent'))        'the unported class is named'

# --- Test 8: rule 5 — an email address in the markup
$pii = New-Prototype -Name 'pii.html' -Body '<button class="btn">Go</button><p>contact rekybongso@gmail.com</p>'
$r = Invoke-Check -Path $pii
Assert-Equal 'True' ([string]($r.Code -ne 0))         'an email address fails the PII rule'
Assert-Equal 'True' ([string]($r.Out -match 'PII'))   'the PII rule is named in the output'

# --- Test 9: the token block must be inlined verbatim or rule 2 cannot be evaluated
$noTokens = Join-Path $root 'notokens.html'
[IO.File]::WriteAllText($noTokens, "<!doctype html><html><head><style>`n$COMP`n</style></head><body><button class=`"btn`">Go</button></body></html>", $Utf8NoBom)
$r = Invoke-Check -Path $noTokens
Assert-Equal 'True' ([string]($r.Code -ne 0))                        'a build that did not inline tokens.css verbatim fails'
Assert-Equal 'True' ([string]($r.Out -match 'inlined|verbatim'))     'the missing token block is explained'

# --- Test 10: an overlay may redefine a token but not introduce one
$overlayOk  = Join-Path $root 'ok.overlay.css'
$overlayBad = Join-Path $root 'bad.overlay.css'
[IO.File]::WriteAllText($overlayOk,  ":root { --pri: #4f46e5; }`n", $Utf8NoBom)
[IO.File]::WriteAllText($overlayBad, ":root { --brand-new: #4f46e5; }`n", $Utf8NoBom)
$okOut = & powershell -NoProfile -File $ScriptUnderTest -Path $clean -UiRoot $ui -OverlayPath $overlayOk 2>&1
Assert-Equal '0' ([string]$LASTEXITCODE) 'an overlay redefining an existing token passes'
$badOut = & powershell -NoProfile -File $ScriptUnderTest -Path $clean -UiRoot $ui -OverlayPath $overlayBad 2>&1
Assert-Equal 'True' ([string]($LASTEXITCODE -ne 0))                  'an overlay introducing a new token fails'
Assert-Equal 'True' ([string]([string]$badOut -match '--brand-new')) 'the newly introduced token is named'

Remove-Item -Recurse -Force $root -ErrorAction SilentlyContinue
if ($script:Failures -gt 0) { Write-Host "`n$($script:Failures) failure(s)" -ForegroundColor Red; exit 1 }
Write-Host "`nAll tests passed" -ForegroundColor Green
exit 0
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `powershell -NoProfile -File .claude/scripts/check-prototype.Tests.ps1`
Expected: FAIL — the script does not exist.

- [ ] **Step 3: Write the implementation**

Create `.claude/scripts/check-prototype.ps1`:

```powershell
<#
.SYNOPSIS
  Validate a built single-file prototype against the shared ui/ design system.

.DESCRIPTION
  Enforces ADR-0003 locally, mirroring the production repo's gate:no-raw-style and
  gate:css-vars-defined CI gates. Five rules: no external hosts, no raw style values
  outside the token files, every custom property resolves, every class exists in
  components.css, and no PII. Any violation exits 1.

.EXAMPLE
  powershell -File check-prototype.ps1 -Path design/foo/build/standalone.html
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Path,
    [string]$UiRoot,
    [string]$OverlayPath
)

$ErrorActionPreference = 'Stop'

function Read-Utf8Text {
    param([string]$P)
    return [IO.File]::ReadAllText($P, [System.Text.Encoding]::UTF8)
}

if (-not $UiRoot) { $UiRoot = Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) 'ui' }
if (-not (Test-Path -LiteralPath $Path))   { throw "prototype not found: $Path" }

$tokensPath = Join-Path $UiRoot 'tokens.css'
$compPath   = Join-Path $UiRoot 'components.css'
if (-not (Test-Path -LiteralPath $tokensPath)) { throw "ui/tokens.css not found at $tokensPath — run /sync-tokens first." }
if (-not (Test-Path -LiteralPath $compPath))   { throw "ui/components.css not found at $compPath — run /sync-tokens first." }

$html   = Read-Utf8Text -P $Path
$tokens = Read-Utf8Text -P $tokensPath
$comp   = Read-Utf8Text -P $compPath
$overlay = ''
if ($OverlayPath) {
    if (-not (Test-Path -LiteralPath $OverlayPath)) { throw "overlay not found: $OverlayPath" }
    $overlay = Read-Utf8Text -P $OverlayPath
}

$violations = @()

# --- Rule 1: no external hosts (Artifact CSP + self-contained requirement)
foreach ($m in [regex]::Matches($html, '(?i)(?:src|href)\s*=\s*["''][^"'']*?(https?://[^"''\s]+)')) {
    $violations += "external host: $($m.Groups[1].Value)"
}
foreach ($m in [regex]::Matches($html, '(?i)@import\s+(?:url\()?["'']?(https?://[^"''\s)]+)')) {
    $violations += "external host in @import: $($m.Groups[1].Value)"
}

# --- Locate the inlined token block so rules 2 and 3 can exclude it.
$tokenSpanStart = $html.IndexOf($tokens.Trim())
if ($tokenSpanStart -lt 0) {
    $violations += "ui/tokens.css was not inlined verbatim into this build — cannot evaluate the raw-style rule. Rebuild with the standard inliner."
    $outside = ''
} else {
    $outside = $html.Remove($tokenSpanStart, $tokens.Trim().Length)
}

# --- Rule 2: no raw style values outside the token files
if ($tokenSpanStart -ge 0) {
    $scan = $outside
    if ($overlay) { $scan = $scan.Replace($overlay.Trim(), '') }
    foreach ($m in [regex]::Matches($scan, '(?<![&\w])#([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})\b')) {
        $violations += "raw hex outside tokens.css: $($m.Value)"
    }
    foreach ($m in [regex]::Matches($scan, '(?<![\w.-])\d+px\b')) {
        $violations += "raw px outside tokens.css: $($m.Value)"
    }
}

# --- Collect defined custom properties from tokens.css plus any overlay
$defined = @{}
foreach ($m in [regex]::Matches($tokens, '(?m)^\s*(--[A-Za-z0-9-]+)\s*:')) { $defined[$m.Groups[1].Value] = $true }
$baseDefined = @{} + $defined
foreach ($m in [regex]::Matches($overlay, '(?m)^\s*(--[A-Za-z0-9-]+)\s*:')) {
    $name = $m.Groups[1].Value
    if (-not $baseDefined.ContainsKey($name)) {
        $violations += "overlay introduces a new token '$name' — an overlay may redefine an existing token but never introduce one"
    }
    $defined[$name] = $true
}

# --- Rule 3: every var(--x) resolves
foreach ($m in [regex]::Matches($html, 'var\(\s*(--[A-Za-z0-9-]+)')) {
    $name = $m.Groups[1].Value
    if (-not $defined.ContainsKey($name)) { $violations += "undefined custom property: $name" }
}

# --- Rule 4: every class used in the markup exists in components.css
$known = @{}
foreach ($m in [regex]::Matches($comp, '\.([A-Za-z][A-Za-z0-9_-]*)')) { $known[$m.Groups[1].Value] = $true }
foreach ($m in [regex]::Matches($html, '(?i)class\s*=\s*["'']([^"'']*)["'']')) {
    foreach ($cls in ($m.Groups[1].Value -split '\s+')) {
        if ($cls -and -not $known.ContainsKey($cls)) {
            $violations += "class not in components.css: .$cls (unported component, or a typo)"
        }
    }
}

# --- Rule 5: no PII. A lint, not a guarantee — human review is still required.
foreach ($m in [regex]::Matches($html, '(?i)\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b')) {
    $violations += "PII: email address '$($m.Value)'"
}

$unique = $violations | Select-Object -Unique
if ($unique.Count -gt 0) {
    Write-Host "check-prototype FAILED for $Path" -ForegroundColor Red
    $unique | ForEach-Object { Write-Host "  - $_" }
    Write-Host "`n$($unique.Count) violation(s)"
    exit 1
}

Write-Host "check-prototype PASSED for $Path" -ForegroundColor Green
exit 0
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `powershell -NoProfile -File .claude/scripts/check-prototype.Tests.ps1`
Expected: PASS — all assertions green, exit 0.

- [ ] **Step 5: Commit**

```bash
git add .claude/scripts/check-prototype.ps1 .claude/scripts/check-prototype.Tests.ps1
git -c user.email=rekybongso@gmail.com -c user.name="Claude Code" commit -m "feat: add check-prototype gate enforcing ADR-0003 locally

Five rules: no external hosts, no raw style values outside the token
files, every custom property resolves, every class exists in
components.css, and no email addresses.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 5: Component catalogue and seed behaviors

**Files:**
- Create: `ui/COMPONENTS.md`
- Create: `ui/behaviors.js`

**Interfaces:**
- Consumes: `ui/components.css` from Task 3 (the class contract).
- Produces: `ui/behaviors.js` exposing a single global `RndUI.init(root)` that wires every ported behavior inside `root` (defaults to `document`). Phase 3's `/design-prototype` calls it once on `DOMContentLoaded`.

- [ ] **Step 1: Write the catalogue**

Create `ui/COMPONENTS.md`. It must list **all 42** upstream components with an explicit status. Derive the class contract for each from `ui/components.css`. Use exactly this table shape, and mark the 19 no-JS components as `CSS-only` and the 4 seeded in Step 2 as `ported`; every other stateful component is `not yet ported`.

```markdown
# ui/ component catalogue

Class contracts mirrored from the production repo's `apps/web/components/ui/`. Prototype
markup uses the same classes the React components emit, so
`<button class="btn pri">` renders identically to `<Button variant="pri">`.

**Port on demand.** A component marked `not yet ported` has working CSS but no
behavior. `/design-prototype` must STOP when a PRD calls for one rather than
improvising a lookalike — improvisation is what produced the `--sub` / `--mut`
divergence this library exists to end.

| Component | Class contract | Behavior | Status |
|---|---|---|---|
| Button | `.btn` + `pri` \| `ghost` \| `dark` \| `subtle` + `block` | none | CSS-only |
| Card | `.card` | none | CSS-only |
| Tabs | `.tabs` > `.tab[data-state=active]`, `.tab-panel` | `RndUI.initTabs` | ported |
| Accordion | `.accordion-item` > `.accordion-trigger[data-state]`, `.accordion-content[data-state]` | `RndUI.initAccordion` | ported |
| Dialog | `.dialog-overlay`, `.dialog-panel`, `.dialog-x` | `RndUI.initDialog` | ported |
| Toast | `.toast-viewport` > `.toast-root`, `.toast-close` | `RndUI.initToast` | ported |
```

The example above shows 6 of the 42 rows. Add the remaining 36, one row each, filling
the **Class contract** column by grepping the component's classes out of
`ui/components.css` — for example `grep -oE '^\.badge[A-Za-z0-9_-]*' ui/components.css | sort -u`
yields Badge's contract (`.badge` plus the `badge-danger` / `badge-info` /
`badge-neutral` / `badge-purple` / `badge-success` / `badge-warning` / `badge-dot`
modifiers). Every row's contract must come from that file, never from memory.

The three status values are fixed and exhaustive:

- **`CSS-only`** (19, Behavior column = `none`): Alert, Badge, Breadcrumb, Button, Card,
  Chip, EmptyState, ErrorState, Field, Hero, List, LoadingState, Row, Sidebar, Spinner,
  Stat, StrengthMeter, Text, Textarea.
- **`ported`** (4): Tabs, Accordion, Dialog, Toast — the four in the example table.
- **`not yet ported`** (19, Behavior column = `—`): AlertDialog, Avatar, Checkbox,
  Command, DobPicker, Drawer, Input, Menu, Pagination, PasswordInput, Popover, Progress,
  RadioGroup, Select, Slider, Switch, Table, ThemeToggle, Tooltip.

19 + 4 + 19 = 42, the full component set. Note that `apps/web/components/ui/` holds 44
files: these 42 `.tsx` components plus two helpers, `cx.ts` and `index.ts`, which are
not components and get no row.

- [ ] **Step 2: Write the seed behaviors**

Create `ui/behaviors.js`:

```javascript
/* Vanilla behavior for the ported ui/ components. The class and data-state contract
   mirrors the production React components, so markup written against components.css
   behaves the same here. Components absent from this file are listed as
   "not yet ported" in COMPONENTS.md — do not improvise a replacement. */
(function (global) {
  'use strict';

  function all(root, sel) { return Array.prototype.slice.call(root.querySelectorAll(sel)); }

  function initTabs(root) {
    all(root, '.tabs').forEach(function (group) {
      var tabs = all(group, '.tab');
      tabs.forEach(function (tab) {
        tab.addEventListener('click', function () {
          tabs.forEach(function (t) {
            t.setAttribute('data-state', t === tab ? 'active' : 'inactive');
            t.classList.toggle('on', t === tab);
            t.setAttribute('aria-selected', t === tab ? 'true' : 'false');
          });
          var panelId = tab.getAttribute('aria-controls');
          if (!panelId) return;
          var scope = group.parentNode || root;
          all(scope, '.tab-panel').forEach(function (p) {
            p.hidden = p.id !== panelId;
          });
        });
      });
    });
  }

  function initAccordion(root) {
    all(root, '.accordion-trigger').forEach(function (trigger) {
      trigger.addEventListener('click', function () {
        var item = trigger.closest('.accordion-item') || trigger.parentNode;
        var content = item.querySelector('.accordion-content');
        var isOpen = trigger.getAttribute('data-state') === 'open';
        var next = isOpen ? 'closed' : 'open';
        trigger.setAttribute('data-state', next);
        trigger.setAttribute('aria-expanded', isOpen ? 'false' : 'true');
        if (content) { content.setAttribute('data-state', next); }
      });
    });
  }

  function initDialog(root) {
    function focusables(panel) {
      return all(panel, 'a[href],button:not([disabled]),input:not([disabled]),select,textarea,[tabindex]:not([tabindex="-1"])');
    }
    function close(overlay) {
      overlay.setAttribute('data-state', 'closed');
      overlay.hidden = true;
      if (overlay.__lastFocus) { overlay.__lastFocus.focus(); }
    }
    all(root, '.dialog-overlay').forEach(function (overlay) {
      var panel = overlay.querySelector('.dialog-panel');
      all(overlay, '.dialog-x').forEach(function (x) {
        x.addEventListener('click', function () { close(overlay); });
      });
      overlay.addEventListener('click', function (e) {
        if (e.target === overlay) { close(overlay); }
      });
      overlay.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') { close(overlay); return; }
        if (e.key !== 'Tab' || !panel) { return; }
        var items = focusables(panel);
        if (!items.length) { return; }
        var first = items[0], last = items[items.length - 1];
        if (e.shiftKey && document.activeElement === first) { e.preventDefault(); last.focus(); }
        else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first.focus(); }
      });
    });
    all(root, '[data-dialog-open]').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var overlay = document.getElementById(btn.getAttribute('data-dialog-open'));
        if (!overlay) { return; }
        overlay.__lastFocus = btn;
        overlay.hidden = false;
        overlay.setAttribute('data-state', 'open');
        var panel = overlay.querySelector('.dialog-panel');
        var items = panel ? focusables(panel) : [];
        if (items.length) { items[0].focus(); } else if (panel) { panel.focus(); }
      });
    });
  }

  function initToast(root) {
    all(root, '.toast-close').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var toast = btn.closest('.toast-root');
        if (toast && toast.parentNode) { toast.parentNode.removeChild(toast); }
      });
    });
  }

  function init(root) {
    var scope = root || document;
    initTabs(scope);
    initAccordion(scope);
    initDialog(scope);
    initToast(scope);
  }

  global.RndUI = {
    init: init,
    initTabs: initTabs,
    initAccordion: initAccordion,
    initDialog: initDialog,
    initToast: initToast
  };
})(this);
```

- [ ] **Step 3: Verify the catalogue is complete**

Run:
```bash
grep -c '^| ' ui/COMPONENTS.md          # expect 44 (42 components + header + separator)
grep -c 'not yet ported' ui/COMPONENTS.md  # expect 19
grep -c 'CSS-only' ui/COMPONENTS.md        # expect 19
grep -c '| ported |' ui/COMPONENTS.md      # expect 4
```
Expected: exactly those counts. If any differs, a component is missing or double-counted — fix the table, not the expectation.

- [ ] **Step 4: Verify behaviors.js parses**

Run: `node --check ui/behaviors.js`
Expected: no output, exit 0.

- [ ] **Step 5: Commit**

```bash
git add ui/COMPONENTS.md ui/behaviors.js
git -c user.email=rekybongso@gmail.com -c user.name="Claude Code" commit -m "feat: add component catalogue and seed behaviors

All 42 upstream components catalogued with explicit port status. Tabs,
Accordion, Dialog, and Toast are implemented; the other 19 stateful
components are marked not-yet-ported so /design-prototype stops rather
than improvising.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 6: Reference doc, the /sync-tokens command, and gitignore

**Files:**
- Create: `.claude/references/design-system.md`
- Create: `.claude/commands/sync-tokens.md`
- Create: `.agents/skills/sync-tokens/SKILL.md`
- Modify: `.gitignore`

**Interfaces:**
- Consumes: everything from Tasks 1–5.
- Produces: no code interface; this task makes the system discoverable and documented.

- [ ] **Step 1: Write the reference doc**

Create `.claude/references/design-system.md` with exactly these seven `##` sections, in this order:

1. `## Upstream source and the marker contract` — the repo URL, the `globals.css` path (noting the parentheses), the two marker prefixes, and the rule that `tokens.css` is byte-identical to the lines strictly between them. Source: spec §3.1.
2. `## Access constraints` — reproduce the four-row table (clone / raw URL / `git archive` / partial clone) verbatim from spec §3.2, including the note that only `--depth 1` works.
3. `## The ui/ layout` — the seven-file table from spec §3.3, marking which files are generated and which are hand-written.
4. `## The overlay rule` — an overlay may redefine an existing token name, never introduce one; source spec §3.4.
5. `## Disclosure boundary` — the committed / never-committed lists from spec §3.6, naming `manifest.json` and the source repo's `.claude/` explicitly.
6. `## check-prototype rules` — the five numbered rules from spec §3.7, plus the caveat that the PII rule catches email addresses only and human review is still required.
7. `## Port on demand` — the policy from spec §3.3: `/design-prototype` stops on an unported component rather than improvising, and `COMPONENTS.md` is the status register.

Copy the numbers (166, 239, 2515, 133) verbatim from this plan's Global Constraints — do not paraphrase or recompute them. This file is the single source of truth, so `CLAUDE.md` and `README.md` link to it rather than restating it, exactly as `mobbin-sourcing.md` works.

- [ ] **Step 2: Write the command, in both trees**

The harness resolves `.agents/skills/`, but `.claude/commands/` is the documented tree — both must exist and agree, as they do for every other command in this repo.

Create `.claude/commands/sync-tokens.md`:

```markdown
---
description: Sync the production design tokens and component CSS into ui/, or check for drift.
argument-hint: [--check] [--ref <branch|sha>]
---

Sync `ui/` from the Solve Education production repo. Read
`.claude/references/design-system.md` first — it carries the marker contract, the
disclosure boundary, and the overlay rule.

1. **Parse arguments.** `--check` reports drift and writes nothing. `--ref <branch|sha>`
   selects the source ref; the default is `main`. `packages/tokens` carries no release
   tags upstream, so `main` is a moving target — prefer a pinned SHA when reproducibility
   matters.

2. **Run the script.**
   - Sync: `powershell -NoProfile -File .claude/scripts/sync-tokens.ps1`
   - Check: `powershell -NoProfile -File .claude/scripts/sync-tokens.ps1 -Check`
   - Pinned: `powershell -NoProfile -File .claude/scripts/sync-tokens.ps1 -Ref <sha>`

3. **Report.** Show the token diff the script prints (added / removed / changed). On a
   `--check` failure, show the drift and stop — do not sync as a "fix" unless the user
   asks, because a sync overwrites local `ui/` edits.

4. **Never** commit `manifest.json` or anything from the source repo's `.claude/`. The
   script already refuses to write them; if you see either under `ui/`, stop and report a
   disclosure-boundary breach.

The clone is about 29 MB and goes to the system temp folder, never into the workspace.
It is deleted when the script exits.
```

Create `.agents/skills/sync-tokens/SKILL.md` with the same body, and this frontmatter:

```markdown
---
name: sync-tokens
description: Sync the production design tokens and component CSS into ui/, or check for drift against the upstream source.
---
```

- [ ] **Step 3: Fix .gitignore**

`.gitignore` currently lists `.superpowers/` twice (lines 32 and 51 of the current file). Remove the second occurrence and its duplicate comment, then add:

```gitignore
# Generated single-file prototype builds (rebuild with build-standalone.ps1)
design/*/build/
```

- [ ] **Step 4: Verify**

Run:
```bash
grep -c '^\.superpowers/$' .gitignore                 # expect 1
git check-ignore -q design/foo/build/x.html && echo "build/ ignored"
test -f .agents/skills/sync-tokens/SKILL.md && echo "skill exists"
powershell -NoProfile -File .claude/scripts/sync-tokens.ps1 -Check
```
Expected: `1`, `build/ ignored`, `skill exists`, and the check reports in sync with the recorded SHA and exits 0.

- [ ] **Step 5: Run the whole suite**

Run:
```bash
powershell -NoProfile -File .claude/scripts/sync-tokens.Tests.ps1
powershell -NoProfile -File .claude/scripts/check-prototype.Tests.ps1
powershell -NoProfile -File .claude/scripts/md_visualize.Tests.ps1
```
Expected: all three print "All tests passed" and exit 0. The third confirms nothing in this plan broke the existing script.

- [ ] **Step 6: Commit**

```bash
git add .claude/references/design-system.md .claude/commands/sync-tokens.md .agents/skills/sync-tokens/SKILL.md .gitignore
git -c user.email=rekybongso@gmail.com -c user.name="Claude Code" commit -m "docs: add design-system reference and /sync-tokens command

Documents the marker contract, disclosure boundary, overlay rule, and the
five check-prototype rules in one place. Adds the command to both the
.claude/commands and .agents/skills trees, and dedupes .superpowers/ in
.gitignore.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Notes for the implementer

- **Do not adjust an expected number to match actual output.** Every count in this plan
  was measured against upstream commit `155341cd32d89de0e10eeaa5c2209ddf6bd80d1c`. If a
  count differs, upstream changed — report it rather than editing the expectation.
- **The tests must never hit the network.** Every test passes `-SourcePath`, which skips
  the clone branch entirely. If you find yourself adding a test that clones, stop.
- **Rule 2 of `check-prototype` depends on the build inlining `ui/tokens.css` verbatim.**
  That is deliberate: it makes a build that stops inlining fail loudly rather than
  silently skipping the raw-style check. Task 4's Test 9 covers exactly this.
- `check-prototype`'s PII rule catches email addresses only. It is a lint, not a
  guarantee, and the docs must say so — human review remains required before publishing.
