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
