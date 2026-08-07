# step10-lottie-loading-everywhere.ps1
# Run from: SAI2 root folder

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

Write-Host "Step 10: wiring loading.json (Lottie) as the site-wide loading animation..." -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 0. Copy loading.json into apps/web/public so it's servable at /animations/loading.json
# ---------------------------------------------------------------------------
$sourceJson = "assets\animation\loading.json"
$destJson = "apps\web\public\animations\loading.json"

if (-not (Test-Path $sourceJson)) {
    Write-Host "  ERROR: source file not found at $sourceJson - aborting. Adjust the path in this script if it's elsewhere." -ForegroundColor Red
    exit 1
}

$destDir = Split-Path -Parent (Join-Path -Path (Get-Location).Path -ChildPath $destJson)
if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
Copy-Item -Path $sourceJson -Destination (Join-Path -Path (Get-Location).Path -ChildPath $destJson) -Force
Write-Host "  copied $sourceJson -> $destJson"

# ---------------------------------------------------------------------------
# 1. Add lottie-react dependency to apps/web
# ---------------------------------------------------------------------------
Patch-File -Path "apps\web\package.json" `
  -OldStr '"lucide-react": "^0.445.0",' `
  -NewStr @'
"lucide-react": "^0.445.0",
    "lottie-react": "^2.4.0",
'@ `
  -Label "add lottie-react dependency"

# ---------------------------------------------------------------------------
# 2. Loading component (packages/ui) - wraps lottie-react, sized/centered
# ---------------------------------------------------------------------------
$loadingComponent = @'
"use client";

import Lottie from "lottie-react";
import { cn } from "../cn";

export type LoadingProps = {
  size?: number;
  label?: string;
  fullScreen?: boolean;
  className?: string;
};

export function Loading({ size = 120, label, fullScreen = false, className }: LoadingProps) {
  return (
    <div
      className={cn(
        "flex flex-col items-center justify-center gap-3",
        fullScreen ? "min-h-[60vh] w-full" : "py-10",
        className
      )}
      role="status"
      aria-live="polite"
    >
      <Lottie
        path="/animations/loading.json"
        loop
        autoplay
        style={{ width: size, height: size }}
      />
      {label && <p className="text-[13px] text-ink-soft">{label}</p>}
      <span className="sr-only">Loading</span>
    </div>
  );
}
'@
Write-Utf8NoBom -Path "packages\ui\src\components\Loading.tsx" -Content $loadingComponent

Patch-File -Path "packages\ui\src\index.ts" `
  -OldStr 'export * from "./components/SocialLoginButtons";' `
  -NewStr @'
export * from "./components/SocialLoginButtons";
export * from "./components/Loading";
'@ `
  -Label "export Loading component"

# ---------------------------------------------------------------------------
# 3. lottie-react needs to resolve in web app - add to ui package deps too
#    (ui is workspace-linked, but the component itself lives/renders in web)
# ---------------------------------------------------------------------------
Patch-File -Path "packages\ui\package.json" `
  -OldStr '"lucide-react": "^0.445.0"
  },' `
  -NewStr @'
"lucide-react": "^0.445.0",
    "lottie-react": "^2.4.0"
  },
'@ `
  -Label "add lottie-react to @saachi/ui dependencies"

# ---------------------------------------------------------------------------
# 4. Route-level loading.tsx files (Next.js App Router automatic loading UI)
#    One per route group so every page transition shows the animation.
# ---------------------------------------------------------------------------
$routeLoadingTemplate = @'
import { Loading } from "@saachi/ui";

export default function RouteLoading() {
  return <Loading fullScreen label="Loading..." />;
}
'@

Write-Utf8NoBom -Path "apps\web\app\(marketing)\loading.tsx" -Content $routeLoadingTemplate
Write-Utf8NoBom -Path "apps\web\app\(auth)\loading.tsx" -Content $routeLoadingTemplate
Write-Utf8NoBom -Path "apps\web\app\(learner)\loading.tsx" -Content $routeLoadingTemplate
Write-Utf8NoBom -Path "apps\web\app\(instructor)\loading.tsx" -Content $routeLoadingTemplate
Write-Utf8NoBom -Path "apps\web\app\(corporate)\loading.tsx" -Content $routeLoadingTemplate

# ---------------------------------------------------------------------------
# 5. Course detail page - swap SkeletonText for Loading
# ---------------------------------------------------------------------------
Patch-File -Path "apps\web\app\(marketing)\courses\[slug]\page.tsx" `
  -OldStr '  SkeletonText,
  EmptyState
} from "@saachi/ui";' `
  -NewStr @'
  EmptyState,
  Loading
} from "@saachi/ui";
'@ `
  -Label "swap SkeletonText import for Loading in course detail"

Patch-File -Path "apps\web\app\(marketing)\courses\[slug]\page.tsx" `
  -OldStr '        <main className="mx-auto max-w-[1140px] px-6 py-16">
          <SkeletonText lines={4} />
        </main>' `
  -NewStr @'
        <main className="mx-auto max-w-[1140px] px-6 py-16">
          <Loading label="Loading course..." />
        </main>
'@ `
  -Label "use Loading in course detail loading state"

# ---------------------------------------------------------------------------
# 6. Course player - swap SkeletonText for Loading
# ---------------------------------------------------------------------------
Patch-File -Path "apps\web\app\(learner)\learn\[courseId]\[lessonId]\page.tsx" `
  -OldStr 'import { Button, EmptyState, SkeletonText } from "@saachi/ui";' `
  -NewStr 'import { Button, EmptyState, Loading } from "@saachi/ui";' `
  -Label "swap SkeletonText import for Loading in course player"

Patch-File -Path "apps\web\app\(learner)\learn\[courseId]\[lessonId]\page.tsx" `
  -OldStr '      <main className="mx-auto max-w-[1140px] px-6 py-16">
        <SkeletonText lines={4} />
      </main>' `
  -NewStr @'
      <main className="mx-auto max-w-[1140px] px-6 py-16">
        <Loading label="Loading lesson..." />
      </main>
'@ `
  -Label "use Loading in course player loading state"

# ---------------------------------------------------------------------------
# 7. Community Q&A page - swap SkeletonText for Loading
# ---------------------------------------------------------------------------
Patch-File -Path "apps\web\app\(learner)\community\[courseId]\page.tsx" `
  -OldStr 'import { Button, Card, Textarea, EmptyState, SkeletonText } from "@saachi/ui";' `
  -NewStr 'import { Button, Card, Textarea, EmptyState, Loading } from "@saachi/ui";' `
  -Label "swap SkeletonText import for Loading in community page"

Patch-File -Path "apps\web\app\(learner)\community\[courseId]\page.tsx" `
  -OldStr '      <main className="mx-auto max-w-[800px] px-6 py-10 md:px-10">
        <SkeletonText lines={4} />
      </main>' `
  -NewStr @'
      <main className="mx-auto max-w-[800px] px-6 py-10 md:px-10">
        <Loading label="Loading discussion..." />
      </main>
'@ `
  -Label "use Loading in community page loading state"

# ---------------------------------------------------------------------------
# 8. Mock auth delay + checkout "Processing" - use inline small Loading too
#    (Button-level, not full page - just the checkout Pay button spinner)
# ---------------------------------------------------------------------------
Patch-File -Path "apps\web\app\(learner)\checkout\page.tsx" `
  -OldStr '            <Button size="lg" className="w-full" onClick={handlePay} disabled={isPaying}>
              {isPaying ? "Processing..." : `Pay ${formatCurrency(cart.total(), currency)}`}
            </Button>' `
  -NewStr @'
            {isPaying ? (
              <div className="mt-4">
                <Loading size={72} label="Processing payment..." />
              </div>
            ) : (
              <Button size="lg" className="w-full" onClick={handlePay}>
                Pay {formatCurrency(cart.total(), currency)}
              </Button>
            )}
'@ `
  -Label "use Loading during checkout payment processing"

Patch-File -Path "apps\web\app\(learner)\checkout\page.tsx" `
  -OldStr 'import { Button, Card, Input, EmptyState } from "@saachi/ui";' `
  -NewStr 'import { Button, Card, Input, EmptyState, Loading } from "@saachi/ui";' `
  -Label "import Loading in checkout"

Write-Host ""
Write-Host "Step 10 done." -ForegroundColor Green
Write-Host "IMPORTANT: run pnpm install (new lottie-react dependency was added)" -ForegroundColor Yellow
Write-Host "Then: pnpm dev:web" -ForegroundColor Green
Write-Host "Test: navigate between route groups (marketing -> learner -> instructor -> corporate) to see the loading.json animation on transitions; open a course detail page, course player, community page, and click Pay on checkout" -ForegroundColor Green