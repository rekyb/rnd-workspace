$ErrorActionPreference = 'Stop'

$prototypePath = Join-Path $PSScriptRoot 'prototype-web.html'
$stylesPath = Join-Path $PSScriptRoot 'styles.css'
$dataPath = Join-Path $PSScriptRoot 'data.js'
$mainPath = Join-Path $PSScriptRoot 'main.js'
$outputPath = Join-Path $PSScriptRoot 'standalone.html'

$html = Get-Content -LiteralPath $prototypePath -Raw -Encoding UTF8
$styles = Get-Content -LiteralPath $stylesPath -Raw -Encoding UTF8
$data = Get-Content -LiteralPath $dataPath -Raw -Encoding UTF8
$main = Get-Content -LiteralPath $mainPath -Raw -Encoding UTF8

$html = $html.Replace(
  '<link rel="stylesheet" href="styles.css">',
  "<style>`r`n$styles`r`n</style>"
)
$html = $html.Replace(
  '<script src="data.js"></script>',
  "<script>`r`n$data`r`n</script>"
)
$html = $html.Replace(
  '<script src="main.js"></script>',
  "<script>`r`n$main`r`n</script>"
)

$assetPattern = '(?<=["''(])(?<path>(?!data:|https?:|#)[^"''()]+?\.(?:png|jpe?g|gif|webp|svg))(?=["'')])'
$html = [regex]::Replace($html, $assetPattern, {
  param($match)

  $relativePath = $match.Groups['path'].Value
  $assetPath = Join-Path $PSScriptRoot ($relativePath -replace '/', '\')
  if (-not (Test-Path -LiteralPath $assetPath -PathType Leaf)) {
    throw "Local asset not found: $relativePath"
  }

  $extension = [IO.Path]::GetExtension($assetPath).ToLowerInvariant()
  $mime = switch ($extension) {
    '.png' { 'image/png' }
    '.jpg' { 'image/jpeg' }
    '.jpeg' { 'image/jpeg' }
    '.gif' { 'image/gif' }
    '.webp' { 'image/webp' }
    '.svg' { 'image/svg+xml' }
    default { throw "Unsupported image type: $extension" }
  }

  $bytes = [IO.File]::ReadAllBytes($assetPath)
  "data:$mime;base64,$([Convert]::ToBase64String($bytes))"
})

[IO.File]::WriteAllText($outputPath, $html, [Text.UTF8Encoding]::new($false))
Write-Output "Built $outputPath"
