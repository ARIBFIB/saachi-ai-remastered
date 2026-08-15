# Fix-ThemeSync.ps1
# Run this from: SAI2 root

$ErrorActionPreference = "Stop"

$webRoot        = Join-Path $PSScriptRoot "apps\web"
$providersFile  = Join-Path $webRoot "app\providers.tsx"
$headerFile     = Join-Path $webRoot "app\_components\SiteHeader.tsx"

function Backup-Once($path) {
    $ts = Get-Date -Format "yyyyMMdd-HHmmss"
    Copy-Item -Path $path -Destination "$path.bak-$ts" -Force
    Write-Host "Backed up: $path.bak-$ts" -ForegroundColor Yellow
}

# ==================================================================
# 1. providers.tsx - central theme -> data-theme sync (fixes dark mode)
# ==================================================================
if (-not (Test-Path $providersFile)) {
    Write-Host "ERROR: Could not find $providersFile" -ForegroundColor Red
    exit 1
}

$pcontent = Get-Content -Path $providersFile -Raw

if ($pcontent -match "ThemeSync") {
    Write-Host "providers.tsx already has ThemeSync, skipping." -ForegroundColor Yellow
} else {
    Backup-Once $providersFile

    $newProviders = @'
"use client";

import { useEffect, useState, type ReactNode } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { useThemeStore } from "@saachi/store";

function ThemeSync() {
  const theme = useThemeStore((s) => s.theme);

  useEffect(() => {
    document.documentElement.setAttribute("data-theme", theme);
  }, [theme]);

  return null;
}

export function Providers({ children }: { children: ReactNode }) {
  const [client] = useState(() => new QueryClient({
    defaultOptions: { queries: { staleTime: 30_000, refetchOnWindowFocus: false } }
  }));

  return (
    <QueryClientProvider client={client}>
      <ThemeSync />
      {children}
    </QueryClientProvider>
  );
}
'@

    Set-Content -Path $providersFile -Value $newProviders -Encoding UTF8 -NoNewline
    Write-Host "Patched: $providersFile (theme now syncs to <html data-theme> centrally)" -ForegroundColor Green
}

# ==================================================================
# 2. SiteHeader.tsx - ensure AnimatedThemeToggler is actually wired in
# ==================================================================
if (-not (Test-Path $headerFile)) {
    Write-Host "WARNING: SiteHeader.tsx not found, skipping." -ForegroundColor Yellow
} else {
    $hcontent = Get-Content -Path $headerFile -Raw

    if ($hcontent -match "AnimatedThemeToggler") {
        Write-Host "SiteHeader.tsx already references AnimatedThemeToggler." -ForegroundColor Yellow

        if ($hcontent -notmatch "<AnimatedThemeToggler") {
            Write-Host "WARNING: import exists but <AnimatedThemeToggler /> is not actually rendered anywhere in SiteHeader.tsx. Manual check needed." -ForegroundColor Red
        }
    } else {
        Backup-Once $headerFile

        # Add import at top, right after the first "use client" or first import line
        if ($hcontent -match '(?m)^"use client";\s*') {
            $hcontent = $hcontent -replace '(?m)^("use client";\s*)', "`$1`r`nimport { AnimatedThemeToggler } from `"@/components/ui/animated-theme-toggler`";`r`n"
        } else {
            $hcontent = "import { AnimatedThemeToggler } from `"@/components/ui/animated-theme-toggler`";`r`n" + $hcontent
        }

        # Try replacing an existing ThemeToggle usage
        if ($hcontent -match '<ThemeToggle\s*/?>') {
            $hcontent = $hcontent -replace '<ThemeToggle\s*/?>', '<AnimatedThemeToggler />'
            Write-Host "Replaced existing <ThemeToggle /> usage with <AnimatedThemeToggler />." -ForegroundColor Green
        }
        # Try inserting near the cart/wishlist icons row as a fallback
        elseif ($hcontent -match 'aria-label="Wishlist"') {
            $hcontent = $hcontent -replace '(\s*)(<Link\s*\r?\n\s*href="/wishlist")', "`$1<AnimatedThemeToggler />`$1`$2"
            Write-Host "Inserted <AnimatedThemeToggler /> before the Wishlist link (fallback placement)." -ForegroundColor Green
        } else {
            Write-Host "WARNING: could not find a safe insertion point in SiteHeader.tsx. Import was added but the button was NOT placed - please paste the current SiteHeader.tsx so I can patch it precisely." -ForegroundColor Red
        }

        Set-Content -Path $headerFile -Value $hcontent -Encoding UTF8 -NoNewline
        Write-Host "Patched: $headerFile" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "Done. Now run: cd apps\web; pnpm run build" -ForegroundColor DarkGray