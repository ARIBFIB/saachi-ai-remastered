"use client";

import React, { useState, useMemo } from "react";
import { motion, AnimatePresence, LayoutGroup } from "motion/react";
import { HugeiconsIcon } from "@hugeicons/react";
import {
  DashboardSquare01Icon,
  BookOpen01Icon,
  UserGroupIcon,
  StarIcon,
  Add01Icon,
  CircleArrowUpRight02Icon,
  Search01Icon,
  BarChartIcon,
  Tick01Icon,
  Settings02Icon,
  InformationCircleIcon,
  Wallet01Icon,
  UserIcon,
} from "@hugeicons/core-free-icons";
import { cn } from "@/lib/utils";

interface TabConfig {
  id: string;
  label: string;
  icon: any;
  badge?: string;
  header: string;
  description: string;
}

const TABS: TabConfig[] = [
  {
    id: "overview",
    label: "Overview",
    icon: DashboardSquare01Icon,
    header: "Course Performance",
    description: "Daily summary across all your courses.",
  },
  {
    id: "courses",
    label: "Courses",
    icon: BookOpen01Icon,
    header: "My Courses",
    description: "Track status and enrollment per course.",
    badge: "4",
  },
  {
    id: "students",
    label: "Students",
    icon: UserGroupIcon,
    header: "Student Activity",
    description: "Recent learners across your courses.",
    badge: "654",
  },
  {
    id: "reviews",
    label: "Reviews",
    icon: StarIcon,
    header: "Recent Reviews",
    description: "What learners are saying right now.",
    badge: "3",
  },
];

export function InstructorBentoCard() {
  const [activeTab, setActiveTab] = useState(TABS[0]);

  const content = useMemo(() => {
    switch (activeTab.id) {
      case "overview":
        return <OverviewPanel />;
      case "courses":
        return <CoursesPanel />;
      case "students":
        return <StudentsPanel />;
      case "reviews":
        return <ReviewsPanel />;
      default:
        return null;
    }
  }, [activeTab.id]);

  return (
    <div className="flex items-center justify-center w-full antialiased">
      <div className="group relative w-full max-w-xl overflow-hidden rounded-3xl sm:rounded-4xl border border-line bg-card shadow-2xl shadow-accent-violet/5 transition-all duration-500 hover:shadow-accent-violet/10 hover:-translate-y-1 m-0">
        <div className="p-4 sm:p-6 space-y-1.5 z-10 relative">
          <h2 className="text-xs text-ink-soft uppercase">
            Instructor Dashboard
          </h2>
          <p className="text-lg sm:text-2xl text-ink font-display font-medium leading-snug max-w-[480px]">
            Course performance and student activity in one place.
          </p>
        </div>

        <div className="relative w-full h-[260px] sm:h-[300px] overflow-hidden rounded-2xl sm:rounded-[2rem]">
          <div className="absolute top-16 left-16 w-full h-full bg-paper-dim rounded-3xl border border-line/50 opacity-80" />

          <div className="absolute top-8 left-24 w-full h-full bg-card rounded-tl-3xl shadow-xl flex flex-col overflow-hidden ring-6 ring-line">
            <div className="px-5 py-4 rounded-tl-3xl border-b border-line/70 flex items-center relative backdrop-blur-sm">
              <div className="flex gap-1.5">
                <div className="w-2 h-2 rounded-full bg-ink-soft/20" />
                <div className="w-2 h-2 rounded-full bg-ink-soft/20" />
                <div className="w-2 h-2 rounded-full bg-ink-soft/20" />
              </div>
              <div className="absolute left-1/2 -translate-x-1/2 flex items-center gap-2">
                <span className="text-xs text-ink-soft/50 uppercase">
                  Saachi AI Instructor
                </span>
              </div>
            </div>

            <div className="flex flex-1 overflow-hidden">
              <div className="w-36 border-r border-line/30 p-2 flex flex-col gap-1 pt-6 bg-paper-dim/20">
                <LayoutGroup>
                  {TABS.map((tab) => {
                    const isActive = activeTab.id === tab.id;
                    const Icon = tab.icon;

                    return (
                      <button
                        key={tab.id}
                        type="button"
                        onClick={() => setActiveTab(tab)}
                        className={cn(
                          "relative flex items-center gap-1.5 p-2 rounded-xl text-xs transition-colors cursor-pointer",
                          isActive
                            ? "text-ink"
                            : "text-ink-soft hover:text-ink",
                        )}
                      >
                        <HugeiconsIcon
                          icon={Icon}
                          size={14}
                          className="z-20 shrink-0 relative"
                        />
                        <span className="truncate z-20 relative font-medium">
                          {tab.label}
                        </span>
                        {tab.badge && (
                          <span
                            className={cn(
                              "ml-auto text-[8px] leading-none py-0.5 px-1 rounded-md tabular-nums transition-all z-20 relative",
                              isActive
                                ? "bg-accent-violet/10 text-accent-violet border border-accent-violet/20"
                                : "bg-paper-dim text-ink-soft border border-transparent",
                            )}
                          >
                            {tab.badge}
                          </span>
                        )}

                        {isActive && (
                          <motion.div
                            layoutId="instructor-sidebar-pill"
                            className="absolute left-0 w-[2px] h-4 rounded-full bg-accent-violet z-30 border border-accent-violet/20"
                            transition={{ type: "spring", bounce: 0.2, duration: 0.6 }}
                          />
                        )}
                        {isActive && (
                          <motion.div
                            layoutId="instructor-background-indicator"
                            className="absolute inset-0 rounded-lg bg-paper-dim border border-line/40"
                            transition={{ type: "spring", bounce: 0.2, duration: 0.6 }}
                          />
                        )}
                      </button>
                    );
                  })}
                </LayoutGroup>
              </div>

              <div className="flex-1 bg-card p-5 pt-6 flex flex-col gap-4 overflow-hidden relative">
                <header className="flex flex-col gap-0.5">
                  <h3 className="text-xs font-semibold text-ink tracking-tight line-clamp-1 uppercase opacity-60">
                    {activeTab.header}
                  </h3>
                  <p className="text-[10px] text-ink-soft font-normal leading-tight line-clamp-1">
                    {activeTab.description}
                  </p>
                </header>

                <AnimatePresence mode="popLayout" initial={false}>
                  <motion.div
                    key={activeTab.id}
                    initial={{ opacity: 0, y: 8, filter: "blur(4px)" }}
                    animate={{ opacity: 1, y: 0, filter: "blur(0px)" }}
                    exit={{ opacity: 0, y: -8, filter: "blur(4px)" }}
                    transition={{ duration: 0.3, ease: [0.23, 1, 0.32, 1] }}
                    className="flex-1"
                  >
                    {content}
                  </motion.div>
                </AnimatePresence>

                <div className="absolute bottom-0 left-0 right-0 h-10 bg-linear-to-t from-card to-transparent pointer-events-none z-20" />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default InstructorBentoCard;

const OverviewPanel = () => (
  <div className="flex flex-col gap-3 h-full">
    <div className="relative p-3.5 rounded-xl border border-line/40 bg-linear-to-br from-card to-paper-dim/20 overflow-hidden">
      <div className="flex flex-col gap-2 relative z-10">
        <div className="flex items-center justify-between">
          <span className="text-[9px] font-medium text-ink-soft">
            Completion Rate
          </span>
          <HugeiconsIcon
            icon={CircleArrowUpRight02Icon}
            size={12}
            className="text-accent-violet"
          />
        </div>
        <div className="flex flex-col gap-0.5">
          <span className="text-xl font-medium tracking-tight text-ink">
            58%
          </span>
          <div className="w-full h-1 bg-paper-dim rounded-full overflow-hidden mt-1">
            <motion.div
              initial={{ width: 0 }}
              animate={{ width: "58%" }}
              className="h-full bg-accent-violet rounded-full"
            />
          </div>
        </div>
        <span className="text-[9px] text-ink-soft">
          Across all published courses
        </span>
      </div>
      <div className="absolute -right-2 -bottom-2 opacity-5 scale-150 rotate-12">
        <HugeiconsIcon icon={BarChartIcon} size={64} />
      </div>
    </div>

    <div className="grid grid-cols-2 gap-2">
      <div className="p-3 rounded-xl border border-line/40 bg-card/50 flex items-center justify-between">
        <div className="flex flex-col">
          <span className="text-[10px] font-medium text-ink">654</span>
          <span className="text-[8px] text-ink-soft uppercase font-medium">
            Enrollments
          </span>
        </div>
        <HugeiconsIcon icon={UserIcon} size={14} className="opacity-20" />
      </div>
      <div className="p-3 rounded-xl border border-line/40 bg-card/50 flex items-center justify-between">
        <div className="flex flex-col">
          <span className="text-[10px] font-medium text-ink">$8,420</span>
          <span className="text-[8px] text-ink-soft uppercase font-medium">
            Lifetime earnings
          </span>
        </div>
        <HugeiconsIcon icon={Wallet01Icon} size={14} className="opacity-20" />
      </div>
    </div>
  </div>
);

const CoursesPanel = () => (
  <div className="flex flex-col h-full not-prose">
    <div className="rounded-xl border border-line/40 overflow-hidden flex flex-col h-full bg-card/50">
      <div className="bg-paper-dim/30 px-3 py-2 border-b border-line/40 flex items-center justify-between">
        <span className="text-[9px] font-semibold text-ink-soft uppercase tracking-wider">
          My Courses
        </span>
        <div className="flex items-center gap-1.5 px-1.5 py-0.5 rounded-md bg-card border border-line/40">
          <HugeiconsIcon icon={Search01Icon} size={10} className="text-ink-soft/50" />
          <span className="text-[8px] text-ink-soft font-medium">Search</span>
        </div>
      </div>
      <div className="p-1 flex flex-col gap-0.5">
        {[
          { name: "Automate Everything with n8n & AI", status: "Published", color: "bg-emerald-400" },
          { name: "AI Chatbots for WhatsApp Support", status: "Pending review", color: "bg-amber-400" },
          { name: "Prompt Engineering for Client Work", status: "Draft", color: "bg-slate-400" },
        ].map((course, i) => (
          <div
            key={i}
            className="flex items-center gap-3 p-2 rounded-lg hover:bg-paper-dim/30 transition-colors group"
          >
            <div className="w-6 h-6 rounded-full bg-paper-dim border border-line/40 flex items-center justify-center relative">
              <HugeiconsIcon icon={BookOpen01Icon} size={10} className="text-ink-soft" />
              <div className={cn("absolute -bottom-0.5 -right-0.5 w-2 h-2 rounded-full border border-card", course.color)} />
            </div>
            <div className="flex flex-col min-w-0 flex-1">
              <span className="text-[10px] font-medium text-ink truncate">{course.name}</span>
              <span className="text-[8px] text-ink-soft truncate">{course.status}</span>
            </div>
            <div className="opacity-0 group-hover:opacity-100 transition-opacity">
              <HugeiconsIcon icon={Settings02Icon} size={12} className="text-ink-soft" />
            </div>
          </div>
        ))}
      </div>
    </div>
  </div>
);

const StudentsPanel = () => (
  <div className="flex flex-col gap-3 h-full">
    <div className="grid grid-cols-2 gap-3">
      {[
        { title: "Message students", desc: "Reach out in bulk.", icon: UserGroupIcon },
        { title: "View progress", desc: "Track completions.", icon: Tick01Icon },
      ].map((card, i) => (
        <div
          key={i}
          className="p-3.5 rounded-xl border border-line/40 bg-card/50 flex flex-col gap-3 relative overflow-hidden group"
        >
          <div className="flex flex-col gap-1 z-10">
            <span className="text-[12px] font-medium text-ink leading-tight">{card.title}</span>
            <span className="text-[9px] text-ink-soft leading-tight">{card.desc}</span>
          </div>
          <button
            type="button"
            className="w-fit flex items-center gap-1.5 px-2 py-1 rounded-md bg-ink text-paper text-[8px] font-semibold transition-transform active:scale-95 group-hover:bg-accent-violet z-10"
          >
            <HugeiconsIcon icon={Add01Icon} size={8} strokeWidth={3} />
            Open
          </button>
        </div>
      ))}
    </div>

    <div className="mt-auto p-3 rounded-xl bg-paper-dim/20 border border-line/30 flex items-center justify-between">
      <div className="flex items-center gap-2">
        <div className="p-1 px-1.5 rounded-md bg-card border border-line/40">
          <HugeiconsIcon icon={InformationCircleIcon} size={10} className="text-ink-soft" />
        </div>
        <span className="text-[9px] text-ink-soft font-medium">2 new students this week</span>
      </div>
      <HugeiconsIcon icon={CircleArrowUpRight02Icon} size={12} className="text-ink-soft/50" />
    </div>
  </div>
);

const ReviewsPanel = () => (
  <div className="flex flex-col gap-3 h-full overflow-hidden">
    <div className="flex-1 rounded-xl border border-line/40 flex flex-col bg-card/50 overflow-hidden">
      <div className="bg-paper-dim/30 px-3 py-2 border-b border-line/40 flex items-center justify-between">
        <span className="text-[9px] font-semibold text-ink-soft uppercase tracking-wider">
          Recent Reviews
        </span>
        <HugeiconsIcon icon={StarIcon} size={12} className="text-ink-soft/30" />
      </div>
      <div className="flex-1 p-1 overflow-y-auto scrollbar-hide">
        {[
          { author: "Bilal S.", course: "n8n & AI", rating: "5.0" },
          { author: "Fatima R.", course: "WhatsApp Support", rating: "4.0" },
          { author: "Omar Sheikh", course: "n8n & AI", rating: "5.0" },
        ].map((review, i) => (
          <div
            key={i}
            className="flex items-center gap-2.5 p-2 rounded-lg hover:bg-paper-dim/30 transition-colors cursor-pointer group"
          >
            <div className="w-6 h-6 rounded-md bg-paper-dim/50 border border-line/40 flex items-center justify-center text-ink-soft/60 group-hover:text-accent-violet group-hover:bg-accent-violet/5 transition-colors">
              <HugeiconsIcon icon={StarIcon} size={12} />
            </div>
            <div className="flex flex-col min-w-0 flex-1">
              <span className="text-[10px] font-medium text-ink truncate">{review.author}</span>
              <span className="text-[8px] text-ink-soft uppercase truncate">{review.course}</span>
            </div>
            <span className="text-[9px] font-mono text-ink-soft">{review.rating}</span>
          </div>
        ))}
      </div>
    </div>
  </div>
);