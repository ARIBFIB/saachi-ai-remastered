<#
.SYNOPSIS
    Fixes the InstructorIconRail so clicking a sidebar icon also navigates
    the URL to that group's first page, instead of only switching the
    detail-panel view locally.

.USAGE
    Run from the SAI2 repo root:
    PS D:\...\SAI2> .\Fix-InstructorSidebarNavigation.ps1
#>

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

function Write-Section($msg) {
    Write-Host ""
    Write-Host "== $msg ==" -ForegroundColor Cyan
}

$targetFile = Join-Path $root "apps\web\components\ui\instructor-sidebar-v2.tsx"

if (-not (Test-Path $targetFile)) {
    Write-Host "ERROR: Could not find file at: $targetFile" -ForegroundColor Red
    Write-Host "Make sure you're running this script from the SAI2 repo root." -ForegroundColor Yellow
    exit 1
}

Write-Section "Patching instructor-sidebar-v2.tsx"

$content = Get-Content -Path $targetFile -Raw
$original = $content
$changes = 0

# ---------------------------------------------------------------------------
# 1. Add `useRouter` import (usePathname already imported from next/navigation)
# ---------------------------------------------------------------------------
$oldImport = 'import { usePathname } from "next/navigation";'
$newImport = 'import { usePathname, useRouter } from "next/navigation";'

if ($content.Contains($oldImport)) {
    $content = $content.Replace($oldImport, $newImport)
    $changes++
    Write-Host "  [OK] Added useRouter import." -ForegroundColor Green
} elseif ($content.Contains("useRouter") -and $content -match 'from "next/navigation"') {
    Write-Host "  [SKIP] useRouter already imported." -ForegroundColor Yellow
} else {
    Write-Host "  [WARN] Could not find expected import line for usePathname. Check imports manually." -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# 2. Give InstructorIconRail access to a resolver for each group's target
#    href, and call router.push on click (in addition to onSelect).
# ---------------------------------------------------------------------------
$oldRailFn = @'
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
'@

$newRailFn = @'
function resolveGroupHref(group: InstructorNavGroup): string {
  const firstItem = group.items[0];
  if (!firstItem) return "/instructor/dashboard";
  return firstItem.href.split("?")[0];
}

export function InstructorIconRail({
  activeGroupId,
  onSelect
}: {
  activeGroupId: string;
  onSelect: (id: string) => void;
}) {
  const router = useRouter();

  function handleClick(group: InstructorNavGroup) {
    onSelect(group.id);
    router.push(resolveGroupHref(group));
  }

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
            onClick={() => handleClick(group)}
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
'@

if ($content.Contains($oldRailFn)) {
    $content = $content.Replace($oldRailFn, $newRailFn)
    $changes++
    Write-Host "  [OK] Patched InstructorIconRail to navigate on click." -ForegroundColor Green
} elseif ($content.Contains("function resolveGroupHref")) {
    Write-Host "  [SKIP] InstructorIconRail already patched." -ForegroundColor Yellow
} else {
    Write-Host "  [WARN] Could not find expected InstructorIconRail block - file structure may differ." -ForegroundColor Yellow
    Write-Host "         No changes made to this function. Patch manually if needed." -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# 3. Same fix for the mobile combined sidebar (InstructorSidebarMobile),
#    which has its own duplicate icon-rail markup.
# ---------------------------------------------------------------------------
$oldMobileFn = @'
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
'@

$newMobileFn = @'
export function InstructorSidebarMobile({ onNavigate }: { onNavigate?: () => void }) {
  const [activeGroupId, setActiveGroupId] = useState("overview");
  const router = useRouter();

  function handleMobileClick(group: InstructorNavGroup) {
    setActiveGroupId(group.id);
    router.push(resolveGroupHref(group));
  }

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
              onClick={() => handleMobileClick(group)}
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
'@

if ($content.Contains($oldMobileFn)) {
    $content = $content.Replace($oldMobileFn, $newMobileFn)
    $changes++
    Write-Host "  [OK] Patched InstructorSidebarMobile to navigate on click." -ForegroundColor Green
} elseif ($content.Contains("handleMobileClick")) {
    Write-Host "  [SKIP] InstructorSidebarMobile already patched." -ForegroundColor Yellow
} else {
    Write-Host "  [WARN] Could not find expected InstructorSidebarMobile block - file structure may differ." -ForegroundColor Yellow
    Write-Host "         No changes made to this function. Patch manually if needed." -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# Write back
# ---------------------------------------------------------------------------
if ($content -ne $original) {
    Set-Content -Path $targetFile -Value $content -NoNewline -Encoding UTF8
    Write-Host ""
    Write-Host "Done. $changes change(s) applied to instructor-sidebar-v2.tsx" -ForegroundColor Green
    Write-Host "Next steps:"
    Write-Host "  1. git diff apps/web/components/ui/instructor-sidebar-v2.tsx"
    Write-Host "  2. pnpm turbo run build   -> verify it compiles"
    Write-Host "  3. Test: click a sidebar icon (e.g. Courses) -> URL should change to /instructor/courses"
    Write-Host "  4. Commit and push"
} else {
    Write-Host ""
    Write-Host "No changes were made - file may already be patched, or its structure" -ForegroundColor Yellow
    Write-Host "differs from what this script expects. Open the file manually if the" -ForegroundColor Yellow
    Write-Host "issue persists." -ForegroundColor Yellow
}