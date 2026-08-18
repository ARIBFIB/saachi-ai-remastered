<#
.SYNOPSIS
    Fixes the layout bug where collapsing the instructor detail panel
    (the small "<" arrow) leaves a large empty gap because the top bar
    and main content still use a hardcoded md:ml-[352px] margin.

    Lifts the `collapsed` state from InstructorDetailPanel up into
    InstructorShell so the top bar / content margin can react to it.

.USAGE
    Run from the SAI2 repo root:
    PS D:\...\SAI2> .\Fix-InstructorSidebarCollapseLayout.ps1
#>

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

function Write-Section($msg) {
    Write-Host ""
    Write-Host "== $msg ==" -ForegroundColor Cyan
}

# ===========================================================================
# 1. Patch instructor-sidebar-v2.tsx: make InstructorDetailPanel's
#    collapsed state controllable from a parent.
# ===========================================================================
Write-Section "Patching instructor-sidebar-v2.tsx (InstructorDetailPanel)"

$sidebarFile = Join-Path $root "apps\web\components\ui\instructor-sidebar-v2.tsx"

if (-not (Test-Path $sidebarFile)) {
    Write-Host "ERROR: Could not find file at: $sidebarFile" -ForegroundColor Red
    exit 1
}

$sidebarContent = Get-Content -Path $sidebarFile -Raw
$sidebarOriginal = $sidebarContent
$sidebarChanges = 0

$oldSignature = @'
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
'@

$newSignature = @'
export function InstructorDetailPanel({
  activeGroupId,
  onNavigate,
  showBrand = false,
  collapsed: collapsedProp,
  onCollapsedChange
}: {
  activeGroupId: string;
  onNavigate?: () => void;
  showBrand?: boolean;
  /** Optional controlled collapse state. If omitted, the panel manages its own state. */
  collapsed?: boolean;
  onCollapsedChange?: (collapsed: boolean) => void;
}) {
  const pathname = usePathname();
  const [expanded, setExpanded] = useState<Set<string>>(new Set());
  const [internalCollapsed, setInternalCollapsed] = useState(false);
  const collapsed = collapsedProp ?? internalCollapsed;
  const setCollapsed = (value: boolean | ((prev: boolean) => boolean)) => {
    const next = typeof value === "function" ? (value as (prev: boolean) => boolean)(collapsed) : value;
    if (onCollapsedChange) onCollapsedChange(next);
    else setInternalCollapsed(next);
  };
  const [search, setSearch] = useState("");
'@

if ($sidebarContent.Contains($oldSignature)) {
    $sidebarContent = $sidebarContent.Replace($oldSignature, $newSignature)
    $sidebarChanges++
    Write-Host "  [OK] Made InstructorDetailPanel's collapsed state controllable." -ForegroundColor Green
} elseif ($sidebarContent.Contains("collapsedProp")) {
    Write-Host "  [SKIP] InstructorDetailPanel already patched." -ForegroundColor Yellow
} else {
    Write-Host "  [WARN] Could not find expected InstructorDetailPanel signature - file structure may differ." -ForegroundColor Yellow
}

if ($sidebarContent -ne $sidebarOriginal) {
    Set-Content -Path $sidebarFile -Value $sidebarContent -NoNewline -Encoding UTF8
    Write-Host "  [OK] Saved instructor-sidebar-v2.tsx ($sidebarChanges change(s))." -ForegroundColor Green
}

# ===========================================================================
# 2. Patch InstructorShell.tsx: lift collapsed state up, and make the
#    top bar / main content margin react to it.
# ===========================================================================
Write-Section "Patching InstructorShell.tsx"

$shellFile = Join-Path $root "apps\web\app\(instructor)\_components\InstructorShell.tsx"

if (-not (Test-Path $shellFile)) {
    Write-Host "ERROR: Could not find file at: $shellFile" -ForegroundColor Red
    exit 1
}

$shellContent = Get-Content -Path $shellFile -Raw
$shellOriginal = $shellContent
$shellChanges = 0

# --- 2a. Add panelCollapsed state, right after activeGroupId state ---
$oldStateLine = '  const [activeGroupId, setActiveGroupId] = useState(() => activeGroupIdFromPathname(pathname));'
$newStateLine = @'
  const [activeGroupId, setActiveGroupId] = useState(() => activeGroupIdFromPathname(pathname));
  const [panelCollapsed, setPanelCollapsed] = useState(false);
'@

if ($shellContent.Contains($oldStateLine) -and -not $shellContent.Contains("panelCollapsed")) {
    $shellContent = $shellContent.Replace($oldStateLine, $newStateLine)
    $shellChanges++
    Write-Host "  [OK] Added panelCollapsed state." -ForegroundColor Green
} elseif ($shellContent.Contains("panelCollapsed")) {
    Write-Host "  [SKIP] panelCollapsed state already present." -ForegroundColor Yellow
} else {
    Write-Host "  [WARN] Could not find activeGroupId state line to anchor on." -ForegroundColor Yellow
}

# --- 2b. Compute a sidebar-offset class based on panelCollapsed ---
$anchorForOffsetVar = 'const notifRef = useRef<HTMLDivElement>(null);'
$offsetVarBlock = @'
const notifRef = useRef<HTMLDivElement>(null);
'@
# We'll insert the offset constant right before the return statement instead,
# by anchoring on the JSX opening div, to keep this simple and robust.

$oldReturnAnchor = '  return (
    <div className="min-h-screen bg-paper">'
$newReturnAnchor = @'
  const sidebarOffsetClass = panelCollapsed ? "md:ml-[128px]" : "md:ml-[352px]";

  return (
    <div className="min-h-screen bg-paper">
'@

if ($shellContent.Contains($oldReturnAnchor) -and -not $shellContent.Contains("sidebarOffsetClass")) {
    $shellContent = $shellContent.Replace($oldReturnAnchor, $newReturnAnchor)
    $shellChanges++
    Write-Host "  [OK] Added sidebarOffsetClass computed value." -ForegroundColor Green
} elseif ($shellContent.Contains("sidebarOffsetClass")) {
    Write-Host "  [SKIP] sidebarOffsetClass already present." -ForegroundColor Yellow
} else {
    Write-Host "  [WARN] Could not find return-statement anchor to insert sidebarOffsetClass." -ForegroundColor Yellow
}

# --- 2c. Pass collapsed/onCollapsedChange into InstructorDetailPanel ---
$oldPanelUsage = '        <InstructorDetailPanel activeGroupId={activeGroupId} showBrand />'
$newPanelUsage = @'
        <InstructorDetailPanel
          activeGroupId={activeGroupId}
          showBrand
          collapsed={panelCollapsed}
          onCollapsedChange={setPanelCollapsed}
        />
'@

if ($shellContent.Contains($oldPanelUsage)) {
    $shellContent = $shellContent.Replace($oldPanelUsage, $newPanelUsage)
    $shellChanges++
    Write-Host "  [OK] Wired panelCollapsed into InstructorDetailPanel usage." -ForegroundColor Green
} elseif ($shellContent.Contains("onCollapsedChange={setPanelCollapsed}")) {
    Write-Host "  [SKIP] InstructorDetailPanel usage already wired." -ForegroundColor Yellow
} else {
    Write-Host "  [WARN] Could not find <InstructorDetailPanel activeGroupId={activeGroupId} showBrand /> usage." -ForegroundColor Yellow
}

# --- 2d. Replace hardcoded md:ml-[352px] on the top bar with the dynamic class ---
$oldTopBarClass = 'className="sticky top-0 z-40 flex items-center justify-between gap-3 border-b border-line bg-card/95 px-4 py-3 backdrop-blur-sm md:ml-[352px] md:px-6"'
$newTopBarClass = 'className={`sticky top-0 z-40 flex items-center justify-between gap-3 border-b border-line bg-card/95 px-4 py-3 backdrop-blur-sm transition-[margin] duration-300 ease-out ${sidebarOffsetClass} md:px-6`}'

if ($shellContent.Contains($oldTopBarClass)) {
    $shellContent = $shellContent.Replace($oldTopBarClass, $newTopBarClass)
    $shellChanges++
    Write-Host "  [OK] Made top bar margin reactive to panelCollapsed." -ForegroundColor Green
} elseif ($shellContent.Contains('${sidebarOffsetClass}') -and $shellContent -match "z-40") {
    Write-Host "  [SKIP] Top bar margin already reactive." -ForegroundColor Yellow
} else {
    Write-Host "  [WARN] Could not find expected top bar className string." -ForegroundColor Yellow
}

# --- 2e. Replace hardcoded md:ml-[352px] on the main content wrapper ---
$oldContentClass = '      <div className="md:ml-[352px]">'
$newContentClass = '      <div className={`transition-[margin] duration-300 ease-out ${sidebarOffsetClass}`}>'

if ($shellContent.Contains($oldContentClass)) {
    $shellContent = $shellContent.Replace($oldContentClass, $newContentClass)
    $shellChanges++
    Write-Host "  [OK] Made main content margin reactive to panelCollapsed." -ForegroundColor Green
} elseif ($shellContent -match '\{`transition-\[margin\] duration-300 ease-out \$\{sidebarOffsetClass\}`\}' ) {
    Write-Host "  [SKIP] Main content margin already reactive." -ForegroundColor Yellow
} else {
    Write-Host "  [WARN] Could not find expected main content wrapper className." -ForegroundColor Yellow
}

if ($shellContent -ne $shellOriginal) {
    Set-Content -Path $shellFile -Value $shellContent -NoNewline -Encoding UTF8
    Write-Host "  [OK] Saved InstructorShell.tsx ($shellChanges change(s))." -ForegroundColor Green
} else {
    Write-Host "  [INFO] No changes needed in InstructorShell.tsx." -ForegroundColor Yellow
}

# ===========================================================================
# DONE
# ===========================================================================
Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Sidebar collapse layout fix applied." -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Next steps:"
Write-Host "  1. git diff -> review both files"
Write-Host "  2. pnpm turbo run build   -> verify it compiles"
Write-Host "  3. Test: click the '<' collapse arrow -> top bar and content"
Write-Host "     should smoothly shift left to fill the freed-up space"
Write-Host "  4. Commit and push"