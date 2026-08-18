<#
  apply-onboarding-changes.ps1
  ---------------------------------
  Run this from:
  PS D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2>

      .\apply-onboarding-changes.ps1

  What it does:
    1. Backs up each file it touches (adds a .bak copy next to the original).
    2. Edits register/page.tsx to set a "just signed up" flag when a learner signs up.
    3. Edits learner-onboarding-tour.tsx to force-show the tour after signup.
    4. Edits learner-onboarding-checklist.tsx to force-show the checklist after signup.
    5. Edits dashboard/page.tsx to clear the flag once the dashboard has shown it.

  If a file/pattern isn't found (e.g. because you've since edited the file by
  hand), the script will tell you exactly which step failed instead of silently
  corrupting anything.
#>

$ErrorActionPreference = "Stop"

$root = Get-Location
Write-Host "Running from: $root" -ForegroundColor Cyan

function Backup-File($path) {
    if (Test-Path $path) {
        Copy-Item $path "$path.bak" -Force
        Write-Host "  Backed up -> $path.bak" -ForegroundColor DarkGray
    }
}

function Replace-InFile {
    param(
        [string]$Path,
        [string]$Old,
        [string]$New,
        [string]$Description
    )

    if (-not (Test-Path $Path)) {
        Write-Host "  [SKIP] File not found: $Path" -ForegroundColor Yellow
        return $false
    }

    $content = Get-Content -Raw -Path $Path

    if ($content.Contains($Old)) {
        Backup-File $Path
        $updated = $content.Replace($Old, $New)
        Set-Content -Path $Path -Value $updated -NoNewline
        Write-Host "  [OK] $Description" -ForegroundColor Green
        return $true
    }
    elseif ($content.Contains($New)) {
        Write-Host "  [ALREADY APPLIED] $Description" -ForegroundColor Cyan
        return $true
    }
    else {
        Write-Host "  [NOT FOUND] Could not locate expected code for: $Description" -ForegroundColor Red
        Write-Host "  -> Open the file and apply this change manually." -ForegroundColor Red
        return $false
    }
}

# ---------------------------------------------------------------
# 1) register/page.tsx
# ---------------------------------------------------------------
$registerPath = "apps\web\app\(auth)\register\page.tsx"
Write-Host "`n1) Updating register page..." -ForegroundColor White

Replace-InFile -Path $registerPath `
  -Old '{ onSuccess: () => router.push(role === "instructor" ? "/instructor/dashboard" : "/dashboard") }' `
  -New @'
{
        onSuccess: () => {
          if (role === "learner") {
            window.localStorage.setItem("saachi-just-signed-up", "true");
          }
          router.push(role === "instructor" ? "/instructor/dashboard" : "/dashboard");
        }
      }
'@ `
  -Description "Set 'just signed up' flag on learner registration"

# ---------------------------------------------------------------
# 2) learner-onboarding-tour.tsx
# ---------------------------------------------------------------
$tourPath = "apps\web\components\ui\learner-onboarding-tour.tsx"
Write-Host "`n2) Updating onboarding tour..." -ForegroundColor White

Replace-InFile -Path $tourPath `
  -Old @'
  useEffect(() => {
    setHydrated(true);
    const seen = window.localStorage.getItem(SEEN_KEY) === "true";
    if (!seen) {
      const t = setTimeout(() => setOpen(true), 500); // let dashboard finish rendering first
      return () => clearTimeout(t);
    }
  }, []);
'@ `
  -New @'
  useEffect(() => {
    setHydrated(true);
    const justSignedUp = window.localStorage.getItem("saachi-just-signed-up") === "true";
    const seen = window.localStorage.getItem(SEEN_KEY) === "true";

    if (justSignedUp || !seen) {
      const t = setTimeout(() => setOpen(true), 500); // let dashboard finish rendering first
      return () => clearTimeout(t);
    }
  }, []);
'@ `
  -Description "Force-show tour after signup, ignoring previous 'seen' flag"

# ---------------------------------------------------------------
# 3) learner-onboarding-checklist.tsx
# ---------------------------------------------------------------
$checklistPath = "apps\web\components\ui\learner-onboarding-checklist.tsx"
Write-Host "`n3) Updating onboarding checklist..." -ForegroundColor White

Replace-InFile -Path $checklistPath `
  -Old @'
  useEffect(() => {
    setHydrated(true);
    const stored = window.localStorage.getItem(DISMISS_KEY);
    setDismissed(stored === "true");
  }, []);
'@ `
  -New @'
  useEffect(() => {
    setHydrated(true);
    const justSignedUp = window.localStorage.getItem("saachi-just-signed-up") === "true";
    const stored = window.localStorage.getItem(DISMISS_KEY);
    setDismissed(justSignedUp ? false : stored === "true");
  }, []);
'@ `
  -Description "Force-show checklist after signup, ignoring previous 'dismissed' flag"

# ---------------------------------------------------------------
# 4) dashboard/page.tsx
# ---------------------------------------------------------------
$dashboardPath = "apps\web\app\(learner)\dashboard\page.tsx"
Write-Host "`n4) Updating dashboard page to clear the signup flag..." -ForegroundColor White

if (Test-Path $dashboardPath) {
    $content = Get-Content -Raw -Path $dashboardPath

    if ($content -match 'import\s*\{\s*useState,\s*useEffect\s*\}\s*from\s*"react";') {
        Write-Host "  [ALREADY APPLIED] useEffect import already present" -ForegroundColor Cyan
    }
    elseif ($content -match 'import\s*\{\s*useEffect\s*\}\s*from\s*"react";') {
        Write-Host "  [ALREADY APPLIED] useEffect import already present" -ForegroundColor Cyan
    }
    else {
        Backup-File $dashboardPath
        $content = $content -replace '(^"use client";\s*\n)', "`$1`nimport { useEffect } from `"react`";`n"
        Set-Content -Path $dashboardPath -Value $content -NoNewline
        Write-Host "  [OK] Added useEffect import" -ForegroundColor Green
    }

    $content = Get-Content -Raw -Path $dashboardPath

    $oldReturn = 'return (
    <div>
      <LearnerOnboardingTour />'
    $newReturn = 'useEffect(() => {
    window.localStorage.removeItem("saachi-just-signed-up");
  }, []);

  return (
    <div>
      <LearnerOnboardingTour />'

    if ($content.Contains($oldReturn)) {
        Backup-File $dashboardPath
        $content = $content.Replace($oldReturn, $newReturn)
        Set-Content -Path $dashboardPath -Value $content -NoNewline
        Write-Host "  [OK] Added flag-clear effect to dashboard" -ForegroundColor Green
    }
    elseif ($content.Contains('window.localStorage.removeItem("saachi-just-signed-up")')) {
        Write-Host "  [ALREADY APPLIED] Flag-clear effect already present" -ForegroundColor Cyan
    }
    else {
        Write-Host "  [NOT FOUND] Could not locate the dashboard return block. Apply manually." -ForegroundColor Red
    }
}
else {
    Write-Host "  [SKIP] File not found: $dashboardPath" -ForegroundColor Yellow
}

Write-Host "`nDone. Review any [NOT FOUND] lines above and apply those manually." -ForegroundColor White
Write-Host "Backups (.bak) were created next to any file that was changed." -ForegroundColor White