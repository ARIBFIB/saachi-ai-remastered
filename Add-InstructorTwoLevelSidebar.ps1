# Add-InstructorTwoLevelSidebar.ps1
# Creates a two-level (icon rail + collapsible detail panel) sidebar component
# in the Saachi AI theme, using lucide-react (already installed - no @carbon
# icons needed), and wires it into InstructorShell.tsx.
# Run this from the SAI2 repo root.

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

$root = (Get-Location).Path
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

$componentPath = Join-Path -Path $root -ChildPath "apps\web\app\(instructor)\_components\InstructorTwoLevelSidebar.tsx"
$shellPath     = Join-Path -Path $root -ChildPath "apps\web\app\(instructor)\_components\InstructorShell.tsx"

if (-not (Test-Path -LiteralPath $shellPath)) {
    throw "File not found: $shellPath"
}

# =========================================================================
# 1. Create the two-level sidebar component
# =========================================================================
if (Test-Path -LiteralPath $componentPath) {
    Copy-Item -LiteralPath $componentPath -Destination "$componentPath.bak-$timestamp"
}

$componentContent = @'
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import { ChevronLeft, ChevronRight, ChevronDown } from "lucide-react";
import { INSTRUCTOR_NAV } from "../../../lib/instructor-nav-config";

const softSpring = "cubic-bezier(0.25, 1.1, 0.4, 1)";

function cx(...parts: Array<string | false | undefined>) {
  return parts.filter(Boolean).join(" ");
}

export function InstructorTwoLevelSidebar({ onNavigate }: { onNavigate?: () => void }) {
  const pathname = usePathname();

  const [activeSectionIndex, setActiveSectionIndex] = useState(() => {
    const idx = INSTRUCTOR_NAV.findIndex((section) =>
      section.items.some(
        (item) => pathname === item.href || Boolean(pathname?.startsWith(`${item.href}/`))
      )
    );
    return idx >= 0 ? idx : 0;
  });
  const [collapsed, setCollapsed] = useState(false);

  const activeSection = INSTRUCTOR_NAV[activeSectionIndex];

  return (
    <div className="flex h-full">
      {/* Icon rail */}
      <div className="flex w-16 shrink-0 flex-col items-center gap-2 border-r border-line bg-card py-4">
        {INSTRUCTOR_NAV.map((section, index) => {
          const FirstIcon = section.items[0]?.icon;
          const isActiveSection = index === activeSectionIndex;
          return (
            <button
              key={section.title}
              type="button"
              title={section.title}
              onClick={() => setActiveSectionIndex(index)}
              className={cx(
                "flex h-10 w-10 shrink-0 items-center justify-center rounded-control transition-colors duration-200 ease-out",
                isActiveSection
                  ? "bg-gold text-ink"
                  : "text-ink-soft hover:bg-paper-dim hover:text-ink"
              )}
              style={{ transitionTimingFunction: softSpring }}
            >
              {FirstIcon && <FirstIcon size={17} strokeWidth={1.75} />}
            </button>
          );
        })}
      </div>

      {/* Detail panel */}
      <div
        className={cx(
          "flex flex-col overflow-hidden border-r border-line bg-card transition-[width] duration-300 ease-out",
          collapsed ? "w-0 border-r-0" : "w-56"
        )}
        style={{ transitionTimingFunction: softSpring }}
      >
        <div className="flex items-center justify-between px-4 pt-5 pb-3">
          <span className="truncate text-[13px] font-semibold uppercase tracking-[0.06em] text-ink-soft/70">
            {activeSection?.title}
          </span>
        </div>

        <nav className="flex flex-1 flex-col gap-0.5 overflow-y-auto px-2 pb-4">
          {activeSection?.items.map((item) => {
            const active = pathname === item.href || Boolean(pathname?.startsWith(`${item.href}/`));
            return (
              <Link
                key={item.href}
                href={item.href}
                onClick={onNavigate}
                className={cx(
                  "flex items-center gap-3 rounded-control px-2.5 py-2 text-[13px] font-medium transition-colors duration-150 ease-out",
                  active ? "bg-gold text-ink" : "text-ink-soft hover:bg-paper-dim hover:text-ink"
                )}
              >
                <item.icon size={16} strokeWidth={1.75} className="shrink-0" />
                <span className="truncate">{item.label}</span>
              </Link>
            );
          })}
        </nav>

        <div className="border-t border-line px-2 py-3">
          <button
            type="button"
            onClick={() => setCollapsed(true)}
            className="flex w-full items-center gap-3 rounded-control px-2.5 py-2 text-[13px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-ink"
          >
            <ChevronLeft size={16} strokeWidth={1.75} />
            Collapse
          </button>
        </div>
      </div>

      {collapsed && (
        <div className="flex w-10 shrink-0 flex-col items-center border-r border-line bg-card py-4">
          <button
            type="button"
            onClick={() => setCollapsed(false)}
            aria-label="Expand sidebar"
            className="flex h-9 w-9 items-center justify-center rounded-control text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-ink"
          >
            <ChevronRight size={16} strokeWidth={1.75} />
          </button>
        </div>
      )}
    </div>
  );
}

export default InstructorTwoLevelSidebar;
'@

Write-Utf8NoBom -Path $componentPath -Content $componentContent
Write-Host "Created: InstructorTwoLevelSidebar.tsx" -ForegroundColor Green

# =========================================================================
# 2. Wire into InstructorShell.tsx (replace old single-panel sidebar content)
# =========================================================================
Copy-Item -LiteralPath $shellPath -Destination "$shellPath.bak-$timestamp"
Write-Host "Backup created: InstructorShell.tsx.bak-$timestamp" -ForegroundColor Cyan

$shell = Get-Content -Raw -LiteralPath $shellPath
$before = $shell

# add import
$shell = $shell.Replace(
    'import { INSTRUCTOR_NAV } from "../../../lib/instructor-nav-config";' + "`n",
    'import { INSTRUCTOR_NAV } from "../../../lib/instructor-nav-config";' + "`n" + 'import { InstructorTwoLevelSidebar } from "./InstructorTwoLevelSidebar";' + "`n"
)

# Replace the desktop fixed sidebar block (old single-column nav) with the new two-level sidebar
$desktopAnchorStart = '      <div'
$desktopSidebarOld = @'
      <div
        className={cx(
          "hidden shrink-0 border-r border-line bg-card transition-[width] duration-200 ease-out md:fixed md:inset-y-0 md:flex",
          collapsed ? "w-[76px]" : "w-[248px]"
        )}
      >
        {sidebarContent}
      </div>
'@

$desktopSidebarNew = @'
      <div className="hidden md:fixed md:inset-y-0 md:flex">
        <InstructorTwoLevelSidebar />
      </div>
'@

$shell = $shell.Replace($desktopSidebarOld, $desktopSidebarNew)

# Replace mobile drawer's sidebarContent usage with the new component
$mobileOld = '            {sidebarContent}'
$mobileNew = '            <InstructorTwoLevelSidebar onNavigate={() => setMobileOpen(false)} />'
$shell = $shell.Replace($mobileOld, $mobileNew)

# Update the main content padding since the new sidebar rail width differs
$paddingOld = '<div className={cx("transition-[padding] duration-200 ease-out", collapsed ? "md:pl-[76px]" : "md:pl-[248px]")}>'
$paddingNew = '<div className="transition-[padding] duration-200 ease-out md:pl-16">'
$shell = $shell.Replace($paddingOld, $paddingNew)

if ($shell -eq $before) {
    Write-Warning "InstructorShell.tsx: no changes were applied - anchors may not have matched. Check file manually."
} else {
    Write-Utf8NoBom -Path $shellPath -Content $shell
    Write-Host "Updated: InstructorShell.tsx" -ForegroundColor Green
}

Write-Host "`nDone. Run 'pnpm dev' inside apps/web and check /instructor/dashboard." -ForegroundColor Cyan
Write-Host "Note: the old 'collapsed'/'sidebarContent' variables inside InstructorShell.tsx may now be unused - if the build warns about unused vars, remove them manually or tell me and I'll give a cleanup script." -ForegroundColor Yellow