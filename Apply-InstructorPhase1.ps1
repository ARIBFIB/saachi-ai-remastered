<#
  Apply-InstructorPhase1.ps1
  PHASE 1: Instructor sidebar restructure (9 groups) + route scaffolding.
  Frontend-only, apps/web, Instructor Module.

  Run from: SAI2 root
    PS D:\...\SAI2> .\Apply-InstructorPhase1.ps1
#>

$ErrorActionPreference = "Stop"

$root = Get-Location
$webApp = Join-Path $root "apps\web"
$instructorAppDir = Join-Path $webApp "app\(instructor)\instructor"
$componentsUiDir  = Join-Path $webApp "components\ui"

if (-not (Test-Path $webApp)) {
    Write-Host "ERROR: apps\web not found. Run this script from the SAI2 root." -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $instructorAppDir)) {
    Write-Host "ERROR: app/(instructor)/instructor not found." -ForegroundColor Red
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

function Write-PlaceholderPage {
    param(
        [string]$RelativeRoute,   # e.g. "courses/curriculum"
        [string]$Title,
        [string]$Description
    )
    $dir = Join-Path $instructorAppDir $RelativeRoute
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $file = Join-Path $dir "page.tsx"

    if (Test-Path $file) {
        Write-Host "  Skipped (already exists): instructor/$RelativeRoute/page.tsx"
        return
    }

    $componentName = ($RelativeRoute -split '[\\/]' | ForEach-Object {
        if ($_ -match '^\[.*\]$') { "Param" } else { (Get-Culture).TextInfo.ToTitleCase($_) }
    }) -join ''
    $componentName = "Instructor$($componentName)Page"

    $content = @"
"use client";

import { EmptyState } from "@saachi/ui";

// Phase 1 scaffold - placeholder route so sidebar navigation works end-to-end.
// Real content/dummy data for this screen is filled in a later phase.
export default function $componentName() {
  return (
    <div>
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">$Title</h1>
      <p className="mb-8 text-[14px] text-ink-soft">$Description</p>

      <EmptyState
        title="Coming soon"
        description="This section is scaffolded and will be filled in during a later phase."
      />
    </div>
  );
}
"@
    Set-Content -Path $file -Value $content -Encoding UTF8
    Write-Host "  Created -> instructor/$RelativeRoute/page.tsx"
}

Write-Host "== Instructor Module - Phase 1: Sidebar Restructure + Scaffolding ==" -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. Backup + rewrite the sidebar data/component with 9 groups
# ---------------------------------------------------------------------------
$sidebarFile = Join-Path $componentsUiDir "instructor-sidebar-v2.tsx"
Write-Host "`nStep 1: Backing up + rewriting instructor-sidebar-v2.tsx..."
Backup-File $sidebarFile

$sidebarContent = @'
"use client";

/**
 * Instructor Module - Two-level sidebar (icon rail + expandable detail panel)
 * Frontend-only. All counts/sub-items below are DUMMY data - swap for real
 * hooks (useInstructorCourses, useInstructorPayouts, etc.) once available.
 *
 * PHASE 1: restructured into 9 groups per Doc 2 (Frontend Technical Spec),
 * Section 12 - Instructor Portal page inventory. Routes for new items are
 * scaffolded as placeholder pages and filled in over later phases.
 */

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import {
  LayoutDashboard,
  BookOpen,
  PlusCircle,
  ListTree,
  HelpCircle,
  Eye,
  Star,
  Users,
  MessageSquare,
  Activity,
  Rocket,
  BarChart3,
  Wallet,
  Banknote,
  CreditCard,
  CalendarClock,
  CalendarDays,
  Inbox,
  Settings as SettingsIcon,
  ShieldCheck,
  BellRing,
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
          { label: "Rejected", href: "/instructor/courses?status=rejected", meta: "1" },
          { label: "Archived", href: "/instructor/courses?status=archived", meta: "0" }
        ]
      },
      { label: "Create Course", href: "/instructor/courses/new" },
      { label: "Curriculum Builder", href: "/instructor/courses/curriculum" },
      { label: "Quiz Builder", href: "/instructor/courses/quiz-builder" },
      { label: "Course Preview", href: "/instructor/courses/preview" }
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
      },
      { label: "Engagement Status", href: "/instructor/students/engagement" },
      { label: "Message Students", href: "/instructor/students/messages" }
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
          { label: "Traffic sources", href: "/instructor/analytics" },
          { label: "Engagement heatmap", href: "/instructor/analytics" }
        ]
      }
    ]
  },
  {
    id: "finance",
    label: "Finance",
    icon: Wallet,
    badge: "1",
    items: [
      { label: "Earnings Overview", href: "/instructor/earnings" },
      {
        label: "Payout Requests",
        href: "/instructor/payouts",
        hasChildren: true,
        children: [
          { label: "Pending", href: "/instructor/payouts", meta: "1" },
          { label: "Paid", href: "/instructor/payouts", meta: "6" },
          { label: "Rejected", href: "/instructor/payouts", meta: "0" }
        ]
      },
      { label: "Payout Methods", href: "/instructor/payouts/methods" }
    ]
  },
  {
    id: "mentorship",
    label: "Mentorship",
    icon: CalendarClock,
    badge: "1",
    items: [
      { label: "Mentorship Settings", href: "/instructor/mentorship" },
      { label: "Availability Calendar", href: "/instructor/mentorship/availability" },
      { label: "Session Requests", href: "/instructor/mentorship/requests" }
    ]
  },
  {
    id: "community",
    label: "Community",
    icon: MessageSquare,
    badge: "5",
    items: [
      {
        label: "Course Q&A",
        href: "/instructor/community",
        hasChildren: true,
        children: [
          { label: "Unanswered", href: "/instructor/community", meta: "5" },
          { label: "Answered", href: "/instructor/community", meta: "21" }
        ]
      }
    ]
  },
  {
    id: "account",
    label: "Account",
    icon: SettingsIcon,
    items: [
      { label: "Settings", href: "/instructor/settings" },
      { label: "Verification", href: "/instructor/verification" },
      { label: "Notification Preferences", href: "/instructor/settings/notifications" }
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
        collapsed ? "w-16 items-center px-0" : "w-72 px-3"
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

Set-Content -Path $sidebarFile -Value $sidebarContent -Encoding UTF8
Write-Host "  Written -> $sidebarFile"

# ---------------------------------------------------------------------------
# 2. Update InstructorShell.tsx width offsets (72-wide panel instead of 64)
# ---------------------------------------------------------------------------
$shellFile = Join-Path $webApp "app\(instructor)\_components\InstructorShell.tsx"
if (Test-Path $shellFile) {
    Write-Host "`nStep 2: Adjusting InstructorShell.tsx offsets for wider detail panel..."
    Backup-File $shellFile
    (Get-Content $shellFile -Raw) `
        -replace 'md:ml-\[336px\]', 'md:ml-[352px]' |
        Set-Content -Path $shellFile -Encoding UTF8
    Write-Host "  Updated offsets in InstructorShell.tsx"
} else {
    Write-Host "`nStep 2: InstructorShell.tsx not found, skipping offset adjustment." -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# 3. Scaffold new placeholder routes
# ---------------------------------------------------------------------------
Write-Host "`nStep 3: Scaffolding new route pages..."

Write-PlaceholderPage -RelativeRoute "courses\curriculum" -Title "Curriculum Builder" `
    -Description "Drag-and-drop module and lesson structuring for your courses."

Write-PlaceholderPage -RelativeRoute "courses\quiz-builder" -Title "Quiz Builder" `
    -Description "Build question banks and configure passing scores for your courses."

Write-PlaceholderPage -RelativeRoute "courses\preview" -Title "Course Preview" `
    -Description "Preview how your course appears to learners before publishing."

Write-PlaceholderPage -RelativeRoute "students\engagement" -Title "Engagement Status" `
    -Description "See which students are active, inactive, or have completed your courses."

Write-PlaceholderPage -RelativeRoute "students\messages" -Title "Message Students" `
    -Description "Send messages to individual students or broadcast to a whole course."

Write-PlaceholderPage -RelativeRoute "payouts" -Title "Payout Requests" `
    -Description "Request a payout and track the status of past requests."

Write-PlaceholderPage -RelativeRoute "payouts\methods" -Title "Payout Methods" `
    -Description "Configure your bank account, mobile wallet, or Stripe Connect details."

Write-PlaceholderPage -RelativeRoute "mentorship\availability" -Title "Availability Calendar" `
    -Description "Set your weekly availability for paid mentorship sessions."

Write-PlaceholderPage -RelativeRoute "mentorship\requests" -Title "Session Requests" `
    -Description "Review and respond to incoming mentorship session requests."

Write-PlaceholderPage -RelativeRoute "community" -Title "Community Q&A" `
    -Description "Answer learner questions across all of your courses."

Write-PlaceholderPage -RelativeRoute "settings\notifications" -Title "Notification Preferences" `
    -Description "Choose which events trigger an email or in-app notification."

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
Write-Host "`n== Phase 1 Complete ==" -ForegroundColor Green
Write-Host "Changed/created:"
Write-Host "  - apps/web/components/ui/instructor-sidebar-v2.tsx  (9 groups, backup saved)"
Write-Host "  - apps/web/app/(instructor)/_components/InstructorShell.tsx  (offset adjusted, backup saved)"
Write-Host "  - 11 new placeholder route pages under apps/web/app/(instructor)/instructor/*"
Write-Host "`nNo new npm packages needed (uses existing lucide-react)."
Write-Host "Next: cd apps\web ; npm run dev  -- then open /instructor/dashboard and click through the sidebar."
Write-Host "`nOnce you confirm Phase 1 looks right, tell me to start Phase 2 (Finance & Payouts)."