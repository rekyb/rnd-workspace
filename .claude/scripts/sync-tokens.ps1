<#
.SYNOPSIS
  Sync the production design tokens and component CSS into this repo's ui-library/ folder.

.DESCRIPTION
  Slices apps/web/app/(frontend)/globals.css from the upstream production repo
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
  powershell -File sync-tokens.ps1 -SourcePath C:\tmp\checkout -UiRoot C:\repo\ui-library

.EXAMPLE
  powershell -File sync-tokens.ps1 -RepoUrl https://host/group/project.git -Ref main

.NOTES
  -RepoUrl has no default on purpose. The upstream repo URL is not stored anywhere in
  this public repo, so /sync-tokens asks the user for it on every run and passes it in.
  Supplying -SourcePath (a local checkout) instead skips the clone and needs no URL.
#>
[CmdletBinding()]
param(
    [string]$RepoUrl,
    [string]$Ref = 'main',
    [string]$SourcePath,
    [string]$UiRoot,
    [string]$SourceSha = '(local)',
    [switch]$Check
)

$ErrorActionPreference = 'Stop'

$script:TempClone = $null

# Default -UiRoot to <repo-root>/ui-library so the command works with no arguments.
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
#
# That "verified once by a human" note used to be the only guard. It is not
# self-enforcing: if upstream ever introduces a `content: "..."` string value
# that embeds a stray /* or */, this same non-greedy pass can mis-pair - either
# truncating a comment removal early (leaving comment fragments as literal
# text) or, worse, treating an unmatched opener as the start of one giant
# comment that swallows real rules up to the next unrelated */ elsewhere in
# the file. See Assert-ComponentsScrubIntegrity below for the runtime check
# that replaces the one-time human verification.
function Remove-CssComments {
    param([string]$Css)
    return [regex]::Replace($Css, '(?s)/\*.*?\*/', '')
}

# Counts unique line-anchored class selectors the same way the write path
# reports "$classCount unique class selectors" (?m)^\.[A-Za-z][A-Za-z0-9_-]*).
# Used both before and after the scrub so a mis-paired comment removal that
# swallows (or exposes) a class selector shows up as a count change.
function Get-ClassSelectorCount {
    param([string]$Css)
    return ([regex]::Matches($Css, '(?m)^\.[A-Za-z][A-Za-z0-9_-]*') | ForEach-Object { $_.Value } | Sort-Object -Unique).Count
}

# Runtime replacement for the one-time human check described above Remove-CssComments.
# A non-greedy /\*.*?\*/ pass has no notion of CSS syntax - it just pairs the
# nearest /* with the nearest following */. A stray /* or */ embedded inside a
# quoted string (e.g. a future `content: "/*";`) can make it mis-pair, either
# leaving comment fragments as literal text or, in the worst case, swallowing
# one or more real rules between an unmatched opener and some unrelated later
# */. Two cheap, syntax-agnostic invariants catch that class of corruption
# without needing a real CSS parser:
#   1. the unique class-selector count must be unchanged by the scrub (a
#      swallowed rule loses its selector; a truncated comment can expose a
#      false one) - verified against the real upstream source, which scrubs
#      3200+ selector occurrences down to 239 unique with no change from this
#      check;
#   2. braces must still balance after the scrub (a swallowed rule takes an
#      unmatched brace with it).
# Neither is a full parse, so a corruption that happens to preserve both the
# selector count and the brace balance would still slip through - but either
# invariant firing means the scrub did something a plain comment/import strip
# should never do, and this is deliberately loud (throw) rather than a silent
# gutted write.
function Assert-ComponentsScrubIntegrity {
    param([string]$Before, [string]$After)
    $beforeClasses = Get-ClassSelectorCount -Css $Before
    $afterClasses  = Get-ClassSelectorCount -Css $After
    if ($afterClasses -ne $beforeClasses) {
        throw ("components.css scrub failed: unique class-selector count changed from " +
               "$beforeClasses to $afterClasses. The comment-stripping regex likely mis-paired " +
               "on a /* or */ embedded inside a quoted string (e.g. a content: value) upstream; " +
               "this needs string-aware parsing, not a quick patch. Refusing to write a possibly " +
               "gutted components.css.")
    }
    $openCount  = ([regex]::Matches($After, '\{')).Count
    $closeCount = ([regex]::Matches($After, '\}')).Count
    if ($openCount -ne $closeCount) {
        throw ("components.css scrub failed: braces are unbalanced after scrubbing " +
               "($openCount '{' vs $closeCount '}'). The comment-stripping regex likely mis-paired " +
               "on a /* or */ embedded inside a quoted string upstream; refusing to write a " +
               "possibly gutted components.css.")
    }
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
    $scrubbed = Remove-ExternalCssImports -Css $noComments
    Assert-ComponentsScrubIntegrity -Before $Css -After $scrubbed
    return $scrubbed
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
#
# Line endings only, not indentation, are normalized before returning.
# ConvertTo-Json -Depth 100 is PowerShell-implementation-defined: Windows
# PowerShell 5.1 emits right-aligned indentation with CRLF; PowerShell 7 emits
# two-space indentation with LF. Both call sites in this script (the write
# path and the -Check path) always call this same function within a single
# run, so the two can never disagree with each other in that run - but a file
# committed by one PowerShell version and later -Check'd by the other (e.g.
# this script committed under Windows PowerShell 5.1, then `pwsh -File
# sync-tokens.ps1 -Check` run on macOS/Linux, the only option there) would
# otherwise report the entire file as drift on line endings alone. Replacing
# CRLF with LF here - and doing the same to the on-disk file before comparing,
# see the -Check block below - neutralizes that one axis. The indentation
# axis (two-space vs right-aligned) is NOT normalized: reproducing one
# version's exact alignment from the other would mean hand-rolling a JSON
# pretty-printer, which is disproportionate for a file that exists only for
# drift-checking, not to be hand-read. A -Check run under a different
# PowerShell version than the one that last wrote tokens.json can therefore
# still report spurious drift from indentation alone; the -Check block below
# reports a diff hint (index, lengths, both sides' surrounding text) precisely
# so an operator hitting this can tell an indentation artifact from real
# content drift, instead of seeing only "tokens.json differs from the
# scrubbed source" with nothing to act on.
function ConvertTo-ScrubbedTokensJson {
    param([string]$Json)
    $beforeCount = ([regex]::Matches($Json, '"\$value"')).Count
    $obj = $Json | ConvertFrom-Json
    Remove-JsonDescriptions -Node $obj | Out-Null
    $scrubbed = $obj | ConvertTo-Json -Depth 100
    $scrubbed = $scrubbed.Replace("`r`n", "`n")

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

# Reports where two texts first diverge, with enough surrounding context that
# an operator can tell a formatting artifact (e.g. the PowerShell 5.1 vs 7
# ConvertTo-Json indentation difference described above
# ConvertTo-ScrubbedTokensJson) apart from a real content change, rather than
# just being told the two strings are unequal.
function Get-TextDiffHint {
    param([string]$Old, [string]$New)
    $minLen = [Math]::Min($Old.Length, $New.Length)
    $i = 0
    while ($i -lt $minLen -and $Old[$i] -eq $New[$i]) { $i++ }
    $ctx = 20
    $oldFrom = [Math]::Max(0, $i - $ctx)
    $newFrom = [Math]::Max(0, $i - $ctx)
    $oldSnippet = $Old.Substring($oldFrom, [Math]::Min($ctx * 2, $Old.Length - $oldFrom))
    $newSnippet = $New.Substring($newFrom, [Math]::Min($ctx * 2, $New.Length - $newFrom))
    return ("first difference at character $i (committed length $($Old.Length), freshly-scrubbed " +
            "length $($New.Length)) - committed: ...$oldSnippet... vs freshly-scrubbed: ...$newSnippet...")
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

Design tokens extracted verbatim from the upstream production repo. Do not
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
        if (-not $RepoUrl) {
            throw "-RepoUrl is required when no -SourcePath is given. The upstream repo URL is deliberately not stored in this repo, so /sync-tokens asks for it on every run. Re-run with -RepoUrl <url>, or pass -SourcePath <local checkout> to skip the clone."
        }
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
        # Normalize CRLF -> LF on BOTH sides before comparing, exactly as the
        # tokens.json comparison below already does. The write path stays byte-
        # preserving (Test 6) - this affects only what counts as drift.
        #
        # Without this, --check is a permanent false positive off Windows. With
        # core.autocrlf=true git stores tokens.css and components.css as LF and
        # checks them out as CRLF, so they match a CRLF upstream on Windows only;
        # a clone on Linux/macOS/CI materializes the LF blob as-is and every line
        # reads as drift. Line endings are not what the guardrail exists to catch
        # - a hand-edited value is, and that still surfaces (Test 22 vs the
        # existing "--check exits non-zero on drift" / "names the drifted token").
        $normalizeEol = { param($t) $t.Replace("`r`n", "`n") }
        if (-not (Test-Path -LiteralPath $tokensPath)) {
            $drift += "tokens.css is missing from $UiRoot"
        } else {
            $current = & $normalizeEol (Read-Utf8Text -Path $tokensPath)
            if ($current -ne (& $normalizeEol $split.Tokens)) {
                $drift += "tokens.css differs from the source:"
                $drift += (Compare-TokenMaps -Old (Get-TokenMap $current) -New (Get-TokenMap $split.Tokens))
            }
        }
        if (-not (Test-Path -LiteralPath $compPath)) {
            $drift += "components.css is missing from $UiRoot"
        } elseif ((& $normalizeEol (Read-Utf8Text -Path $compPath)) -ne (& $normalizeEol $scrubbedComponents)) {
            $drift += "components.css differs from the scrubbed source"
        }
        if (-not (Test-Path -LiteralPath $jsonPath)) {
            $drift += "tokens.json is missing from $UiRoot"
        } else {
            # Normalize CRLF -> LF on the on-disk side too before comparing:
            # $scrubbedTokensJson is already LF-normalized (see
            # ConvertTo-ScrubbedTokensJson), but the committed file may predate
            # that normalization, or have been written by a PowerShell version
            # whose ConvertTo-Json emits CRLF. Comparing both sides post-
            # normalization means a pure line-ending difference is never
            # reported as drift; only a genuine content (or indentation-style)
            # difference reaches the comparison below.
            $currentJson = (Read-Utf8Text -Path $jsonPath).Replace("`r`n", "`n")
            if ($currentJson -ne $scrubbedTokensJson) {
                $hint = Get-TextDiffHint -Old $currentJson -New $scrubbedTokensJson
                $drift += ("tokens.json differs from the scrubbed source ($hint). Note: " +
                           "ConvertTo-Json's indentation style (not just line endings) differs " +
                           "between Windows PowerShell 5.1 and PowerShell 7, and this script does " +
                           "not normalize indentation - so this may be a formatting artifact from " +
                           "running -Check under a different PowerShell version than the one that " +
                           "last wrote tokens.json, not real content drift. Compare the hint above " +
                           "against the token/class counts reported elsewhere before treating this " +
                           "as real drift.")
            }
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
- **Source repo:** upstream production repo (URL configured in .claude/scripts/sync-tokens.ps1)
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
