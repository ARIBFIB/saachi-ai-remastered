<#
  Fix-BuildErrors.ps1
  Run from SAI2 root: .\Fix-BuildErrors.ps1

  Fixes two build errors reported after Add-MissingPages-2.ps1:
  1. Conflicting star export 'useCourseDetail' between useCourses.ts and
     useCourseDetailStubs.ts -> rename the stub's export to avoid the clash.
  2. 'updateProgress' does not exist on EnrollmentState -> remove the call
     from the course player page (frontend-only demo, safe to drop for now).
#>

$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# Fix 1: rename useCourseDetail -> useCourseDetailDemo in the stub file,
# and update its usages (courses/[slug]/page.tsx).
# ---------------------------------------------------------------------------
$stubPath = 'packages\api-client\src\hooks\useCourseDetailStubs.ts'

if (Test-Path $stubPath) {
    $content = Get-Content $stubPath -Raw

    if ($content -match "export function useCourseDetail\(") {
        $content = $content -replace "export function useCourseDetail\(", "export function useCourseDetailDemo("
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText((Join-Path $PWD $stubPath), $content, $utf8NoBom)
        Write-Host "FIXED: renamed useCourseDetail -> useCourseDetailDemo in $stubPath" -ForegroundColor Green
    } else {
        Write-Host "SKIP: useCourseDetail not found in $stubPath (already renamed?)" -ForegroundColor Yellow
    }
} else {
    Write-Host "WARNING: $stubPath not found." -ForegroundColor Red
}

$coursePagePath = 'apps\web\app\(marketing)\courses\[slug]\page.tsx'
if (Test-Path -LiteralPath $coursePagePath) {
    $content = Get-Content -LiteralPath $coursePagePath -Raw
    $original = $content

    $content = $content -replace "useCourseDetail\b", "useCourseDetailDemo"

    if ($content -ne $original) {
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText((Join-Path $PWD $coursePagePath), $content, $utf8NoBom)
        Write-Host "FIXED: updated useCourseDetail -> useCourseDetailDemo in $coursePagePath" -ForegroundColor Green
    } else {
        Write-Host "SKIP: no useCourseDetail usage found in $coursePagePath" -ForegroundColor Yellow
    }
} else {
    Write-Host "WARNING: $coursePagePath not found." -ForegroundColor Red
}

# ---------------------------------------------------------------------------
# Fix 2: remove the non-existent updateProgress call from the course player
# ---------------------------------------------------------------------------
$playerPath = 'apps\web\app\(learner)\learn\[courseId]\[lessonId]\page.tsx'

if (Test-Path -LiteralPath $playerPath) {
    $content = Get-Content -LiteralPath $playerPath -Raw
    $original = $content

    $content = $content -replace [regex]::Escape('  const updateProgress = useEnrollmentStore((s) => s.updateProgress);' + "`r`n"), ""
    $content = $content -replace [regex]::Escape('  const updateProgress = useEnrollmentStore((s) => s.updateProgress);' + "`n"), ""

    $oldBlock = @'
    setCompletedIds((prev) => new Set(prev).add(currentLesson.id));
    const pct = Math.round(((completedIds.size + 1) / allLessons.length) * 100);
    if (enrollment && updateProgress) {
      updateProgress(enrollment.courseId, Math.min(100, pct));
    }
    if (nextLesson) {
'@
    $newBlock = @'
    setCompletedIds((prev) => new Set(prev).add(currentLesson.id));
    // NOTE: demo-only local completion tracking. Wire this up to the real
    // enrollment progress mutation once packages/store's enrollment API
    // exposes a progress-update action.
    if (nextLesson) {
'@

    if ($content.Contains($oldBlock)) {
        $content = $content.Replace($oldBlock, $newBlock)
    }

    if ($content -ne $original) {
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText((Join-Path $PWD $playerPath), $content, $utf8NoBom)
        Write-Host "FIXED: removed updateProgress call from $playerPath" -ForegroundColor Green
    } else {
        Write-Host "SKIP: updateProgress call not found in $playerPath (already fixed?)" -ForegroundColor Yellow
    }
} else {
    Write-Host "WARNING: $playerPath not found." -ForegroundColor Red
}

Write-Host ""
Write-Host "Done. Re-run: pnpm --filter web build" -ForegroundColor Cyan