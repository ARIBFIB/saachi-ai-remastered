"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import * as Dialog from "@radix-ui/react-dialog";
import { X, Check, ChevronLeft, ChevronRight, CheckCircle2, Circle } from "lucide-react";
import { Button, cn } from "@saachi/ui";

const SEEN_KEY = "saachi-learner-tour-seen";

export type TourStep = {
  id: string;
  title: string;
  description?: string;
  targetSelector: string;
};

const STEPS: TourStep[] = [
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
    id: "nav",
    title: "Explore your courses",
    description: "Certificates, wishlist, orders, and settings are all in the sidebar.",
    targetSelector: "[data-onboard='nav-my-courses']"
  }
];

function getElementPosition(selector: string) {
  const element = document.querySelector(selector) as HTMLElement | null;
  if (!element) return null;
  const rect = element.getBoundingClientRect();
  return { top: rect.top + window.scrollY, left: rect.left + window.scrollX, width: rect.width, height: rect.height };
}

function Coachmark({
  step, stepIndex, totalSteps, isFirst, isLast, onNext, onPrev, onClose
}: {
  step: TourStep; stepIndex: number; totalSteps: number; isFirst: boolean; isLast: boolean;
  onNext: () => void; onPrev: () => void; onClose: () => void;
}) {
  const [pos, setPos] = useState(getElementPosition(step.targetSelector));

  const update = useCallback(() => setPos(getElementPosition(step.targetSelector)), [step.targetSelector]);

  useEffect(() => {
    update();
    window.addEventListener("resize", update);
    window.addEventListener("scroll", update);
    const target = document.querySelector(step.targetSelector);
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
      if (e.key === "Escape") onClose();
      else if (e.key === "ArrowRight" && !isLast) onNext();
      else if (e.key === "ArrowLeft" && !isFirst) onPrev();
    }
    document.addEventListener("keydown", onKey);
    return () => document.removeEventListener("keydown", onKey);
  }, [onClose, onNext, onPrev, isFirst, isLast]);

  if (!pos) return null;
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
          top: Math.min(Math.max(16, top + height + 16), window.innerHeight - 200),
          left: Math.min(Math.max(16, left + width / 2 - 160), window.innerWidth - 336)
        }}
      >
        <p className="mb-1 text-[12px] font-semibold text-ink-soft">Step {stepIndex + 1} of {totalSteps}</p>
        <h3 className="mb-1 text-[15px] font-semibold text-ink">{step.title}</h3>
        {step.description && <p className="mb-4 text-[13px] text-ink-soft">{step.description}</p>}
        <div className="flex items-center justify-between gap-2">
          <Button variant="secondary" size="sm" onClick={onPrev} disabled={isFirst}>
            <ChevronLeft className="mr-1 h-4 w-4" /> Prev
          </Button>
          <Button size="sm" onClick={onNext}>
            {isLast ? "Finish" : "Next"}
            {!isLast && <ChevronRight className="ml-1 h-4 w-4" />}
          </Button>
        </div>
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
              <button
                type="button"
                onClick={markSeen}
                aria-label="Close tour"
                className="flex h-7 w-7 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim hover:text-ink"
              >
                <X size={15} />
              </button>
            </div>

            <ul className="space-y-1 p-3">
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
            onClose={markSeen}
          />
        )}
      </AnimatePresence>
    </>
  );
}

export default LearnerOnboardingTour;
