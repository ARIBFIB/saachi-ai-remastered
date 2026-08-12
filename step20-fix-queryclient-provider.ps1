# ============================================================================
# step20-fix-queryclient-provider.ps1
#
# Fixes Vercel build error:
#   "Error occurred prerendering page /login"
#   "Error: No QueryClient set, use QueryClientProvider to set one"
#
# Root cause: useLogin/useRegister (TanStack Query hooks) are used on
# /login, but there is no <QueryClientProvider> wrapping the app, so
# Next.js crashes when it tries to prerender that page at build time.
#
# What this script does:
#   1. Creates apps/web/lib/query-provider.tsx (a client component that
#      sets up a QueryClient with useState, per TanStack Query's official
#      Next.js App Router recipe).
#   2. Prints out the CURRENT content of app/layout.tsx so we can see
#      exactly what's there (it was not in the original export, so we
#      can't blind-patch it safely).
#   3. Attempts an automatic patch IF it finds a recognizable pattern
#      (an AntdProvider wrapping {children}, since that's the only other
#      provider we know exists). If it can't find a safe insertion point,
#      it prints manual instructions instead of guessing.
#
# Run from SAI2 repo root:
#   PS D:\...\SAI2> .\step20-fix-queryclient-provider.ps1
# ============================================================================

$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
$webRoot = Join-Path $root "apps\web"
$libDir = Join-Path $webRoot "lib"
$queryProviderPath = Join-Path $libDir "query-provider.tsx"
$layoutPath = Join-Path $webRoot "app\layout.tsx"

function Write-CodeFile {
    param([string]$Path, [string]$Content)
    $dir = Split-Path $Path -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

Write-Host ""
Write-Host "=== Step 1: Creating QueryProvider ===" -ForegroundColor Cyan
Write-Host ""

$queryProviderContent = @'
"use client";

import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

/**
 * Wraps the app with a TanStack Query QueryClient.
 *
 * IMPORTANT: the QueryClient is created inside useState so that each
 * request/browser session gets its own instance (avoids sharing cached
 * data across different users on the server, and avoids the
 * "No QueryClient set" error during Next.js static prerendering).
 *
 * See: https://tanstack.com/query/latest/docs/framework/react/guides/ssr#using-the-app-router
 */
export function QueryProvider({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 60 * 1000,
            refetchOnWindowFocus: false
          }
        }
      })
  );

  return <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>;
}
'@

if ([System.IO.File]::Exists($queryProviderPath)) {
    Write-Host "  [SKIP - already exists] lib\query-provider.tsx" -ForegroundColor Yellow
    Write-Host "        (delete it first if you want this script to regenerate it)" -ForegroundColor DarkGray
}
else {
    Write-CodeFile $queryProviderPath $queryProviderContent
    Write-Host "  [OK] lib\query-provider.tsx created" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Step 2: Inspecting app/layout.tsx ===" -ForegroundColor Cyan
Write-Host ""

if (-not [System.IO.File]::Exists($layoutPath)) {
    Write-Host "  [ERROR] app\layout.tsx not found at: $layoutPath" -ForegroundColor Red
    Write-Host "  Cannot auto-patch. Please locate your root layout manually." -ForegroundColor Red
    exit 1
}

$layoutContent = [System.IO.File]::ReadAllText($layoutPath)

Write-Host "--- Current app/layout.tsx content ---" -ForegroundColor DarkGray
Write-Host $layoutContent
Write-Host "--- End of file ---" -ForegroundColor DarkGray
Write-Host ""

if ($layoutContent -match "QueryProvider") {
    Write-Host "  [ALREADY OK] layout.tsx already references QueryProvider -- no patch needed." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "If the build STILL fails with the same error, the QueryProvider may be" -ForegroundColor Yellow
    Write-Host "wrapping in the wrong place, or a client component higher up is calling" -ForegroundColor Yellow
    Write-Host "useLogin/useRegister outside of it. Paste the layout.tsx content above" -ForegroundColor Yellow
    Write-Host "back to me and I'll pinpoint it." -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

# Try to auto-patch: look for the import block and the <AntdProvider> wrapper,
# since that's the only other provider we know exists in this codebase.
$importPattern = 'import\s*\{\s*AntdProvider\s*\}\s*from\s*"[^"]*design-system[^"]*";'
$antdOpenPattern = '<AntdProvider>'

if ($layoutContent -match $importPattern -and $layoutContent -match $antdOpenPattern) {
    Write-Host "  Found AntdProvider import + usage -- attempting auto-patch..." -ForegroundColor Cyan

    $newImportLine = ($layoutContent | Select-String $importPattern).Matches[0].Value + "`nimport { QueryProvider } from `"@/lib/query-provider`";"
    $patched = $layoutContent -replace $importPattern, [regex]::Escape($newImportLine) -replace '\\', ''

    # The regex escape trick above is fragile across PS versions -- do it more
    # simply with plain string replace instead:
    $importMatch = ($layoutContent | Select-String $importPattern).Matches[0].Value
    $patched = $layoutContent.Replace(
        $importMatch,
        $importMatch + "`nimport { QueryProvider } from `"@/lib/query-provider`";"
    )
    $patched = $patched.Replace("<AntdProvider>", "<QueryProvider>`n        <AntdProvider>")
    $patched = $patched.Replace("</AntdProvider>", "</AntdProvider>`n      </QueryProvider>")

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($layoutPath, $patched, $utf8NoBom)

    Write-Host "  [OK] layout.tsx patched -- QueryProvider now wraps AntdProvider" -ForegroundColor Green
    Write-Host ""
    Write-Host "--- New layout.tsx content ---" -ForegroundColor DarkGray
    Write-Host $patched
    Write-Host "--- End of file ---" -ForegroundColor DarkGray
}
else {
    Write-Host "  [MANUAL PATCH NEEDED]" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Could not find a recognizable <AntdProvider> wrapper to attach to." -ForegroundColor Yellow
    Write-Host "  Please open apps\web\app\layout.tsx yourself and:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host '    1. Add near the top:' -ForegroundColor Yellow
    Write-Host '         import { QueryProvider } from "@/lib/query-provider";' -ForegroundColor White
    Write-Host ""
    Write-Host '    2. Wrap whatever is inside <body> with it, e.g.:' -ForegroundColor Yellow
    Write-Host '         <body>' -ForegroundColor White
    Write-Host '           <QueryProvider>' -ForegroundColor White
    Write-Host '             {/* ...existing providers/children... */}' -ForegroundColor White
    Write-Host '           </QueryProvider>' -ForegroundColor White
    Write-Host '         </body>' -ForegroundColor White
    Write-Host ""
    Write-Host "  Paste the file content back to me if you'd rather I do it precisely." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Now run:" -ForegroundColor Yellow
Write-Host "  cd apps\web"
Write-Host "  pnpm run build"
Write-Host ""