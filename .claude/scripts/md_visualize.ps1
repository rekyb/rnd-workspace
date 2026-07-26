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
$evaluator = [System.Text.RegularExpressions.MatchEvaluator]{
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
