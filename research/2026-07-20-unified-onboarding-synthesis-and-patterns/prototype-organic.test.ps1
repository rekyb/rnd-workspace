$ErrorActionPreference = 'Stop'

$prototypePath = Join-Path $PSScriptRoot 'prototype-organic.html'

if (-not (Test-Path -LiteralPath $prototypePath)) {
    throw "FAIL: prototype-organic.html does not exist"
}

$html = Get-Content -LiteralPath $prototypePath -Raw
$failures = [System.Collections.Generic.List[string]]::new()

$requiredScreens = @(
    'landing',
    'age-gate',
    'discovery',
    'recommendations',
    'program-preview',
    'program-confirmation',
    'registration',
    'enrollment-confirmation',
    'program-welcome'
)

foreach ($screen in $requiredScreens) {
    if ($html -notmatch ('id="screen-' + [regex]::Escape($screen) + '"')) {
        $failures.Add("Missing screen: $screen")
    }
}

$requiredPatterns = @{
    'navigation controls' = 'data-go='
    'semantic main' = '<main'
    'progress semantics' = 'aria-valuenow='
    'live region' = 'aria-live="polite"'
    'mobile breakpoint' = '@media\s*\(min-width:\s*48rem\)'
    'wide breakpoint' = '@media\s*\(min-width:\s*80rem\)'
    'reduced motion' = 'prefers-reduced-motion'
    'focus treatment' = ':focus-visible'
    'age validation' = 'validateAge'
    'otp simulation' = 'verifyOtp'
}

foreach ($entry in $requiredPatterns.GetEnumerator()) {
    if ($html -notmatch $entry.Value) {
        $failures.Add("Missing $($entry.Key)")
    }
}

$forbiddenInteractivePatterns = @(
    '>\s*Lesson 0\s*<',
    '>\s*Skill Check\s*<',
    '>\s*Baseline assessment\s*<',
    '>\s*Placement result\s*<'
)

foreach ($pattern in $forbiddenInteractivePatterns) {
    if ($html -match $pattern) {
        $failures.Add("Forbidden assessment mechanic found: $pattern")
    }
}

if ($html -match 'https?://') {
    $failures.Add('External URL found; prototype must be self-contained')
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    throw "FAIL: $($failures.Count) prototype contract check(s) failed"
}

Write-Output "PASS: organic onboarding prototype satisfies $($requiredScreens.Count) screens and all contract checks"
