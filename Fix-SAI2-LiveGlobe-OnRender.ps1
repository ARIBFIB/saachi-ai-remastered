<#
.SYNOPSIS
    Fixes the final REAL TypeScript error in apps/web/components/ui/live-globe.tsx:
      TS2345: Property 'onRender' is missing in type '...' but required in type 'COBEOptions'.

    The installed `cobe` version (0.6.x) changed its API: instead of manually
    calling `globe.update({ phi, theta })` inside a requestAnimationFrame loop,
    cobe now requires an `onRender(state)` callback passed into createGlobe(...),
    which cobe itself calls every frame. You mutate the `state` object inside
    that callback to drive rotation/drag - cobe manages the animation loop.

    This script rewrites live-globe.tsx to use the onRender API while keeping
    all existing behavior: auto-rotation at `speed`, pointer-drag-to-rotate,
    pause-while-dragging, fade-in on init, and lazy-init via ResizeObserver
    when the canvas isn't sized yet.

.EXAMPLE
    PS D:\...\SAI2> .\Fix-SAI2-LiveGlobe-OnRender.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
if (-not $root) { $root = Get-Location }

function Write-Section($text) {
    Write-Host ""
    Write-Host ("=" * 90) -ForegroundColor DarkGray
    Write-Host "  $text" -ForegroundColor Cyan
    Write-Host ("=" * 90) -ForegroundColor DarkGray
}

$webPath  = Join-Path $root "apps\web"
$filePath = Join-Path $webPath "components\ui\live-globe.tsx"

if (-not (Test-Path $filePath)) {
    Write-Host "ERROR: could not find $filePath" -ForegroundColor Red
    Write-Host "Run this script from the SAI2 repo root." -ForegroundColor Red
    exit 1
}

Write-Section "Step 1/4 - Rewriting live-globe.tsx to use cobe's onRender API"

# Backup the current (still-broken) version first, just in case.
$backupPath = "$filePath.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Copy-Item -Path $filePath -Destination $backupPath -Force
Write-Host "  Backed up existing file to: $backupPath" -ForegroundColor DarkGray

$newContent = @'
"use client";

import { useEffect, useRef, useCallback } from "react";
import createGlobe from "cobe";

export interface LiveMarker {
  id: string;
  location: [number, number];
}

interface GlobeLiveProps {
  markers?: LiveMarker[];
  className?: string;
  speed?: number;
}

const defaultMarkers: LiveMarker[] = [
  { id: "karachi", location: [24.86, 67.0] },
  { id: "london", location: [51.51, -0.13] },
  { id: "tokyo", location: [35.68, 139.65] },
  { id: "nyc", location: [40.71, -74.01] },
  { id: "sydney", location: [-33.87, 151.21] },
  { id: "lagos", location: [6.52, 3.38] }
];

export function GlobeLive({ markers = defaultMarkers, className = "", speed = 0.003 }: GlobeLiveProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const pointerInteracting = useRef<{ x: number; y: number } | null>(null);
  const dragOffset = useRef({ phi: 0, theta: 0 });
  const phiOffsetRef = useRef(0);
  const thetaOffsetRef = useRef(0);
  const isPausedRef = useRef(false);
  const phiRef = useRef(0);

  const handlePointerDown = useCallback((e: React.PointerEvent) => {
    pointerInteracting.current = { x: e.clientX, y: e.clientY };
    if (canvasRef.current) canvasRef.current.style.cursor = "grabbing";
    isPausedRef.current = true;
  }, []);

  const handlePointerUp = useCallback(() => {
    if (pointerInteracting.current !== null) {
      phiOffsetRef.current += dragOffset.current.phi;
      thetaOffsetRef.current += dragOffset.current.theta;
      dragOffset.current = { phi: 0, theta: 0 };
    }
    pointerInteracting.current = null;
    if (canvasRef.current) canvasRef.current.style.cursor = "grab";
    isPausedRef.current = false;
  }, []);

  useEffect(() => {
    const handlePointerMove = (e: PointerEvent) => {
      if (pointerInteracting.current !== null) {
        dragOffset.current = {
          phi: (e.clientX - pointerInteracting.current.x) / 300,
          theta: (e.clientY - pointerInteracting.current.y) / 1000
        };
      }
    };
    window.addEventListener("pointermove", handlePointerMove, { passive: true });
    window.addEventListener("pointerup", handlePointerUp, { passive: true });
    return () => {
      window.removeEventListener("pointermove", handlePointerMove);
      window.removeEventListener("pointerup", handlePointerUp);
    };
  }, [handlePointerUp]);

  useEffect(() => {
    if (!canvasRef.current) return;
    const canvas = canvasRef.current;
    let globe: ReturnType<typeof createGlobe> | null = null;

    function init() {
      const size = canvas.offsetWidth;
      if (size === 0 || globe) return;

      const dpr = Math.min(window.devicePixelRatio || 1, 2);

      // Render colors are WebGL RGB triples consumed directly by cobe's
      // renderer - not Tailwind utility classes - so they're literal values
      // here rather than CSS var references. Tuned to the brand accent
      // (accent-violet #7c3aed -> ~0.486, 0.227, 0.929).
      globe = createGlobe(canvas, {
        devicePixelRatio: dpr,
        width: size * dpr,
        height: size * dpr,
        phi: 0,
        theta: 0.2,
        dark: 0,
        diffuse: 1.5,
        mapSamples: 16000,
        mapBrightness: 10,
        baseColor: [0.93, 0.9, 0.97],
        markerColor: [0.486, 0.227, 0.929],
        glowColor: [0.94, 0.91, 0.98],
        markers: markers.map((m) => ({ location: m.location, size: 0.05 })),
        opacity: 0.85,
        onRender: (state) => {
          if (!isPausedRef.current) phiRef.current += speed;
          state.phi = phiRef.current + phiOffsetRef.current + dragOffset.current.phi;
          state.theta = 0.2 + thetaOffsetRef.current + dragOffset.current.theta;
          state.width = size * dpr;
          state.height = size * dpr;
        }
      });

      setTimeout(() => canvas && (canvas.style.opacity = "1"));
    }

    if (canvas.offsetWidth > 0) {
      init();
    } else {
      const ro = new ResizeObserver((entries) => {
        if (entries[0]?.contentRect.width > 0) {
          ro.disconnect();
          init();
        }
      });
      ro.observe(canvas);
    }

    return () => {
      if (globe) globe.destroy();
    };
  }, [markers, speed]);

  return (
    <div className={`relative aspect-square select-none ${className}`}>
      <canvas
        ref={canvasRef}
        onPointerDown={handlePointerDown}
        style={{
          width: "100%",
          height: "100%",
          cursor: "grab",
          opacity: 0,
          transition: "opacity 1.2s ease",
          borderRadius: "50%",
          touchAction: "none"
        }}
      />
    </div>
  );
}
'@

Set-Content -Path $filePath -Value $newContent -NoNewline
Write-Host "  Rewrote: $filePath" -ForegroundColor Green
Write-Host "    - now drives rotation/drag via cobe's onRender(state) callback" -ForegroundColor Green
Write-Host "    - removed the manual requestAnimationFrame + globe.update() loop" -ForegroundColor Green
Write-Host "    - kept: auto-rotate speed, drag-to-rotate, pause-on-drag, fade-in, lazy ResizeObserver init" -ForegroundColor Green

# ---------------------------------------------------------------------------
# Step 2 - Clean cache
# ---------------------------------------------------------------------------
Write-Section "Step 2/4 - Cleaning .next cache for apps/web"

$nextDir = Join-Path $webPath ".next"
if (Test-Path $nextDir) {
    Remove-Item -Path $nextDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  Removed $nextDir" -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# Step 3 - Rebuild
# ---------------------------------------------------------------------------
Write-Section "Step 3/4 - Rebuilding apps/web"

Push-Location $root
try {
    pnpm --filter web run build
    $buildOk = ($LASTEXITCODE -eq 0)
} finally {
    Pop-Location
}

if (-not $buildOk) {
    Write-Host ""
    Write-Host "Build still failing - see output above." -ForegroundColor Red
    Write-Host "A restored backup of the pre-rewrite file is available at:" -ForegroundColor Red
    Write-Host "  $backupPath" -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------------------------
# Step 4 - Re-verify
# ---------------------------------------------------------------------------
Write-Section "Step 4/4 - Re-running type-check + lint for apps/web"

Push-Location $webPath
try {
    Write-Host "type-check:" -ForegroundColor Cyan
    pnpm run type-check
    $typeCheckOk = ($LASTEXITCODE -eq 0)

    Write-Host ""
    Write-Host "lint:" -ForegroundColor Cyan
    pnpm run lint
} finally {
    Pop-Location
}

Write-Section "SUMMARY"
if ($typeCheckOk) {
    Write-Host "apps/web type-check: PASSED - all clear." -ForegroundColor Green
    Write-Host ""
    Write-Host "Visually verify the globe on the homepage (Live global visitors section)" -ForegroundColor Cyan
    Write-Host "still auto-rotates and responds to drag, since the animation approach changed." -ForegroundColor Cyan
} else {
    Write-Host "apps/web type-check: FAILED - see output above." -ForegroundColor Red
}
Write-Host ""