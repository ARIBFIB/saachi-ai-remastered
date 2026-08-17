<#
  Apply-InstructorSidebar.ps1
  Redesigns the Instructor Module sidebar (apps/web) into a two-level
  sidebar (icon rail + expandable detail panel), inspired by the shared
  sidebar-component.tsx example, adapted to lucide-react + existing theme.

  Run from: SAI2 root
    PS D:\...\SAI2> .\Apply-InstructorSidebar.ps1
#>

$ErrorActionPreference = "Stop"

$root = Get-Location
$webApp = Join-Path $root "apps\web"

if (-not (Test-Path $webApp)) {
    Write-Host "ERROR: apps\web not found. Run this script from the SAI2 root." -ForegroundColor Red
    exit 1
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

function Backup-File($path) {
    if (Test-Path $path) {
        $backupPath = "$path.bak-$timestamp"
        Copy-Item $path $backupPath
        Write-Host "  Backed up -> $backupPath"
    }
}

Write-Host "== Instructor Sidebar Redesign ==" -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. Paths
# ---------------------------------------------------------------------------
$componentsUiDir   = Join-Path $webApp "components\ui"
$instructorCompDir = Join-Path $webApp "app\(instructor)\_components"

$newSidebarComponent = Join-Path $componentsUiDir "instructor-sidebar-v2.tsx"
$instructorShellFile = Join-Path $instructorCompDir "InstructorShell.tsx"
$twoLevelSidebarFile = Join-Path $instructorCompDir "InstructorTwoLevelSidebar.tsx"

if (-not (Test-Path $componentsUiDir))   { New-Item -ItemType Directory -Path $componentsUiDir -Force | Out-Null }
if (-not (Test-Path $instructorCompDir)) { Write-Host "ERROR: (instructor)/_components not found." -ForegroundColor Red; exit 1 }

# ---------------------------------------------------------------------------
# 2. Backups
# ---------------------------------------------------------------------------
Write-Host "`nStep 1: Backing up existing files..."
Backup-File $instructorShellFile
Backup-File $twoLevelSidebarFile

# ---------------------------------------------------------------------------
# 3. New shared sidebar component (icon rail + detail panel)
# ---------------------------------------------------------------------------
Write-Host "`nStep 2: Writing new component -> components/ui/instructor-sidebar-v2.tsx"

$sidebarComponentContent = @'
"use client";

/**
 * Instructor Module - Two-level sidebar (icon rail + expandable detail panel)
 * Frontend-only. All counts/sub-items below are DUMMY data - swap for real
 * hooks (useInstructorCourses, useInstructorReviews, etc.) once available.
 */

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import {
  LayoutDashboard,
  BookOpen,
  PlusCircle,
  Star,
  Users,
  Rocket,
  BarChart3,
  Wallet,
  CalendarClock,
  Settings as SettingsIcon,
  ShieldCheck,
  Search,
  ChevronDown,
  ChevronLeft,
  ChevronRight,
  type LucideIcon
} from "lucide-react";
import { cn } from "@/lib/utils";

const softSpring = "cubic-bezier(0.25, 1.1, 0.4, 1)";

/* ------------------------------- Data model ------------------------------ */

export type InstructorSubItem = {
  label: string;
  href: string;
  meta?: string; // dummy stat shown next to the sub-item, e.g. "12"
};

export type InstructorSectionItem = {
  label: string;
  href: string;
  hasChildren?: boolean;
  children?: InstructorSubItem[];
};

export type InstructorNavGroup = {
  id: string;
  label: string;
  icon: LucideIcon;
  badge?: string; // dummy notification-style badge on the icon rail
  items: InstructorSectionItem[];
};

// NOTE: demo-only dummy sub-items and counts, purely for frontend UI.
// Replace `meta` values with real query results once wired to the backend.
export const INSTRUCTOR_SIDEBAR: InstructorNavGroup[] = [
  {
    id: "overview",
    label: "Dashboard",
    icon: LayoutDashboard,
    items: [{ label: "Overview", href: "/instructor/dashboard" }]
  },
  {
    id: "courses",
    label: "Courses",
    icon: BookOpen,
    badge: "4",
    items: [
      {
        label: "My Courses",
        href: "/instructor/courses",
        hasChildren: true,
        children: [
          { label: "Published", href: "/instructor/courses?status=published", meta: "1" },
          { label: "Pending review", href: "/instructor/courses?status=pending_review", meta: "1" },
          { label: "Draft", href: "/instructor/courses?status=draft", meta: "1" },
          { label: "Rejected", href: "/instructor/courses?status=rejected", meta: "1" }
        ]
      },
      { label: "Create Course", href: "/instructor/courses/new" }
    ]
  },
  {
    id: "students",
    label: "Students",
    icon: Users,
    badge: "2",
    items: [
      {
        label: "All Students",
        href: "/instructor/students",
        hasChildren: true,
        children: [
          { label: "New this week", href: "/instructor/students", meta: "2" },
          { label: "Completed course", href: "/instructor/students", meta: "8" },
          { label: "In progress", href: "/instructor/students", meta: "5" }
        ]
      }
    ]
  },
  {
    id: "reviews",
    label: "Reviews",
    icon: Star,
    badge: "3",
    items: [
      {
        label: "Recent Reviews",
        href: "/instructor/reviews",
        hasChildren: true,
        children: [
          { label: "Awaiting reply", href: "/instructor/reviews", meta: "3" },
          { label: "5-star reviews", href: "/instructor/reviews", meta: "12" },
          { label: "All reviews", href: "/instructor/reviews" }
        ]
      }
    ]
  },
  {
    id: "growth",
    label: "Growth",
    icon: Rocket,
    items: [
      { label: "Promotions", href: "/instructor/promotions" },
      {
        label: "Analytics",
        href: "/instructor/analytics",
        hasChildren: true,
        children: [
          { label: "Enrollment trends", href: "/instructor/analytics" },
          { label: "Completion rate", href: "/instructor/analytics" },
          { label: "Traffic sources", href: "/instructor/analytics" }
        ]
      }
    ]
  },
  {
    id: "finance",
    label: "Earnings",
    icon: Wallet,
    items: [
      {
        label: "Earnings",
        href: "/instructor/earnings",
        hasChildren: true,
        children: [
          { label: "Available balance", href: "/instructor/earnings" },
          { label: "Lifetime earnings", href: "/instructor/earnings" },
          { label: "Request payout", href: "/instructor/earnings" }
        ]
      }
    ]
  },
  {
    id: "mentorship",
    label: "Mentorship",
    icon: CalendarClock,
    items: [{ label: "Mentorship Settings", href: "/instructor/mentorship" }]
  },
  {
    id: "account",
    label: "Account",
    icon: SettingsIcon,
    items: [
      { label: "Settings", href: "/instructor/settings" },
      { label: "Verification", href: "/instructor/verification" }
    ]
  }
];

/* --------------------------------- Icon rail ------------------------------ */

export function InstructorIconRail({
  activeGroupId,
  onSelect
}: {
  activeGroupId: string;
  onSelect: (id: string) => void;
}) {
  return (
    <div className="hidden md:flex w-16 shrink-0 flex-col items-center gap-2 border-r border-line bg-card py-4">
      {INSTRUCTOR_SIDEBAR.map((group) => {
        const Icon = group.icon;
        const isActive = group.id === activeGroupId;
        return (
          <button
            key={group.id}
            type="button"
            title={group.label}
            onClick={() => onSelect(group.id)}
            className={cn(
              "relative flex h-10 w-10 shrink-0 items-center justify-center rounded-control transition-colors duration-200 ease-out",
              isActive ? "bg-gold text-ink" : "text-ink-soft hover:bg-paper-dim hover:text-ink"
            )}
            style={{ transitionTimingFunction: softSpring }}
          >
            <Icon size={17} strokeWidth={1.75} />
            {group.badge && (
              <span className="absolute -right-1 -top-1 flex h-4 min-w-4 items-center justify-center rounded-full bg-gold-dark px-1 text-[9px] font-semibold text-white">
                {group.badge}
              </span>
            )}
          </button>
        );
      })}
    </div>
  );
}

/* ------------------------------- Detail panel ----------------------------- */

export function InstructorDetailPanel({
  activeGroupId,
  onNavigate,
  showBrand = false
}: {
  activeGroupId: string;
  onNavigate?: () => void;
  showBrand?: boolean;
}) {
  const pathname = usePathname();
  const [expanded, setExpanded] = useState<Set<string>>(new Set());
  const [collapsed, setCollapsed] = useState(false);
  const [search, setSearch] = useState("");

  const group = INSTRUCTOR_SIDEBAR.find((g) => g.id === activeGroupId) ?? INSTRUCTOR_SIDEBAR[0];

  const toggle = (key: string) => {
    setExpanded((prev) => {
      const next = new Set(prev);
      if (next.has(key)) next.delete(key);
      else next.add(key);
      return next;
    });
  };

  const filteredItems = search.trim()
    ? group.items.filter((item) => item.label.toLowerCase().includes(search.toLowerCase()))
    : group.items;

  return (
    <div
      className={cn(
        "flex h-full flex-col gap-4 border-r border-line bg-card py-4 transition-[width] duration-300 ease-out",
        collapsed ? "w-16 items-center px-0" : "w-64 px-3"
      )}
      style={{ transitionTimingFunction: softSpring }}
    >
      {showBrand && !collapsed && (
        <Link href="/instructor/dashboard" className="flex items-center gap-2 px-2 pb-2">
          <span className="font-display text-[16px] font-bold text-ink">
            Saachi<span className="text-gold-dark">AI</span>
          </span>
          <span className="rounded-full bg-paper-dim px-2 py-0.5 text-[10px] font-semibold uppercase tracking-[0.06em] text-ink-soft">
            Instructor
          </span>
        </Link>
      )}

      {/* Section title + collapse toggle */}
      <div className={cn("flex items-center", collapsed ? "justify-center" : "justify-between px-1")}>
        {!collapsed && (
          <span className="font-display text-[15px] font-semibold text-ink">{group.label}</span>
        )}
        <button
          type="button"
          aria-label={collapsed ? "Expand panel" : "Collapse panel"}
          onClick={() => setCollapsed((v) => !v)}
          className="flex h-8 w-8 items-center justify-center rounded-control text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-ink"
        >
          {collapsed ? <ChevronRight size={15} /> : <ChevronLeft size={15} />}
        </button>
      </div>

      {/* Search */}
      {!collapsed && (
        <div className="flex h-10 items-center gap-2 rounded-control border border-line bg-paper-dim px-3">
          <Search size={14} className="shrink-0 text-ink-soft" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search..."
            className="w-full bg-transparent text-[13px] text-ink placeholder:text-ink-soft/60 outline-none"
          />
        </div>
      )}

      {/* Items */}
      <nav className="flex flex-1 flex-col gap-1 overflow-y-auto">
        {filteredItems.map((item, idx) => {
          const itemKey = `${group.id}-${idx}`;
          const isExpanded = expanded.has(itemKey);
          const isActive = pathname === item.href || Boolean(pathname?.startsWith(item.href.split("?")[0] + "/"));

          return (
            <div key={itemKey} className="flex flex-col">
              {item.hasChildren ? (
                <button
                  type="button"
                  onClick={() => toggle(itemKey)}
                  title={collapsed ? item.label : undefined}
                  className={cn(
                    "flex items-center gap-2 rounded-control px-2.5 py-2 text-left text-[13px] font-medium transition-colors duration-150 ease-out",
                    collapsed ? "justify-center" : "justify-between",
                    isActive ? "bg-gold text-ink" : "text-ink-soft hover:bg-paper-dim hover:text-ink"
                  )}
                >
                  {!collapsed && <span className="truncate">{item.label}</span>}
                  {!collapsed && (
                    <ChevronDown
                      size={14}
                      className="shrink-0 transition-transform duration-200 ease-out"
                      style={{
                        transitionTimingFunction: softSpring,
                        transform: isExpanded ? "rotate(180deg)" : "rotate(0deg)"
                      }}
                    />
                  )}
                  {collapsed && <span className="h-1.5 w-1.5 rounded-full bg-current" />}
                </button>
              ) : (
                <Link
                  href={item.href}
                  onClick={onNavigate}
                  title={collapsed ? item.label : undefined}
                  className={cn(
                    "flex items-center rounded-control px-2.5 py-2 text-[13px] font-medium transition-colors duration-150 ease-out",
                    collapsed ? "justify-center" : "justify-start",
                    isActive ? "bg-gold text-ink" : "text-ink-soft hover:bg-paper-dim hover:text-ink"
                  )}
                >
                  {collapsed ? <span className="h-1.5 w-1.5 rounded-full bg-current" /> : item.label}
                </Link>
              )}

              {item.hasChildren && isExpanded && !collapsed && item.children && (
                <div className="ml-2 flex flex-col gap-0.5 border-l border-line pl-2 py-1">
                  {item.children.map((child, childIdx) => (
                    <Link
                      key={`${itemKey}-${childIdx}`}
                      href={child.href}
                      onClick={onNavigate}
                      className="flex items-center justify-between rounded-control px-2.5 py-1.5 text-[12.5px] text-ink-soft transition-colors duration-100 ease-out hover:bg-paper-dim hover:text-ink"
                    >
                      <span className="truncate">{child.label}</span>
                      {child.meta && (
                        <span className="ml-2 shrink-0 rounded-full bg-paper-dim px-1.5 py-0.5 text-[10px] font-semibold text-ink-soft">
                          {child.meta}
                        </span>
                      )}
                    </Link>
                  ))}
                </div>
              )}
            </div>
          );
        })}
      </nav>
    </div>
  );
}

/* ------------------------------ Combined (mobile) -------------------------- */

export function InstructorSidebarMobile({ onNavigate }: { onNavigate?: () => void }) {
  const [activeGroupId, setActiveGroupId] = useState("overview");

  return (
    <div className="flex h-full">
      <div className="flex w-16 shrink-0 flex-col items-center gap-2 border-r border-line bg-card py-4">
        {INSTRUCTOR_SIDEBAR.map((group) => {
          const Icon = group.icon;
          const isActive = group.id === activeGroupId;
          return (
            <button
              key={group.id}
              type="button"
              title={group.label}
              onClick={() => setActiveGroupId(group.id)}
              className={cn(
                "relative flex h-10 w-10 shrink-0 items-center justify-center rounded-control transition-colors duration-200 ease-out",
                isActive ? "bg-gold text-ink" : "text-ink-soft hover:bg-paper-dim hover:text-ink"
              )}
            >
              <Icon size={17} strokeWidth={1.75} />
              {group.badge && (
                <span className="absolute -right-1 -top-1 flex h-4 min-w-4 items-center justify-center rounded-full bg-gold-dark px-1 text-[9px] font-semibold text-white">
                  {group.badge}
                </span>
              )}
            </button>
          );
        })}
      </div>
      <InstructorDetailPanel activeGroupId={activeGroupId} onNavigate={onNavigate} showBrand />
    </div>
  );
}

export default InstructorSidebarMobile;
'@

Set-Content -Path $newSidebarComponent -Value $sidebarComponentContent -Encoding UTF8
Write-Host "  Written -> $newSidebarComponent"

# ---------------------------------------------------------------------------
# 4. Rewrite InstructorShell.tsx (desktop fixed sidebar + mobile drawer)
# ---------------------------------------------------------------------------
Write-Host "`nStep 3: Rewriting InstructorShell.tsx..."

$instructorShellContent = @'
"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, useRef, useState, type ReactNode } from "react";
import { Menu, X, LogOut, Bell, ChevronDown, Settings, User } from "lucide-react";
import { AnimatedThemeToggler } from "@/components/ui/animated-theme-toggler";
import { useSession, useLogout } from "@saachi/api-client";
import {
  INSTRUCTOR_SIDEBAR,
  InstructorIconRail,
  InstructorDetailPanel,
  InstructorSidebarMobile
} from "@/components/ui/instructor-sidebar-v2";

function cx(...parts: Array<string | false | undefined>) {
  return parts.filter(Boolean).join(" ");
}

type NotificationItem = { id: string; label: string; href: string };

// NOTE: demo-only dummy data. Replace with useInstructorNotifications() once confirmed.
const NOTIFICATIONS: NotificationItem[] = [
  { id: "n1", label: 'New review on "Automate Everything with n8n & AI"', href: "/instructor/reviews" },
  { id: "n2", label: "2 new students enrolled this week", href: "/instructor/students" },
  { id: "n3", label: "Your Silver Boost promotion expires in 4 days", href: "/instructor/promotions" }
];

function activeGroupIdFromPathname(pathname: string | null): string {
  if (!pathname) return "overview";
  const found = INSTRUCTOR_SIDEBAR.find((group) =>
    group.items.some((item) => pathname === item.href.split("?")[0] || pathname.startsWith(item.href.split("?")[0] + "/"))
  );
  return found?.id ?? "overview";
}

export function InstructorShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const { data: session } = useSession();
  const logout = useLogout();

  const [mobileOpen, setMobileOpen] = useState(false);
  const [notifOpen, setNotifOpen] = useState(false);
  const [userMenuOpen, setUserMenuOpen] = useState(false);
  const [activeGroupId, setActiveGroupId] = useState(() => activeGroupIdFromPathname(pathname));

  const notifRef = useRef<HTMLDivElement>(null);
  const userMenuRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    setActiveGroupId(activeGroupIdFromPathname(pathname));
  }, [pathname]);

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (notifRef.current && !notifRef.current.contains(e.target as Node)) setNotifOpen(false);
      if (userMenuRef.current && !userMenuRef.current.contains(e.target as Node)) setUserMenuOpen(false);
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  function handleLogout() {
    logout.mutate(undefined, { onSuccess: () => router.push("/login") });
  }

  return (
    <div className="min-h-screen bg-paper">
      {/* Desktop two-level sidebar (icon rail + detail panel) */}
      <div className="hidden md:fixed md:inset-y-0 md:flex">
        <InstructorIconRail activeGroupId={activeGroupId} onSelect={setActiveGroupId} />
        <InstructorDetailPanel activeGroupId={activeGroupId} showBrand />
      </div>

      {/* Top bar */}
      <div className="sticky top-0 z-40 flex items-center justify-between gap-3 border-b border-line bg-card/95 px-4 py-3 backdrop-blur-sm md:ml-[336px] md:px-6">
        <div className="flex min-w-0 items-center gap-3">
          <button
            type="button"
            onClick={() => setMobileOpen(true)}
            aria-label="Open menu"
            className="flex h-9 w-9 shrink-0 items-center justify-center rounded-control text-ink md:hidden"
          >
            <Menu size={18} strokeWidth={1.75} />
          </button>

          <Link href="/instructor/dashboard" className="flex shrink-0 items-center gap-2 md:hidden">
            <span className="font-display text-[16px] font-bold text-ink">
              Saachi<span className="text-gold-dark">AI</span>
            </span>
            <span className="rounded-full bg-paper-dim px-2 py-0.5 text-[10px] font-semibold uppercase tracking-[0.06em] text-ink-soft">
              Instructor
            </span>
          </Link>
        </div>

        <div className="flex items-center gap-2 sm:gap-3">
          <div className="relative" ref={notifRef}>
            <button
              type="button"
              onClick={() => setNotifOpen((v) => !v)}
              aria-label="Notifications"
              className="relative flex h-9 w-9 items-center justify-center rounded-control text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-ink"
            >
              <Bell size={17} strokeWidth={1.75} />
              {NOTIFICATIONS.length > 0 && (
                <span className="absolute right-1.5 top-1.5 flex h-4 min-w-4 items-center justify-center rounded-full bg-gold-dark px-1 text-[9px] font-semibold text-white">
                  {NOTIFICATIONS.length}
                </span>
              )}
            </button>

            {notifOpen && (
              <div className="absolute right-0 top-[calc(100%+8px)] w-[300px] overflow-hidden rounded-card border border-line bg-card shadow-lg">
                <div className="border-b border-line px-4 py-3">
                  <p className="text-[13px] font-semibold text-ink">Notifications</p>
                </div>
                <div className="flex flex-col">
                  {NOTIFICATIONS.map((n) => (
                    <Link
                      key={n.id}
                      href={n.href}
                      onClick={() => setNotifOpen(false)}
                      className="flex items-start gap-2.5 border-b border-line px-4 py-3 text-[12.5px] text-ink transition-colors duration-100 ease-out last:border-0 hover:bg-paper-dim"
                    >
                      <span className="mt-1 h-1.5 w-1.5 shrink-0 rounded-full bg-gold-dark" />
                      <span>{n.label}</span>
                    </Link>
                  ))}
                </div>
              </div>
            )}
          </div>

          <AnimatedThemeToggler />

          <div className="relative" ref={userMenuRef}>
            <button
              type="button"
              onClick={() => setUserMenuOpen((v) => !v)}
              className="flex min-w-0 items-center gap-2 rounded-control px-1.5 py-1 transition-colors duration-150 ease-out hover:bg-paper-dim"
            >
              <div className="flex h-8 w-8 shrink-0 items-center justify-center overflow-hidden rounded-full border border-line bg-gold-tint text-[12px] font-semibold text-gold-dark">
                {session?.avatarUrl ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={session.avatarUrl} alt={session.fullName} className="h-full w-full object-cover" />
                ) : (
                  (session?.fullName ?? "I").charAt(0)
                )}
              </div>
              <div className="hidden min-w-0 text-left sm:block">
                <div className="truncate text-[12.5px] font-semibold leading-tight text-ink">
                  {session?.fullName ?? "Instructor"}
                </div>
                <div className="truncate text-[11px] leading-tight text-ink-soft">Instructor</div>
              </div>
              <ChevronDown size={13} strokeWidth={1.75} className="hidden shrink-0 text-ink-soft sm:block" />
            </button>

            {userMenuOpen && (
              <div className="absolute right-0 top-[calc(100%+8px)] w-[220px] overflow-hidden rounded-card border border-line bg-card shadow-lg">
                <div className="border-b border-line px-4 py-3">
                  <p className="truncate text-[13px] font-semibold text-ink">{session?.fullName ?? "Instructor"}</p>
                  <p className="truncate text-[12px] text-ink-soft">{session?.email}</p>
                </div>
                <div className="flex flex-col p-1.5">
                  <Link
                    href="/instructor/settings"
                    onClick={() => setUserMenuOpen(false)}
                    className="flex items-center gap-2.5 rounded-control px-3 py-2 text-[13px] text-ink transition-colors duration-100 ease-out hover:bg-paper-dim"
                  >
                    <Settings size={14} strokeWidth={1.75} /> Settings
                  </Link>
                  <Link
                    href="/dashboard"
                    onClick={() => setUserMenuOpen(false)}
                    className="flex items-center gap-2.5 rounded-control px-3 py-2 text-[13px] text-ink transition-colors duration-100 ease-out hover:bg-paper-dim"
                  >
                    <User size={14} strokeWidth={1.75} /> Switch to learner view
                  </Link>
                  <button
                    type="button"
                    onClick={handleLogout}
                    className="flex items-center gap-2.5 rounded-control px-3 py-2 text-left text-[13px] text-error transition-colors duration-100 ease-out hover:bg-error-tint"
                  >
                    <LogOut size={14} strokeWidth={1.75} /> Log out
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Mobile drawer */}
      {mobileOpen && (
        <div className="fixed inset-0 z-50 flex md:hidden">
          <div
            className="absolute inset-0 bg-ink/40 transition-opacity duration-200 ease-out"
            onClick={() => setMobileOpen(false)}
          />
          <div className="relative flex h-full w-[300px] bg-card transition-transform duration-200 ease-out">
            <button
              type="button"
              onClick={() => setMobileOpen(false)}
              aria-label="Close menu"
              className="absolute right-2 top-2 z-10 flex h-8 w-8 items-center justify-center rounded-control bg-card text-ink shadow"
            >
              <X size={16} strokeWidth={1.75} />
            </button>
            <InstructorSidebarMobile onNavigate={() => setMobileOpen(false)} />
          </div>
        </div>
      )}

      <div className="md:ml-[336px]">
        <main className="mx-auto max-w-[1200px] px-4 py-8 md:px-8 md:py-10">{children}</main>
      </div>
    </div>
  );
}
'@

Set-Content -Path $instructorShellFile -Value $instructorShellContent -Encoding UTF8
Write-Host "  Written -> $instructorShellFile"

# ---------------------------------------------------------------------------
# 5. Replace InstructorTwoLevelSidebar.tsx with a thin re-export (kept for
#    backward compatibility with any other file importing it directly)
# ---------------------------------------------------------------------------
Write-Host "`nStep 4: Rewriting InstructorTwoLevelSidebar.tsx (compat re-export)..."

$twoLevelSidebarContent = @'
"use client";

// Compatibility shim: the two-level sidebar now lives in
// components/ui/instructor-sidebar-v2.tsx (InstructorSidebarMobile).
// This file is kept so any existing import of InstructorTwoLevelSidebar
// keeps working without changes elsewhere.

import { InstructorSidebarMobile } from "@/components/ui/instructor-sidebar-v2";

export function InstructorTwoLevelSidebar({ onNavigate }: { onNavigate?: () => void }) {
  return <InstructorSidebarMobile onNavigate={onNavigate} />;
}

export default InstructorTwoLevelSidebar;
'@

Set-Content -Path $twoLevelSidebarFile -Value $twoLevelSidebarContent -Encoding UTF8
Write-Host "  Written -> $twoLevelSidebarFile"

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
Write-Host "`n== Done ==" -ForegroundColor Green
Write-Host "Changed files:"
Write-Host "  - apps/web/components/ui/instructor-sidebar-v2.tsx  (new)"
Write-Host "  - apps/web/app/(instructor)/_components/InstructorShell.tsx  (rewritten, backup saved)"
Write-Host "  - apps/web/app/(instructor)/_components/InstructorTwoLevelSidebar.tsx  (rewritten, backup saved)"
Write-Host "`nNo new npm packages needed (uses existing lucide-react)."
Write-Host "Next: cd apps\web ; npm run dev  -- then open /instructor/dashboard to check."