<#
  expand-onboarding-tour.ps1
  ---------------------------------
  Run this from:
  PS D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2>

      .\expand-onboarding-tour.ps1

  What it does:
    - Backs up learner-onboarding-tour.tsx (adds a .bak copy).
    - Replaces it with an expanded version that:
        * Has a step for every sidebar nav item (Dashboard, My Courses,
          Certificates, Wishlist, Cart, Orders, Notifications, Settings)
          plus the KPI row and Continue Learning section.
        * Steps whose target isn't found (no data-onboard attribute yet)
          show as a centered info card instead of a spotlight highlight,
          so nothing breaks even before you add more data-onboard tags.
        * Adds a "Skip tour" button in both the step-list dialog and the
          spotlight coachmark.
    - Also tags every sidebar nav item in layout.tsx with a data-onboard
      attribute so the new steps can spotlight each one.

  If the target file doesn't exist at the expected path, the script tells
  you and stops without touching anything else.
#>

$ErrorActionPreference = "Stop"

$root = Get-Location
Write-Host "Running from: $root" -ForegroundColor Cyan

function Backup-File($path) {
    if (Test-Path $path) {
        Copy-Item $path "$path.bak" -Force
        Write-Host "  Backed up -> $path.bak" -ForegroundColor DarkGray
    }
}

$tourPath = "apps\web\components\ui\learner-onboarding-tour.tsx"

if (-not (Test-Path $tourPath)) {
    Write-Host "[NOT FOUND] $tourPath does not exist. Aborting - nothing was changed." -ForegroundColor Red
    exit 1
}

Write-Host "`nUpdating onboarding tour: $tourPath" -ForegroundColor White
Backup-File $tourPath

$newContent = @'
"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import * as Dialog from "@radix-ui/react-dialog";
import { X, ChevronLeft, ChevronRight, CheckCircle2, Circle } from "lucide-react";
import { Button, cn } from "@saachi/ui";

const SEEN_KEY = "saachi-learner-tour-seen";

export type TourStep = {
  id: string;
  title: string;
  description?: string;
  /**
   * CSS selector for the element to spotlight. If the element isn't found
   * on the page (e.g. a nav item without a data-onboard tag), the step
   * still renders as a centered info card instead of being skipped.
   */
  targetSelector?: string;
};

const STEPS: TourStep[] = [
  {
    id: "welcome",
    title: "Welcome to Saachi AI",
    description: "Quick tour of your dashboard - takes about a minute. You can skip anytime."
  },
  {
    id: "kpis",
    title: "Track your progress",
    description: "See your enrolled, completed, and unread notification counts at a glance.",
    targetSelector: "[data-onboard='kpi-row']"
  },
  {
    id: "continue",
    title: "Pick up where you left off",
    description: "Courses in progress show up here so you can jump straight back in.",
    targetSelector: "[data-onboard='continue-learning']"
  },
  {
    id: "nav-dashboard",
    title: "Dashboard",
    description: "Your home base - progress overview, continue-learning list, and the onboarding checklist all live here.",
    targetSelector: "[data-onboard='nav-dashboard']"
  },
  {
    id: "nav-my-courses",
    title: "My Courses",
    description: "Every course you're enrolled in, with filters for in-progress, completed, and not-started.",
    targetSelector: "[data-onboard='nav-my-courses']"
  },
  {
    id: "nav-certificates",
    title: "Certificates",
    description: "Download and share certificates for the courses you've completed.",
    targetSelector: "[data-onboard='nav-certificates']"
  },
  {
    id: "nav-wishlist",
    title: "Wishlist",
    description: "Save courses you're interested in and move them to your cart whenever you're ready.",
    targetSelector: "[data-onboard='nav-wishlist']"
  },
  {
    id: "nav-cart",
    title: "Cart",
    description: "Review items you're about to buy, apply coupon codes, and check out.",
    targetSelector: "[data-onboard='nav-cart']"
  },
  {
    id: "nav-orders",
    title: "Orders",
    description: "Your full purchase history, including totals and order status.",
    targetSelector: "[data-onboard='nav-orders']"
  },
  {
    id: "nav-notifications",
    title: "Notifications",
    description: "Course updates, instructor replies, and account alerts all land here.",
    targetSelector: "[data-onboard='nav-notifications']"
  },
  {
    id: "nav-settings",
    title: "Settings",
    description: "Update your profile, billing details, privacy preferences, and account security.",
    targetSelector: "[data-onboard='nav-settings']"
  }
];

function getElementPosition(selector?: string) {
  if (!selector) return null;
  const element = document.querySelector(selector) as HTMLElement | null;
  if (!element) return null;
  const rect = element.getBoundingClientRect();
  return { top: rect.top + window.scrollY, left: rect.left + window.scrollX, width: rect.width, height: rect.height };
}

function StepCard({
  step, stepIndex, totalSteps, isFirst, isLast, onNext, onPrev, onSkip
}: {
  step: TourStep; stepIndex: number; totalSteps: number; isFirst: boolean; isLast: boolean;
  onNext: () => void; onPrev: () => void; onSkip: () => void;
}) {
  return (
    <>
      <p className="mb-1 text-[12px] font-semibold text-ink-soft">Step {stepIndex + 1} of {totalSteps}</p>
      <h3 className="mb-1 text-[15px] font-semibold text-ink">{step.title}</h3>
      {step.description && <p className="mb-4 text-[13px] text-ink-soft">{step.description}</p>}
      <div className="flex items-center justify-between gap-2">
        <button
          type="button"
          onClick={onSkip}
          className="text-[12.5px] font-medium text-ink-soft underline-offset-2 hover:text-ink hover:underline"
        >
          Skip tour
        </button>
        <div className="flex items-center gap-2">
          <Button variant="secondary" size="sm" onClick={onPrev} disabled={isFirst}>
            <ChevronLeft className="mr-1 h-4 w-4" /> Prev
          </Button>
          <Button size="sm" onClick={onNext}>
            {isLast ? "Finish" : "Next"}
            {!isLast && <ChevronRight className="ml-1 h-4 w-4" />}
          </Button>
        </div>
      </div>
    </>
  );
}

function Coachmark({
  step, stepIndex, totalSteps, isFirst, isLast, onNext, onPrev, onSkip
}: {
  step: TourStep; stepIndex: number; totalSteps: number; isFirst: boolean; isLast: boolean;
  onNext: () => void; onPrev: () => void; onSkip: () => void;
}) {
  const [pos, setPos] = useState(getElementPosition(step.targetSelector));

  const update = useCallback(() => setPos(getElementPosition(step.targetSelector)), [step.targetSelector]);

  useEffect(() => {
    update();
    window.addEventListener("resize", update);
    window.addEventListener("scroll", update);
    const target = step.targetSelector ? document.querySelector(step.targetSelector) : null;
    const ro = target ? new ResizeObserver(update) : null;
    if (target && ro) ro.observe(target);
    return () => {
      window.removeEventListener("resize", update);
      window.removeEventListener("scroll", update);
      ro?.disconnect();
    };
  }, [step.targetSelector, update]);

  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if (e.key === "Escape") onSkip();
      else if (e.key === "ArrowRight" && !isLast) onNext();
      else if (e.key === "ArrowLeft" && !isFirst) onPrev();
    }
    document.addEventListener("keydown", onKey);
    return () => document.removeEventListener("keydown", onKey);
  }, [onSkip, onNext, onPrev, isFirst, isLast]);

  // No target found (or step has no target on purpose) -> centered info card, no spotlight.
  if (!pos) {
    return (
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 pointer-events-auto"
      >
        <motion.div
          initial={{ scale: 0.9, opacity: 0, y: 8 }}
          animate={{ scale: 1, opacity: 1, y: 0 }}
          exit={{ scale: 0.9, opacity: 0, y: 8 }}
          transition={{ type: "spring", damping: 25, stiffness: 400 }}
          className="w-80 max-w-[90vw] rounded-card border border-line bg-card p-4 shadow-xl"
        >
          <StepCard
            step={step}
            stepIndex={stepIndex}
            totalSteps={totalSteps}
            isFirst={isFirst}
            isLast={isLast}
            onNext={onNext}
            onPrev={onPrev}
            onSkip={onSkip}
          />
        </motion.div>
      </motion.div>
    );
  }

  const { top, left, width, height } = pos;
  const padding = 8;

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-50 pointer-events-none"
      style={{
        background: `radial-gradient(circle at ${left + width / 2}px ${top + height / 2}px, transparent ${Math.max(width, height) / 2 + padding}px, rgba(0,0,0,0.65) ${Math.max(width, height) / 2 + padding + 1}px)`
      }}
    >
      <div
        className="absolute rounded-control border-2 border-gold shadow-lg"
        style={{ top: top - padding, left: left - padding, width: width + padding * 2, height: height + padding * 2 }}
      />
      <motion.div
        initial={{ scale: 0.9, opacity: 0, y: 8 }}
        animate={{ scale: 1, opacity: 1, y: 0 }}
        exit={{ scale: 0.9, opacity: 0, y: 8 }}
        transition={{ type: "spring", damping: 25, stiffness: 400 }}
        className="absolute w-80 max-w-[90vw] rounded-card border border-line bg-card p-4 shadow-xl pointer-events-auto"
        style={{
          top: Math.min(Math.max(16, top + height + 16), window.innerHeight - 220),
          left: Math.min(Math.max(16, left + width / 2 - 160), window.innerWidth - 336)
        }}
      >
        <StepCard
          step={step}
          stepIndex={stepIndex}
          totalSteps={totalSteps}
          isFirst={isFirst}
          isLast={isLast}
          onNext={onNext}
          onPrev={onPrev}
          onSkip={onSkip}
        />
      </motion.div>
    </motion.div>
  );
}

export function LearnerOnboardingTour() {
  const [hydrated, setHydrated] = useState(false);
  const [open, setOpen] = useState(false);
  const [activeIndex, setActiveIndex] = useState(0);

  useEffect(() => {
    setHydrated(true);
    const justSignedUp = window.localStorage.getItem("saachi-just-signed-up") === "true";
    const seen = window.localStorage.getItem(SEEN_KEY) === "true";

    if (justSignedUp || !seen) {
      const t = setTimeout(() => setOpen(true), 500); // let dashboard finish rendering first
      return () => clearTimeout(t);
    }
  }, []);

  function markSeen() {
    window.localStorage.setItem(SEEN_KEY, "true");
    setOpen(false);
    setActiveIndex(0);
  }

  if (!hydrated) return null;

  const step = STEPS[activeIndex];
  const isFirst = activeIndex === 0;
  const isLast = activeIndex === STEPS.length - 1;

  return (
    <>
      <Dialog.Root open={open} onOpenChange={(v) => { if (!v) markSeen(); }} modal={false}>
        <Dialog.Portal>
          <Dialog.Content
            className="fixed bottom-4 right-4 z-50 w-80 rounded-card border border-line bg-card shadow-xl pointer-events-auto"
            onOpenAutoFocus={(e) => e.preventDefault()}
            onPointerDownOutside={(e) => e.preventDefault()}
            onInteractOutside={(e) => e.preventDefault()}
          >
            <div className="flex items-center justify-between border-b border-line p-4">
              <Dialog.Title className="text-[14px] font-semibold text-ink">Quick tour</Dialog.Title>
              <div className="flex items-center gap-3">
                <button
                  type="button"
                  onClick={markSeen}
                  className="text-[12px] font-medium text-ink-soft underline-offset-2 hover:text-ink hover:underline"
                >
                  Skip
                </button>
                <button
                  type="button"
                  onClick={markSeen}
                  aria-label="Close tour"
                  className="flex h-7 w-7 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim hover:text-ink"
                >
                  <X size={15} />
                </button>
              </div>
            </div>

            <ul className="max-h-72 space-y-1 overflow-y-auto p-3">
              {STEPS.map((s, i) => (
                <li key={s.id}>
                  <button
                    type="button"
                    onClick={() => setActiveIndex(i)}
                    className={cn(
                      "flex w-full items-center gap-2.5 rounded-control px-3 py-2 text-left text-[13px]",
                      i === activeIndex ? "bg-paper-dim text-ink" : "text-ink-soft hover:bg-paper-dim"
                    )}
                  >
                    {i < activeIndex ? (
                      <CheckCircle2 size={16} className="shrink-0 text-teal" />
                    ) : (
                      <Circle size={16} className="shrink-0 text-ink-soft/40" />
                    )}
                    {s.title}
                  </button>
                </li>
              ))}
            </ul>
          </Dialog.Content>
        </Dialog.Portal>
      </Dialog.Root>

      <AnimatePresence>
        {open && step && (
          <Coachmark
            step={step}
            stepIndex={activeIndex}
            totalSteps={STEPS.length}
            isFirst={isFirst}
            isLast={isLast}
            onNext={() => (isLast ? markSeen() : setActiveIndex((i) => i + 1))}
            onPrev={() => setActiveIndex((i) => Math.max(0, i - 1))}
            onSkip={markSeen}
          />
        )}
      </AnimatePresence>
    </>
  );
}

export default LearnerOnboardingTour;
'@

Set-Content -Path $tourPath -Value $newContent -NoNewline
Write-Host "  [OK] Tour rewritten with per-button steps + Skip option" -ForegroundColor Green

# ---------------------------------------------------------------
# Add data-onboard attributes to all sidebar nav items in the
# learner layout, so the new steps can spotlight them too.
# ---------------------------------------------------------------
$layoutPath = "apps\web\app\(learner)\layout.tsx"
Write-Host "`nUpdating sidebar nav with data-onboard tags: $layoutPath" -ForegroundColor White

if (-not (Test-Path $layoutPath)) {
    Write-Host "  [SKIP] File not found: $layoutPath" -ForegroundColor Yellow
}
else {
    $layoutContent = Get-Content -Raw -Path $layoutPath

    $oldOnboardLogic = 'const onboardAttr = item.href === "/my-courses" ? { "data-onboard": "nav-my-courses" } : {};'
    $newOnboardLogic = @'
const ONBOARD_MAP: Record<string, string> = {
              "/dashboard": "nav-dashboard",
              "/my-courses": "nav-my-courses",
              "/certificates": "nav-certificates",
              "/wishlist": "nav-wishlist",
              "/cart": "nav-cart",
              "/orders": "nav-orders",
              "/notifications": "nav-notifications",
              "/settings": "nav-settings"
            };
            const onboardAttr = ONBOARD_MAP[item.href] ? { "data-onboard": ONBOARD_MAP[item.href] } : {};
'@

    if ($layoutContent.Contains($oldOnboardLogic)) {
        Backup-File $layoutPath
        $layoutContent = $layoutContent.Replace($oldOnboardLogic, $newOnboardLogic)
        Set-Content -Path $layoutPath -Value $layoutContent -NoNewline
        Write-Host "  [OK] Added data-onboard tags for all sidebar items" -ForegroundColor Green
    }
    elseif ($layoutContent.Contains("ONBOARD_MAP")) {
        Write-Host "  [ALREADY APPLIED] data-onboard map already present" -ForegroundColor Cyan
    }
    else {
        Write-Host "  [NOT FOUND] Could not locate the onboardAttr line in layout.tsx. Apply manually:" -ForegroundColor Red
        Write-Host "    Replace the single-item ternary for onboardAttr with a lookup map" -ForegroundColor Red
        Write-Host "    covering /dashboard, /my-courses, /certificates, /wishlist, /cart," -ForegroundColor Red
        Write-Host "    /orders, /notifications, /settings." -ForegroundColor Red
    }
}

Write-Host "`nDone." -ForegroundColor White
Write-Host "Backups (.bak) were created next to any file that was changed." -ForegroundColor White
Write-Host "Restart your dev server if it's running, then clear localStorage flags to preview:" -ForegroundColor White
Write-Host '  localStorage.removeItem("saachi-learner-tour-seen"); location.reload();' -ForegroundColor DarkGray