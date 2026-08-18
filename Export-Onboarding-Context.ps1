<#
Export-Onboarding-Context.ps1
Run this from: SAI2 root (same level as apps/, packages/, package.json)
Generates: Onboarding-Context-<timestamp>.txt

Usage:
  PS D:\...\SAI2> .\Export-Onboarding-Context.ps1
#>

$ErrorActionPreference = "SilentlyContinue"

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$outFile   = "Onboarding-Context-$timestamp.txt"

# Only files relevant to building the learner onboarding checklist feature
$targetPaths = @(
    # Learner dashboard + layout (where onboarding will be shown)
    "apps\web\app\(learner)\dashboard\page.tsx",
    "apps\web\app\(learner)\layout.tsx",

    # Auth pages (to know where signup/login redirect happens)
    "apps\web\app\(auth)\login\page.tsx",
    "apps\web\app\(auth)\register\page.tsx",

    # Existing similar component (instructor onboarding checklist) as reference pattern
    "apps\web\components\ui\instructor-onboarding-checklist.tsx",

    # shadcn/ui primitives that might already exist (avoid duplicate creation)
    "apps\web\components\ui\dialog.tsx",

    # Utils (cn helper, needed by the new component)
    "apps\web\lib\utils.ts",

    # State stores (to decide where "hasSeenOnboarding" flag should live)
    "packages\store\src\index.ts",
    "packages\store\src\useEnrollmentStore.ts",
    "packages\store\src\useNotifPrefsStore.ts",
    "packages\store\src\useLocaleStore.ts",

    # API client / auth hook (to know user object shape, e.g. role, flags)
    "packages\api-client\src\hooks\useAuth.ts",
    "packages\api-client\src\types\index.ts",

    # Config files needed to confirm path aliases & installed deps
    "apps\web\tsconfig.json",
    "apps\web\package.json",
    "apps\web\next.config.js",

    # Shared UI package entry (in case onboarding should live here instead)
    "packages\ui\src\index.ts"
)

if (Test-Path $outFile) { Remove-Item $outFile }

"===== ONBOARDING FEATURE CONTEXT EXPORT =====" | Out-File -FilePath $outFile -Encoding utf8
"Generated: $timestamp" | Out-File -FilePath $outFile -Append -Encoding utf8
"" | Out-File -FilePath $outFile -Append -Encoding utf8

$foundCount = 0
$missingCount = 0

foreach ($rel in $targetPaths) {
    $full = Join-Path -Path (Get-Location) -ChildPath $rel

    "----------------------------------------------------------------------" | Out-File -FilePath $outFile -Append -Encoding utf8
    "FILE: $rel" | Out-File -FilePath $outFile -Append -Encoding utf8
    "----------------------------------------------------------------------" | Out-File -FilePath $outFile -Append -Encoding utf8

    if (Test-Path $full) {
        Get-Content -Path $full -Raw | Out-File -FilePath $outFile -Append -Encoding utf8
        $foundCount++
    } else {
        "[NOT FOUND - file does not exist at this path]" | Out-File -FilePath $outFile -Append -Encoding utf8
        $missingCount++
    }
    "" | Out-File -FilePath $outFile -Append -Encoding utf8
}

Write-Host ""
Write-Host "Done. Exported: $foundCount file(s), Missing: $missingCount file(s)" -ForegroundColor Green
Write-Host "Output: $outFile" -ForegroundColor Cyan