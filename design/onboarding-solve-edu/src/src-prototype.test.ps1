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
# The greeting carried this branch until 2026-07-31, when it was removed as two
# lines of product-owned copy between the learner and their next action. The
# BRANCH was not removed with it — it moved to the control the learner actually
# presses. These checks follow it there rather than being deleted, because a
# branch nothing asserts is a branch that can quietly collapse to one arm.
Check ($homeCode -match "var verb = first \? 'Start' : 'Continue'") `
  'the first-run branch has no observable effect. Without it every learner sees the same action label forever'
Check ($homeRendered -notmatch '(?i)good to see you again') `
  'the returning greeting is back on the home surface'
Check ($homeCode -notmatch '(?i)good to see you again') `
  'home.js still writes the returning greeting'
Check ($homeCode -notmatch "setText\('home_greeting'") `
  'home.js still writes a greeting into a slot the markup no longer has, so the call is dead'
Check ($homeRendered -notmatch 'id="home_greeting"') `
  'the greeting slot is back in the markup'
# The one line in that block that was NOT a greeting. Dropping it silently makes
# a prototype holding no data look like a prototype holding real data, which is
# the fabrication class this whole file exists to prevent.
Check ($homeCode -match 'Opened directly, so this is a sample learner') `
  'the sample-learner notice went with the greeting. A prototype with no data must say so'
# showScreen() hides every note, so the notice has to be written AFTER it or it
# is cleared in the same tick it is set. Checked by position rather than by an
# adjacency pattern, which only asserted that nobody reformatted the comment.
$showIdx = $homeCode.IndexOf("showScreen('learning_home')")
$standaloneIdx = $homeCode.IndexOf('if (state.standalone)')
Check ($showIdx -ge 0 -and $standaloneIdx -gt $showIdx) `
  'the sample-learner notice is written before showScreen clears every note, so it never reaches the learner'

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
# Retired 2026-07-31: the top bar IS the design now, so "reinstates the top nav"
# was both stale and vacuous. What still matters is that the funnel's own header
# does not leak onto the home, which is a different element.
Check ($homeRendered -notmatch 'id="global-header"') `
  "home.html carries the funnel's header. The Learning Home has its own top bar" 

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
# 2026-07-31, Slice 16: this asserted `-notmatch '<aside'`, which banned the
# element rather than the defect. The defect is NAVIGATION inside a
# complementary landmark, which is what the message has always said. Cycle 4
# adds a rail, and a rail is the one thing <aside> is actually for, so the
# check is narrowed to its own intent instead of deleted: an <aside> is
# permitted, an <aside> containing the primary navigation is not.
$asides = [regex]::Matches($homeRendered, '(?s)<aside\b.*?</aside>')
$navInAside = @($asides | Where-Object { $_.Value -match '<nav\b' -or $_.Value -match 'home-nav' })
Check ($navInAside.Count -eq 0) `
  'navigation still sits in a complementary landmark'
foreach ($a in $asides) {
  Check ($a.Value -match 'aria-label=') `
    'a complementary landmark carries no accessible name, so a screen-reader user gets "complementary" and nothing else'
}
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
if ($homeRendered -match '(?s)id="learning_home"(.*?)id="chapter_screen"') { $homeSection = $Matches[1] }
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
Check ($mainCode -match 'firstChapterMinutes') `
  'main.js does not carry a duration for the first item, so the action cannot bound its cost'
Check ($mainCode -match 'firstChapterMinutes:\s*null') `
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
# Narrowed with the check in group 9, and for the same reason: Cycle 4's rail
# is a complementary landmark by design. What must not happen is the navigation
# living inside one.
Check ($navInAside.Count -eq 0) `
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

# ---------------------------------------------------------------- 18
Show-Group 'All eleven destinations are reachable, at most two levels deep'

# The production home carries eleven flat, ungrouped destinations and marks none
# of them. They are reorganized here into four top-level families. A top bar
# cannot keep all eleven visible the way a sidebar could, so eight move one
# level into their family panel — and a panel shows its whole family at once
# rather than nesting further, which is the difference between one level of
# depth and the push-depth-down arm the cited study rejects.
# Reachable means the learner can get there. Inbox is an icon control whose
# accessible name is its label, so it is matched on aria-label rather than on a
# text node — the point is that it exists and is named, not that it renders
# words.
$dests = 'Home','Inbox','Catalog','Ladders','Practice','Challenges','Evidence','Credentials','Opportunities','Applications','Referral'
foreach ($d in $dests) {
  $reachable = ($homeRendered -match ">\s*$d\s*<") -or ($homeRendered -match "aria-label=`"$d`"")
  Check $reachable "destination '$d' is not reachable anywhere in the navigation"
}
foreach ($p in 'panel_learn','panel_portfolio','panel_work') {
  Check ($homeHtml -match "id=`"$p`"") "family panel $p is missing"
}
# Learn 4 + Portfolio 2 + Work 2 = 8 members per view, across three views.
# Counted per destination rather than by class: .home-nav-child is also the
# language and profile menu rows, so a bare class count would sweep those in and
# stop discriminating.
foreach ($m in 'Catalog','Ladders','Practice','Challenges','Evidence','Credentials','Opportunities','Applications') {
  Check ((([regex]::Matches($homeRendered, ">\s*$m\s*<")).Count) -eq 3) `
    "family member '$m' does not appear once per view"
}
Check ($homeRendered -notmatch '(?s)home-nav-panel[^>]*>(?:(?!</div>).)*?home-nav-panel') `
  'a panel nests another panel. A family shows all its members at once, never a deeper tree'
Check ($homeCode -match 'function openFamily') 'home.js cannot open a family panel'
Check ($homeCode -match 'function closeAllPanels') 'home.js cannot close the panels'
Check ($homeCode -match "key === 'Escape'") 'Escape does not close an open panel'
Check ((([regex]::Matches($homeRendered, 'aria-expanded="false"')).Count) -ge 9) `
  'family controls do not report their expanded state'
# Ids repeat across three views unless they are suffixed, and a duplicate id
# makes aria-controls point at whichever one the parser saw first.
$panelIds = [regex]::Matches($homeHtml, 'id="(panel_[a-z_0-9]+)"') | ForEach-Object { $_.Groups[1].Value }
Check (($panelIds | Select-Object -Unique).Count -eq $panelIds.Count) `
  'panel ids repeat across views, so aria-controls resolves to the wrong panel'
$allIds = [regex]::Matches($homeHtml, 'id="([A-Za-z_0-9-]+)"') | ForEach-Object { $_.Groups[1].Value }
Check (($allIds | Select-Object -Unique).Count -eq $allIds.Count) `
  'home.html carries a duplicate id, so getElementById returns whichever came first'

# ---------------------------------------------------------------- 19
Show-Group 'The utility cluster tells the truth about the learner'

Check ($homeHtml -match 'id="inbox_btn"') 'Inbox has no control'
Check ($homeRendered -match 'aria-label="Inbox"') `
  'the Inbox icon control has no accessible name, so it is announced as an unlabelled button'
Check ($homeHtml -match 'id="panel_profile"') 'there is no profile menu'
foreach ($m in 'Your profile', 'Settings', 'Referral', 'Log out') {
  Check ($homeRendered -match [regex]::Escape($m)) "the profile menu is missing '$m'"
}
Check ($styles -match '\.home-menu-divider') `
  'Log out is not separated from the navigational items above it'

# Log out ENDS THE SESSION and returns to the funnel entry. Two halves, and the
# second is the one that gets skipped: navigating without clearing the handoff
# leaves the learner one back-button away from their own logged-out home, which
# is a logout that logged nothing out.
Check ((([regex]::Matches($homeRendered, 'class="home-nav-child home-menu-logout" data-stub="Log out"')).Count) -eq 3) `
  'the logout row is not present and distinguished in every view'
Check ($homeCode -match "if \(name === 'Log out'\)") `
  'Log out falls through to the out-of-scope handler, so it announces itself as a stub instead of logging out'
Check ($homeCode -match "window\.location\.href = 'onboarding\.html'") `
  'Log out does not return to the funnel entry'
# Ordinal, not the default culture-sensitive comparison: PowerShell's
# String.IndexOf(String) uses the current culture, which does not reliably locate
# a needle containing operator punctuation such as `===`. This check failed
# against source that was correct until it was pinned to Ordinal.
# Both indexes are searched FROM the logout branch, not from the top of the
# file. `onboarding.html` is also the unmapped-goal recovery target and appears
# ~3,600 characters earlier, so a search from zero finds that one and reports a
# correct build as broken. This check did exactly that before it was scoped.
$ord = [System.StringComparison]::Ordinal
$logoutIdx = $homeCode.IndexOf("if (name === 'Log out')", $ord)
Check ($logoutIdx -ge 0) 'the Log out branch is gone from the destination handler'
if ($logoutIdx -ge 0) {
  $clearIdx = $homeCode.IndexOf("sessionStorage.removeItem('se_handoff')", $logoutIdx, $ord)
  $navIdx   = $homeCode.IndexOf("window.location.href = 'onboarding.html'", $logoutIdx, $ord)
  Check ($clearIdx -ge 0 -and $navIdx -ge 0 -and $clearIdx -lt $navIdx) `
    'the handoff is not cleared before Log out navigates, so the previous learner survives the logout'
}
# Theme and language are device preferences, not account data. Clearing them
# would drop a learner onto the onboarding in English and light mode, which for
# an audience that may not read English is the one place it hurts most.
Check ($homeCode -notmatch 'localStorage\.clear\(\)' -and $homeCode -notmatch "localStorage\.removeItem\('se_(theme|lang)'\)") `
  'Log out clears the device preferences, so it resets the interface language a learner may depend on'
# Colour is the secondary signal, never the only one: the row is last and sits
# below a divider, both of which survive for a learner who cannot resolve hue.
Check ($styles -match '\.home-menu-logout \{ color: var\(--danger\); \}') `
  'the logout row is not distinguished, so the one destructive row looks like every other row'
# $homeRendered has comments stripped, so the divider and the button are
# adjacent here even though the source has an explanatory comment between them.
Check ((([regex]::Matches($homeRendered, '(?s)home-menu-divider"></span>\s*<button[^>]*home-menu-logout')).Count) -eq 3) `
  'the divider no longer immediately precedes Log out, so the non-colour half of its distinction is gone'

# Theme and language are account preferences, so they live in the profile menu
# rather than as their own controls in the bar. The bar keeps three utilities.
# Checked structurally, not by counting controls: a text search for "theme_btn"
# passes wherever the control sits, which is exactly what these two rule out.
$profilePanels = [regex]::Matches($homeHtml, '(?s)id="panel_profile[_0-9]*">(.*?)</div>\s*</div>')
Check ($profilePanels.Count -eq 3) `
  "found $($profilePanels.Count) profile menus; expected one per view"
foreach ($p in $profilePanels) {
  Check ($p.Groups[1].Value -match 'id="theme_btn') `
    'the theme control is not inside the profile menu'
  Check ($p.Groups[1].Value -match 'id="lang_btn') `
    'the language control is not inside the profile menu'
}
Check ($homeHtml -notmatch 'home-topbar-utils">\s*<p class="home-xp"[^>]*>.*?</p>\s*<button[^>]*id="theme_btn') `
  'the theme control is still a sibling of XP in the utility cluster'
# One level of depth is the rule the family panels are held to, and the profile
# menu is not exempt. The language choice happens in a page-level DIALOG, so the
# menu never opens a menu and the list never re-enters the panel's stacking
# context — the failure that buried the family panels behind the content column.
Check ($homeHtml -notmatch '(?s)id="panel_profile[_0-9]*">(?:(?!</header>).)*?home-nav-panel') `
  'the profile menu opens a nested panel, which is the second level of depth the top bar exists to avoid'
Check ($homeRendered -notmatch '<select') `
  'the language control is a select again. It was replaced by a dialog, and two mechanisms for one choice is how they drift apart'
# Both preference rows are ONE line: leading icon, label, trailing affordance,
# the same three-part scan line the navigational rows above them use. The
# language row shows only the language name, and the globe is aria-hidden, so
# without an aria-label the trigger announces as "English" and nothing else.
$langTriggers = [regex]::Matches($homeHtml, '<button type="button" class="home-nav-child home-menu-row" id="(lang_btn[_0-9]*)" aria-haspopup="dialog" aria-label="Change language, currently English">')
Check ($langTriggers.Count -eq 3) `
  "found $($langTriggers.Count) named language triggers declaring a dialog; expected one per view"
Check ((([regex]::Matches($homeRendered, 'id="lang_name')).Count) -eq 3) `
  'the language row does not name the current language in every view, so two of three show a stale value'
# A downward chevron promises a list that drops below the control. This one
# opens a dialog.
Check ($homeRendered -match 'home-menu-chevron" aria-hidden="true">chevron_right<') `
  'the language row points its chevron down at a dialog that opens centred, which is a promise the control does not keep'
# Both preference rows are FLUSH, and both carry .home-nav-child so their
# padding, radius, type and hover come from the same rule as every other row in
# the menu. The language control was briefly a bordered pill: one bordered
# element among five flush ones reads as the emphasis of the menu, which the
# language row has not earned. A parallel rule set is also how two things that
# should look identical drift apart.
Check ($styles -notmatch '\.home-menu-field') `
  'the pill class is back. Both preference rows are flush and share .home-nav-child, so a second rule set for one of them can only diverge'
foreach ($t in $langTriggers) {
  Check ($t.Value -match 'class="home-nav-child home-menu-row"') `
    'the language row does not share the menu-row styling, so it can drift from the rows around it'
}
Check ($homeRendered -match '<button type="button" class="home-nav-child home-menu-row" id="theme_btn"') `
  'the two preference rows no longer share a class, so they can drift apart visually'
Check ($homeCode -match "querySelectorAll\('\[id\^=`"lang_name`"\]'\)") `
  'home.js does not carry the language choice into every view, so the menu shows a stale value on two of three'

# The dialog itself. ONE per page, not one per view: three copies would mean
# three sets of ticks that can disagree about which language is current.
Check ((([regex]::Matches($homeHtml, 'id="lang_modal"')).Count) -eq 1) `
  'the language dialog is not a single page-level instance, so its ticks can disagree across views'
Check ($homeRendered -match '(?s)id="lang_modal" class="modal-overlay">\s*<div class="modal-content" role="dialog" aria-modal="true" aria-labelledby="lang_modal_title"') `
  'the language dialog is not a labelled modal dialog, so assistive technology reads it as ordinary page content'
Check ($homeRendered -match 'id="lang_modal_title"') 'the language dialog has no title to be labelled by'
Check ((([regex]::Matches($homeRendered, 'class="lang-option" data-lang=')).Count) -eq 2) `
  'the language dialog does not offer exactly the two supported languages'
Check ($homeRendered -match 'data-lang="en" aria-current="true"') `
  'no option is marked current, so the dialog does not say which language is already set'
Check ($styles -match '\.lang-option\[aria-current="true"\] \.lang-option-tick') `
  'the current option has no visible tick, so the selection is exposed only to assistive technology'
# Flags are INLINE SVG, not emoji. A regional-indicator pair renders as a colour
# flag on Android and as the bare letters "ID" on Windows Chrome, so emoji would
# show broken on the one platform the team reviews on. Inline SVG also keeps the
# page self-contained, which the funnel's no-external-host rule requires.
Check ((([regex]::Matches($homeRendered, '<svg class="lang-option-flag"')).Count) -eq 2) `
  'the language options do not carry an inline SVG flag each'
Check ($homeRendered -notmatch '[\uD83C][\uDDE6-\uDDFF]') `
  'a regional-indicator flag emoji is in the markup. It renders as bare letters on Windows Chrome'
Check ((([regex]::Matches($homeRendered, '<svg class="lang-option-flag" viewBox="0 0 60 30" aria-hidden="true" focusable="false">')).Count) -eq 2) `
  'a flag is exposed to assistive technology. The language name is the accessible name; a flag adds nothing a screen reader can use'
Check ($homeRendered -notmatch '<img[^>]*lang-option') `
  'a flag is an external image rather than inline markup, so the dialog is no longer self-contained'
# The white half of the Indonesian flag vanishes on a white modal without one.
Check ($styles -match '(?s)\.lang-option-flag\s*\{[^}]*border:\s*1px solid var\(--hair-dark\)') `
  'the flags have no boundary, so a flag with a white field has no readable edge against the modal'
# Focus in, focus trapped, focus back. The third is the one that gets skipped,
# and skipping it drops a keyboard learner at the top of the document.
Check ($homeCode -match 'function openLangModal') 'the language dialog cannot be opened'
Check ($homeCode -match 'function closeLangModal') 'the language dialog cannot be closed'
Check ($homeCode -match 'if \(current\) current\.focus\(\)') `
  'focus does not move into the dialog, so a keyboard learner opens it and stays outside it'
Check ($homeCode -match 'langReturnFocus\.focus\(\)') `
  'focus is not restored on close, so a keyboard learner is returned to the top of the document'
Check ($homeCode -match "e\.key !== 'Tab'") `
  'the dialog has no focus trap, so Tab walks out into a page that is inert to the eye but not to the keyboard'
Check ($homeCode -match "e\.key === 'Escape' && langModalOpen\(\)") `
  'Escape does not close the dialog first, so one key press dismisses the dialog and the panels beneath it together'
# The PRD's narrow-width modal row forbids depending on the backdrop alone.
Check ($homeRendered -match 'id="lang_modal_close"') `
  'the dialog has no explicit close inside its own bounds, so dismissal depends on the backdrop'
Check ($homeCode -match "langModal\.addEventListener\('click', closeLangModal\)") `
  'the backdrop does not dismiss the dialog'
Check ($homeCode -match "langCard\.addEventListener\('click', function \(e\) \{ e\.stopPropagation\(\); \}\)") `
  'a click inside the dialog reaches the backdrop handler, so choosing a language closes the dialog by the wrong path'
Check ($styles -match '(?s)\.modal-overlay\s*\{[^}]*overflow-y:\s*auto') `
  'the dialog cannot scroll within itself, so a list taller than a keyboard-shortened viewport is unreachable'

# XP is the one addition on this surface that could reintroduce the exact defect
# Cycle 2 removed. A literal is the 150-point pill; these make that impossible.
Check ($homeRendered -match 'id="home_xp_value">0<') `
  'the XP counter does not start at zero in markup. A first-run learner has earned nothing'
Check ($homeCode -match 'state\.chaptersDone \* XP_PER_CHAPTER') `
  'XP is not derived from durable learner data, so it is a declared number'
Check ($homeRendered -notmatch '(?i)\b[1-9][0-9]*\s*XP\b') `
  'a non-zero XP literal appears in the markup. Every progress value is computed or absent (PRD 5.3)'
Check ($homeCode -match 'function renderXp') 'home.js has no XP renderer'

# Theme and language are learner choices, so they carry state rather than
# flipping an icon and hoping.
# `.card.active > *` animates a transform with fill-mode forwards, so the top
# bar and the content column BOTH hold a stacking context. As siblings at
# z-index auto they paint in DOM order, which buried every open panel behind the
# content — the panel's own z-index cannot escape its parent's context.
Check ($styles -match '(?s)\.home-topbar\s*\{[^}]*z-index:\s*\d+') `
  'the top bar has no z-index, so an open panel renders behind the content column'
# The shell fills the viewport; the reading column is what gets capped. A fixed
# px cap on the shell is what made the prototype look like a boxed screenshot.
Check ($styles -notmatch '(?s)\.home-card\s*\{[^}]*max-width:\s*\d+px') `
  'the Learning Home shell is capped at a fixed width, so it does not follow the viewport'
Check ($styles -match '(?s)\.home-main\s*\{[^}]*max-width:\s*\d+px') `
  'the reading column has no maximum width, so line length runs away on a wide screen'
Check ($homeCode -match 'function markLocation') `
  'home.js cannot mark the current location'
Check ($homeCode -match "setAttribute\('aria-current', 'page'\)") `
  'the current destination is not exposed programmatically'
Check ($homeCode -match 'function familyOf') `
  'the family of a destination is not derived, so a hand-maintained table could drift from the markup'
Check ($styles -match '\.home-nav-child\.active') `
  'an active family member has no visible treatment inside its panel'
Check ($homeCode -match "querySelectorAll\('\[data-stub\]'\)") `
  'the out-of-scope handler is bound to nav items only, so panel members and the profile menu swallow their clicks'
$stubCount = ([regex]::Matches($homeRendered, 'data-stub=')).Count
Check ($stubCount -ge 30) `
  "$stubCount controls declare an out-of-scope response; expected at least 30 across three views"
Check ($homeCode -match 'function applyTheme') 'there is no theme switch'
Check ($styles -match ':root\[data-theme="dark"\]') 'dark mode has no token set, so the switch would change nothing'
# The control is a SWITCH now, and that changes what each part has to carry. A
# push button has no state, so its label must state the action; a switch has
# one, so the label names the setting and aria-checked carries the setting. The
# two are not interchangeable: a switch whose label still read "Switch to dark
# mode" would announce "Switch to dark mode, on", which says the opposite of
# what it means half the time.
Check (([regex]::Matches($homeRendered, 'role="switch" aria-checked="false"')).Count -eq 3) `
  'the theme control does not expose switch state, so assistive technology cannot tell which mode is on'
Check ($homeCode -match "setAttribute\('aria-checked', dark \? 'true' : 'false'\)") `
  'home.js does not move the switch state, so the control reports one setting for ever'
Check ($homeCode -notmatch "setAttribute\('aria-label', dark") `
  'the theme row carries an aria-label as well as visible text, so the two can drift apart'
Check ((([regex]::Matches($homeRendered, '<span class="home-menu-label">Dark mode</span>')).Count) -eq 3) `
  'the theme row does not read "Dark mode" in every view. It is the setting name nearly every product uses, and against a switch it needs no qualifier: on means dark'
Check ($homeRendered -notmatch 'home-menu-hint') `
  'the switch still carries a visually-hidden qualifier. "Dark mode" is unambiguous against on/off, so the qualifier is dead weight in the accessible name'
# Position, not hue. This is now the ONLY non-colour signal of state: the moon
# no longer flips, because a sun beside "Dark mode, on" reads as the opposite of
# the state. So this check carries SC 1.4.1 on its own.
Check ($styles -match '\[aria-checked="true"\] \.home-menu-switch::after \{ transform: translateX') `
  'the switch knob does not move, so its state is carried by colour alone (SC 1.4.1)'
Check ($homeCode -notmatch "icon\.textContent = dark") `
  'the leading icon flips with the theme, which contradicts the static label beside it'
# Dark mode only works if the shell reads its colours from tokens. `#f8f9fa` is
# the light value of --bg written out, so it stayed light when the token
# re-pointed and produced dark cards on a light page. Found by measuring
# rendered colours; a text check cannot see two themes disagreeing, but it can
# see the literal that causes it.
Check ($styles -notmatch '(?s)\.home-card\s*\{[^}]*background:\s*(#|white|black)') `
  'the Learning Home shell hard-codes a background, so dark mode leaves it light'
Check ($styles -notmatch '(?s)\.home-topbar\s*\{[^}]*background:\s*(#|white|black)') `
  'the top bar hard-codes a background, so dark mode leaves it light'
Check ($homeCode -match 'function applyLang') 'there is no language switch'
# The handler binds [data-family], not .home-nav-item[data-family]. That was a
# live fix when the language switch was a .home-icon-btn in the bar and the
# narrower selector left it unbound — its panel never opened while this suite
# passed. Language has since moved into the profile menu and all four remaining
# triggers are nav items, so the broad selector is insurance now rather than a
# fix. It is still asserted: the next utility control added to the bar will not
# be a nav item either.
Check ($homeCode -match "querySelectorAll\('\[data-family\]'\)") `
  'the family handler is scoped to nav items, so a utility trigger would be a dead control'
Check ((([regex]::Matches($homeRendered, 'data-family=')).Count) -eq 12) `
  'expected 12 family triggers (4 per view x 3 views: Learn, Portfolio, Work, Profile)'
Check ((([regex]::Matches($homeRendered, 'class="home-nav-note')).Count) -eq 3) `
  'not every view has its own out-of-scope note, so two views write into a hidden node'
Check ($homeCode -match 'function noteEl') `
  'the note is looked up by id rather than scoped to the active card'
Check ($homeCode -notmatch "documentElement\.setAttribute\('lang'") `
  'the language switch relabels the document while every string stays English, which is a WCAG 3.1.1 falsehood'
Check ($homeCode -match 'out of scope for this prototype') `
  'the language switch implies the interface translated when the string catalogue is out of scope'

# The profile control is ICON-ONLY as of 2026-07-31, at the product owner's
# direction: an avatar glyph in the top-right is the one navigation label a
# learner does not need read to them, and the word was competing for horizontal
# room with the four destination families that do need theirs.
#
# THE ACCESSIBLE NAME IS THE PRICE, and it is what these checks buy. Dropping a
# visible label from a control whose panel is announced through it is only safe
# while the aria-label is there; without it the control announces as its glyph
# name, or as nothing at all, and SC 4.1.2 fails on all three views at once.
Check ((([regex]::Matches($homeRendered, 'id="profile_btn[^"]*"[^>]*aria-label="Profile"')).Count) -eq 3) `
  'a profile trigger is icon-only with no accessible name, so it announces as its glyph or not at all (SC 4.1.2)'
Check ($homeRendered -notmatch 'account_circle</span>\s*Profile') `
  'the visible "Profile" word is back in the top bar'
Check ($styles -match '\.home-nav-item-icon') `
  'the icon-only nav item has no treatment of its own, so it keeps the padding the dropped word held open'

# ---------------------------------------------------------------- 20
Show-Group 'Contrast is computed, not claimed'

# This group exists because a comment asserted "contrast is asserted by the
# guard suite" while the suite computed nothing, and two token values were
# described as meeting SC 1.4.11's 3:1 when they measured 1.47:1 and 2.28:1.
# A PRD or a comment asserting a standard nobody checked is the same defect
# class as an invented finding, so the claim is made true here rather than
# softened.
function Get-Luminance([string]$Hex) {
  $h = $Hex.TrimStart('#')
  $c = 0..2 | ForEach-Object { [Convert]::ToInt32($h.Substring($_ * 2, 2), 16) / 255 }
  $l = $c | ForEach-Object { if ($_ -le 0.03928) { $_ / 12.92 } else { [Math]::Pow((($_ + 0.055) / 1.055), 2.4) } }
  return 0.2126 * $l[0] + 0.7152 * $l[1] + 0.0722 * $l[2]
}
function Get-Ratio([string]$A, [string]$B) {
  $x = Get-Luminance $A; $y = Get-Luminance $B
  return [Math]::Round((([Math]::Max($x, $y) + 0.05) / ([Math]::Min($x, $y) + 0.05)), 2)
}
function Get-Token([string]$Name, [switch]$Dark) {
  $block = if ($Dark) { [regex]::Match($styles, '(?s):root\[data-theme="dark"\]\s*\{(.*?)\}').Groups[1].Value }
           else       { [regex]::Match($styles, '(?s)^:root\s*\{(.*?)\}').Groups[1].Value }
  $m = [regex]::Match($block, [regex]::Escape("--$Name") + ':\s*(#[0-9a-fA-F]{6})')
  if ($m.Success) { return $m.Groups[1].Value }
  # dark mode re-points only some tokens; fall back to the light value
  if ($Dark) { return Get-Token $Name }
  return $null
}

foreach ($mode in @('light', 'dark')) {
  $dark = ($mode -eq 'dark')
  $bg   = Get-Token 'bg'   -Dark:$dark
  $surf = Get-Token 'surf' -Dark:$dark
  $ink  = Get-Token 'ink'  -Dark:$dark
  $sub  = Get-Token 'sub'  -Dark:$dark
  $hd   = Get-Token 'hair-dark' -Dark:$dark
  $dang = Get-Token 'danger' -Dark:$dark

  # Log out is coloured text on the profile menu's surface, so it is body text
  # and 4.5:1 applies. --red would have failed this at 3.96:1 on white, which is
  # exactly why --danger exists as a separate, per-theme token.
  Check ($null -ne $dang) "$mode : there is no --danger token, so the logout row has no defined colour"
  if ($dang) {
    $r = Get-Ratio $dang $surf
    Check ($r -ge 4.5) "$mode : the logout row is ${r}:1 on a panel surface, below SC 1.4.3's 4.5:1"
    $r = Get-Ratio $dang $bg
    Check ($r -ge 4.5) "$mode : the logout row is ${r}:1 on its hover background, below SC 1.4.3's 4.5:1"
  }

  # SC 1.4.3 Contrast (Minimum), AA: 4.5:1 for body text.
  $r = Get-Ratio $ink $surf
  Check ($r -ge 4.5) "$mode : body text on a surface is ${r}:1, below WCAG 2.2 SC 1.4.3's 4.5:1"
  $r = Get-Ratio $sub $surf
  Check ($r -ge 4.5) "$mode : secondary text on a surface is ${r}:1, below SC 1.4.3's 4.5:1"
  $r = Get-Ratio $sub $bg
  Check ($r -ge 4.5) "$mode : secondary text on the page is ${r}:1, below SC 1.4.3's 4.5:1"

  # SC 1.4.11 Non-text Contrast, AA: 3:1 for a UI component boundary. --hair-dark
  # is the component boundary; --hair is the decorative hairline and is exempt.
  $r = Get-Ratio $hd $surf
  Check ($r -ge 3.0) "$mode : a panel boundary is ${r}:1 against its own surface, below SC 1.4.11's 3:1"
  $r = Get-Ratio $hd $bg
  Check ($r -ge 3.0) "$mode : a panel boundary is ${r}:1 against the page, below SC 1.4.11's 3:1"
}

# ---------------------------------------------------------------- 21
Show-Group 'The home is two columns, and the rail carries a closed list'

# PRD Cycle 4 / Slice 16. The composition itself is a labelled assumption, not
# a finding — these checks assert that the build matches what the PRD decided,
# not that the decision is validated. What validates it is a first-click test
# against the block stack it replaces.

$homeBlock = ''
if ($homeRendered -match '(?s)<div id="learning_home".*?(?=<div id="chapter_screen")') { $homeBlock = $Matches[0] }
$railBlock = ''
if ($homeRendered -match '(?s)<aside class="home-rail".*?</aside>') { $railBlock = $Matches[0] }

Check ($homeBlock.Length -gt 0) 'the learning_home block could not be isolated, so nothing below is scoped to it'

# Two columns, and the content column is the wider one. Computed at the 1024px
# viewport the criterion names rather than asserted, because "wider" is a
# consequence of the track sizes and the container padding, not a claim.
#
# 2026-07-31: the rail moved to the LEFT track, so the pattern accepts the fixed
# track on either side. Which side it is painted on is explicitly not what the
# criterion governs — document order is, and that is asserted separately below.
$gridM = [regex]::Match($styles, '(?s)\.home-layout\s*\{[^}]*grid-template-columns:\s*(?:minmax\(0,\s*1fr\)\s+(\d+)px|(\d+)px\s+minmax\(0,\s*1fr\))')
Check ($gridM.Success) `
  '.home-layout is not a two-track grid of a flexible content column plus a fixed rail (Slice 16 composition)'
if ($gridM.Success) {
  $railPx = [int]($gridM.Groups[1].Value + $gridM.Groups[2].Value)
  # .home-main caps at 1120px with 24px padding each side; .home-layout adds a
  # 24px gap between the two tracks.
  $contentAt1024 = 1024 - 48 - 24 - $railPx
  Check ($contentAt1024 -gt $railPx) `
    "at a 1024px viewport the content column computes to ${contentAt1024}px against a ${railPx}px rail, so the rail is not the narrower of the two"
}

# The rail is not the first column IN DOCUMENT ORDER. This is the whole of the
# criterion, and it is the half that survives the 2026-07-31 side swap: a
# screen-reader user reaches the primary action first whichever track the rail
# is painted in, because the markup order never changed.
$colIdx  = $homeRendered.IndexOf('id="home_content_col"')
$railIdx = $homeRendered.IndexOf('id="home_rail"')
Check ($colIdx -gt 0 -and $railIdx -gt $colIdx) `
  'the rail precedes the content column in document order, so a keyboard or screen-reader user reaches the secondary signals before the primary action'

# The painted swap is done with explicit grid placement, not `order` or
# `direction: rtl`.
#
# 2026-07-31: this check previously banned reordering outright and its message
# claimed any CSS reorder "separates the painted order from the reading order".
# That was stricter than the criterion it was guarding — Slice 16 permits the
# rail on either side in as many words — and the message was wrong on the
# mechanism too: `order` and `grid-column` both leave reading order untouched.
# What the check is really worth is holding the swap to ONE mechanism, so it is
# narrowed to that rather than deleted. `direction: rtl` stays banned because it
# is not a placement tool: it would flip inline alignment inside both columns as
# a side effect.
Check ($styles -notmatch '(?s)\.home-layout\s*\{[^}]*direction:\s*rtl') `
  '.home-layout swaps its tracks with direction: rtl, which also flips inline alignment inside both columns'
Check ($styles -notmatch '(?s)\.home-(?:rail|col-content)\s*\{[^}]*order:\s*\d') `
  'the columns are placed with `order`, not with explicit grid-column. Both paint the same; `order` is the one that gets copied onto a flex container where it does break reading order'
Check ($styles -match '(?s)\.home-rail\s*\{[^}]*grid-column:\s*1' -and $styles -match '(?s)\.home-col-content\s*\{[^}]*grid-column:\s*2') `
  'the painted side swap is not expressed as explicit grid placement, so which column lands where depends on source order and would silently revert if the markup were reordered'

# The narrow layout must RESET that placement. `grid-column: 2` on a
# single-track grid creates an implicit second column, which would put the
# content column beside a track that no longer exists and take the 360px
# viewport into horizontal scroll.
Check ($styles -match '(?s)@media \(max-width: 767px\)(?:(?!@media).)*?\.home-col-content\s*\{[^}]*grid-column:\s*1') `
  'the explicit grid placement is not reset at narrow width, so the content column lands in an implicit second track and the surface scrolls sideways at 360px'

# The rail's contents are a CLOSED list: the Ask field, the program card and
# the course-progress counter, and nothing else. Stated as a closed list because
# an open one would let a streak, a league or a promotional slot return without
# a decision (PRD section 14).
#
# AMENDED 2026-07-31 by Cycle 5, from two members to three. The closed list did
# its job: adding the Ask field cost a section-14 overturn, a section-2
# assumption, and this edit — which is exactly the decision an open list would
# have let someone skip. It is still closed, and a fourth member costs the same
# three edits. The membership is asserted as an exact SET below rather than as a
# count, so an addition fails here even if it happens to keep the totals equal.
# Slot ROOTS only. Matching every `id="home_*"` inside the rail would also
# collect the Ask box, its recent list, the task list and the progress fill,
# which are contents of slots rather than slots. A slot root is identified by
# its structural class, and the class match is anchored so `home-ask-box` does
# not read as `home-ask`. Attribute order varies across these tags, so the id is
# pulled from the tag after the class filter rather than in one pattern.
$railSlotIds = @()
foreach ($t in [regex]::Matches($railBlock, '<(?:section|div)\s[^>]*>')) {
  $clsM = [regex]::Match($t.Value, 'class="([^"]*)"')
  if (-not $clsM.Success) { continue }
  if ($clsM.Groups[1].Value -notmatch '(^|\s)(home-ask|home-panel|home-rail-slot)(\s|$)') { continue }
  $idM = [regex]::Match($t.Value, 'id="([a-z_]+)"')
  if ($idM.Success) { $railSlotIds += $idM.Groups[1].Value }
}
$railSlotIds = @($railSlotIds | Sort-Object -Unique)
$expectedRailSlots = @('home_ask', 'home_course_progress', 'home_program_tasks')
$unexpected = @($railSlotIds | Where-Object { $expectedRailSlots -notcontains $_ })
$missing = @($expectedRailSlots | Where-Object { $railSlotIds -notcontains $_ })
Check ($unexpected.Count -eq 0) `
  "the rail carries $($unexpected -join ', '), which is not in Slice 16's closed list. Adding a slot means amending the criterion, not the markup alone"
Check ($missing.Count -eq 0) `
  "the rail is missing $($missing -join ', ')"
Check ($railBlock -notmatch '(?i)(streak|league|leaderboard|achievement|points|badge|upgrade|premium)') `
  'the rail carries a gamification or promotional slot. Slice 16 moves existing slots into it and adds no affordance (section 14)'
Check ($railBlock -notmatch 'btn-primary') `
  'the rail carries a filled control. The one-filled-control invariant is counted across both columns, not within each'

# The counter RELOCATES. Stated as a count of one, so a move that leaves the
# original in place on the Up Next card fails.
Check ((([regex]::Matches($homeRendered, 'id="home_course_count"')).Count) -eq 1) `
  'the course-progress count is authored more than once, so the relocation left a copy behind'
Check ((([regex]::Matches($homeRendered, 'class="up-next-track"')).Count) -eq 1) `
  'the progress track is authored more than once. Slice 16 states the relocation as a count of one'
Check ($homeCode -match 'function applyComposition') `
  'home.js has no applyComposition(), so PRD 11.1s Cycle 4 dispositions are described but never executed'
Check ($homeCode -notmatch 'cloneNode') `
  'home.js clones a node to place the second copy. Relocation means moving one element, not rendering two'

# The breakpoint in the script and the breakpoint in the stylesheet have to be
# the same number. If they drift, there is a band of widths where the rail is
# still painted and its contents have already been moved out of it.
$jsBp = [regex]::Match($homeCode, "NARROW\s*=\s*'\(max-width:\s*(\d+)px\)'")
Check ($jsBp.Success) 'home.js does not declare the narrow breakpoint as a single constant'
if ($jsBp.Success) {
  Check ($jsBp.Groups[1].Value -eq '767') `
    "home.js drops the rail at $($jsBp.Groups[1].Value)px; the stylesheet collapses the grid at 767px. A mismatch leaves a band of widths with an empty rail"
}
Check ($styles -match '(?s)@media \(max-width: 767px\)\s*\{(?:(?!@media).)*?\.home-layout\s*\{[^}]*grid-template-columns:\s*minmax\(0,\s*1fr\)\s*;') `
  'the grid does not collapse to a single column at 767px, so the rail survives into the narrow layout'

# Narrow-width dispositions, each of the three named in PRD 11.1.
Check ($homeCode -match "upNext\.insertBefore\(counter") `
  'the counter does not return to the Up Next card at narrow width (PRD 11.1: relocated, not dropped)'
Check ($homeCode -match "col\.insertBefore\(program, col\.firstChild\)") `
  'the program card does not become the dominant object at narrow width (PRD 11.1: relocated into the assigned-task block)'
Check ($homeCode -match "(?s)if \(narrow\).*?show\('home_switcher', false\)") `
  'the switcher is not sub-levelled at narrow width, so it takes vertical space for one course in a single column'

# ---------------------------------------------------------------- 22
Show-Group 'The switcher shows enrolments, and never pads the row'

Check ($mainCode -match 'enrolledCourses:') `
  'main.js does not write the enrolment at finalization, so the switcher would have to declare its own list'
Check ($mainCode -match 'mapped \? \[\{ id: mapped\.id, title: mapped\.title \}\] : \[\]') `
  'the enrolment is not derived from the resolved course, or does not read empty when no course resolved'
Check ($homeCode -match 'function renderSwitcher') 'home.js has no renderSwitcher()'
Check ($homeCode -match 'function enrolledCourses') `
  'the switcher reads a field directly rather than through a resolver, so a replayed handoff without it renders nothing'
Check ($homeCode -notmatch '(?i)(suggested|locked course|popular|featured)') `
  'the switcher pads its row with courses the learner is not enrolled in. A padded strip is promotional content in a structural slot'
Check ($homeCode -match "show\('home_switcher', courses\.length > 1\)") `
  'the switcher renders below two enrolments. With one course there is nothing to switch between, so it is a plural heading over a chip duplicating the card above it'
Check ($homeCode -match 'if \(courses\.length < 2\) return') `
  'the switcher builds rows for a single enrolment, so the hidden section still costs a render and can be revealed by a stray class change'
Check ($homeCode -notmatch "mark\.textContent = 'Open'") `
  'the current-course chip still reads "Open", which is an imperative on a control that then refuses to act'
Check ($homeCode -match "mark\.textContent = 'Current'") `
  'the current course carries no text marker naming it as the one in progress'
Check ($homeCode -match "setAttribute\('aria-current', 'true'\)") `
  'the current course is marked visually only. A border colour tells assistive technology nothing'
Check ($homeCode -match "home-switcher-mark") `
  'the current course is marked by colour alone, with no text equivalent'
Check ($homeCode -notmatch "home-switcher-item[^']*btn-primary") `
  'a switcher entry carries the filled treatment. The switcher is not the primary action'
Check ($homeRendered -match '(?s)<section id="home_switcher".*?</section>' -and $Matches[0] -notmatch 'btn-primary') `
  'the switcher markup contains a filled control'
$switcherIdx = $homeRendered.IndexOf('id="home_switcher"')
$upNextIdx   = $homeRendered.IndexOf('id="home_up_next"')
Check ($upNextIdx -gt 0 -and $switcherIdx -gt $upNextIdx) `
  'the switcher precedes the dominant object, so a strip of courses competes for the first screenful'

# ---------------------------------------------------------------- 23
Show-Group 'Slice 12 and Slice 13 still hold after the recomposition'

# Slice 16's Regression criterion requires these to be ENUMERATED in the
# slice's test run rather than asserted, because this slice moves the very
# elements those criteria govern. Each check below names the criterion it
# covers. A passing suite is the only evidence the move preserved them.

# --- Slice 12
Check ($homeBlock -notmatch 'width:\s*[1-9][0-9]*%') `
  'S12.1 a numeric progress value is hard-coded on the recomposed surface'
# S12.2's denominator MOVED SLOTS on 2026-07-31 and the criterion did not change.
# The headline number is now a percentage at the product owner's direction, and
# "0%" names no denominator — so the denominator has to be somewhere in the slot
# or Slice 12 fails. It is in the condition line, which is the sentence that says
# what would move the number, and that is asserted below rather than assumed.
Check ($homeCode -match "setText\('home_course_count', pct \+ '%'\)") `
  'S12.2 the headline progress value is not the percentage the slot is specified to show'
Check ($homeCode -match "'Finish 1 of ' \+ total \+ ' ' \+ many \+ ' to see progress here'") `
  'S12.2 the zero state names no denominator anywhere in the slot. "0%" carries none, so the condition line must, or the criterion is simply unmet'
# One computation, not two over the same inputs. A rounding change in one and not
# the other would print a number beside a bar that disagreed with it.
Check ($homeCode -match 'var pct = Math\.round\(\(done / total\) \* 100\)' -and `
       $homeCode -match "style\.width = pct \+ '%'") `
  'S12.1 the bar width and the printed percentage are computed separately, so they can disagree'
Check ($homeCode -match "setText\('home_course_condition', conditionFor\(done, total, 'chapter', 'chapters'\)\)") `
  'S12.2 the countable condition no longer renders in the same slot as the zero'
Check ($railBlock -match 'id="home_course_count"' -and $railBlock -match 'id="home_course_condition"') `
  'S12.2 the count and its condition were separated by the relocation. They are one slot and must move together'
Check ($homeBlock -match 'id="home_unmapped"' -and $homeBlock -match 'id="unmapped_choose_btn"') `
  'S12.3 the empty state or its recovery action did not survive the recomposition'
Check ($homeBlock -notmatch '(?i)(sponsored|upgrade to|try premium|invite a friend)') `
  'S12.3 a slot on the recomposed surface was given to promotional content'
Check ($homeCode -match "show\('home_up_next', mapped\)" -and $homeCode -match "show\('home_unmapped', !mapped\)") `
  'S12.4 the two data states no longer render through the same slots'
Check ($homeBlock -match 'id="home_skeleton"' -or $homeRendered -match 'id="home_skeleton"') `
  'S12.5 the skeletonised content region is gone'
Check ($homeCode -match 'SKELETON_DELAY_MS = 400' -and $homeCode -match 'SKELETON_MIN_MS = 500') `
  'S12.6 the two skeleton numbers changed. They are width- and layout-independent'
Check ($homeBlock -notmatch '(?i)(coach|tour|walkthrough|step 1 of|got it)') `
  'S12.7 a tour or coach-mark sequence appears before the first action'
# S12.8 guaranteed that a new account is never greeted as a returning one. The
# greeting was removed on 2026-07-31, so the criterion is now met by there being
# no returning-state copy to mis-apply, and by the one place the states still
# differ saying "Start" rather than "Continue". The guarantee is unchanged; what
# it is checked against moved.
Check ($homeCode -notmatch '(?i)(good to see you again|welcome back|picking up where)') `
  'S12.8 returning-state copy is back on the first-run surface'
Check ($homeCode -match "var verb = first \? 'Start' : 'Continue'") `
  'S12.8 the first-run and returning states are no longer distinguishable anywhere'
Check ($homeBlock -notmatch '(?i)welcome back') `
  'S12.8 the recomposed surface greets a first-run learner as a returning one'

# --- Slice 13
Check ($homeCode -match 'var mapped = !!state\.initialCourseId') `
  'S13.1 the primary action no longer resolves from the stored first-course identifier'
Check ($homeCode -match "isProgram = state\.entryPath === 'program'") `
  'S13.2 the program branch no longer resolves from the confirmed enrolment'
Check ($homeCode -notmatch '(?i)(recency|popularity|trending|recommendedFor|activityHistory)') `
  'S13.3/S13.4 the recomposed surface consults a ranker or an activity source'
Check ($homeCode -notmatch "(?i)chaptersDone\s*\?\s*") `
  'S13.3 the primary action branches on activity history, so two histories would produce two different actions'
Check ($homeCode -match "show\('start-lesson-btn', mapped\)") `
  'S13.5 the primary action is no longer gated on a resolved course, so an unresolvable one could still render an action'

# ---------------------------------------------------------------- 24
Show-Group 'Search simulates a catalogue and says so, and still cannot move the primary action'

# PRD Cycle 5 / Slice 17, REVISED 2026-07-31 by Cycle 7 / Slice 19.
#
# Slice 17 carried three prohibitions: no suggestion or completion, no answer or
# result list, and no change to the primary action. The product owner overturned
# the first two; §14 records the overturn with the original reasoning intact, as
# it does for the Slice 17 overturn before it.
#
# WHAT THIS GROUP GUARDS NOW IS THE PRICE OF THAT OVERTURN, and it is a higher
# price than Slice 17's, because a surface that returns plausible course cards
# can fabricate in a way a surface that returns nothing cannot:
#   1. the simulation is LABELLED where it renders, not caveated elsewhere;
#   2. an empty result stays empty — no substitute set;
#   3. results come from an EXPLICIT search, not from typing (no typeahead);
#   4. the starters are a declared constant, not derived from the learner;
#   5. the third prohibition is untouched — searching cannot re-point Up Next.
# Item 5 is the load-bearing one: if it fails, Slice 13's determinism criterion
# is dead and §2.1 F3's disposition is wrong.

$askBlock = ''
if ($homeRendered -match '(?s)<section class="home-ask".*?</section>') { $askBlock = $Matches[0] }
Check ($askBlock.Length -gt 0) 'the search section could not be isolated, so nothing below is scoped to it'

# Placement: first in the rail, and the rail is still second in reading order.
$askIdx = $homeRendered.IndexOf('id="home_ask"')
Check ($askIdx -gt $railIdx -and $askIdx -lt $homeRendered.IndexOf('id="home_program_tasks"')) `
  'the search field is not the first slot in the rail'
Check ($askIdx -gt $colIdx) `
  'the search field precedes the content column in document order, so it is reached before the primary action'

# Expansion: in place, not an overlay. Slice 12 forbids an overlay before the
# first action and neither Slice 17 nor Slice 19 suspends that.
Check ($askBlock -match 'aria-expanded="false"' -and $askBlock -match 'aria-controls="home_ask_box"') `
  'the search trigger does not expose its expanded state, so the box opens silently for assistive technology'
Check ($askBlock -match '<label class="home-ask-label" for="home_ask_input"') `
  'the search input has no programmatic label'
Check ($askBlock -notmatch '(?i)(modal|overlay|role="dialog")') `
  'the search box is a modal or overlay. Slice 12 forbids an overlay before the first action'
Check ($homeCode -match 'function collapseAsk') `
  'the search box has no collapse path. A control that expands with no way back is a trap'
Check ($homeCode -match "(?s)askBox\.addEventListener\('keydown'.*?Escape.*?collapseAsk\(true\)") `
  'Escape does not collapse the search box and return focus to its trigger'

# A single-line field, and a clear path out of a typed query. Slice 19 replaced
# the multi-line question box: the shape of the input is the promise it makes.
Check ($askBlock -match '<input type="search"[^>]*id="home_ask_input"') `
  'the search input is not a single-line search field. A textarea invites a paragraph and this slot answers a phrase'
Check ($askBlock -notmatch '<textarea') `
  'the multi-line question box survives alongside the search field, so the slot asks for two different things at once'
Check ($askBlock -match 'id="home_ask_clear"' -and $askBlock -match 'aria-label="Clear the search field"') `
  'the search field has no labelled clear control'
Check ($homeCode -match '(?s)function clearSearch\([\s\S]{0,400}?results\.textContent = ') `
  'clearing the query leaves the result list up, so the surface keeps asserting a match for a phrase that is gone'

# --- 1. The simulation is labelled where it renders ---
Check ($homeCode -match 'Simulated catalogue') `
  'the result list does not state that its catalogue is simulated. An unlabelled plausible result is the fabrication class this document is written against'
Check ($homeCode -match 'placeholder content for this prototype') `
  'the placeholder label does not say it is placeholder content in the learner''s own words'
$renderResultsFn = ''
if ($homeCode -match '(?s)function renderResults\(query, results\)\s*\{.*?\n  \}') { $renderResultsFn = $Matches[0] }
Check ($renderResultsFn.Length -gt 0) 'renderResults() could not be isolated'
Check ($renderResultsFn -match 'Simulated catalogue') `
  'the placeholder label is not emitted by renderResults() itself, so a result can render without it'

# --- 2. No substitute set on an empty result, and a fill-in is never a match ---
Check ($homeCode -match 'Nothing in this placeholder set matches') `
  'a search matching nothing does not say so'
Check ($homeCode -notmatch '(?i)searchCatalogue\.slice\(0, ?3\)' -and $dataCode -notmatch '(?i)if \(!terms\.length\) return searchCatalogue') `
  'an unmatched query falls back to a default set, presenting non-matches as answers'
Check ($dataCode -match 'if \(!terms\.length\) return \{ matches: \[\], related: \[\] \};') `
  'a query with no usable terms does not return an empty result'
# Topic adjacency hangs off a match. With no match there is no anchor, so
# offering the topic set anyway would be the substitute set by another route.
Check ($dataCode -match 'if \(!matches\.length\) return \{ matches: \[\], related: \[\] \};') `
  'an unmatched query still returns related courses, so the topic set becomes the substitute set the check above rules out'
# The related list must be DISJOINT from the matches and must never be counted
# with them. A fill-in presented as a match is fabricated relevance.
Check ($dataCode -match 'chosen\.indexOf\(course\.id\) === -1') `
  'the related list can repeat a course already shown as a match'
Check ($renderResultsFn -match 'matches\.length \+ \(matches\.length === 1') `
  'the result count includes related courses, so it states a relevance no match established'
Check ($renderResultsFn -match "textContent = 'Related in this placeholder set'") `
  'the related courses render with no heading of their own, so a topic fill-in reads as a match'

# --- 3. Results come from an explicit search, not from typing ---
# The input handler may maintain the clear control and re-open the panel; it may
# NOT compute results. Isolated and asserted on its body, so the check keeps
# working as the handler grows rather than pinning one exact line.
$inputHandler = ''
if ($homeCode -match "(?s)askInput\.addEventListener\('input', function \(\) \{.*?\n      \}\);") { $inputHandler = $Matches[0] }
Check ($inputHandler.Length -gt 0) 'the input-event handler could not be isolated'
Check ($inputHandler -match 'syncClearButton\(\)') `
  'the input handler does not maintain the clear control, so it lingers on an emptied field'
Check ($inputHandler -notmatch '(renderResults|searchCourses|resultCard)') `
  'results are computed on the input event, which is the typeahead Slice 17 excluded and Cycle 7 did not reinstate'
# Escape leaves focus in the field, and `focus` cannot fire again on an element
# that never lost it — so without a re-open path a keyboard learner who pressed
# Escape is locked out of the starters. Both recoveries are asserted.
Check ($inputHandler -match 'setAskExpanded\(true\)') `
  'typing does not re-open the panel, so a keyboard learner who pressed Escape cannot reach the starters again'
Check ($homeCode -match "(?s)askInput\.addEventListener\('click'.*?setAskExpanded\(true\)") `
  'clicking an already-focused field does not re-open the panel, so a pointer learner who pressed Escape is stuck'
Check ($homeCode -match '(?s)function submitAsk\(\)\s*\{.*?setAskExpanded\(true\);\s*\n\s*renderResults\(') `
  'asking does not open the panel before rendering, so Enter from a collapsed field writes results into a hidden container'
Check ($askBlock -match 'autocomplete="off"') `
  'the search field leaves the browser history dropdown on, so the surface offers completions it did not author'

# --- 4. The starters are a declared constant, not derived from the learner ---
Check ($dataCode -match '(?s)const searchStarters = \[.*?\];') `
  'the starters are not declared as a constant in data.js, so the view invents them'
$startersConst = ''
if ($dataCode -match '(?s)const searchStarters = \[.*?\];') { $startersConst = $Matches[0] }
Check (([regex]::Matches($startersConst, "'")).Count -eq 6) `
  'expected exactly three starter prompts'
$startersFn = ''
if ($homeCode -match '(?s)function renderStarters\(\)\s*\{.*?\n  \}') { $startersFn = $Matches[0] }
Check ($startersFn.Length -gt 0) 'renderStarters() could not be isolated'
foreach ($derived in @('goalId', 'initialCourseId', 'courseTitle', 'enrolledCourses', 'displayName')) {
  Check ($startersFn -notmatch "state\.$derived") `
    "renderStarters() reads state.$derived, so the starters are personalization rather than the declared constant §9 requires"
}
# Activating a starter FILLS and does not search: a control that writes the
# phrase and submits it denies the learner the edit the starter exists to make
# cheap.
Check ($startersFn -match 'input\.value = text;' -and $startersFn -notmatch 'submitAsk\(\)') `
  'a starter submits as well as fills, so the learner never gets to edit the phrase it wrote for them'
# Every starter must resolve against the catalogue, or it teaches the learner
# the field is broken.
foreach ($starter in @('English', 'math', 'money')) {
  Check ($dataCode -match "(?i)'[^']*$starter[^']*'") `
    "no starter mentions $starter, so the declared starters and the catalogue keywords have drifted apart"
}

# --- 5. The determinism criterion, UNTOUCHED by the overturn ---
# If searching can re-point the primary action, F3's disposition is wrong and
# Slice 13 is broken. Asserted by isolating each function that runs on a search
# and confirming none writes a field the primary action reads.
$submitFn = ''
if ($homeCode -match '(?s)function submitAsk\(\)\s*\{.*?\n  \}') { $submitFn = $Matches[0] }
Check ($submitFn.Length -gt 0) 'submitAsk() could not be isolated'
foreach ($fn in @($submitFn, $renderResultsFn)) {
  foreach ($field in @('initialCourseId', 'courseTitle', 'firstChapterTitle', 'chapterTotal', 'chaptersDone')) {
    Check ($fn -notmatch "state\.$field\s*=") `
      "the search path writes state.$field, so searching can change the primary action. Slice 13's determinism criterion fails and §2.1 F3 no longer holds"
  }
}
Check ($submitFn -match 'state\.searchQueries = ') `
  'submitAsk() does not record the query, so the slot collects nothing and its zero state can never populate'
# A result card is inert and says so. Routing needs a catalogue and a lesson
# player, both §14 non-goals; re-pointing Up Next instead would break Slice 13.
# Scoped to resultCard(), which builds BOTH the matches and the related set, so
# one assertion covers every card the surface can render.
$resultCardFn = ''
if ($homeCode -match '(?s)function resultCard\(course\)\s*\{.*?\n  \}') { $resultCardFn = $Matches[0] }
Check ($resultCardFn.Length -gt 0) 'resultCard() could not be isolated'
Check ($resultCardFn -match 'Opening a course is out of scope') `
  'a result card is a silent dead end rather than a labelled stub'
Check ($resultCardFn -notmatch '(?i)(location\.href|location\.assign|window\.open)') `
  'a result card navigates. There is no course surface to navigate to and §14 does not build one'
foreach ($field in @('initialCourseId', 'courseTitle', 'firstChapterTitle', 'chapterTotal', 'chaptersDone')) {
  Check ($resultCardFn -notmatch "state\.$field\s*=") `
    "activating a result card writes state.$field, so a search result can re-point the primary action"
}

# The zero state is the learner's own input, never the starters.
Check ($homeCode -match 'Searches you run will appear here') `
  'the search box has no zero state, so an empty recent list renders as nothing at all'
Check ($homeCode -match 'function recentSearches') `
  'the recent list reads a field directly rather than through a resolver, so a replayed handoff without it throws'
Check ($homeCode -match 'recent\.slice\(\)\.reverse\(\)') `
  'the recent searches are not ordered most-recent-first'
Check ($homeCode -notmatch "(?i)searchQueries = \[\s*'") `
  'the recent list is seeded with a constant, so the zero state is a lie for anyone who has searched nothing'
$recentFn = ''
if ($homeCode -match '(?s)function renderAskRecent\(\)\s*\{.*?\n  \}') { $recentFn = $Matches[0] }
Check ($recentFn.Length -gt 0) 'renderAskRecent() could not be isolated'
Check ($recentFn -notmatch 'searchStarters') `
  'the recent list falls back to the starters, so a learner who has searched nothing is shown a constant as their own history'

# The attachment control is GONE, not hidden. Removed 2026-07-31 at the product
# owner's direction: §14's moderation position for 13-to-17-year-olds is still
# unspecified, and the cheapest way to hold that line is to not ship the
# affordance at all.
Check ($askBlock -notmatch 'home_ask_attach' -and $askBlock -notmatch 'attach_file') `
  'the attachment control is still in the markup'
Check ($homeCode -notmatch 'home_ask_attach') `
  'home.js still binds the removed attachment control, so boot() throws on a null element'
Check ($homeRendered -notmatch 'type="file"') `
  'a file input reached the rendered home. The moderation position for 13-to-17-year-olds is an open §15 decision'

# The fill is still spent once, counted across both columns and now across a
# result list that could hold three more candidates for it.
Check ($askBlock -notmatch 'btn-primary') `
  'the search submit control is filled. The primary action on the dominant object owns the only fill on this surface'
Check ($askBlock -match 'btn-secondary') `
  'the search submit control has no button treatment at all'
Check ($resultCardFn -notmatch 'btn-primary') `
  'a result card is filled, so three of them outweigh the one action this surface exists to produce'
# The submit control says "Ask", not "Search". Changed 2026-07-31 at the product
# owner's direction: the field asks a question in the learner's words and the
# verb on the control should be the one they would use to answer it.
Check ($askBlock -match 'id="home_ask_submit">Ask</button>') `
  'the submit control has drifted from the agreed "Ask" copy'

Show-Group 'The tracker names the goal the learner chose, and hides it when there is none'

# Added 2026-07-31 at the product owner's direction: the goal from intake now
# renders above the progress bar.
#
# IT IS NOT A DUPLICATE OF THE COURSE, which is the test §7.6's N-of-one rule
# sets. The goal is what the learner ASKED FOR; the course is what the system
# RESOLVED it to. Showing both is the closest this surface comes to answering
# §2's worry that a learner cannot tell whether their intake answer was used —
# §2.1 F3 says the home renders the intake result, and until now it did so only
# by implication, through a course title the learner never typed.
Check ($homeRendered -match 'id="home_course_goal"') `
  'the tracker has no slot for the chosen goal'
$goalIdx = $homeRendered.IndexOf('id="home_course_goal"')
Check ($goalIdx -gt 0 -and $goalIdx -lt $homeRendered.IndexOf('id="home_course_fill"')) `
  'the goal renders below the progress bar rather than above it'
Check ($homeRendered -match 'class="home-rail-goal is-hidden"') `
  'the goal row starts visible, so a learner with no goal sees an empty labelled row before the script runs'

# THE GOAL IS THE HEADLINE as of 2026-07-31, and "Your current learning path" is
# now the FALLBACK for a learner who has no goal. Exactly one of the two always
# renders: neither would leave the slot unlabelled, which is the complaint that
# put a heading here in the first place, and both would be two titles for one
# slot.
Check ($homeRendered -match 'id="home_course_fallback_title">Your current learning path</h3>') `
  'the fallback heading is gone, so a program learner (who has no goal) gets an unlabelled progress slot'
Check ($homeCode -match "show\('home_course_fallback_title', !goalTitle\)") `
  'the fallback heading is not gated on the absence of a goal, so the slot renders two titles or none'
$goalHeadIdx = $homeRendered.IndexOf('id="home_course_goal"')
Check ($goalHeadIdx -lt $homeRendered.IndexOf('id="home_course_fallback_title"')) `
  'the goal chip does not precede the fallback heading, so it is not the headline'

# The chip stays visible at 360px, unlike the heading it replaces. That heading
# is hidden inside the Up Next card because the card already names the COURSE —
# an argument that does not reach the goal, which the card never states.
Check ($styles -match '\.up-next > \.home-rail-slot > \.home-rail-goal \{ display: inline-flex; \}') `
  'the goal chip is hidden at 360px along with the generic title, dropping the one fact on the surface the learner supplied'

# CONTRAST. --pri is a FILL colour: #ffcb1d measures about 1.7:1 on white and
# fails SC 1.4.3 outright as type, so the chip must use it as a mixed GROUND
# with full-strength ink over it, never as text.
Check ($styles -match '\.home-rail-goal \{[^}]*background: color-mix\(in srgb, var\(--pri\)') `
  'the goal chip does not derive its ground from the brand yellow by mixing, so it will not re-derive in dark mode'
Check ($styles -notmatch '\.home-rail-goal-(label|value) \{[^}]*color: var\(--pri\)') `
  'the chip uses the brand yellow as TEXT. #ffcb1d measures about 1.7:1 on white and fails SC 1.4.3'
# Measured in-browser both themes: label and value 14.9:1 light, 6.09:1 dark.
# The label was --ink2 and came in at 4.26:1 on the dark chip — under AA on 10px
# text — so both lines sit at full --ink and the hierarchy is carried by type.
Check ($styles -match '(?s)\.home-rail-goal-label \{[^}]*color: var\(--ink\);') `
  'the chip label is not at full ink. It was --ink2, which measures 4.26:1 on the dark chip and fails SC 1.4.3 at 10px'
Check ($styles -notmatch '(?s)\.home-rail-goal-label \{[^}]*opacity:') `
  'the chip label is translucent, which lowers its real contrast while getComputedStyle still reports the full token — a failure no contrast check can see'

# Resolved through the SHARED lookup, so the string the home prints is the one
# the intake screen presented. A second mapping here could drift from the goal
# set and print a title no learner was ever shown.
Check ($dataCode -match 'function goalTitleFor') `
  'the goal title is not resolved from the goal set, so the home can print a name the intake never showed'
Check ($dataCode -match 'window\.goalTitleFor = goalTitleFor;') `
  'the goal lookup is not exported, so the home falls back to its own mapping'
Check ($homeCode -match 'window\.goalTitleFor\(state\.goalId\)') `
  'the goal is not read from the handoff through the shared lookup'
Check ($homeCode -notmatch "goalId === 'english' \?") `
  'the home carries its own goal-to-title branch, which is a second source that can disagree with the goal set'

# HIDDEN, NOT FAKED. A program learner arrives with no goal, and a replayed
# handoff may predate the field. Printing a plausible goal there would be
# putting words in the learner's mouth about their own intent — a worse
# fabrication than the invented progress values Cycle 2 removed, because it is
# a claim about the person rather than about their data.
Check ($dataCode -match '(?s)function goalTitleFor\(goalId\) \{\s*if \(!goalId\) return null;') `
  'a missing goal id does not resolve to null, so the row can render something for a learner who chose nothing'
Check ($dataCode -match '(?s)function goalTitleFor[\s\S]{0,600}?\n  return null;\s*\n\}') `
  'an unrecognised goal id falls back to a default title rather than to nothing'
Check ($homeCode -match "show\('home_course_goal', !!goalTitle\)") `
  'the goal row is not gated on there being a goal to show'

# ---------------------------------------------------------------- 25a
Show-Group 'The dominant object fills its column and carries placeholder cover art'

# Cycle 7, added 2026-07-31 at the product owner's direction. Two changes with
# one purpose: the card that Slice 16 calls the dominant object now looks like
# it, instead of sitting short with the viewport empty beneath it.

# The height. `.home-main` was already flex:1 inside a 100dvh card, so this is
# the grid claiming height that existed rather than new height being invented.
Check ($styles -match '(?s)\.home-layout \{[^}]*flex: 1;') `
  'the layout grid does not fill the shell, so the content column has no spare height to give the card'
Check ($styles -notmatch '(?s)\.home-layout \{[^}]*align-items: start;') `
  'the grid still sizes both tracks to content, which is what kept the card short'
Check ($styles -match '(?s)\.home-col-content > \.up-next \{[^}]*flex: 1;') `
  'the Up Next card does not grow into the column'
# Scoped with the CHILD combinator on purpose: the program card relocates into
# this column at 360px, and only one object can be the one that grows.
Check ($styles -match '\.home-col-content > \.up-next') `
  'the growth rule is not scoped to the card sitting directly in the content column'

# The cover. It is PLACEHOLDER ART and says so on itself — the same rule the
# search results follow, because a caveat that lives anywhere but on the thing
# it qualifies is a caveat nobody reads.
$upNextBlock = ''
if ($homeRendered -match '(?s)<section id="home_up_next".*?</section>') { $upNextBlock = $Matches[0] }
Check ($upNextBlock.Length -gt 0) 'the Up Next section could not be isolated'
# The on-screen "Placeholder cover" tag was REMOVED 2026-07-31 at the product
# owner's direction, and the check that required it is replaced rather than
# deleted so the distinction it turned on stays asserted.
#
# WHY THIS ONE COULD GO AND THE SEARCH LABEL COULD NOT. A result list asserts a
# FACT — that these courses match the query — and an unlabelled fabricated fact
# is the failure class this document is written against. Cover art asserts
# nothing; it is chrome. What the tag protected was a REVIEWER mistaking stock
# art for licensed final art, and data.js plus the section 9 criteria carry that
# now. The check below is what keeps the two from being confused later: the
# search label must still be there.
Check ($homeCode -match 'Simulated catalogue') `
  'the search results lost their placeholder label too. Removing the cover tag was scoped to decoration; the result list asserts a fact and must still say it is simulated'
Check ($upNextBlock -notmatch 'up-next-cover-tag') `
  'the cover tag markup is back without its stylesheet rule, so it renders unstyled'
Check ($styles -notmatch '^\.up-next-cover-tag \{') `
  'the removed tag''s stylesheet rule survives its markup'
Check ($upNextBlock -match '<div class="up-next-cover"[^>]*aria-hidden="true"') `
  'the cover is exposed to assistive technology. It duplicates the course title at best, in the two nodes before the primary action'
Check ($upNextBlock -match '<img class="up-next-cover-img[^>]*alt=""') `
  'the cover image has no empty alt, so decorative art is announced'

# The deadlock that shipped and was caught in-browser: an image that starts
# display:none and is revealed on load will NEVER load if it is also lazy —
# Chrome does not load a lazy image that is not being rendered.
Check ($upNextBlock -notmatch 'up-next-cover-img[^>]*loading="lazy"') `
  'the cover image is lazy AND hidden until load, which deadlocks: it waits for a load that never starts. It is also the largest image on the first screen'

# The fallback is a real design, not a nicety: a published Artifact's CSP blocks
# every external host, so the gradient and glyph are what renders there.
Check ($homeCode -match '(?s)function renderCover\(\)\s*\{.*?img\.onerror') `
  'a cover that fails to load leaves a broken image on the dominant object'
Check ($homeCode -match "img\.classList\.add\('is-hidden'\);\s*\n\s*if \(!entry \|\| !entry\.cover\)") `
  'a course with no cover art in the catalogue keeps the previous course''s photograph'
Check ($homeCode -match '(?s)function coverFor\(courseId\)') `
  'the cover is not resolved from the catalogue by id, so the card and a search result can disagree about the same course'
Check ($dataCode -match "cover: 'https://images\.unsplash\.com/") `
  'the catalogue carries no cover art'
# Every catalogue entry has one, or a course silently falls back while its
# neighbours do not — which reads as a bug rather than as a decision.
$coverCount = ([regex]::Matches($dataCode, "cover: 'https://images\.unsplash\.com/")).Count
$courseCount = ([regex]::Matches($dataCode, "\{ id: '[a-z]+-1',")).Count
Check ($coverCount -eq $courseCount) `
  "expected every one of the $courseCount catalogue courses to carry cover art, found $coverCount"

# ---------------------------------------------------------------- 25
Show-Group 'The course tracker states its own job and enumerates the course'

# PRD Cycle 6 / Slice 18. This group exists because of user feedback, not a
# study: learners reported not knowing what the "Course progress" rail slot was
# about. §11.1 had already written down the mechanism when it explained why the
# node relocates back at 360px — the counter and its subject should not be
# separated — and Cycle 4 separated them at wide width anyway.
#
# The REFRAME (progress bar to enumerated outline) is a labelled §2 assumption,
# not an evidenced improvement. `research/PATTERNS.md` supports naming the
# subject (F6, 3 of 7 platforms), but its peer review on 2026-07-29 retracted
# the stronger claim that one progress framing beats another at low progress as
# "confounded and untested". These checks assert the build matches the decision;
# the first-click test is what would validate it.

$trackerBlock = ''
if ($homeRendered -match '(?s)<div id="home_course_progress".*?</div>\s*</aside>') { $trackerBlock = $Matches[0] }

# The heading, which is where the reported defect was answered.
#
# SUPERSEDED 2026-07-31. Slice 18 originally required the course NAME here, from
# data. The product owner replaced it with a function label, on the ground that
# the Up Next card one column over already names the course and the rail was
# repeating it. These checks now assert the replacement, and the two they
# replaced are recorded above so a future reader does not read their absence as
# the referent regression coming back a third time.
#
# SUPERSEDED AGAIN 2026-07-31, later the same day: the learner's chosen GOAL is
# now the headline and this label is the fallback for a learner who has no goal.
# The check is loosened from an exact-markup match to a copy match for that
# reason and no other — the group above asserts the two-headings-one-slot rule
# that replaced it, so nothing is left unguarded by the loosening.
Check ($homeRendered -match 'class="home-rail-title" id="home_course_fallback_title">Your current learning path</h3>') `
  'the tracker fallback heading is not the agreed label, so the slot is unlabelled or has drifted from the copy decision'
Check ($homeRendered -notmatch 'Course progress') `
  'the generic "Course progress" heading survives. It was the label users could not interpret'
Check ($homeRendered -notmatch "(?i)What you'll learn") `
  'the heading promises learning OUTCOMES over rows that are chapter titles. The copy would claim more than the content delivers'

# The label is a LITERAL, so nothing may write it at runtime. A setText() onto
# this node would mean the heading has a second source and the two can disagree.
Check ($homeCode -notmatch 'home_course_progress_name') `
  'home.js still writes the tracker heading, so the label in the markup is not the only thing that sets it'

# The course is still named ONCE, on the dominant object. This is what the slot
# now depends on: drop it and the chapters belong to no stated course anywhere.
Check ($homeCode -match "setText\('home_course_title', state\.courseTitle\)") `
  'nothing on the surface names the course from data. The tracker gave that job to the Up Next card, which no longer does it'

# The count and the list cannot disagree, because there is only one of them.
Check ($mainCode -match 'chapterTotal: mapped \? mapped\.chapters\.length : null') `
  'the denominator is not derived from the chapter list, so a count and its contents can drift apart again'
Check ($mainCode -notmatch 'skills:\s*\d') `
  'COURSE_MAP still declares a skill COUNT beside the list. Two fields describing one thing is how they disagree'
Check ($mainCode -match 'firstChapterTitle: mapped \? mapped\.chapters\[0\] : null') `
  'the first chapter is declared separately from the list rather than read out of it'
Check ($mainCode -match 'courseChapters: mapped \? mapped\.chapters\.slice\(\) : null') `
  'the course structure is not written onto the handoff, so the tracker would have to declare its own'
Check ($mainCode -notmatch 'firstSkill:\s*.') `
  'the old standalone firstSkill field survives alongside the list'

# Built from the handoff, never from a constant.
Check ($homeCode -match 'function renderChapters') 'home.js has no renderChapters()'
Check ($homeCode -match 'function courseChapters') `
  'the tracker reads a field directly rather than through a resolver, so a replayed handoff without it throws'
Check ($homeCode -match 'courseChapters\(\)\.forEach') `
  'the chapter rows are not iterated from the resolved list'
Check ($homeRendered -match '<ol class="home-chapter-list" id="home_chapter_list"></ol>') `
  'the chapter list is not empty in the markup, so rows exist that no data produced'

# Completion is derived, never declared. Same rule as every other counter here.
Check ($homeCode -match 'var complete = i < done') `
  'chapter completion is not computed from the learner s own progress'
Check ($homeCode -match 'renderChapters\(done\)') `
  'renderChapters is called without the completion count, so it cannot mark state from data'
Check ($trackerBlock -notmatch '(?i)(is-done|is-current)') `
  'a chapter state is hard-coded in the markup, so a first-run learner sees progress they did not make'

# Not a browse surface. PATTERNS.md warns against routing the learner into one.
$chaptersFn = ''
if ($homeCode -match '(?s)function renderChapters\(done\)\s*\{.*?\n  \}') { $chaptersFn = $Matches[0] }
Check ($chaptersFn.Length -gt 0) 'renderChapters() could not be isolated'
Check ($chaptersFn -notmatch "createElement\('button'\)" -and $chaptersFn -notmatch 'addEventListener') `
  'the chapter rows are interactive. An outline orients; a menu of clickable skills competes with the primary action beside it'
Check ($chaptersFn -match "createElement\('li'\)") `
  'the chapter rows are not list items, so the outline has no list semantics'

# State is exposed, and not by colour alone.
#
# AMENDED 2026-07-31 at the product owner's direction: the current row's "Next"
# chip is REMOVED. It restated what the primary action already says in full a
# few pixels away — "Start: Introduce yourself" — and a second, weaker label for
# the same chapter is the two-names-for-one-thing defect this list was
# restructured to remove. Completion keeps its text, because nothing else on the
# surface states it.
#
# SC 1.4.1 survives the removal for a reason worth asserting rather than
# assuming: the three states differ by GLYPH, not by colour, so a non-colour
# visual distinction remains. That is what the third check below pins down —
# without it, a later change to a single shared icon would silently reduce this
# list to colour alone and no test would notice.
Check ($chaptersFn -match "setAttribute\('aria-current', 'step'\)") `
  'the current skill is marked visually only. aria-current is now the whole of its programmatic exposure, since the Next chip was removed'
Check ($chaptersFn -match "textContent = 'Done'") `
  'completion is carried by icon and colour with no text equivalent'
Check ($chaptersFn -notmatch "'Next'") `
  'the Next chip is back. It duplicates the primary action, which names the same chapter in full a few pixels away'
Check ($chaptersFn -match "complete \? 'check_circle' : \(current \? 'play_circle' : 'circle'\)") `
  'the three chapter states no longer differ by glyph, so with the Next chip gone the current row is distinguished by colour alone and SC 1.4.1 fails'
Check ($chaptersFn -match "aria-hidden") `
  'the chapter state icon is not hidden from assistive technology, so each row is announced with its glyph name'

# A replayed handoff is not filled with invented names.
Check ($homeCode -match "'Chapter ' \+ \(i \+ 1\)") `
  'a chapter with no title in the handoff is given an invented name rather than its position'

# The action and the tracker cannot disagree, because they read the same list.
#
# This guards a defect the tracker EXPOSED rather than caused. Before Slice 18
# the handoff carried only firstChapterTitle, so a learner two skills in saw
# "Continue: Read a bar chart" on a button that opened skill 3 — the label and
# the destination disagreed and nothing on screen could reveal it. Putting the
# outline beside the button made it obvious in one glance.
Check ($homeCode -match 'var nextTitle = courseChapters\(\)\[done\]') `
  'the primary action label is not read from the current position, so it names skills[0] forever while opening something else'
Check ($homeCode -notmatch 'actionLabel\(first, state\.firstChapterTitle') `
  'the action label still reads firstChapterTitle, which is only correct for a learner who has done nothing'
Check ($homeCode -match 'courseChapters\(\)\[state\.chaptersDone\]') `
  'openChapter() does not resolve its destination from the same list the label does'
Check ($homeCode -match 'done === 0 \? state\.firstChapterMinutes : null') `
  'a duration is shown for a skill whose cost the handoff never carried. An unknown cost is omitted, never estimated'

# The heading is scoped to the rail. The rule is unchanged from when it carried
# the course name; the REASON is now that at 360px the slot sits inside the Up
# Next card, whose heading already establishes what the learner is working on,
# so a second heading introducing the same thing is Slice 16's duplication.
Check ($styles -match '(?s)\.home-rail-title\s*\{[^}]*display:\s*none' -and `
       $styles -match '(?s)\.home-rail > \.home-rail-slot > \.home-rail-title\s*\{[^}]*display:\s*block') `
  'the tracker heading is not scoped to the rail, so at 360px it renders a second heading inside the Up Next card'
# The eyebrow was a one-cycle experiment and is gone. A rule with no element is
# how the next reader concludes the two-line heading is still the design.
Check ($styles -notmatch '\.home-rail-eyebrow') `
  'the .home-rail-eyebrow rules outlive the element they styled'

# ---------------------------------------------------------------- report
Write-Host ''
if ($script:Failures.Count -eq 0) {
  Write-Host "src-prototype.test.ps1 PASSED - $($script:Checks) checks, 25 groups"
  exit 0
}
Write-Host "src-prototype.test.ps1 FAILED - $($script:Failures.Count) of $($script:Checks) checks"
foreach ($f in $script:Failures) { Write-Host "  - $f" }
exit 1
