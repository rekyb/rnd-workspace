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

  LOAD-BEARING DEPENDENCY - why check-prototype.ps1 rule 2 currently works.
  Rule 2 (no raw hex / raw px outside the design-system files) can only run if it
  finds tokens.css AND components.css inlined BYTE-FOR-BYTE VERBATIM in the built
  file, so it can subtract them before scanning. Today they do survive verbatim
  only by luck of content, not by any guarantee in this script: tokens.css
  contains no url() at all, and components.css's single asset reference is
  root-absolute - url("/brand/logo-icon.svg") - which rule 5 above passes through
  untouched thanks to the negative lookahead in $assetPattern.
  If a future /sync-tokens ever lands ONE RELATIVE image reference in either file
  (e.g. url("img/logo.svg")), pass 4 would rewrite it to a data: URI, the inlined
  text would no longer match the file on disk, and rule 2 would stop enforcing
  anything. It fails closed rather than silently: check-prototype.ps1 emits a
  "... was not inlined verbatim into this build" violation and exits non-zero, so
  every export would start failing the gate until this builder is taught to
  exempt the ui-library/ stylesheets from asset rewriting. Fix it there - do not
  "fix" it by loosening rule 2.

  RELATED, currently harmless: ui-library/behaviors.js is inlined by pass 2 but is
  NOT exempted from rule 2 (only the two stylesheets are). It contains zero px and
  zero hex values today, so there is no conflict. But any future ported behavior
  that writes a raw value - el.style.height = x + 'px' - would fail rule 2 on
  every export of every project. That exemption would have to be added to
  check-prototype.ps1, not worked around here.

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

  A [regex]::Replace MatchEvaluator scriptblock's own "exit" call is not reliable
  in PowerShell 5.1 - it does not always terminate the parent process, only the
  evaluator's own execution. So the evaluators below never call exit directly:
  they record a problem via Add-BuildError and return the ORIGINAL matched text
  unchanged, and the script checks $script:Errors (via Test-BuildErrors) right
  after each replace pass, exiting there instead. Only the top-level, non-nested
  checks (project folder / entry file missing) call Fail (which does exit)
  directly, since those run outside any scriptblock and exit reliably.

  $matches is scoped inside a scriptblock and may come back empty there, so
  attribute extraction uses [regex]::Match(...).Groups[...] explicitly instead of
  relying on the automatic $matches variable.

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

$script:Errors = New-Object System.Collections.Generic.List[string]

function Fail {
    param([string]$Message)
    Write-Host "build-prototype: $Message"
    exit 1
}

function Add-BuildError {
    param([string]$Message)
    $script:Errors.Add($Message) | Out-Null
}

function Test-BuildErrors {
    if ($script:Errors.Count -gt 0) {
        foreach ($e in $script:Errors) { Write-Host "build-prototype: $e" }
        exit 1
    }
}

function Test-External {
    param([string]$Reference)
    if ($Reference -match '^//') { return $true }
    if ($Reference -match '^[A-Za-z][A-Za-z0-9+.-]*:') {
        if ($Reference -match '(?i)^data:') { return $false }
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
            Add-BuildError "asset not found: $rel (referenced from $Origin)"
            return $match.Value
        }
        $ext = [IO.Path]::GetExtension($path).ToLowerInvariant()
        $mime = switch ($ext) {
            '.png'  { 'image/png' }
            '.jpg'  { 'image/jpeg' }
            '.jpeg' { 'image/jpeg' }
            '.gif'  { 'image/gif' }
            '.webp' { 'image/webp' }
            '.svg'  { 'image/svg+xml' }
            default { $null }
        }
        if (-not $mime) {
            Add-BuildError "unsupported image type: $ext (referenced from $Origin)"
            return $match.Value
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
    $hrefMatch = [regex]::Match($tag, 'href\s*=\s*["''](?<href>[^"'']+)["'']')
    if (-not $hrefMatch.Success) {
        Add-BuildError "stylesheet link with no href: $tag"
        return $match.Value
    }
    $href = $hrefMatch.Groups['href'].Value
    if (Test-External -Reference $href) {
        Add-BuildError "external stylesheet cannot be inlined: $href"
        return $match.Value
    }
    $path = Resolve-Ref -Reference $href -BaseDir $entryDir
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        Add-BuildError "stylesheet not found: $href"
        return $match.Value
    }
    $css = [IO.File]::ReadAllText($path, [Text.Encoding]::UTF8)
    $css = Convert-Assets -Text $css -BaseDir (Split-Path -Parent $path) -Origin $href
    return "<style>`r`n$css`r`n</style>"
})
Test-BuildErrors

# --- Inline scripts -------------------------------------------------------
$scriptPattern = '<script\b[^>]*\bsrc\s*=\s*["''][^"'']+["''][^>]*>\s*</script>'
$html = [regex]::Replace($html, $scriptPattern, {
    param($match)
    $tag = $match.Value
    $srcMatch = [regex]::Match($tag, 'src\s*=\s*["''](?<src>[^"'']+)["'']')
    if (-not $srcMatch.Success) {
        Add-BuildError "script tag with no src: $tag"
        return $match.Value
    }
    $src = $srcMatch.Groups['src'].Value
    if (Test-External -Reference $src) {
        Add-BuildError "external script cannot be inlined: $src"
        return $match.Value
    }
    $path = Resolve-Ref -Reference $src -BaseDir $entryDir
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        Add-BuildError "script not found: $src"
        return $match.Value
    }
    $js = [IO.File]::ReadAllText($path, [Text.Encoding]::UTF8)
    return "<script>`r`n$js`r`n</script>"
})
Test-BuildErrors

# --- Inline assets referenced by the markup itself ------------------------
$html = Convert-Assets -Text $html -BaseDir $entryDir -Origin (Split-Path -Leaf $entryFull)
Test-BuildErrors

# --- Write ----------------------------------------------------------------
$outDir = Split-Path -Parent $Out
if ($outDir -and -not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
}
[IO.File]::WriteAllText($Out, $html, [Text.UTF8Encoding]::new($false))
Write-Output "Built $((Resolve-Path -LiteralPath $Out).Path)"
exit 0
