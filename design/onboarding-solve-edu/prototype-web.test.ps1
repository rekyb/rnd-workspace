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
