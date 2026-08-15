# Horizontal-Gallery-With-Labels-And-Buttons.ps1
# Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Content
    )
    $dir = Split-Path -Path $Path -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

$root = (Get-Location).Path
$webApp = Join-Path -Path $root -ChildPath "apps\web"
$pagePath = Join-Path -Path $webApp -ChildPath "app\(marketing)\page.tsx"
$galleryTrailPath = Join-Path -Path $webApp -ChildPath "components\ui\gallery-cursor-trail.tsx"
$shadcnButtonPath = Join-Path -Path $webApp -ChildPath "components\ui\button.tsx"
$buttonColorfulPath = Join-Path -Path $webApp -ChildPath "components\ui\button-colorful.tsx"

if (-not (Test-Path $pagePath)) {
    Write-Host "ERROR: $pagePath not found. Run from SAI2 repo root." -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------------
# 1. shadcn Button primitive (dependency for ButtonColorful)
# ------------------------------------------------------------------
if (-not (Test-Path $shadcnButtonPath)) {
$shadcnButtonContent = @'
import * as React from "react"
import { Slot } from "@radix-ui/react-slot"
import { cva, type VariantProps } from "class-variance-authority"

import { cn } from "@/lib/utils"

const buttonVariants = cva(
  "inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive:
          "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline:
          "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
        secondary:
          "bg-secondary text-secondary-foreground hover:bg-secondary/80",
        ghost: "hover:bg-accent hover:text-accent-foreground",
        link: "text-primary underline-offset-4 hover:underline",
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 rounded-md px-3",
        lg: "h-11 rounded-md px-8",
        icon: "h-10 w-10",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  },
)

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button"
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    )
  },
)
Button.displayName = "Button"

export { Button, buttonVariants }
'@
Write-Utf8NoBom -Path $shadcnButtonPath -Content $shadcnButtonContent
Write-Host "Created: $shadcnButtonPath" -ForegroundColor Green
} else {
    Write-Host "shadcn Button already exists, skipping." -ForegroundColor Yellow
}

# ------------------------------------------------------------------
# 2. ButtonColorful
# ------------------------------------------------------------------
$buttonColorfulContent = @'
"use client";

import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { ArrowUpRight } from "lucide-react";

interface ButtonColorfulProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  label?: string;
}

export function ButtonColorful({
  className,
  label = "Explore",
  ...props
}: ButtonColorfulProps) {
  return (
    <Button
      className={cn(
        "relative h-9 px-3.5 overflow-hidden",
        "bg-zinc-900 dark:bg-zinc-100",
        "transition-all duration-200",
        "group/btn",
        className
      )}
      {...props}
    >
      <div
        className={cn(
          "absolute inset-0",
          "bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500",
          "opacity-50 group-hover/btn:opacity-90",
          "blur transition-opacity duration-500"
        )}
      />
      <div className="relative flex items-center justify-center gap-1.5">
        <span className="text-[12.5px] font-semibold text-white dark:text-zinc-900">{label}</span>
        <ArrowUpRight className="h-3.5 w-3.5 text-white/90 dark:text-zinc-900/90" />
      </div>
    </Button>
  );
}

export default ButtonColorful;
'@

Write-Utf8NoBom -Path $buttonColorfulPath -Content $buttonColorfulContent
Write-Host "Created: $buttonColorfulPath" -ForegroundColor Green

# ------------------------------------------------------------------
# 3. GalleryCursorTrail: horizontal, narrower, labeled cards (News,
#    Community, Courses, Certificate), each with a ButtonColorful CTA
#    that appears on hover. Also fades near the left text column via
#    mask-image so it never overlaps the headline/paragraph/buttons.
# ------------------------------------------------------------------
$galleryTrailContent = @'
"use client";

import { useState } from "react";
import Link from "next/link";
import { cn } from "@/lib/utils";
import { ImageCursorTrail } from "@/components/ui/image-cursor-trail";
import { ButtonColorful } from "@/components/ui/button-colorful";

export type GalleryCard = {
  label: string;
  src: string;
  href: string;
  buttonLabel: string;
};

// Four content-relevant cards: News, Community, Courses, Certificate.
export const GALLERY_CARDS: GalleryCard[] = [
  {
    label: "News",
    src: "https://images.unsplash.com/photo-1495020689067-958852a7765e?q=80&h=800&w=800&auto=format&fit=crop",
    href: "/about",
    buttonLabel: "Read news"
  },
  {
    label: "Community",
    src: "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?q=80&h=800&w=800&auto=format&fit=crop",
    href: "/mentorship",
    buttonLabel: "Join community"
  },
  {
    label: "Courses",
    src: "https://images.unsplash.com/photo-1555949963-aa79dcee981c?q=80&h=800&w=800&auto=format&fit=crop",
    href: "/courses",
    buttonLabel: "Browse courses"
  },
  {
    label: "Certificate",
    src: "https://images.unsplash.com/photo-1546410531-bb4caa6b424d?q=80&h=800&w=800&auto=format&fit=crop",
    href: "/certificates",
    buttonLabel: "Get certified"
  }
];

export const GALLERY_IMAGES = GALLERY_CARDS.map((c) => c.src);

/**
 * Horizontal, compact card strip (fits the right-side hero column).
 * On hover: the hovered card expands slightly, shows its label and a
 * ButtonColorful CTA, and triggers a small cursor-trail using that
 * same image. A mask-image gradient fades the whole strip out toward
 * the left (text column) side so it never overlaps the headline,
 * paragraph, or CTA buttons even if the mouse drifts that way.
 */
export function GalleryCursorTrail() {
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null);

  return (
    <div
      className="relative flex h-[220px] w-full max-w-[420px] items-stretch gap-1.5"
      style={{
        maskImage: "linear-gradient(to left, black 70%, transparent 100%)",
        WebkitMaskImage: "linear-gradient(to left, black 70%, transparent 100%)"
      }}
    >
      {GALLERY_CARDS.map((card, idx) => {
        const isHovered = hoveredIndex === idx;
        return (
          <div
            key={card.label}
            onMouseEnter={() => setHoveredIndex(idx)}
            onMouseLeave={() => setHoveredIndex(null)}
            className={cn(
              "group relative h-full flex-grow overflow-hidden rounded-lg transition-all duration-500 ease-out",
              isHovered ? "w-[170px] flex-grow-[3]" : "w-14 flex-grow"
            )}
          >
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              className="h-full w-full object-cover object-center transition-transform duration-500 group-hover:scale-105"
              src={card.src}
              alt={card.label}
            />

            <div
              className={cn(
                "pointer-events-none absolute inset-0 bg-gradient-to-t from-black/70 via-black/10 to-transparent transition-opacity duration-300",
                isHovered ? "opacity-100" : "opacity-60"
              )}
            />

            <span
              className={cn(
                "absolute left-2.5 top-2.5 rounded-full bg-black/40 px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wide text-white backdrop-blur-sm transition-opacity duration-300",
                isHovered ? "opacity-0" : "opacity-100"
              )}
            >
              {card.label}
            </span>

            <div
              className={cn(
                "pointer-events-none absolute inset-x-0 bottom-0 flex flex-col gap-2 p-3 transition-all duration-300",
                isHovered ? "translate-y-0 opacity-100" : "translate-y-2 opacity-0"
              )}
            >
              <span className="text-[13px] font-semibold text-white">{card.label}</span>
              <Link href={card.href} className="pointer-events-auto w-fit">
                <ButtonColorful label={card.buttonLabel} />
              </Link>
            </div>

            <ImageCursorTrail
              items={[card.src, card.src, card.src]}
              active={isHovered}
              maxNumberOfImages={3}
              distance={16}
              imgClass="w-16 h-20"
              className="!absolute !inset-0 !h-full !w-full !rounded-lg !bg-transparent"
            />
          </div>
        );
      })}
    </div>
  );
}

export default GalleryCursorTrail;
'@

Write-Utf8NoBom -Path $galleryTrailPath -Content $galleryTrailContent
Write-Host "Updated: $galleryTrailPath" -ForegroundColor Green

# ------------------------------------------------------------------
# 4. page.tsx: replace vertical right-column placement with the new
#    horizontal, smaller, fade-toward-text version.
# ------------------------------------------------------------------
$pageContent = [System.IO.File]::ReadAllText($pagePath)

$oldVerticalBlock = @'
        <div className="pointer-events-auto absolute right-0 top-1/2 z-10 hidden w-[380px] -translate-y-1/2 lg:block xl:right-4 xl:w-[420px]">
          <GalleryCursorTrail orientation="vertical" />
        </div>

        <HeroCursorTrail />
      </section>
'@

$newHorizontalBlock = @'
        <div className="pointer-events-auto absolute right-0 top-1/2 z-10 hidden -translate-y-1/2 lg:block xl:right-4">
          <GalleryCursorTrail />
        </div>

        <HeroCursorTrail />
      </section>
'@

if ($pageContent.Contains($oldVerticalBlock)) {
    $pageContent = $pageContent.Replace($oldVerticalBlock, $newHorizontalBlock)
    Write-Host "Replaced vertical gallery placement with horizontal version." -ForegroundColor Green
} elseif ($pageContent -match [regex]::Escape('<GalleryCursorTrail')) {
    # already horizontal call style (no orientation prop) - nothing to do
    Write-Host "GalleryCursorTrail usage already matches horizontal call signature." -ForegroundColor Yellow
} else {
    Write-Host "ERROR: expected vertical placement block not found - check page.tsx manually." -ForegroundColor Red
    exit 1
}

Write-Utf8NoBom -Path $pagePath -Content $pageContent
Write-Host "Updated: $pagePath" -ForegroundColor Green

# ------------------------------------------------------------------
# 5. Install required npm deps for ButtonColorful/shadcn Button
# ------------------------------------------------------------------
Write-Host "`nInstalling dependencies (@radix-ui/react-slot, class-variance-authority)..." -ForegroundColor Cyan
Push-Location $webApp
try {
    pnpm add @radix-ui/react-slot class-variance-authority
} finally {
    Pop-Location
}

Write-Host "`nDone. cd apps\web ; pnpm run build (or pnpm dev) to verify." -ForegroundColor Cyan