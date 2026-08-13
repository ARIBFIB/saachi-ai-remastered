"use client";

// ============================================================================
// DashboardSidebar.tsx
// Shared learner-portal sidebar. Reads nav items from
// lib/dashboard-nav-config.ts so every dashboard page renders the SAME
// links in the SAME order. Replaces the per-page inline <aside> blocks.
//
// Migration: in each dashboard page, remove the local navItems array and
// the inline <aside>...</aside> JSX, then render <DashboardSidebar /> in
// its place (or better, move it once into
// app/(learner)/dashboard/layout.tsx so it is not repeated at all).
// ============================================================================
import Link from "next/link";
import { usePathname } from "next/navigation";
import { HelpCircle } from "lucide-react";
import { dashboardNavItems } from "@/lib/dashboard-nav-config";

export function DashboardSidebar() {
  const pathname = usePathname();

  return (
    <aside className="fixed inset-y-0 left-0 hidden w-72 flex-col justify-between border-r border-[var(--token-color-border)] bg-[var(--token-color-surfaceAlt)] lg:flex">
      <div className="flex flex-col">
        <div className="flex flex-col gap-1.5 border-b border-[var(--token-color-border)] p-6">
          <span className="text-2xl font-bold" style={{ color: "var(--token-color-ink)" }}>
            Learner Portal
          </span>
          <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-xs)" }}>
            Manage your skills
          </span>
        </div>

        <nav className="flex flex-1 flex-col gap-1 py-4">
          {dashboardNavItems.map(({ icon: Icon, label, href }) => {
            const isActive = pathname === href;
            return (
              <Link
                key={href}
                href={href}
                className="flex h-12 items-center gap-4 border-l-4 pl-4 pr-6 text-sm font-semibold tracking-wide transition"
                style={{
                  borderColor: isActive ? "var(--token-color-primary)" : "transparent",
                  backgroundColor: isActive ? "var(--token-color-primaryTint)" : "transparent",
                  color: isActive ? "var(--token-color-primary)" : "var(--token-color-inkSoft)",
                }}
              >
                <Icon size={18} />
                {label}
              </Link>
            );
          })}
        </nav>
      </div>

      <div className="border-t border-[var(--token-color-border)] p-4">
        <Link
          href="/support"
          className="flex h-12 items-center gap-4 rounded-lg pl-4 text-sm font-semibold tracking-wide text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-surface)]"
        >
          <HelpCircle size={18} />
          Help Center
        </Link>
      </div>
    </aside>
  );
}
