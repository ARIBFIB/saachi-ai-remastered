<#
    fix-register-role-redirect.ps1

    Bug: after registering with role = "instructor", the register page
    always redirects to "/dashboard" (the learner dashboard) instead of
    "/instructor/dashboard".

    Fix: redirect based on the selected role.

    Run from SAI2 root:
      PS D:\...\SAI2> .\fix-register-role-redirect.ps1
#>

$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
if (-not $root) { $root = (Get-Location).Path }

$pageFile = Join-Path $root "apps\web\app\(auth)\register\page.tsx"

if (-not (Test-Path -LiteralPath $pageFile)) {
    Write-Host "Could not find: $pageFile" -ForegroundColor Red
    exit 1
}

$content = [System.IO.File]::ReadAllText($pageFile)
$originalContent = $content

$old = @'
    register.mutate(
      { fullName, email, password, confirmPassword, role: role as "learner" | "instructor" },
      { onSuccess: () => router.push("/dashboard") }
    );
'@

$new = @'
    register.mutate(
      { fullName, email, password, confirmPassword, role: role as "learner" | "instructor" },
      { onSuccess: () => router.push(role === "instructor" ? "/instructor/dashboard" : "/dashboard") }
    );
'@

if ($content -match [regex]::Escape($old)) {
    $content = $content.Replace($old, $new)
    Write-Host "Fixed: redirect now depends on selected role" -ForegroundColor Green
}
else {
    Write-Host "Expected block not found in exact form. No changes made." -ForegroundColor Yellow
    Write-Host "Manually change the onSuccess redirect in apps\web\app\(auth)\register\page.tsx to:" -ForegroundColor Yellow
    Write-Host '  onSuccess: () => router.push(role === "instructor" ? "/instructor/dashboard" : "/dashboard")' -ForegroundColor Yellow
    exit 0
}

if ($content -ne $originalContent) {
    [System.IO.File]::WriteAllText($pageFile, $content, [System.Text.Encoding]::UTF8)
    Write-Host ""
    Write-Host "File updated: apps\web\app\(auth)\register\page.tsx" -ForegroundColor Cyan
}