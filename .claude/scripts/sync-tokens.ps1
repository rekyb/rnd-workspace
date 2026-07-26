<#
.SYNOPSIS
  Sync the production design tokens and component CSS into this repo's ui/ folder.

.DESCRIPTION
  Slices apps/web/app/(frontend)/globals.css from the Solve Education production repo
  at its TOKENS:START / TOKENS:END markers. The lines strictly between the markers
  become ui/tokens.css (the design tokens); the rest of the file, minus both marker
  lines, becomes ui/components.css (the component classes). Both are byte-exact copies
  of the source text - nothing is regenerated, so upstream generator changes never need
  tracking here.

.NOTES
  Failures are reported on stdout (via Write-Host), not stderr, and signaled only by a
  non-zero exit code. This is deliberate: PS 5.1 aborts a caller that merges a child's
  stderr with 2>&1 under $ErrorActionPreference = 'Stop', before that caller ever gets
  to inspect $LASTEXITCODE or the message. Routing errors to stdout keeps both readable
  to callers in that situation. Branch on $LASTEXITCODE, not on stderr content.

.EXAMPLE
  powershell -File sync-tokens.ps1 -SourcePath C:\tmp\checkout -UiRoot C:\repo\ui
#>
[CmdletBinding()]
param(
    [string]$SourcePath,
    [string]$UiRoot,
    [string]$SourceSha = '(local)',
    [switch]$Check
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
# ui/tokens.css - provenance

$new

## What this is

Design tokens extracted verbatim from the Solve Education production repo. Do not
hand-edit tokens.css or components.css - run ``/sync-tokens`` instead. Per-project
brand divergence belongs in ``design/<project>/tokens.overlay.css``, which may
redefine an existing token name but never introduce a new one.
"@
}

# Slice raw text at the two whole-line markers. Returns a hashtable with Tokens and
# Components. Operating on the raw string (never a line array) keeps the output
# byte-identical, including the source's original line endings.
function Split-TokenBlock {
    param([string]$Raw, [string]$SourceLabel)

    $startRx = [regex]::Escape($StartPrefix)
    $endRx   = [regex]::Escape($EndPrefix)

    # Use instance Regex objects so the END search can start at an offset via the
    # Match(input, startat) overload. The static [regex]::Match(string, pattern, int)
    # call resolves to the (string, string, RegexOptions) overload instead - PowerShell
    # then tries to coerce the start-index int into a RegexOptions enum and throws.
    $startRegex = New-Object System.Text.RegularExpressions.Regex("(?m)^[ \t]*$startRx[^\r\n]*")
    $endRegex   = New-Object System.Text.RegularExpressions.Regex("(?m)^[ \t]*$endRx[^\r\n]*")

    $m1 = $startRegex.Match($Raw)
    if (-not $m1.Success) {
        throw "TOKENS marker not found in $SourceLabel : no line starting with '$StartPrefix'. The upstream marker contract changed; refusing to write a partial file."
    }
    $m2 = $endRegex.Match($Raw, $m1.Index + $m1.Length)
    if (-not $m2.Success) {
        throw "TOKENS marker not found in $SourceLabel : no line starting with '$EndPrefix' after the START marker. The upstream marker contract changed; refusing to write a partial file."
    }

    $nl1 = $Raw.IndexOf("`n", $m1.Index + $m1.Length)
    if ($nl1 -lt 0) { throw "TOKENS marker not found in $SourceLabel : START marker is the last line." }
    $tokensStart = $nl1 + 1
    $tokensEnd   = $m2.Index

    $nl2 = $Raw.IndexOf("`n", $m2.Index + $m2.Length)
    if ($nl2 -lt 0) { $afterEnd = $Raw.Length } else { $afterEnd = $nl2 + 1 }

    # A "line" includes its terminator, so the span from the character after the
    # START line's terminator up to the first character of the END marker line
    # is byte-identical to the source's between-marker lines, terminator and all
    # (including the final between-marker line's own terminator). This keeps
    # tokens.css byte-identical to the source and lets tokens.css + components.css
    # reconstitute the source exactly, minus the two marker lines themselves.
    $tokensRaw = $Raw.Substring($tokensStart, $tokensEnd - $tokensStart)

    return @{
        Tokens     = $tokensRaw
        Components = $Raw.Substring(0, $m1.Index) + $Raw.Substring($afterEnd)
    }
}

# Everything that can fail is funneled through this try/catch and reported via
# Write-Host (stdout) rather than left to propagate as a terminating error. A
# thrown/Write-Error message crossing a process boundary lands in the *stderr*
# stream; a caller that merges child stderr with `2>&1` while running under its
# own $ErrorActionPreference = 'Stop' (as this script's own test harness does)
# treats that merged content as a terminating NativeCommandError and aborts
# before it can inspect $LASTEXITCODE or the captured text. Reporting failures
# on stdout with an explicit exit code keeps the error message inspectable by
# callers in that situation, while still failing loudly (non-zero exit).
try {
    if (-not $SourcePath) { throw "-SourcePath is required." }
    if (-not $UiRoot)     { throw "-UiRoot is required." }

    $globals = Join-Path $SourcePath 'apps\web\app\(frontend)\globals.css'
    if (-not (Test-Path -LiteralPath $globals)) { throw "globals.css not found at $globals" }

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
} catch {
    Write-Host $_.Exception.Message
    exit 1
}
