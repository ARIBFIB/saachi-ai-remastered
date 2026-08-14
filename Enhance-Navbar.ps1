<#
============================================================================
 Enhance-Navbar.ps1
 Saachi AI (SAI2) - Hover Dropdown Top Navbar
----------------------------------------------------------------------------
 Run from the repo root:
     PS D:\...\SAI2> .\Enhance-Navbar.ps1

 What it does:
   1. Adds apps\web\components\ui\navbar-menu.tsx (Aceternity-style menu)
   2. Backs up apps\web\app\_components\SiteHeader.tsx -> .bak-<timestamp>
   3. Rewrites SiteHeader.tsx to use the new hover-dropdown menu for
      Courses / For Instructors / Company, keeping logo, theme toggle,
      wishlist, cart, and auth buttons exactly as before.

 Safe to re-run: SiteHeader.tsx is always backed up first.
============================================================================
#>

$ErrorActionPreference = "Stop"

$Root    = $PSScriptRoot
if (-not $Root) { $Root = Get-Location }

$WebApp  = Join-Path $Root "apps\web"
$AppDir  = Join-Path $WebApp "app"
$CompDir = Join-Path $AppDir "_components"
$UiDir   = Join-Path $WebApp "components\ui"

foreach ($dir in @($CompDir, $UiDir)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Write-Host "Created dir: $dir" -ForegroundColor DarkGray
    }
}

function Write-File {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )
    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $encoding = New-Object System.Text.UTF8Encoding($false)
    $stream = New-Object System.IO.FileStream($fullPath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
    try {
        $writer = New-Object System.IO.StreamWriter($stream, $encoding)
        try {
            $writer.Write($Content)
        }
        finally {
            $writer.Flush()
            $writer.Dispose()
        }
    }
    finally {
        $stream.Dispose()
    }
    Write-Host "Wrote: $fullPath" -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# 0. Backup existing SiteHeader.tsx
# ---------------------------------------------------------------------------
$HeaderPath = Join-Path $CompDir "SiteHeader.tsx"
if (Test-Path $HeaderPath) {
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backup = Join-Path $CompDir "SiteHeader.tsx.bak-$stamp"
    Copy-Item $HeaderPath $backup
    Write-Host "Backed up SiteHeader.tsx -> $backup" -ForegroundColor Yellow
} else {
    Write-Host "WARNING: SiteHeader.tsx not found at $HeaderPath (continuing anyway)" -ForegroundColor Red
}

# ---------------------------------------------------------------------------
# 1. components/ui/navbar-menu.tsx
# ---------------------------------------------------------------------------
$navbarMenu = @'
"use client";
import React from "react";
import { motion } from "framer-motion";
import Link from "next/link";
import Image from "next/image";
import { cn } from "@/lib/utils";

const transition = {
  type: "spring",
  mass: 0.5,
  damping: 11.5,
  stiffness: 100,
  restDelta: 0.001,
  restSpeed: 0.001,
};

export const MenuItem = ({
  setActive,
  active,
  item,
  children,
}: {
  setActive: (item: string) => void;
  active: string | null;
  item: string;
  children?: React.ReactNode;
}) => {
  return (
    <div onMouseEnter={() => setActive(item)} className="relative">
      <motion.p
        transition={{ duration: 0.3 }}
        className="cursor-pointer text-[14px] font-medium text-ink-soft transition-colors hover:text-ink"
      >
        {item}
      </motion.p>
      {active !== null && (
        <motion.div
          initial={{ opacity: 0, scale: 0.85, y: 10 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          transition={transition}
        >
          {active === item && (
            <div className="absolute top-[calc(100%_+_1.2rem)] left-1/2 -translate-x-1/2 pt-4">
              <motion.div
                transition={transition}
                layoutId="active"
                className="overflow-hidden rounded-2xl border border-line bg-card shadow-xl backdrop-blur-sm"
              >
                <motion.div layout className="h-full w-max p-4">
                  {children}
                </motion.div>
              </motion.div>
            </div>
          )}
        </motion.div>
      )}
    </div>
  );
};

export const Menu = ({
  setActive,
  children,
}: {
  setActive: (item: string | null) => void;
  children: React.ReactNode;
}) => {
  return (
    <nav
      onMouseLeave={() => setActive(null)}
      className="relative flex items-center justify-center gap-6"
    >
      {children}
    </nav>
  );
};

export const ProductItem = ({
  title,
  description,
  href,
  src,
}: {
  title: string;
  description: string;
  href: string;
  src: string;
}) => {
  return (
    <Link href={href} className="flex gap-3">
      <Image
        src={src}
        width={128}
        height={64}
        alt={title}
        className="h-16 w-32 shrink-0 rounded-md object-cover shadow-lg"
      />
      <div>
        <h4 className="mb-1 text-[14.5px] font-semibold text-ink">{title}</h4>
        <p className="max-w-[10rem] text-[12.5px] leading-snug text-ink-soft">{description}</p>
      </div>
    </Link>
  );
};

export const HoveredLink = ({ children, className, ...rest }: any) => {
  return (
    <Link
      {...rest}
      className={cn("text-[13.5px] text-ink-soft transition-colors hover:text-ink", className)}
    >
      {children}
    </Link>
  );
};
'@
Write-File (Join-Path $UiDir "navbar-menu.tsx") $navbarMenu

# ---------------------------------------------------------------------------
# 2. app/_components/SiteHeader.tsx (full rewrite)
# ---------------------------------------------------------------------------
$siteHeader = @'
"use client";

import Link from "next/link";
import { useState } from "react";
import { ShoppingCart, Heart, Menu as MenuIcon, X, LogOut } from "lucide-react";
import { Button, ThemeToggle } from "@saachi/ui";
import { useCartStore, useWishlistStore } from "@saachi/store";
import { useSession, useLogout } from "@saachi/api-client";
import { Menu, MenuItem, HoveredLink } from "@/components/ui/navbar-menu";
import { CATEGORIES } from "../../lib/categories";

const MOBILE_NAV_LINKS = [
  { href: "/courses", label: "All courses" },
  { href: "/categories/ai-automation", label: "Automation" },
  { href: "/categories/ai-marketing", label: "Marketing" },
  { href: "/pricing", label: "Pricing" },
  { href: "/about", label: "About" }
];

export function SiteHeader() {
  const [mobileOpen, setMobileOpen] = useState(false);
  const [active, setActive] = useState<string | null>(null);
  const cartCount = useCartStore((s) => s.items.length);
  const wishlistCount = useWishlistStore((s) => s.items.length);
  const { data: session } = useSession();
  const logout = useLogout();

  return (
    <header className="sticky top-0 z-40 border-b border-line bg-card/90 backdrop-blur">
      <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 md:px-8">
        <Link href="/" className="font-display text-[20px] font-bold text-ink">
          Saachi<span className="text-gold-dark">AI</span>
        </Link>

        <div className="hidden md:block">
          <Menu setActive={setActive}>
            <MenuItem setActive={setActive} active={active} item="Courses">
              <div className="grid grid-cols-2 gap-x-10 gap-y-2 p-1 text-sm">
                {CATEGORIES.map((cat) => (
                  <HoveredLink key={cat.id} href={`/categories/${cat.slug}`}>
                    {cat.name}
                  </HoveredLink>
                ))}
                <HoveredLink href="/courses" className="font-semibold text-gold-dark">
                  Browse all courses &rarr;
                </HoveredLink>
              </div>
            </MenuItem>

            <MenuItem setActive={setActive} active={active} item="For Instructors">
              <div className="flex flex-col gap-3 text-sm">
                <HoveredLink href="/register">Become an instructor</HoveredLink>
                <HoveredLink href="/mentorship">Offer mentorship</HoveredLink>
                <HoveredLink href="/legal/instructor-agreement">Instructor agreement</HoveredLink>
              </div>
            </MenuItem>

            <MenuItem setActive={setActive} active={active} item="Company">
              <div className="flex flex-col gap-3 text-sm">
                <HoveredLink href="/about">About us</HoveredLink>
                <HoveredLink href="/pricing">Pricing</HoveredLink>
                <HoveredLink href="/contact">Contact</HoveredLink>
              </div>
            </MenuItem>
          </Menu>
        </div>

        <div className="flex items-center gap-2">
          <ThemeToggle />

          <Link
            href="/wishlist"
            aria-label="Wishlist"
            className="relative flex h-9 w-9 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim"
          >
            <Heart size={18} />
            {wishlistCount > 0 && (
              <span className="absolute -right-0.5 -top-0.5 flex h-4 w-4 items-center justify-center rounded-full bg-gold text-[10px] font-bold text-ink">
                {wishlistCount}
              </span>
            )}
          </Link>

          <Link
            href="/cart"
            aria-label="Cart"
            className="relative flex h-9 w-9 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim"
          >
            <ShoppingCart size={18} />
            {cartCount > 0 && (
              <span className="absolute -right-0.5 -top-0.5 flex h-4 w-4 items-center justify-center rounded-full bg-gold text-[10px] font-bold text-ink">
                {cartCount}
              </span>
            )}
          </Link>

          {session ? (
            <div className="hidden items-center gap-2 md:flex">
              <span className="text-[13px] text-ink-soft">{session.fullName}</span>
              <Button size="sm" variant="ghost" onClick={() => logout.mutate()} aria-label="Log out">
                <LogOut size={14} />
              </Button>
            </div>
          ) : (
            <div className="hidden items-center gap-2 md:flex">
              <Link href="/login">
                <Button size="sm" variant="secondary">
                  Log in
                </Button>
              </Link>
              <Link href="/register">
                <Button size="sm" variant="brand">Sign up</Button>
              </Link>
            </div>
          )}

          <button
            type="button"
            className="flex h-9 w-9 items-center justify-center rounded-control text-ink-soft md:hidden"
            onClick={() => setMobileOpen((v) => !v)}
            aria-label="Toggle menu"
          >
            {mobileOpen ? <X size={20} /> : <MenuIcon size={20} />}
          </button>
        </div>
      </div>

      {mobileOpen && (
        <div className="border-t border-line bg-card px-4 py-4 md:hidden">
          <nav className="flex flex-col gap-3">
            {MOBILE_NAV_LINKS.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                onClick={() => setMobileOpen(false)}
                className="text-[15px] font-medium text-ink"
              >
                {link.label}
              </Link>
            ))}
            <div className="mt-2 flex gap-2">
              {session ? (
                <Button size="sm" variant="secondary" onClick={() => logout.mutate()} className="w-full">
                  Log out
                </Button>
              ) : (
                <>
                  <Link href="/login" className="flex-1">
                    <Button size="sm" variant="secondary" className="w-full">
                      Log in
                    </Button>
                  </Link>
                  <Link href="/register" className="flex-1">
                    <Button size="sm" variant="brand" className="w-full">
                      Sign up
                    </Button>
                  </Link>
                </>
              )}
            </div>
          </nav>
        </div>
      )}
    </header>
  );
}
'@
Write-File $HeaderPath $siteHeader

Write-Host ""
Write-Host "Done. New/updated files:" -ForegroundColor Cyan
Write-Host "  apps\web\components\ui\navbar-menu.tsx"
Write-Host "  apps\web\app\_components\SiteHeader.tsx  (backup saved alongside)"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  cd apps\web"
Write-Host "  pnpm dev"