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

# ---------------------------------------------------------------- 0
Show-Group 'The scripts actually parse'

# This group exists because a 2026-07-30 edit closed an array with a brace,
# main.js failed to parse, every handler failed to bind, and "Get started" did
# nothing — while all 80 text-pattern checks stayed green. A suite that reads
# source as text cannot tell working code from a syntax error. If Node is
# absent the checks are skipped loudly rather than silently passing, because a
# skipped check that reports success is the failure mode this whole file is
# written against.
$node = Get-Command node -ErrorAction SilentlyContinue
if ($node) {
  # $ErrorActionPreference is 'Stop' for this file, and a native command that
  # writes to stderr becomes a terminating error under it — so the first failing
  # parse aborted the run instead of reporting a failed check. Relaxed around
  # the node calls only, with every stream discarded, so the exit code is the
  # signal. A check that crashes the suite is not a check that reports.
  $prevEAP = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  foreach ($f in 'main.js', 'home.js', 'data.js') {
    $path = Join-Path $PSScriptRoot $f
    & node --check $path *> $null
    Check ($LASTEXITCODE -eq 0) "$f does not parse. Nothing in it runs, so every control on the page is inert"
  }
  $ErrorActionPreference = $prevEAP
} else {
  Write-Host '   SKIPPED - node not on PATH, so the scripts were not parsed'
  $script:Failures.Add('node is unavailable, so the parse checks did not run. Treat this suite as incomplete') | Out-Null
  $script:Checks++
}

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

# ---------------------------------------------------------------- 9
Show-Group 'The navigation says where the learner is, to everyone'

# Layout F2: every benchmarked platform marks the current destination; ours
# marked it visually and told assistive technology nothing. The visible half
# already shipped, so what these guard is the half that was missing.
#
# 2026-07-30: the navigation moved from a left sidebar to a top bar, and the
# eleven production destinations were reorganized into four top-level families.
# The landmark, marking and icon rules are unchanged in intent; what changed is
# the shell they live in.
Check ($homeRendered -notmatch 'home-sidebar') `
  'the sidebar is still present. The Learning Home navigation is a top bar now'
Check ($homeRendered -notmatch '<aside') `
  'navigation still sits in a complementary landmark'
Check ((([regex]::Matches($homeRendered, '<header class="home-topbar"')).Count) -eq 3) `
  'not all three views carry the top bar'
Check ((([regex]::Matches($homeRendered, 'role="banner"')).Count) -eq 3) `
  'the top bar is not a banner landmark in every view'
Check ((([regex]::Matches($homeRendered, '<nav class="home-nav" aria-label="Main">')).Count) -eq 3) `
  'the navigation is not a named nav landmark in every view'
Check (([regex]::Matches($homeRendered, 'aria-current="page"')).Count -eq 3) `
  'not every view marks its current destination. All three carry the same navigation, so all three must mark it'
# The label follows the icon span, so the text node carries a leading space:
# `</span> Learn</button>`. Matching '>Learn<' finds nothing.
foreach ($fam in 'Home', 'Learn', 'Portfolio', 'Work') {
  Check ((([regex]::Matches($homeRendered, ">\s*$fam\s*<")).Count) -ge 3) `
    "the top level is missing '$fam' in at least one view"
}
Check ($homeRendered -notmatch '>Courses<') `
  'the invented Courses destination is still present. The real IA replaces it'
Check ($homeRendered -notmatch '>Achievements<') `
  'the invented Achievements destination is still present. Portfolio replaces it'
Check ($homeRendered -notmatch '<div class="home-nav-item') `
  'a destination is still a non-semantic div. It must be operable by keyboard, not merely clickable'
# Count icon spans whose own tag lacks aria-hidden, not every icon span.
$bareIcons = ([regex]::Matches($homeRendered, '<span[^>]*material-symbols-rounded(?![^>]*aria-hidden)[^>]*>')).Count
Check ($bareIcons -eq 0) `
  "$bareIcons icon spans carry no aria-hidden. Without it a destination is announced with its icon ligature"

# ---------------------------------------------------------------- 10
Show-Group 'Fill is spent once, so it still ranks something'

# Layout F4: fill is a ranking signal only while exactly one control owns it.
# The Up Next card was a filled purple block directly above a filled purple
# button, which is the two-signal defect the benchmark measured on our own home.
Check ($homeRendered -notmatch 'background:\s*var\(--purple\)') `
  'a content block is filled with the primary colour again. Only the primary action may carry fill (layout F4)'
Check ($styles -match '\.up-next-eyebrow') 'styles.css has no Up Next surface treatment'
# The invariant is per data state, not per file: the Learning Home carries two
# filled buttons in markup (the mapped action and the unmapped recovery) and
# home.js gates them on the same boolean with opposite senses, so exactly one
# is ever reachable. Counting the whole file would also sweep in the skill
# screen, which is a different surface.
$homeSection = ''
if ($homeRendered -match '(?s)id="learning_home"(.*?)id="skill_screen"') { $homeSection = $Matches[1] }
Check ($homeSection.Length -gt 0) 'could not isolate the learning_home markup'
$primaryButtons = ([regex]::Matches($homeSection, 'class="btn btn-primary')).Count
Check ($primaryButtons -eq 2) `
  "the Learning Home carries $primaryButtons filled buttons in markup; expected the mapped action plus the unmapped recovery"
Check ($homeCode -match "show\('home_unmapped', !mapped\)" -and $homeCode -match "show\('start-lesson-btn', mapped\)") `
  'the mapped action and the unmapped recovery are not gated on the same boolean, so both could render at once'
# Measured at 360px: .btn sets display: inline-flex, which outranks [hidden] and
# an unweighted class, so the "hidden" primary action stayed on screen beside
# the unmapped recovery and the surface carried two filled controls.
Check ($styles -match '(?s)\.is-hidden,\s*\[hidden\]\s*\{\s*display:\s*none\s*!important') `
  'hiding is not enforced against .btn display, so a hidden control can still render'
Check ($homeCode -notmatch "\.hidden = ") `
  'home.js hides a control with the hidden property alone, which a display rule overrides'

# ---------------------------------------------------------------- 11
Show-Group 'The narrow layout is a specified state, not an afterthought'

# Slice 14. Measured 2026-07-30: before this cycle no media query in the file
# touched the Learning Home shell, so a 360px viewport rendered a 240px rail
# against what was left. A criterion that only meets cases which cannot fail it
# gates nothing, so these assert the rules exist.
# Matched on the declaration itself, not on "a 767px query appears somewhere and
# .home-card appears somewhere later" — a lazy cross-file match passed this even
# with the narrow block deleted, which is the false-pass this suite exists to
# prevent. The base rule is flex-direction: row; only the narrow one is column.
# 2026-07-30, top-nav change: three checks here were retired rather than kept
# as false passes. `.home-sidebar { flex-shrink: 0 }` guarded a rail that no
# longer exists. `.home-card { flex-direction: column }` and
# `.home-nav { flex-direction: row }` were narrow-only anchors under the sidebar
# shell; with a top bar both are true of the BASE rules, so they would match
# whether or not a narrow rule existed — which is exactly the lazy-anchor false
# pass this group already had to fix once. Their replacements land with the
# narrow rules themselves, in the media query, and are asserted there.
Check ($styles -match '100dvh') `
  'no dynamic viewport unit. A fixed vh strands controls under Android browser chrome and the keyboard'
Check ($styles -notmatch 'transform:\s*translateY\(0\)\s*scale\(1\)') `
  'the entry animation still ends on a computed transform, which makes every card a containing block for position: fixed'
Check ($styles -match '(?s)\.modal-overlay\s*\{[^}]*overflow-y:\s*auto') `
  'a modal taller than the viewport is clipped with no scroll path, which puts its primary action out of reach'
Check ($homeCode -notmatch "style\.cssText") `
  'home.js writes inline styles at runtime. A media query cannot reach one, which is what blocked the narrow layout'

# ---------------------------------------------------------------- 12
Show-Group 'The first action names one thing and does not invent its cost'

# Layout F6, adopted on its narrow half: name the specific item and bound it.
# The duration is nullable, and an unknown duration is omitted rather than
# guessed. That is the unmapped-goal rule applied to time instead of content.
Check ($mainCode -match 'firstSkillMinutes') `
  'main.js does not carry a duration for the first item, so the action cannot bound its cost'
Check ($mainCode -match 'firstSkillMinutes:\s*null') `
  'every course has a duration, so the omit-rather-than-default path is unreachable through real data'
Check ($homeCode -match 'function actionLabel') 'home.js has no action-label builder'
Check ($homeCode -match "typeof minutes === 'number'") `
  'home.js does not test the duration before stating it. An absent key and a null must behave identically'
Check ($homeCode -notmatch "minutes \|\| \d") `
  'home.js defaults a missing duration. A guessed estimate is the fabrication class this build removes'

# ---------------------------------------------------------------- 13
Show-Group 'The gender opt-out is a first-class option'

# A shipped Slice 5 criterion requires it to be styled at the same weight as
# the other options. It was outside the grid at a lighter weight, smaller size
# and muted colour, at every width.
Check ($onboarding -match '(?s)<div class="gender-grid">.*?gender-btn-prefer.*?</div>') `
  'the opt-out sits outside the option grid, which stacks it last as an afterthought'
Check ($styles -notmatch '(?s)\.gender-card-optout\s*\{[^}]*font:\s*400') `
  'the opt-out is still set at a lighter weight than the options it sits beside'

# ---------------------------------------------------------------- 14
Show-Group 'The wait, the failure, and the dead ends are all real'

# Each of these was found by the Principal Designer Mode T review on 2026-07-30
# against a build whose suite was green. Group 6 asserted the two skeleton
# constants existed and neither was in force; nothing asserted an error state
# at all. Constants are not behaviour, and a criterion nothing tests is a
# criterion nothing gates.
Check ($homeHtml -match 'id="home_skeleton" class="is-hidden"') `
  'the skeleton ships visible, so the 400ms delay suppresses nothing and cannot prevent a flash'
Check ($homeCode -match 'skeletonShownAt = Date\.now\(\)') `
  'the reveal time is not recorded at reveal, so the 500ms hold is computed from a time the skeleton was never shown'
Check ($homeCode -match 'skeletonShownAt === null') `
  'a wait shorter than the delay still pays the hold, which is the flash the two-number rule exists to prevent'
Check ($homeHtml -match 'id="home_error"') `
  'home.html has no error state. Slice 12 requires a recoverable failure on this surface, not a permanent skeleton'
Check ($homeRendered -match 'role="alert"') `
  'the failure is not announced. A learner using assistive technology is left on a skeleton with no message'
Check ($homeHtml -match 'id="home_retry_btn"') 'the error state offers no recovery action'
Check ($homeCode -match 'function renderError') 'home.js has no error branch, so the error markup is unreachable'
Check ($homeCode -match '(?s)try \{ return JSON\.parse\(raw\); \} catch') `
  'the handoff is parsed unguarded. A malformed payload throws in boot() and strands the learner on the skeleton'
Check ($homeCode -notmatch 'var PROGRAM_TASKS') `
  'the task list is a constant in the view again. Its denominator must arrive on the handoff, not be declared by the screen'
Check ($mainCode -match 'programTasks:') `
  'main.js does not write the assigned-task payload at finalization'
Check ($mainCode -match 'taskTotal:') `
  'main.js does not write the task denominator, so the home would have to invent one'
# 2026-07-30, top-nav change: the brand no longer needs its own banner role or
# a narrow-width removal. It sits inside the <header role="banner"> that group 9
# already asserts, which is the exemption Slice 12's ordinal block-order
# criterion names, so it is not product-owned content preceding the learner's
# next action at either width.
Check ($homeRendered -notmatch '<aside') `
  'primary navigation sits inside a complementary landmark'
$stubs = ([regex]::Matches($homeRendered, 'data-stub=')).Count
Check ($stubs -ge 3) `
  "$stubs destinations declare an out-of-scope response. A focusable control that answers nothing is a dead end"
Check ($homeCode -match 'is out of scope for this prototype') `
  'the out-of-scope destinations swallow the click instead of saying why nothing happened'

# ---------------------------------------------------------------- 16
Show-Group 'The goal set is conditioned on the declared age band'

# A 13-to-17 learner is offered a different set of goals from an adult. The
# three teen categories are a labelled assumption in PRD section 2, not a
# finding, and the by-band goal_selected read is what would falsify them.
$dataJs = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'data.js') -Raw
$dataCode = Remove-Comments $dataJs

Check ($dataCode -match 'goalOptionsByBand') `
  'data.js still declares one flat goal list, so every age band sees the same six options'
Check ($dataCode -match 'function goalOptionsFor') `
  'there is no resolver, so the render path has to know the shape of the band map'
Check ($dataCode -notmatch 'window\.goalOptions\s*=') `
  'the old flat export survives. Two sources for one list is how they drift apart'
foreach ($id in @('english', 'math_science', 'life_skills')) {
  Check ($dataCode -match "id:\s*'$id'") "the teen set is missing the $id goal"
}
Check ($mainCode -match 'goalOptionsFor\(appState\.selectedAgeCategory\)') `
  'renderGoalCards does not consult the age band, so the conditional set is unreachable'
Check ($mainCode -notmatch 'goalOptions\.forEach') `
  'renderGoalCards still iterates the flat list'

# selectGoal used to call renderGoalCards() on every activation, which tears
# down and recreates every button in the grid. A keyboard Enter/Space fires
# selectGoal while the activated button still has focus, so that rebuild
# replaced the focused node and dropped focus to <body>; the next Tab then
# restarted at the top of the page instead of reaching Continue. A text match
# cannot prove where focus lands after the call, only that the rebuild which
# discarded it is gone; the live-browser walk (Tab to a card, press Enter,
# confirm focus and aria-pressed stay on that same card) is the actual proof.
Check ($mainCode -notmatch '(?s)function selectGoal\(goalId\)\s*\{\s*appState\.selectedGoal = goalId;\s*renderGoalCards\(\);') `
  'selectGoal still rebuilds the entire grid via renderGoalCards() on every activation, which is what destroys the focused button on a keyboard select'

# The condition has to be real. A teen key holding a copy of the same six, or
# sharing ids with them, passes every check above while changing nothing.
$teenBlock = ''
if ($dataCode -match '(?s)teen:\s*\[(.*?)\]') { $teenBlock = $Matches[1] }
$teenIds = [regex]::Matches($teenBlock, "id:\s*'([a-z_]+)'") | ForEach-Object { $_.Groups[1].Value }
Check ($teenIds.Count -eq 3) `
  "the teen set holds $($teenIds.Count) goals; expected 3"
$sharedIds = $teenIds | Where-Object { @('data','customer','project','marketing','communication','language') -contains $_ }
Check ($sharedIds.Count -eq 0) `
  "the teen set reuses $($sharedIds -join ', ') from the default set. Identifiers must be unique across bands"

# Slice 6: back navigation preserves the goal within an option set, but a band
# switch that changes the set discards it. Continue re-disables for free,
# because updateHeaders derives its disabled state from selectedGoal.
Check ($mainCode -match 'function setAgeCategory') `
  'the age category is written directly, so nothing can notice that the option set changed'
Check ($mainCode -match 'appState\.selectedGoal = null') `
  'switching age band leaves a goal selected that the new set does not contain'
$rawWrites = ([regex]::Matches($mainCode, 'appState\.selectedAgeCategory\s*=')).Count
Check ($rawWrites -eq 1) `
  "$rawWrites places write selectedAgeCategory; expected 1, inside setAgeCategory. A second writer bypasses the clear"

# Slice 6 requires each configured goal to resolve to exactly one first course.
# language is deliberately unmapped so the home unmapped state stays reachable
# through real data, so this asserts the teen ids only, not every id.
foreach ($id in @('english', 'math_science', 'life_skills')) {
  Check ($mainCode -match "'$id':\s*\{") `
    "the $id goal has no course, so a teen learner reaches the unmapped home state by omission rather than by design"
}
Check ($mainCode -notmatch "'language':\s*\{") `
  'language gained a course. The unmapped path is then unreachable through real data and its guard passes vacuously'

# The age gate and the goal screen always rendered one visual idea at two
# scales, with the age half expressed as inline styles a media query cannot
# reach. One class now carries both.
Check ($styles -match '\.choice-card\s*\{') `
  'there is no shared card class, so the two screens are still two implementations of one component'
Check ($styles -notmatch '\.goal-card') `
  'goal-card survives somewhere in the stylesheet. Two card systems is the duplication this removes'
Check ($mainCode -notmatch 'goal-card') `
  'renderGoalCards still emits the retired class, so the goal cards render unstyled'
Check ($styles -match '\.card-wide') `
  'nothing overrides the 520px cap on line 169, so the enlarged goal cards render about 162px wide'
Check ($styles -match '(?s)\.card:not\(\.landing-card\):not\(\.home-card\)\s*>\s*\.card-wide') `
  'card-wide is declared at too low a specificity to beat the 520px cap and would need !important'
Check ($styles -notmatch '\.card-wide[^{]*\{[^}]*!important') `
  'card-wide wins by !important rather than by specificity'
# Scoped to the goal screen only. The age gate still carries its own inline
# 900px override at this point; Task 5 removes that one and asserts globally.
$goalScreen = ''
if ($onboarding -match '(?s)id="goal_intake"(.*?)id="assigned_content"') { $goalScreen = $Matches[1] }
Check ($goalScreen.Length -gt 0) 'could not isolate the goal_intake markup'
Check ($goalScreen -notmatch '!important') `
  'the goal screen still overrides the 520px cap inline instead of by specificity'
Check ($goalScreen -match 'id="goal_grid"[^>]*card-wide') `
  'the goal grid is not widened, so the enlarged cards render inside the 520px cap'

# Fix round 1. The resolver above was correct on paper and still rendered the
# wrong set at runtime, because nothing called it at the moment the learner
# actually reached the goal screen: the only call site ran once at page load,
# while selectedAgeCategory was still null, and painted the default six for
# good. A text match cannot observe when a function runs during a real
# session, only whether its call site exists where the learner arrives and
# whether the masking page-load call is gone. These are a structural
# tripwire, not proof; the four-walk browser check is the proof that ran the
# funnel and watched the grid.
$updateHeadersBlock = ''
if ($mainCode -match '(?s)function updateHeaders\(screenId\)\s*\{(.*?)function handleGlobalContinue') {
  $updateHeadersBlock = $Matches[1]
}
Check ($updateHeadersBlock -match "goal_intake'\)\s*\{\s*renderGoalCards\(\)") `
  'updateHeaders does not render the goal grid on entry to goal_intake, so a stale band is never repainted by navigation alone'

$domReadyBlock = ''
if ($mainCode -match "(?s)DOMContentLoaded'.*?=>\s*\{(.*?)const progressMap") {
  $domReadyBlock = $Matches[1]
}
Check ($domReadyBlock -notmatch 'renderGoalCards\(\)') `
  'DOMContentLoaded still renders the goal grid at page load, before any age band is known. That call painted the wrong set and is what hid this bug behind a green suite'

# ---------------------------------------------------------------- 17
Show-Group 'The age gate is operable by keyboard, like every screen beside it'

# Seven controls on this screen were divs with click handlers, no tabindex and
# no role, while the gender cards directly below them were already buttons.
# PRD Slice 10 makes keyboard operation an acceptance requirement for every
# slice, and the same rule is asserted for the home destinations in group 9.
$ageGate = ''
if ($onboarding -match '(?s)id="age_gate"(.*?)id="gender_gate"') { $ageGate = $Matches[1] }
Check ($ageGate.Length -gt 0) 'could not isolate the age_gate markup'

Check ($ageGate -notmatch '<div[^>]*class="[^"]*option-card') `
  'an age option is still a non-semantic div. It must be operable by keyboard, not merely clickable'
$ageButtons = ([regex]::Matches($ageGate, '<button[^>]*class="[^"]*option-card')).Count
Check ($ageButtons -eq 7) `
  "$ageButtons age options are buttons; expected 7 (three bands plus four adult sub-ranges)"
$agePressed = ([regex]::Matches($ageGate, 'aria-pressed')).Count
Check ($agePressed -eq 7) `
  "$agePressed age options expose a pressed state; expected 7. A visual highlight tells assistive technology nothing"
Check ($ageGate -notmatch 'style=') `
  'the age gate still carries inline styles, which no media query can reach'
$ageGroups = ([regex]::Matches($ageGate, 'role="group"')).Count
Check ($ageGroups -eq 2) `
  "$ageGroups age containers declare a group; expected 2. Without it seven buttons are announced as seven unrelated controls"
$ageBareIcons = ([regex]::Matches($ageGate, '<span[^>]*material-symbols-rounded(?![^>]*aria-hidden)[^>]*>')).Count
Check ($ageBareIcons -eq 0) `
  "$ageBareIcons age icons carry no aria-hidden, so a band is announced as 'backpack I am a teen'"
Check ($mainCode -notmatch "getElementById\('age-adult-options'\)\.style\.display") `
  'the sub-range group is shown by writing an inline display, which is the state a media query cannot reach'
# Counted, not matched. Three places already write aria-pressed (two in
# selectGender, one in renderGoalCards), so a bare -match passes before
# selectAgeOption writes it at all, and a check that is green before the change
# gates nothing. Those three plus three more: one in clearOptionPeers, which is
# called from all three deselection sites, one on the selected element in
# selectAgeOption, and one in selectGoal, which toggles the pressed state on
# the existing goal buttons in place instead of rebuilding the grid.
$pressedWrites = ([regex]::Matches($mainCode, "setAttribute\('aria-pressed'")).Count
Check ($pressedWrites -eq 6) `
  "$pressedWrites places write aria-pressed; expected 6. selectAgeOption sets a class but not the pressed state the markup declares"
Check ($mainCode -match 'function clearOptionPeers') `
  'the deselection sweep is repeated inline at each call site instead of named once'
Check ($styles -match '(?s)\.age-subrange-card:focus-visible\s*\{') `
  'the sub-range buttons have no focus-visible rule, so the global button reset leaves them focusable with no visible ring'

# ---------------------------------------------------------------- report
Write-Host ''
if ($script:Failures.Count -eq 0) {
  Write-Host "src-prototype.test.ps1 PASSED - $($script:Checks) checks, 17 groups"
  exit 0
}
Write-Host "src-prototype.test.ps1 FAILED - $($script:Failures.Count) of $($script:Checks) checks"
foreach ($f in $script:Failures) { Write-Host "  - $f" }
exit 1
