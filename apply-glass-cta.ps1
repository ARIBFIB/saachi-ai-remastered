# apply-glass-cta.ps1 (fixed)
# Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2

$ErrorActionPreference = "Stop"

$webRoot  = Join-Path $PSScriptRoot "apps\web"
$uiDir    = Join-Path $webRoot "components\ui"
$pagePath = Join-Path $webRoot "app\(marketing)\page.tsx"

if (-not (Test-Path $pagePath)) {
    Write-Error "page.tsx not found at $pagePath. Run this script from the SAI2 root folder."
}

if (-not (Test-Path $uiDir)) {
    New-Item -ItemType Directory -Path $uiDir -Force | Out-Null
}

# ---------------------------------------------------------------------------
# 1. Create components/ui/glass-cta.tsx
# ---------------------------------------------------------------------------
$glassCtaPath = Join-Path $uiDir "glass-cta.tsx"

$glassCtaContent = @'
"use client";

import * as React from "react";
import Link from "next/link";
import { ShieldCheck } from "lucide-react";

export interface GlassCtaProps extends React.HTMLAttributes<HTMLDivElement> {}

const GlassCta = React.forwardRef<HTMLDivElement, GlassCtaProps>(
  ({ className, ...props }, ref) => {
    return (
      <div
        ref={ref}
        className={`group relative w-full [perspective:1200px] ${className ?? ""}`}
        {...props}
      >
        <div className="relative overflow-hidden rounded-[40px] bg-gradient-to-br from-zinc-900 to-black p-10 text-center shadow-2xl transition-all duration-500 ease-in-out [transform-style:preserve-3d] md:p-16 group-hover:[box-shadow:rgba(0,0,0,0.35)_30px_50px_35px_-40px,rgba(0,0,0,0.15)_0px_25px_30px_0px] group-hover:[transform:rotate3d(1,1,0,4deg)]">
          <div className="pointer-events-none absolute inset-2 rounded-[34px] border-b border-l border-white/10 bg-gradient-to-b from-white/10 to-white/0 backdrop-blur-sm [transform-style:preserve-3d] [transform:translate3d(0,0,15px)]" />

          <div className="pointer-events-none absolute -right-16 -top-16 [transform-style:preserve-3d]">
            {[
              { size: "260px", z: "10px", delay: "0s" },
              { size: "200px", z: "30px", delay: "0.3s" },
              { size: "140px", z: "50px", delay: "0.6s" }
            ].map((circle, index) => (
              <div
                key={index}
                className="absolute aspect-square rounded-full bg-white/5 shadow-[rgba(124,58,237,0.25)_-10px_10px_40px_0px] transition-all duration-500 ease-in-out"
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

          <div className="relative z-10 flex flex-col items-center [transform:translate3d(0,0,26px)]">
            <ShieldCheck size={28} className="mb-4 text-white/90" />
            <h2 className="font-display text-[26px] font-bold text-white md:text-[34px]">
              Your next skill is one course away.
            </h2>
            <p className="mx-auto mt-3 max-w-lg text-[14.5px] text-white/70">
              Join 42,000+ learners already building real AI projects. 7-day refund window, no risk.
            </p>
            <div className="mt-7 flex flex-wrap items-center justify-center gap-3">
              <Link href="/courses">
                <button className="rounded-full bg-white px-6 py-3 text-[14px] font-semibold text-black transition-transform hover:scale-105">
                  Start learning free
                </button>
              </Link>
              <Link href="/register">
                <button className="rounded-full border border-white/25 px-6 py-3 text-[14px] font-semibold text-white transition-colors hover:bg-white/10">
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
Write-Host "Created/overwritten: $glassCtaPath" -ForegroundColor Green

# ---------------------------------------------------------------------------
# 2. Backup page.tsx before editing (only if not already backed up this run)
# ---------------------------------------------------------------------------
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = "$pagePath.bak-$timestamp"
Copy-Item -Path $pagePath -Destination $backupPath -Force
Write-Host "Backed up current page.tsx to: $backupPath" -ForegroundColor Yellow

# ---------------------------------------------------------------------------
# 3. Read page.tsx as string array
# ---------------------------------------------------------------------------
[string[]]$lines = Get-Content -Path $pagePath -Encoding UTF8

# 3a. Add the import line right after the GlobalVisitorsPanel import, if missing
$importAnchorText = 'import { GlobalVisitorsPanel } from "@/components/ui/global-visitors-panel";'
$importLine = 'import GlassCta from "@/components/ui/glass-cta";'

$fullText = [string]::Join("`n", $lines)
$alreadyHasImport = $fullText.Contains($importLine)

if (-not $alreadyHasImport) {
    $anchorIndex = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Trim() -eq $importAnchorText) {
            $anchorIndex = $i
            break
        }
    }
    if ($anchorIndex -ge 0) {
        $newLines = [System.Collections.Generic.List[string]]::new()
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $newLines.Add($lines[$i])
            if ($i -eq $anchorIndex) {
                $newLines.Add($importLine)
            }
        }
        [string[]]$lines = $newLines.ToArray()
        Write-Host "Import added after GlobalVisitorsPanel import." -ForegroundColor Green
    } else {
        Write-Warning "Import anchor line not found. Adding GlassCta import at the very top instead."
        $newLines = [System.Collections.Generic.List[string]]::new()
        $newLines.Add($importLine)
        foreach ($l in $lines) { $newLines.Add($l) }
        [string[]]$lines = $newLines.ToArray()
    }
} else {
    Write-Host "Import already present, skipping." -ForegroundColor Yellow
}

# 3b. Find "Final CTA" section start and its matching </section>, replace block
$startIndex = -1
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '\{/\*\s*Final CTA\s*\*/\}') {
        $startIndex = $i
        break
    }
}

if ($startIndex -lt 0) {
    Write-Warning "Could not find the '{/* Final CTA */}' marker (it may already be replaced)."
} else {
    $endIndex = -1
    for ($i = $startIndex; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '</section>') {
            $endIndex = $i
            break
        }
    }

    if ($endIndex -lt 0) {
        Write-Warning "Found Final CTA start but no matching </section>. No section was replaced."
    } else {
        [string[]]$replacementBlock = @(
            '      {/* Final CTA */}',
            '      <section className="mx-auto max-w-7xl px-4 pb-24 md:px-8">',
            '        <Reveal>',
            '          <GlassCta />',
            '        </Reveal>',
            '      </section>'
        )

        $newLines = [System.Collections.Generic.List[string]]::new()
        for ($i = 0; $i -lt $startIndex; $i++) {
            $newLines.Add($lines[$i])
        }
        foreach ($rl in $replacementBlock) {
            $newLines.Add($rl)
        }
        for ($i = $endIndex + 1; $i -lt $lines.Count; $i++) {
            $newLines.Add($lines[$i])
        }
        [string[]]$lines = $newLines.ToArray()
        Write-Host "Final CTA section replaced with <GlassCta />." -ForegroundColor Green
    }
}

# ---------------------------------------------------------------------------
# 4. Write the file back
# ---------------------------------------------------------------------------
Set-Content -Path $pagePath -Value $lines -Encoding UTF8

# ---------------------------------------------------------------------------
# 5. Verify
# ---------------------------------------------------------------------------
$finalContent = Get-Content -Path $pagePath -Raw

$importOk = $finalContent.Contains('import GlassCta from "@/components/ui/glass-cta";')
$usageOk  = $finalContent -match '<GlassCta\s*/>'
$fileOk   = Test-Path $glassCtaPath

Write-Host ""
Write-Host "----- Verification -----"
Write-Host ("glass-cta.tsx created:       " + ($(if ($fileOk) { "YES" } else { "NO" })))
Write-Host ("Import present in page.tsx:  " + ($(if ($importOk) { "YES" } else { "NO" })))
Write-Host ("<GlassCta /> used in page:   " + ($(if ($usageOk) { "YES" } else { "NO" })))

if ($fileOk -and $importOk -and $usageOk) {
    Write-Host ""
    Write-Host "All changes applied successfully." -ForegroundColor Green
} else {
    Write-Host ""
    Write-Warning "Something didn't apply cleanly. Check $backupPath to restore original if needed."
}

Write-Host ""
Write-Host "Now run:" -ForegroundColor Cyan
Write-Host "  cd `"$webRoot`""
Write-Host "  npm run dev"