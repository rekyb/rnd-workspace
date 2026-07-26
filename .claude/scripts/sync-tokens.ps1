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

    # Use instance Regex objects so the END search can start at an offset via the
    # Match(input, startat) overload. The static [regex]::Match(string, pattern, int)
    # call resolves to the (string, string, RegexOptions) overload instead — PowerShell
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

    # The substring up to $tokensEnd still carries the single line terminator that
    # ends the last between-marker line (it terminates that line, immediately
    # followed by the END marker line) — strip exactly one, preserving whichever
    # terminator the source used, so tokens.css has no trailing blank line.
    $tokensRaw = $Raw.Substring($tokensStart, $tokensEnd - $tokensStart)
    if ($tokensRaw.EndsWith("`r`n")) {
        $tokensRaw = $tokensRaw.Substring(0, $tokensRaw.Length - 2)
    } elseif ($tokensRaw.EndsWith("`n")) {
        $tokensRaw = $tokensRaw.Substring(0, $tokensRaw.Length - 1)
    }

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

    if (-not (Test-Path -LiteralPath $UiRoot)) { New-Item -ItemType Directory -Force -Path $UiRoot | Out-Null }

    Write-Utf8NoBom -Path (Join-Path $UiRoot 'tokens.css')     -Text $split.Tokens
    Write-Utf8NoBom -Path (Join-Path $UiRoot 'components.css') -Text $split.Components

    $propCount  = [regex]::Matches($split.Tokens, '(?m)^\s*--[A-Za-z0-9-]+\s*:').Count
    $classCount = ([regex]::Matches($split.Components, '(?m)^\.[A-Za-z][A-Za-z0-9_-]*') | ForEach-Object { $_.Value } | Sort-Object -Unique).Count
    Write-Host "tokens.css: $propCount custom properties"
    Write-Host "components.css: $classCount unique class selectors"
    exit 0
} catch {
    Write-Host $_.Exception.Message
    exit 1
}
