$ErrorActionPreference = 'Stop'
$prototypePath = Join-Path $PSScriptRoot 'prototype-web.html'
$stylesPath = Join-Path $PSScriptRoot 'styles.css'
$dataPath = Join-Path $PSScriptRoot 'data.js'
$mainPath = Join-Path $PSScriptRoot 'main.js'
$html = Get-Content -LiteralPath $prototypePath -Raw
if (Test-Path -LiteralPath $stylesPath) { $html += "`n" + (Get-Content -LiteralPath $stylesPath -Raw) }
if (Test-Path -LiteralPath $dataPath) { $html += "`n" + (Get-Content -LiteralPath $dataPath -Raw) }
if (Test-Path -LiteralPath $mainPath) { $html += "`n" + (Get-Content -LiteralPath $mainPath -Raw) }

function Assert-Matches([string]$Pattern, [string]$Message) {
  if ($html -notmatch $Pattern) { throw $Message }
}

function Assert-NotMatches([string]$Pattern, [string]$Message) {
  if ($html -match $Pattern) { throw $Message }
}

$standalonePath = Join-Path $PSScriptRoot 'standalone.html'
if (Test-Path -LiteralPath $standalonePath) {
  $standalone = Get-Content -LiteralPath $standalonePath -Raw -Encoding UTF8
  $styles = Get-Content -LiteralPath $stylesPath -Raw -Encoding UTF8
  $data = Get-Content -LiteralPath $dataPath -Raw -Encoding UTF8
  $main = Get-Content -LiteralPath $mainPath -Raw -Encoding UTF8

  function Assert-Standalone([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
  }

  Assert-Standalone ($standalone -notmatch 'href=["'']styles\.css["'']') 'Standalone must inline styles.css'
  Assert-Standalone ($standalone -notmatch 'src=["''](?:data|main)\.js["'']') 'Standalone must inline local JavaScript'
  Assert-Standalone ($standalone -notmatch '(?:src=["'']|url\(["'']?)(?!data:|https?:|#)[^"'')]+(?:\.png|\.jpe?g|\.gif|\.webp|\.svg)') 'Standalone must embed local images'
  Assert-Standalone ($standalone.Contains($styles.Trim())) 'Standalone must contain the current stylesheet'
  Assert-Standalone ($standalone.Contains($data.Trim())) 'Standalone must contain the current data script'
  Assert-Standalone ($standalone.Contains($main.Trim())) 'Standalone must contain the current main script'

  Write-Output 'PASS: standalone snapshot matches modular sources'
} else {
  Write-Output 'SKIP: standalone.html not built - run .\build-standalone.ps1 to verify the snapshot'
}

Assert-Matches 'background:\s*rgba\(35,\s*151,\s*203,\s*0\.12\);\s*border:\s*1px solid rgba\(35,\s*151,\s*203,\s*0\.28\)' 'Gamification card must use a full blue tint.'
Assert-Matches 'background:\s*rgba\(236,\s*26,\s*100,\s*0\.10\);\s*border:\s*1px solid rgba\(236,\s*26,\s*100,\s*0\.25\)' 'AI Coach card must use a full magenta tint.'
Assert-Matches 'background:\s*rgba\(142,\s*39,\s*155,\s*0\.10\);\s*border:\s*1px solid rgba\(142,\s*39,\s*155,\s*0\.25\)' 'Incentives card must use a full purple tint.'
Assert-Matches 'background:\s*rgba\(234,\s*65,\s*52,\s*0\.10\);\s*border:\s*1px solid rgba\(234,\s*65,\s*52,\s*0\.25\)' 'Network card must use a full red tint.'
Assert-Matches 'font-size:\s*15px;\s*color:\s*var\(--ink2\)' 'GAIN card body copy must use dark text.'

Assert-Matches 'id="goal_grid"[^>]*role="group"' 'Goal grid must expose a labelled choice group.'
Assert-Matches '\.goal-grid\s*\{[^}]*grid-template-columns:\s*repeat\(3,\s*minmax\(0,\s*1fr\)\)' 'Desktop goal grid must use three columns.'
Assert-Matches '@media\s*\(max-width:\s*768px\)[\s\S]*?\.goal-grid\s*\{[^}]*grid-template-columns:\s*repeat\(2,\s*minmax\(0,\s*1fr\)\)' 'Tablet/mobile goal grid must use two columns.'
Assert-Matches '@media\s*\(max-width:\s*420px\)[\s\S]*?\.goal-grid\s*\{[^}]*grid-template-columns:\s*1fr' 'Narrow goal grid must use one column.'
Assert-Matches 'function\s+renderGoalCards\s*\(' 'Goal cards must render from goalOptions.'
Assert-Matches 'function\s+selectGoal\s*\(goalId\)' 'Goal selection handler is required.'
Assert-Matches "setAttribute\('aria-pressed',\s*isSelected\.toString\(\)\)" 'Cards must expose their selected state.'
Assert-Matches "document\.getElementById\('global-continue-btn'\)\.disabled\s*=\s*false" 'Selecting a goal must enable Continue.'
Assert-NotMatches 'id="goal_dropdown"|id="goal_search"|function\s+toggleGoalDropdown|function\s+filterGoals' 'Obsolete dropdown and search behavior must be removed.'

$goalIds = @('data', 'customer', 'project', 'marketing', 'communication', 'language')
foreach ($goalId in $goalIds) {
  Assert-Matches "id:\s*'$goalId'" "Missing goal option: $goalId"
}

Write-Output 'PASS: learning-goal card grid structure and behavior'

Assert-Matches 'id="country_search"[^>]*role="combobox"[^>]*aria-autocomplete="list"[^>]*aria-controls="country_list"[^>]*aria-expanded="false"' 'Country input must control the actual listbox and expose collapsed combobox semantics.'
Assert-Matches 'id="country_search"[^>]*role="combobox"[^>]*aria-labelledby="country_gate_title"' 'Country combobox must retain the country heading as its accessible name.'
Assert-Matches 'id="country_dropdown"[^>]*class="[^\"]*select-hide[^\"]*"[^>]*role="presentation"' 'Country dropdown must start hidden and remain a presentational container.'
Assert-Matches 'id="country_list"\s+role="listbox"' 'Country list must be the actual listbox.'
Assert-Matches 'id="country_list"\s+role="listbox"></div>\s*<div\s+id="country_status"\s+class="country-empty-state"\s+role="status"' 'Country status must be a sibling outside the listbox.'
Assert-NotMatches 'id="country_combobox"[\s\S]*?expand_more[\s\S]*?id="country_dropdown"' 'Country combobox must not show an expand-more icon before its results listbox.'
Assert-Matches 'function\s+handleCountryInput\s*\(' 'Country input handler is required.'
Assert-Matches 'function\s+handleCountryInput\s*\(\)[\s\S]*?input\.removeAttribute\(''aria-activedescendant''\)[\s\S]*?if\s*\(!query\)' 'Editing country text must clear the active descendant before empty-query handling or rerendering.'
Assert-Matches 'if\s*\(!query\)' 'Empty country queries must keep results closed.'
Assert-Matches 'function\s+handleCountryKeydown\s*\(event\)' 'Country keyboard handler is required.'
Assert-Matches "event\.key\s*===\s*'ArrowDown'" 'Country results must support Arrow Down.'
Assert-Matches "event\.key\s*===\s*'ArrowUp'" 'Country results must support Arrow Up.'
Assert-Matches "event\.key\s*===\s*'Enter'" 'Country results must support Enter selection.'
Assert-Matches "event\.key\s*===\s*'Escape'" 'Country results must support Escape closure.'
Assert-Matches "setAttribute\('aria-activedescendant'" 'Keyboard-active country must be exposed.'
Assert-Matches 'function\s+handleCountryKeydown\s*\(event\)[\s\S]*?if\s*\(filteredCountries\.length\s*===\s*0\)\s*return' 'Empty country results must ignore keyboard navigation without exposing an active descendant.'
Assert-Matches "function\s+handleCountryKeydown\s*\(event\)[\s\S]*?event\.key\s*===\s*'Escape'[\s\S]*?closeCountryDropdown\s*\(\)[\s\S]*?if\s*\(filteredCountries\.length\s*===\s*0\)\s*return" 'Escape must close no-match country results before the empty-results navigation guard.'
Assert-Matches 'function\s+selectCountry\s*\(country\)' 'Country selection helper is required.'
Assert-Matches 'selectedCountry\s*=\s*null[\s\S]*?global-continue-btn[\s\S]*?disabled\s*=\s*true' 'Editing country text must clear selection and disable Continue.'
Assert-Matches 'No countries found' 'Empty country results require feedback.'
Assert-NotMatches 'validateCountry\s*\(' 'Broken validateCountry handler must be removed.'
Assert-Matches '#country_list\s*\{[^}]*display:\s*flex;[^}]*flex-direction:\s*column;' 'Country results must stack vertically.'
Assert-Matches 'option\.className\s*=\s*''country-option''' 'Rendered countries require a dedicated option class.'
Assert-Matches '#country_list:hover\s*\{[^}]*background:\s*transparent;' 'Country list container must not receive hover background.'
Assert-Matches '#country_list\s*>\s*\.country-option:hover\s*\{[^}]*background:\s*var\(--bg\);' 'Hover styling must target only one country option.'
Assert-Matches '#country_list\s*>\s*\.country-option\[aria-selected="true"\]\s*\{[^}]*background:\s*var\(--purple-bg\);' 'Selected styling must target only the active country option.'
Assert-Matches '#country_dropdown\s*>\s*\.country-empty-state\s*\{[^}]*display:\s*none;[^}]*cursor:\s*default;[^}]*background:\s*transparent;' 'Empty country feedback must reset inherited option interaction styles.'
Assert-Matches '#country_dropdown\s*>\s*\.country-empty-state:hover\s*\{[^}]*background:\s*transparent;[^}]*cursor:\s*default;' 'Empty country feedback must remain noninteractive on hover.'
Assert-Matches 'status\.textContent\s*=\s*''No countries found''[\s\S]*?status\.style\.display\s*=\s*''block''' 'No-match rendering must populate and reveal the external live status.'

Write-Output 'PASS: searchable country combobox structure and behavior'

Assert-Matches 'id="impact_video"' 'Impact video container must be addressable for protocol-aware rendering.'
Assert-Matches 'window\.location\.protocol\s*===\s*''file:''' 'Local-file viewing must be detected to avoid YouTube error 153.'
Assert-Matches 'https://www\.youtube\.com/watch\?v=vEgSkcthYMQ' 'Local-file fallback must link to the video on YouTube.'
Assert-Matches 'https://www\.youtube\.com/embed/vEgSkcthYMQ' 'HTTP viewing must retain the embedded YouTube player.'
Assert-Matches 'id="impact_video"[^>]*>\s*</div>' 'The video container must start empty so a file URL does not eagerly load YouTube.'

Write-Output 'PASS: YouTube embed handles local-file referrer restrictions'

Assert-Matches 'id="gender_gate"[^>]*class="card' 'Gender gate must exist as a card screen.'
Assert-Matches 'id="gender_options"[^>]*role="group"[^>]*aria-labelledby="gender_gate_title"' 'Gender options must expose a labelled choice group.'
Assert-Matches 'id="gender-btn-female"[^>]*aria-pressed="false"[^>]*>Female</button>' 'Female must be a text-only pressable button.'
Assert-Matches 'id="gender-btn-male"[^>]*aria-pressed="false"[^>]*>Male</button>' 'Male must be a text-only pressable button.'
Assert-Matches 'id="gender-btn-prefer"[^>]*aria-pressed="false"[^>]*>Prefer not to say</button>' 'Opt-out must be a text-only pressable button.'
Assert-Matches '\.gender-grid\s*\{[^}]*grid-template-columns:\s*repeat\(2,\s*minmax\(0,\s*1fr\)\)' 'Gender row one must use two columns.'
Assert-Matches '@media\s*\(max-width:\s*420px\)\s*\{[^{}]*\.gender-grid\s*\{[^}]*grid-template-columns:\s*1fr' 'Narrow gender grid must collapse to one column.'
Assert-Matches '\.gender-card\s*\{[^}]*background:\s*var\(--surf\)' 'Gender buttons must reset the native button background.'
Assert-Matches '\.gender-card:focus-visible\s*\{[^}]*outline:' 'Gender buttons must show a visible focus ring.'

Write-Output 'PASS: gender gate structure and styling'

Assert-Matches 'selectedGender:\s*null' 'Gender selection state must be initialised.'
Assert-Matches 'function\s+selectGender\s*\(element,\s*gender\)' 'Gender selection handler is required.'
Assert-Matches "function\s+selectGender[\s\S]*?setAttribute\('aria-pressed',\s*'false'\)" 'Selecting a gender must clear the previous selection.'
Assert-Matches "function\s+selectGender[\s\S]*?classList\.remove\('selected'\)" 'Selecting a gender must clear the previous selected style.'
Assert-Matches "function\s+selectGender[\s\S]*?setAttribute\('aria-pressed',\s*'true'\)" 'Selecting a gender must expose the pressed state.'
Assert-Matches "function\s+selectGender[\s\S]*?global-continue-btn'\)\.disabled\s*=\s*false" 'Selecting a gender must enable Continue.'
Assert-Matches "getElementById\('gender-btn-female'\)\?\.addEventListener\('click'" 'Female option must be wired.'
Assert-Matches "getElementById\('gender-btn-male'\)\?\.addEventListener\('click'" 'Male option must be wired.'
Assert-Matches "getElementById\('gender-btn-prefer'\)\?\.addEventListener\('click'" 'Opt-out option must be wired.'
Assert-Matches "selectGender\(this,\s*'prefer_not_to_say'\)" 'Opt-out must record prefer_not_to_say.'

Write-Output 'PASS: gender selection state and behavior'

Assert-Matches "function\s+continueFromAge\s*\(\)\s*\{\s*if\s*\(!appState\.selectedAgeCategory\)\s*return;\s*goTo\('gender_gate'\);\s*\}" 'Age gate must route only to the gender gate.'
Assert-Matches 'function\s+continueFromGender\s*\(\)' 'Gender continue handler is required.'
Assert-Matches "function\s+continueFromGender[\s\S]*?entryPath\s*===\s*'organic'[\s\S]*?goTo\('goal_intake'\)" 'Organic path must continue from gender to goals.'
Assert-Matches "function\s+continueFromGender[\s\S]*?goTo\('save_wall'\)[\s\S]*?populateProfileSummary\(\)" 'Program path must continue from gender to the save wall.'
Assert-Matches "activeCard\s*===\s*'gender_gate'[\s\S]*?continueFromGender\(\)" 'Continue must dispatch to the gender handler.'
Assert-Matches "'age_gate',\s*'gender_gate'" 'Gender gate must show the onboarding footer.'
Assert-Matches "screenId\s*===\s*'gender_gate'[\s\S]*?disabled\s*=\s*!appState\.selectedGender" 'Continue must stay disabled until a gender is chosen.'

Write-Output 'PASS: gender gate routing'

Assert-Matches "const\s+progressMap\s*=\s*\{[^}]*'name_gate':\s*10" 'First gate must show a visible progress sliver.'
Assert-Matches "const\s+progressMap\s*=\s*\{[^}]*'country_gate':\s*28" 'Organic country step weighting.'
Assert-Matches "const\s+progressMap\s*=\s*\{[^}]*'age_gate':\s*46" 'Organic age step weighting.'
Assert-Matches "const\s+progressMap\s*=\s*\{[^}]*'gender_gate':\s*64" 'Organic gender step weighting.'
Assert-Matches "const\s+progressMap\s*=\s*\{[^}]*'goal_intake':\s*82" 'Organic goal step weighting.'
Assert-NotMatches "const\s+progressMap\s*=\s*\{[^}]*'assigned_content'" 'Dead organic assigned-content weighting must be removed.'
Assert-Matches "programProgressMap\s*=\s*\{[^}]*'assigned_content':\s*17" 'Program assigned-content weighting.'
Assert-Matches "programProgressMap\s*=\s*\{[^}]*'name_gate':\s*33" 'Program name weighting.'
Assert-Matches "programProgressMap\s*=\s*\{[^}]*'country_gate':\s*50" 'Program country weighting.'
Assert-Matches "programProgressMap\s*=\s*\{[^}]*'age_gate':\s*67" 'Program age weighting.'
Assert-Matches "programProgressMap\s*=\s*\{[^}]*'gender_gate':\s*83" 'Program gender weighting.'

Write-Output 'PASS: progress bar weighting'

Assert-Matches 'id="code_entry_modal"[\s\S]{0,120}?role="dialog"\s+aria-modal="true"\s+aria-labelledby="code_modal_title"' 'Code entry must be a named modal dialog.'
Assert-Matches 'id="sign_in_modal"[\s\S]{0,120}?role="dialog"\s+aria-modal="true"\s+aria-labelledby="sign_in_modal_title"' 'Login must be a named modal dialog.'
Assert-Matches 'id="code_modal_title"' 'Code modal needs the heading its dialog is named by.'
Assert-Matches 'id="sign_in_modal_title"' 'Login modal needs the heading its dialog is named by.'
Assert-Matches 'class="modal-content[^"]*"[^>]*tabindex="-1"' 'Modal content must be focusable as a fallback target.'
Assert-NotMatches 'class="code-digit"\s+autofocus' 'A closed modal must not steal focus on page load.'
Assert-Matches '\.modal-overlay\s*\{[^}]*visibility:\s*hidden' 'A closed modal must leave the tab order.'
Assert-Matches '\.modal-overlay\.show\s*\{[^}]*visibility:\s*visible' 'An open modal must be focusable.'

Write-Output 'PASS: modal dialog semantics'

Assert-Matches 'function\s+openModal\s*\(id,\s*initialFocusSelector\)' 'Modal open helper is required.'
Assert-Matches 'modalReturnFocus\s*=\s*document\.activeElement' 'Opening a modal must record its trigger.'
Assert-Matches "setAttribute\('inert',\s*''\)" 'Opening a modal must make the background inert.'
Assert-Matches "removeAttribute\('inert'\)" 'Closing the last modal must un-inert the background.'
Assert-Matches 'function\s+trapModalTab\s*\(event\)' 'Modal Tab trap is required.'
Assert-Matches "addEventListener\('keydown',\s*event\s*=>\s*\{\s*if\s*\(event\.key\s*===\s*'Escape'\)" 'Escape must close the open modal.'
Assert-Matches 'returnTo\.isConnected[\s\S]*?returnTo\.focus\(\)' 'Closing a modal must restore focus to a still-visible trigger.'
Assert-Matches "openModal\('code_entry_modal',\s*'\.code-digit'\)" 'Program entry must focus the first code digit.'
Assert-Matches "openModal\('sign_in_modal',\s*'#login_email_input'\)" 'Login must focus the email field.'
Assert-NotMatches "getElementById\('(?:code_entry_modal|sign_in_modal)'\)\.classList\.add\('show'\)" 'Modals must open through openModal, not a bare class toggle.'

Write-Output 'PASS: modal focus management'

Assert-Matches 'function\s+validateSaveGate[\s\S]*?pwd\.length\s*>=\s*8' 'Account creation must apply the 8-character PRD policy.'

foreach ($goalId in $goalIds) {
  Assert-Matches "'$goalId':\s*'" "Goal '$goalId' must map to a first course."
}
Assert-NotMatches "'digital_literacy':|'entrepreneurship':|'workplace':\s*'Workplace Communication'" 'Stale course-map keys must be removed.'

Write-Output 'PASS: password policy and goal-to-course map'

Assert-NotMatches 'new RegExp\(`\(\$\{q\}\)`' 'An unescaped query must not be interpolated into a regex.'
Assert-Matches 'q\.replace\(' 'Country highlight must escape the query first.'
Assert-Matches "onerror=""this\.style\.visibility='hidden'""" 'Flag images must fail closed rather than show a broken icon.'
Assert-NotMatches 'signin-btn-telegram|sso-btn-telegram|signin-btn-apple|sso-btn-apple' 'Handlers for absent Apple/Telegram controls must be removed.'
Assert-NotMatches 'at least 15 years old' 'Vestigial age-block copy must be removed.'

Write-Output 'PASS: country search hardening and dead-code removal'
