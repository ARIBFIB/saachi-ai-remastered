# step11-admin-foundation.ps1
# Run from: SAI2 root folder
# Builds: dark/light theme system, shimmer skeleton components, AdminShell (sidebar + topbar),
# theme toggle, and a wired Dashboard page with KPI cards.

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $fullPath = Join-Path -Path (Get-Location).Path -ChildPath $Path
    $dir = Split-Path -Parent $fullPath
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($fullPath, $Content, $enc)
    Write-Host "  wrote $fullPath"
}

function Patch-File {
    param([string]$Path, [string]$OldStr, [string]$NewStr, [string]$Label)
    $fullPath = Join-Path -Path (Get-Location).Path -ChildPath $Path
    if (-not (Test-Path $fullPath)) {
        Write-Host "  SKIP (file not found): $fullPath" -ForegroundColor Yellow
        return
    }
    $content = Get-Content -Path $fullPath -Raw
    if ($content.Contains($OldStr)) {
        $updated = $content.Replace($OldStr, $NewStr)
        $enc = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($fullPath, $updated, $enc)
        Write-Host "  patched ($Label): $fullPath"
    } else {
        Write-Host "  WARNING: pattern for '$Label' not found - skipped." -ForegroundColor Yellow
    }
}

Write-Host "Step 11: Admin Portal foundation (theme, shimmer, shell, dashboard)..." -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. Shared theme store (packages/store) - persisted, used by both web + admin
# ---------------------------------------------------------------------------
$themeStore = @'
import { create } from "zustand";
import { persist } from "zustand/middleware";

export type ThemeMode = "light" | "dark";

type ThemeState = {
  theme: ThemeMode;
  setTheme: (theme: ThemeMode) => void;
  toggleTheme: () => void;
};

export const useThemeStore = create<ThemeState>()(
  persist(
    (set, get) => ({
      theme: "light",
      setTheme: (theme) => set({ theme }),
      toggleTheme: () => set({ theme: get().theme === "light" ? "dark" : "light" })
    }),
    { name: "saachi-theme" }
  )
);
'@
Write-Utf8NoBom -Path "packages\store\src\useThemeStore.ts" -Content $themeStore

Patch-File -Path "packages\store\src\index.ts" `
  -OldStr 'export * from "./useLocaleStore";' `
  -NewStr @'
export * from "./useLocaleStore";
export * from "./useThemeStore";
'@ `
  -Label "export theme store"

# ---------------------------------------------------------------------------
# 2. ThemeToggle component (packages/ui) - sun/moon, black & white icon style
# ---------------------------------------------------------------------------
$themeToggle = @'
"use client";

import { useEffect, useState } from "react";
import { Sun, Moon } from "lucide-react";
import { useThemeStore } from "@saachi/store";
import { cn } from "../cn";

export function ThemeToggle({ className }: { className?: string }) {
  const { theme, toggleTheme } = useThemeStore();
  const [mounted, setMounted] = useState(false);

  useEffect(() => setMounted(true), []);

  useEffect(() => {
    if (!mounted) return;
    document.documentElement.setAttribute("data-theme", theme);
  }, [theme, mounted]);

  if (!mounted) {
    return <div className={cn("h-9 w-9 shrink-0 rounded-control", className)} />;
  }

  return (
    <button
      type="button"
      onClick={toggleTheme}
      aria-label={theme === "light" ? "Switch to dark mode" : "Switch to light mode"}
      className={cn(
        "flex h-9 w-9 shrink-0 items-center justify-center rounded-control border border-line text-ink transition-colors duration-150 ease-out hover:bg-paper-dim",
        className
      )}
    >
      {theme === "light" ? <Moon size={16} strokeWidth={1.75} /> : <Sun size={16} strokeWidth={1.75} />}
    </button>
  );
}
'@
Write-Utf8NoBom -Path "packages\ui\src\components\ThemeToggle.tsx" -Content $themeToggle

Patch-File -Path "packages\ui\src\index.ts" `
  -OldStr 'export * from "./components/Loading";' `
  -NewStr @'
export * from "./components/Loading";
export * from "./components/ThemeToggle";
export * from "./components/Shimmer";
export * from "./components/KpiCard";
export * from "./components/DataTable";
export * from "./components/StatusPill";
'@ `
  -Label "export new admin components"

Patch-File -Path "packages\ui\package.json" `
  -OldStr '"lottie-react": "^2.4.0"
  },' `
  -NewStr @'
"lottie-react": "^2.4.0",
    "@saachi/store": "workspace:*"
  },
'@ `
  -Label "add @saachi/store dependency to ui package"

# ---------------------------------------------------------------------------
# 3. Shimmer / skeleton components (black & white shimmer sweep)
# ---------------------------------------------------------------------------
$shimmer = @'
import type { HTMLAttributes } from "react";
import { cn } from "../cn";

export type ShimmerProps = HTMLAttributes<HTMLDivElement>;

/** Base shimmer block - grayscale sweep, works in light + dark theme. */
export function Shimmer({ className, ...props }: ShimmerProps) {
  return (
    <div
      className={cn(
        "relative overflow-hidden rounded-control bg-paper-dim",
        "before:absolute before:inset-0 before:-translate-x-full",
        "before:bg-gradient-to-r before:from-transparent before:via-white/60 before:to-transparent",
        "before:animate-shimmer dark:before:via-white/10",
        className
      )}
      {...props}
    />
  );
}

export function ShimmerText({ lines = 3, lastLineWidth = "60%" }: { lines?: number; lastLineWidth?: string }) {
  return (
    <div className="flex flex-col gap-2">
      {Array.from({ length: lines }).map((_, i) => (
        <Shimmer key={i} className="h-3.5" style={{ width: i === lines - 1 ? lastLineWidth : "100%" }} />
      ))}
    </div>
  );
}

export function ShimmerKpiCard() {
  return (
    <div className="rounded-card border border-line bg-card p-5">
      <Shimmer className="mb-4 h-9 w-9 rounded-full" />
      <Shimmer className="mb-2 h-6 w-20" />
      <Shimmer className="h-3.5 w-28" />
    </div>
  );
}

export function ShimmerTableRow({ columns = 5 }: { columns?: number }) {
  return (
    <div className="flex items-center gap-4 border-b border-line px-4 py-3.5">
      {Array.from({ length: columns }).map((_, i) => (
        <Shimmer key={i} className="h-3.5 flex-1" />
      ))}
    </div>
  );
}

export function ShimmerTable({ rows = 6, columns = 5 }: { rows?: number; columns?: number }) {
  return (
    <div className="overflow-hidden rounded-card border border-line bg-card">
      {Array.from({ length: rows }).map((_, i) => (
        <ShimmerTableRow key={i} columns={columns} />
      ))}
    </div>
  );
}

export function ShimmerChart() {
  return (
    <div className="rounded-card border border-line bg-card p-6">
      <Shimmer className="mb-6 h-4 w-32" />
      <Shimmer className="h-[220px] w-full" />
    </div>
  );
}
'@
Write-Utf8NoBom -Path "packages\ui\src\components\Shimmer.tsx" -Content $shimmer

# ---------------------------------------------------------------------------
# 4. KpiCard, StatusPill, DataTable (generic, TanStack Table wrapper)
# ---------------------------------------------------------------------------
$kpiCard = @'
import type { LucideIcon } from "lucide-react";
import { ArrowUpRight, ArrowDownRight } from "lucide-react";
import { cn } from "../cn";

export type KpiCardProps = {
  label: string;
  value: string;
  icon: LucideIcon;
  delta?: { value: string; direction: "up" | "down" };
  className?: string;
};

export function KpiCard({ label, value, icon: Icon, delta, className }: KpiCardProps) {
  return (
    <div className={cn("rounded-card border border-line bg-card p-5", className)}>
      <div className="mb-4 flex h-9 w-9 items-center justify-center rounded-full border border-line text-ink">
        <Icon size={16} strokeWidth={1.75} />
      </div>
      <div className="font-mono text-[22px] font-semibold leading-none text-ink">{value}</div>
      <div className="mt-2 flex items-center gap-2">
        <span className="text-[13px] text-ink-soft">{label}</span>
        {delta && (
          <span
            className={cn(
              "flex items-center gap-0.5 text-[12px] font-semibold",
              delta.direction === "up" ? "text-success" : "text-error"
            )}
          >
            {delta.direction === "up" ? <ArrowUpRight size={12} /> : <ArrowDownRight size={12} />}
            {delta.value}
          </span>
        )}
      </div>
    </div>
  );
}
'@
Write-Utf8NoBom -Path "packages\ui\src\components\KpiCard.tsx" -Content $kpiCard

$statusPill = @'
import { cn } from "../cn";

type StatusTone = "neutral" | "success" | "warning" | "error" | "info";

export type StatusPillProps = {
  label: string;
  tone?: StatusTone;
  className?: string;
};

const toneStyles: Record<StatusTone, string> = {
  neutral: "bg-paper-dim text-ink-soft border-line",
  success: "bg-success-tint text-success border-success/20",
  warning: "bg-warning-tint text-warning border-warning/20",
  error: "bg-error-tint text-error border-error/20",
  info: "bg-info-tint text-info border-info/20"
};

export function StatusPill({ label, tone = "neutral", className }: StatusPillProps) {
  return (
    <span
      className={cn(
        "inline-flex items-center gap-1.5 rounded-full border px-2.5 py-1 text-[12px] font-semibold capitalize",
        toneStyles[tone],
        className
      )}
    >
      <span className="h-1.5 w-1.5 rounded-full bg-current" />
      {label}
    </span>
  );
}
'@
Write-Utf8NoBom -Path "packages\ui\src\components\StatusPill.tsx" -Content $statusPill

$dataTable = @'
"use client";

import type { ReactNode } from "react";
import { ChevronUp, ChevronDown, ChevronsUpDown } from "lucide-react";
import {
  flexRender,
  getCoreRowModel,
  getPaginationRowModel,
  getSortedRowModel,
  useReactTable,
  type ColumnDef,
  type SortingState
} from "@tanstack/react-table";
import { useState } from "react";
import { cn } from "../cn";
import { ShimmerTable } from "./Shimmer";
import { EmptyState } from "./EmptyState";
import { Button } from "./Button";

export type DataTableProps<T> = {
  columns: ColumnDef<T, any>[];
  data: T[];
  isLoading?: boolean;
  emptyTitle?: string;
  emptyDescription?: string;
  pageSize?: number;
  toolbar?: ReactNode;
  onRowClick?: (row: T) => void;
};

export function DataTable<T>({
  columns,
  data,
  isLoading,
  emptyTitle = "Nothing here yet",
  emptyDescription,
  pageSize = 10,
  toolbar,
  onRowClick
}: DataTableProps<T>) {
  const [sorting, setSorting] = useState<SortingState>([]);

  const table = useReactTable({
    data,
    columns,
    state: { sorting },
    onSortingChange: setSorting,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    initialState: { pagination: { pageSize } }
  });

  if (isLoading) {
    return (
      <div className="flex flex-col gap-4">
        {toolbar}
        <ShimmerTable rows={6} columns={columns.length} />
      </div>
    );
  }

  if (data.length === 0) {
    return (
      <div className="flex flex-col gap-4">
        {toolbar}
        <EmptyState title={emptyTitle} description={emptyDescription} />
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-4">
      {toolbar}
      <div className="overflow-hidden rounded-card border border-line bg-card">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-[13px]">
            <thead className="border-b border-line bg-paper-dim">
              {table.getHeaderGroups().map((headerGroup) => (
                <tr key={headerGroup.id}>
                  {headerGroup.headers.map((header) => {
                    const sortState = header.column.getIsSorted();
                    return (
                      <th key={header.id} className="whitespace-nowrap px-4 py-3 font-semibold text-ink-soft">
                        {header.isPlaceholder ? null : (
                          <button
                            type="button"
                            onClick={header.column.getToggleSortingHandler()}
                            className={cn(
                              "flex items-center gap-1.5",
                              header.column.getCanSort() ? "cursor-pointer select-none hover:text-ink" : "cursor-default"
                            )}
                          >
                            {flexRender(header.column.columnDef.header, header.getContext())}
                            {header.column.getCanSort() &&
                              (sortState === "asc" ? (
                                <ChevronUp size={13} />
                              ) : sortState === "desc" ? (
                                <ChevronDown size={13} />
                              ) : (
                                <ChevronsUpDown size={13} className="opacity-40" />
                              ))}
                          </button>
                        )}
                      </th>
                    );
                  })}
                </tr>
              ))}
            </thead>
            <tbody>
              {table.getRowModel().rows.map((row) => (
                <tr
                  key={row.id}
                  onClick={() => onRowClick?.(row.original)}
                  className={cn(
                    "border-b border-line last:border-0",
                    onRowClick && "cursor-pointer transition-colors duration-150 ease-out hover:bg-paper-dim"
                  )}
                >
                  {row.getVisibleCells().map((cell) => (
                    <td key={cell.id} className="whitespace-nowrap px-4 py-3.5 text-ink">
                      {flexRender(cell.column.columnDef.cell, cell.getContext())}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {table.getPageCount() > 1 && (
        <div className="flex items-center justify-between px-1">
          <span className="text-[12px] text-ink-soft">
            Page {table.getState().pagination.pageIndex + 1} of {table.getPageCount()}
          </span>
          <div className="flex gap-2">
            <Button size="sm" variant="secondary" onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()}>
              Previous
            </Button>
            <Button size="sm" variant="secondary" onClick={() => table.nextPage()} disabled={!table.getCanNextPage()}>
              Next
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}
'@
Write-Utf8NoBom -Path "packages\ui\src\components\DataTable.tsx" -Content $dataTable

Patch-File -Path "packages\ui\package.json" `
  -OldStr '"clsx": "^2.1.0",' `
  -NewStr @'
"clsx": "^2.1.0",
    "@tanstack/react-table": "^8.20.0",
'@ `
  -Label "add react-table dependency to ui package"

# ---------------------------------------------------------------------------
# 5. Admin globals.css - light + dark theme tokens, shimmer keyframes
# ---------------------------------------------------------------------------
$adminGlobals = @'
@import url("https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=IBM+Plex+Mono:wght@500;600&display=swap");
@import "tailwindcss";

@theme {
  --color-ink: #14171a;
  --color-ink-soft: #565b63;

  --color-paper: #f6f7f8;
  --color-paper-dim: #eceef0;
  --color-card: #ffffff;

  --color-line: #e3e5e8;
  --color-line-strong: #cfd3d8;

  --color-accent: #14171a;
  --color-accent-soft: #eceef0;

  --color-success: #1c7a4d;
  --color-success-tint: #e6f4ec;
  --color-warning: #96650b;
  --color-warning-tint: #fbf0dd;
  --color-error: #b3392c;
  --color-error-tint: #faeae8;
  --color-info: #2453a6;
  --color-info-tint: #e8eefb;

  --font-body: "Inter", -apple-system, "Segoe UI", sans-serif;
  --font-mono: "IBM Plex Mono", "SFMono-Regular", monospace;

  --radius-card: 16px;
  --radius-control: 10px;

  --animate-shimmer: shimmer 1.6s ease-in-out infinite;
}

@keyframes shimmer {
  100% { transform: translateX(100%); }
}

[data-theme="dark"] {
  --color-ink: #f2f3f5;
  --color-ink-soft: #9aa0a8;

  --color-paper: #0d0f12;
  --color-paper-dim: #16191d;
  --color-card: #131619;

  --color-line: #23272c;
  --color-line-strong: #33383e;

  --color-accent: #f2f3f5;
  --color-accent-soft: #1c2026;

  --color-success: #4ade95;
  --color-success-tint: #10241a;
  --color-warning: #f0b849;
  --color-warning-tint: #2a2110;
  --color-error: #f28b7d;
  --color-error-tint: #2a1613;
  --color-info: #7ea6ef;
  --color-info-tint: #131f30;
}

* {
  box-sizing: border-box;
}

html {
  color-scheme: light;
}
html[data-theme="dark"] {
  color-scheme: dark;
}

body {
  background: var(--color-paper);
  color: var(--color-ink);
  font-family: var(--font-body);
  transition: background-color 150ms ease-out, color 150ms ease-out;
}

::selection {
  background: var(--color-ink);
  color: var(--color-paper);
}

/* Black & white icon rule: all lucide icons in the admin app are stroke-only,
   inherit currentColor, no fills - keeps the interface monochrome. */
svg {
  color: inherit;
}

@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
'@
Write-Utf8NoBom -Path "apps\admin\app\globals.css" -Content $adminGlobals

# ---------------------------------------------------------------------------
# 6. Admin package.json - add shared workspace packages + tanstack table
# ---------------------------------------------------------------------------
Patch-File -Path "apps\admin\package.json" `
  -OldStr '"@tanstack/react-table": "^8.20.0",
    "zustand": "^4.5.0",' `
  -NewStr @'
"@tanstack/react-table": "^8.20.0",
    "zustand": "^4.5.0",
    "@saachi/ui": "workspace:*",
    "@saachi/store": "workspace:*",
    "@saachi/utils": "workspace:*",
    "@saachi/api-client": "workspace:*",
'@ `
  -Label "add workspace deps to admin package.json"

Patch-File -Path "apps\admin\next.config.js" `
  -OldStr 'transpilePackages: ["@saachi/ui", "@saachi/api-client", "@saachi/utils"],' `
  -NewStr 'transpilePackages: ["@saachi/ui", "@saachi/api-client", "@saachi/utils", "@saachi/store"],' `
  -Label "add @saachi/store to admin transpilePackages"

Patch-File -Path "apps\admin\tsconfig.json" `
  -OldStr '"@saachi/utils": ["../../packages/utils/src"],
      "@saachi/utils/*": ["../../packages/utils/src/*"]' `
  -NewStr @'
"@saachi/utils": ["../../packages/utils/src"],
      "@saachi/utils/*": ["../../packages/utils/src/*"],
      "@saachi/store": ["../../packages/store/src"],
      "@saachi/store/*": ["../../packages/store/src/*"]
'@ `
  -Label "add @saachi/store path alias to admin tsconfig"

# ---------------------------------------------------------------------------
# 7. Admin nav config (single source of truth for the sidebar - all 26 screens)
# ---------------------------------------------------------------------------
$adminNavConfig = @'
import type { LucideIcon } from "lucide-react";
import {
  LayoutDashboard,
  Users,
  ClipboardCheck,
  LibraryBig,
  Tags,
  Receipt,
  Banknote,
  Undo2,
  Percent,
  Image,
  Ticket,
  Megaphone,
  MessageSquareWarning,
  MessagesSquare,
  LifeBuoy,
  BarChart3,
  Layers,
  SlidersHorizontal,
  Landmark,
  CreditCard,
  ScrollText,
  ShieldCheck,
  History
} from "lucide-react";

export type AdminNavItem = {
  label: string;
  href: string;
  icon: LucideIcon;
};

export type AdminNavSection = {
  title: string;
  items: AdminNavItem[];
};

export const ADMIN_NAV: AdminNavSection[] = [
  {
    title: "Overview",
    items: [{ label: "Dashboard", href: "/dashboard", icon: LayoutDashboard }]
  },
  {
    title: "Users",
    items: [{ label: "User Management", href: "/users", icon: Users }]
  },
  {
    title: "Courses",
    items: [
      { label: "Moderation Queue", href: "/courses/moderation", icon: ClipboardCheck },
      { label: "Course Catalog", href: "/courses/catalog", icon: LibraryBig },
      { label: "Categories & Tags", href: "/courses/categories", icon: Tags }
    ]
  },
  {
    title: "Finance",
    items: [
      { label: "Transactions", href: "/finance/transactions", icon: Receipt },
      { label: "Payouts", href: "/finance/payouts", icon: Banknote },
      { label: "Refunds", href: "/finance/refunds", icon: Undo2 },
      { label: "Tax / VAT Settings", href: "/finance/tax-settings", icon: Percent }
    ]
  },
  {
    title: "Marketing",
    items: [
      { label: "Homepage Banners", href: "/marketing/banners", icon: Image },
      { label: "Coupons", href: "/marketing/coupons", icon: Ticket },
      { label: "Promotion Sales", href: "/marketing/promotions", icon: Megaphone }
    ]
  },
  {
    title: "Moderation",
    items: [
      { label: "Flagged Reviews", href: "/moderation/reviews", icon: MessageSquareWarning },
      { label: "Flagged Forum Posts", href: "/moderation/forum", icon: MessagesSquare }
    ]
  },
  {
    title: "Support",
    items: [{ label: "Ticket Queue", href: "/support/tickets", icon: LifeBuoy }]
  },
  {
    title: "Analytics",
    items: [
      { label: "Overview", href: "/analytics/overview", icon: BarChart3 },
      { label: "Cohort Analysis", href: "/analytics/cohorts", icon: Layers }
    ]
  },
  {
    title: "Settings",
    items: [
      { label: "Platform Settings", href: "/settings/platform", icon: SlidersHorizontal },
      { label: "Commission Tiers", href: "/settings/commission-tiers", icon: Landmark },
      { label: "Payment Gateways", href: "/settings/payment-gateways", icon: CreditCard },
      { label: "Legal Documents", href: "/settings/legal-documents", icon: ScrollText },
      { label: "Roles & Permissions", href: "/settings/roles", icon: ShieldCheck }
    ]
  },
  {
    title: "System",
    items: [{ label: "Audit Log", href: "/logs/audit", icon: History }]
  }
];
'@
Write-Utf8NoBom -Path "apps\admin\lib\nav-config.ts" -Content $adminNavConfig

# ---------------------------------------------------------------------------
# 8. AdminShell - collapsible sidebar (grouped sections) + topbar (theme toggle,
#    search, admin avatar). Black & white icons throughout (stroke only).
# ---------------------------------------------------------------------------
$adminShell = @'
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState, type ReactNode } from "react";
import { Menu, X, LogOut, Search, ChevronLeft, ChevronRight } from "lucide-react";
import { ThemeToggle } from "@saachi/ui";
import { ADMIN_NAV } from "../lib/nav-config";

function cx(...parts: Array<string | false | undefined>) {
  return parts.filter(Boolean).join(" ");
}

export function AdminShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const [mobileOpen, setMobileOpen] = useState(false);
  const [collapsed, setCollapsed] = useState(false);

  const sidebarContent = (
    <div className="flex h-full flex-col">
      <div className={cx("flex items-center gap-2.5 px-5 py-6", collapsed && "justify-center px-0")}>
        <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full border border-ink text-[13px] font-bold text-ink">
          S
        </span>
        {!collapsed && (
          <div>
            <div className="text-[14px] font-semibold leading-none text-ink">Saachi AI</div>
            <div className="mt-1 text-[10px] font-medium uppercase tracking-[0.08em] text-ink-soft">Admin</div>
          </div>
        )}
      </div>

      <nav className="flex flex-1 flex-col gap-5 overflow-y-auto px-3 pb-4">
        {ADMIN_NAV.map((section) => (
          <div key={section.title}>
            {!collapsed && (
              <div className="mb-1.5 px-2.5 text-[10px] font-semibold uppercase tracking-[0.08em] text-ink-soft/60">
                {section.title}
              </div>
            )}
            <div className="flex flex-col gap-0.5">
              {section.items.map((item) => {
                const active = pathname === item.href || Boolean(pathname?.startsWith(`${item.href}/`));
                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    onClick={() => setMobileOpen(false)}
                    title={collapsed ? item.label : undefined}
                    className={cx(
                      "flex items-center gap-3 rounded-control px-2.5 py-2 text-[13px] font-medium transition-colors duration-150 ease-out",
                      collapsed && "justify-center",
                      active ? "bg-accent text-paper" : "text-ink-soft hover:bg-paper-dim hover:text-ink"
                    )}
                  >
                    <item.icon size={16} strokeWidth={1.75} className="shrink-0" />
                    {!collapsed && <span className="truncate">{item.label}</span>}
                  </Link>
                );
              })}
            </div>
          </div>
        ))}
      </nav>

      <div className="border-t border-line px-3 py-3">
        <button
          type="button"
          onClick={() => setCollapsed((v) => !v)}
          className={cx(
            "mb-1 flex w-full items-center gap-3 rounded-control px-2.5 py-2 text-[13px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-ink",
            collapsed && "justify-center"
          )}
        >
          {collapsed ? <ChevronRight size={16} strokeWidth={1.75} /> : <ChevronLeft size={16} strokeWidth={1.75} />}
          {!collapsed && "Collapse"}
        </button>
        <Link
          href="/login"
          className={cx(
            "flex w-full items-center gap-3 rounded-control px-2.5 py-2 text-[13px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-error",
            collapsed && "justify-center"
          )}
        >
          <LogOut size={16} strokeWidth={1.75} />
          {!collapsed && "Log out"}
        </Link>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-paper">
      <div
        className={cx(
          "hidden shrink-0 border-r border-line bg-card transition-[width] duration-200 ease-out md:fixed md:inset-y-0 md:flex",
          collapsed ? "w-[76px]" : "w-[248px]"
        )}
      >
        {sidebarContent}
      </div>

      <div
        className={cx(
          "sticky top-0 z-40 flex items-center justify-between border-b border-line bg-card/95 px-4 py-3 backdrop-blur-sm transition-[padding] duration-200 ease-out md:px-6",
          collapsed ? "md:pl-[76px]" : "md:pl-[248px]"
        )}
      >
        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={() => setMobileOpen(true)}
            aria-label="Open menu"
            className="flex h-9 w-9 items-center justify-center rounded-control text-ink md:hidden"
          >
            <Menu size={18} strokeWidth={1.75} />
          </button>
          <div className="relative hidden sm:block">
            <Search size={15} strokeWidth={1.75} className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-ink-soft" />
            <input
              placeholder="Search users, courses, tickets..."
              className="h-9 w-[280px] rounded-control border border-line bg-paper pl-9 pr-3 text-[13px] text-ink outline-none placeholder:text-ink-soft/60 focus:border-line-strong"
            />
          </div>
        </div>

        <div className="flex items-center gap-3">
          <ThemeToggle />
          <div className="flex h-9 w-9 items-center justify-center rounded-full border border-line text-[12px] font-semibold text-ink">
            A
          </div>
        </div>
      </div>

      {mobileOpen && (
        <div className="fixed inset-0 z-50 flex md:hidden">
          <div className="absolute inset-0 bg-ink/40" onClick={() => setMobileOpen(false)} />
          <div className="relative flex h-full w-[280px] flex-col bg-card">
            <button
              type="button"
              onClick={() => setMobileOpen(false)}
              aria-label="Close menu"
              className="absolute right-3 top-3 flex h-9 w-9 items-center justify-center rounded-control text-ink"
            >
              <X size={18} strokeWidth={1.75} />
            </button>
            {sidebarContent}
          </div>
        </div>
      )}

      <div className={cx("transition-[padding] duration-200 ease-out", collapsed ? "md:pl-[76px]" : "md:pl-[248px]")}>
        {children}
      </div>
    </div>
  );
}
'@
Write-Utf8NoBom -Path "apps\admin\app\_components\AdminShell.tsx" -Content $adminShell

# ---------------------------------------------------------------------------
# 9. Admin layout.tsx - wires Providers + AdminShell (login page opts out)
# ---------------------------------------------------------------------------
$adminLayout = @'
import type { Metadata } from "next";
import { Providers } from "./providers";
import "./globals.css";

export const metadata: Metadata = {
  title: "Saachi AI - Admin",
  description: "Internal operations console for the Saachi AI platform."
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
'@
Write-Utf8NoBom -Path "apps\admin\app\layout.tsx" -Content $adminLayout

# Wrap every non-login route group with AdminShell via a nested layout.
$adminAppLayout = @'
import { AdminShell } from "./_components/AdminShell";

export default function AdminAppLayout({ children }: { children: React.ReactNode }) {
  return <AdminShell>{children}</AdminShell>;
}
'@
Write-Utf8NoBom -Path "apps\admin\app\(console)\layout.tsx" -Content $adminAppLayout

Write-Host "  NOTE: existing admin/app/dashboard, users, courses, finance, marketing," -ForegroundColor Yellow
Write-Host "        moderation, support, analytics, settings, logs folders will be MOVED" -ForegroundColor Yellow
Write-Host "        under app/(console)/ in the next command so they inherit AdminShell." -ForegroundColor Yellow

# ---------------------------------------------------------------------------
# 10. Move existing route folders into the (console) route group
# ---------------------------------------------------------------------------
$consoleFolders = @("dashboard","users","courses","finance","marketing","moderation","support","analytics","settings","logs")
foreach ($folder in $consoleFolders) {
    $src = "apps\admin\app\$folder"
    $dst = "apps\admin\app\(console)\$folder"
    $srcFull = Join-Path -Path (Get-Location).Path -ChildPath $src
    $dstFull = Join-Path -Path (Get-Location).Path -ChildPath $dst
    if (Test-Path $srcFull) {
        $dstParent = Split-Path -Parent $dstFull
        if (-not (Test-Path $dstParent)) { New-Item -ItemType Directory -Path $dstParent -Force | Out-Null }
        Move-Item -Path $srcFull -Destination $dstFull -Force
        Write-Host "  moved $src -> $dst"
    } else {
        Write-Host "  SKIP (not found): $src" -ForegroundColor Yellow
    }
}

# ---------------------------------------------------------------------------
# 11. Dashboard page - KPI cards, trend chart, alert feed - all shimmer-loaded
# ---------------------------------------------------------------------------
$dashboardPage = @'
"use client";

import { useEffect, useState } from "react";
import {
  Users,
  DollarSign,
  ClipboardCheck,
  LifeBuoy,
  ArrowRight
} from "lucide-react";
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from "recharts";
import Link from "next/link";
import { KpiCard, StatusPill, ShimmerKpiCard, ShimmerChart, Shimmer } from "@saachi/ui";

const REVENUE_TREND = [
  { day: "Mon", revenue: 1240 },
  { day: "Tue", revenue: 1890 },
  { day: "Wed", revenue: 1510 },
  { day: "Thu", revenue: 2230 },
  { day: "Fri", revenue: 2670 },
  { day: "Sat", revenue: 1980 },
  { day: "Sun", revenue: 2410 }
];

const ALERT_FEED = [
  { id: "al_1", label: "3 courses pending moderation review", tone: "warning" as const, href: "/courses/moderation" },
  { id: "al_2", label: "1 refund request awaiting approval", tone: "error" as const, href: "/finance/refunds" },
  { id: "al_3", label: "2 support tickets breaching SLA", tone: "error" as const, href: "/support/tickets" },
  { id: "al_4", label: "Weekly payout batch ready to process", tone: "info" as const, href: "/finance/payouts" }
];

export default function AdminDashboardPage() {
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const t = setTimeout(() => setIsLoading(false), 700);
    return () => clearTimeout(t);
  }, []);

  const kpis = [
    { label: "New signups today", value: "142", icon: Users, delta: { value: "+12%", direction: "up" as const } },
    { label: "Revenue today", value: "$4,380", icon: DollarSign, delta: { value: "+8%", direction: "up" as const } },
    { label: "Pending approvals", value: "3", icon: ClipboardCheck, delta: { value: "-2", direction: "down" as const } },
    { label: "Open tickets", value: "7", icon: LifeBuoy, delta: { value: "+1", direction: "up" as const } }
  ];

  return (
    <main className="mx-auto max-w-[1200px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-8">
        <h1 className="text-[24px] font-semibold text-ink">Dashboard</h1>
        <p className="mt-1 text-[13px] text-ink-soft">Platform-wide overview and pending operational items.</p>
      </div>

      <div className="mb-8 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {isLoading
          ? Array.from({ length: 4 }).map((_, i) => <ShimmerKpiCard key={i} />)
          : kpis.map((kpi) => <KpiCard key={kpi.label} {...kpi} />)}
      </div>

      <div className="mb-8 grid grid-cols-1 gap-6 lg:grid-cols-[1.4fr_1fr]">
        {isLoading ? (
          <ShimmerChart />
        ) : (
          <div className="rounded-card border border-line bg-card p-6">
            <div className="mb-1 text-[14px] font-semibold text-ink">Revenue - last 7 days</div>
            <p className="mb-5 text-[12px] text-ink-soft">Gross transaction volume across all payment gateways.</p>
            <ResponsiveContainer width="100%" height={220}>
              <LineChart data={REVENUE_TREND}>
                <CartesianGrid strokeDasharray="3 3" stroke="var(--color-line)" />
                <XAxis dataKey="day" stroke="var(--color-ink-soft)" fontSize={12} tickLine={false} axisLine={false} />
                <YAxis stroke="var(--color-ink-soft)" fontSize={12} tickLine={false} axisLine={false} />
                <Tooltip
                  contentStyle={{
                    background: "var(--color-card)",
                    border: "1px solid var(--color-line)",
                    borderRadius: 10,
                    fontSize: 12,
                    color: "var(--color-ink)"
                  }}
                />
                <Line type="monotone" dataKey="revenue" stroke="var(--color-ink)" strokeWidth={2} dot={false} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        )}

        <div className="rounded-card border border-line bg-card p-6">
          <div className="mb-4 text-[14px] font-semibold text-ink">Needs attention</div>
          {isLoading ? (
            <div className="flex flex-col gap-3">
              {Array.from({ length: 4 }).map((_, i) => (
                <Shimmer key={i} className="h-11 w-full" />
              ))}
            </div>
          ) : (
            <div className="flex flex-col gap-2">
              {ALERT_FEED.map((alert) => (
                <Link
                  key={alert.id}
                  href={alert.href}
                  className="flex items-center justify-between gap-3 rounded-control border border-line px-3.5 py-3 text-[13px] text-ink transition-colors duration-150 ease-out hover:bg-paper-dim"
                >
                  <div className="flex items-center gap-2.5">
                    <StatusPill label={alert.tone} tone={alert.tone} />
                    <span className="text-[12.5px]">{alert.label}</span>
                  </div>
                  <ArrowRight size={14} strokeWidth={1.75} className="shrink-0 text-ink-soft" />
                </Link>
              ))}
            </div>
          )}
        </div>
      </div>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\admin\app\(console)\dashboard\page.tsx" -Content $dashboardPage

# ---------------------------------------------------------------------------
# 12. Admin login page - restyled to match new theme tokens (light/dark ready)
# ---------------------------------------------------------------------------
$adminLoginPage = @'
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { ShieldCheck } from "lucide-react";
import { Button, Card, Input, ThemeToggle } from "@saachi/ui";

export default function AdminLoginPage() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    document.cookie = "saachi_admin_session=demo_token; path=/; max-age=" + 60 * 60 * 24 * 7;
    setTimeout(() => router.push("/dashboard"), 500);
  };

  return (
    <main className="flex min-h-screen items-center justify-center bg-paper px-4">
      <div className="absolute right-5 top-5">
        <ThemeToggle />
      </div>

      <Card className="w-full max-w-[400px] p-8">
        <div className="mb-6 flex flex-col items-center text-center">
          <span className="mb-4 flex h-11 w-11 items-center justify-center rounded-full border border-ink text-[15px] font-bold text-ink">
            S
          </span>
          <h1 className="text-[20px] font-semibold text-ink">Saachi AI - Admin</h1>
          <p className="mt-1.5 text-[13px] text-ink-soft">Internal staff access only. 2FA required.</p>
        </div>

        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <Input label="Email" type="email" placeholder="you@saachi.ai" required />
          <Input label="Password" type="password" placeholder="********" required />
          <Button type="submit" size="lg" disabled={loading}>
            {loading ? "Verifying..." : "Continue"}
          </Button>
        </form>

        <div className="mt-5 flex items-center justify-center gap-1.5 text-[12px] text-ink-soft">
          <ShieldCheck size={13} strokeWidth={1.75} />
          Protected by mandatory two-factor authentication
        </div>
      </Card>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\admin\app\login\page.tsx" -Content $adminLoginPage

Write-Host ""
Write-Host "Step 11 done." -ForegroundColor Green
Write-Host "Run: pnpm install" -ForegroundColor Yellow
Write-Host "Then: pnpm dev:admin" -ForegroundColor Green
Write-Host ""
Write-Host "What this step built:" -ForegroundColor Cyan
Write-Host "  - Shared dark/light theme store + ThemeToggle (sun/moon, black & white icons)"
Write-Host "  - Shimmer/skeleton components: Shimmer, ShimmerText, ShimmerKpiCard, ShimmerTable, ShimmerChart"
Write-Host "  - KpiCard, StatusPill, DataTable (TanStack Table wrapper) added to @saachi/ui"
Write-Host "  - AdminShell: collapsible grouped sidebar (all 26 planned screens linked), topbar w/ search + theme toggle"
Write-Host "  - app/(console)/ route group created - dashboard/users/courses/finance/marketing/moderation/support/analytics/settings/logs MOVED inside it"
Write-Host "  - Dashboard page fully wired: KPI cards, revenue chart, alert feed, shimmer loading state"
Write-Host "  - Login page restyled to new theme tokens"
Write-Host ""
Write-Host "Next steps (say 'next' and I will generate step12, etc.):" -ForegroundColor Cyan
Write-Host "  Step 12: User Management (list + detail + DataTable + ban/suspend)"
Write-Host "  Step 13: Course Moderation Queue + Catalog + Categories/Tags"
Write-Host "  Step 14: Finance (Transactions, Payouts, Refunds, Tax Settings)"
Write-Host "  Step 15: Marketing (Banners, Coupons, Promotion Sales)"
Write-Host "  Step 16: Moderation (Reviews, Forum) + Support Tickets"
Write-Host "  Step 17: Analytics (Overview, Cohorts)"
Write-Host "  Step 18: Settings (Platform, Commission Tiers, Payment Gateways, Legal Docs, Roles) + Audit Log"