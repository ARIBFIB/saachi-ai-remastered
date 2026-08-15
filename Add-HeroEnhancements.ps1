# Add-HeroEnhancements.ps1
# Run this from: SAI2 root

$ErrorActionPreference = "Stop"

$webRoot    = Join-Path $PSScriptRoot "apps\web"
$uiDir      = Join-Path $webRoot "components\ui"
$pageFile   = Join-Path $webRoot "app\(marketing)\page.tsx"
$headerFile = Join-Path $webRoot "app\_components\SiteHeader.tsx"

if (-not (Test-Path $webRoot)) {
    Write-Host "ERROR: apps\web not found. Run this from SAI2 root." -ForegroundColor Red
    exit 1
}

New-Item -ItemType Directory -Force -Path $uiDir | Out-Null

function Backup-Once($path) {
    if (Test-Path $path) {
        $ts = Get-Date -Format "yyyyMMdd-HHmmss"
        Copy-Item -Path $path -Destination "$path.bak-$ts" -Force
        Write-Host "Backed up: $path.bak-$ts" -ForegroundColor Yellow
    }
}

# ==================================================================
# 1. hero-media-collage.tsx
# ==================================================================
$collageLines = @(
'"use client";'
''
'import { motion } from "framer-motion";'
''
'const COLLAGE_IMAGES = ['
'  {'
'    src: "https://media2.gogoprint.com/product-config/ggp-v1/product-part/CertificateNameOptions.png",'
'    alt: "Course certificate preview",'
'    className: "absolute right-6 top-2 w-[150px] rotate-[6deg]",'
'    delay: 0.1'
'  },'
'  {'
'    src: "https://media2.gogoprint.com/wysiwyg/GGP250919_Product%20Images_Assorted%202_Product%20Banner_V1_Certificates.png",'
'    alt: "Printed certificate stack",'
'    className: "absolute right-[130px] top-[110px] w-[130px] -rotate-[8deg]",'
'    delay: 0.2'
'  },'
'  {'
'    src: "https://img.magnific.com/free-photo/elevated-view-laptop-stationeries-blue-backdrop_23-2147880457.jpg?semt=ais_test_b&w=740&q=80",'
'    alt: "Laptop and study desk",'
'    className: "absolute right-2 top-[210px] w-[170px] rotate-[3deg]",'
'    delay: 0.3'
'  }'
'];'
''
'const TRUST_BADGES = ['
'  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRXw__JGEVPoYpshYYG8UuBjH7gxWJmlNu82dtp0iM3ww&s=10",'
'  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7yozzI-aiXLy--A4tQX80TWaWt1YSSBDA-fDrcggKhQ&s=10",'
'  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSpa2Z8Pb_yaZthxdUoOsXaA8DsXMl4S980UXIUadYBxg&s=10",'
'  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTxV1v7Hc6n9DsaX6YdAE3CpbR9E5z8NRWut6CWeS0Y5Q&s=10"'
'];'
''
'export function HeroMediaCollage() {'
'  return ('
'    <div className="pointer-events-none absolute right-0 top-0 hidden h-[320px] w-[280px] lg:block xl:right-4">'
'      {COLLAGE_IMAGES.map((img) => ('
'        <motion.div'
'          key={img.src}'
'          initial={{ opacity: 0, y: 24, scale: 0.92 }}'
'          animate={{ opacity: 1, y: 0, scale: 1 }}'
'          transition={{ duration: 0.6, delay: img.delay, ease: [0.16, 1, 0.3, 1] }}'
'          className={img.className}'
'        >'
'          {/* eslint-disable-next-line @next/next/no-img-element */}'
'          <img'
'            src={img.src}'
'            alt={img.alt}'
'            className="aspect-square w-full rounded-2xl border border-line/60 bg-card object-cover shadow-xl"'
'          />'
'        </motion.div>'
'      ))}'
''
'      <motion.div'
'        initial={{ opacity: 0, y: 16 }}'
'        animate={{ opacity: 1, y: 0 }}'
'        transition={{ duration: 0.6, delay: 0.5, ease: [0.16, 1, 0.3, 1] }}'
'        className="pointer-events-auto absolute bottom-0 right-2 flex items-center gap-1.5 rounded-full border border-line bg-card/95 px-3 py-2 shadow-md backdrop-blur-sm"'
'      >'
'        {TRUST_BADGES.map((src, i) => ('
'          // eslint-disable-next-line @next/next/no-img-element'
'          <img'
'            key={src + i}'
'            src={src}'
'            alt="Trust badge"'
'            className="h-6 w-6 rounded-full border border-line object-cover grayscale transition-all duration-200 hover:grayscale-0"'
'            style={{ marginLeft: i === 0 ? 0 : -8 }}'
'          />'
'        ))}'
'        <span className="ml-1.5 whitespace-nowrap text-[10px] font-semibold text-ink-soft">Trusted &amp; Certified</span>'
'      </motion.div>'
'    </div>'
'  );'
'}'
)

$collagePath = Join-Path $uiDir "hero-media-collage.tsx"
Set-Content -Path $collagePath -Value $collageLines -Encoding UTF8
Write-Host "Created: $collagePath" -ForegroundColor Green

# ==================================================================
# 2. Patch page.tsx
# ==================================================================
if (-not (Test-Path $pageFile)) {
    Write-Host "ERROR: page.tsx not found at $pageFile" -ForegroundColor Red
    exit 1
}

$content = Get-Content -Path $pageFile -Raw

if ($content -match "HeroMediaCollage") {
    Write-Host "page.tsx already patched with HeroMediaCollage, skipping." -ForegroundColor Yellow
} else {
    Backup-Once $pageFile

    # --- 2a. Add react hooks import ---
    $anchor = 'import Link from "next/link";'
    if ($content -match [regex]::Escape($anchor)) {
        $content = $content.Replace($anchor, "import { useEffect, useState } from `"react`";`r`n" + $anchor)
        Write-Host "Added useEffect/useState import." -ForegroundColor Green
    } else {
        Write-Host "WARNING: could not find Link import anchor, skipping hook import." -ForegroundColor Yellow
    }

    # --- 2b. Add HeroMediaCollage import ---
    $anchor = 'import { CoverflowCarousel } from "@/components/ui/coverflow-carousel";'
    if ($content -match [regex]::Escape($anchor)) {
        $content = $content.Replace($anchor, $anchor + "`r`nimport { HeroMediaCollage } from `"@/components/ui/hero-media-collage`";")
        Write-Host "Added HeroMediaCollage import." -ForegroundColor Green
    } else {
        Write-Host "WARNING: could not find CoverflowCarousel import anchor." -ForegroundColor Yellow
    }

    # --- 2c. Add loading state inside HomePage() ---
    $anchor = 'const { data: featured, isLoading } = useCourseList({ sort: "popular", page: 1 });'
    if ($content -match [regex]::Escape($anchor)) {
        $stateBlock = $anchor + "`r`n  const [heroLoaded, setHeroLoaded] = useState(false);`r`n`r`n  useEffect(() => {`r`n    const t = setTimeout(() => setHeroLoaded(true), 700);`r`n    return () => clearTimeout(t);`r`n  }, []);"
        $content = $content.Replace($anchor, $stateBlock)
        Write-Host "Added hero skeleton loading state." -ForegroundColor Green
    } else {
        Write-Host "WARNING: could not find useCourseList anchor, skipping loading state." -ForegroundColor Yellow
    }

    # --- 2d. Replace headline + paragraph with skeleton/reveal ---
    $startMarker = '<h1 className="font-display text-[38px] font-bold leading-[1.05] text-ink md:text-[64px]">'
    $endMarker = 'structured, practical, and paid.
          </p>'

    $startIdx = $content.IndexOf($startMarker)
    $endIdx = $content.IndexOf($endMarker)

    if ($startIdx -ge 0 -and $endIdx -ge 0) {
        $endIdx = $endIdx + $endMarker.Length
        $before = $content.Substring(0, $startIdx)
        $after = $content.Substring($endIdx)

        $replacement = @'
{heroLoaded ? (
            <>
              <h1 className="font-display text-[38px] font-bold leading-[1.05] text-ink md:text-[64px]">
                Learn AI Skills.
                <br />
                <span className="text-gradient-brand">Build Real Projects.</span>
              </h1>
              <p className="mt-5 text-[16px] leading-relaxed text-ink-soft md:text-[18px]">
                Not another watch-time platform. Saachi AI is a skills exchange for the AI era -
                structured, practical, and paid.
              </p>
            </>
          ) : (
            <div className="flex flex-col gap-3">
              <div className="h-[38px] w-[92%] animate-pulse rounded-lg bg-paper-dim md:h-[64px]" />
              <div className="h-[38px] w-[70%] animate-pulse rounded-lg bg-paper-dim md:h-[64px]" />
              <div className="mt-3 h-4 w-full animate-pulse rounded bg-paper-dim" />
              <div className="h-4 w-[85%] animate-pulse rounded bg-paper-dim" />
            </div>
          )}
'@
        $content = $before + $replacement + $after
        Write-Host "Replaced headline/paragraph with skeleton-aware block." -ForegroundColor Green
    } else {
        Write-Host "WARNING: could not find headline/paragraph markers, skipping skeleton swap." -ForegroundColor Yellow
    }

    # --- 2e. Replace CTA buttons with hover/motion effects ---
    $startMarker2 = '<div className="mt-8 flex flex-wrap gap-3">'
    $endMarker2 = 'Become an instructor
              </Button>
            </Link>
          </div>'

    $startIdx2 = $content.IndexOf($startMarker2)
    $endIdx2 = $content.IndexOf($endMarker2)

    if ($startIdx2 -ge 0 -and $endIdx2 -ge 0) {
        $endIdx2 = $endIdx2 + $endMarker2.Length
        $before2 = $content.Substring(0, $startIdx2)
        $after2 = $content.Substring($endIdx2)

        $replacement2 = @'
<div className="mt-8 flex flex-wrap gap-3">
            <Link href="/courses" className="group">
              <button
                type="button"
                className="inline-flex h-[52px] items-center gap-2 rounded-full px-7 text-[16px] font-semibold text-white shadow-[0_0_40px_-12px_rgba(124,58,237,0.5)] transition-all duration-200 ease-out hover:-translate-y-0.5 hover:shadow-[0_0_50px_-8px_rgba(124,58,237,0.65)] active:translate-y-0"
                style={{ backgroundImage: "var(--color-accent-gradient)" }}
              >
                Browse courses
                <ArrowRight size={16} className="transition-transform duration-200 ease-out group-hover:translate-x-1" />
              </button>
            </Link>
            <Link href="/register" className="group">
              <button
                type="button"
                className="inline-flex h-[52px] items-center gap-2 rounded-full border border-line-strong bg-card px-7 text-[16px] font-semibold text-ink transition-all duration-200 ease-out hover:-translate-y-0.5 hover:border-accent-violet/50 hover:bg-paper-dim active:translate-y-0"
              >
                Become an instructor
                <ArrowRight size={16} className="transition-transform duration-200 ease-out group-hover:translate-x-1" />
              </button>
            </Link>
          </div>
'@
        $content = $before2 + $replacement2 + $after2
        Write-Host "Replaced CTA buttons with hover/motion effects." -ForegroundColor Green
    } else {
        Write-Host "WARNING: could not find CTA button markers, skipping button upgrade." -ForegroundColor Yellow
    }

    # --- 2f. Add ArrowRight to lucide-react import ---
    $anchor = 'import {
  Sparkles,'
    if ($content -match [regex]::Escape($anchor)) {
        $content = $content.Replace($anchor, "import {`r`n  ArrowRight,`r`n  Sparkles,")
        Write-Host "Added ArrowRight icon import." -ForegroundColor Green
    } else {
        Write-Host "WARNING: could not find lucide-react import block start, ArrowRight may be undefined." -ForegroundColor Yellow
    }

    # --- 2g. Insert HeroMediaCollage into hero section ---
    $anchor = '<div className="mt-6">
            <ActivityTicker />
          </div>
        </div>
      </section>'
    if ($content -match [regex]::Escape($anchor)) {
        $newBlock = @'
<div className="mt-6">
            <ActivityTicker />
          </div>
        </div>

        <HeroMediaCollage />
      </section>
'@
        $content = $content.Replace($anchor, $newBlock)
        Write-Host "Inserted HeroMediaCollage into hero section." -ForegroundColor Green
    } else {
        Write-Host "WARNING: could not find hero section end anchor, HeroMediaCollage not inserted." -ForegroundColor Yellow
    }

    Set-Content -Path $pageFile -Value $content -Encoding UTF8 -NoNewline
    Write-Host "Patched: $pageFile" -ForegroundColor Cyan
}

# ==================================================================
# 3. Patch SiteHeader.tsx - small trust badge next to logo
# ==================================================================
if (-not (Test-Path $headerFile)) {
    Write-Host "WARNING: SiteHeader.tsx not found, skipping nav badge." -ForegroundColor Yellow
} else {
    $hcontent = Get-Content -Path $headerFile -Raw

    if ($hcontent -match "Rated") {
        Write-Host "SiteHeader.tsx already has trust badge, skipping." -ForegroundColor Yellow
    } else {
        Backup-Once $headerFile

        $anchor = 'Saachi<span className="text-gold-dark">AI</span>
        </Link>'

        if ($hcontent -match [regex]::Escape($anchor)) {
            $newAnchor = @'
Saachi<span className="text-gold-dark">AI</span>
        </Link>

        <div className="ml-3 hidden items-center gap-1 rounded-full border border-line bg-paper-dim px-2.5 py-1 text-[11px] font-semibold text-ink-soft lg:flex">
          <span className="text-gold-dark">4.8</span>
          <span aria-hidden="true">&#9733;</span>
          <span>Rated by learners</span>
        </div>
'@
            $hcontent = $hcontent.Replace($anchor, $newAnchor)
            Set-Content -Path $headerFile -Value $hcontent -Encoding UTF8 -NoNewline
            Write-Host "Patched: $headerFile (added trust badge)" -ForegroundColor Green
        } else {
            Write-Host "WARNING: could not find logo anchor in SiteHeader.tsx, skipping." -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "Done. Review any WARNING lines above - those steps were skipped safely without breaking the file." -ForegroundColor Cyan
Write-Host "Now run: cd apps\web; pnpm run build" -ForegroundColor DarkGray