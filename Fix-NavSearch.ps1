# ============================================================
#  Saachi AI - Fix: TopSearchBar inside SiteHeader
#  Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2
#  PS> .\Fix-NavSearch.ps1
# ============================================================

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$web  = Join-Path $root "apps\web"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Fix: Nav + SearchBar Layering" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

function Write-File($path, $content) {
    $dir = Split-Path $path -Parent
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [System.IO.File]::WriteAllText($path, $content, [System.Text.UTF8Encoding]::new($false))
    Write-Host "  [OK] $path" -ForegroundColor Green
}

# ============================================================
#  FILE 1 — TopSearchBar  (no longer sticky — just a bar)
#  Hide logic stays here but position is now relative inside header
# ============================================================

$topSearchBar = @'
"use client";

import { useEffect, useMemo, useRef, useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { Search, ChevronDown, GraduationCap, Award, Newspaper, BookOpen, Users } from "lucide-react";
import { cn } from "@/lib/utils";
import {
  useCourseList,
  useNewsList,
  useBlogList,
  useCommunityList,
  useCertificateList
} from "@saachi/api-client";
import { CATEGORIES } from "../../lib/categories";
import { SearchCommand, type SearchGroup } from "@/components/ui/search-command";

/**
 * Returns true when the user is scrolling DOWN past 80 px.
 * Used by SiteHeader to collapse the search row.
 */
export function useSearchBarHidden() {
  const [hidden, setHidden] = useState(false);
  const lastY = useRef(0);
  useEffect(() => {
    lastY.current = window.scrollY;
    function onScroll() {
      const y = window.scrollY;
      setHidden(y > lastY.current && y > 80);
      lastY.current = y;
    }
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);
  return hidden;
}

export function TopSearchBar({ hidden }: { hidden: boolean }) {
  const router = useRouter();

  const [query, setQuery]       = useState("");
  const [deptOpen, setDeptOpen] = useState(false);
  const [department, setDept]   = useState<string | undefined>(undefined);
  const [open, setOpen]         = useState(false);

  const deptRef    = useRef<HTMLDivElement>(null);
  const wrapperRef = useRef<HTMLDivElement>(null);

  const courseQ = useCourseList({ search: query || undefined, category: department, sort: "popular" });
  const newsQ   = useNewsList({ search: query || undefined });
  const blogQ   = useBlogList({ search: query || undefined });
  const commQ   = useCommunityList({ search: query || undefined });
  const certQ   = useCertificateList({ search: query || undefined });

  const groups: SearchGroup[] = useMemo(() => [
    {
      key: "courses",
      label: "Courses",
      icon: <GraduationCap size={12} />,
      items: (courseQ.data?.items ?? []).slice(0, 5).map((c) => ({
        id: c.id,
        title: c.title,
        href: `/courses/${c.slug}`,
        sub: c.instructor.fullName
      }))
    },
    {
      key: "news",
      label: "News",
      icon: <Newspaper size={12} />,
      items: (newsQ.data ?? []).slice(0, 3).map((n) => ({
        id: n.id,
        title: n.title,
        href: `/news/${n.slug}`,
        sub: n.category
      }))
    },
    {
      key: "blog",
      label: "Blog",
      icon: <BookOpen size={12} />,
      items: (blogQ.data ?? []).slice(0, 3).map((b) => ({
        id: b.id,
        title: b.title,
        href: `/blog/${b.slug}`,
        sub: b.tag
      }))
    },
    {
      key: "community",
      label: "Community",
      icon: <Users size={12} />,
      items: (commQ.data ?? []).slice(0, 3).map((p) => ({
        id: p.id,
        title: p.title,
        href: `/community/${p.id}`,
        sub: p.category
      }))
    },
    {
      key: "certificates",
      label: "Certificates",
      icon: <Award size={12} />,
      items: (certQ.data ?? []).slice(0, 3).map((c) => ({
        id: c.id,
        title: c.courseTitle,
        href: `/certificates/${c.id}`,
        sub: c.learnerName
      }))
    }
  ], [courseQ.data, newsQ.data, blogQ.data, commQ.data, certQ.data]);

  // close dept dropdown on outside click
  useEffect(() => {
    function handle(e: MouseEvent) {
      if (deptRef.current && !deptRef.current.contains(e.target as Node)) setDeptOpen(false);
    }
    document.addEventListener("mousedown", handle);
    return () => document.removeEventListener("mousedown", handle);
  }, []);

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setOpen(false);
    const params = new URLSearchParams();
    if (query.trim()) params.set("q", query.trim());
    if (department)   params.set("category", department);
    router.push(`/search?${params.toString()}`);
  }

  const deptLabel = department
    ? CATEGORIES.find((c) => c.id === department)?.name ?? "Department"
    : "All depts";

  return (
    /*
     * overflow-hidden + max-h transition = smooth accordion collapse.
     * When hidden=true the bar slides up and disappears behind the nav bar
     * because the entire <header> is sticky — no z-index clipping needed.
     */
    <div
      className={cn(
        "overflow-hidden border-t border-black/10 transition-all duration-300 ease-in-out",
        hidden ? "max-h-0 opacity-0" : "max-h-20 opacity-100"
      )}
      style={{ backgroundImage: "var(--color-accent-gradient)" }}
    >
      <div className="mx-auto flex max-w-7xl items-center gap-3 px-4 py-3 md:px-8">
        {/* Search input + cmdk dropdown */}
        <form onSubmit={handleSubmit} className="relative flex-1 max-w-xl" ref={wrapperRef}>
          <div className="flex h-10 items-center gap-2 rounded-full border border-white/25 bg-white pl-4 pr-2 shadow-sm">
            <Search size={15} className="shrink-0 text-ink-soft" />
            <input
              value={query}
              onChange={(e) => { setQuery(e.target.value); setOpen(true); }}
              onFocus={() => setOpen(true)}
              placeholder="Search courses, news, community..."
              className="w-full bg-transparent text-[13px] text-ink placeholder:text-ink-soft/60 focus:outline-none"
            />

            {/* Department picker */}
            <div ref={deptRef} className="relative shrink-0">
              <button
                type="button"
                onClick={() => setDeptOpen((v) => !v)}
                className="flex items-center gap-1 rounded-full bg-paper-dim px-2.5 py-1.5 text-[11px] font-semibold text-ink-soft hover:text-ink transition-colors"
              >
                <span className="hidden max-w-[80px] truncate sm:inline">{deptLabel}</span>
                <ChevronDown size={11} className={cn("transition-transform duration-200", deptOpen && "rotate-180")} />
              </button>

              {deptOpen && (
                <div className="absolute right-0 top-[calc(100%+8px)] z-50 w-56 overflow-hidden rounded-xl border border-line bg-card shadow-xl">
                  <button
                    type="button"
                    onClick={() => { setDept(undefined); setDeptOpen(false); }}
                    className={cn("flex w-full items-center px-4 py-2.5 text-left text-[13px] hover:bg-paper-dim", !department ? "font-semibold text-accent-violet" : "text-ink")}
                  >
                    All departments
                  </button>
                  {CATEGORIES.map((cat) => (
                    <button
                      key={cat.id}
                      type="button"
                      onClick={() => { setDept(cat.id); setDeptOpen(false); }}
                      className={cn("flex w-full items-center px-4 py-2.5 text-left text-[13px] hover:bg-paper-dim", department === cat.id ? "font-semibold text-accent-violet" : "text-ink")}
                    >
                      {cat.name}
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* cmdk dropdown — renders below the white pill */}
          {open && (
            <SearchCommand
              query={query}
              groups={groups}
              onClose={() => setOpen(false)}
            />
          )}
        </form>

        {/* Search submit button */}
        <button
          type="button"
          onClick={handleSubmit as any}
          className="group/btn relative hidden h-10 shrink-0 items-center gap-1.5 overflow-hidden rounded-full bg-zinc-900 px-5 sm:flex"
        >
          <span className="absolute inset-0 bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500 opacity-50 blur transition-opacity duration-500 group-hover/btn:opacity-90" />
          <span className="relative flex items-center gap-1.5 text-[13px] font-semibold text-white">
            <Search size={14} />
            Search
          </span>
        </button>
      </div>
    </div>
  );
}

export default TopSearchBar;
'@

Write-File "$web\app\_components\TopSearchBar.tsx" $topSearchBar

# ============================================================
#  FILE 2 — SiteHeader  (owns sticky, controls hidden state)
# ============================================================

$siteHeader = @'
"use client";

import Link from "next/link";
import { useState } from "react";
import { ShoppingCart, Heart, Menu as MenuIcon, X, LogOut } from "lucide-react";
import { Button } from "@saachi/ui";
import { useCartStore, useWishlistStore } from "@saachi/store";
import { AnimatedThemeToggler } from "@/components/ui/animated-theme-toggler";
import { useSession, useLogout } from "@saachi/api-client";
import { Menu, MenuItem, HoveredLink } from "@/components/ui/navbar-menu";
import { CATEGORIES } from "../../lib/categories";
import { TopSearchBar, useSearchBarHidden } from "./TopSearchBar";

const MOBILE_NAV_LINKS = [
  { href: "/courses",                   label: "All courses" },
  { href: "/categories/ai-automation",  label: "Automation" },
  { href: "/categories/ai-marketing",   label: "Marketing" },
  { href: "/pricing",                   label: "Pricing" },
  { href: "/about",                     label: "About" }
];

export function SiteHeader() {
  const [mobileOpen, setMobileOpen] = useState(false);
  const [active, setActive]         = useState<string | null>(null);

  const cartCount     = useCartStore((s) => s.items.length);
  const wishlistCount = useWishlistStore((s) => s.items.length);
  const { data: session } = useSession();
  const logout = useLogout();

  // single scroll listener — shared by TopSearchBar visibility
  const searchHidden = useSearchBarHidden();

  return (
    /*
     * The entire header is sticky. TopSearchBar lives INSIDE it so it
     * naturally hides behind the nav bar when collapsed — no z-index tricks.
     */
    <header className="sticky top-0 z-40 border-b border-line bg-card/90 backdrop-blur">
      {/* ── top nav row ── */}
      <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 md:px-8">
        <Link href="/" className="font-display text-[20px] font-bold text-ink">
          Saachi<span className="text-gold-dark">AI</span>
        </Link>

        <div className="ml-3 hidden items-center gap-1 rounded-full border border-line bg-paper-dim px-2.5 py-1 text-[11px] font-semibold text-ink-soft lg:flex">
          <span className="text-gold-dark">4.8</span>
          <span aria-hidden="true">&#9733;</span>
          <span>Rated by learners</span>
        </div>

        {/* desktop nav */}
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

        {/* right icons */}
        <div className="flex items-center gap-2">
          <AnimatedThemeToggler />

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
                <Button size="sm" variant="secondary">Log in</Button>
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

      {/* ── search bar row — inside header, collapses on scroll ── */}
      <TopSearchBar hidden={searchHidden} />

      {/* ── mobile nav ── */}
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
                    <Button size="sm" variant="secondary" className="w-full">Log in</Button>
                  </Link>
                  <Link href="/register" className="flex-1">
                    <Button size="sm" variant="brand" className="w-full">Sign up</Button>
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

Write-File "$web\app\_components\SiteHeader.tsx" $siteHeader

# ============================================================
#  Done
# ============================================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Done! Start dev server:" -ForegroundColor Cyan
Write-Host "  cd apps\web && npm run dev" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""