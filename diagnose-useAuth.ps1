<#
    diagnose-useAuth.ps1

    Prints packages/api-client/src/hooks/useAuth.ts so we can see the shape
    of data returned by useLogin()'s mutation (specifically whether it
    includes a "role" field we can redirect on).

    Run from SAI2 root:
      PS D:\...\SAI2> .\diagnose-useAuth.ps1
#>

$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
if (-not $root) { $root = (Get-Location).Path }

$authFile = Join-Path $root "packages\api-client\src\hooks\useAuth.ts"

if (-not (Test-Path -LiteralPath $authFile)) {
    Write-Host "Could not find: $authFile" -ForegroundColor Red
    exit 1
}

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "FILE: packages\api-client\src\hooks\useAuth.ts" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
$content = [System.IO.File]::ReadAllText($authFile)
Write-Host $content