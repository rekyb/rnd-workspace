# Dependency-free test harness for sync-tokens.ps1
$ErrorActionPreference = 'Stop'
$script:Failures = 0
$ScriptUnderTest = Join-Path $PSScriptRoot 'sync-tokens.ps1'

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

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# Builds a fake upstream checkout. $Globals is the full globals.css text.
function New-SourceFixture {
    param([string]$Globals)
    $root = Join-Path ([System.IO.Path]::GetTempPath()) ("synctok_" + [guid]::NewGuid().ToString('N'))
    $frontend = Join-Path $root 'apps\web\app\(frontend)'
    $tokens   = Join-Path $root 'packages\tokens'
    New-Item -ItemType Directory -Force -Path $frontend | Out-Null
    New-Item -ItemType Directory -Force -Path $tokens | Out-Null
    [IO.File]::WriteAllText((Join-Path $frontend 'globals.css'), $Globals, $Utf8NoBom)
    [IO.File]::WriteAllText((Join-Path $tokens 'tokens.json'), '{"color":{"pri":{"$value":"#ffcb1d"}}}', $Utf8NoBom)
    [IO.File]::WriteAllText((Join-Path $tokens 'manifest.json'), '{"projectId":"SECRET-DO-NOT-COPY"}', $Utf8NoBom)
    return $root
}

function New-UiRoot {
    $p = Join-Path ([System.IO.Path]::GetTempPath()) ("uiroot_" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Force -Path $p | Out-Null
    return $p
}

$GOOD = @"
/* header comment */
.pre { color: red; }
/* TOKENS:START (generated from packages/tokens/tokens.json by build.mjs — do not edit by hand) */
:root {
  --pri: #ffcb1d;
  --ink: #1d1826;
}
:root[data-theme="dark"] {
  --ink: #f5f2fa;
}
/* TOKENS:END */
.post { color: blue; }
"@

# --- Test 1: tokens.css is exactly the lines strictly between the markers
$src = New-SourceFixture -Globals $GOOD
$ui  = New-UiRoot
& powershell -NoProfile -File $ScriptUnderTest -SourcePath $src -UiRoot $ui | Out-Null
$tokensOut = [IO.File]::ReadAllText((Join-Path $ui 'tokens.css'), [System.Text.Encoding]::UTF8)
$expectedTokens = @"
:root {
  --pri: #ffcb1d;
  --ink: #1d1826;
}
:root[data-theme="dark"] {
  --ink: #f5f2fa;
}
"@
# A here-string's closing "@ does not contribute the final line's own trailing
# newline, but a "line" includes its terminator — the last between-marker line
# ("}") is terminated the same as every other line above it, so the expected
# value needs that terminator appended explicitly.
Assert-Equal ($expectedTokens + "`n") $tokensOut 'tokens.css is the lines strictly between the markers'

# --- Test 2: components.css is the file minus that block minus both marker lines
$compOut = [IO.File]::ReadAllText((Join-Path $ui 'components.css'), [System.Text.Encoding]::UTF8)
$expectedComp = @"
/* header comment */
.pre { color: red; }
.post { color: blue; }
"@
Assert-Equal $expectedComp $compOut 'components.css is the source minus the token block and both markers'

# --- Test 15: the two outputs reconstitute the source minus the two marker lines
$srcRaw = [IO.File]::ReadAllText((Join-Path $src 'apps\web\app\(frontend)\globals.css'), [System.Text.Encoding]::UTF8)
$startLine = [regex]::Match($srcRaw, '(?m)^[ \t]*/\* TOKENS:START[^\r\n]*\r?\n').Value
$endLine   = [regex]::Match($srcRaw, '(?m)^[ \t]*/\* TOKENS:END[^\r\n]*\r?\n').Value
$expectedWhole = $srcRaw.Replace($startLine, '').Replace($endLine, '')
$rebuilt = $compOut.Substring(0, $compOut.IndexOf('.post')) + $tokensOut + $compOut.Substring($compOut.IndexOf('.post'))
Assert-Equal $expectedWhole $rebuilt 'tokens.css + components.css reconstitute the source minus both marker lines'

# --- Test 3: no custom properties leak into components.css
Assert-Equal '0' ([string]([regex]::Matches($compOut, '(?m)^\s*--[A-Za-z0-9-]+\s*:').Count)) 'components.css contains no custom-property definitions'

# --- Test 4: outputs are UTF-8 with NO BOM
$bytes = [IO.File]::ReadAllBytes((Join-Path $ui 'tokens.css'))
$hasBom = ($bytes.Count -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
Assert-Equal 'False' ([string]$hasBom) 'tokens.css is written without a BOM'

# --- Test 5: non-ASCII in a BOM-less source survives the round trip
$srcNonAscii = $GOOD.Replace('/* header comment */', '/* café — em-dash */')
$src5 = New-SourceFixture -Globals $srcNonAscii
$ui5  = New-UiRoot
& powershell -NoProfile -File $ScriptUnderTest -SourcePath $src5 -UiRoot $ui5 | Out-Null
$comp5 = [IO.File]::ReadAllText((Join-Path $ui5 'components.css'), [System.Text.Encoding]::UTF8)
Assert-Equal 'True' ([string]($comp5 -match 'café — em-dash')) 'BOM-less non-ASCII source survives extraction'

# --- Test 6: CRLF line endings are preserved, not normalized
$crlf = $GOOD -replace "`r?`n", "`r`n"
$src6 = New-SourceFixture -Globals $crlf
$ui6  = New-UiRoot
& powershell -NoProfile -File $ScriptUnderTest -SourcePath $src6 -UiRoot $ui6 | Out-Null
$tok6 = [IO.File]::ReadAllText((Join-Path $ui6 'tokens.css'), [System.Text.Encoding]::UTF8)
Assert-Equal 'True' ([string]($tok6.Contains("`r`n"))) 'CRLF source keeps CRLF endings in tokens.css'

# --- Test 7: a missing END marker fails loudly and writes nothing
$noEnd = $GOOD -replace '/\* TOKENS:END \*/', '/* nothing here */'
$src7 = New-SourceFixture -Globals $noEnd
$ui7  = New-UiRoot
$out7 = & powershell -NoProfile -File $ScriptUnderTest -SourcePath $src7 -UiRoot $ui7 2>&1
Assert-Equal 'True' ([string]($LASTEXITCODE -ne 0)) 'missing END marker exits non-zero'
Assert-Equal 'True' ([string]([string]$out7 -match 'TOKENS marker')) 'missing END marker reports the marker contract'
Assert-Equal 'False' ([string](Test-Path -LiteralPath (Join-Path $ui7 'tokens.css'))) 'missing END marker writes no tokens.css'

# --- Test 8: a missing START marker fails loudly
$noStart = $GOOD -replace '/\* TOKENS:START[^\r\n]*', '/* nothing here */'
$src8 = New-SourceFixture -Globals $noStart
$ui8  = New-UiRoot
& powershell -NoProfile -File $ScriptUnderTest -SourcePath $src8 -UiRoot $ui8 2>&1 | Out-Null
Assert-Equal 'True' ([string]($LASTEXITCODE -ne 0)) 'missing START marker exits non-zero'

foreach ($d in @($src,$ui,$src5,$ui5,$src6,$ui6,$src7,$ui7,$src8,$ui8)) { Remove-Item -Recurse -Force $d -ErrorAction SilentlyContinue }
if ($script:Failures -gt 0) { Write-Host "`n$($script:Failures) failure(s)" -ForegroundColor Red; exit 1 }
Write-Host "`nAll tests passed" -ForegroundColor Green
exit 0
