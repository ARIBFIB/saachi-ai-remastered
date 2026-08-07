# fix-path-issue.ps1
# Run this FIRST, then re-run fix-frontend.ps1 (or just replace the function in it)

$content = Get-Content -Path ".\fix-frontend.ps1" -Raw

$oldFunc = @'
function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $enc)
    Write-Host "  wrote $Path"
}
'@

$newFunc = @'
function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $fullPath = Join-Path -Path (Get-Location).Path -ChildPath $Path
    $dir = Split-Path -Parent $fullPath
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($fullPath, $Content, $enc)
    Write-Host "  wrote $fullPath"
}
'@

$content = $content.Replace($oldFunc, $newFunc)
Set-Content -Path ".\fix-frontend.ps1" -Value $content -Encoding UTF8
Write-Host "Patched fix-frontend.ps1 - now re-run: .\fix-frontend.ps1" -ForegroundColor Green