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
