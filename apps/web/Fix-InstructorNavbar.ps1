# Fix-InstructorNavbar.ps1
# Run this from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2\apps\web
# It creates a ConditionalChrome wrapper and updates root layout.tsx so that
# SiteHeader/SiteFooter do NOT render on /instructor routes (InstructorShell
# already provides its own top bar there), fixing the double-navbar issue.

$ErrorActionPreference = "Stop"

$appDir = Join-Path (Get-Location) "app"
if (-not (Test-Path $appDir)) {
    Write-Error "Could not find '.\app' folder. Run this script from the 'apps\web' directory."
    exit 1
}

# 1. Create the ConditionalChrome component
$componentPath = Join-Path $appDir "_components\ConditionalChrome.tsx"
$componentContent = @'
"use client";

import { usePathname } from "next/navigation";
import type { ReactNode } from "react";
import { SiteHeader } from "./SiteHeader";
import { SiteFooter } from "./SiteFooter";

// Routes that render their own header/shell (e.g. InstructorShell) and
// should NOT also get the public SiteHeader/SiteFooter.
const CHROME_EXCLUDED_PREFIXES = ["/instructor"];

export function ConditionalChrome({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const hideChrome = CHROME_EXCLUDED_PREFIXES.some((prefix) => pathname?.startsWith(prefix));

  if (hideChrome) {
    return <>{children}</>;
  }

  return (
    <>
      <SiteHeader />
      <main>{children}</main>
      <SiteFooter />
    </>
  );
}
'@

Set-Content -Path $componentPath -Value $componentContent -Encoding UTF8
Write-Host "Created: $componentPath"

# 2. Rewrite root layout.tsx to use ConditionalChrome
$layoutPath = Join-Path $appDir "layout.tsx"
$layoutContent = @'
import type { Metadata } from "next";
import type { ReactNode } from "react";
import "./globals.css";
import { Providers } from "./providers";
import { ConditionalChrome } from "./_components/ConditionalChrome";

export const metadata: Metadata = {
  title: "Saachi AI \u2014 Learn practical AI skills",
  description: "A skills exchange for the AI era. Learn practical AI application skills and sell what you know."
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen bg-paper text-ink antialiased">
        <Providers>
          <ConditionalChrome>{children}</ConditionalChrome>
        </Providers>
      </body>
    </html>
  );
}
'@

Set-Content -Path $layoutPath -Value $layoutContent -Encoding UTF8
Write-Host "Updated: $layoutPath"

Write-Host ""
Write-Host "Done. Restart your dev server (npm run dev) to see the fix."
Write-Host "The instructor dashboard should now show only ONE top bar."