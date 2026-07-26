<#
.SYNOPSIS
  Validate a built single-file prototype against the shared ui-library/ design system.

.DESCRIPTION
  Enforces ADR-0003 locally, mirroring the production repo's gate:no-raw-style and
  gate:css-vars-defined CI gates. Five rules; every violation is collected and
  reported together, not just the first one found:

    1. No external hosts - every src/href/@import target must be local. This is
       both an Artifact CSP requirement and the self-contained-file requirement.
    2. No raw style values (hex colors, px lengths) outside the verbatim
       ui-library/tokens.css and ui-library/components.css blocks. A prototype must reference a
       token or a component class, never hand-roll a color or a spacing value.
    3. Every var(--x) reference resolves to a custom property defined in
       ui-library/tokens.css or (if given) -OverlayPath.
    4. Every class used in the markup exists in ui-library/components.css.
    5. No email addresses in the markup - a PII lint, not a guarantee; human
       review of a prototype before it is shared is still required.

  Any violation across all five rules causes a non-zero exit; all violations are
  listed, not just the first.

.PARAMETER Path
  The built prototype HTML file to check (a single self-contained file with
  ui-library/tokens.css and ui-library/components.css inlined into a <style> block).

.PARAMETER UiRoot
  Directory containing tokens.css and components.css. Defaults to
  <repo-root>/ui-library, where <repo-root> is two levels above this script's
  own folder (.claude/scripts/../..).

.PARAMETER OverlayPath
  Optional path to a project's tokens.overlay.css. An overlay may redefine an
  existing custom property (e.g. --pri for a per-project brand color) but must
  never introduce a new one - introducing one is reported as a violation.

.NOTES
  Failures are reported on stdout (via Write-Host), not stderr, and signaled only
  by a non-zero exit code. This is deliberate: PS 5.1 aborts a caller that merges
  a child's stderr with 2>&1 under $ErrorActionPreference = 'Stop', before that
  caller ever gets to inspect $LASTEXITCODE or the message. Routing errors to
  stdout keeps both readable to callers in that situation. Callers must branch on
  $LASTEXITCODE, not on stderr content. Every code path below - a bad argument, a
  missing ui-library/ file, or a rule violation - ends in Write-Host + exit, never a bare
  throw escaping the script; the outer try/catch is a last-resort net for any
  exception this script did not anticipate, converted the same way.

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

# Reads a UTF-8 file and normalizes CRLF to LF. The prototype HTML and the ui-library/
# files it embeds can come from different tools or checkouts with different
# line-ending conventions (a Windows checkout of tokens.css vs. a build tool
# that normalizes to LF when it inlines things). Rule 2's whole mechanism is a
# verbatim IndexOf search for the token/component blocks inside the HTML; that
# search must not fail just because a CRLF-vs-LF mismatch shifted every byte
# after the first line. None of the values this script ever reports - hex
# codes, px lengths, class names, custom-property names, email addresses - can
# contain a carriage return, so normalizing away \r before any regex or IndexOf
# runs never changes what gets reported, only whether a legitimate match is
# found.
function Get-NormalizedText {
    param([string]$P)
    return (Read-Utf8Text -P $P).Replace("`r`n", "`n")
}

# Decides whether the character at $Pos in $Text sits in a CSS declaration's
# value position (e.g. the "#fff" in "border: 1px solid #fff;"), as opposed to
# a selector (e.g. "#a1b2c3 { ... }") or plain text such as an HTML fragment
# (href="#a1b2c3"). A hex-shaped token is only a raw-style violation in the
# first case; the id selector and the URL fragment are not style values at
# all, but they are indistinguishable from a genuine raw hex color by shape
# alone - "#a1b2c3" is valid in all three positions.
#
# The heuristic: scan backward from $Pos to the nearest preceding statement
# boundary - '{', '}', or ';' (or the start of the text, if none). If a ':'
# appears between that boundary and $Pos, we are inside the value half of a
# declaration (the colon that separates "property" from "value" is still
# "open"); if no ':' appears there, we are at the start of a fresh statement
# - a selector, or, for non-CSS text such as HTML markup, just prose that
# happens to contain no colon nearby either.
#
# This deliberately does not anchor only on "immediately preceded by a colon",
# which would cause a mirror-image bug: "border: 1px solid #fff;" has other
# value tokens (a length, a keyword) between the colon and the hex, so an
# immediate-colon anchor would miss it as a genuine violation. Verified
# against the real ui-library/components.css multi-value declarations.
function Test-InDeclarationValue {
    param([string]$Text, [int]$Pos)
    $boundary = -1
    for ($i = $Pos - 1; $i -ge 0; $i--) {
        $c = $Text[$i]
        if ($c -eq '{' -or $c -eq '}' -or $c -eq ';') { $boundary = $i; break }
    }
    $span = $Text.Substring($boundary + 1, $Pos - $boundary - 1)
    return $span.Contains(':')
}

try {
    if (-not $UiRoot) { $UiRoot = Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) 'ui-library' }
    if (-not (Test-Path -LiteralPath $Path)) { throw "prototype not found: $Path" }

    $tokensPath = Join-Path $UiRoot 'tokens.css'
    $compPath   = Join-Path $UiRoot 'components.css'
    if (-not (Test-Path -LiteralPath $tokensPath)) { throw "ui-library/tokens.css not found at $tokensPath - run /sync-tokens first." }
    if (-not (Test-Path -LiteralPath $compPath))   { throw "ui-library/components.css not found at $compPath - run /sync-tokens first." }

    $html   = Get-NormalizedText -P $Path
    $tokens = Get-NormalizedText -P $tokensPath
    $comp   = Get-NormalizedText -P $compPath
    $overlay = ''
    if ($OverlayPath) {
        if (-not (Test-Path -LiteralPath $OverlayPath)) { throw "overlay not found: $OverlayPath" }
        $overlay = Get-NormalizedText -P $OverlayPath
    }

    $violations = @()

    # --- Rule 1: no external hosts (Artifact CSP + self-contained requirement)
    foreach ($m in [regex]::Matches($html, '(?i)(?:src|href)\s*=\s*["''][^"'']*?(https?://[^"''\s]+)')) {
        $violations += "external host: $($m.Groups[1].Value)"
    }
    foreach ($m in [regex]::Matches($html, '(?i)@import\s+(?:url\()?["'']?(https?://[^"''\s)]+)')) {
        $violations += "external host in @import: $($m.Groups[1].Value)"
    }

    # --- Locate the inlined tokens.css AND components.css blocks verbatim, so
    # rule 2 can exclude both from the raw-style scan. Both files are the
    # trusted, synced design-system source; only prototype-authored CSS should
    # ever be flagged for a hand-rolled hex color or px length. The real
    # ui-library/components.css legitimately contains hundreds of raw px values in its
    # own selectors (e.g. "border: 1px solid ..."), so excluding only the
    # tokens.css block would flag the entire shared component library on every
    # real build - components.css must be excluded too, not just tokens.css.
    $tokensTrim = $tokens.Trim()
    $compTrim   = $comp.Trim()
    $canScanRule2 = $true
    $outside = $html

    $tokenSpanStart = $outside.IndexOf($tokensTrim)
    if ($tokenSpanStart -lt 0) {
        $violations += "ui-library/tokens.css was not inlined verbatim into this build - cannot evaluate the raw-style rule. Rebuild with the standard inliner."
        $canScanRule2 = $false
    } else {
        $outside = $outside.Remove($tokenSpanStart, $tokensTrim.Length)
    }

    if ($canScanRule2) {
        $compSpanStart = $outside.IndexOf($compTrim)
        if ($compSpanStart -lt 0) {
            $violations += "ui-library/components.css was not inlined verbatim into this build - cannot evaluate the raw-style rule. Rebuild with the standard inliner."
            $canScanRule2 = $false
        } else {
            $outside = $outside.Remove($compSpanStart, $compTrim.Length)
        }
    }

    # --- Rule 2: no raw style values outside the token/component files
    if ($canScanRule2) {
        $scan = $outside
        if ($overlay) { $scan = $scan.Replace($overlay.Trim(), '') }
        foreach ($m in [regex]::Matches($scan, '(?<![&\w])#([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})\b')) {
            if (Test-InDeclarationValue -Text $scan -Pos $m.Index) {
                $violations += "raw hex outside the design-system files: $($m.Value)"
            }
        }
        foreach ($m in [regex]::Matches($scan, '(?<![\w.-])\d+px\b')) {
            $violations += "raw px outside the design-system files: $($m.Value)"
        }
    }

    # --- Collect defined custom properties from tokens.css plus any overlay.
    # A property declaration is not always alone on its own line: tokens.css
    # writes one per line ("  --pri: #ffcb1d;"), but an overlay is commonly a
    # single-line rule ("`:root { --pri: #4f46e5; }`"), where "--pri" is
    # preceded by "{ " rather than starting the line. Anchoring only to
    # (?m)^\s* misses that second, equally valid, form entirely - so match a
    # declaration start either at the beginning of a line or right after a
    # "{" or ";" (the two characters that can precede a declaration).
    $declRx = '(?m)(?:^\s*|[\{;]\s*)(--[A-Za-z0-9-]+)\s*:'
    $defined = @{}
    foreach ($m in [regex]::Matches($tokens, $declRx)) { $defined[$m.Groups[1].Value] = $true }
    $baseDefined = @{} + $defined
    foreach ($m in [regex]::Matches($overlay, $declRx)) {
        $name = $m.Groups[1].Value
        if (-not $baseDefined.ContainsKey($name)) {
            $violations += "overlay introduces a new token '$name' - an overlay may redefine an existing token but never introduce one"
        }
        $defined[$name] = $true
    }

    # --- Rule 3: every var(--x) resolves. --radix-* properties are exempt:
    # Radix UI (used by several components.css primitives - accordion, select,
    # toast) sets these at runtime via an inline style attribute on the DOM
    # node (e.g. --radix-accordion-content-height for a collapse animation),
    # never via a CSS declaration, so they can never appear in tokens.css. Real
    # examples verified against the current ui-library/components.css:
    # --radix-select-trigger-width, --radix-toast-swipe-move-x,
    # --radix-accordion-content-height.
    #
    # Trade-off (accepted, reviewed): this is a blanket prefix exemption, so a
    # typo inside the prefix - e.g. --radix-slect-trigger-width - would pass
    # rule 3 forever; it can never be statically compared against a known
    # list because the names are runtime-injected by Radix, not declared
    # anywhere. The alternative (no exemption) permanently fails every real
    # build using the accordion/select/toast primitives, which is worse.
    # Kept narrowly scoped to the literal "--radix-" prefix rather than a
    # broader allowance.
    foreach ($m in [regex]::Matches($html, 'var\(\s*(--[A-Za-z0-9-]+)')) {
        $name = $m.Groups[1].Value
        if ($name -like '--radix-*') { continue }
        if (-not $defined.ContainsKey($name)) { $violations += "undefined custom property: $name" }
    }

    # --- Rule 4: every class used in the markup exists in components.css
    # url(...) targets are stripped before scanning for class selectors: a path
    # like url("/brand/logo-icon.svg") contains ".svg", which the bare
    # \.identifier pattern would otherwise mistake for a class selector named
    # "svg" and silently widen the known-class set with something that was
    # never a real class.
    $compForClasses = [regex]::Replace($comp, 'url\([^)]*\)', '')
    $known = @{}
    foreach ($m in [regex]::Matches($compForClasses, '\.([A-Za-z][A-Za-z0-9_-]*)')) { $known[$m.Groups[1].Value] = $true }
    foreach ($m in [regex]::Matches($html, '(?i)class\s*=\s*["'']([^"'']*)["'']')) {
        foreach ($cls in ($m.Groups[1].Value -split '\s+')) {
            if ($cls -and -not $known.ContainsKey($cls)) {
                $violations += "class not in components.css: .$cls (unported component, or a typo)"
            }
        }
    }

    # --- Rule 5: no PII. A lint, not a guarantee - human review is still required.
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
} catch {
    Write-Host $_.Exception.Message
    exit 1
}
