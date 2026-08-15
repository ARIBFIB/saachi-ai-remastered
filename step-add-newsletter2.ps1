<#
  step-add-newsletter2.ps1
  Adds the shadcn "newsletter-2" component + its missing deps (checkbox, sonner)
  to apps/web, then swaps <NewsletterCard /> for <NewsletterBlock /> on the
  landing page (apps/web/app/(marketing)/page.tsx).

  Run from: SAI2 root
    PS D:\...\SAI2> .\step-add-newsletter2.ps1
#>

$ErrorActionPreference = "Stop"

$root = Get-Location
$webRoot = Join-Path $root "apps\web"

if (-not [System.IO.Directory]::Exists($webRoot)) {
    Write-Host "ERROR: apps\web not found under $root. Run this from the SAI2 root." -ForegroundColor Red
    exit 1
}

function Write-Utf8NoBom {
    param(
        [string]$Path,
        [string]$Content
    )
    $dir = [System.IO.Path]::GetDirectoryName($Path)
    if (-not [System.IO.Directory]::Exists($dir)) {
        [System.IO.Directory]::CreateDirectory($dir) | Out-Null
    }
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $enc)
    Write-Host "  wrote: $Path"
}

Write-Host "== Step: newsletter-2 component ==" -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. components/ui/checkbox.tsx (missing dependency)
# ---------------------------------------------------------------------------
$checkboxPath = Join-Path $webRoot "components\ui\checkbox.tsx"
$checkboxContent = @'
"use client"

import * as React from "react"
import * as CheckboxPrimitive from "@radix-ui/react-checkbox"
import { Check } from "lucide-react"

import { cn } from "@/lib/utils"

const Checkbox = React.forwardRef<
  React.ElementRef<typeof CheckboxPrimitive.Root>,
  React.ComponentPropsWithoutRef<typeof CheckboxPrimitive.Root>
>(({ className, ...props }, ref) => (
  <CheckboxPrimitive.Root
    ref={ref}
    className={cn(
      "peer h-4 w-4 shrink-0 rounded-sm border border-primary ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 data-[state=checked]:bg-primary data-[state=checked]:text-primary-foreground",
      className,
    )}
    {...props}
  >
    <CheckboxPrimitive.Indicator
      className={cn("flex items-center justify-center text-current")}
    >
      <Check className="h-4 w-4" />
    </CheckboxPrimitive.Indicator>
  </CheckboxPrimitive.Root>
))
Checkbox.displayName = CheckboxPrimitive.Root.displayName

export { Checkbox }
'@
Write-Utf8NoBom -Path $checkboxPath -Content $checkboxContent

# ---------------------------------------------------------------------------
# 2. components/ui/sonner.tsx (missing dependency - toast provider)
# ---------------------------------------------------------------------------
$sonnerPath = Join-Path $webRoot "components\ui\sonner.tsx"
$sonnerContent = @'
"use client"

import { useTheme } from "next-themes"
import { Toaster as Sonner } from "sonner"

type ToasterProps = React.ComponentProps<typeof Sonner>

const Toaster = ({ ...props }: ToasterProps) => {
  const { theme = "system" } = useTheme()

  return (
    <Sonner
      theme={theme as ToasterProps["theme"]}
      className="toaster group"
      toastOptions={{
        classNames: {
          toast:
            "group toast group-[.toaster]:bg-background group-[.toaster]:text-foreground group-[.toaster]:border-border group-[.toaster]:shadow-lg",
          description: "group-[.toast]:text-muted-foreground",
          actionButton:
            "group-[.toast]:bg-primary group-[.toast]:text-primary-foreground",
          cancelButton:
            "group-[.toast]:bg-muted group-[.toast]:text-muted-foreground",
        },
      }}
      {...props}
    />
  )
}

export { Toaster }
'@
Write-Utf8NoBom -Path $sonnerPath -Content $sonnerContent

# ---------------------------------------------------------------------------
# 3. components/ui/newsletter-2.tsx (the actual block)
#    NOTE: adapted to import Button/Input from the shadcn-style files that
#    already exist in apps/web/components/ui, and to use our own tokens.
# ---------------------------------------------------------------------------
$newsletterPath = Join-Path $webRoot "components\ui\newsletter-2.tsx"
$newsletterContent = @'
"use client";

import { RiArrowRightLine, RiLockLine } from "@remixicon/react";
import { toast } from "sonner";

import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { Toaster } from "@/components/ui/sonner";

export default function NewsletterBlock() {
  return (
    <section className="flex w-full items-center justify-center rounded-card border border-line bg-card px-6 py-12 text-ink">
      <Toaster />
      <div className="w-full max-w-5xl px-2 py-2 sm:px-6 sm:py-4">
        <div className="flex flex-col gap-8 md:flex-row md:items-center md:justify-between md:gap-16">
          <div className="flex flex-col gap-3 md:max-w-sm">
            <p className="text-xs font-semibold tracking-widest text-ink-soft uppercase">
              Saachi AI Weekly
            </p>
            <h2 className="font-display text-2xl leading-tight font-bold tracking-tight text-ink sm:text-3xl">
              Get new courses in your inbox
            </h2>
            <p className="text-sm text-ink-soft">
              One email a week. New releases, instructor spotlights, and the
              occasional discount code.
            </p>
          </div>

          <div className="flex flex-col gap-3 md:max-w-md md:min-w-0 md:flex-1">
            <form
              className="flex flex-col gap-3"
              onSubmit={(e) => {
                e.preventDefault();
                toast.success("You're subscribed. See you Tuesday!");
              }}
            >
              <div className="flex flex-col gap-2 sm:flex-row">
                <input
                  type="email"
                  required
                  placeholder="you@example.com"
                  aria-label="Email address"
                  className="h-10 flex-1 rounded-control border border-line-strong bg-card px-3.5 text-[14px] text-ink outline-none transition-colors duration-150 ease-out placeholder:text-ink-soft/50 focus:border-gold"
                />
                <Button type="submit" variant="brand" className="shrink-0 rounded-full px-5">
                  Subscribe
                  <RiArrowRightLine aria-hidden="true" className="ml-1.5" size={16} />
                </Button>
              </div>
              <div className="flex items-center gap-2">
                <Checkbox id="newsletter-consent" name="consent" />
                <label
                  htmlFor="newsletter-consent"
                  className="text-sm font-normal text-ink-soft"
                >
                  I agree to receive the Saachi AI Weekly newsletter.
                </label>
              </div>
            </form>
            <p className="flex items-center gap-1.5 text-xs text-ink-soft">
              <RiLockLine aria-hidden="true" className="shrink-0" size={12} />
              Your data stays private. Unsubscribe any time, no questions asked.
            </p>
          </div>
        </div>
      </div>
    </section>
  );
}
'@
Write-Utf8NoBom -Path $newsletterPath -Content $newsletterContent

# ---------------------------------------------------------------------------
# 4. Swap <NewsletterCard /> for <NewsletterBlock /> on the landing page
# ---------------------------------------------------------------------------
$pagePath = Join-Path $webRoot "app\(marketing)\page.tsx"

if (-not [System.IO.File]::Exists($pagePath)) {
    Write-Host "WARNING: landing page not found at $pagePath - skipping swap." -ForegroundColor Yellow
} else {
    $pageContent = [System.IO.File]::ReadAllText($pagePath)

    $oldImport = 'import { NewsletterCard } from "./_components/NewsletterCard";'
    $newImport = 'import NewsletterBlock from "@/components/ui/newsletter-2";'

    if ($pageContent.Contains($oldImport)) {
        $pageContent = $pageContent.Replace($oldImport, $newImport)
        Write-Host "  replaced import statement"
    } else {
        Write-Host "  WARNING: import line for NewsletterCard not found (already changed?)" -ForegroundColor Yellow
    }

    $oldUsage = '<NewsletterCard />'
    $newUsage = '<NewsletterBlock />'

    if ($pageContent.Contains($oldUsage)) {
        $pageContent = $pageContent.Replace($oldUsage, $newUsage)
        Write-Host "  replaced <NewsletterCard /> usage"
    } else {
        Write-Host "  WARNING: <NewsletterCard /> usage not found (already changed?)" -ForegroundColor Yellow
    }

    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($pagePath, $pageContent, $enc)
    Write-Host "  wrote: $pagePath"
}

# ---------------------------------------------------------------------------
# 5. Add missing npm deps to apps/web/package.json (if not already present)
# ---------------------------------------------------------------------------
$pkgPath = Join-Path $webRoot "package.json"
$pkgJson = Get-Content -Raw -Path $pkgPath | ConvertFrom-Json

$depsToAdd = @{
    "sonner"                    = "^1.7.0"
    "@remixicon/react"          = "^4.5.0"
    "@radix-ui/react-checkbox"  = "^1.1.4"
    "next-themes"                = "^0.4.0"
}

$changed = $false
foreach ($dep in $depsToAdd.Keys) {
    if (-not $pkgJson.dependencies.PSObject.Properties.Name.Contains($dep)) {
        $pkgJson.dependencies | Add-Member -MemberType NoteProperty -Name $dep -Value $depsToAdd[$dep]
        Write-Host "  added dependency: $dep@$($depsToAdd[$dep])"
        $changed = $true
    } else {
        Write-Host "  dependency already present: $dep"
    }
}

if ($changed) {
    $jsonOut = $pkgJson | ConvertTo-Json -Depth 20
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($pkgPath, $jsonOut, $enc)
    Write-Host "  updated: $pkgPath"
} else {
    Write-Host "  package.json already up to date"
}

Write-Host ""
Write-Host "== Done ==" -ForegroundColor Green
Write-Host "Next steps:"
Write-Host "  1. cd apps\web  (or run pnpm install from SAI2 root)"
Write-Host "  2. pnpm install     # to pull sonner, @remixicon/react, @radix-ui/react-checkbox, next-themes"
Write-Host "  3. pnpm dev         # verify landing page renders the new newsletter block"