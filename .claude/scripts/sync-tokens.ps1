<#
.SYNOPSIS
  Sync the production design tokens and component CSS into this repo's ui-library/ folder.

.DESCRIPTION
  Slices apps/web/app/(frontend)/globals.css from the Solve Education production repo
  at its TOKENS:START / TOKENS:END markers. The lines strictly between the markers
  become ui-library/tokens.css (the design tokens); the rest of the file, minus both marker
  lines, becomes ui-library/components.css (the component classes). Both are byte-exact copies
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
    [string]$RepoUrl = 'https://gitlab.solveeducation.org/solveearn/solveeducation.git',
    [string]$Ref = 'main',
    [string]$SourcePath,
    [string]$UiRoot,
    [string]$SourceSha = '(local)',
    [switch]$Check
)

$ErrorActionPreference = 'Stop'

$script:TempClone = $null

# Default -UiRoot to <repo-root>/ui so the command works with no arguments.
if (-not $UiRoot) { $UiRoot = Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) 'ui-library' }

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

function Remove-TempClone {
    if ($script:TempClone -and (Test-Path -LiteralPath $script:TempClone)) {
        Remove-Item -Recurse -Force $script:TempClone -ErrorAction SilentlyContinue
    }
}

# Run a native git command whose stderr we merge for logging. Under
# $ErrorActionPreference = 'Stop' (set for this whole script), a native command's
# stderr line reaching the pipeline via 2>&1 is promoted to a terminating error the
# instant it is produced - even though it is only being piped to Out-Null - so the
# script would abort on git's very first progress line ("Cloning into ...") instead
# of running to completion and letting us branch on $LASTEXITCODE. Flip the
# preference to Continue only around the native call, then restore it, so 2>&1 can
# be drained quietly and $LASTEXITCODE can be inspected normally afterward.
function Invoke-GitQuiet {
    param([string[]]$GitArgs)
    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & git @GitArgs 2>&1 | Out-Null
    } finally {
        $ErrorActionPreference = $prevEap
    }
    return $LASTEXITCODE
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

# Strip every /* ... */ CSS comment from components.css. Verified against the
# current source that no content: string embeds a comment-like sequence (the
# count of literal /* tokens equals the count of */ tokens, and none appear
# inside a quoted string), so a single non-greedy, dot-matches-newline pass is
# safe. If that invariant ever breaks upstream, this needs string-aware parsing.
function Remove-CssComments {
    param([string]$Css)
    return [regex]::Replace($Css, '(?s)/\*.*?\*/', '')
}

# Removes @import statements whose target is an external (http/https) host -
# those fetch from a remote origin, which breaks the CSP / self-contained
# requirement every claude.ai Artifact consumer of this library depends on. A
# root-relative local path such as url("/brand/logo-icon.svg") is left alone;
# it is not a remote fetch, just a link that renders as a missing image until
# the asset is vendored in - a known, accepted limitation, not a CSP problem.
function Remove-ExternalCssImports {
    param([string]$Css)
    $rx = New-Object System.Text.RegularExpressions.Regex('@import[^;]*;', 'Singleline')
    return $rx.Replace($Css, {
        param($m)
        if ($m.Value -match 'https?://') { '' } else { $m.Value }
    })
}

# Single scrub entry point for components.css, used identically by the write
# path and the -Check path so a difference in scrubbing can never show up as
# phantom drift.
function ConvertTo-ScrubbedComponents {
    param([string]$Css)
    $noComments = Remove-CssComments -Css $Css
    return Remove-ExternalCssImports -Css $noComments
}

# Recursively removes every "$description" property from a parsed JSON object
# graph (PSCustomObject nodes and array nodes), mutating in place. Values,
# nested objects, and arrays of objects are all walked.
function Remove-JsonDescriptions {
    param($Node)
    if ($Node -is [System.Management.Automation.PSCustomObject]) {
        if ($Node.PSObject.Properties.Name -contains '$description') {
            $Node.PSObject.Properties.Remove('$description')
        }
        foreach ($p in @($Node.PSObject.Properties)) {
            Remove-JsonDescriptions -Node $p.Value | Out-Null
        }
    } elseif ($Node -is [System.Array]) {
        foreach ($item in $Node) { Remove-JsonDescriptions -Node $item | Out-Null }
    }
    return $Node
}

# Single scrub entry point for tokens.json: parse (never regex a JSON file),
# strip every $description, and re-emit. Reformatting is fine - tokens.json
# exists only for drift checking, not to be hand-read. Asserts the two
# invariants that matter: the result still parses as JSON, and the number of
# $value leaves is unchanged (a corrupt scrub would silently drop tokens,
# which is worse than a loud failure). Used identically by the write path and
# the -Check path.
function ConvertTo-ScrubbedTokensJson {
    param([string]$Json)
    $beforeCount = ([regex]::Matches($Json, '"\$value"')).Count
    $obj = $Json | ConvertFrom-Json
    Remove-JsonDescriptions -Node $obj | Out-Null
    $scrubbed = $obj | ConvertTo-Json -Depth 100

    $reparsed = $null
    try { $reparsed = $scrubbed | ConvertFrom-Json } catch { $reparsed = $null }
    if ($null -eq $reparsed) {
        throw "tokens.json scrub failed: the scrubbed output does not parse as JSON."
    }
    if (([regex]::Matches($scrubbed, '\$description')).Count -ne 0) {
        throw ("tokens.json scrub failed: " + '$description' + " survived the scrub.")
    }
    $afterCount = ([regex]::Matches($scrubbed, '"\$value"')).Count
    if ($afterCount -ne $beforeCount) {
        throw ("tokens.json scrub failed: " + '$value' + " leaf count changed from $beforeCount to $afterCount.")
    }
    return $scrubbed
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
# ui-library/tokens.css - provenance

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
try {
    if (-not $SourcePath) {
        $base = $env:TEMP
        if (-not $base) { $base = [System.IO.Path]::GetTempPath() }
        $script:TempClone = Join-Path $base ("setokens_" + [guid]::NewGuid().ToString('N'))
        Write-Host "cloning $RepoUrl ($Ref) - about 29 MB, this takes a minute..."
        $env:GIT_TERMINAL_PROMPT = '0'

        # git clone --branch accepts branch/tag names only - it rejects a commit SHA.
        # A 40-char hex Ref is treated as a SHA: clone the default branch shallowly,
        # then try to fetch that exact object. Many servers refuse to serve an
        # arbitrary SHA that isn't a branch/tag tip; if so, fail loudly rather than
        # silently syncing the default branch while reporting success.
        $isSha = $Ref -match '^[0-9a-fA-F]{40}$'

        if ($isSha) {
            if ((Invoke-GitQuiet @('clone', '--depth', '1', $RepoUrl, $script:TempClone)) -ne 0) {
                throw "git clone failed for $RepoUrl. Anonymous read access may have been revoked. The committed ui-library/ files are unaffected; only refresh is blocked."
            }
            if ((Invoke-GitQuiet @('-C', $script:TempClone, 'fetch', '--depth', '1', 'origin', $Ref)) -ne 0) {
                throw "git fetch failed for commit $Ref against $RepoUrl. The server does not appear to permit fetching an arbitrary SHA directly. Refusing to fall back to the default branch, since syncing the wrong ref while reporting success is the worst possible outcome."
            }
            if ((Invoke-GitQuiet @('-C', $script:TempClone, 'checkout', '--detach', 'FETCH_HEAD')) -ne 0) {
                throw "git checkout failed for commit $Ref after the fetch against $RepoUrl succeeded."
            }
        } else {
            if ((Invoke-GitQuiet @('clone', '--depth', '1', '--branch', $Ref, $RepoUrl, $script:TempClone)) -ne 0) {
                throw "git clone failed for $RepoUrl ($Ref). Anonymous read access may have been revoked. The committed ui-library/ files are unaffected; only refresh is blocked."
            }
        }

        $SourcePath = $script:TempClone
        $SourceSha  = (& git -C $script:TempClone rev-parse HEAD).Trim()
    }
    if (-not $UiRoot)     { throw "-UiRoot is required." }

    $globals = Join-Path $SourcePath 'apps\web\app\(frontend)\globals.css'
    if (-not (Test-Path -LiteralPath $globals)) { throw "globals.css not found at $globals" }

    $raw   = Read-Utf8Text -Path $globals
    $split = Split-TokenBlock -Raw $raw -SourceLabel $globals

    $tokensJsonSrc = Join-Path $SourcePath 'packages\tokens\tokens.json'
    if (-not (Test-Path -LiteralPath $tokensJsonSrc)) { throw "tokens.json not found at $tokensJsonSrc" }
    $tokensJson = Read-Utf8Text -Path $tokensJsonSrc

    $propCount  = [regex]::Matches($split.Tokens, '(?m)^\s*--[A-Za-z0-9-]+\s*:').Count

    # tokens.css is never scrubbed (values only, already 0 comments, stays byte-
    # identical). components.css and tokens.json ARE scrubbed - computed once here
    # so the write path and the -Check comparison path can never scrub differently
    # and report permanent phantom drift.
    $scrubbedComponents = ConvertTo-ScrubbedComponents -Css $split.Components
    $scrubbedTokensJson = ConvertTo-ScrubbedTokensJson -Json $tokensJson
    $classCount = ([regex]::Matches($scrubbedComponents, '(?m)^\.[A-Za-z][A-Za-z0-9_-]*') | ForEach-Object { $_.Value } | Sort-Object -Unique).Count

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
        } elseif ((Read-Utf8Text -Path $compPath) -ne $scrubbedComponents) {
            $drift += "components.css differs from the scrubbed source"
        }
        if (-not (Test-Path -LiteralPath $jsonPath)) {
            $drift += "tokens.json is missing from $UiRoot"
        } elseif ((Read-Utf8Text -Path $jsonPath) -ne $scrubbedTokensJson) {
            $drift += "tokens.json differs from the scrubbed source"
        }

        if ($drift.Count -gt 0) {
            Write-Host "DRIFT detected against $SourceSha" -ForegroundColor Red
            $drift | ForEach-Object { Write-Host $_ }
            Remove-TempClone
            exit 1
        }
        Write-Host "in sync with $SourceSha ($propCount custom properties, $classCount class selectors)" -ForegroundColor Green
        Remove-TempClone
        exit 0
    }

    if (-not (Test-Path -LiteralPath $UiRoot)) { New-Item -ItemType Directory -Force -Path $UiRoot | Out-Null }

    $previous = $null
    if (Test-Path -LiteralPath $tokensPath) { $previous = Get-TokenMap (Read-Utf8Text -Path $tokensPath) }

    Write-Utf8NoBom -Path $tokensPath -Text $split.Tokens
    Write-Utf8NoBom -Path $compPath   -Text $scrubbedComponents
    Write-Utf8NoBom -Path $jsonPath   -Text $scrubbedTokensJson

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
    Remove-TempClone
    exit 0
} finally {
    Remove-TempClone
}
} catch {
    Write-Host $_.Exception.Message
    exit 1
}
