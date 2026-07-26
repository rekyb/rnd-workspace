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
.marker-slot[data-note="REPLACE_MARKER"] { color: teal; }
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
.marker-slot[data-note="REPLACE_MARKER"] { color: teal; }
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
# Built from explicit code points on both sides (not a literal in this file) so the
# assertion doesn't depend on how PowerShell decoded sync-tokens.Tests.ps1 itself --
# a script that is fully 7-bit ASCII has no such decoding decision to get wrong, so
# neither side of this comparison can be mangled identically by that same mistake.
# The marker is placed in a plain declaration value (REPLACE_MARKER), not inside a
# comment - components.css now strips every comment, so a marker planted inside one
# would prove the wrong thing (that comment-scrubbing works, not that a non-comment
# byte sequence round-trips untouched).
$emDash = [char]0x2014
$eAcute = [char]0x00E9
$marker = "caf$eAcute $emDash em-dash"
$srcNonAscii = $GOOD.Replace('REPLACE_MARKER', $marker)
$src5 = New-SourceFixture -Globals $srcNonAscii
$ui5  = New-UiRoot
& powershell -NoProfile -File $ScriptUnderTest -SourcePath $src5 -UiRoot $ui5 | Out-Null
$comp5 = [IO.File]::ReadAllText((Join-Path $ui5 'components.css'), [System.Text.Encoding]::UTF8)
Assert-Equal 'True' ([string]($comp5 -match [regex]::Escape($marker))) 'BOM-less non-ASCII source survives extraction'

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

# --- Test 9: tokens.json is copied, manifest.json is NEVER copied
$src9 = New-SourceFixture -Globals $GOOD
$ui9  = New-UiRoot
& powershell -NoProfile -File $ScriptUnderTest -SourcePath $src9 -UiRoot $ui9 -SourceSha ('a' * 40) | Out-Null
Assert-Equal 'True'  ([string](Test-Path -LiteralPath (Join-Path $ui9 'tokens.json')))   'tokens.json is copied into ui/'
Assert-Equal 'False' ([string](Test-Path -LiteralPath (Join-Path $ui9 'manifest.json'))) 'manifest.json is NEVER copied into ui/'

# --- Test 10: provenance block records the SHA between its markers
$prov = [IO.File]::ReadAllText((Join-Path $ui9 'TOKENS.md'), [System.Text.Encoding]::UTF8)
Assert-Equal 'True' ([string]($prov -match '<!-- PROVENANCE:START -->')) 'TOKENS.md has a PROVENANCE:START marker'
Assert-Equal 'True' ([string]($prov -match ('a' * 40)))                  'TOKENS.md records the resolved commit SHA'
Assert-Equal 'True' ([string]($prov -match '3 custom properties')) 'TOKENS.md records a token count'

# --- Test 11: hand-written prose outside the provenance markers survives a re-sync
$withProse = $prov + "`n## My hand-written notes`nKeep me.`n"
[IO.File]::WriteAllText((Join-Path $ui9 'TOKENS.md'), $withProse, $Utf8NoBom)
& powershell -NoProfile -File $ScriptUnderTest -SourcePath $src9 -UiRoot $ui9 -SourceSha ('b' * 40) | Out-Null
$prov2 = [IO.File]::ReadAllText((Join-Path $ui9 'TOKENS.md'), [System.Text.Encoding]::UTF8)
Assert-Equal 'True'  ([string]($prov2 -match 'Keep me\.'))  'hand-written prose survives a re-sync'
Assert-Equal 'True'  ([string]($prov2 -match ('b' * 40)))   'provenance block is refreshed with the new SHA'
Assert-Equal 'False' ([string]($prov2 -match ('a' * 40)))   'the previous SHA is replaced, not appended'

# --- Test 12: --check exits 0 and writes nothing when ui-library/ matches the source
$before = (Get-ChildItem -LiteralPath $ui9 -File | ForEach-Object { "$($_.Name):$($_.Length)" }) -join '|'
& powershell -NoProfile -File $ScriptUnderTest -SourcePath $src9 -UiRoot $ui9 -SourceSha ('b' * 40) -Check | Out-Null
Assert-Equal '0' ([string]$LASTEXITCODE) '--check exits 0 when ui-library/ is in sync'
$after = (Get-ChildItem -LiteralPath $ui9 -File | ForEach-Object { "$($_.Name):$($_.Length)" }) -join '|'
Assert-Equal $before $after '--check writes nothing when in sync'

# --- Test 13: --check exits non-zero and reports drift when tokens.css differs
[IO.File]::WriteAllText((Join-Path $ui9 'tokens.css'), ":root {`n  --pri: #000000;`n}`n", $Utf8NoBom)
$drift = & powershell -NoProfile -File $ScriptUnderTest -SourcePath $src9 -UiRoot $ui9 -SourceSha ('b' * 40) -Check 2>&1
Assert-Equal 'True' ([string]($LASTEXITCODE -ne 0))          '--check exits non-zero on drift'
Assert-Equal 'True' ([string]([string]$drift -match 'pri'))  '--check names the drifted token'

# --- Test 14: --check writes nothing even when it detects drift
$stillDrifted = [IO.File]::ReadAllText((Join-Path $ui9 'tokens.css'), [System.Text.Encoding]::UTF8)
Assert-Equal 'True' ([string]($stillDrifted -match '#000000')) '--check leaves the drifted file untouched'

# --- Test 16: the script's own source stays 7-bit ASCII (regression guard)
# PS 5.1 decodes a BOM-less .ps1 using the system ANSI codepage, so a non-ASCII
# character in a here-string reaches the generated TOKENS.md as mojibake. Keeping
# the source ASCII-only is what makes that impossible; this asserts it.
$srcBytes = [IO.File]::ReadAllBytes($ScriptUnderTest)
$nonAscii = @($srcBytes | Where-Object { $_ -gt 127 })
Assert-Equal '0' ([string]$nonAscii.Count) 'sync-tokens.ps1 source contains no non-ASCII bytes'

# --- Test 17: components.css scrub - CSS comments and external @import are removed,
# a root-relative local url() is kept, and an ordinary class selector survives
$secretMarker = 'SECRET-DO-NOT-COPY-9f8e-projectId'
$scrubGlobals = @"
/* internal note: $secretMarker - DesignSync rebrand notes, see PRD wiki/prd/x */
@import url("https://fonts.googleapis.com/css2?family=Test");
.keep-me { background: url("/brand/logo-icon.svg") center / contain no-repeat; }
/* TOKENS:START (generated from packages/tokens/tokens.json by build.mjs — do not edit by hand) */
:root {
  --pri: #ffcb1d;
}
/* TOKENS:END */
.post-keep { color: blue; }
"@
$src17 = New-SourceFixture -Globals $scrubGlobals
$ui17  = New-UiRoot
& powershell -NoProfile -File $ScriptUnderTest -SourcePath $src17 -UiRoot $ui17 | Out-Null
$comp17 = [IO.File]::ReadAllText((Join-Path $ui17 'components.css'), [System.Text.Encoding]::UTF8)
Assert-Equal 'False' ([string]($comp17 -match [regex]::Escape($secretMarker)))        'components.css scrub removes a secret carried in a comment'
Assert-Equal 'False' ([string]($comp17 -match 'DesignSync'))                          'components.css scrub removes the DesignSync comment text'
Assert-Equal 'False' ([string]($comp17 -match '/\*'))                                 'components.css scrub leaves no comment-open token at all'
Assert-Equal 'False' ([string]($comp17 -match 'https?://'))                           'components.css scrub removes the external @import (no http(s):// survives)'
Assert-Equal 'True'  ([string]($comp17 -match [regex]::Escape('url("/brand/logo-icon.svg")'))) 'components.css scrub keeps the root-relative local url()'
Assert-Equal 'True'  ([string]($comp17 -match [regex]::Escape('.keep-me')))            'components.css scrub keeps a known class selector before the token block'
Assert-Equal 'True'  ([string]($comp17 -match [regex]::Escape('.post-keep')))          'components.css scrub keeps a known class selector after the token block'

# --- Test 18: tokens.json scrub - every $description is dropped, every $value survives
$jsonWithDesc = '{"$description":"top-level secret PRD note","color":{"$type":"color","pri":{"$value":"#ffcb1d","$description":"secret design note"},"sec":{"$value":"#112233"}}}'
$src18 = New-SourceFixture -Globals $GOOD
[IO.File]::WriteAllText((Join-Path $src18 'packages\tokens\tokens.json'), $jsonWithDesc, $Utf8NoBom)
$ui18  = New-UiRoot
& powershell -NoProfile -File $ScriptUnderTest -SourcePath $src18 -UiRoot $ui18 | Out-Null
$json18 = [IO.File]::ReadAllText((Join-Path $ui18 'tokens.json'), [System.Text.Encoding]::UTF8)
Assert-Equal 'False' ([string]($json18 -match [regex]::Escape('$description'))) 'tokens.json scrub removes every $description'
Assert-Equal 'False' ([string]($json18 -match 'secret'))                       'tokens.json scrub removes the description text itself'
Assert-Equal 'True'  ([string]($json18 -match [regex]::Escape('$value')))      'tokens.json scrub keeps $value leaves'
Assert-Equal 'True'  ([string]($json18 -match 'ffcb1d'))                       'tokens.json scrub keeps the pri value data'
Assert-Equal 'True'  ([string]($json18 -match '112233'))                       'tokens.json scrub keeps the sec value data'
$reparsed18 = $null
try { $reparsed18 = $json18 | ConvertFrom-Json } catch { $reparsed18 = $null }
Assert-Equal 'True' ([string]($null -ne $reparsed18)) 'tokens.json scrub output still parses as JSON'

foreach ($d in @($src,$ui,$src5,$ui5,$src6,$ui6,$src7,$ui7,$src8,$ui8,$src9,$ui9,$src17,$ui17,$src18,$ui18)) { Remove-Item -Recurse -Force $d -ErrorAction SilentlyContinue }
if ($script:Failures -gt 0) { Write-Host "`n$($script:Failures) failure(s)" -ForegroundColor Red; exit 1 }
Write-Host "`nAll tests passed" -ForegroundColor Green
exit 0
