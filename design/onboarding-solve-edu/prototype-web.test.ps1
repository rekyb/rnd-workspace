$ErrorActionPreference = 'Stop'
$prototypePath = Join-Path $PSScriptRoot 'prototype-web.html'
$html = Get-Content -LiteralPath $prototypePath -Raw

function Assert-Matches([string]$Pattern, [string]$Message) {
  if ($html -notmatch $Pattern) { throw $Message }
}

function Assert-NotMatches([string]$Pattern, [string]$Message) {
  if ($html -match $Pattern) { throw $Message }
}

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

Assert-Matches 'id="country_search"[^>]*role="combobox"[^>]*aria-autocomplete="list"[^>]*aria-controls="country_dropdown"[^>]*aria-expanded="false"' 'Country input must control the actual listbox and expose collapsed combobox semantics.'
Assert-Matches 'id="country_dropdown"[^>]*class="[^\"]*select-hide[^\"]*"[^>]*role="listbox"' 'Country results must start hidden and expose listbox semantics.'
Assert-NotMatches 'id="country_combobox"[\s\S]*?expand_more[\s\S]*?id="country_dropdown"' 'Country combobox must not show an expand-more icon before its results listbox.'
Assert-Matches 'function\s+handleCountryInput\s*\(' 'Country input handler is required.'
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

Write-Output 'PASS: searchable country combobox structure and behavior'
