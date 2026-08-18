<#
  SAI2 - Learner Dashboard: Activity Chart + Bento "Explore" Grid
  Frontend-only, dummy data. Run from repo root:
  D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2
  Usage: powershell -ExecutionPolicy Bypass -File .\add-dashboard-widgets.ps1
#>

$ErrorActionPreference = "Stop"

$root = Get-Location
Write-Host "Running in: $root" -ForegroundColor Cyan

$uiDir        = Join-Path $root "apps\web\components\ui"
$dashboardFile = Join-Path $root "apps\web\app\(learner)\dashboard\page.tsx"

if (-not (Test-Path (Join-Path $root "apps\web"))) {
    Write-Host "ERROR: 'apps\web' not found. Run this script from the SAI2 repo root." -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $dashboardFile)) {
    Write-Host "ERROR: dashboard\page.tsx not found at expected path:`n$dashboardFile" -ForegroundColor Red
    exit 1
}

New-Item -ItemType Directory -Force -Path $uiDir | Out-Null

# =========================================================================
# 1) apps\web\components\ui\bento-grid.tsx
# =========================================================================
$bentoPath = Join-Path $uiDir "bento-grid.tsx"

$bentoContent = @'
import { ReactNode } from "react";
import Link from "next/link";
import { ArrowRight } from "lucide-react";
import { cn } from "@saachi/ui";

const BentoGrid = ({ children, className }: { children: ReactNode; className?: string }) => {
  return (
    <div className={cn("grid w-full auto-rows-[14rem] grid-cols-1 gap-4 md:auto-rows-[15rem] md:grid-cols-3", className)}>
      {children}
    </div>
  );
};

const BentoCard = ({
  name,
  className,
  Icon,
  description,
  href,
  cta
}: {
  name: string;
  className?: string;
  Icon: any;
  description: string;
  href: string;
  cta: string;
}) => (
  <div
    className={cn(
      "group relative col-span-1 flex flex-col justify-between overflow-hidden rounded-card border border-line bg-card transition-colors hover:border-gold-dark/40",
      className
    )}
  >
    <div className="pointer-events-none z-10 flex flex-col gap-1.5 p-6 transition-transform duration-300 ease-out group-hover:-translate-y-6">
      <Icon size={26} strokeWidth={1.5} className="mb-1 text-gold-dark transition-transform duration-300 ease-out group-hover:scale-90" />
      <h3 className="text-[15px] font-semibold text-ink">{name}</h3>
      <p className="text-[13px] text-ink-soft">{description}</p>
    </div>

    <div className="pointer-events-none absolute bottom-0 flex w-full translate-y-8 items-center p-5 opacity-0 transition-all duration-300 ease-out group-hover:translate-y-0 group-hover:opacity-100">
      <Link href={href} className="pointer-events-auto flex items-center gap-1.5 text-[13px] font-semibold text-gold-dark hover:underline">
        {cta}
        <ArrowRight size={14} />
      </Link>
    </div>
  </div>
);

export { BentoCard, BentoGrid };
'@

Set-Content -Path $bentoPath -Value $bentoContent -Encoding UTF8
Write-Host "Created: $bentoPath" -ForegroundColor Green

# =========================================================================
# 2) apps\web\components\ui\activity-chart-card.tsx
# =========================================================================
$activityPath = Join-Path $uiDir "activity-chart-card.tsx"

$activityContent = @'
"use client";

import * as React from "react";
import { motion } from "framer-motion";
import { ChevronDown, TrendingUp } from "lucide-react";
import { Card, Button, cn } from "@saachi/ui";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger
} from "@/components/ui/dropdown-menu";

// NOTE: demo-only. No backend learning-activity endpoint exists yet; this
// renders static per-range dummy data. The dropdown only swaps which local
// dataset is shown - no network request is made.

interface ActivityDataPoint {
  day: string;
  value: number;
}

interface ActivityChartCardProps {
  title?: string;
  className?: string;
}

const RANGE_DATA: Record<string, { total: string; trend: string; points: ActivityDataPoint[] }> = {
  Weekly: {
    total: "12h",
    trend: "+8% from last week",
    points: [
      { day: "S", value: 1 },
      { day: "M", value: 2.5 },
      { day: "T", value: 1.5 },
      { day: "W", value: 3 },
      { day: "T", value: 1 },
      { day: "F", value: 2 },
      { day: "S", value: 1 }
    ]
  },
  Monthly: {
    total: "46h",
    trend: "+15% from last month",
    points: [
      { day: "W1", value: 10 },
      { day: "W2", value: 14 },
      { day: "W3", value: 8 },
      { day: "W4", value: 14 }
    ]
  },
  Yearly: {
    total: "310h",
    trend: "+22% from last year",
    points: [
      { day: "Q1", value: 60 },
      { day: "Q2", value: 90 },
      { day: "Q3", value: 70 },
      { day: "Q4", value: 90 }
    ]
  }
};

const RANGES = Object.keys(RANGE_DATA);

const chartVariants = {
  hidden: { opacity: 0 },
  visible: { opacity: 1, transition: { staggerChildren: 0.08 } }
};

const barVariants = {
  hidden: { scaleY: 0, opacity: 0, transformOrigin: "bottom" as const },
  visible: {
    scaleY: 1,
    opacity: 1,
    transformOrigin: "bottom" as const,
    transition: { duration: 0.45, ease: [0.4, 0, 0.2, 1] as const }
  }
};

export const ActivityChartCard = ({ title = "Learning activity", className }: ActivityChartCardProps) => {
  const [selectedRange, setSelectedRange] = React.useState(RANGES[0]);
  const { total, trend, points } = RANGE_DATA[selectedRange];

  const maxValue = React.useMemo(() => points.reduce((max, p) => (p.value > max ? p.value : max), 0), [points]);

  return (
    <Card className={cn("w-full p-6", className)} aria-labelledby="activity-card-title">
      <div className="mb-5 flex items-center justify-between">
        <h2 id="activity-card-title" className="font-display text-[16px] font-semibold text-ink">
          {title}
        </h2>
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="secondary" size="sm" className="flex items-center gap-1">
              {selectedRange}
              <ChevronDown size={14} />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            {RANGES.map((option) => (
              <DropdownMenuItem key={option} onSelect={() => setSelectedRange(option)}>
                {option}
              </DropdownMenuItem>
            ))}
          </DropdownMenuContent>
        </DropdownMenu>
      </div>

      <div className="flex flex-col items-start gap-5 sm:flex-row sm:items-end">
        <div className="flex shrink-0 flex-col">
          <p className="font-display text-[36px] font-bold tracking-tight text-ink">{total}</p>
          <p className="mt-1 flex items-center gap-1 text-[12.5px] text-ink-soft">
            <TrendingUp size={14} className="text-teal" />
            {trend}
          </p>
        </div>

        <motion.div
          key={selectedRange}
          className="flex h-28 w-full items-end justify-between gap-2"
          variants={chartVariants}
          initial="hidden"
          animate="visible"
          aria-label="Learning activity chart"
        >
          {points.map((item, index) => (
            <div key={index} className="flex h-full w-full flex-col items-center justify-end gap-2" role="presentation">
              <motion.div
                className="w-full rounded-md bg-gold"
                style={{ height: `${maxValue > 0 ? (item.value / maxValue) * 100 : 0}%` }}
                variants={barVariants}
                aria-label={`${item.day}: ${item.value}h`}
              />
              <span className="text-[11px] text-ink-soft">{item.day}</span>
            </div>
          ))}
        </motion.div>
      </div>
    </Card>
  );
};

export default ActivityChartCard;
'@

Set-Content -Path $activityPath -Value $activityContent -Encoding UTF8
Write-Host "Created: $activityPath" -ForegroundColor Green

# =========================================================================
# 3) Patch dashboard/page.tsx
# =========================================================================
$dashboardContent = Get-Content -Path $dashboardFile -Raw

# --- 3a. imports ---------------------------------------------------------
$oldImports = 'import { LearnerOnboardingTour } from "@/components/ui/learner-onboarding-tour";
import { LearnerOnboardingChecklist } from "@/components/ui/learner-onboarding-checklist";'

$newImports = 'import { LearnerOnboardingTour } from "@/components/ui/learner-onboarding-tour";
import { LearnerOnboardingChecklist } from "@/components/ui/learner-onboarding-checklist";
import { ActivityChartCard } from "@/components/ui/activity-chart-card";
import { BentoCard, BentoGrid } from "@/components/ui/bento-grid";
import {
  BookOpen as BentoBookOpen,
  Award as BentoAward,
  Users as BentoUsers,
  Heart as BentoHeart,
  MessageCircle as BentoMessageCircle,
  GraduationCap as BentoGraduationCap
} from "lucide-react";'

if ($dashboardContent -notmatch [regex]::Escape($oldImports)) {
    Write-Host "WARNING: dashboard imports block did not match - skipping import patch." -ForegroundColor Yellow
} else {
    $dashboardContent = $dashboardContent.Replace($oldImports, $newImports)
}

# --- 3b. insert Activity card + Bento grid after KPI row, before Continue learning heading ---
$oldSection = '      <h2 data-onboard="continue-learning" className="mb-4 font-display text-[20px] font-semibold text-ink">Continue learning</h2>'

$newSection = '      <div className="mb-10">
        <ActivityChartCard />
      </div>

      <h2 className="mb-4 font-display text-[20px] font-semibold text-ink">Explore</h2>
      <div className="mb-10">
        <BentoGrid>
          <BentoCard
            name="Continue learning"
            description="Jump back into your enrolled courses."
            Icon={BentoBookOpen}
            href="/my-courses"
            cta="Go to My Courses"
            className="md:col-span-2 md:row-span-2"
          />
          <BentoCard
            name="Certificates"
            description="View and download your earned certificates."
            Icon={BentoAward}
            href="/certificates"
            cta="View certificates"
          />
          <BentoCard
            name="Book mentorship"
            description="1-on-1 sessions with verified instructors."
            Icon={BentoUsers}
            href="/mentorship"
            cta="Find a mentor"
            className="md:row-span-2"
          />
          <BentoCard
            name="Wishlist"
            description="Courses you have saved for later."
            Icon={BentoHeart}
            href="/wishlist"
            cta="View wishlist"
          />
          <BentoCard
            name="Course community"
            description="Ask questions and get answers from instructors."
            Icon={BentoMessageCircle}
            href="/my-courses"
            cta="Browse my courses"
          />
          <BentoCard
            name="Become an instructor"
            description="Apply to teach and sell your own courses."
            Icon={BentoGraduationCap}
            href="/become-instructor"
            cta="Apply now"
          />
        </BentoGrid>
      </div>

      <h2 data-onboard="continue-learning" className="mb-4 font-display text-[20px] font-semibold text-ink">Continue learning</h2>'

if ($dashboardContent -notmatch [regex]::Escape($oldSection)) {
    Write-Host "WARNING: dashboard 'Continue learning' heading did not match - skipping section insert." -ForegroundColor Yellow
    Write-Host "You'll need to manually add <ActivityChartCard /> and the BentoGrid before that heading." -ForegroundColor Yellow
} else {
    $dashboardContent = $dashboardContent.Replace($oldSection, $newSection)
}

Set-Content -Path $dashboardFile -Value $dashboardContent -Encoding UTF8
Write-Host "Patched: $dashboardFile" -ForegroundColor Green

# =========================================================================
# Summary
# =========================================================================
Write-Host ""
Write-Host "Done. Summary:" -ForegroundColor Cyan
Write-Host " - apps\web\components\ui\bento-grid.tsx (new)"
Write-Host " - apps\web\components\ui\activity-chart-card.tsx (new)"
Write-Host " - apps\web\app\(learner)\dashboard\page.tsx (patched)"
Write-Host ""
Write-Host "Depends on: apps\web\components\ui\dropdown-menu.tsx (from the previous user-dropdown step)." -ForegroundColor Yellow
Write-Host "If you haven't run that script yet, run it first or this file's import will fail." -ForegroundColor Yellow
Write-Host ""
Write-Host "No new npm packages needed (framer-motion + lucide-react already in the repo)." -ForegroundColor Cyan
Write-Host "Frontend-only, dummy data - no backend calls added." -ForegroundColor Cyan