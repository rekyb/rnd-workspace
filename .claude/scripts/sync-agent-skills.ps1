<#
.SYNOPSIS
    Keep the .agents/skills/ registration stubs in step with .claude/commands/.

.DESCRIPTION
    Every workflow command has one body, in .claude/commands/<name>.md, and one
    registration stub per additional harness, in .agents/skills/<name>/SKILL.md.
    The stub carries the frontmatter a skill-resolving harness needs -- `name` for
    invocation, `description` for intent matching -- and points at the body. It
    never restates the body.

    That asymmetry is deliberate. Every reference and persona in this workspace
    already lives once, in .claude/, and is read by both harnesses; 18 of the 19
    stubs cite .claude/ paths directly. Command bodies were the one artifact
    duplicated, and they are the one artifact that drifted -- twice, most recently
    when the coverage gates landed in .claude/ and never reached .agents/.

    Default mode checks. -Fix regenerates. Same shape as /sync-tokens --check.

.PARAMETER Fix
    Write the stubs instead of checking them. Without it the script changes
    nothing and exits non-zero on any divergence.

.EXAMPLE
    powershell -NoProfile -File .claude/scripts/sync-agent-skills.ps1
    Check every stub. Exit 0 when they agree, 1 when they do not.

.EXAMPLE
    powershell -NoProfile -File .claude/scripts/sync-agent-skills.ps1 -Fix
    Regenerate every stub from its command's frontmatter.
#>
[CmdletBinding()]
param(
    [switch]$Fix
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot   = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$CommandDir = Join-Path $RepoRoot '.claude\commands'
$SkillDir   = Join-Path $RepoRoot '.agents\skills'

if (-not (Test-Path $CommandDir)) {
    Write-Error "No command directory at $CommandDir"
    exit 2
}

$Template = @'
---
name: {{NAME}}
description: {{DESC}}
---

The body of this skill lives in `.claude/commands/{{NAME}}.md`. Read that file and follow it exactly. It is the single source of truth for this workflow and the only copy kept current.

Reading a `.claude/commands/` file as a skill:

- `$ARGUMENTS` means the arguments this skill was invoked with.
- A slashed reference such as `/draft-prd` means the skill `draft-prd` in this tree.
- Paths under `.claude/references/` and `.claude/personas/` are shared by every harness. Read them where they are; there is no second copy.

This file registers the skill. It does not restate the workflow, because a second copy of the body is what let the two trees drift apart. `.claude/scripts/sync-agent-skills.ps1` regenerates this file and fails on any hand-edit.
'@

function Get-FrontmatterDescription {
    param([string]$Path)

    $lines = [System.IO.File]::ReadAllLines($Path)
    if ($lines.Count -eq 0 -or $lines[0].Trim() -ne '---') { return $null }

    for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Trim() -eq '---') { return $null }
        if ($lines[$i] -match '^description:\s*(.+)$') { return $Matches[1].Trim() }
    }
    return $null
}

function New-StubText {
    param([string]$Name, [string]$Description)

    $text = $Template.Replace('{{NAME}}', $Name).Replace('{{DESC}}', $Description)
    # Exactly one trailing newline, then match the working tree: CRLF.
    # core.autocrlf normalizes back to LF in the blob.
    $normalized = ($text -replace "`r`n", "`n").TrimEnd("`n") + "`n"
    return ($normalized -replace "`n", "`r`n")
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$problems  = New-Object System.Collections.Generic.List[string]
$written   = New-Object System.Collections.Generic.List[string]
$commands  = @{}

foreach ($file in Get-ChildItem -Path $CommandDir -Filter '*.md' | Sort-Object Name) {
    $name = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $desc = Get-FrontmatterDescription -Path $file.FullName

    if ([string]::IsNullOrWhiteSpace($desc)) {
        $problems.Add("$name : command has no frontmatter 'description:' -- a stub cannot be generated")
        continue
    }

    $commands[$name] = $desc
    $stubPath = Join-Path $SkillDir "$name\SKILL.md"
    $expected = New-StubText -Name $name -Description $desc

    $actual = $null
    if (Test-Path $stubPath) { $actual = [System.IO.File]::ReadAllText($stubPath) }

    if ($actual -eq $expected) { continue }

    if ($Fix) {
        $dir = Split-Path $stubPath -Parent
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        [System.IO.File]::WriteAllText($stubPath, $expected, $utf8NoBom)
        if ($null -eq $actual) { $written.Add("$name (created)") } else { $written.Add("$name (updated)") }
    }
    else {
        if ($null -eq $actual) { $problems.Add("$name : no stub at .agents/skills/$name/SKILL.md") }
        else { $problems.Add("$name : stub does not match its command's frontmatter or the current template") }
    }
}

# An orphan stub outlives a command that was renamed or deleted. -Fix never
# removes files; a stray stub is reported for a human to resolve.
if (Test-Path $SkillDir) {
    foreach ($dir in Get-ChildItem -Path $SkillDir -Directory | Sort-Object Name) {
        if (-not $commands.ContainsKey($dir.Name)) {
            $problems.Add("$($dir.Name) : stub has no command at .claude/commands/$($dir.Name).md -- delete it or restore the command")
        }
    }
}

if ($Fix) {
    if ($written.Count -eq 0) { Write-Host "All $($commands.Count) stubs already current. Nothing written." }
    else {
        Write-Host "Wrote $($written.Count) of $($commands.Count) stubs:"
        foreach ($w in $written) { Write-Host "  $w" }
    }
    # Orphans are the one thing -Fix cannot resolve.
    $orphans = $problems | Where-Object { $_ -like '*has no command at*' }
    if ($orphans) {
        Write-Host ""
        Write-Host "Unresolved (needs a human):"
        foreach ($o in $orphans) { Write-Host "  $o" }
        exit 1
    }
    exit 0
}

if ($problems.Count -eq 0) {
    Write-Host "OK: $($commands.Count) commands, $($commands.Count) stubs, all in step."
    exit 0
}

Write-Host "Registration drift ($($problems.Count)):"
foreach ($p in $problems) { Write-Host "  $p" }
Write-Host ""
Write-Host "Run with -Fix to regenerate."
exit 1
