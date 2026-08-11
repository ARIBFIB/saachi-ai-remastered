<#
================================================================================
  create-email-verified-page.ps1
  Scaffolds the "Email Verified" confirmation page for apps/web (SAI2).

  Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2

  Notes:
  - Transactional flow: no Header/Footer, matching the "Forgot Password"
    page's convention.
  - Colors use CSS variables from lib/design-system/tokens.ts. The two
    background blobs use --token-color-primaryTint and --token-color-
    successTint (both already in tokens.ts) instead of new hardcoded hues.
================================================================================
#>

$ErrorActionPreference = "Stop"

$webRoot = Join-Path $PSScriptRoot "apps\web"
if (-not (Test-Path $webRoot)) {
    Write-Error "Could not find apps\web under $PSScriptRoot. Run this script from the SAI2 repo root."
}

function New-Dir($path) {
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}

function Write-File($path, [string]$content) {
    New-Dir (Split-Path $path -Parent)
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
    Write-Host "  [written] $path"
}

Write-Host "`nScaffolding Email Verified page..." -ForegroundColor Cyan

# ------------------------------------------------------------------------
# app/(auth)/verify-email/page.tsx
# ------------------------------------------------------------------------
$emailVerifiedPage = @'
import Link from "next/link";
import { Check, ArrowRight } from "lucide-react";

export default function EmailVerifiedPage() {
  return (
    <div className="relative flex min-h-screen items-center justify-center overflow-hidden bg-[var(--token-color-surface)] p-12">
      <div
        className="pointer-events-none absolute -left-32 -top-60 h-[640px] w-[640px] rounded-full opacity-20 blur-[50px]"
        style={{ backgroundColor: "var(--token-color-primaryTint)" }}
      />
      <div
        className="pointer-events-none absolute -right-32 bottom-0 h-[768px] w-[768px] rounded-full opacity-10 blur-3xl"
        style={{ backgroundColor: "var(--token-color-successTint)" }}
      />

      <div className="relative flex w-96 max-w-96 flex-col items-center gap-6 rounded-2xl border border-[var(--token-color-border)] bg-[var(--token-color-surface)] p-10 shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
        <span className="relative flex h-20 w-20 items-center justify-center rounded-full bg-[var(--token-color-success)]/10">
          <Check className="h-9 w-9 text-[var(--token-color-success)]" strokeWidth={3} />
          <span className="absolute inset-0 rounded-full border-4 border-[var(--token-color-success)] opacity-20" />
        </span>

        <div className="flex flex-col items-center gap-2 text-center">
          <h1 className="text-3xl font-bold text-[var(--token-color-ink)]">Email Verified</h1>
          <p className="max-w-72 text-base leading-6 text-gray-700">
            Your email address has been successfully confirmed. You now have full access to Saachi AI.
          </p>
        </div>

        <Link
          href="/dashboard"
          className="flex w-full items-center justify-center gap-2 rounded-lg bg-[var(--token-color-primary)] px-6 py-4 text-sm font-semibold tracking-wide text-white shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)] hover:bg-[var(--token-color-primaryHover)]"
        >
          Continue to Dashboard
          <ArrowRight className="h-3 w-3" />
        </Link>
      </div>
    </div>
  );
}
'@
Write-File (Join-Path $webRoot "app\(auth)\verify-email\page.tsx") $emailVerifiedPage

Write-Host "`nDone. Email Verified page scaffolded at:" -ForegroundColor Green
Write-Host "  apps\web\app\(auth)\verify-email\page.tsx"
Write-Host "`nVisit /verify-email after running 'pnpm --filter web dev'.`n"