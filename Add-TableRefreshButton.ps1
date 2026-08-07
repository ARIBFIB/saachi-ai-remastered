<#
  Add-TableRefreshButton.ps1
  1) Creates a shared <RefreshButton /> component in packages/ui (spins on click,
     invalidates TanStack Query cache so all tables refetch fresh data).
  2) Exports it from packages/ui index.
  3) Inserts the button into every admin page that renders a <DataTable>.

  Usage:
    PS D:\...\SAI2> .\Add-TableRefreshButton.ps1
#>

param(
    [string]$ProjectRoot = (Get-Location).Path
)

$uiSrc      = Join-Path $ProjectRoot "packages\ui\src"
$adminApp   = Join-Path $ProjectRoot "apps\admin\app\(console)"

if (-not (Test-Path $uiSrc)) {
    Write-Host "ERROR: packages\ui\src not found at -> $uiSrc" -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------------------------
# 1) Create RefreshButton.tsx
# ---------------------------------------------------------------------------
$refreshComponentPath = Join-Path $uiSrc "RefreshButton.tsx"

$refreshComponentCode = @'
"use client";

import { useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { RotateCw } from "lucide-react";

type RefreshButtonProps = {
  className?: string;
  title?: string;
};

export function RefreshButton({ className = "", title = "Refresh" }: RefreshButtonProps) {
  const queryClient = useQueryClient();
  const [spinning, setSpinning] = useState(false);

  const handleRefresh = async () => {
    if (spinning) return;
    setSpinning(true);
    await queryClient.invalidateQueries();
    window.setTimeout(() => setSpinning(false), 500);
  };

  return (
    <button
      type="button"
      onClick={handleRefresh}
      title={title}
      aria-label={title}
      className={`flex h-9 w-9 shrink-0 items-center justify-center rounded-control border border-line text-ink-soft transition-colors duration-150 ease-out hover:border-line-strong hover:text-ink ${className}`}
    >
      <RotateCw size={15} strokeWidth={1.75} className={spinning ? "animate-spin" : ""} />
    </button>
  );
}
'@

if (-not (Test-Path $refreshComponentPath)) {
    Set-Content -LiteralPath $refreshComponentPath -Value $refreshComponentCode -NoNewline
    Write-Host "[OK] Created $refreshComponentPath" -ForegroundColor Green
} else {
    Write-Host "[SKIP] RefreshButton.tsx already exists." -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# 2) Export it from packages/ui index (index.ts or index.tsx)
# ---------------------------------------------------------------------------
$indexTs  = Join-Path $uiSrc "index.ts"
$indexTsx = Join-Path $uiSrc "index.tsx"
$indexFile = $null
if (Test-Path $indexTs) { $indexFile = $indexTs }
elseif (Test-Path $indexTsx) { $indexFile = $indexTsx }

if ($indexFile) {
    $indexContent = Get-Content -Raw -LiteralPath $indexFile
    if ($indexContent -notmatch 'RefreshButton') {
        Add-Content -LiteralPath $indexFile -Value "`nexport * from `"./RefreshButton`";"
        Write-Host "[OK] Exported RefreshButton from $indexFile" -ForegroundColor Green
    } else {
        Write-Host "[SKIP] RefreshButton already exported." -ForegroundColor Yellow
    }
} else {
    Write-Host "[WARN] Could not find packages\ui\src\index.ts(x) - export it manually:" -ForegroundColor Yellow
    Write-Host '        export * from "./RefreshButton";'
}

# ---------------------------------------------------------------------------
# 3) Patch admin pages that use <DataTable ... /> to include <RefreshButton />
# ---------------------------------------------------------------------------
$targetFiles = @(
    "courses\catalog\page.tsx",
    "finance\transactions\page.tsx",
    "logs\audit\page.tsx",
    "dashboard\activity\page.tsx",
    "support\tickets\page.tsx",
    "users\page.tsx",
    "moderation\reviews\page.tsx",
    "moderation\forum\page.tsx",
    "marketing\coupons\page.tsx",
    "marketing\banners\page.tsx"
)

$patchedCount = 0
$skippedCount = 0

foreach ($rel in $targetFiles) {
    $filePath = Join-Path $adminApp $rel
    if (-not (Test-Path $filePath)) {
        Write-Host "[MISS] $rel not found, skipping." -ForegroundColor DarkYellow
        continue
    }

    $code = Get-Content -Raw -LiteralPath $filePath

    if ($code -match "RefreshButton") {
        Write-Host "[SKIP] $rel already has RefreshButton." -ForegroundColor Yellow
        $skippedCount++
        continue
    }

    Copy-Item $filePath "$filePath.bak" -Force

    # a) Add RefreshButton to the @saachi/ui import list
    if ($code -match 'from\s+"@saachi/ui"') {
        $code = [regex]::Replace(
            $code,
            'import\s*\{([^}]*)\}\s*from\s*"@saachi/ui";',
            {
                param($m)
                $imports = $m.Groups[1].Value
                if ($imports -match '\bRefreshButton\b') { return $m.Value }
                return "import {$imports, RefreshButton } from `"@saachi/ui`";"
            },
            1
        )
    }

    # b) Insert <RefreshButton /> right after the opening <main ...> header title block.
    #    Anchor: the closing "</div>" that ends the "flex items-center gap-3" title row,
    #    just before "<Button" (if any) or before the next sibling element.
    #    Safest generic anchor: insert right before the first <DataTable
    if ($code -match "<DataTable") {
        $code = [regex]::Replace(
            $code,
            '(\n\s*<DataTable)',
            "`n      <div className=`"mb-3 flex justify-end`"><RefreshButton /></div>`$1",
            1
        )
        Set-Content -LiteralPath $filePath -Value $code -NoNewline
        Write-Host "[OK] Patched $rel" -ForegroundColor Green
        $patchedCount++
    } else {
        Write-Host "[WARN] $rel - <DataTable not found, skipped insert." -ForegroundColor DarkYellow
    }
}

Write-Host ""
Write-Host "Done. Patched: $patchedCount | Already had it: $skippedCount" -ForegroundColor Cyan
Write-Host "Restart your dev server to see the refresh icons." -ForegroundColor Cyan