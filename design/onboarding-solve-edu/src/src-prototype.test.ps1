# Regression suite for the src/ build: the split onboarding funnel plus the
# first-run Learning Home.
#
# Why this file exists. The flat prototype rendered a 1-day streak, a 150-point
# total, a 40% progress bar, and "Welcome back!" to an account created seconds
# earlier, and prototype-web.test.ps1 asserted against none of them. The
# 2026-07-28 benchmark was commissioned partly because of that, and PRD Cycle 2
# removes it. These tests exist so it cannot come back quietly.
#
# Run: powershell -NoProfile -File src-prototype.test.ps1

$ErrorActionPreference = 'Stop'

$onboarding = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'onboarding.html') -Raw
$homeHtml   = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'home.html') -Raw
$homeJs     = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'home.js') -Raw
$mainJs     = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'main.js') -Raw
$styles     = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'styles.css') -Raw

# A comment is neither rendered nor executed, so a "must not contain" assertion
# has to ignore them. Without this, the comment explaining why there is no
# streak reads as a streak, and the comment stating that no ranker is consulted
# reads as a ranker.
function Remove-Comments([string]$Text) {
  $t = [regex]::Replace($Text, '(?s)<!--.*?-->', '')
  return [regex]::Replace($t, '(?s)/\*.*?\*/', '')
}

$homeRendered = Remove-Comments $homeHtml
$homeCode     = Remove-Comments $homeJs
$mainCode     = Remove-Comments $mainJs
$all          = $onboarding + "`n" + $homeHtml + "`n" + $homeJs + "`n" + $mainJs

$script:Failures = New-Object System.Collections.Generic.List[string]
$script:Checks = 0

function Check([bool]$Condition, [string]$Message) {
  $script:Checks++
  if (-not $Condition) { $script:Failures.Add($Message) | Out-Null }
}

function Show-Group([string]$Name) { Write-Host "-- $Name" }

# ---------------------------------------------------------------- 1
Show-Group 'No fabricated progress reaches the learner'

Check ($homeRendered -notmatch '(?i)welcome back') `
  'home.html greets the learner with "Welcome back". A first run is not a return (Slice 12)'
Check ($homeRendered -notmatch '(?i)day streak') `
  'home.html renders a streak value. Streaks are a PRD non-goal'
Check ($homeRendered -notmatch '(?i)streak') `
  'home.html shows a streak affordance. The locked-leaderboard finding was held, not adopted'
Check ($homeRendered -notmatch 'rounded">stars<') `
  'home.html renders the points pill. Points are a PRD non-goal'
Check ($homeRendered -notmatch 'width:\s*[1-9][0-9]*%') `
  'home.html hard-codes a non-zero progress width. Every fill must be computed from data'
Check ($mainCode -notmatch 'General Skills Mastery') `
  'main.js still falls back to a substituted default course. Slice 13 forbids substituting one'
Check ($homeCode -notmatch 'General Skills Mastery') `
  'home.js substitutes a default course'

# ---------------------------------------------------------------- 2
Show-Group 'Every zero states, in the same slot, what would change it'

Check ($homeHtml -match 'id="home_course_count"') 'home.html has no count slot'
Check ($homeHtml -match 'id="home_course_condition"') `
  'home.html has no condition slot. A zero without its condition is just a zero (benchmark F2)'
Check ($homeCode -match 'function conditionFor') 'home.js has no conditionFor()'
Check ($homeCode -match 'to see progress here') `
  'home.js does not state the countable condition at zero'
Check ($homeCode -match "of ' \+ total") `
  'home.js does not build the count from data. It must never be a literal'

# ---------------------------------------------------------------- 3
Show-Group 'The first action comes from stored intake, not from behaviour'

Check ($mainCode -match 'function finishOnboarding') 'main.js has no finishOnboarding()'
Check ($mainCode -match 'initialCourseId') `
  'main.js does not resolve a course id at finalization. Slice 13 needs it stored, not recomputed'
Check ($mainCode -match "location\.href = 'home\.html'") 'main.js does not hand off to home.html'
Check ($mainCode -notmatch "goTo\('learning_home'\)") `
  'main.js still routes to an in-page learning_home screen'
Check ($onboarding -notmatch 'id="learning_home"') `
  'onboarding.html still contains the learning_home screen. It belongs to home.html now'
Check ($homeCode -notmatch '(?i)(recency|popularity|trending|recommendedFor)') `
  'home.js consults a ranker. At first run there is nothing to rank (Slice 13 structural test)'

# ---------------------------------------------------------------- 4
Show-Group 'The unmapped goal substitutes nothing'

Check ($homeHtml -match 'id="home_unmapped"') 'home.html has no unmapped-goal state'
Check ($homeRendered -match '(?i)not a starting point') `
  'the unmapped state does not explain why nothing was chosen'
Check ($homeCode -match 'initialCourseId') 'home.js does not branch on the stored course id'
Check ($mainCode -match 'COURSE_MAP') 'main.js has no course map'
Check ($mainCode -notmatch "'language':") `
  "main.js maps 'language'. It is deliberately unmapped so the empty state stays reachable"

# ---------------------------------------------------------------- 5
Show-Group 'First run is a real branch, not trivially true'

Check ($homeCode -match 'firstActionAt') 'home.js does not track firstActionAt'
Check ($homeCode -match 'firstActionAt === null') `
  'home.js does not branch on firstActionAt. Without it every learner is first-run forever'
Check ($homeCode -match 'Ready when you are') 'home.js has no first-run greeting'
Check ($homeCode -match 'Good to see you again') 'home.js has no returning greeting'

# ---------------------------------------------------------------- 6
Show-Group 'The labelled wait cannot flash'

Check ($homeHtml -match 'id="home_loading"') 'home.html has no loading state'
Check ($homeHtml -match 'role="status"') `
  'the loading region is not announced. WCAG 2.2 4.1.3 for the one message that matters'
Check ($homeCode -match 'SKELETON_DELAY_MS\s*=\s*400') `
  'home.js does not delay the skeleton 400ms (Doherty threshold)'
Check ($homeCode -match 'SKELETON_MIN_MS\s*=\s*500') `
  'home.js does not hold the skeleton a minimum. A 50ms flash reads worse than the case it bans'
Check ($styles -match '\.home-skel') 'styles.css has no skeleton style, so the loading state is invisible'
Check ($styles -match 'prefers-reduced-motion') 'the skeleton animation ignores prefers-reduced-motion'

# ---------------------------------------------------------------- 7
Show-Group 'No prototype scaffolding leaks into the product surface'

Check ($homeRendered -notmatch 'data-screen=') `
  'home.html carries a state switcher. The prototype is a journey, not a state gallery'
Check ($homeRendered -notmatch '(?i)lorem ipsum') 'home.html carries placeholder text'
Check ($homeRendered -notmatch 'id="global-header"') `
  'home.html reinstates the top nav. The sidebar already carries the brand and navigation'

# ---------------------------------------------------------------- 8
Show-Group 'PII and internal specifics stay out'

# info@solveeducation.org is the organisation's published contact address, in the
# reference prototype's footer since 2026-07-21. It is not learner PII. Anything
# else that looks like a real address is.
$emailPattern = '[A-Za-z0-9._%+-]+@(?!example\.com|solveeducation\.org)[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
Check ($all -notmatch $emailPattern) `
  'an address that is neither a placeholder nor the published org contact appears in the source'
Check ($homeRendered -notmatch '(?i)(funder|grant number)') 'internal specifics appear in home.html'

# ---------------------------------------------------------------- report
Write-Host ''
if ($script:Failures.Count -eq 0) {
  Write-Host "src-prototype.test.ps1 PASSED - $($script:Checks) checks, 8 groups"
  exit 0
}
Write-Host "src-prototype.test.ps1 FAILED - $($script:Failures.Count) of $($script:Checks) checks"
foreach ($f in $script:Failures) { Write-Host "  - $f" }
exit 1
