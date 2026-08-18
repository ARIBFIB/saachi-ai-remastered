<#
Apply-Learner-Onboarding.ps1
Run this from: SAI2 root (same level as apps/, packages/, package.json)

What it does:
  1. Backs up apps\web\app\(learner)\dashboard\page.tsx -> page.tsx.bak-<timestamp>
  2. Creates apps\web\components\ui\learner-onboarding-checklist.tsx
  3. Patches dashboard page.tsx to import + render <LearnerOnboardingChecklist />

Usage:
  PS D:\...\SAI2> .\Apply-Learner-Onboarding.ps1
#>

$ErrorActionPreference = "Stop"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

$componentPath = "apps\web\components\ui\learner-onboarding-checklist.tsx"
$dashboardPath = "apps\web\app\(learner)\dashboard\page.tsx"

if (-not (Test-Path $dashboardPath)) {
    Write-Host "ERROR: $dashboardPath not found. Run this from the SAI2 root." -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------------------------
# 1. Backup dashboard page
# ---------------------------------------------------------------------------
$backupPath = "$dashboardPath.bak-$timestamp"
Copy-Item -Path $dashboardPath -Destination $backupPath -Force
Write-Host "Backed up dashboard -> $backupPath" -ForegroundColor Yellow

# ---------------------------------------------------------------------------
# 2. Write the new component
# ---------------------------------------------------------------------------
$componentDir = Split-Path -Path $componentPath -Parent
if (-not (Test-Path $componentDir)) {
    New-Item -ItemType Directory -Path $componentDir -Force | Out-Null
}

$componentContent = @'
"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { ChevronDown, X, CircleCheck, Circle } from "lucide-react";
import { useEnrollmentStore } from "@saachi/store";
import { Button, cn } from "@saachi/ui";

const DISMISS_KEY = "saachi-learner-onboarding-dismissed";

type ChecklistItem = {
  id: string;
  label: string;
  description: string;
  href: string;
  done: boolean;
};

export function LearnerOnboardingChecklist() {
  const enrollments = useEnrollmentStore((s) => s.enrollments);

  const [dismissed, setDismissed] = useState(true); // default true until we check localStorage (avoids flash)
  const [expanded, setExpanded] = useState(true);
  const [hydrated, setHydrated] = useState(false);

  useEffect(() => {
    setHydrated(true);
    const stored = window.localStorage.getItem(DISMISS_KEY);
    setDismissed(stored === "true");
  }, []);

  const hasEnrollment = enrollments.length > 0;
  const hasStartedLesson = enrollments.some((e) => e.progressPercent > 0);
  const hasCompletedCourse = enrollments.some((e) => e.progressPercent === 100);

  const items: ChecklistItem[] = [
    {
      id: "browse",
      label: "Browse the course marketplace",
      description: "Explore 1,280+ AI courses across automation, design, and development.",
      href: "/courses",
      done: true // reaching the dashboard implies they've seen the marketplace flow
    },
    {
      id: "enroll",
      label: "Enroll in your first course",
      description: "Pick a course that matches your goals and get started.",
      href: "/courses",
      done: hasEnrollment
    },
    {
      id: "lesson",
      label: "Start your first lesson",
      description: "Jump into a lesson and begin building real skills.",
      href: "/my-courses",
      done: hasStartedLesson
    },
    {
      id: "profile",
      label: "Complete your profile",
      description: "Add your details so instructors and the community know you.",
      href: "/settings",
      done: false
    },
    {
      id: "certificate",
      label: "Finish a course and earn a certificate",
      description: "Complete a course end-to-end to unlock your first certificate.",
      href: "/certificates",
      done: hasCompletedCourse
    }
  ];

  const completedCount = items.filter((i) => i.done).length;
  const allDone = completedCount === items.length;

  function handleDismiss() {
    window.localStorage.setItem(DISMISS_KEY, "true");
    setDismissed(true);
  }

  if (!hydrated) return null;
  if (dismissed) return null;

  return (
    <div className="mb-10 overflow-hidden rounded-card border border-line bg-card">
      <div className="flex items-center gap-3 px-5 py-4">
        <div className="flex-1">
          <div className="mb-1.5 flex items-center gap-2">
            <h2 className="text-[15px] font-semibold text-ink">Get started on Saachi AI</h2>
            <span className="rounded-full bg-paper-dim px-2 py-0.5 text-[11px] font-semibold text-ink-soft">
              {completedCount} of {items.length} complete
            </span>
          </div>
          <div className="h-1.5 w-full max-w-xs overflow-hidden rounded-full bg-paper-dim">
            <div
              className="h-full rounded-full bg-gold transition-all duration-300 ease-out"
              style={{ width: `${(completedCount / items.length) * 100}%` }}
            />
          </div>
        </div>

        <button
          type="button"
          onClick={() => setExpanded((v) => !v)}
          aria-label={expanded ? "Collapse checklist" : "Expand checklist"}
          className="flex h-8 w-8 shrink-0 items-center justify-center rounded-control text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-ink"
        >
          <ChevronDown
            size={16}
            className="transition-transform duration-200 ease-out"
            style={{ transform: expanded ? "rotate(180deg)" : "rotate(0deg)" }}
          />
        </button>

        {allDone && (
          <button
            type="button"
            onClick={handleDismiss}
            aria-label="Dismiss checklist"
            className="flex h-8 w-8 shrink-0 items-center justify-center rounded-control text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-ink"
          >
            <X size={16} />
          </button>
        )}
      </div>

      {expanded && (
        <div className="border-t border-line px-5 py-2">
          {items.map((item) => (
            <div
              key={item.id}
              className="flex items-center gap-3 border-b border-line py-3 last:border-0"
            >
              <span className={cn("shrink-0", item.done ? "text-teal" : "text-ink-soft/40")}>
                {item.done ? <CircleCheck size={18} /> : <Circle size={18} />}
              </span>
              <div className="min-w-0 flex-1">
                <p
                  className={cn(
                    "text-[13.5px] font-semibold",
                    item.done ? "text-ink-soft line-through" : "text-ink"
                  )}
                >
                  {item.label}
                </p>
                <p className="text-[12px] text-ink-soft">{item.description}</p>
              </div>
              {!item.done && (
                <Link href={item.href} className="shrink-0">
                  <Button size="sm" variant="secondary">
                    Go
                  </Button>
                </Link>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default LearnerOnboardingChecklist;
'@

Set-Content -Path $componentPath -Value $componentContent -Encoding utf8
Write-Host "Created -> $componentPath" -ForegroundColor Green

# ---------------------------------------------------------------------------
# 3. Patch dashboard page.tsx: add import + render the component
# ---------------------------------------------------------------------------
$dashboardContent = Get-Content -Path $dashboardPath -Raw

# Add import after the last existing import line
$importLine = 'import { LearnerOnboardingChecklist } from "@/components/ui/learner-onboarding-checklist";'

if ($dashboardContent -notmatch [regex]::Escape($importLine)) {
    $lastImportPattern = '(import \{ Button, EmptyState, KpiCard \} from "@saachi/ui";)'
    $dashboardContent = [regex]::Replace(
        $dashboardContent,
        $lastImportPattern,
        "`$1`n$importLine",
        1
    )
}

# Render the checklist right after the opening <div> of the returned JSX,
# before the "Welcome back" heading.
$renderAnchor = '<h1 className="mb-1 font-display text-[26px] font-bold text-ink">'
$renderInsert = "      <LearnerOnboardingChecklist />`r`n`r`n      $renderAnchor"

if ($dashboardContent -notmatch [regex]::Escape("<LearnerOnboardingChecklist />")) {
    $idx = $dashboardContent.IndexOf($renderAnchor)
    if ($idx -ge 0) {
        $dashboardContent = $dashboardContent.Remove($idx, $renderAnchor.Length).Insert($idx, $renderInsert)
    } else {
        Write-Host "WARNING: could not find render anchor in dashboard page.tsx - insert <LearnerOnboardingChecklist /> manually." -ForegroundColor Yellow
    }
}

Set-Content -Path $dashboardPath -Value $dashboardContent -Encoding utf8
Write-Host "Patched -> $dashboardPath" -ForegroundColor Green

Write-Host ""
Write-Host "Done. Review the changes, then run:  pnpm --filter web type-check" -ForegroundColor Cyan
Write-Host "If anything looks wrong, restore from: $backupPath" -ForegroundColor Cyan