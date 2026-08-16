# update-glass-cta-3d.ps1
# Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2

$ErrorActionPreference = "Stop"

$webRoot = Join-Path $PSScriptRoot "apps\web"
$uiDir   = Join-Path $webRoot "components\ui"
$glassCtaPath = Join-Path $uiDir "glass-cta.tsx"

if (-not (Test-Path $uiDir)) {
    Write-Error "components/ui folder not found at $uiDir. Run apply-glass-cta.ps1 first."
}

# Backup existing glass-cta.tsx if present
if (Test-Path $glassCtaPath) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    Copy-Item -Path $glassCtaPath -Destination "$glassCtaPath.bak-$timestamp" -Force
    Write-Host "Backed up existing glass-cta.tsx" -ForegroundColor Yellow
}

$glassCtaContent = @'
"use client";

import * as React from "react";
import Link from "next/link";
import { ShieldCheck, Sparkles, ArrowRight } from "lucide-react";

export interface GlassCtaProps extends React.HTMLAttributes<HTMLDivElement> {}

const GlassCta = React.forwardRef<HTMLDivElement, GlassCtaProps>(
  ({ className, ...props }, ref) => {
    return (
      <div
        ref={ref}
        className={`group w-full [perspective:1400px] ${className ?? ""}`}
        {...props}
      >
        <div
          className="relative overflow-hidden rounded-[40px] border border-black/5 bg-gradient-to-br from-white to-zinc-100 p-10 text-center shadow-2xl transition-all duration-500 ease-in-out [transform-style:preserve-3d] dark:border-white/5 dark:from-zinc-900 dark:to-black md:p-16 group-hover:[box-shadow:rgba(0,0,0,0.35)_30px_60px_40px_-40px,rgba(0,0,0,0.12)_0px_25px_30px_0px] group-hover:[transform:rotate3d(1,1,0,3deg)]"
        >
          {/* glass inset layer */}
          <div className="pointer-events-none absolute inset-2 rounded-[34px] border-b border-l border-black/10 bg-gradient-to-b from-black/[0.03] to-transparent backdrop-blur-sm [transform-style:preserve-3d] [transform:translate3d(0,0,20px)] dark:border-white/10 dark:from-white/10 dark:to-white/0" />

          {/* floating depth circles, top-right */}
          <div className="pointer-events-none absolute -right-16 -top-16 [transform-style:preserve-3d]">
            {[
              { size: "280px", z: "10px", delay: "0s" },
              { size: "220px", z: "35px", delay: "0.25s" },
              { size: "160px", z: "60px", delay: "0.5s" },
              { size: "100px", z: "85px", delay: "0.75s" }
            ].map((circle, index) => (
              <div
                key={index}
                className="absolute aspect-square rounded-full bg-accent-violet/10 shadow-[rgba(124,58,237,0.25)_-10px_10px_40px_0px] transition-all duration-500 ease-in-out dark:bg-white/5"
                style={{
                  width: circle.size,
                  top: "0px",
                  right: "0px",
                  transform: `translate3d(0, 0, ${circle.z})`,
                  transitionDelay: circle.delay
                }}
              />
            ))}
          </div>

          {/* badge, top-right, pops out further on hover */}
          <div
            className="absolute grid aspect-square w-[54px] place-content-center rounded-full bg-ink shadow-[rgba(0,0,0,0.25)_-10px_10px_20px_0px] transition-all duration-500 ease-in-out [transform:translate3d(0,0,90px)] [transition-delay:0.9s] group-hover:[transform:translate3d(0,0,115px)] dark:bg-white"
            style={{ top: "28px", right: "28px" }}
          >
            <ShieldCheck size={22} className="text-white dark:text-ink" strokeWidth={2} />
          </div>

          {/* main content layer */}
          <div className="relative z-10 flex flex-col items-center [transform:translate3d(0,0,30px)]">
            <span className="mb-4 inline-flex items-center gap-1.5 rounded-full border border-black/10 bg-black/[0.03] px-3.5 py-1.5 text-[12px] font-semibold text-ink/70 backdrop-blur-sm dark:border-white/15 dark:bg-white/5 dark:text-white/70">
              <Sparkles size={13} className="text-accent-violet dark:text-white/80" />
              7-day refund - zero risk
            </span>

            <h2 className="font-display text-[26px] font-bold text-ink md:text-[36px] dark:text-white">
              Your next skill is one course away.
            </h2>
            <p className="mx-auto mt-3 max-w-lg text-[14.5px] text-ink-soft md:text-[15.5px] dark:text-white/70">
              Join 42,000+ learners already building real AI projects with Saachi AI. Practical courses, verified certificates, real results.
            </p>

            <div className="mt-8 flex flex-wrap items-center justify-center gap-3 [transform-style:preserve-3d]">
              <Link href="/courses" className="group/btn [transform-style:preserve-3d]">
                <button
                  className="flex items-center gap-2 rounded-full bg-ink px-6 py-3 text-[14px] font-semibold text-white shadow-[rgba(0,0,0,0.3)_0px_10px_20px_-8px] transition-all duration-200 ease-in-out group-hover/btn:[transform:translate3d(0,0,25px)] dark:bg-white dark:text-ink"
                >
                  Start learning free
                  <ArrowRight size={15} className="transition-transform duration-200 ease-out group-hover/btn:translate-x-0.5" />
                </button>
              </Link>
              <Link href="/register" className="group/btn [transform-style:preserve-3d]">
                <button
                  className="rounded-full border border-black/15 bg-transparent px-6 py-3 text-[14px] font-semibold text-ink transition-all duration-200 ease-in-out hover:bg-black/[0.03] group-hover/btn:[transform:translate3d(0,0,20px)] dark:border-white/25 dark:text-white dark:hover:bg-white/10"
                >
                  Become an instructor
                </button>
              </Link>
            </div>
          </div>
        </div>
      </div>
    );
  }
);

GlassCta.displayName = "GlassCta";

export default GlassCta;
'@

Set-Content -Path $glassCtaPath -Value $glassCtaContent -Encoding UTF8
Write-Host "Updated: $glassCtaPath" -ForegroundColor Green

# Verify
$content = Get-Content -Path $glassCtaPath -Raw
$hasRotate3d = $content.Contains('rotate3d')
$hasDarkVariant = $content.Contains('dark:')
$hasBadge = $content.Contains('ShieldCheck size={22}')

Write-Host ""
Write-Host "----- Verification -----"
Write-Host ("3D tilt/hover effect present: " + ($(if ($hasRotate3d) { "YES" } else { "NO" })))
Write-Host ("Light/dark mode variants:      " + ($(if ($hasDarkVariant) { "YES" } else { "NO" })))
Write-Host ("Badge/logo added:              " + ($(if ($hasBadge) { "YES" } else { "NO" })))

if ($hasRotate3d -and $hasDarkVariant -and $hasBadge) {
    Write-Host ""
    Write-Host "All changes applied successfully." -ForegroundColor Green
} else {
    Write-Warning "Something may not have applied correctly - review the file manually."
}

Write-Host ""
Write-Host "Now run:" -ForegroundColor Cyan
Write-Host "  cd `"$webRoot`""
Write-Host "  npm run dev"