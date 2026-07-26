# Mobbin-First Benchmark Sourcing — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Mobbin the default source of benchmark evidence, with Claude-in-Chrome as a justified exception, while guaranteeing no Mobbin image is ever committed to this public repo.

**Architecture:** Mostly a documentation change across the workspace's instruction files (`CLAUDE.md`, `README.md`, `GEMINI.md`, five commands, two personas), plus one new PowerShell script that mechanically swaps Mobbin links for local image embeds to produce a gitignored visual reading copy. Safety rests on four independent gates rather than one: `.gitignore`, a mandatory gitignored `docx/` folder, a `/publish-research` staged-file check, and a provenance label in `PATTERNS.md`.

**Tech Stack:** Markdown, PowerShell 5.1 (matching the existing `md_to_docx.ps1` convention), git, Mobbin MCP tools (`mcp__claude_ai_Mobbin__search_screens` / `search_flows` / `search_sections`).

**Spec:** `docs/superpowers/specs/2026-07-26-mobbin-benchmark-integration-design.md`

## Global Constraints

- **No Mobbin image may ever be committed.** The repo `rekyb/research-workspace` is PUBLIC and Mobbin's library is licensed third-party content.
- **Token names, never values** does not apply here, but the analogous rule does: instruction files reference the sourcing standard by name; the standard itself lives in exactly one file (`.claude/references/mobbin-sourcing.md`).
- **Mobbin covers `ios` and `web` only — there is no Android platform.** Any instruction text must not claim otherwise.
- **Chrome-required triggers are C1–C5** and must be written identically everywhere they appear: C1 our own product · C2 no Mobbin coverage · C3 live behaviour needed · C4 currency is the question · C5 Android-specific.
- **Never purchase, upgrade, or change the Mobbin plan.** The existing no-payment guardrail applies to Mobbin exactly as to a benchmarked platform.
- **The three Mobbin tool names are exactly:** `mcp__claude_ai_Mobbin__search_screens`, `mcp__claude_ai_Mobbin__search_flows`, `mcp__claude_ai_Mobbin__search_sections`.
- **Commit trailer:** end every commit body with `Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>`.
- **Git identity is already correct** (`Claude Code` / `rekybongso@gmail.com`) — do not change it.
- **Do not touch** the 8 already-committed `.docx` files or any existing study's contents.

---

## File Structure

| File | Responsibility | Task |
|---|---|---|
| `.gitignore` | Gate 1 — prevent reference images, visual copies, and docx from being committable | 1 |
| `.claude/scripts/md_visualize.ps1` | The link→image transform producing the visual reading copy | 2 |
| `.claude/scripts/md_visualize.Tests.ps1` | Dependency-free test harness for the above | 2 |
| `.claude/references/mobbin-sourcing.md` | **Single source of truth** for the sourcing standard: C1–C5, folder shapes, `references.md` format, IP boundary | 3 |
| `CLAUDE.md` | Operating rules — capture standards rewritten Mobbin-first; Mobbin section corrected | 4 |
| `README.md` | Public-facing docs — guardrails, setup, structure, capture standards, tooling | 5 |
| `GEMINI.md` | Antigravity operator instructions — §2 capture rewritten | 6 |
| `.claude/commands/new-research.md` | Per-platform source selection; `PLAN.md` Source column | 7 |
| `.claude/commands/synth-findings.md` | `--visual` flag; Mobbin citations as links | 8 |
| `.claude/commands/publish-research.md` | Gate 3 — staged-file leak check | 9 |
| `.claude/commands/close-research.md` + `.claude/personas/principal-designer.md` | Gate 4 — the third `PATTERNS.md` Kind | 10 |
| `.claude/personas/principal-researcher.md` | Plan gate requires a written C1–C5 reason per Chrome platform | 11 |

Tasks 4–11 each modify one instruction file and are independently reviewable. Task 1 must come first (it prevents leaks during development of everything else). Task 2 must precede Task 8 (which references the script). Task 3 must precede Tasks 4–11 (they all reference the standard by name).

---

### Task 1: Gate 1 — `.gitignore`

**Files:**
- Modify: `.gitignore` (append to the existing block structure)

**Interfaces:**
- Consumes: nothing
- Produces: three ignore patterns that every later task relies on — `research/*/platforms/*/reference/`, `*.visual.md`, `research/*/docx/`

- [ ] **Step 1: Write the failing test**

Create `scratch/gitignore-check.sh` (a throwaway verification, not committed):

```bash
#!/usr/bin/env bash
set -e
mkdir -p research/_probe/platforms/_p/reference research/_probe/docx
touch research/_probe/platforms/_p/reference/x.png
touch research/_probe/SYNTHESIS.visual.md
touch research/_probe/docx/X.docx
fail=0
for f in \
  research/_probe/platforms/_p/reference/x.png \
  research/_probe/SYNTHESIS.visual.md \
  research/_probe/docx/X.docx
do
  if git check-ignore -q "$f"; then echo "IGNORED  $f"; else echo "NOT IGNORED  $f"; fail=1; fi
done
rm -rf research/_probe
exit $fail
```

- [ ] **Step 2: Run it to verify it fails**

Run: `bash scratch/gitignore-check.sh`
Expected: FAIL — all three print `NOT IGNORED`, exit code 1.

- [ ] **Step 3: Add the ignore patterns**

Append to `.gitignore`, immediately after the existing `research/*/corpus/` block so related rules sit together:

```gitignore
# Mobbin reference images (licensed third-party library content — never committed)
research/*/platforms/*/reference/

# Generated visual reading copies (contain embedded reference images)
*.visual.md

# Word exports (may embed reference images; regenerate with md_to_docx.ps1)
research/*/docx/
```

- [ ] **Step 4: Run it to verify it passes**

Run: `bash scratch/gitignore-check.sh`
Expected: PASS — all three print `IGNORED`, exit code 0.

- [ ] **Step 5: Verify already-tracked docx are unaffected**

Run: `git ls-files "*.docx" | wc -l`
Expected: `8` — `.gitignore` does not untrack existing files, and those 8 predate Mobbin. If this returns anything other than 8, STOP and report.

- [ ] **Step 6: Clean up and commit**

```bash
rm -f scratch/gitignore-check.sh
git add .gitignore
git commit -m "chore: gitignore Mobbin reference images, visual copies, and docx exports

Gate 1 of the Mobbin IP boundary. Reference images are licensed library
content and this repo is public; visual copies and docx exports embed
them. Existing tracked docx are unaffected - gitignore does not untrack.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 2: The `md_visualize.ps1` transform

**Files:**
- Create: `.claude/scripts/md_visualize.ps1`
- Create: `.claude/scripts/md_visualize.Tests.ps1`

**Interfaces:**
- Consumes: `references.md` tables written per the format defined in Task 3
- Produces: a script invoked as
  `powershell -File .claude/scripts/md_visualize.ps1 -Source <md> [-Out <md>] [-StudyRoot <dir>]`
  Defaults: `-Out` is `<Source directory>/<Source basename>.visual.md`; `-StudyRoot` is the directory containing `-Source`. Exit code 0 on success, 1 on error. Writes a one-line summary to stdout: `swapped N of M candidate links`.

**Behaviour contract (what Task 8 relies on):**
1. Scans `<StudyRoot>/platforms/*/references.md` for mapping tables.
2. A markdown inline link `[text](url)` is a swap candidate **only if `url` appears in the Mobbin URL column of one of those tables** — matching is by table lookup, never by URL pattern.
3. If the matched row's local file exists on disk, the link is replaced by `![text](<path relative to the output file's directory>)`. Otherwise the link is left untouched.
4. Never writes to `-Source`.
5. Idempotent: running twice on the same input produces identical output.
6. Image embeds already present (`![...](...)`) are never modified.

- [ ] **Step 1: Write the failing test**

Create `.claude/scripts/md_visualize.Tests.ps1`. Dependency-free — no Pester required.

```powershell
# Dependency-free test harness for md_visualize.ps1
$ErrorActionPreference = 'Stop'
$script:Failures = 0
$ScriptUnderTest = Join-Path $PSScriptRoot 'md_visualize.ps1'

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

function New-Fixture {
    $root = Join-Path ([System.IO.Path]::GetTempPath()) ("mdviz_" + [guid]::NewGuid().ToString('N'))
    $plat = Join-Path $root 'platforms\headspace'
    $ref  = Join-Path $plat 'reference'
    New-Item -ItemType Directory -Force -Path $ref | Out-Null
    # a real 1x1 PNG so File.Exists() is true
    [IO.File]::WriteAllBytes((Join-Path $ref '01-paywall.png'), [byte[]](0x89,0x50,0x4E,0x47))
    @'
# References — headspace (Mobbin-sourced)

| # | Screen | Mobbin URL | Screen ID | Local file | Accessed |
|---|---|---|---|---|---|
| 01 | Paywall — annual default | https://mobbin.com/screens/abc123 | abc123 | reference/01-paywall.png | 2026-07-26 |
| 02 | Trial offer | https://mobbin.com/screens/def456 | def456 | reference/02-missing.png | 2026-07-26 |
'@ | Set-Content -Path (Join-Path $plat 'references.md') -Encoding utf8
    return $root
}

# --- Test 1: a mapped link with an existing file becomes an image embed
$root = New-Fixture
$src  = Join-Path $root 'SYNTHESIS.md'
@'
Headspace fronts the annual plan.
Evidence: [Headspace — paywall](https://mobbin.com/screens/abc123)
'@ | Set-Content -Path $src -Encoding utf8
& powershell -NoProfile -File $ScriptUnderTest -Source $src | Out-Null
$out = Get-Content (Join-Path $root 'SYNTHESIS.visual.md') -Raw
Assert-Equal 'True' ([string]($out -match '!\[Headspace — paywall\]\(platforms/headspace/reference/01-paywall\.png\)')) 'mapped link with existing file becomes an image embed'

# --- Test 2: source file is never modified
$srcAfter = Get-Content $src -Raw
Assert-Equal 'True' ([string]($srcAfter -match '\[Headspace — paywall\]\(https://mobbin\.com/screens/abc123\)')) 'source file is left untouched'

# --- Test 3: mapped link whose local file is missing stays a link
$src3 = Join-Path $root 'B.md'
'Evidence: [Trial](https://mobbin.com/screens/def456)' | Set-Content -Path $src3 -Encoding utf8
& powershell -NoProfile -File $ScriptUnderTest -Source $src3 | Out-Null
$out3 = Get-Content (Join-Path $root 'B.visual.md') -Raw
Assert-Equal 'True' ([string]($out3 -match '\[Trial\]\(https://mobbin\.com/screens/def456\)')) 'missing local file degrades to an unchanged link'
Assert-Equal 'False' ([string]($out3 -match '!\[Trial\]')) 'missing local file produces no image embed'

# --- Test 4: an unmapped mobbin.com link in prose is NOT rewritten
$src4 = Join-Path $root 'C.md'
'See [Mobbin](https://mobbin.com/browse/ios) for more.' | Set-Content -Path $src4 -Encoding utf8
& powershell -NoProfile -File $ScriptUnderTest -Source $src4 | Out-Null
$out4 = Get-Content (Join-Path $root 'C.visual.md') -Raw
Assert-Equal 'True' ([string]($out4 -match '\[Mobbin\]\(https://mobbin\.com/browse/ios\)')) 'unmapped mobbin.com link is left alone'

# --- Test 5: idempotent
$src5 = Join-Path $root 'D.md'
'Evidence: [P](https://mobbin.com/screens/abc123)' | Set-Content -Path $src5 -Encoding utf8
& powershell -NoProfile -File $ScriptUnderTest -Source $src5 | Out-Null
$first = Get-Content (Join-Path $root 'D.visual.md') -Raw
& powershell -NoProfile -File $ScriptUnderTest -Source $src5 | Out-Null
$second = Get-Content (Join-Path $root 'D.visual.md') -Raw
Assert-Equal $first $second 'running twice produces identical output'

# --- Test 6: existing image embeds are untouched
$src6 = Join-Path $root 'E.md'
'![already](platforms/headspace/reference/01-paywall.png)' | Set-Content -Path $src6 -Encoding utf8
& powershell -NoProfile -File $ScriptUnderTest -Source $src6 | Out-Null
$out6 = Get-Content (Join-Path $root 'E.visual.md') -Raw
Assert-Equal 'True' ([string]($out6 -match '!\[already\]\(platforms/headspace/reference/01-paywall\.png\)')) 'pre-existing image embed is preserved'

Remove-Item -Recurse -Force $root
if ($script:Failures -gt 0) { Write-Host "`n$($script:Failures) failure(s)" -ForegroundColor Red; exit 1 }
Write-Host "`nAll tests passed" -ForegroundColor Green
exit 0
```

- [ ] **Step 2: Run it to verify it fails**

Run: `powershell -NoProfile -File .claude/scripts/md_visualize.Tests.ps1`
Expected: FAIL — the script under test does not exist, so every test errors out.

- [ ] **Step 3: Write the implementation**

Create `.claude/scripts/md_visualize.ps1`:

```powershell
<#
.SYNOPSIS
  Produce a visual reading copy of a research markdown file by swapping Mobbin
  citation links for local reference-image embeds.

.DESCRIPTION
  Reads every platforms/*/references.md mapping table under -StudyRoot and builds
  a URL -> local-file map. Any inline markdown link whose URL appears in that map,
  and whose local file exists on disk, is rewritten as an image embed with a path
  relative to the output file. Everything else passes through untouched.

  The source file is never modified. The output is gitignored (*.visual.md) because
  it embeds licensed Mobbin library content that must not be committed.

.EXAMPLE
  powershell -File md_visualize.ps1 -Source research/2026-07-28-x/SYNTHESIS.md
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Source,
    [string]$Out,
    [string]$StudyRoot
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Source)) {
    Write-Error "Source not found: $Source"
    exit 1
}

$srcItem = Get-Item -LiteralPath $Source
if (-not $StudyRoot) { $StudyRoot = $srcItem.DirectoryName }
if (-not $Out) {
    $base = [IO.Path]::GetFileNameWithoutExtension($srcItem.Name)
    $Out  = Join-Path $srcItem.DirectoryName "$base.visual.md"
}

# --- Build the URL -> absolute-local-path map from every references.md table
$map = @{}
$refFiles = @()
$platformsDir = Join-Path $StudyRoot 'platforms'
if (Test-Path -LiteralPath $platformsDir) {
    $refFiles = Get-ChildItem -Path $platformsDir -Filter 'references.md' -Recurse -File -ErrorAction SilentlyContinue
}

foreach ($rf in $refFiles) {
    foreach ($line in (Get-Content -LiteralPath $rf.FullName)) {
        if ($line -notmatch '^\s*\|') { continue }
        $cells = $line.Split('|') | ForEach-Object { $_.Trim() }
        # Split on '|' yields empty leading/trailing entries for a well-formed row
        if ($cells.Count -lt 7) { continue }
        $url   = $cells[3]
        $local = $cells[5]
        if ($url -notmatch '^https?://') { continue }   # skips header + separator rows
        if ([string]::IsNullOrWhiteSpace($local)) { continue }
        $abs = Join-Path $rf.DirectoryName $local
        if (-not $map.ContainsKey($url)) { $map[$url] = $abs }
    }
}

# --- Compute a forward-slash path from the output directory to a target file
$outDir = Split-Path -Parent ([IO.Path]::GetFullPath($Out))
if ([string]::IsNullOrWhiteSpace($outDir)) { $outDir = (Get-Location).Path }
function Get-RelativePath {
    param([string]$FromDir, [string]$ToFile)
    $fromUri = New-Object System.Uri(([IO.Path]::GetFullPath($FromDir).TrimEnd('\') + '\'))
    $toUri   = New-Object System.Uri([IO.Path]::GetFullPath($ToFile))
    return [Uri]::UnescapeDataString($fromUri.MakeRelativeUri($toUri).ToString()).Replace('\', '/')
}

# --- Transform. (?<!!) ensures an existing image embed is never re-matched.
$text = Get-Content -LiteralPath $Source -Raw
$candidates = 0
$swapped    = 0

$pattern   = '(?<!!)\[([^\]]*)\]\(([^)\s]+)\)'
$evaluator = {
    param($m)
    $script:candidates++
    $label = $m.Groups[1].Value
    $url   = $m.Groups[2].Value
    if ($map.ContainsKey($url)) {
        $abs = $map[$url]
        if (Test-Path -LiteralPath $abs) {
            $script:swapped++
            $rel = Get-RelativePath -FromDir $outDir -ToFile $abs
            return "![$label]($rel)"
        }
    }
    return $m.Value
}

$result = [regex]::Replace($text, $pattern, $evaluator)
Set-Content -LiteralPath $Out -Value $result -Encoding utf8 -NoNewline

Write-Host "swapped $swapped of $candidates candidate links -> $Out"
exit 0
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `powershell -NoProfile -File .claude/scripts/md_visualize.Tests.ps1`
Expected: PASS — `All tests passed`, exit code 0.

If Test 1 fails on the column index, print `$cells` for one row and adjust: a row `| 01 | Screen | URL | ID | file | date |` splits into 8 entries with empty first and last, so URL is index 3 and local file is index 5.

- [ ] **Step 5: Verify the output is gitignored**

Run: `powershell -NoProfile -File .claude/scripts/md_visualize.Tests.ps1; git status --porcelain | grep -c "visual.md" || true`
Expected: `0` — no `.visual.md` appears as untracked.

- [ ] **Step 6: Commit**

```bash
git add .claude/scripts/md_visualize.ps1 .claude/scripts/md_visualize.Tests.ps1
git commit -m "feat: add md_visualize.ps1 for gitignored visual reading copies

Mechanically swaps Mobbin citation links for local reference-image embeds
using the platforms/*/references.md mapping tables. Matching is by table
lookup, never by URL pattern, so ordinary mobbin.com prose links are not
rewritten. Never writes to the source; idempotent; missing local files
degrade to unchanged links.

Dependency-free test harness - no Pester required.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 3: The sourcing standard

**Files:**
- Create: `.claude/references/mobbin-sourcing.md`

**Interfaces:**
- Consumes: nothing
- Produces: the single authoritative definition of C1–C5, the two folder shapes, the `references.md` column format, and the IP boundary. Tasks 4–11 reference this file by path rather than restating its content.

- [ ] **Step 1: Write the file**

Create `.claude/references/mobbin-sourcing.md`:

````markdown
# Mobbin sourcing standard

How benchmark evidence is sourced, cited, and kept publishable. This file is the
single source of truth; other instruction files reference it rather than restating it.

## Default source

**Mobbin is the default source for benchmark evidence.** Claude-in-Chrome is the
exception, used when one of the C1–C5 triggers below applies and the reason is written
into the study's `PLAN.md`.

Tools: `mcp__claude_ai_Mobbin__search_screens`, `mcp__claude_ai_Mobbin__search_flows`,
`mcp__claude_ai_Mobbin__search_sections`. Load via ToolSearch if deferred.

**Registration:** Mobbin is a claude.ai connector. If the connector is unavailable
(absent from `claude mcp list`, failing its health check, or a headless/cron session),
fall back to a project-scoped `.mcp.json` at the repo root pointing at
`https://api.mobbin.com/mcp`. Never run both at once — same URL means a duplicate server
and a second OAuth. Delete `.mcp.json` once the connector works again; it is not committed.
A newly added connector is invisible until Claude Code restarts.

**Never purchase, upgrade, or change the Mobbin plan.** The no-payment guardrail applies
here exactly as it does to a benchmarked platform.

## Chrome-required triggers (C1–C5)

Use Claude-in-Chrome, and record which trigger applies, when:

| ID | Trigger | Why Mobbin cannot serve it |
|---|---|---|
| C1 | The product is ours (`solve.education`, anything under `design/`) | Unreleased or internal product has no library coverage |
| C2 | Mobbin has no coverage of the platform | Verified by search, not assumed |
| C3 | The question needs live behaviour — validation response, error states, timing, "what the system does" | Stills cannot demonstrate system response |
| C4 | Currency is itself the question | Mobbin is a snapshot; the live product may have moved |
| C5 | The question is Android-specific | Mobbin covers `ios` and `web` only; Android interaction convention is out of scope |

Usability studies (`--type usability`) are always first-party and unaffected by this standard.

## Platform coverage limit

Mobbin's `platform` parameter accepts **`ios` and `web` only — there is no Android.**
Mobbin adds native iOS coverage, which is a genuine gain over web-only capture, but it
does not close the Android gap. For Android-first work, iOS patterns transfer at the level
of flow structure and information architecture, not platform interaction convention (back
behaviour, system sheets, navigation idiom). Treat Mobbin-sourced mobile findings as
structural evidence; keep platform-convention claims out of them.

## Folder shapes

**Mobbin-sourced (default):**

```
platforms/<platform>/
├── references.md     committed — the screen ↔ URL mapping table
├── flow.md           committed — written flow
├── notes.md          committed — analysis
└── reference/        GITIGNORED — downloaded Mobbin PNGs
```

**Chrome-sourced:**

```
platforms/<platform>/
├── screenshots/      committed — first-party PNGs
├── flow.gif          committed — first-party recording
├── flow.md           committed
└── notes.md          committed
```

The presence of `references.md` (vs `screenshots/`) is how a reader tells which shape
they are looking at.

## `references.md` format

Column order is fixed — `md_visualize.ps1` parses by position (URL is column 3, local
file is column 5).

```markdown
# References — <platform> (Mobbin-sourced)

| # | Screen | Mobbin URL | Screen ID | Local file | Accessed |
|---|---|---|---|---|---|
| 01 | Paywall — annual default | https://mobbin.com/screens/abc123 | abc123 | reference/01-paywall.png | 2026-07-26 |
```

- **Mobbin URL** — the `mobbin_url` returned by the search tool. This is the canonical link
  and the citation used in committed prose.
- **Screen ID** — the UUID, kept so a citation stays recoverable if URL form changes.
- **Local file** — path relative to the platform folder. A file in `reference/` with no
  matching row is an error: the row is what makes it citable.

Downloads are disposable — deleting `reference/` and re-downloading from `references.md`
must reproduce the same state.

## Evidence rules

- **`flow.gif` is Chrome-only.** A GIF stitched from Mobbin frames is a derivative of their
  library and could not be committed. Mobbin platforms carry the flow in `flow.md` +
  `references.md`.
- **Mobbin-sourced `flow.md` must mark system-response claims as inferred.** Screen sequence
  does not prove what the system did. Write "inferred from screen sequence", never assert
  observation.
- **No finding may claim first-party observation of a Mobbin-sourced screen.**
- Every Mobbin screen or flow consulted is logged in the study's `sources.md` with
  provenance `mobbin` and an access date.

## IP boundary — four gates

The repo is **public** and Mobbin's library is licensed third-party content whose images are
copyright of their respective owners. Republishing it violates their terms and resells what
Mobbin sells.

1. **`.gitignore`** — `research/*/platforms/*/reference/`, `*.visual.md`, `research/*/docx/`
2. **The docx rule** — Word exports go in the gitignored `research/*/docx/` folder, because
   an export embeds images into a binary no markdown check can inspect
3. **`/publish-research` gate** — refuses to push when staged files include anything under
   `reference/`, any `*.visual.md`, or any `.docx` outside the ignored folder
4. **Provenance label** — `research/PATTERNS.md` entries sourced this way use
   **Kind:** `reference-library observed (Mobbin; not first-party captured)`

## Reading a synthesis with images

`SYNTHESIS.md` always carries Mobbin links and is always safe to commit. To read it with
screenshots inline:

```
powershell -File .claude/scripts/md_visualize.ps1 -Source research/<study>/SYNTHESIS.md
```

This writes `SYNTHESIS.visual.md` (gitignored). It never modifies the source. Regenerate
freely; the copy is disposable.
````

- [ ] **Step 2: Verify the file is committable and internally consistent**

Run:
```bash
git check-ignore -q .claude/references/mobbin-sourcing.md && echo "WRONGLY IGNORED" || echo "committable"
grep -c "C5" .claude/references/mobbin-sourcing.md
grep -c "mcp__claude_ai_Mobbin__" .claude/references/mobbin-sourcing.md
```
Expected: `committable`, `C5` appears at least twice, tool prefix appears at least 3 times.

- [ ] **Step 3: Commit**

```bash
git add .claude/references/mobbin-sourcing.md
git commit -m "docs: add the Mobbin sourcing standard

Single source of truth for C1-C5 Chrome-required triggers, the two
platform folder shapes, the references.md column format, evidence rules,
and the four-gate IP boundary. Other instruction files reference this
rather than restating it.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 4: `CLAUDE.md` — capture standards and the Mobbin section

**Files:**
- Modify: `CLAUDE.md` — the `## Capture standards` section, and the existing Mobbin subsection under `## Tooling notes`

**Interfaces:**
- Consumes: `.claude/references/mobbin-sourcing.md` (Task 3)
- Produces: the operating rules every command inherits

- [ ] **Step 1: Replace the "Mobbin in the research workflow" subsection**

The current subsection (added 2026-07-26) states Mobbin must never substitute for captured
evidence. That was correct under the old model and is **wrong** under this one. Replace the
whole `### Mobbin in the research workflow` section — from its heading to just before
`## Version control & publishing` — with:

```markdown
### Mobbin in the research workflow

**Mobbin is the default source for benchmark evidence.** Claude-in-Chrome is the exception,
used when a C1–C5 trigger applies. The full standard — triggers, folder shapes,
`references.md` format, evidence rules, and the IP boundary — lives in
`.claude/references/mobbin-sourcing.md`. Read it before capturing.

The three rules that must never be violated, restated here because they are load-bearing:

- **No Mobbin image is ever committed.** The repo is public; the library is licensed
  third-party content. Reference images live in a gitignored `reference/` folder and are
  cited by URL in committed prose.
- **No finding claims first-party observation of a Mobbin screen.** Mobbin shows a pattern
  exists; it does not show that we watched it work.
- **Mobbin covers `ios` and `web` only.** Android-specific questions are C5 — Chrome, a
  device, or unanswerable.
```

Keep the connector-first / `.mcp.json` fallback rule already present in the `## Tooling notes`
Mobbin bullet exactly as written — it is still correct.

- [ ] **Step 2: Rewrite the `## Capture standards` section**

Replace the section's opening (the numbered items 0–5) so it branches by source. Keep the
existing redaction detail verbatim, but scope it to Chrome capture:

```markdown
## Capture standards

**Choose the source first.** Mobbin is the default; Chrome requires a C1–C5 trigger recorded
in `PLAN.md`. See `.claude/references/mobbin-sourcing.md`.

### Mobbin-sourced platforms (default)

1. **Search** with `mcp__claude_ai_Mobbin__search_screens` / `search_flows` /
   `search_sections`. Platform is `ios` or `web` — there is no Android.
2. **Download** the selected screens into `platforms/<platform>/reference/` with numbered,
   descriptive names (`01-paywall.png`), and write the matching `references.md` row in the
   same step. A file with no row is an error.
3. **Written flow (required)** — `platforms/<platform>/flow.md`, same standard as below, with
   one addition: system-response claims must be marked **inferred from screen sequence**, not
   asserted as observed. There is no `flow.gif` for Mobbin platforms.
4. **Notes** — `platforms/<platform>/notes.md`, the analysis.
5. **Sources** — log every screen/flow consulted in `sources.md` with provenance `mobbin`
   and the access date.

No redaction step is needed: Mobbin screens carry no account session and no PII.

### Chrome-sourced platforms (C1–C5 only)

Unchanged from prior practice — redact before capture, screenshots, `flow.gif`, `flow.md`,
`notes.md`, `sources.md`. The redaction rules below are mandatory whenever a logged-in
session is used.
```

Leave the existing redaction subsection (steps 0–5 detail, `window.__redact()`, verification)
in place beneath that heading — it still governs Chrome capture.

- [ ] **Step 3: Verify no contradictory text survives**

Run:
```bash
grep -n "substitute for captured evidence" CLAUDE.md || echo "OK - old rule removed"
grep -n "Android-first" CLAUDE.md
grep -c "mobbin-sourcing.md" CLAUDE.md
```
Expected: `OK - old rule removed`; any `Android-first` hit must not claim Mobbin covers it;
`mobbin-sourcing.md` referenced at least twice.

- [ ] **Step 4: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: rewrite CLAUDE.md capture standards for Mobbin-first sourcing

Replaces the Mobbin subsection added earlier today, which forbade Mobbin
as an evidence substitute - correct under the old Chrome-first model,
wrong under this one. Capture standards now branch by source, with
redaction scoped to Chrome capture where a logged-in session exists.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 5: `README.md` — five sections

**Files:**
- Modify: `README.md` — `## Guardrails` (34-48), `## Requirements & setup` (49-73), `## Repository structure` (75-125), `## Capture standards` (180-196), `## Tooling notes` (244-259)

**Interfaces:**
- Consumes: `.claude/references/mobbin-sourcing.md` (Task 3)
- Produces: the public-facing description of the workflow

- [ ] **Step 1: Add the redistribution guardrail**

In `## Guardrails`, change "Two hard rules" to "Three hard rules" and append:

```markdown
- **Never republish licensed reference material.** Mobbin is the default benchmark
  source, and its library is licensed third-party content. Reference images are kept in
  a gitignored `reference/` folder and cited by URL — they are never committed to this
  public repo. A Mobbin-sourced finding is labelled as such, so "grounded in captured
  evidence" keeps its meaning.
```

- [ ] **Step 2: Update the setup table**

In `## Requirements & setup`, add a Mobbin row above the Chrome row and reword the Chrome row:

```markdown
| **Mobbin** (MCP) | **Default source** for benchmark evidence — curated screens and flows from shipped iOS and web products, including paywalled and region-locked apps. | Registered as a claude.ai connector at `https://api.mobbin.com/mcp` (OAuth). Requires a paid Mobbin plan. Covers `ios` and `web` only — no Android. |
| **Google Chrome** + **Claude-in-Chrome** (or Antigravity Browser Extension) | **Fallback capture** for the C1–C5 cases Mobbin cannot serve — our own products, missing coverage, live-behaviour questions, currency, and Android. | Chrome extension ID: `eeijfnjmjelapkebgockoeaadonbchdd`. |
```

- [ ] **Step 3: Update the repository-structure tree**

In the `research/YYYY-MM-DD-<slug>/` block, replace the single `platforms/` shape with both:

```
        ├── platforms/              # benchmark studies: one folder per platform
        │   ├── <mobbin-sourced>/   #   default shape
        │   │   ├── references.md   #     screen ↔ Mobbin URL mapping table (committed)
        │   │   ├── reference/      #     downloaded Mobbin PNGs (GITIGNORED)
        │   │   ├── flow.md         #     written step-by-step
        │   │   └── notes.md        #     observations & patterns
        │   └── <chrome-sourced>/   #   C1–C5 cases only
        │       ├── screenshots/    #     first-party captures (committed)
        │       ├── flow.gif        #     first-party recording (committed)
        │       ├── flow.md
        │       └── notes.md
```

And in the `.claude/` block add the two new files:

```
│   ├── references/
│   │   ├── design-gates.md         # design-gate definitions used by /draft-spec & /design-prototype
│   │   └── mobbin-sourcing.md      # Mobbin sourcing standard: C1–C5, folder shapes, IP boundary
│   └── scripts/
│       ├── md_to_docx.py           # Markdown → .docx export (python-docx)
│       ├── md_to_docx.ps1          # dependency-free PowerShell fallback for the same export
│       └── md_visualize.ps1        # Mobbin links → local image embeds (gitignored *.visual.md)
```

- [ ] **Step 4: Rewrite `## Capture standards`**

```markdown
## Capture standards

Benchmark evidence comes from **Mobbin by default**; Chrome is used for the C1–C5 cases it
cannot serve (our own products, missing coverage, live-behaviour questions, currency,
Android). The full standard is `.claude/references/mobbin-sourcing.md`.

**Mobbin-sourced** — screens downloaded to a gitignored `platforms/<platform>/reference/`,
each logged in a committed `references.md` mapping table (screen, Mobbin URL, screen ID,
local file, access date). The flow is written as `flow.md`, with system-response claims
marked *inferred from screen sequence*. No `flow.gif`.

**Chrome-sourced** — numbered PNGs in `platforms/<platform>/screenshots/`, the core flow
recorded as `flow.gif`, the same flow written as `flow.md`, analysis in `notes.md`.
Personal data is redacted *before* anything is saved.

**Both** — every source logged in the research-level `sources.md` with its access date and
provenance.

Reading a synthesis with its screenshots inline:

```bash
powershell -File .claude/scripts/md_visualize.ps1 -Source research/<study>/SYNTHESIS.md
```

This writes a gitignored `SYNTHESIS.visual.md`. `SYNTHESIS.md` itself always carries links,
so it is always safe to commit.
```

- [ ] **Step 5: Update `## Tooling notes`**

Add a Mobbin bullet as the first entry, and amend the Word-export bullet:

```markdown
- **Pattern reference & default benchmark source:** **Mobbin** via its MCP server
  (`search_screens`, `search_flows`, `search_sections`) — curated screens and flows from
  shipped iOS and web products. Paid plan; claude.ai connector. Covers `ios` and `web` only.
- **Word export:** `pandoc` is *not* installed. `.docx` files are generated from Markdown
  via `.claude/scripts/md_to_docx.ps1` (or `md_to_docx.py` with python-docx). Exports are
  written to the study's **gitignored** `docx/` folder, because an export embeds images
  into a binary that no text check can inspect.
```

- [ ] **Step 6: Verify**

Run:
```bash
grep -c "Three hard rules" README.md
grep -c "mobbin-sourcing.md" README.md
grep -c "md_visualize.ps1" README.md
grep -n "no Android\|no Android platform\|ios\` and \`web\` only" README.md | head -3
```
Expected: `1`, at least `2`, at least `2`, and at least one Android-limit mention.

- [ ] **Step 7: Commit**

```bash
git add README.md
git commit -m "docs: update README for Mobbin-first benchmark sourcing

Adds the redistribution guardrail, Mobbin to the setup table, both
platform folder shapes to the structure tree, rewritten capture
standards, and the gitignored docx rule. States the ios/web-only
coverage limit plainly - Mobbin does not cover Android.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 6: `GEMINI.md` — §2 Capturing Evidence

**Files:**
- Modify: `GEMINI.md:30-33` (the `### 2. Capturing Evidence (benchmark Studies)` section)

**Interfaces:**
- Consumes: `.claude/references/mobbin-sourcing.md` (Task 3)
- Produces: Antigravity-operator instructions consistent with `CLAUDE.md`

- [ ] **Step 1: Replace the section**

Replace lines 30-33 with:

```markdown
### 2. Capturing Evidence (`benchmark` Studies)
- **Mobbin is the default source.** Use the Mobbin MCP tools (`search_screens`,
  `search_flows`, `search_sections`) to find the screens and flows the study needs. Platform
  is `ios` or `web` — **Mobbin has no Android coverage.**
- **Browser capture is the exception**, used only for a C1–C5 trigger recorded in `PLAN.md`:
  C1 our own product · C2 no Mobbin coverage · C3 the question needs live behaviour · C4
  currency is the question · C5 the question is Android-specific.
- **Mobbin-sourced:** download screens to `platforms/<platform>/reference/` (**gitignored**)
  and log each in a committed `references.md` table (screen, Mobbin URL, screen ID, local
  file, accessed). Write `flow.md` marking system-response claims as *inferred from screen
  sequence*. There is no `flow.gif`. **Never commit a Mobbin image** — this repo is public
  and the library is licensed.
- **Chrome-sourced:** **Redaction is CRITICAL (Hard Rule)** — before saving any visual
  evidence you MUST inject CSS or manipulate the DOM to blur personal data (avatars, names,
  emails) to comply with the workspace's zero-PII policy. Save screenshots as numbered PNGs
  in `platforms/<platform>/screenshots/`, plus `flow.gif`.
- Full standard: `.claude/references/mobbin-sourcing.md`.
```

- [ ] **Step 2: Verify CLAUDE.md and GEMINI.md agree**

Run:
```bash
for f in CLAUDE.md GEMINI.md README.md; do
  echo "== $f"; grep -c "C5\|Android" "$f"
done
grep -n "Redaction is CRITICAL" GEMINI.md
```
Expected: all three files mention the Android limit; the redaction hard rule is still present
in `GEMINI.md` (scoped to Chrome).

- [ ] **Step 3: Commit**

```bash
git add GEMINI.md
git commit -m "docs: rewrite GEMINI.md capture section for Mobbin-first sourcing

Antigravity operators were still getting Chrome-first instructions.
Now mirrors CLAUDE.md: Mobbin default, C1-C5 triggers for browser
capture, redaction hard rule scoped to Chrome where a logged-in session
actually exists.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 7: `/new-research` — per-platform source selection

**Files:**
- Modify: `.claude/commands/new-research.md` — step 7 (benchmark branch, lines 82-93) and the benchmark `PLAN.md` template (lines 158-182)

**Interfaces:**
- Consumes: `.claude/references/mobbin-sourcing.md` (Task 3)
- Produces: a `PLAN.md` with a per-platform **Source** field that Task 11's persona gate reads

- [ ] **Step 1: Rewrite the benchmark branch of step 7**

Replace the `**Benchmark**` block with:

```markdown
   **Benchmark** (the plan is what the Principal Researcher signs off on before any
   capture):
   - **You need the platforms first.** If the topic names them, draft the plan now; if not,
     **use Mobbin to propose candidates** — `mcp__claude_ai_Mobbin__search_flows` for the
     flow the study is about — and present the shortlist to the user rather than asking cold.
   - **Pick a source per platform.** Mobbin is the default. Chrome requires one of the C1–C5
     triggers from `.claude/references/mobbin-sourcing.md`, and the trigger **must be written
     into `PLAN.md`**. Before claiming C2 ("no Mobbin coverage"), actually search — do not
     assume.
   - **Draft `PLAN.md`:** derive key research questions from the `## Goal`, list the
     platforms with their **Source** and (for Chrome) the trigger, and for each name the
     specific flows/screens to capture, the success criteria, and known risks.
   - **Dispatch the Principal Researcher (Mode A)** via the Agent tool (`general-purpose`)
     with `.claude/personas/principal-researcher.md`, the drafted `PLAN.md`, and the
     `README.md`. It returns must-fixes.
   - **Revise `PLAN.md`** and **present it to the user for approval.** Capture begins only
     after they approve.
```

- [ ] **Step 2: Update the benchmark `PLAN.md` template**

Replace the `## Per-platform capture plan` block:

```markdown
## Per-platform capture plan
### <platform 1>
- **Source:** <mobbin | chrome>
- **Chrome trigger (chrome only):** <C1 our own product | C2 no Mobbin coverage, verified by search | C3 live behaviour needed | C4 currency is the question | C5 Android-specific>
- **Flows/screens to capture:** <the specific flows and key screens>
- **What we're looking for:** <the patterns/answers tied to the questions above>
- **Risks:** <paywalls, login/PII, capture blockers — note that Mobbin sourcing removes the paywall and PII risks>
```

- [ ] **Step 3: Verify**

Run:
```bash
grep -c "Source:" .claude/commands/new-research.md
grep -c "C1\|C5" .claude/commands/new-research.md
grep -c "mobbin-sourcing.md" .claude/commands/new-research.md
```
Expected: at least `1`, at least `2`, at least `1`.

- [ ] **Step 4: Commit**

```bash
git add .claude/commands/new-research.md
git commit -m "feat: /new-research picks a source per platform

Mobbin is the default; Chrome needs a written C1-C5 trigger in PLAN.md.
Also uses Mobbin to propose candidate platforms instead of asking the
user cold when the topic does not name them.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 8: `/synth-findings --visual`

**Files:**
- Modify: `.claude/commands/synth-findings.md` — frontmatter `argument-hint` (line 3), the arguments line (line 9), the benchmark evidence-gathering step (lines 21-24), the embed instruction (lines 42-45), and a new final step

**Interfaces:**
- Consumes: `.claude/scripts/md_visualize.ps1` from Task 2 — invoked as
  `powershell -File .claude/scripts/md_visualize.ps1 -Source <study>/SYNTHESIS.md`
- Produces: a `SYNTHESIS.md` whose Mobbin evidence is cited as links

- [ ] **Step 1: Update the frontmatter and arguments line**

```markdown
argument-hint: [--docx] [--visual]
```

```markdown
Arguments: `$ARGUMENTS` — `--docx` also produces a Word file (written to the study's
gitignored `docx/` folder); `--visual` also produces a gitignored `SYNTHESIS.visual.md`
with Mobbin reference images inlined for reading.
```

- [ ] **Step 2: Update benchmark evidence gathering**

```markdown
   - **Benchmark:** read `README.md`, `sources.md`, and every `platforms/*/notes.md` and
     `platforms/*/flow.md`. Note each platform's **source shape**: a `references.md` means
     Mobbin-sourced (cite by URL, no `flow.gif`); a `screenshots/` folder means
     Chrome-sourced (cite by relative image path). If there are no platform notes yet,
     STOP — capture some platforms first.
```

- [ ] **Step 3: Update the evidence-embedding instruction**

Replace the `**CRITICAL:** embed each cited screenshot` clause with:

```markdown
   3. **Key findings** — what we learned observing it. Cite the platform(s) and evidence.
      **Citation depends on the platform's source:**
      - **Chrome-sourced:** embed the capture directly with relative markdown, e.g.
        `![description](platforms/<platform>/screenshots/filename.png)`.
      - **Mobbin-sourced:** cite the canonical Mobbin URL as a link, e.g.
        `[<platform> — <screen>](https://mobbin.com/screens/<id>)`. **Never embed a Mobbin
        reference image in `SYNTHESIS.md`** — it is gitignored and the file is committed.
        Run `--visual` to read it with images.
```

- [ ] **Step 4: Add the visual-copy step**

Add after the docx step:

```markdown
N. **If `--visual` was passed**, generate the reading copy:

   ```
   powershell -File .claude/scripts/md_visualize.ps1 -Source <study>/SYNTHESIS.md
   ```

   Report the `swapped N of M` line it prints. The output `SYNTHESIS.visual.md` is
   gitignored — never stage it, and never edit it (it is regenerated from
   `SYNTHESIS.md`). If N is 0 and the study has Mobbin platforms, the `references.md`
   URLs do not match the links in the synthesis — check both before reporting success.
```

- [ ] **Step 5: Verify end-to-end on a throwaway fixture**

```bash
mkdir -p research/_probe/platforms/hs/reference
printf '\x89PNG' > research/_probe/platforms/hs/reference/01-a.png
cat > research/_probe/platforms/hs/references.md <<'EOF'
| # | Screen | Mobbin URL | Screen ID | Local file | Accessed |
|---|---|---|---|---|---|
| 01 | Paywall | https://mobbin.com/screens/abc | abc | reference/01-a.png | 2026-07-26 |
EOF
echo 'Evidence: [HS — paywall](https://mobbin.com/screens/abc)' > research/_probe/SYNTHESIS.md
powershell -File .claude/scripts/md_visualize.ps1 -Source research/_probe/SYNTHESIS.md
grep -q '!\[HS — paywall\](platforms/hs/reference/01-a.png)' research/_probe/SYNTHESIS.visual.md && echo "SWAP OK" || echo "SWAP FAILED"
git status --porcelain research/_probe | grep -c "visual.md" || echo "0 (correctly ignored)"
rm -rf research/_probe
```
Expected: `swapped 1 of 1`, `SWAP OK`, and the visual file correctly ignored.

- [ ] **Step 6: Commit**

```bash
git add .claude/commands/synth-findings.md
git commit -m "feat: add --visual to /synth-findings

SYNTHESIS.md cites Mobbin evidence as links and stays publish-safe;
--visual generates a gitignored SYNTHESIS.visual.md with the reference
images inlined for reading. Citation style now branches on whether a
platform is Mobbin- or Chrome-sourced.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 9: Gate 3 — `/publish-research` leak check

**Files:**
- Modify: `.claude/commands/publish-research.md` — extend step 3 (the safety gate)

**Interfaces:**
- Consumes: the `.gitignore` patterns from Task 1
- Produces: a hard stop before any Mobbin content can be pushed

- [ ] **Step 1: Add the leak check to step 3**

Append to the step 3 bullet list, before "Only continue once this is clean":

```markdown
   - **Mobbin redistribution guard (required).** Run:

     ```bash
     git diff --cached --name-only | grep -E '(/reference/|\.visual\.md$)' && echo LEAK
     git diff --cached --name-only | grep -E '\.docx$' | grep -v '/docx/' && echo DOCX_LEAK
     ```

     If either prints a path, **STOP** and tell the user exactly which files are staged and
     why they cannot be pushed: `reference/` holds licensed Mobbin library images,
     `*.visual.md` embeds them, and a `.docx` outside the gitignored `docx/` folder may embed
     them invisibly. This repo is public. Unstage them and re-run the gate — do not use
     `git add -f` to override.
```

- [ ] **Step 2: Verify the gate actually fires**

```bash
mkdir -p research/_probe/platforms/hs/reference
printf '\x89PNG' > research/_probe/platforms/hs/reference/01-a.png
git add -f research/_probe/platforms/hs/reference/01-a.png
git diff --cached --name-only | grep -E '(/reference/|\.visual\.md$)' && echo "GATE FIRES (correct)"
git reset -q HEAD research/_probe/platforms/hs/reference/01-a.png
rm -rf research/_probe
```
Expected: the path prints, followed by `GATE FIRES (correct)`.

- [ ] **Step 3: Commit**

```bash
git add .claude/commands/publish-research.md
git commit -m "feat: block Mobbin content in the /publish-research safety gate

Gate 3. Refuses to push when staged files include anything under
reference/, any *.visual.md, or a .docx outside the gitignored docx/
folder. Fails loudly with the offending paths rather than passing
silently.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 10: Gate 4 — the third `PATTERNS.md` Kind

**Files:**
- Modify: `.claude/personas/principal-designer.md` — the section describing `PATTERNS.md` entry fields
- Modify: `.claude/commands/close-research.md` — the Principal Designer dispatch brief

**Interfaces:**
- Consumes: `.claude/references/mobbin-sourcing.md` (Task 3)
- Produces: the provenance label that keeps "grounded in captured evidence" meaningful

> **Pre-existing drift, do not "fix" silently.** `.claude/personas/principal-designer.md`
> documents only two Kind values (`benchmark-observed | usability-finding`), but
> `research/PATTERNS.md` already uses a third in practice —
> `literature-grounded design principle (litreview; no live UI observed)`. The persona spec
> is behind the library. This task adds the Mobbin value **and** brings the litreview value
> into the spec, so the enumeration finally matches reality. Do not delete either existing
> value.

- [ ] **Step 1: Update the entry-writing instruction (line 39-40)**

In `.claude/personas/principal-designer.md`, the current text at lines 39-40 reads:

```markdown
2. **Write each as an entry**: **Name** · **Kind** (benchmark-observed /
   usability-finding) · **Where seen** (study folder + evidence links) · **When it
```

Replace the parenthetical so all four values are listed:

```markdown
2. **Write each as an entry**: **Name** · **Kind** (benchmark-observed /
   usability-finding / literature-grounded design principle /
   reference-library observed) · **Where seen** (study folder + evidence links) · **When it
```

- [ ] **Step 2: Update the entry template (line 62) and add the Mobbin rule**

Line 62 currently reads:

```markdown
- **Kind:** benchmark-observed | usability-finding
```

Replace with:

```markdown
- **Kind:** benchmark-observed | usability-finding | literature-grounded design principle (litreview; no live UI observed) | reference-library observed (Mobbin; not first-party captured)
```

Then, immediately after the template block ending at line 66 (`- **Evidence:** …`), add:

```markdown
- `reference-library observed (Mobbin; not first-party captured)` — the pattern was seen in
  Mobbin's curated library, not captured by this workspace. **Where seen** cites the Mobbin
  URL(s) and the study; **Evidence** cites the study's `references.md`, never an image path
  (reference images are gitignored and must never appear in a committed file). Such an entry
  may state that a pattern is widely shipped; it may **not** state that we observed the
  system's behaviour.
```

- [ ] **Step 3: Update the close-research dispatch brief**

In `.claude/commands/close-research.md`, where the Principal Designer is briefed, add:

```markdown
   - Tell it the study's per-platform sources (from `PLAN.md`). Patterns drawn from a
     Mobbin-sourced platform MUST use
     **Kind:** `reference-library observed (Mobbin; not first-party captured)` and cite the
     Mobbin URL — never a `reference/` image path, which is gitignored. See
     `.claude/references/mobbin-sourcing.md`.
```

- [ ] **Step 4: Verify**

Run:
```bash
grep -c "reference-library observed" .claude/personas/principal-designer.md .claude/commands/close-research.md
for v in "benchmark-observed" "usability-finding" "literature-grounded"; do
  printf '%s: ' "$v"; grep -c "$v" .claude/personas/principal-designer.md
done
```
Expected: `reference-library observed` appears at least once in each of the two files, and
**all three** pre-existing values still appear in the persona — the enumeration was added to,
never replaced. If `usability-finding` or `benchmark-observed` dropped to 0, the edit
overwrote instead of extending; revert and redo.

- [ ] **Step 5: Commit**

```bash
git add .claude/personas/principal-designer.md .claude/commands/close-research.md
git commit -m "feat: add reference-library Kind to the pattern library

Gate 4. PATTERNS.md already distinguished benchmark-observed from
literature-grounded; Mobbin-sourced patterns now carry their own
provenance label and cite Mobbin URLs rather than gitignored image paths.
Keeps 'grounded in captured evidence' meaningful now that Mobbin is the
default source.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 11: Principal Researcher checks the Chrome justification

**Files:**
- Modify: `.claude/personas/principal-researcher.md` — the Mode A (plan review) section

**Interfaces:**
- Consumes: the `PLAN.md` **Source** / **Chrome trigger** fields from Task 7
- Produces: a plan gate that catches undeclared Chrome use

- [ ] **Step 1: Locate the insertion point**

`## Mode A — Plan review (dispatched by /new-research)` begins at **line 35** and runs to
just before `## Mode B — Synthesis QA` at **line 62**. The verdict/must-fix wording sits at
lines 56-57. Insert the new check **inside Mode A's checklist, before the verdict wording at
line 56** — it is a check, not a verdict rule.

Run `sed -n '35,60p' .claude/personas/principal-researcher.md` to see the existing checklist
style, and match its formatting (bullet phrasing, bold lead-ins).

- [ ] **Step 2: Add the source-justification check**

Within Mode A's checklist, before the verdict wording, add:

```markdown
- **Source justification (benchmark only).** Every platform in `## Per-platform capture plan`
  must declare a **Source**. Mobbin is the default and needs no justification. Any platform
  sourced from **Chrome must name a C1–C5 trigger**
  (`.claude/references/mobbin-sourcing.md`): C1 our own product · C2 no Mobbin coverage,
  verified by search · C3 live behaviour needed · C4 currency is the question · C5
  Android-specific. Flag as a **must-fix**:
  - a Chrome platform with no trigger, or a trigger that does not fit the stated research
    question;
  - a **C2 claim with no evidence the search was actually run** — "Mobbin probably doesn't
    have it" is not a trigger;
  - a Mobbin-sourced platform whose research questions require live system behaviour, which
    is C3 and needs Chrome instead.
  Do **not** flag Chrome use that is properly justified — the goal is deliberate sourcing,
  not minimal Chrome use.
```

- [ ] **Step 3: Verify**

Run:
```bash
grep -c "C1–C5\|C1-C5" .claude/personas/principal-researcher.md
grep -c "mobbin-sourcing.md" .claude/personas/principal-researcher.md
```
Expected: at least `1` each.

- [ ] **Step 4: Commit**

```bash
git add .claude/personas/principal-researcher.md
git commit -m "feat: Principal Researcher checks per-platform source justification

At the benchmark plan gate, any Chrome-sourced platform must name a
C1-C5 trigger, and a C2 'no coverage' claim must show the search was
actually run. Properly justified Chrome use is not flagged - the goal is
deliberate sourcing, not minimal Chrome use.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

### Task 12: Cross-file consistency verification

**Files:**
- Modify: none expected (fix any drift found)

**Interfaces:**
- Consumes: every file touched in Tasks 1–11
- Produces: confirmation that the acceptance criteria in spec §10 hold

- [ ] **Step 1: Verify no file still asserts Chrome-first or forbids Mobbin evidence**

```bash
grep -rn "substitute for captured evidence" CLAUDE.md README.md GEMINI.md .claude/ && echo "DRIFT" || echo "OK"
grep -rn "Mobbin.*never.*evidence\|never let a Mobbin" CLAUDE.md README.md GEMINI.md .claude/ && echo "DRIFT" || echo "OK"
```
Expected: `OK` twice.

- [ ] **Step 2: Verify the Android limit is stated wherever Mobbin coverage is claimed**

```bash
for f in CLAUDE.md README.md GEMINI.md .claude/references/mobbin-sourcing.md; do
  printf '%s: ' "$f"
  grep -c "Android" "$f"
done
```
Expected: every file returns ≥1. Any file that describes Mobbin's coverage without the
Android caveat is drift — fix it.

- [ ] **Step 3: Verify the C1–C5 triggers are identical everywhere**

```bash
grep -rn "C5" .claude/references/mobbin-sourcing.md .claude/commands/new-research.md \
  .claude/personas/principal-researcher.md GEMINI.md
```
Expected: every occurrence describes C5 as *Android-specific*. Any variation in meaning is a
must-fix.

- [ ] **Step 4: Verify tool names are exact**

```bash
grep -rn "mcp__" CLAUDE.md README.md GEMINI.md .claude/ | grep -i mobbin | grep -v "mcp__claude_ai_Mobbin__" && echo "WRONG PREFIX" || echo "OK"
```
Expected: `OK` — the only prefix in use is `mcp__claude_ai_Mobbin__`.

- [ ] **Step 5: Verify the four gates are live**

```bash
# Gate 1
git check-ignore -q "research/x/platforms/y/reference/z.png" && echo "G1 OK"
git check-ignore -q "research/x/SYNTHESIS.visual.md" && echo "G1b OK"
git check-ignore -q "research/x/docx/A.docx" && echo "G2 OK"
# Gate 3
grep -q "Mobbin redistribution guard" .claude/commands/publish-research.md && echo "G3 OK"
# Gate 4
grep -q "reference-library observed" .claude/personas/principal-designer.md && echo "G4 OK"
```
Expected: all five print OK.

- [ ] **Step 6: Verify the script still passes its tests**

Run: `powershell -NoProfile -File .claude/scripts/md_visualize.Tests.ps1`
Expected: `All tests passed`, exit code 0.

- [ ] **Step 7: Verify the 8 pre-existing docx are still tracked**

Run: `git ls-files "*.docx" | wc -l`
Expected: `8`.

- [ ] **Step 8: Commit any fixes**

If steps 1–7 required changes:

```bash
git add -A
git commit -m "fix: resolve cross-file drift in Mobbin sourcing docs

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

If nothing needed fixing, report that all acceptance criteria pass and make no commit.

---

## Post-implementation

Not part of this plan, but worth doing next:

- **Run one real Mobbin-sourced study end to end.** The acceptance criteria verify mechanics,
  not usefulness. The open questions in spec §9 — how often C2 fires, whether the evidence
  loss from dropping `flow.gif` bites — can only be answered by using it.
- **`design/ai-literacy-app/benchmark/`** holds one orphaned Headspace screenshot with a
  mangled filename and no source log. It is the natural first candidate: re-source it
  properly through Mobbin, or delete it.
