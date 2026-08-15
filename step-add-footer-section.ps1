<#
  step-add-footer-section.ps1
  Adds the shadcn "footer-section" (animated, Framer Motion blur-in columns)
  component to apps/web, adapted to Saachi AI's design-token system
  (var(--color-*), font-display, etc. - no hardcoded hex), and wires it in
  as the site-wide footer (replaces the content of _components/SiteFooter.tsx
  so ConditionalChrome.tsx needs zero changes).

  Dependencies used by this component: "motion" and "lucide-react" - both
  are already declared in apps/web/package.json, so no new installs needed.

  Run from: SAI2 root
    PS D:\...\SAI2> .\step-add-footer-section.ps1
#>

$ErrorActionPreference = "Stop"

$root = Get-Location
$webRoot = Join-Path $root "apps\web"

if (-not [System.IO.Directory]::Exists($webRoot)) {
    Write-Host "ERROR: apps\web not found under $root. Run this from the SAI2 root." -ForegroundColor Red
    exit 1
}

$encNoBom = New-Object System.Text.UTF8Encoding($false)

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $dir = [System.IO.Path]::GetDirectoryName($Path)
    if (-not [System.IO.Directory]::Exists($dir)) {
        [System.IO.Directory]::CreateDirectory($dir) | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, $Content, $encNoBom)
    Write-Host "  wrote: $Path"
}

Write-Host "== Step: footer-section component ==" -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. components/ui/footer-section.tsx
#    Adapted from the shadcn demo:
#      - bg / border / text swapped for design tokens (bg-card, border-line,
#        text-ink, text-ink-soft) so it respects the zero-hardcoded-hex rule.
#      - Brand mark swapped from generic FrameIcon+"Asme" to the real
#        "Saachi AI" wordmark used elsewhere in the header/footer.
#      - Link columns swapped for the site's real routes (courses, pricing,
#        legal pages, etc.) instead of placeholder "#" links.
#      - Social icons kept from lucide-react, hrefs left as "#" placeholders
#        since no real social URLs exist yet - update these when available.
# ---------------------------------------------------------------------------
$footerSectionPath = Join-Path $webRoot "components\ui\footer-section.tsx"
$footerSectionContent = @'
"use client";

import React from "react";
import type { ComponentProps, ReactNode } from "react";
import Link from "next/link";
import { motion, useReducedMotion } from "motion/react";
import { FacebookIcon, InstagramIcon, LinkedinIcon, YoutubeIcon } from "lucide-react";

interface FooterLink {
  title: string;
  href: string;
  icon?: React.ComponentType<{ className?: string }>;
}

interface FooterSection {
  label: string;
  links: FooterLink[];
}

const footerLinks: FooterSection[] = [
  {
    label: "Platform",
    links: [
      { title: "Browse courses", href: "/courses" },
      { title: "Pricing", href: "/pricing" },
      { title: "Become an instructor", href: "/register" },
      { title: "Mentorship", href: "/mentorship" }
    ]
  },
  {
    label: "Company",
    links: [
      { title: "About us", href: "/about" },
      { title: "Contact", href: "/contact" },
      { title: "Blog", href: "/blog" },
      { title: "News", href: "/news" }
    ]
  },
  {
    label: "Legal",
    links: [
      { title: "Terms & Conditions", href: "/legal/terms" },
      { title: "Privacy Policy", href: "/legal/privacy" },
      { title: "Refund Policy", href: "/legal/refund-policy" },
      { title: "Instructor Agreement", href: "/legal/instructor-agreement" }
    ]
  },
  {
    label: "Social",
    links: [
      { title: "Facebook", href: "#", icon: FacebookIcon },
      { title: "Instagram", href: "#", icon: InstagramIcon },
      { title: "Youtube", href: "#", icon: YoutubeIcon },
      { title: "LinkedIn", href: "#", icon: LinkedinIcon }
    ]
  }
];

export function Footer() {
  return (
    <footer className="relative mt-24 w-full border-t border-line bg-card px-6 py-12 lg:py-16">
      <div className="bg-accent-violet/20 absolute top-0 right-1/2 left-1/2 h-px w-1/3 -translate-x-1/2 -translate-y-1/2 rounded-full blur" />

      <div className="mx-auto grid w-full max-w-7xl gap-8 xl:grid-cols-3 xl:gap-8">
        <AnimatedContainer className="space-y-4">
          <Link href="/" className="font-display text-[20px] font-bold text-ink">
            Saachi<span className="text-gold-dark">AI</span>
          </Link>
          <p className="mt-8 max-w-[260px] text-sm text-ink-soft md:mt-4">
            A skills exchange for the AI era. Learn practical AI skills, and sell what you know.
          </p>
          <p className="text-sm text-ink-soft/70">
            &copy; {new Date().getFullYear()} Saachi AI. All rights reserved.
          </p>
        </AnimatedContainer>

        <div className="mt-10 grid grid-cols-2 gap-8 md:grid-cols-4 xl:col-span-2 xl:mt-0">
          {footerLinks.map((section, index) => (
            <AnimatedContainer key={section.label} delay={0.1 + index * 0.1}>
              <div className="mb-10 md:mb-0">
                <h3 className="text-xs font-semibold uppercase tracking-[0.06em] text-ink-soft/70">
                  {section.label}
                </h3>
                <ul className="mt-4 space-y-2 text-sm text-ink-soft">
                  {section.links.map((link) => (
                    <li key={link.title}>
                      <Link
                        href={link.href}
                        className="inline-flex items-center transition-colors duration-150 ease-out hover:text-ink"
                      >
                        {link.icon && <link.icon className="me-1.5 size-4" />}
                        {link.title}
                      </Link>
                    </li>
                  ))}
                </ul>
              </div>
            </AnimatedContainer>
          ))}
        </div>
      </div>
    </footer>
  );
}

type ViewAnimationProps = {
  delay?: number;
  className?: ComponentProps<typeof motion.div>["className"];
  children: ReactNode;
};

function AnimatedContainer({ className, delay = 0.1, children }: ViewAnimationProps) {
  const shouldReduceMotion = useReducedMotion();

  if (shouldReduceMotion) {
    return <>{children}</>;
  }

  return (
    <motion.div
      initial={{ filter: "blur(4px)", translateY: -8, opacity: 0 }}
      whileInView={{ filter: "blur(0px)", translateY: 0, opacity: 1 }}
      viewport={{ once: true }}
      transition={{ delay, duration: 0.8 }}
      className={className}
    >
      {children}
    </motion.div>
  );
}
'@
Write-Utf8NoBom -Path $footerSectionPath -Content $footerSectionContent

# ---------------------------------------------------------------------------
# 2. Wire it in as the site-wide footer.
#    We overwrite _components/SiteFooter.tsx to simply re-export the new
#    Footer under the existing "SiteFooter" name, so ConditionalChrome.tsx
#    (which imports { SiteFooter } from "./SiteFooter") needs no changes.
# ---------------------------------------------------------------------------
$siteFooterPath = Join-Path $webRoot "app\_components\SiteFooter.tsx"
$siteFooterContent = @'
import { Footer } from "@/components/ui/footer-section";

export function SiteFooter() {
  return <Footer />;
}
'@
Write-Utf8NoBom -Path $siteFooterPath -Content $siteFooterContent

# ---------------------------------------------------------------------------
# 3. Confirm required deps are present (motion, lucide-react). Add if missing.
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "== Verifying dependencies ==" -ForegroundColor Cyan

$pkgPath = Join-Path $webRoot "package.json"
$pkgJson = Get-Content -Raw -Path $pkgPath | ConvertFrom-Json

$requiredDeps = @{
    "motion"       = "^11.15.0"
    "lucide-react" = "^0.445.0"
}

$changed = $false
foreach ($dep in $requiredDeps.Keys) {
    if (-not $pkgJson.dependencies.PSObject.Properties.Name.Contains($dep)) {
        $pkgJson.dependencies | Add-Member -MemberType NoteProperty -Name $dep -Value $requiredDeps[$dep]
        Write-Host "  added missing dependency: $dep@$($requiredDeps[$dep])"
        $changed = $true
    } else {
        Write-Host "  already present: $dep"
    }
}

if ($changed) {
    $jsonOut = $pkgJson | ConvertTo-Json -Depth 20
    Write-Utf8NoBom -Path $pkgPath -Content $jsonOut
} else {
    Write-Host "  package.json already has everything this component needs"
}

# ---------------------------------------------------------------------------
# 4. Install if pnpm is available and something changed
# ---------------------------------------------------------------------------
if ($changed) {
    Write-Host ""
    Write-Host "== Installing dependencies (pnpm install from root) ==" -ForegroundColor Cyan
    $pnpmAvailable = Get-Command pnpm -ErrorAction SilentlyContinue
    if ($pnpmAvailable) {
        Push-Location $root
        try {
            & pnpm install
        } finally {
            Pop-Location
        }
    } else {
        Write-Host "  pnpm not found on PATH - run manually: pnpm install" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "== Done ==" -ForegroundColor Green
Write-Host "The new animated Footer is now live site-wide via _components/SiteFooter.tsx."
Write-Host "Update the placeholder Social href=`"#`" values in components/ui/footer-section.tsx once real social links exist."
Write-Host "Run 'pnpm dev' and scroll to the bottom of any page to see it."