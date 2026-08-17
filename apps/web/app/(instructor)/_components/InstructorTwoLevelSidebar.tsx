"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import { ChevronLeft, ChevronRight, ChevronDown } from "lucide-react";
import { INSTRUCTOR_NAV } from "../../../lib/instructor-nav-config";

const softSpring = "cubic-bezier(0.25, 1.1, 0.4, 1)";

function cx(...parts: Array<string | false | undefined>) {
  return parts.filter(Boolean).join(" ");
}

export function InstructorTwoLevelSidebar({ onNavigate }: { onNavigate?: () => void }) {
  const pathname = usePathname();

  const [activeSectionIndex, setActiveSectionIndex] = useState(() => {
    const idx = INSTRUCTOR_NAV.findIndex((section) =>
      section.items.some(
        (item) => pathname === item.href || Boolean(pathname?.startsWith(`${item.href}/`))
      )
    );
    return idx >= 0 ? idx : 0;
  });
  const [collapsed, setCollapsed] = useState(false);

  const activeSection = INSTRUCTOR_NAV[activeSectionIndex];

  return (
    <div className="flex h-full">
      {/* Icon rail */}
      <div className="flex w-16 shrink-0 flex-col items-center gap-2 border-r border-line bg-card py-4">
        {INSTRUCTOR_NAV.map((section, index) => {
          const FirstIcon = section.items[0]?.icon;
          const isActiveSection = index === activeSectionIndex;
          return (
            <button
              key={section.title}
              type="button"
              title={section.title}
              onClick={() => setActiveSectionIndex(index)}
              className={cx(
                "flex h-10 w-10 shrink-0 items-center justify-center rounded-control transition-colors duration-200 ease-out",
                isActiveSection
                  ? "bg-gold text-ink"
                  : "text-ink-soft hover:bg-paper-dim hover:text-ink"
              )}
              style={{ transitionTimingFunction: softSpring }}
            >
              {FirstIcon && <FirstIcon size={17} strokeWidth={1.75} />}
            </button>
          );
        })}
      </div>

      {/* Detail panel */}
      <div
        className={cx(
          "flex flex-col overflow-hidden border-r border-line bg-card transition-[width] duration-300 ease-out",
          collapsed ? "w-0 border-r-0" : "w-56"
        )}
        style={{ transitionTimingFunction: softSpring }}
      >
        <div className="flex items-center justify-between px-4 pt-5 pb-3">
          <span className="truncate text-[13px] font-semibold uppercase tracking-[0.06em] text-ink-soft/70">
            {activeSection?.title}
          </span>
        </div>

        <nav className="flex flex-1 flex-col gap-0.5 overflow-y-auto px-2 pb-4">
          {activeSection?.items.map((item) => {
            const active = pathname === item.href || Boolean(pathname?.startsWith(`${item.href}/`));
            return (
              <Link
                key={item.href}
                href={item.href}
                onClick={onNavigate}
                className={cx(
                  "flex items-center gap-3 rounded-control px-2.5 py-2 text-[13px] font-medium transition-colors duration-150 ease-out",
                  active ? "bg-gold text-ink" : "text-ink-soft hover:bg-paper-dim hover:text-ink"
                )}
              >
                <item.icon size={16} strokeWidth={1.75} className="shrink-0" />
                <span className="truncate">{item.label}</span>
              </Link>
            );
          })}
        </nav>

        <div className="border-t border-line px-2 py-3">
          <button
            type="button"
            onClick={() => setCollapsed(true)}
            className="flex w-full items-center gap-3 rounded-control px-2.5 py-2 text-[13px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-ink"
          >
            <ChevronLeft size={16} strokeWidth={1.75} />
            Collapse
          </button>
        </div>
      </div>

      {collapsed && (
        <div className="flex w-10 shrink-0 flex-col items-center border-r border-line bg-card py-4">
          <button
            type="button"
            onClick={() => setCollapsed(false)}
            aria-label="Expand sidebar"
            className="flex h-9 w-9 items-center justify-center rounded-control text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-ink"
          >
            <ChevronRight size={16} strokeWidth={1.75} />
          </button>
        </div>
      )}
    </div>
  );
}

export default InstructorTwoLevelSidebar;