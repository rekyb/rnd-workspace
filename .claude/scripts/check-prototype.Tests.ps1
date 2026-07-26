# Dependency-free test harness for check-prototype.ps1
$ErrorActionPreference = 'Stop'
$script:Failures = 0
$ScriptUnderTest = Join-Path $PSScriptRoot 'check-prototype.ps1'
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

$root = Join-Path ([System.IO.Path]::GetTempPath()) ("protochk_" + [guid]::NewGuid().ToString('N'))
$ui   = Join-Path $root 'ui'
New-Item -ItemType Directory -Force -Path $ui | Out-Null

$TOKENS = ":root {`n  --pri: #ffcb1d;`n  --ink: #1d1826;`n  --sp-md: 16px;`n}`n"
$COMP   = ".btn {`n  background: var(--pri);`n}`n.card {`n  color: var(--ink);`n}`n"
[IO.File]::WriteAllText((Join-Path $ui 'tokens.css'), $TOKENS, $Utf8NoBom)
[IO.File]::WriteAllText((Join-Path $ui 'components.css'), $COMP, $Utf8NoBom)

# Build a standalone.html the way the real inliner does: tokens.css verbatim, then
# components.css, then the markup.
function New-Prototype {
    param([string]$Name, [string]$ExtraCss = '', [string]$Body)
    $html = "<!doctype html><html><head><style>`n$TOKENS`n$COMP`n$ExtraCss`n</style></head><body>`n$Body`n</body></html>"
    $p = Join-Path $root $Name
    [IO.File]::WriteAllText($p, $html, $Utf8NoBom)
    return $p
}

function Invoke-Check {
    param([string]$Path)
    $out = & powershell -NoProfile -File $ScriptUnderTest -Path $Path -UiRoot $ui 2>&1
    return @{ Code = $LASTEXITCODE; Out = [string]$out }
}

# --- Test 1: a clean prototype passes
$clean = New-Prototype -Name 'clean.html' -Body '<button class="btn">Go</button><div class="card">Hi</div>'
$r = Invoke-Check -Path $clean
Assert-Equal '0' ([string]$r.Code) 'rule set passes a clean prototype'

# --- Test 2: rule 1 - external host in an @import
$ext = New-Prototype -Name 'ext.html' -ExtraCss '@import url("https://fonts.googleapis.com/css2?family=Open+Sans");' -Body '<button class="btn">Go</button>'
$r = Invoke-Check -Path $ext
Assert-Equal 'True' ([string]($r.Code -ne 0))             'external @import fails'
Assert-Equal 'True' ([string]($r.Out -match 'external'))  'external @import is reported as an external-host violation'

# --- Test 3: rule 1 - external host in a src attribute
$extSrc = New-Prototype -Name 'extsrc.html' -Body '<img src="https://cdn.example.com/a.png"><button class="btn">Go</button>'
$r = Invoke-Check -Path $extSrc
Assert-Equal 'True' ([string]($r.Code -ne 0)) 'external src attribute fails'

# --- Test 4: rule 2 - a raw hex outside the token block
$hex = New-Prototype -Name 'hex.html' -ExtraCss '.custom { color: #ff0000; }' -Body '<button class="btn">Go</button>'
$r = Invoke-Check -Path $hex
Assert-Equal 'True' ([string]($r.Code -ne 0))            'raw hex outside tokens.css fails'
Assert-Equal 'True' ([string]($r.Out -match '#ff0000'))  'the offending hex value is named'

# --- Test 5: rule 2 - a raw px outside the token block
$px = New-Prototype -Name 'px.html' -ExtraCss '.custom { padding: 13px; }' -Body '<button class="btn">Go</button>'
$r = Invoke-Check -Path $px
Assert-Equal 'True' ([string]($r.Code -ne 0)) 'raw px outside tokens.css fails'

# --- Test 6: rule 3 - an undefined custom property
$undef = New-Prototype -Name 'undef.html' -ExtraCss '.custom { color: var(--nope); }' -Body '<button class="btn">Go</button>'
$r = Invoke-Check -Path $undef
Assert-Equal 'True' ([string]($r.Code -ne 0))          'undefined var(--x) fails'
Assert-Equal 'True' ([string]($r.Out -match '--nope')) 'the undefined property is named'

# --- Test 7: rule 4 - a class absent from components.css
$badClass = New-Prototype -Name 'badclass.html' -Body '<button class="btn ghost-nonexistent">Go</button>'
$r = Invoke-Check -Path $badClass
Assert-Equal 'True' ([string]($r.Code -ne 0))                            'unknown class fails'
Assert-Equal 'True' ([string]($r.Out -match 'ghost-nonexistent'))        'the unported class is named'

# --- Test 8: rule 5 - an email address in the markup
$pii = New-Prototype -Name 'pii.html' -Body '<button class="btn">Go</button><p>contact rekybongso@gmail.com</p>'
$r = Invoke-Check -Path $pii
Assert-Equal 'True' ([string]($r.Code -ne 0))         'an email address fails the PII rule'
Assert-Equal 'True' ([string]($r.Out -match 'PII'))   'the PII rule is named in the output'

# --- Test 9: the token block must be inlined verbatim or rule 2 cannot be evaluated
$noTokens = Join-Path $root 'notokens.html'
[IO.File]::WriteAllText($noTokens, "<!doctype html><html><head><style>`n$COMP`n</style></head><body><button class=`"btn`">Go</button></body></html>", $Utf8NoBom)
$r = Invoke-Check -Path $noTokens
Assert-Equal 'True' ([string]($r.Code -ne 0))                        'a build that did not inline tokens.css verbatim fails'
Assert-Equal 'True' ([string]($r.Out -match 'inlined|verbatim'))     'the missing token block is explained'

# --- Test 10: an overlay may redefine a token but not introduce one
$overlayOk  = Join-Path $root 'ok.overlay.css'
$overlayBad = Join-Path $root 'bad.overlay.css'
[IO.File]::WriteAllText($overlayOk,  ":root { --pri: #4f46e5; }`n", $Utf8NoBom)
[IO.File]::WriteAllText($overlayBad, ":root { --brand-new: #4f46e5; }`n", $Utf8NoBom)
$okOut = & powershell -NoProfile -File $ScriptUnderTest -Path $clean -UiRoot $ui -OverlayPath $overlayOk 2>&1
Assert-Equal '0' ([string]$LASTEXITCODE) 'an overlay redefining an existing token passes'
$badOut = & powershell -NoProfile -File $ScriptUnderTest -Path $clean -UiRoot $ui -OverlayPath $overlayBad 2>&1
Assert-Equal 'True' ([string]($LASTEXITCODE -ne 0))                  'an overlay introducing a new token fails'
Assert-Equal 'True' ([string]([string]$badOut -match '--brand-new')) 'the newly introduced token is named'

# --- Test 11: components.css itself legitimately contains raw hex/px values (it is
# a shared design-system file, same trust level as tokens.css) - a verbatim-inlined
# build must not be flagged for them. The real ui-library/components.css has ~360 raw px
# occurrences in its own selectors (borders, paddings, etc.), so excluding only the
# tokens.css span from the rule-2 scan would fail every real build.
$ui2 = Join-Path $root 'ui2'
New-Item -ItemType Directory -Force -Path $ui2 | Out-Null
$TOKENS2 = ":root {`n  --pri: #ffcb1d;`n}`n"
$COMP2   = ".card {`n  border: 1px solid #000000;`n  padding: 12px;`n}`n"
[IO.File]::WriteAllText((Join-Path $ui2 'tokens.css'), $TOKENS2, $Utf8NoBom)
[IO.File]::WriteAllText((Join-Path $ui2 'components.css'), $COMP2, $Utf8NoBom)
$html2 = "<!doctype html><html><head><style>`n$TOKENS2`n$COMP2`n</style></head><body><div class=`"card`">Hi</div></body></html>"
$p2 = Join-Path $root 'realistic.html'
[IO.File]::WriteAllText($p2, $html2, $Utf8NoBom)
$r2 = & powershell -NoProfile -File $ScriptUnderTest -Path $p2 -UiRoot $ui2 2>&1
Assert-Equal '0' ([string]$LASTEXITCODE) 'legitimate raw px/hex values inside the verbatim components.css block do not trigger rule 2'

# --- Test 12: a CSS id selector whose name is itself hex-shaped is not
# mistaken for a raw hex value. "#a1b2c3" is a valid (if unusual) CSS id and
# is shape-identical to a genuine 6-digit hex color; only its position (a
# selector, not a declaration value) tells them apart. A non-hex-shaped id
# like "#nav-bar" would never reach the hex regex at all (its letters aren't
# valid hex digits), so it would not actually exercise this distinction.
$idSel = New-Prototype -Name 'idsel.html' -ExtraCss '#a1b2c3 { color: var(--ink); }' -Body '<button class="btn">Go</button>'
$r = Invoke-Check -Path $idSel
Assert-Equal '0' ([string]$r.Code) 'a hex-shaped CSS id selector is not flagged as a raw hex value'

# --- Test 13: a bare in-page anchor whose fragment is itself hex-shaped is not
# mistaken for a raw hex value. This must be the BARE-ANCHOR form -
# href="#a1b2c3", where a quote (not a word character) immediately precedes
# the '#' - not href="/docs.html#a1b2c3". In the "/docs.html#..." form the
# character right before '#' is 'l' (from ".html"), so the pre-existing
# (?<![&\w]) lookbehind excludes that match before Test-InDeclarationValue is
# ever reached; that fixture passes identically against the pre-fix script
# (verified) and so does not actually exercise the fix. The bare-anchor form
# below reaches Test-InDeclarationValue (no colon precedes it back to the
# nearest boundary) and is confirmed to discriminate: it exits 1 against the
# pre-fix script and 0 against the current one (verified against a
# reconstructed pre-fix check-prototype.ps1).
$frag = New-Prototype -Name 'frag.html' -Body '<a class="btn" href="#a1b2c3">Go</a>'
$r = Invoke-Check -Path $frag
Assert-Equal '0' ([string]$r.Code) 'a hex-shaped bare in-page anchor is not flagged as a raw hex value'

# --- Test 13b: a raw hex WITHOUT a space after the colon still fails. This is
# a forward-looking correctness guard for Test-InDeclarationValue, not a
# regression test for the hex-position fix itself - it passes identically
# against the pre-fix script too (verified), because the pre-fix rule had
# false positives (Tests 12/13's shapes) but no false negatives. It is still
# worth keeping: it proves the declaration-value check does not overcorrect
# into "anchored so tightly it stops catching real violations."
$hexNoSpace = New-Prototype -Name 'hexnospace.html' -ExtraCss '.custom { background:#abc; }' -Body '<button class="btn">Go</button>'
$r = Invoke-Check -Path $hexNoSpace
Assert-Equal 'True' ([string]($r.Code -ne 0))         'a raw hex immediately after a colon (no space) still fails'
Assert-Equal 'True' ([string]($r.Out -match '#abc'))  'the offending no-space hex value is named'

# --- Test 13c: a raw hex separated from its property's colon by other value
# tokens (a length and a keyword) still fails. Like 13b, this is a
# forward-looking correctness guard, not a regression test for this fix - it
# also passes identically against the pre-fix script (verified). What it
# guards against is a DIFFERENT, hypothetical fix: a naive "hex must
# immediately follow a colon" anchor, which would break on this exact shape.
# It is the exact pattern the real ui-library/components.css uses for borders
# ("border: 1px solid ...").
$hexMultiValue = New-Prototype -Name 'hexmultivalue.html' -ExtraCss '.custom { border: 1px solid #abcdef; }' -Body '<button class="btn">Go</button>'
$r = Invoke-Check -Path $hexMultiValue
Assert-Equal 'True' ([string]($r.Code -ne 0))            'a raw hex several value-tokens after the colon still fails'
Assert-Equal 'True' ([string]($r.Out -match '#abcdef'))  'the offending multi-value-position hex value is named'

# --- Test 14: a class name matching a file extension inside components.css'
# url(...) is not treated as a known class. Naive `\.classname` scanning would
# also match the ".svg" inside url("/brand/logo-icon.svg"), silently widening
# the known-class set with things that were never real class selectors.
$ui3 = Join-Path $root 'ui3'
New-Item -ItemType Directory -Force -Path $ui3 | Out-Null
$TOKENS3 = ":root {`n  --pri: #ffcb1d;`n}`n"
$COMP3   = ".card {`n  background: url(`"/brand/logo-icon.svg`") center;`n}`n"
[IO.File]::WriteAllText((Join-Path $ui3 'tokens.css'), $TOKENS3, $Utf8NoBom)
[IO.File]::WriteAllText((Join-Path $ui3 'components.css'), $COMP3, $Utf8NoBom)
$html3 = "<!doctype html><html><head><style>`n$TOKENS3`n$COMP3`n</style></head><body><div class=`"svg`">Hi</div></body></html>"
$p3 = Join-Path $root 'svgclass.html'
[IO.File]::WriteAllText($p3, $html3, $Utf8NoBom)
$r3 = & powershell -NoProfile -File $ScriptUnderTest -Path $p3 -UiRoot $ui3 2>&1
Assert-Equal 'True' ([string]($LASTEXITCODE -ne 0)) 'a class matching a url() file extension in components.css is not treated as a known class'

# --- Test 15: a CRLF-vs-LF line-ending mismatch between the on-disk tokens.css and
# the inlined build does not break the verbatim match. A real checkout on Windows
# may keep tokens.css as CRLF while the build tool that produced standalone.html
# normalized to LF (or vice versa) - the two files coming from different tools/
# checkouts is exactly the scenario this guards against.
$ui4 = Join-Path $root 'ui4'
New-Item -ItemType Directory -Force -Path $ui4 | Out-Null
$tokens4Crlf = $TOKENS.Replace("`n", "`r`n")
[IO.File]::WriteAllText((Join-Path $ui4 'tokens.css'), $tokens4Crlf, $Utf8NoBom)
[IO.File]::WriteAllText((Join-Path $ui4 'components.css'), $COMP, $Utf8NoBom)
$html4 = "<!doctype html><html><head><style>`n$TOKENS`n$COMP`n</style></head><body><button class=`"btn`">Go</button></body></html>"
$p4 = Join-Path $root 'crlfmismatch.html'
[IO.File]::WriteAllText($p4, $html4, $Utf8NoBom)
$r4 = & powershell -NoProfile -File $ScriptUnderTest -Path $p4 -UiRoot $ui4 2>&1
Assert-Equal '0' ([string]$LASTEXITCODE) 'a CRLF-on-disk vs LF-in-build mismatch does not break verbatim token-block matching'

# --- Test 16: a --radix-* custom property is exempt from rule 3. Radix UI (used
# by several real components.css primitives - accordion, select, toast) sets
# these at runtime via an inline style attribute, never via a CSS declaration,
# so they can never be "defined" in tokens.css even in a correct build.
$radix = New-Prototype -Name 'radix.html' -ExtraCss '.acc { height: var(--radix-accordion-content-height); }' -Body '<button class="btn">Go</button>'
$r = Invoke-Check -Path $radix
Assert-Equal '0' ([string]$r.Code) 'a --radix-* runtime custom property is not flagged as undefined'

# --- Test 17: the script's own source stays 7-bit ASCII (regression guard)
# PS 5.1 decodes a BOM-less .ps1 using the system ANSI codepage, so a non-ASCII
# character in a here-string reaches stdout as mojibake. Keeping the source
# ASCII-only is what makes that impossible; this asserts it.
$srcBytes = [IO.File]::ReadAllBytes($ScriptUnderTest)
$nonAscii = @($srcBytes | Where-Object { $_ -gt 127 })
Assert-Equal '0' ([string]$nonAscii.Count) 'check-prototype.ps1 source contains no non-ASCII bytes'

Remove-Item -Recurse -Force $root -ErrorAction SilentlyContinue
if ($script:Failures -gt 0) { Write-Host "`n$($script:Failures) failure(s)" -ForegroundColor Red; exit 1 }
Write-Host "`nAll tests passed" -ForegroundColor Green
exit 0
