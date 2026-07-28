# Prototype Pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `/design-prototype` a design-project command that authors multi-file source in `src/` against `ui-library/`, and add `/export-prototype` to build that source into a gate-checked, publishable single file.

**Architecture:** Split the one command that used to do everything into **author** and **export**. `/design-prototype` writes `design/<project>/src/` from the project's `PRD.md`, linking the shared design system rather than hand-rolling styles. `/export-prototype` inlines that source into `design/<project>/build/standalone.html` via a new generalized PowerShell builder, runs `check-prototype.ps1` on the result, and only then — behind an explicit confirmation — publishes it as a claude.ai Artifact. The builder is driven by the markup's own `<link>` and `<script>` tags rather than hardcoded filenames, which is what makes it work for any project layout.

**Tech Stack:** PowerShell 5.1 (`powershell.exe`), dependency-free `.Tests.ps1` harnesses, Markdown command/skill definitions, the claude.ai `Artifact` tool.

## Global Constraints

Copied verbatim from the spec, `CLAUDE.md`, and this repo's established invariants. **Every task's requirements implicitly include this section.**

- **Scope of this plan is spec §5's tooling only** — the `/design-prototype` rework and `/export-prototype`. **Migrating `onboarding-solve-edu` and `ai-literacy-app` onto `ui-library/` is explicitly NOT in this plan** and gets its own. Nothing here may edit either project's prototype source.
- **`/design-prototype` becomes project-only** (user decision, 2026-07-28). It resolves a design project per `.claude/references/design-projects.md` and requires a `PRD.md`. The study-folder path, the `SPEC.md` fallback, and the `SYNTHESIS.md` fallback are all retired from this command.
- **Every command needs BOTH registrations** — `.claude/commands/<name>.md` *and* `.agents/skills/<name>/SKILL.md`, and their `description` lines must agree. Currently 18/18; this plan takes it to **19/19**.
- **`ui-library/` synced artifacts are read-only except via `/sync-tokens`** — `tokens.css`, `components.css`, `tokens.json`, and `TOKENS.md`'s `PROVENANCE` block. No task here may modify them.
- **Per-project divergence goes in `design/<project>/tokens.overlay.css`**, which may redefine an existing token name but never introduce a new one.
- **Port on demand, fail loudly** (spec §3.3) — `/design-prototype` must **STOP** when the PRD calls for a component `ui-library/COMPONENTS.md` marks `not yet ported`, rather than improvising a lookalike.
- **The upstream repo URL is never stored in this repo** — not in a file, a commit message, or a test fixture.
- **Commit identity:** `Claude Code` / `rekybongso@gmail.com`.
- **PowerShell 5.1 only.** No `&&` / `||` (use `;` + `if ($?)`), no ternary, no `??`. Do not redirect a native exe's stderr with `2>&1` under `$ErrorActionPreference = 'Stop'`. Keep script source **7-bit ASCII** — no smart quotes, em-dashes, or arrows in `.ps1` files.
- **Error-reporting convention for scripts** (established by `check-prototype.ps1`, see its `.NOTES`): report failures with `Write-Host` on **stdout** and signal only via a **non-zero exit code**. Never let a bare `throw` escape. Callers branch on `$LASTEXITCODE`, never on stderr content.
- **Output encoding:** UTF-8 **without** BOM, via `[IO.File]::WriteAllText($path, $text, [Text.UTF8Encoding]::new($false))`.

---

## File Structure

| File | Status | Responsibility |
|---|---|---|
| `.claude/scripts/build-prototype.ps1` | **Create** | Inline a project's multi-file `src/` into one self-contained HTML file. Pure build; no policy. |
| `.claude/scripts/build-prototype.Tests.ps1` | **Create** | Dependency-free test harness for the builder. |
| `.claude/commands/export-prototype.md` | **Create** | Build → gate → optionally publish. |
| `.agents/skills/export-prototype/SKILL.md` | **Create** | Paired registration for the above. |
| `.claude/commands/design-prototype.md` | **Modify** | Retarget to a design project; author `src/`; stop publishing. |
| `.agents/skills/design-prototype/SKILL.md` | **Modify** | Same, condensed. |
| `.claude/personas/principal-designer.md` | **Modify** (Mode T, from line 184) | Judge a project prototype against its PRD and the design system; drop the study branch. |
| `.claude/references/design-projects.md` | **Modify** ("How the commands touch this", from line 109) | Add both commands to the contract. |
| `CLAUDE.md` | **Modify** | Move `/design-prototype` to the design table; add `/export-prototype`. |
| `README.md` | **Modify** | Same; replace the placeholder note at line 314. |
| `GEMINI.md` | **Modify** | Skill count 18 → 19 (lines 5, 267); extend §7. |

**Deliberately NOT touched:** `design/onboarding-solve-edu/build-standalone.ps1` stays where it is and keeps working until the migration plan retires it. `ui-library/*`. Anything under `research/`.

---

### Task 1: The generalized builder

Build `design/<project>/build/standalone.html` from a project's multi-file source. Driven by the markup's own tags, so it works for `src/index.html` and for legacy layouts alike.

**Files:**
- Create: `.claude/scripts/build-prototype.ps1`
- Test: `.claude/scripts/build-prototype.Tests.ps1`

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces — the contract Task 2 depends on:
  - Invocation: `powershell -NoProfile -File .claude/scripts/build-prototype.ps1 -ProjectPath <design/slug> [-EntryPath <file>] [-Out <file>]`
  - `-ProjectPath` **(mandatory)** — the project folder.
  - `-EntryPath` — defaults to `<ProjectPath>/src/index.html`.
  - `-Out` — defaults to `<ProjectPath>/build/standalone.html`; parent directory is created if absent.
  - **Exit 0** on success, printing exactly one line: `Built <absolute-out-path>`.
  - **Non-zero** on any failure, with the reason on stdout and **no output file written**.

**Behaviour to implement (the rules the tests below pin down):**

1. `<link rel="stylesheet" href="X">` is replaced by `<style>` + the file's verbatim contents + `</style>`.
2. `<script src="Y"></script>` is replaced by `<script>` + the file's verbatim contents + `</script>`.
3. An **external** `href`/`src` (`http:`, `https:`, or protocol-relative `//host/…`) is a **hard failure** — the builder cannot inline it, so it cannot do its job. Local-only is also required by `check-prototype.ps1` rule 1.
4. A **missing** local `href`/`src` target is a hard failure naming the path.
5. Image references (`.png .jpg .jpeg .gif .webp .svg`) in attribute or `url()` position become `data:` URIs. Resolution base is **the file the reference came from** — the entry HTML for markup, the stylesheet's own folder for CSS. A missing *relative* image is a hard failure naming it.
6. **Root-absolute paths (`/…`) are left untouched, not an error.** `ui-library/components.css` ships `url("/brand/logo-icon.svg")`, a production asset-pipeline path documented in `COMPONENTS.md` as intentionally unresolvable. This exception is also what keeps the synced stylesheets **byte-for-byte verbatim** in the output, which `check-prototype.ps1` rule 2 requires in order to run at all.
7. External image URLs are likewise passed through untouched. Policy on external hosts belongs to `check-prototype.ps1` rule 1 — one owner, not two.

- [ ] **Step 1: Write the failing test file**

Create `.claude/scripts/build-prototype.Tests.ps1`. Model the harness on `check-prototype.Tests.ps1` (same `Assert-Equal`, same temp-root pattern, same UTF-8-no-BOM writer).

```powershell
# Dependency-free test harness for build-prototype.ps1
$ErrorActionPreference = 'Stop'
$script:Failures = 0
$ScriptUnderTest = Join-Path $PSScriptRoot 'build-prototype.ps1'
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

$root = Join-Path ([System.IO.Path]::GetTempPath()) ("protobuild_" + [guid]::NewGuid().ToString('N'))

# A 1x1 transparent PNG, so image tests use real bytes rather than a text stub.
$PNG_B64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=='

function New-Project {
    param([string]$Name)
    $p   = Join-Path $root $Name
    $src = Join-Path $p 'src'
    New-Item -ItemType Directory -Force -Path $src | Out-Null
    return $p
}

function Write-File {
    param([string]$Path, [string]$Text)
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [IO.File]::WriteAllText($Path, $Text, $Utf8NoBom)
}

function Invoke-Build {
    param([string]$ProjectPath, [string]$EntryPath, [string]$Out)
    $a = @('-NoProfile', '-File', $ScriptUnderTest, '-ProjectPath', $ProjectPath)
    if ($EntryPath) { $a += @('-EntryPath', $EntryPath) }
    if ($Out)       { $a += @('-Out', $Out) }
    $o = & powershell @a
    return @{ Code = $LASTEXITCODE; Out = [string]$o }
}
```

- [ ] **Step 2: Add tests 1-4 (the happy path and the defaults)**

Append to the same file:

```powershell
# --- Test 1: a minimal project inlines its CSS and JS into one file.
$p1 = New-Project 'p1'
Write-File (Join-Path $p1 'src\index.html') '<!doctype html><html><head><link rel="stylesheet" href="app.css"></head><body><div class="x"></div><script src="app.js"></script></body></html>'
Write-File (Join-Path $p1 'src\app.css')    '.x { color: var(--ink); }'
Write-File (Join-Path $p1 'src\app.js')     'window.BUILT = true;'
$r1  = Invoke-Build -ProjectPath $p1
$o1  = Join-Path $p1 'build\standalone.html'
Assert-Equal '0'    ([string]$r1.Code)                                  'a minimal project builds with exit 0'
Assert-Equal 'True' ([string](Test-Path -LiteralPath $o1))              'the default output lands at build/standalone.html'
$t1 = [IO.File]::ReadAllText($o1)
Assert-Equal 'True'  ([string]($t1 -match '\.x \{ color: var\(--ink\); \}')) 'the stylesheet contents are inlined'
Assert-Equal 'True'  ([string]($t1 -match 'window\.BUILT = true;'))          'the script contents are inlined'
Assert-Equal 'False' ([string]($t1 -match '<link'))                          'no <link> tag survives the build'
Assert-Equal 'False' ([string]($t1 -match 'src="app\.js"'))                  'no external script src survives the build'

# --- Test 2: -Out overrides the default location.
$alt = Join-Path $root 'elsewhere\custom.html'
$r2  = Invoke-Build -ProjectPath $p1 -Out $alt
Assert-Equal '0'    ([string]$r2.Code)                        '-Out builds with exit 0'
Assert-Equal 'True' ([string](Test-Path -LiteralPath $alt))   '-Out writes to the given path, creating its folder'

# --- Test 3: the success line names the output file.
Assert-Equal 'True' ([string]($r1.Out -match 'Built .*standalone\.html')) 'success prints the built path'

# --- Test 4: the build is deterministic - same input, same bytes.
$first = [IO.File]::ReadAllBytes($o1)
Invoke-Build -ProjectPath $p1 | Out-Null
$second = [IO.File]::ReadAllBytes($o1)
Assert-Equal ([Convert]::ToBase64String($first)) ([Convert]::ToBase64String($second)) 'rebuilding produces byte-identical output'
```

- [ ] **Step 3: Add tests 5-9 (the loud failures)**

```powershell
# --- Test 5: a missing entry file fails and names the path it expected.
$p5 = New-Project 'p5'
$r5 = Invoke-Build -ProjectPath $p5
Assert-Equal 'True'  ([string]($r5.Code -ne 0))                                      'a missing entry file exits non-zero'
Assert-Equal 'True'  ([string]($r5.Out -match 'index\.html'))                        'the failure names the entry file it looked for'
Assert-Equal 'False' ([string](Test-Path -LiteralPath (Join-Path $p5 'build\standalone.html'))) 'a failed build writes no output'

# --- Test 6: a missing stylesheet fails and names it.
$p6 = New-Project 'p6'
Write-File (Join-Path $p6 'src\index.html') '<html><head><link rel="stylesheet" href="gone.css"></head><body></body></html>'
$r6 = Invoke-Build -ProjectPath $p6
Assert-Equal 'True'  ([string]($r6.Code -ne 0))                'a missing stylesheet exits non-zero'
Assert-Equal 'True'  ([string]($r6.Out -match 'gone\.css'))    'the failure names the missing stylesheet'

# --- Test 7: a missing script fails and names it.
$p7 = New-Project 'p7'
Write-File (Join-Path $p7 'src\index.html') '<html><body><script src="gone.js"></script></body></html>'
$r7 = Invoke-Build -ProjectPath $p7
Assert-Equal 'True' ([string]($r7.Code -ne 0))             'a missing script exits non-zero'
Assert-Equal 'True' ([string]($r7.Out -match 'gone\.js'))  'the failure names the missing script'

# --- Test 8: an external stylesheet cannot be inlined, so it is a hard failure.
$p8 = New-Project 'p8'
Write-File (Join-Path $p8 'src\index.html') '<html><head><link rel="stylesheet" href="https://cdn.example.com/x.css"></head><body></body></html>'
$r8 = Invoke-Build -ProjectPath $p8
Assert-Equal 'True' ([string]($r8.Code -ne 0))                    'an external stylesheet exits non-zero'
Assert-Equal 'True' ([string]($r8.Out -match 'cdn\.example\.com')) 'the failure names the external host'

# --- Test 9: a protocol-relative script src is external too.
$p9 = New-Project 'p9'
Write-File (Join-Path $p9 'src\index.html') '<html><body><script src="//cdn.example.com/x.js"></script></body></html>'
$r9 = Invoke-Build -ProjectPath $p9
Assert-Equal 'True' ([string]($r9.Code -ne 0)) 'a protocol-relative script src exits non-zero'
```

- [ ] **Step 4: Add tests 10-14 (assets, and the verbatim guarantee)**

```powershell
# --- Test 10: a relative image becomes a data: URI.
$p10 = New-Project 'p10'
Write-File (Join-Path $p10 'src\index.html') '<html><body><img src="img/a.png"></body></html>'
[IO.File]::WriteAllBytes((Join-Path $p10 'src\img\a.png'), [Convert]::FromBase64String($PNG_B64))
$r10 = Invoke-Build -ProjectPath $p10
$t10 = [IO.File]::ReadAllText((Join-Path $p10 'build\standalone.html'))
Assert-Equal '0'     ([string]$r10.Code)                            'a project with an image builds'
Assert-Equal 'True'  ([string]($t10 -match 'data:image/png;base64,')) 'the image is base64-inlined'
Assert-Equal 'False' ([string]($t10 -match 'src="img/a\.png"'))       'the original image path is gone'

# --- Test 11: a missing relative image is a hard failure.
$p11 = New-Project 'p11'
Write-File (Join-Path $p11 'src\index.html') '<html><body><img src="img/missing.png"></body></html>'
$r11 = Invoke-Build -ProjectPath $p11
Assert-Equal 'True' ([string]($r11.Code -ne 0))                 'a missing image exits non-zero'
Assert-Equal 'True' ([string]($r11.Out -match 'missing\.png'))  'the failure names the missing image'

# --- Test 12: a root-absolute asset path is left alone, NOT an error. This is what
# lets ui-library/components.css (which ships url("/brand/logo-icon.svg")) pass through.
$p12 = New-Project 'p12'
Write-File (Join-Path $p12 'src\index.html') '<html><head><link rel="stylesheet" href="ui.css"></head><body></body></html>'
Write-File (Join-Path $p12 'src\ui.css')     '.logo { background: url("/brand/logo-icon.svg") no-repeat; }'
$r12 = Invoke-Build -ProjectPath $p12
$t12 = [IO.File]::ReadAllText((Join-Path $p12 'build\standalone.html'))
Assert-Equal '0'    ([string]$r12.Code)                                    'a root-absolute asset path does not fail the build'
Assert-Equal 'True' ([string]($t12 -match 'url\("/brand/logo-icon\.svg"\)')) 'a root-absolute asset path is left untouched'

# --- Test 13: an inlined stylesheet survives byte-for-byte. check-prototype.ps1 rule 2
# skips itself entirely unless it finds tokens.css and components.css inlined verbatim,
# so this guarantee is load-bearing, not cosmetic.
$p13 = New-Project 'p13'
$VERBATIM = ":root {`n  --pri: #ffcb1d;`n  --ink: #1d1826;`n}`n.logo { background: url(`"/brand/logo-icon.svg`"); }`n"
Write-File (Join-Path $p13 'src\index.html') '<html><head><link rel="stylesheet" href="tokens.css"></head><body></body></html>'
Write-File (Join-Path $p13 'src\tokens.css') $VERBATIM
Invoke-Build -ProjectPath $p13 | Out-Null
$t13 = [IO.File]::ReadAllText((Join-Path $p13 'build\standalone.html'))
Assert-Equal 'True' ([string]($t13.Contains($VERBATIM))) 'an inlined stylesheet appears verbatim in the output'

# --- Test 14: a CSS url() resolves against the STYLESHEET's folder, not the entry HTML's.
# The two differ whenever CSS lives in a subfolder, and getting this wrong silently
# inlines the wrong file or fails a build that should succeed.
$p14 = New-Project 'p14'
Write-File (Join-Path $p14 'src\index.html')     '<html><head><link rel="stylesheet" href="css/app.css"></head><body></body></html>'
Write-File (Join-Path $p14 'src\css\app.css')    '.h { background: url("pix/b.png"); }'
[IO.File]::WriteAllBytes((Join-Path $p14 'src\css\pix\b.png'), [Convert]::FromBase64String($PNG_B64))
$r14 = Invoke-Build -ProjectPath $p14
$t14 = [IO.File]::ReadAllText((Join-Path $p14 'build\standalone.html'))
Assert-Equal '0'    ([string]$r14.Code)                             'a CSS-relative asset resolves against the stylesheet folder'
Assert-Equal 'True' ([string]($t14 -match 'data:image/png;base64,')) 'the CSS-relative image is inlined'

# --- Test 15: output is UTF-8 with no BOM.
$bytes15 = [IO.File]::ReadAllBytes((Join-Path $p1 'build\standalone.html'))
$hasBom  = ($bytes15.Length -ge 3 -and $bytes15[0] -eq 0xEF -and $bytes15[1] -eq 0xBB -and $bytes15[2] -eq 0xBF)
Assert-Equal 'False' ([string]$hasBom) 'the built file has no UTF-8 BOM'

# --- Cleanup + summary
Remove-Item -Recurse -Force -LiteralPath $root -ErrorAction SilentlyContinue
Write-Host ''
if ($script:Failures -gt 0) { Write-Host "$($script:Failures) test(s) failed" -ForegroundColor Red; exit 1 }
Write-Host 'All tests passed' -ForegroundColor Green
exit 0
```

- [ ] **Step 5: Run the tests and confirm they fail for the right reason**

Run: `powershell -NoProfile -File .claude/scripts/build-prototype.Tests.ps1`
Expected: every test FAILs, and the failures are about `build-prototype.ps1` not existing — not about the harness itself erroring out.

- [ ] **Step 6: Write the builder**

Create `.claude/scripts/build-prototype.ps1`. Keep the source 7-bit ASCII.

```powershell
<#
.SYNOPSIS
  Build a design project's multi-file prototype source into one self-contained HTML file.

.DESCRIPTION
  Generalized from design/onboarding-solve-edu/build-standalone.ps1. Instead of
  hardcoding filenames, it is driven by the entry HTML's own tags, so it works for
  the src/index.html contract in .claude/references/design-projects.md and for
  legacy flat layouts alike.

    1. Every <link rel="stylesheet" href="..."> becomes an inline <style> block
       holding the file's VERBATIM contents.
    2. Every <script src="..."></script> becomes an inline <script> block.
    3. An external href/src (http:, https:, or protocol-relative //host/...) is a
       hard failure: the builder cannot inline it, so it cannot do its job. A
       missing local target is likewise a hard failure naming the path.
    4. Image references (.png .jpg .jpeg .gif .webp .svg) in attribute or url()
       position become data: URIs, resolved against the folder of the FILE THEY
       CAME FROM - the entry HTML for markup, the stylesheet's own folder for CSS.
       A missing relative image is a hard failure.
    5. Root-absolute paths (/...) are passed through untouched and are NOT an
       error. ui-library/components.css ships url("/brand/logo-icon.svg"), a
       production asset-pipeline path documented in COMPONENTS.md as intentionally
       unresolvable. This exception is also what keeps the synced stylesheets
       byte-for-byte verbatim in the output, which check-prototype.ps1 rule 2
       requires in order to run at all.
    6. External image URLs are passed through untouched. Policy on external hosts
       belongs to check-prototype.ps1 rule 1 - one owner for that rule, not two.

  This script builds; it does not judge. Run check-prototype.ps1 on the result.

.PARAMETER ProjectPath
  The design/<project> folder to build.

.PARAMETER EntryPath
  The entry HTML. Defaults to <ProjectPath>/src/index.html.

.PARAMETER Out
  The output file. Defaults to <ProjectPath>/build/standalone.html. Its parent
  directory is created if absent.

.NOTES
  Failures are reported on stdout via Write-Host and signaled only by a non-zero
  exit code, matching check-prototype.ps1 - see its .NOTES for why stderr is
  avoided under PowerShell 5.1. No output file is written on failure.

.EXAMPLE
  powershell -File build-prototype.ps1 -ProjectPath design/onboarding-solve-edu
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ProjectPath,
    [string]$EntryPath,
    [string]$Out
)

$ErrorActionPreference = 'Stop'

function Fail {
    param([string]$Message)
    Write-Host "build-prototype: $Message"
    exit 1
}

function Test-External {
    param([string]$Reference)
    if ($Reference -match '^//') { return $true }
    if ($Reference -match '^[A-Za-z][A-Za-z0-9+.-]*:') {
        if ($Reference -match '^(?i)data:') { return $false }
        return $true
    }
    return $false
}

function Resolve-Ref {
    param([string]$Reference, [string]$BaseDir)
    return (Join-Path $BaseDir ($Reference -replace '/', '\'))
}

# --- Resolve inputs -------------------------------------------------------
if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) {
    Fail "project folder not found: $ProjectPath"
}
$projectFull = (Resolve-Path -LiteralPath $ProjectPath).Path

if (-not $EntryPath) { $EntryPath = Join-Path $projectFull 'src\index.html' }
if (-not (Test-Path -LiteralPath $EntryPath -PathType Leaf)) {
    Fail "entry file not found: $EntryPath"
}
$entryFull = (Resolve-Path -LiteralPath $EntryPath).Path
$entryDir  = Split-Path -Parent $entryFull

if (-not $Out) { $Out = Join-Path $projectFull 'build\standalone.html' }

# --- Asset inlining -------------------------------------------------------
# Skips data:, http(s):, protocol-relative, fragment, and root-absolute paths.
$assetPattern = '(?<=["''(])(?<path>(?!data:|https?:|//|#|/)[^"''()]+?\.(?:png|jpe?g|gif|webp|svg))(?=["'')])'

function Convert-Assets {
    param([string]$Text, [string]$BaseDir, [string]$Origin)
    return [regex]::Replace($Text, $assetPattern, {
        param($match)
        $rel  = $match.Groups['path'].Value
        $path = Resolve-Ref -Reference $rel -BaseDir $BaseDir
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            Write-Host "build-prototype: asset not found: $rel (referenced from $Origin)"
            exit 1
        }
        $ext = [IO.Path]::GetExtension($path).ToLowerInvariant()
        $mime = switch ($ext) {
            '.png'  { 'image/png' }
            '.jpg'  { 'image/jpeg' }
            '.jpeg' { 'image/jpeg' }
            '.gif'  { 'image/gif' }
            '.webp' { 'image/webp' }
            '.svg'  { 'image/svg+xml' }
            default {
                Write-Host "build-prototype: unsupported image type: $ext"
                exit 1
            }
        }
        $bytes = [IO.File]::ReadAllBytes($path)
        return "data:$mime;base64,$([Convert]::ToBase64String($bytes))"
    })
}

# --- Inline stylesheets ---------------------------------------------------
$html = [IO.File]::ReadAllText($entryFull, [Text.Encoding]::UTF8)

$linkPattern = '<link\b[^>]*\brel\s*=\s*["'']stylesheet["''][^>]*>'
$html = [regex]::Replace($html, $linkPattern, {
    param($match)
    $tag = $match.Value
    if ($tag -notmatch 'href\s*=\s*["''](?<href>[^"'']+)["'']') {
        Write-Host "build-prototype: stylesheet link with no href: $tag"
        exit 1
    }
    $href = $matches['href']
    if (Test-External -Reference $href) {
        Write-Host "build-prototype: external stylesheet cannot be inlined: $href"
        exit 1
    }
    $path = Resolve-Ref -Reference $href -BaseDir $entryDir
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        Write-Host "build-prototype: stylesheet not found: $href"
        exit 1
    }
    $css = [IO.File]::ReadAllText($path, [Text.Encoding]::UTF8)
    $css = Convert-Assets -Text $css -BaseDir (Split-Path -Parent $path) -Origin $href
    return "<style>`r`n$css`r`n</style>"
})

# --- Inline scripts -------------------------------------------------------
$scriptPattern = '<script\b[^>]*\bsrc\s*=\s*["''](?<src>[^"'']+)["''][^>]*>\s*</script>'
$html = [regex]::Replace($html, $scriptPattern, {
    param($match)
    $src = $match.Groups['src'].Value
    if (Test-External -Reference $src) {
        Write-Host "build-prototype: external script cannot be inlined: $src"
        exit 1
    }
    $path = Resolve-Ref -Reference $src -BaseDir $entryDir
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        Write-Host "build-prototype: script not found: $src"
        exit 1
    }
    $js = [IO.File]::ReadAllText($path, [Text.Encoding]::UTF8)
    return "<script>`r`n$js`r`n</script>"
})

# --- Inline assets referenced by the markup itself ------------------------
$html = Convert-Assets -Text $html -BaseDir $entryDir -Origin (Split-Path -Leaf $entryFull)

# --- Write ----------------------------------------------------------------
$outDir = Split-Path -Parent $Out
if ($outDir -and -not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
}
[IO.File]::WriteAllText($Out, $html, [Text.UTF8Encoding]::new($false))
Write-Output "Built $((Resolve-Path -LiteralPath $Out).Path)"
exit 0
```

- [ ] **Step 7: Run the tests until green**

Run: `powershell -NoProfile -File .claude/scripts/build-prototype.Tests.ps1`
Expected: `All tests passed`, exit 0.

Two failure modes to expect and fix rather than work around:
- **`exit` inside a `MatchEvaluator` scriptblock may not terminate the parent.** If a failure test reports exit 0, refactor `Convert-Assets` and the two `[regex]::Replace` evaluators to collect errors into a `$script:Errors` list and check it after each pass, failing there instead.
- **`$matches` inside a scriptblock is scoped.** If the `href` extraction comes back empty, switch to `[regex]::Match($tag, ...)` and read `.Groups['href'].Value` explicitly.

- [ ] **Step 8: Prove it against a real project (read-only)**

The migration is out of scope, but the builder must be shown to work on real input.

Run:
```
powershell -NoProfile -File .claude/scripts/build-prototype.ps1 -ProjectPath design/onboarding-solve-edu -EntryPath design/onboarding-solve-edu/prototype-web.html -Out "$env:TEMP/proto-smoke.html"
```
Expected: exit 0 and a `Built …` line. Compare its size to the existing `design/onboarding-solve-edu/standalone.html` (~2.9 MB) — same order of magnitude means the asset inlining really ran.

**Do not** write into the project folder and **do not** commit the output. If it fails, that is a real finding: record it in the report; do not patch the project to suit the builder.

- [ ] **Step 9: Commit**

```bash
git add .claude/scripts/build-prototype.ps1 .claude/scripts/build-prototype.Tests.ps1
git commit -m "feat(scripts): add build-prototype.ps1, the generalized prototype builder"
```

---

### Task 2: `/export-prototype`

**Files:**
- Create: `.claude/commands/export-prototype.md`
- Create: `.agents/skills/export-prototype/SKILL.md`

**Interfaces:**
- Consumes: `build-prototype.ps1`'s CLI contract from Task 1.
- Produces: the command Task 3's final step hands off to. Its name and argument shape (`/export-prototype [project] [--artifact]`) are referenced by Task 3 and Task 4.

- [ ] **Step 1: Write the command file**

Create `.claude/commands/export-prototype.md`:

```markdown
---
description: Build a design project's src/ into build/standalone.html, run the local design gate, and — with --artifact — publish it to claude.ai after an explicit confirmation.
argument-hint: [project] [--artifact]
---

Turn a design project's **multi-file prototype source** into the **one file** you can
open, share, or publish. Where `/design-prototype` *authors* `src/`, this command
*ships* it: inline, gate, and (optionally) publish.

Splitting the two matters because they fail differently. Authoring fails on design
questions — a missing screen, an unported component. Exporting fails on mechanical ones
— a missing asset, a raw hex value, an unresolved token. Keeping them apart means a gate
failure never sends you back through a whole authoring pass.

## Arguments

- **`[project]`** (optional positional) — a design project slug or path. Resolved per
  `.claude/references/design-projects.md`; naming one adopts this terminal's binding.
- **`--artifact`** — after the gate passes, publish to claude.ai as an Artifact. Omitted,
  the command stops at a built, gate-checked local file.

## Steps

1. **Resolve the project.** Per `.claude/references/design-projects.md`: explicit
   argument (adopt the binding) → this terminal's binding → the sole `Status: Active`
   project → otherwise STOP, list what was found, and ask. Never create a project.

2. **Confirm there is something to export.** The entry file is
   `design/<project>/src/index.html`. If it is missing, STOP and tell the user to run
   `/design-prototype` first — there is no prototype source yet.

3. **Build.** Run:
   `powershell -NoProfile -File .claude/scripts/build-prototype.ps1 -ProjectPath design/<project>`
   On a non-zero exit, relay the builder's message verbatim and STOP. Its failures are
   concrete (a missing asset, an external link) and belong to the source, not to this
   command.

4. **Gate.** Run:
   `powershell -NoProfile -File .claude/scripts/check-prototype.ps1 -Path design/<project>/build/standalone.html`
   Add `-OverlayPath design/<project>/tokens.overlay.css` **if that file exists** —
   without it, every token the overlay redefines reads as unresolved.
   Branch on `$LASTEXITCODE`, never on output text. On a non-zero exit, report **every**
   violation (the script collects them all deliberately) and STOP.

   Read rule 2's caveat before declaring a pass: if `tokens.css` or `components.css`
   was not found inlined verbatim, the raw-value rule **did not run**. A gate that
   skipped its own rule is not a green gate — say so plainly rather than reporting
   "passed".

5. **Report the local result.** The built path, its size, and the gate outcome. Without
   `--artifact`, stop here — say where the file is and that it is publishable.

6. **`--artifact` only — PII and impersonation check.** Publishing is outward-facing.
   Re-check the built file for internal specifics (product / program / funder names),
   real people's names, avatars, emails, or account data, and confirm it does not
   impersonate a real organisation (generic-branded only). `check-prototype.ps1` rule 5
   catches email addresses and nothing else — it is a lint, not a guarantee. Anything
   found: STOP and report, do not publish.

7. **`--artifact` only — checkpoint.** Ask for explicit confirmation to publish, naming
   what will be published and that Artifacts start private. Proceed only on a clear yes.

8. **`--artifact` only — publish.** Copy the built file into the session scratchpad and
   publish it with the **Artifact** tool. Use a **stable file path per project** so a
   later export redeploys the **same URL** rather than minting a new one. Title = the
   project's `README.md` title + " Prototype". Keep the favicon stable across redeploys.
   If the project has been published before, pass its existing `url`.

9. **Update the log** in `design/<project>/README.md` with a dated status-log row: built,
   gate result, and the Artifact URL if one was published.

10. **Report** the built path, the gate outcome (including any rule that was skipped),
    and the Artifact URL if published.

## Guardrails

- `build/` is **gitignored** (`.gitignore`, `design/*/build/`). The built file is an
  artifact, not a source of truth — never commit it, and never hand-edit it. Fix `src/`
  and rebuild.
- **Never publish on a failed gate**, and never publish without the step-7 confirmation.
- A gate rule that could not run is **not** a rule that passed. Report the difference.
```

- [ ] **Step 2: Write the paired skill file**

Create `.agents/skills/export-prototype/SKILL.md`. Same content, condensed to
single-paragraph steps, command names **without** the leading slash (matching how the
other `.agents/skills/*/SKILL.md` files are written). The `description:` line must match
the command's **exactly**.

- [ ] **Step 3: Verify the registrations are paired and counted**

Run:
```bash
ls .claude/commands/*.md | wc -l; ls -d .agents/skills/*/ | wc -l
diff <(sed -n 's/^description: //p' .claude/commands/export-prototype.md) \
     <(sed -n 's/^description: //p' .agents/skills/export-prototype/SKILL.md)
```
Expected: `19` and `19`, and the `diff` produces no output.

- [ ] **Step 4: Commit**

```bash
git add .claude/commands/export-prototype.md .agents/skills/export-prototype/SKILL.md
git commit -m "feat(workflow): add /export-prototype to build, gate, and publish a prototype"
```

---

### Task 3: Retarget `/design-prototype` to a design project

**Files:**
- Modify: `.claude/commands/design-prototype.md` (whole file — the steps, the arguments block, the frontmatter `argument-hint`)
- Modify: `.agents/skills/design-prototype/SKILL.md` (same)
- Modify: `.claude/personas/principal-designer.md` (Mode T, from line 184)

**Interfaces:**
- Consumes: `/export-prototype` from Task 2 (the hand-off in the final step); the resolution rule in `.claude/references/design-projects.md`.
- Produces: `design/<project>/src/index.html`, `app.js`, `data.js`, and optional `img/` — the exact input contract Task 1's builder expects.

**What changes, and why each change:**

| Today | After | Why |
|---|---|---|
| Resolves a **study** folder | Resolves a **design project** | User decision, 2026-07-28. Matches discover → DECIDE → MAKE. |
| Soft gate: `PRD.md` > `SPEC.md` > `SYNTHESIS.md` | **Hard gate on `PRD.md`** | With the project-only scope there is no study to fall back to. Absent PRD → STOP, point at `/draft-prd`. |
| Token source: `lenses/tokens.md` > SPEC tokens > derived | `ui-library/tokens.css` + optional `tokens.overlay.css` | The design system is the vocabulary now; that is the whole point of Phase 1. |
| Writes one self-contained HTML file | Writes **multi-file `src/`** | Spec §5. Inlining is `/export-prototype`'s job. |
| Publishes the Artifact itself (steps 10-12) | **Does not publish** — hands off | One owner for the outward-facing action. |
| No component check | **STOPs on an unported component** | Spec §3.3. Improvisation is what produced the `--sub`/`--mut` divergence. |

- [ ] **Step 1: Rewrite the command's frontmatter and Arguments block**

`argument-hint` becomes `[project] [--fidelity lo|hi] [--gate name,…] [--scope moment]`.
The `description` becomes:

```
description: Author a design project's clickable prototype as multi-file source in src/, built from its PRD.md against the shared ui-library/ design system. Gated by the Principal Designer (Mode T); shipped by /export-prototype.
```

In **Arguments**, replace "Study folder (optional positional) — defaults to the active
research" with:

```markdown
- **`[project]`** (optional positional) — a design project slug or path, resolved per
  `.claude/references/design-projects.md`. Naming one adopts this terminal's binding.
```

Leave `--fidelity`, `--gate`, and `--scope` as they are — they describe design passes and
are unaffected by where the source comes from. Keep the Fidelity table and the
à-la-carte gate registry intact, with one edit: the `tokens` gate row's
"(prefers `lenses/tokens.md` if present)" becomes "(re-checks every value against
`ui-library/tokens.css` and the project overlay)".

- [ ] **Step 2: Replace steps 1-5 with the project-resolution and ground-truth steps**

```markdown
1. **Resolve the project.** Per `.claude/references/design-projects.md`: explicit
   `[project]` argument (adopt the binding) → this terminal's binding → the sole
   `Status: Active` project → otherwise STOP, list what was found, and ask. Never create
   a project; `/new-design` is the only command that does.

2. **Hard gate on the PRD.** `design/<project>/PRD.md` must exist. If it does not, STOP
   and tell the user to run `/draft-prd` first. This is deliberately harder than the old
   soft gate: a prototype with no decision doc behind it has nothing to be traceable to,
   and traceability is the first thing the Principal Designer judges.

3. **À-la-carte fast path.** If `--gate`/`--deepen` is present, run those named passes
   against the existing `src/`, then STOP after telling the user to run
   `/export-prototype` to rebuild and republish. If `src/index.html` does not exist yet,
   say so and STOP — there is nothing to deepen.

4. **Read the ground truth.** Read `PRD.md` in full — §7 Solution Shape (the Mermaid
   flow), §8 vertical slices, §9 acceptance criteria per slice, §11 Screens / IA / Empty
   States, §12 Modal Reference, and the **Prototype Element Dictionary** appendix. Read
   the project `README.md` for the title and `Informed by:`. For each study named there,
   read its `SYNTHESIS.md` — that is where the *evidence* behind a screen lives, and what
   lets the prototype cite real findings instead of asserting them.

5. **Context-lock (gates §0.1).** Restate, one line each:
   - **Tokens** — `ui-library/tokens.css`, plus `design/<project>/tokens.overlay.css` if
     it exists. There is no third source. If the design calls for a value neither
     provides, the answer is an overlay entry that **redefines an existing token name**,
     never a new name and never a raw value.
   - **Components** — `ui-library/components.css`, catalogued in
     `ui-library/COMPONENTS.md`.
   - **Screens** — the §11 list, verbatim.
   - **Definition of Done** — G1-G8.
   If any is missing, ask. Do not guess.

6. **Component availability check — STOP on an unported component.** Cross-check every
   entry in the PRD's Prototype Element Dictionary against `ui-library/COMPONENTS.md`.
   Any component whose **Status** is `not yet ported` has working CSS but **no
   behavior**. STOP. Report which components are unported and offer the three real
   options: port the behavior into `ui-library/behaviors.js` first, change the PRD to use
   a ported component, or scope the prototype to exclude that screen with `--scope`.
   **Do not improvise a lookalike** — improvisation is what produced the `--sub` / `--mut`
   divergence this library exists to end (spec §3.3).
```

- [ ] **Step 3: Replace the generation and hand-off steps**

```markdown
7. **Author the source (gates §1-2, 5-7).** Write, into `design/<project>/src/`:
   - `index.html` — the screens, linking the design system with relative paths:
     `<link rel="stylesheet" href="../../../ui-library/tokens.css">`, then
     `components.css`, then `../tokens.overlay.css` **last** if it exists, so a redefined
     token wins.
   - `app.js` — behavior. Import from `ui-library/behaviors.js` for any ported component
     rather than reimplementing it.
   - `data.js` — the sample data, shaped per PRD §13 Data Model.
   - `img/` — any local images.

   Tokens and component classes only: no raw hex, no raw px. Every screen traces to a §11
   entry and a §8 slice. All states (§6), specific load-bearing copy (§7), no dead-ends.
   Flag every extrapolation beyond the PRD as an assumption; do not present it as fact.
   Honour `--scope` and `--fidelity` if set.

8. **Self-audit against the DoD (gates §11.1, §9, §10).** Produce a G1-G8 gate table
   (pass/fail + evidence) and fix the fails. A hi-fi run includes a11y (§9) and
   responsive (§10); a lo-fi run runs the structure subset only and says so.

9. **Local gate, as a fast check.** Run `/export-prototype` **without** `--artifact` to
   build and gate the source now. Rule 2 (no raw style values) and rule 3 (every
   `var(--x)` resolves) will catch mechanical slips far faster than a review pass will.
   Fix anything it reports and re-run before going further.

10. **Principal Designer review — Mode T.** Dispatch the Principal Designer as a subagent
    (Agent tool, `general-purpose`) in **Mode T**, handing it
    `.claude/personas/principal-designer.md`, the authored `src/` files, the gate table,
    the `check-prototype.ps1` result, `PRD.md`, the project `README.md`, and the
    `SYNTHESIS.md` of each study in `Informed by:`. It returns **ready / revise /
    reject**. Address its points; re-run if it said *reject*. Relay the verdict.

11. **PII / guardrail gate.** Re-check the source carries zero internal specifics
    (product / program / funder / real names) and no un-redacted PII, and that it does not
    impersonate a real organisation (generic-branded only). Never invent evidence to fill
    a gap.

12. **Update the log** in `design/<project>/README.md` with a dated status-log row:
    fidelity, screen count, gates passed/failed, and the Mode T verdict.

13. **Report and hand off.** The screen count, the DoD gate table, the local gate result,
    the Principal Designer's verdict and what was addressed, and any flagged assumptions.
    Then tell the user the next step is **`/export-prototype --artifact`** to publish.
    This command does not publish — publishing is outward-facing and has one owner.
```

Also update the intro prose (lines 6-27). It currently says "for a synthesized research
study" and describes publishing an Artifact. It should say the command authors a design
project's prototype source from its PRD, and that `/export-prototype` ships it.

- [ ] **Step 4: Mirror all of it into the skill file**

Apply the same changes to `.agents/skills/design-prototype/SKILL.md`, condensed to
single-paragraph steps, command names without the leading slash. Its `description:` must
match the command's exactly.

- [ ] **Step 5: Update Principal Designer Mode T**

In `.claude/personas/principal-designer.md`, from line 184:

- **Header** — `## Mode T — Prototype review (dispatched by /design-prototype)` stays.
- **Intro** — it reviews *authored `src/` source for a design project*, before
  `/export-prototype` publishes it. Drop "or a study's synthesis".
- **Input** — "the authored `src/` files, the run's Definition-of-Done gate table, the
  `check-prototype.ps1` result, the project's `PRD.md` and `README.md`, and the
  `SYNTHESIS.md` of each study named in `Informed by:`." Delete the study-sourced branch
  and the "Prefer `PRD.md` where both exist" sentence — there is no longer a both.
- **Criterion 1 (Traceability)** — every screen maps to a PRD §8 vertical slice and its
  §11 screen entry. Delete the `SPEC.md` / synthesis-finding alternative.
- **Add a criterion, between 2 and 3 — Design-system compliance.** Every value is a
  `ui-library/` token or a project-overlay redefinition of one; every class exists in
  `components.css`; no component marked `not yet ported` is used. A prototype that
  hand-rolls a colour or invents a class has recreated the divergence the library exists
  to end, even when it looks right.
- **Criterion 5 (PII-safety)** — keep, and note the prototype is judged **before**
  `/export-prototype` publishes it, so this is the review that matters.

- [ ] **Step 6: Verify nothing still points at the retired paths**

Run:
```bash
grep -n "SPEC.md\|SYNTHESIS.md\|active-research\|lenses/tokens.md" \
  .claude/commands/design-prototype.md .agents/skills/design-prototype/SKILL.md
```
Expected: the only surviving `SYNTHESIS.md` hits are the ones about reading a cited
study's evidence (steps 4 and 10). **No** `SPEC.md`, **no** `active-research`, **no**
`lenses/tokens.md`.

Then confirm the pair still agrees:
```bash
diff <(sed -n 's/^description: //p' .claude/commands/design-prototype.md) \
     <(sed -n 's/^description: //p' .agents/skills/design-prototype/SKILL.md)
```
Expected: no output.

- [ ] **Step 7: Commit**

```bash
git add .claude/commands/design-prototype.md .agents/skills/design-prototype/SKILL.md .claude/personas/principal-designer.md
git commit -m "feat(design): retarget /design-prototype to a design project and its PRD"
```

---

### Task 4: Surface docs and the project contract

The two halves of the workspace are described in four places. After Task 3,
`/design-prototype` is no longer a research command, and all four say it is.

**Files:**
- Modify: `.claude/references/design-projects.md` ("How the commands touch this", from line 109)
- Modify: `CLAUDE.md` (lines 170, 197, 226, and the design-half command table at ~283)
- Modify: `README.md` (lines 183, 191-194, 208, 314-317, and the design table at ~309)
- Modify: `GEMINI.md` (lines 5 and 267 for the count; §7 at line 99)

**Interfaces:**
- Consumes: the final command names, argument shapes, and descriptions from Tasks 2 and 3.
- Produces: nothing downstream.

- [ ] **Step 1: `.claude/references/design-projects.md`**

In "How the commands touch this", after the `/draft-prd` bullet, add:

```markdown
- **`/design-prototype [project]`** — resolves per the rule above and authors
  `design/<project>/src/` from that project's `PRD.md`. Requires the PRD; never creates a
  project. Does not publish.
- **`/export-prototype [project] [--artifact]`** — resolves per the rule above, builds
  `design/<project>/build/standalone.html` from `src/`, runs `check-prototype.ps1`, and
  with `--artifact` publishes to claude.ai after an explicit confirmation.
```

Also extend the folder diagram at line 16 so `src/` and `build/` name their owners:
`src/` "authored by /design-prototype", `build/` "generated by /export-prototype,
gitignored".

- [ ] **Step 2: `CLAUDE.md`**

- **Line 226** — delete the `/design-prototype` row from the research command table.
- **The design table (~line 283)** — add both rows after `/draft-prd`:

```markdown
| `/design-prototype [project]` | Authors the project's clickable prototype as multi-file source in `src/`, built from its `PRD.md` against `ui-library/`. STOPs on a component `COMPONENTS.md` marks `not yet ported`. Gated by the Principal Designer (Mode T). Does not publish. |
| `/export-prototype [project] [--artifact]` | Builds `src/` into `build/standalone.html`, runs `.claude/scripts/check-prototype.ps1`, and with `--artifact` publishes it to claude.ai after an explicit confirmation. |
```

- **Line 197** — the design-output bullet list currently presents `/design-prototype` as
  a study output. Rewrite so the two *study* outputs are `/brief-feature` (the narrative)
  and nothing else, and say the prototype now lives in the design half.
- **Line 170** — Mode T "judges the drafted HTML prototype" becomes "judges the authored
  `src/` prototype source against the project's PRD and the design system".
- **The pipeline diagram (lines 262-263)** — extend `MAKE` so it names both commands.

- [ ] **Step 3: `README.md`**

- **Line 183** — delete the `/design-prototype` row from the research table.
- **Lines 191-194** — the "optional design-output steps" paragraph pairs
  `/brief-feature` with `/design-prototype`. Rewrite: `/brief-feature` is the study's
  optional output; the prototype is a design-project output.
- **The design table (~line 309)** — add the same two rows as CLAUDE.md.
- **Lines 314-317** — **delete the placeholder note added on 2026-07-28** ("Prototyping a
  design project still goes through `/design-prototype`, which today resolves a *study*
  folder…"). It exists only to describe the gap this plan closes. Replace it with a short
  paragraph on the author/export split and why they are separate commands.
- **The folder tree (~line 116)** — annotate `src/` and `build/` with their owning
  commands, matching Step 1.

- [ ] **Step 4: `GEMINI.md`**

- **Lines 5 and 267** — `All 18 slash commands` / `All 18 skills` become **19**.
- **§7 (line 99)**, "The Design Half — Projects & PRDs (`new-design`, `draft-prd`)" —
  retitle to include `design-prototype` and `export-prototype`, and add a paragraph for
  each in the same style as the existing `new-design` / `draft-prd` entries. Edit §7 **in
  place**; do not append a new section — the file's 1-13 numbering is load-bearing and
  renumbering it churns six sections for nothing.

- [ ] **Step 5: Verify the docs match reality**

```bash
# every command on disk appears in each surface doc
for c in $(ls .claude/commands/ | sed 's/\.md$//'); do
  for f in README.md CLAUDE.md; do
    grep -q "/$c" $f || echo "MISSING: /$c in $f"
  done
done
# no surface doc still calls /design-prototype a research command
grep -n "design-prototype" CLAUDE.md README.md | grep -i "study\|synthesized\|active research"
# counts
ls .claude/commands/*.md | wc -l; ls -d .agents/skills/*/ | wc -l
grep -c "All 19" GEMINI.md
```
Expected: no `MISSING:` lines, no output from the second grep, `19` and `19`, and `2`.

- [ ] **Step 6: Run the full local suite**

```bash
powershell -NoProfile -File .claude/scripts/build-prototype.Tests.ps1
powershell -NoProfile -File .claude/scripts/check-prototype.Tests.ps1
powershell -NoProfile -File .claude/scripts/sync-tokens.Tests.ps1
powershell -NoProfile -File .claude/scripts/md_visualize.Tests.ps1
powershell -NoProfile -File design/onboarding-solve-edu/prototype-web.test.ps1
```
Expected: all five exit 0. The last two are regression guards — this plan does not touch
their subjects, so a failure there means something leaked out of scope.

`/sync-tokens --check` **cannot** be run: it requires the upstream repo URL, which by
design is stored nowhere in this repo. Say so in the report rather than implying the
check passed. No task here touches `ui-library/`, so drift is not possible.

- [ ] **Step 7: Commit**

```bash
git add CLAUDE.md README.md GEMINI.md .claude/references/design-projects.md
git commit -m "docs: move the prototype commands into the design half"
```

---

## Out of scope — the follow-on plan

Deliberately excluded, so this plan produces working tooling on its own:

- **Migrating `onboarding-solve-edu`** onto `ui-library/` — its **23** hand-copied tokens
  (not the 14 the spec says; counted 2026-07-28), moving its root-level files into `src/`,
  and retiring `design/onboarding-solve-edu/build-standalone.ps1` in favour of the new
  builder. It has `prototype-web.test.ps1`, which is exactly why it is the right first
  migration target — and exactly why it should not be disturbed while the tooling is
  still being built.
- **Migrating `ai-literacy-app`** — 96 tokens under different names and a deliberately
  different brand. Sanctioned fallback: leave it `Design system: independent`.
- **De-branding `design/onboarding-solve-edu/`** — an open question, not yet asked for.

Until the first migration lands, `check-prototype.ps1` still guards nothing in practice,
because no project's source links `ui-library/` yet. This plan builds the machine; the
next one feeds it.

---

## Self-review

**Spec coverage.** §5's first bullet (`/design-prototype` authors multi-file source in
`src/` against the PRD and `ui-library/`, Mode T gate) → Task 3. Its second bullet
(`/export-prototype` builds `build/standalone.html` via a generalized builder promoted
from `onboarding-solve-edu`, runs `check-prototype.ps1`, `--artifact` publishes after
confirmation) → Tasks 1 and 2. §3.3's "port on demand, fail loudly" → Task 3 step 2's
component check. §3.4's overlay rule → Task 2 step 4 (`-OverlayPath`) and Task 3 step 5.
The migration bullets and the cleanup bullet are **out of scope by decision**, recorded
above; the cleanup bullet is already complete as of `8a7b02a`.

**Placeholders.** None. Every code step carries real code; every doc step carries the
real replacement text or names the exact lines and what they become.

**Type consistency.** The builder's parameters (`-ProjectPath`, `-EntryPath`, `-Out`) are
spelled identically in Task 1's `.SYNOPSIS`, its tests, and Task 2's step 3. Output path
`design/<project>/build/standalone.html` is identical across Tasks 1, 2, and 4.
`check-prototype.ps1`'s `-Path` and `-OverlayPath` match its real parameter block.
`/export-prototype [project] [--artifact]` is spelled the same in Tasks 2, 3, and 4.
