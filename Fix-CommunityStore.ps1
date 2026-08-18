<#
.SYNOPSIS
    Fixes the "upvotes does not exist in type 'CommunityAnswer'" TypeScript
    build error in packages/store/src/useCommunityStore.ts

.USAGE
    Run this from the SAI2 repo root:
    PS D:\...\SAI2> .\Fix-CommunityStore.ps1
#>

$ErrorActionPreference = "Stop"

$targetFile = Join-Path $PSScriptRoot "packages\store\src\useCommunityStore.ts"

if (-not (Test-Path $targetFile)) {
    Write-Host "ERROR: Could not find file at: $targetFile" -ForegroundColor Red
    Write-Host "Make sure you're running this script from the SAI2 repo root." -ForegroundColor Yellow
    exit 1
}

Write-Host "Reading $targetFile ..." -ForegroundColor Cyan
$content = Get-Content -Path $targetFile -Raw

$originalContent = $content
$changesMade = 0

# ---------------------------------------------------------------------------
# Fix 1: Add `upvotes: number;` to the CommunityAnswer type definition
# ---------------------------------------------------------------------------
$oldType = @'
export type CommunityAnswer = {
  id: string;
  authorName: string;
  isInstructor: boolean;
  body: string;
  createdAt: string;
};
'@

$newType = @'
export type CommunityAnswer = {
  id: string;
  authorName: string;
  isInstructor: boolean;
  body: string;
  createdAt: string;
  upvotes: number;
};
'@

if ($content.Contains($oldType)) {
    $content = $content.Replace($oldType, $newType)
    $changesMade++
    Write-Host "  [OK] Patched CommunityAnswer type definition." -ForegroundColor Green
} elseif ($content.Contains("upvotes: number;") -and $content -match "export type CommunityAnswer") {
    Write-Host "  [SKIP] CommunityAnswer type already has 'upvotes'." -ForegroundColor Yellow
} else {
    Write-Host "  [WARN] Could not find expected CommunityAnswer type block (may already be edited)." -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# Fix 2: Add `upvotes: 0` wherever a new answer object is constructed
#         inside addAnswer (both createdAt lines that aren't seed data)
# ---------------------------------------------------------------------------
$oldAnswerConstruct = @'
                      id: genId("a"),
                      authorName,
                      isInstructor,
                      body,
                      createdAt: new Date().toISOString()
                    }
'@

$newAnswerConstruct = @'
                      id: genId("a"),
                      authorName,
                      isInstructor,
                      body,
                      createdAt: new Date().toISOString(),
                      upvotes: 0
                    }
'@

if ($content.Contains($oldAnswerConstruct)) {
    $content = $content.Replace($oldAnswerConstruct, $newAnswerConstruct)
    $changesMade++
    Write-Host "  [OK] Patched addAnswer() to include upvotes: 0." -ForegroundColor Green
} elseif ($content -match 'upvotes:\s*0') {
    Write-Host "  [SKIP] addAnswer() already includes 'upvotes: 0'." -ForegroundColor Yellow
} else {
    Write-Host "  [WARN] Could not find expected addAnswer() answer object (may already be edited)." -ForegroundColor Yellow
    Write-Host "         You may need to add 'upvotes: 0,' manually next to 'createdAt: new Date().toISOString()' inside addAnswer()." -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# Write back only if something changed
# ---------------------------------------------------------------------------
if ($content -ne $originalContent) {
    Set-Content -Path $targetFile -Value $content -NoNewline
    Write-Host ""
    Write-Host "Done. $changesMade change(s) applied to useCommunityStore.ts" -ForegroundColor Green
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Review the diff (git diff packages/store/src/useCommunityStore.ts)"
    Write-Host "  2. Run: pnpm install (if needed) && pnpm turbo run build"
    Write-Host "  3. Commit and push"
} else {
    Write-Host ""
    Write-Host "No changes were made. File may already be fixed, or its structure" -ForegroundColor Yellow
    Write-Host "differs from what this script expects. Open the file manually and" -ForegroundColor Yellow
    Write-Host "check the two spots mentioned above." -ForegroundColor Yellow
}