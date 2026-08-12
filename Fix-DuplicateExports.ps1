<#
================================================================================
Fix-DuplicateExports.ps1

Run this from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2>

    PS D:\...\SAI2> .\Fix-DuplicateExports.ps1 -WhatIfOnly    # preview only
    PS D:\...\SAI2> .\Fix-DuplicateExports.ps1                # apply fix

WHAT THIS FIXES:
  packages/api-client/src/index.ts does:
    export * from "./hooks/useAdminUsers";        -> exports useAdminUserDetail(id)
    export * from "./hooks/useAdminUserDetail";   -> ALSO exports useAdminUserDetail(id)

    export * from "./hooks/useAdminSupport";      -> exports useAdminTicketDetail(id)
    export * from "./hooks/useAdminTicketDetail"; -> ALSO exports useAdminTicketDetail(id)

  Two different functions share the same exported name in each pair. With
  typescript.ignoreBuildErrors now set to false, `pnpm build` will fail with
  "Module ... has already exported a member named 'useAdminUserDetail'".

WHAT THIS SCRIPT DOES (safe, automated):
  [1] Backs up every file it touches to .fix-backups\<timestamp>\
  [2] Renames the function declared in hooks\useAdminUserDetail.ts from
      useAdminUserDetail  ->  useAdminUserDetailPage
  [3] Renames the function declared in hooks\useAdminTicketDetail.ts from
      useAdminTicketDetail  ->  useAdminTicketDetailPage
  [4] Leaves hooks\useAdminUsers.ts and hooks\useAdminSupport.ts completely
      untouched -- their useAdminUserDetail(id) / useAdminTicketDetail(id)
      (the simple list-page versions) keep their original names.
  [5] Scans the rest of the repo (apps\web, apps\admin, packages) for any
      call sites that reference useAdminUserDetail( or useAdminTicketDetail(
      OUTSIDE of the four hook files above, and lists them -- these are the
      places where YOU need to decide (based on context) whether the call
      site wants the list-hook version (unchanged name) or the detail-page
      version (needs `Page` appended). This step never edits files, only
      reports, because the script cannot infer intent from a plain-text scan.

WHAT THIS SCRIPT DELIBERATELY DOES NOT DO:
  - Does not touch packages/api-client/src/index.ts (no change needed there
    once the two names differ -- both `export *` lines are still valid).
  - Does not guess which call sites meant the list-hook vs. the detail-hook.
    Renaming those wrongly would silently swap correct behavior for wrong
    behavior, which is worse than leaving it for a quick manual check.
================================================================================
#>

[CmdletBinding()]
param(
    [string]$RepoRoot = (Get-Location).Path,
    [switch]$WhatIfOnly
)

$ErrorActionPreference = "Stop"
$timestamp  = Get-Date -Format "yyyyMMdd-HHmmss"
$backupRoot = Join-Path $RepoRoot ".fix-backups\$timestamp"
$apiClientHooksDir = Join-Path $RepoRoot "packages\api-client\src\hooks"

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "==== $Title ====" -ForegroundColor Cyan
}

# Same wrapper as Fix-SAI2-Issues.ps1 -- avoids PowerShell's wildcard parser
# choking on [slug]/[id]-style bracket folder names elsewhere in the repo.
function New-DirSafe {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return }
    [System.IO.Directory]::CreateDirectory($Path) | Out-Null
}

function Backup-File {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return }
    $relative = $Path.Substring($RepoRoot.Length).TrimStart('\')
    $dest = Join-Path $backupRoot $relative
    New-DirSafe -Path (Split-Path $dest)
    Copy-Item -LiteralPath $Path -Destination $dest -Force
}

if (-not (Test-Path -LiteralPath $apiClientHooksDir)) {
    Write-Host "Could not find packages\api-client\src\hooks under '$RepoRoot'." -ForegroundColor Red
    Write-Host "Run this script from the SAI2 repo root." -ForegroundColor Red
    exit 1
}

New-DirSafe -Path $backupRoot
Write-Host "Backups will be written to: $backupRoot" -ForegroundColor DarkGray

# ------------------------------------------------------------------------------
# [1] Rename useAdminUserDetail -> useAdminUserDetailPage in its own file
# ------------------------------------------------------------------------------
Write-Section "1. Renaming useAdminUserDetail -> useAdminUserDetailPage"

$userDetailPath = Join-Path $apiClientHooksDir "useAdminUserDetail.ts"

if (Test-Path -LiteralPath $userDetailPath) {
    $content = Get-Content -Raw -LiteralPath $userDetailPath
    $original = $content

    # Whole-word match only, so we never touch unrelated identifiers like
    # useAdminUserDetailXyz or comments mentioning something else.
    $content = [regex]::Replace($content, '\buseAdminUserDetail\b', 'useAdminUserDetailPage')

    if ($content -ne $original) {
        $occurrences = ([regex]::Matches($original, '\buseAdminUserDetail\b')).Count
        if (-not $WhatIfOnly) {
            Backup-File -Path $userDetailPath
            [System.IO.File]::WriteAllText($userDetailPath, $content, [System.Text.UTF8Encoding]::new($false))
        }
        Write-Host "  Renamed $occurrences occurrence(s) in hooks\useAdminUserDetail.ts" -ForegroundColor Green
    } else {
        Write-Host "  No occurrences of 'useAdminUserDetail' found -- already renamed or file changed shape. Check manually." -ForegroundColor DarkYellow
    }
} else {
    Write-Host "  hooks\useAdminUserDetail.ts not found -- skipped." -ForegroundColor DarkYellow
}

# ------------------------------------------------------------------------------
# [2] Rename useAdminTicketDetail -> useAdminTicketDetailPage in its own file
# ------------------------------------------------------------------------------
Write-Section "2. Renaming useAdminTicketDetail -> useAdminTicketDetailPage"

$ticketDetailPath = Join-Path $apiClientHooksDir "useAdminTicketDetail.ts"

if (Test-Path -LiteralPath $ticketDetailPath) {
    $content = Get-Content -Raw -LiteralPath $ticketDetailPath
    $original = $content

    $content = [regex]::Replace($content, '\buseAdminTicketDetail\b', 'useAdminTicketDetailPage')

    if ($content -ne $original) {
        $occurrences = ([regex]::Matches($original, '\buseAdminTicketDetail\b')).Count
        if (-not $WhatIfOnly) {
            Backup-File -Path $ticketDetailPath
            [System.IO.File]::WriteAllText($ticketDetailPath, $content, [System.Text.UTF8Encoding]::new($false))
        }
        Write-Host "  Renamed $occurrences occurrence(s) in hooks\useAdminTicketDetail.ts" -ForegroundColor Green
    } else {
        Write-Host "  No occurrences of 'useAdminTicketDetail' found -- already renamed or file changed shape. Check manually." -ForegroundColor DarkYellow
    }
} else {
    Write-Host "  hooks\useAdminTicketDetail.ts not found -- skipped." -ForegroundColor DarkYellow
}

# ------------------------------------------------------------------------------
# [3] Confirm index.ts still exports both -- no edit needed, just a sanity note
# ------------------------------------------------------------------------------
Write-Section "3. Checking packages\api-client\src\index.ts"

$indexPath = Join-Path $RepoRoot "packages\api-client\src\index.ts"
if (Test-Path -LiteralPath $indexPath) {
    $indexContent = Get-Content -Raw -LiteralPath $indexPath
    $hasUserDetailExport = $indexContent -match [regex]::Escape('export * from "./hooks/useAdminUserDetail"')
    $hasTicketDetailExport = $indexContent -match [regex]::Escape('export * from "./hooks/useAdminTicketDetail"')

    if ($hasUserDetailExport -and $hasTicketDetailExport) {
        Write-Host "  Both 'export *' lines are present and need NO changes -- the collision" -ForegroundColor DarkGray
        Write-Host "  is resolved purely by the two functions now having different names." -ForegroundColor DarkGray
    } else {
        Write-Host "  Could not confirm both export lines in index.ts -- check manually." -ForegroundColor DarkYellow
    }
} else {
    Write-Host "  packages\api-client\src\index.ts not found -- skipped." -ForegroundColor DarkYellow
}

# ------------------------------------------------------------------------------
# [4] Report other call sites that may need manual review
# ------------------------------------------------------------------------------
Write-Section "4. Scanning for call sites that may need manual review"

$scanRoots = @(
    (Join-Path $RepoRoot "apps"),
    (Join-Path $RepoRoot "packages")
) | Where-Object { Test-Path -LiteralPath $_ }

$excludeFiles = @(
    (Join-Path $RepoRoot "packages\api-client\src\hooks\useAdminUserDetail.ts"),
    (Join-Path $RepoRoot "packages\api-client\src\hooks\useAdminTicketDetail.ts"),
    (Join-Path $RepoRoot "packages\api-client\src\hooks\useAdminUsers.ts"),
    (Join-Path $RepoRoot "packages\api-client\src\hooks\useAdminSupport.ts")
)

$pattern = 'useAdminUserDetail\(|useAdminTicketDetail\('
$hits = @()

if ($scanRoots.Count -gt 0) {
    Get-ChildItem -Path $scanRoots -Recurse -Include "*.ts", "*.tsx" -File -ErrorAction SilentlyContinue |
        Where-Object {
            $_.FullName -notmatch '\\node_modules\\' -and
            ($excludeFiles -notcontains $_.FullName)
        } |
        ForEach-Object {
            try {
                $lines = Get-Content -LiteralPath $_.FullName -ErrorAction Stop
            } catch {
                return
            }
            for ($i = 0; $i -lt $lines.Count; $i++) {
                if ($lines[$i] -match $pattern) {
                    $relPath = $_.FullName.Substring($RepoRoot.Length).TrimStart('\')
                    $hits += [PSCustomObject]@{
                        File = $relPath
                        Line = $i + 1
                        Text = $lines[$i].Trim()
                    }
                }
            }
        }
}

if ($hits.Count -eq 0) {
    Write-Host "  No call sites found outside the hook files themselves." -ForegroundColor DarkGray
    Write-Host "  (This can happen if the admin UI pages that call these hooks haven't" -ForegroundColor DarkGray
    Write-Host "  been generated/committed yet.)" -ForegroundColor DarkGray
} else {
    Write-Host "  Found $($hits.Count) call site(s). For EACH one below, decide:" -ForegroundColor Yellow
    Write-Host "    - If it's on a LIST page (e.g. a users table, a tickets table)," -ForegroundColor Yellow
    Write-Host "      it almost certainly means the version in useAdminUsers.ts /" -ForegroundColor Yellow
    Write-Host "      useAdminSupport.ts -- leave the call as-is." -ForegroundColor Yellow
    Write-Host "    - If it's on a DETAIL page (e.g. a single user's profile route," -ForegroundColor Yellow
    Write-Host "      a single ticket's thread view), it means the renamed version --" -ForegroundColor Yellow
    Write-Host "      change the call to useAdminUserDetailPage(...) or" -ForegroundColor Yellow
    Write-Host "      useAdminTicketDetailPage(...) respectively." -ForegroundColor Yellow
    Write-Host ""
    $hits | ForEach-Object {
        Write-Host ("  {0}:{1}" -f $_.File, $_.Line) -ForegroundColor DarkYellow
        Write-Host ("      {0}" -f $_.Text) -ForegroundColor Gray
    }
}

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------
Write-Section "Done"
if ($WhatIfOnly) {
    Write-Host "Ran in -WhatIfOnly mode -- no files were changed. Re-run without -WhatIfOnly to apply." -ForegroundColor Magenta
} else {
    Write-Host "Backups of every changed file are in: $backupRoot" -ForegroundColor Green
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Review the call-site list in section 4 above (if any) and update" -ForegroundColor White
    Write-Host "     detail-page calls to use the 'Page' suffixed hook name." -ForegroundColor White
    Write-Host "  2. Run: pnpm --filter @saachi/api-client run type-check (if that script" -ForegroundColor White
    Write-Host "     exists) or just: pnpm --filter web run build -- to confirm the" -ForegroundColor White
    Write-Host "     'already exported a member named ...' error is gone." -ForegroundColor White
    Write-Host "  3. Move on to Step 2: wiring login/register forms to useLogin()/useRegister()." -ForegroundColor White
}