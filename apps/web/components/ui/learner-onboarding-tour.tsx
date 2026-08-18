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
    description:
      "This is your learner dashboard - the home base for everything you do on Saachi AI. In the next few steps we'll walk through where to track progress, manage your courses, and find your certificates, cart, and settings. Takes under a minute, and you can skip anytime."
  },
  {
    id: "kpis",
    title: "Track your progress",
    description:
      "These three numbers are your learning snapshot: how many courses you're enrolled in, how many you've finished, and how many notifications are still unread. Check this first whenever you open the dashboard to see where you stand.",
    targetSelector: "[data-onboard='kpi-row']"
  },
  {
    id: "continue",
    title: "Pick up where you left off",
    description:
      "Any course you've started but not finished shows up here with a live progress bar. Click a card to jump straight back into the next unfinished lesson - no need to hunt through My Courses first.",
    targetSelector: "[data-onboard='continue-learning']"
  },
  {
    id: "nav-dashboard",
    title: "Dashboard",
    description:
      "Your home base. The progress overview, continue-learning list, and the 'Get started' checklist all live here - it's the fastest way to see what needs your attention.",
    targetSelector: "[data-onboard='nav-dashboard']"
  },
  {
    id: "nav-my-courses",
    title: "My Courses",
    description:
      "Every course you're enrolled in lives here, with filters for in progress, completed, and not started. Use this when you want to browse your full library instead of just what's in progress.",
    targetSelector: "[data-onboard='nav-my-courses']"
  },
  {
    id: "nav-certificates",
    title: "Certificates",
    description:
      "Once a course hits 100% completion, its verified certificate is auto-generated here as a downloadable PDF. Each one has a unique verification ID so anyone - an employer, a client - can confirm it's real.",
    targetSelector: "[data-onboard='nav-certificates']"
  },
  {
    id: "nav-wishlist",
    title: "Wishlist",
    description:
      "Not ready to buy yet? Save a course here instead of losing track of it. When you're ready, move it to your cart in one click without searching for it again.",
    targetSelector: "[data-onboard='nav-wishlist']"
  },
  {
    id: "nav-cart",
    title: "Cart",
    description:
      "Everything you're about to purchase collects here. You can apply a coupon code before checkout, review the total, and proceed to payment whenever you're ready.",
    targetSelector: "[data-onboard='nav-cart']"
  },
  {
    id: "nav-orders",
    title: "Orders",
    description:
      "Your complete purchase history - every order, its items, total, status, and date. Useful for tracking a recent payment or revisiting what you've bought in the past.",
    targetSelector: "[data-onboard='nav-orders']"
  },
  {
    id: "nav-notifications",
    title: "Notifications",
    description:
      "Course updates, instructor replies, and account alerts all land here. Unread items are highlighted so you never miss something that needs a response.",
    targetSelector: "[data-onboard='nav-notifications']"
  },
  {
    id: "nav-settings",
    title: "Settings",
    description:
      "Manage your profile, billing details, privacy preferences, and account security - including password changes and two-factor authentication - all in one place.",
    targetSelector: "[data-onboard='nav-settings']"
  },
  {
    id: "wrap-up",
    title: "You're all set",
    description:
      "That's the full tour. The 'Get started' checklist on your dashboard will keep tracking your progress through these same steps - come back to it anytime, or restart this tour from Settings if you need a refresher."
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
      {step.description && <p className="mb-4 text-[13px] leading-relaxed text-ink-soft">{step.description}</p>}
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
