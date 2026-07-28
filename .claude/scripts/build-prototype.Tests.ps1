# Dependency-free test harness for build-prototype.ps1
$ErrorActionPreference = 'Stop'
$script:Failures = 0
$ScriptUnderTest = Join-Path $PSScriptRoot 'build-prototype.ps1'
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

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

$root = Join-Path ([System.IO.Path]::GetTempPath()) ("protobuild_" + [guid]::NewGuid().ToString('N'))

# A 1x1 transparent PNG, so image tests use real bytes rather than a text stub.
$PNG_B64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=='

function New-Project {
    param([string]$Name)
    $p   = Join-Path $root $Name
    $src = Join-Path $p 'src'
    New-Item -ItemType Directory -Force -Path $src | Out-Null
    return $p
}

function Write-File {
    param([string]$Path, [string]$Text)
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [IO.File]::WriteAllText($Path, $Text, $Utf8NoBom)
}

function Invoke-Build {
    param([string]$ProjectPath, [string]$EntryPath, [string]$Out)
    $a = @('-NoProfile', '-File', $ScriptUnderTest, '-ProjectPath', $ProjectPath)
    if ($EntryPath) { $a += @('-EntryPath', $EntryPath) }
    if ($Out)       { $a += @('-Out', $Out) }
    $o = & powershell @a
    return @{ Code = $LASTEXITCODE; Out = [string]$o }
}

# --- Test 1: a minimal project inlines its CSS and JS into one file.
$p1 = New-Project 'p1'
Write-File (Join-Path $p1 'src\index.html') '<!doctype html><html><head><link rel="stylesheet" href="app.css"></head><body><div class="x"></div><script src="app.js"></script></body></html>'
Write-File (Join-Path $p1 'src\app.css')    '.x { color: var(--ink); }'
Write-File (Join-Path $p1 'src\app.js')     'window.BUILT = true;'
$r1  = Invoke-Build -ProjectPath $p1
$o1  = Join-Path $p1 'build\standalone.html'
Assert-Equal '0'    ([string]$r1.Code)                                  'a minimal project builds with exit 0'
Assert-Equal 'True' ([string](Test-Path -LiteralPath $o1))              'the default output lands at build/standalone.html'
$t1 = [IO.File]::ReadAllText($o1)
Assert-Equal 'True'  ([string]($t1 -match '\.x \{ color: var\(--ink\); \}')) 'the stylesheet contents are inlined'
Assert-Equal 'True'  ([string]($t1 -match 'window\.BUILT = true;'))          'the script contents are inlined'
Assert-Equal 'False' ([string]($t1 -match '<link'))                          'no <link> tag survives the build'
Assert-Equal 'False' ([string]($t1 -match 'src="app\.js"'))                  'no external script src survives the build'

# --- Test 2: -Out overrides the default location.
$alt = Join-Path $root 'elsewhere\custom.html'
$r2  = Invoke-Build -ProjectPath $p1 -Out $alt
Assert-Equal '0'    ([string]$r2.Code)                        '-Out builds with exit 0'
Assert-Equal 'True' ([string](Test-Path -LiteralPath $alt))   '-Out writes to the given path, creating its folder'

# --- Test 3: the success line names the output file.
Assert-Equal 'True' ([string]($r1.Out -match 'Built .*standalone\.html')) 'success prints the built path'

# --- Test 4: the build is deterministic - same input, same bytes.
$first = [IO.File]::ReadAllBytes($o1)
Invoke-Build -ProjectPath $p1 | Out-Null
$second = [IO.File]::ReadAllBytes($o1)
Assert-Equal ([Convert]::ToBase64String($first)) ([Convert]::ToBase64String($second)) 'rebuilding produces byte-identical output'

# --- Test 5: a missing entry file fails and names the path it expected.
$p5 = New-Project 'p5'
$r5 = Invoke-Build -ProjectPath $p5
Assert-Equal 'True'  ([string]($r5.Code -ne 0))                                      'a missing entry file exits non-zero'
Assert-Equal 'True'  ([string]($r5.Out -match 'index\.html'))                        'the failure names the entry file it looked for'
Assert-Equal 'False' ([string](Test-Path -LiteralPath (Join-Path $p5 'build\standalone.html'))) 'a failed build writes no output'

# --- Test 6: a missing stylesheet fails and names it.
$p6 = New-Project 'p6'
Write-File (Join-Path $p6 'src\index.html') '<html><head><link rel="stylesheet" href="gone.css"></head><body></body></html>'
$r6 = Invoke-Build -ProjectPath $p6
Assert-Equal 'True'  ([string]($r6.Code -ne 0))                'a missing stylesheet exits non-zero'
Assert-Equal 'True'  ([string]($r6.Out -match 'gone\.css'))    'the failure names the missing stylesheet'

# --- Test 7: a missing script fails and names it.
$p7 = New-Project 'p7'
Write-File (Join-Path $p7 'src\index.html') '<html><body><script src="gone.js"></script></body></html>'
$r7 = Invoke-Build -ProjectPath $p7
Assert-Equal 'True' ([string]($r7.Code -ne 0))             'a missing script exits non-zero'
Assert-Equal 'True' ([string]($r7.Out -match 'gone\.js'))  'the failure names the missing script'

# --- Test 8: an external stylesheet cannot be inlined, so it is a hard failure.
$p8 = New-Project 'p8'
Write-File (Join-Path $p8 'src\index.html') '<html><head><link rel="stylesheet" href="https://cdn.example.com/x.css"></head><body></body></html>'
$r8 = Invoke-Build -ProjectPath $p8
Assert-Equal 'True' ([string]($r8.Code -ne 0))                    'an external stylesheet exits non-zero'
Assert-Equal 'True' ([string]($r8.Out -match 'cdn\.example\.com')) 'the failure names the external host'

# --- Test 9: a protocol-relative script src is external too.
$p9 = New-Project 'p9'
Write-File (Join-Path $p9 'src\index.html') '<html><body><script src="//cdn.example.com/x.js"></script></body></html>'
$r9 = Invoke-Build -ProjectPath $p9
Assert-Equal 'True' ([string]($r9.Code -ne 0)) 'a protocol-relative script src exits non-zero'

# --- Test 10: a relative image becomes a data: URI.
$p10 = New-Project 'p10'
Write-File (Join-Path $p10 'src\index.html') '<html><body><img src="img/a.png"></body></html>'
New-Item -ItemType Directory -Force -Path (Join-Path $p10 'src\img') | Out-Null
[IO.File]::WriteAllBytes((Join-Path $p10 'src\img\a.png'), [Convert]::FromBase64String($PNG_B64))
$r10 = Invoke-Build -ProjectPath $p10
$t10 = [IO.File]::ReadAllText((Join-Path $p10 'build\standalone.html'))
Assert-Equal '0'     ([string]$r10.Code)                            'a project with an image builds'
Assert-Equal 'True'  ([string]($t10 -match 'data:image/png;base64,')) 'the image is base64-inlined'
Assert-Equal 'False' ([string]($t10 -match 'src="img/a\.png"'))       'the original image path is gone'

# --- Test 11: a missing relative image is a hard failure.
$p11 = New-Project 'p11'
Write-File (Join-Path $p11 'src\index.html') '<html><body><img src="img/missing.png"></body></html>'
$r11 = Invoke-Build -ProjectPath $p11
Assert-Equal 'True' ([string]($r11.Code -ne 0))                 'a missing image exits non-zero'
Assert-Equal 'True' ([string]($r11.Out -match 'missing\.png'))  'the failure names the missing image'

# --- Test 12: a root-absolute asset path is left alone, NOT an error. This is what
# lets ui-library/components.css (which ships url("/brand/logo-icon.svg")) pass through.
$p12 = New-Project 'p12'
Write-File (Join-Path $p12 'src\index.html') '<html><head><link rel="stylesheet" href="ui.css"></head><body></body></html>'
Write-File (Join-Path $p12 'src\ui.css')     '.logo { background: url("/brand/logo-icon.svg") no-repeat; }'
$r12 = Invoke-Build -ProjectPath $p12
$t12 = [IO.File]::ReadAllText((Join-Path $p12 'build\standalone.html'))
Assert-Equal '0'    ([string]$r12.Code)                                    'a root-absolute asset path does not fail the build'
Assert-Equal 'True' ([string]($t12 -match 'url\("/brand/logo-icon\.svg"\)')) 'a root-absolute asset path is left untouched'

# --- Test 13: an inlined stylesheet survives byte-for-byte. check-prototype.ps1 rule 2
# skips itself entirely unless it finds tokens.css and components.css inlined verbatim,
# so this guarantee is load-bearing, not cosmetic.
$p13 = New-Project 'p13'
$VERBATIM = ":root {`n  --pri: #ffcb1d;`n  --ink: #1d1826;`n}`n.logo { background: url(`"/brand/logo-icon.svg`"); }`n"
Write-File (Join-Path $p13 'src\index.html') '<html><head><link rel="stylesheet" href="tokens.css"></head><body></body></html>'
Write-File (Join-Path $p13 'src\tokens.css') $VERBATIM
Invoke-Build -ProjectPath $p13 | Out-Null
$t13 = [IO.File]::ReadAllText((Join-Path $p13 'build\standalone.html'))
Assert-Equal 'True' ([string]($t13.Contains($VERBATIM))) 'an inlined stylesheet appears verbatim in the output'

# --- Test 14: a CSS url() resolves against the STYLESHEET's folder, not the entry HTML's.
# The two differ whenever CSS lives in a subfolder, and getting this wrong silently
# inlines the wrong file or fails a build that should succeed.
$p14 = New-Project 'p14'
Write-File (Join-Path $p14 'src\index.html')     '<html><head><link rel="stylesheet" href="css/app.css"></head><body></body></html>'
Write-File (Join-Path $p14 'src\css\app.css')    '.h { background: url("pix/b.png"); }'
New-Item -ItemType Directory -Force -Path (Join-Path $p14 'src\css\pix') | Out-Null
[IO.File]::WriteAllBytes((Join-Path $p14 'src\css\pix\b.png'), [Convert]::FromBase64String($PNG_B64))
$r14 = Invoke-Build -ProjectPath $p14
$t14 = [IO.File]::ReadAllText((Join-Path $p14 'build\standalone.html'))
Assert-Equal '0'    ([string]$r14.Code)                             'a CSS-relative asset resolves against the stylesheet folder'
Assert-Equal 'True' ([string]($t14 -match 'data:image/png;base64,')) 'the CSS-relative image is inlined'

# --- Test 15: output is UTF-8 with no BOM.
$bytes15 = [IO.File]::ReadAllBytes((Join-Path $p1 'build\standalone.html'))
$hasBom  = ($bytes15.Length -ge 3 -and $bytes15[0] -eq 0xEF -and $bytes15[1] -eq 0xBB -and $bytes15[2] -eq 0xBF)
Assert-Equal 'False' ([string]$hasBom) 'the built file has no UTF-8 BOM'

# --- Test 16: an inline <script> with no src is left untouched (not treated as
# a missing/external src - it simply is not a <script src="..."> tag at all).
$p16 = New-Project 'p16'
Write-File (Join-Path $p16 'src\index.html') '<html><body><script>window.INLINE = 1;</script></body></html>'
$r16 = Invoke-Build -ProjectPath $p16
$t16 = [IO.File]::ReadAllText((Join-Path $p16 'build\standalone.html'))
Assert-Equal '0'    ([string]$r16.Code)                              'a project with only an inline script builds'
Assert-Equal 'True' ([string]($t16 -match 'window\.INLINE = 1;'))    'the inline script content survives untouched'

# --- Test 17: an external image URL in CSS passes through untouched (rule 7 -
# policy on external hosts belongs to check-prototype.ps1, not the builder).
$p17 = New-Project 'p17'
Write-File (Join-Path $p17 'src\index.html') '<html><head><link rel="stylesheet" href="ext.css"></head><body></body></html>'
Write-File (Join-Path $p17 'src\ext.css')    '.hero { background: url("https://cdn.example.com/hero.jpg"); }'
$r17 = Invoke-Build -ProjectPath $p17
$t17 = [IO.File]::ReadAllText((Join-Path $p17 'build\standalone.html'))
Assert-Equal '0'    ([string]$r17.Code)                                                   'an external CSS image URL does not fail the build'
Assert-Equal 'True' ([string]($t17 -match 'url\("https://cdn\.example\.com/hero\.jpg"\)')) 'an external CSS image URL is left untouched'

# --- Test 18: multiple stylesheets and scripts all inline correctly, in order.
$p18 = New-Project 'p18'
Write-File (Join-Path $p18 'src\index.html') '<!doctype html><html><head><link rel="stylesheet" href="a.css"><link rel="stylesheet" href="b.css"></head><body><script src="a.js"></script><script src="b.js"></script></body></html>'
Write-File (Join-Path $p18 'src\a.css')      '.a { color: red; }'
Write-File (Join-Path $p18 'src\b.css')      '.b { color: blue; }'
Write-File (Join-Path $p18 'src\a.js')       'window.A = 1;'
Write-File (Join-Path $p18 'src\b.js')       'window.B = 1;'
$r18 = Invoke-Build -ProjectPath $p18
$t18 = [IO.File]::ReadAllText((Join-Path $p18 'build\standalone.html'))
Assert-Equal '0'    ([string]$r18.Code)                       'a project with multiple stylesheets and scripts builds'
Assert-Equal 'True' ([string]($t18 -match '\.a \{ color: red; \}'))   'the first stylesheet is inlined'
Assert-Equal 'True' ([string]($t18 -match '\.b \{ color: blue; \}'))  'the second stylesheet is inlined'
Assert-Equal 'True' ([string]($t18 -match 'window\.A = 1;'))          'the first script is inlined'
Assert-Equal 'True' ([string]($t18 -match 'window\.B = 1;'))          'the second script is inlined'
Assert-Equal 'False' ([string]($t18 -match '<link'))                  'no <link> tag survives with multiple stylesheets'

# --- Cleanup + summary
Remove-Item -Recurse -Force -LiteralPath $root -ErrorAction SilentlyContinue
Write-Host ''
if ($script:Failures -gt 0) { Write-Host "$($script:Failures) test(s) failed" -ForegroundColor Red; exit 1 }
Write-Host 'All tests passed' -ForegroundColor Green
exit 0
