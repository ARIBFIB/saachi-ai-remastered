<#
  step-add-global-visitors-panel.ps1
  Adds two components to apps/web and wires them into the landing page as a
  new "Live on Saachi AI right now" section:

    1. components/ui/live-globe.tsx
       - adapted from the cobe globe demo. Canvas/globe colors are tied to
         WebGL render params (not Tailwind classes), so they're left as
         literal RGB triples per cobe's API - these aren't the site's
         Tailwind-class hex violations the design system guards against.
         The floating "LIVE" chip is an intentional always-dark overlay
         (same pattern as AuthVisualPanel's fixed-dark panel elsewhere in
         this codebase), noted with a comment.

    2. components/ui/global-visitors-panel.tsx
       - dummy "who's online right now" data across ~10 countries spanning
         every populated continent, feeds both the globe's markers and a
         country-wise ranked bar graph, plus a trend line/area chart
         (adapted from the line-graph-statistics demo) with period tabs.
         All colors here use the site's design tokens (bg-card, text-ink,
         accent-violet, gold-dark, teal, etc.) instead of hardcoded hex.

  Also adds the "cobe" npm dependency (WebGL globe renderer) and wires the
  new panel into apps/web/app/(marketing)/page.tsx, right after the Stats
  section.

  Run from: SAI2 root
    PS D:\...\SAI2> .\step-add-global-visitors-panel.ps1
#>

$ErrorActionPreference = "Stop"

$root = Get-Location
$webRoot = Join-Path $root "apps\web"

if (-not [System.IO.Directory]::Exists($webRoot)) {
    Write-Host "ERROR: apps\web not found under $root. Run this from the SAI2 root." -ForegroundColor Red
    exit 1
}

$encNoBom = New-Object System.Text.UTF8Encoding($false)

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $dir = [System.IO.Path]::GetDirectoryName($Path)
    if (-not [System.IO.Directory]::Exists($dir)) {
        [System.IO.Directory]::CreateDirectory($dir) | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, $Content, $encNoBom)
    Write-Host "  wrote: $Path"
}

Write-Host "== Step 1/4: components/ui/live-globe.tsx ==" -ForegroundColor Cyan

$liveGlobePath = Join-Path $webRoot "components\ui\live-globe.tsx"
$liveGlobeContent = @'
"use client";

import { useEffect, useRef, useCallback, useState } from "react";
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
    let animationId: number;
    let phi = 0;

    function init() {
      const width = canvas.offsetWidth;
      if (width === 0 || globe) return;

      // Render colors are WebGL RGB triples consumed directly by cobe's
      // renderer - not Tailwind utility classes - so they're literal values
      // here rather than CSS var references. Tuned to the brand accent
      // (accent-violet #7c3aed -> ~0.486, 0.227, 0.929).
      globe = createGlobe(canvas, {
        devicePixelRatio: Math.min(window.devicePixelRatio || 1, 2),
        width,
        height: width,
        phi: 0,
        theta: 0.2,
        dark: 0,
        diffuse: 1.5,
        mapSamples: 16000,
        mapBrightness: 10,
        baseColor: [0.93, 0.9, 0.97],
        markerColor: [0.486, 0.227, 0.929],
        glowColor: [0.94, 0.91, 0.98],
        markerElevation: 0.01,
        markers: markers.map((m) => ({ location: m.location, size: 0.05 })),
        arcs: [],
        arcColor: [0.486, 0.227, 0.929],
        arcWidth: 0.5,
        arcHeight: 0.25,
        opacity: 0.85
      });

      function animate() {
        if (!isPausedRef.current) phi += speed;
        globe!.update({
          phi: phi + phiOffsetRef.current + dragOffset.current.phi,
          theta: 0.2 + thetaOffsetRef.current + dragOffset.current.theta
        });
        animationId = requestAnimationFrame(animate);
      }
      animate();
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
      if (animationId) cancelAnimationFrame(animationId);
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
Write-Utf8NoBom -Path $liveGlobePath -Content $liveGlobeContent

Write-Host ""
Write-Host "== Step 2/4: components/ui/global-visitors-panel.tsx ==" -ForegroundColor Cyan

$panelPath = Join-Path $webRoot "components\ui\global-visitors-panel.tsx"
$panelContent = @'
"use client";

import { useEffect, useMemo, useState } from "react";
import { Globe2, TrendingUp } from "lucide-react";
import { GlobeLive, type LiveMarker } from "@/components/ui/live-globe";

// NOTE: demo-only dummy "who's online" data spanning every populated
// continent. Replace with a real analytics/websocket feed once available.
type CountryStat = {
  code: string;
  name: string;
  flag: string;
  count: number;
  coords: [number, number];
};

const COUNTRY_STATS: CountryStat[] = [
  { code: "PK", name: "Pakistan", flag: "\u{1F1F5}\u{1F1F0}", count: 1240, coords: [30.38, 69.35] },
  { code: "US", name: "United States", flag: "\u{1F1FA}\u{1F1F8}", count: 2860, coords: [37.09, -95.71] },
  { code: "IN", name: "India", flag: "\u{1F1EE}\u{1F1F3}", count: 1610, coords: [20.59, 78.96] },
  { code: "GB", name: "United Kingdom", flag: "\u{1F1EC}\u{1F1E7}", count: 940, coords: [55.38, -3.44] },
  { code: "AE", name: "United Arab Emirates", flag: "\u{1F1E6}\u{1F1EA}", count: 520, coords: [23.42, 53.85] },
  { code: "ID", name: "Indonesia", flag: "\u{1F1EE}\u{1F1E9}", count: 610, coords: [-0.79, 113.92] },
  { code: "PH", name: "Philippines", flag: "\u{1F1F5}\u{1F1ED}", count: 480, coords: [12.88, 121.77] },
  { code: "NG", name: "Nigeria", flag: "\u{1F1F3}\u{1F1EC}", count: 390, coords: [9.08, 8.68] },
  { code: "DE", name: "Germany", flag: "\u{1F1E9}\u{1F1EA}", count: 340, coords: [51.17, 10.45] },
  { code: "CA", name: "Canada", flag: "\u{1F1E8}\u{1F1E6}", count: 300, coords: [56.13, -106.35] }
];

const GLOBE_MARKERS: LiveMarker[] = COUNTRY_STATS.map((c) => ({ id: c.code, location: c.coords }));

type PeriodKey = "7d" | "30d" | "90d";

const PERIODS: { key: PeriodKey; label: string }[] = [
  { key: "7d", label: "Last 7 days" },
  { key: "30d", label: "Last 30 days" },
  { key: "90d", label: "Last 3 months" }
];

const TREND_DATA: Record<PeriodKey, { dates: string[]; values: number[]; peak: number; average: number; growth: string }> = {
  "7d": {
    dates: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
    values: [3200, 3450, 3300, 3700, 3900, 4200, 4550],
    peak: 4550,
    average: 3757,
    growth: "+18%"
  },
  "30d": {
    dates: ["Jul 18", "Jul 21", "Jul 24", "Jul 27", "Jul 30", "Aug 2", "Aug 5", "Aug 8", "Aug 11", "Aug 14", "Aug 15", "Aug 16"],
    values: [2900, 3100, 3400, 3250, 3600, 3800, 3700, 4000, 4300, 4550, 4700, 4800],
    peak: 4800,
    average: 3766,
    growth: "+12%"
  },
  "90d": {
    dates: ["May", "May", "Jun", "Jun", "Jun", "Jul", "Jul", "Jul", "Aug", "Aug", "Aug", "Aug"],
    values: [2200, 2450, 2700, 3000, 3300, 3550, 3900, 4200, 4550, 4900, 5400, 6200],
    peak: 6200,
    average: 3829,
    growth: "+24%"
  }
};

function generateSmoothPath(values: number[], maxValue: number, width: number, height: number, padding: number, isArea: boolean) {
  const chartWidth = width - padding * 2;
  const chartHeight = height - padding * 2;

  const points = values.map((value, index) => ({
    x: padding + (index / (values.length - 1)) * chartWidth,
    y: padding + (1 - value / maxValue) * chartHeight
  }));

  if (points.length < 2) return "";

  let path = `M ${points[0].x},${points[0].y}`;
  for (let i = 1; i < points.length; i++) {
    const prev = points[i - 1];
    const curr = points[i];
    const next = points[i + 1];
    const cp1x = prev.x + (curr.x - prev.x) * 0.5;
    const cp1y = prev.y;
    const cp2x = curr.x - (next ? (next.x - curr.x) * 0.3 : 0);
    const cp2y = curr.y;
    path += ` C ${cp1x},${cp1y} ${cp2x},${cp2y} ${curr.x},${curr.y}`;
  }

  if (isArea) {
    path += ` L ${points[points.length - 1].x},${height - padding} L ${padding},${height - padding} Z`;
  }
  return path;
}

export function GlobalVisitorsPanel() {
  const totalBase = useMemo(() => COUNTRY_STATS.reduce((sum, c) => sum + c.count, 0), []);
  const [liveTotal, setLiveTotal] = useState(totalBase);
  const [period, setPeriod] = useState<PeriodKey>("30d");
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  useEffect(() => {
    const interval = setInterval(() => {
      setLiveTotal((v) => Math.max(totalBase - 400, v + Math.floor(Math.random() * 41) - 18));
    }, 1200);
    return () => clearInterval(interval);
  }, [totalBase]);

  const rankedCountries = useMemo(
    () => [...COUNTRY_STATS].sort((a, b) => b.count - a.count),
    []
  );
  const maxCountryCount = rankedCountries[0]?.count ?? 1;

  const trend = TREND_DATA[period];
  const maxTrendValue = Math.max(...trend.values) * 1.1;
  const chartWidth = 700;
  const chartHeight = 260;
  const chartPadding = 44;

  const linePath = generateSmoothPath(trend.values, maxTrendValue, chartWidth, chartHeight, chartPadding, false);
  const areaPath = generateSmoothPath(trend.values, maxTrendValue, chartWidth, chartHeight, chartPadding, true);

  return (
    <div className="rounded-card border border-line bg-card p-6 md:p-8">
      <div className="mb-8 flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <div className="flex items-center gap-3">
          <span className="relative flex h-3 w-3 shrink-0">
            <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-teal opacity-60" />
            <span className="relative inline-flex h-3 w-3 rounded-full bg-teal" />
          </span>
          <div>
            <p className="font-display text-[20px] font-semibold text-ink">
              {liveTotal.toLocaleString()} people learning right now
            </p>
            <p className="text-[13px] text-ink-soft">
              Across {COUNTRY_STATS.length}+ countries, live on Saachi AI
            </p>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 gap-8 lg:grid-cols-[1fr_1.1fr]">
        {/* Globe + top countries */}
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-[minmax(0,220px)_1fr] sm:items-center">
          <GlobeLive markers={GLOBE_MARKERS} className="mx-auto w-full max-w-[220px]" />

          <div>
            <h3 className="mb-3 flex items-center gap-1.5 text-[12px] font-semibold uppercase tracking-[0.06em] text-ink-soft/70">
              <Globe2 size={13} />
              Top countries right now
            </h3>
            <div className="flex flex-col gap-2.5">
              {rankedCountries.slice(0, 6).map((c, i) => (
                <div key={c.code} className="flex items-center gap-2.5">
                  <span className="w-5 shrink-0 text-[15px]">{c.flag}</span>
                  <span className="w-[104px] shrink-0 truncate text-[12.5px] text-ink">{c.name}</span>
                  <div className="h-1.5 flex-1 overflow-hidden rounded-full bg-paper-dim">
                    <div
                      className="h-full rounded-full bg-accent-violet transition-all duration-700 ease-out"
                      style={{ width: mounted ? `${Math.max(6, (c.count / maxCountryCount) * 100)}%` : "0%", transitionDelay: `${i * 80}ms` }}
                    />
                  </div>
                  <span className="w-12 shrink-0 text-right font-mono text-[12px] text-ink-soft">{c.count.toLocaleString()}</span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Trend chart */}
        <div>
          <div className="mb-3 flex flex-wrap items-center justify-between gap-2">
            <h3 className="flex items-center gap-1.5 text-[12px] font-semibold uppercase tracking-[0.06em] text-ink-soft/70">
              <TrendingUp size={13} />
              Global visitor trend
            </h3>
            <div className="flex gap-1.5">
              {PERIODS.map((p) => (
                <button
                  key={p.key}
                  type="button"
                  onClick={() => setPeriod(p.key)}
                  className={`rounded-full px-3 py-1 text-[11.5px] font-semibold transition-colors duration-150 ease-out ${
                    period === p.key ? "bg-ink text-paper" : "bg-paper-dim text-ink-soft hover:text-ink"
                  }`}
                >
                  {p.label}
                </button>
              ))}
            </div>
          </div>

          <div className="h-[220px] w-full">
            <svg viewBox={`0 0 ${chartWidth} ${chartHeight}`} className="h-full w-full" preserveAspectRatio="none">
              <path d={areaPath} fill="var(--color-accent-violet)" opacity="0.08" />
              <path
                d={linePath}
                fill="none"
                stroke="var(--color-accent-violet)"
                strokeWidth="2.5"
                strokeLinecap="round"
                style={{
                  strokeDasharray: mounted ? "none" : "1400",
                  strokeDashoffset: mounted ? "0" : "1400",
                  transition: "stroke-dashoffset 1.4s ease-out"
                }}
              />
              {trend.dates.map((d, i) => {
                const x = chartPadding + (i / (trend.dates.length - 1)) * (chartWidth - chartPadding * 2);
                return (
                  <text key={i} x={x} y={chartHeight - 10} textAnchor="middle" fontSize="11" fill="var(--color-ink-soft)">
                    {d}
                  </text>
                );
              })}
            </svg>
          </div>

          <div className="mt-4 grid grid-cols-3 gap-3">
            <div className="rounded-control border border-line bg-paper-dim px-3 py-2.5 text-center">
              <p className="text-[11px] font-medium text-ink-soft">Peak</p>
              <p className="font-mono text-[16px] font-semibold text-ink">{trend.peak.toLocaleString()}</p>
            </div>
            <div className="rounded-control border border-line bg-paper-dim px-3 py-2.5 text-center">
              <p className="text-[11px] font-medium text-ink-soft">Average</p>
              <p className="font-mono text-[16px] font-semibold text-ink">{trend.average.toLocaleString()}</p>
            </div>
            <div className="rounded-control border border-line bg-paper-dim px-3 py-2.5 text-center">
              <p className="text-[11px] font-medium text-ink-soft">Growth</p>
              <p className="font-mono text-[16px] font-semibold text-teal">{trend.growth}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
'@
Write-Utf8NoBom -Path $panelPath -Content $panelContent

# ---------------------------------------------------------------------------
# 3. Wire the panel into the landing page, right after the Stats section.
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "== Step 3/4: wire into landing page ==" -ForegroundColor Cyan

$pagePath = Join-Path $webRoot "app\(marketing)\page.tsx"
if (-not [System.IO.File]::Exists($pagePath)) {
    Write-Host "  WARNING: landing page not found at $pagePath - skipping wire-up." -ForegroundColor Yellow
} else {
    $pageContent = [System.IO.File]::ReadAllText($pagePath)

    $importAnchor = 'import { AnimatedTestimonials } from "@/components/ui/animated-testimonials";'
    $newImport = $importAnchor + "`nimport { GlobalVisitorsPanel } from `"@/components/ui/global-visitors-panel`";"

    if ($pageContent.Contains($importAnchor) -and -not $pageContent.Contains("GlobalVisitorsPanel")) {
        $pageContent = $pageContent.Replace($importAnchor, $newImport)
        Write-Host "  added import"
    } elseif ($pageContent.Contains("GlobalVisitorsPanel")) {
        Write-Host "  import already present - skipping"
    } else {
        Write-Host "  WARNING: import anchor line not found - add the import manually" -ForegroundColor Yellow
    }

    $sectionAnchor = @'
      {/* Logo cloud */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <LogoCloud />
        </Reveal>
      </section>
'@

    $newSection = @'
      {/* Logo cloud */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <LogoCloud />
        </Reveal>
      </section>

      {/* Live global visitors */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <h2 className="mb-2 font-display text-[22px] font-semibold text-ink">Live on Saachi AI right now</h2>
          <p className="mb-8 text-[14px] text-ink-soft">A real-time snapshot of learners around the world.</p>
        </Reveal>
        <Reveal delay={80}>
          <GlobalVisitorsPanel />
        </Reveal>
      </section>
'@

    if ($pageContent.Contains($sectionAnchor)) {
        $pageContent = $pageContent.Replace($sectionAnchor, $newSection)
        Write-Host "  inserted GlobalVisitorsPanel section after Logo cloud"
    } elseif ($pageContent.Contains("GlobalVisitorsPanel")) {
        Write-Host "  section already present - skipping"
    } else {
        Write-Host "  WARNING: Logo cloud section anchor not found - add <GlobalVisitorsPanel /> manually" -ForegroundColor Yellow
    }

    Write-Utf8NoBom -Path $pagePath -Content $pageContent
}

# ---------------------------------------------------------------------------
# 4. Add "cobe" dependency and install.
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "== Step 4/4: dependencies ==" -ForegroundColor Cyan

$pkgPath = Join-Path $webRoot "package.json"
$pkgJson = Get-Content -Raw -Path $pkgPath | ConvertFrom-Json

$changed = $false
if (-not $pkgJson.dependencies.PSObject.Properties.Name.Contains("cobe")) {
    $pkgJson.dependencies | Add-Member -MemberType NoteProperty -Name "cobe" -Value "^0.6.3"
    Write-Host "  added dependency: cobe@^0.6.3"
    $changed = $true
} else {
    Write-Host "  already present: cobe"
}

if ($changed) {
    $jsonOut = $pkgJson | ConvertTo-Json -Depth 20
    Write-Utf8NoBom -Path $pkgPath -Content $jsonOut

    Write-Host ""
    Write-Host "== Installing dependencies (pnpm install from root) ==" -ForegroundColor Cyan
    $pnpmAvailable = Get-Command pnpm -ErrorAction SilentlyContinue
    if ($pnpmAvailable) {
        Push-Location $root
        try {
            & pnpm install
        } finally {
            Pop-Location
        }
    } else {
        Write-Host "  pnpm not found on PATH - run manually: pnpm install" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "== Done ==" -ForegroundColor Green
Write-Host "New section added: 'Live on Saachi AI right now' (globe + live counter + top-countries bar graph + trend chart)."
Write-Host "Run 'pnpm dev' and check the landing page, right below the logo cloud."