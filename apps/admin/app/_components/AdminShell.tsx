"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState, type ReactNode } from "react";
import { Menu, X, LogOut, Search, ChevronLeft, ChevronRight } from "lucide-react";
import { ThemeToggle } from "@saachi/ui";
import { ADMIN_NAV } from "../lib/nav-config";

function cx(...parts: Array<string | false | undefined>) {
  return parts.filter(Boolean).join(" ");
}

export function AdminShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const [mobileOpen, setMobileOpen] = useState(false);
  const [collapsed, setCollapsed] = useState(false);

  const sidebarContent = (
    <div className="flex h-full flex-col">
      <div className={cx("flex items-center gap-2.5 px-5 py-6", collapsed && "justify-center px-0")}>
        <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full border border-ink text-[13px] font-bold text-ink">
          S
        </span>
        {!collapsed && (
          <div>
            <div className="text-[14px] font-semibold leading-none text-ink">Saachi AI</div>
            <div className="mt-1 text-[10px] font-medium uppercase tracking-[0.08em] text-ink-soft">Admin</div>
          </div>
        )}
      </div>

      <nav className="flex flex-1 flex-col gap-5 overflow-y-auto px-3 pb-4">
        {ADMIN_NAV.map((section) => (
          <div key={section.title}>
            {!collapsed && (
              <div className="mb-1.5 px-2.5 text-[10px] font-semibold uppercase tracking-[0.08em] text-ink-soft/60">
                {section.title}
              </div>
            )}
            <div className="flex flex-col gap-0.5">
              {section.items.map((item) => {
                const active = pathname === item.href || Boolean(pathname?.startsWith(`${item.href}/`));
                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    onClick={() => setMobileOpen(false)}
                    title={collapsed ? item.label : undefined}
                    className={cx(
                      "flex items-center gap-3 rounded-control px-2.5 py-2 text-[13px] font-medium transition-colors duration-150 ease-out",
                      collapsed && "justify-center",
                      active ? "bg-accent text-paper" : "text-ink-soft hover:bg-paper-dim hover:text-ink"
                    )}
                  >
                    <item.icon size={16} strokeWidth={1.75} className="shrink-0" />
                    {!collapsed && <span className="truncate">{item.label}</span>}
                  </Link>
                );
              })}
            </div>
          </div>
        ))}
      </nav>

      <div className="border-t border-line px-3 py-3">
        <button
          type="button"
          onClick={() => setCollapsed((v) => !v)}
          className={cx(
            "mb-1 flex w-full items-center gap-3 rounded-control px-2.5 py-2 text-[13px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-ink",
            collapsed && "justify-center"
          )}
        >
          {collapsed ? <ChevronRight size={16} strokeWidth={1.75} /> : <ChevronLeft size={16} strokeWidth={1.75} />}
          {!collapsed && "Collapse"}
        </button>
        <Link
          href="/login"
          className={cx(
            "flex w-full items-center gap-3 rounded-control px-2.5 py-2 text-[13px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-error",
            collapsed && "justify-center"
          )}
        >
          <LogOut size={16} strokeWidth={1.75} />
          {!collapsed && "Log out"}
        </Link>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-paper">
      <div
        className={cx(
          "hidden shrink-0 border-r border-line bg-card transition-[width] duration-200 ease-out md:fixed md:inset-y-0 md:flex",
          collapsed ? "w-[76px]" : "w-[248px]"
        )}
      >
        {sidebarContent}
      </div>

      <div
        className={cx(
          "sticky top-0 z-40 flex items-center justify-between border-b border-line bg-card/95 px-4 py-3 backdrop-blur-sm transition-[padding] duration-200 ease-out md:px-6",
          collapsed ? "md:pl-[76px]" : "md:pl-[248px]"
        )}
      >
        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={() => setMobileOpen(true)}
            aria-label="Open menu"
            className="flex h-9 w-9 items-center justify-center rounded-control text-ink md:hidden"
          >
            <Menu size={18} strokeWidth={1.75} />
          </button>
          <div className="relative hidden sm:block">
            <Search size={15} strokeWidth={1.75} className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-ink-soft" />
            <input
              placeholder="Search users, courses, tickets..."
              className="h-9 w-[280px] rounded-control border border-line bg-paper pl-9 pr-3 text-[13px] text-ink outline-none placeholder:text-ink-soft/60 focus:border-line-strong"
            />
          </div>
        </div>

        <div className="flex items-center gap-3">
          <ThemeToggle />
          <div className="flex h-9 w-9 items-center justify-center rounded-full border border-line text-[12px] font-semibold text-ink">
            A
          </div>
        </div>
      </div>

      {mobileOpen && (
        <div className="fixed inset-0 z-50 flex md:hidden">
          <div className="absolute inset-0 bg-ink/40" onClick={() => setMobileOpen(false)} />
          <div className="relative flex h-full w-[280px] flex-col bg-card">
            <button
              type="button"
              onClick={() => setMobileOpen(false)}
              aria-label="Close menu"
              className="absolute right-3 top-3 flex h-9 w-9 items-center justify-center rounded-control text-ink"
            >
              <X size={18} strokeWidth={1.75} />
            </button>
            {sidebarContent}
          </div>
        </div>
      )}

      <div className={cx("transition-[padding] duration-200 ease-out", collapsed ? "md:pl-[76px]" : "md:pl-[248px]")}>
        {children}
      </div>
    </div>
  );
}