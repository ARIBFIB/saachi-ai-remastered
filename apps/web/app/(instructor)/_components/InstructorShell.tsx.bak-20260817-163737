"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, useRef, useState, type ReactNode } from "react";
import { Menu, X, LogOut, ChevronLeft, ChevronRight, Bell, ChevronDown, Settings, User } from "lucide-react";
import { AnimatedThemeToggler } from "@/components/ui/animated-theme-toggler";
import { useSession, useLogout } from "@saachi/api-client";
import { INSTRUCTOR_NAV } from "../../../lib/instructor-nav-config";
import { InstructorTwoLevelSidebar } from "./InstructorTwoLevelSidebar";

function cx(...parts: Array<string | false | undefined>) {
  return parts.filter(Boolean).join(" ");
}

type NotificationItem = { id: string; label: string; href: string };

// NOTE: demo-only dummy data. Replace with useInstructorNotifications() once confirmed.
const NOTIFICATIONS: NotificationItem[] = [
  { id: "n1", label: 'New review on "Automate Everything with n8n & AI"', href: "/instructor/reviews" },
  { id: "n2", label: "2 new students enrolled this week", href: "/instructor/students" },
  { id: "n3", label: "Your Silver Boost promotion expires in 4 days", href: "/instructor/promotions" }
];

export function InstructorShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const { data: session } = useSession();
  const logout = useLogout();

  const [mobileOpen, setMobileOpen] = useState(false);
  const [collapsed, setCollapsed] = useState(false);
  const [notifOpen, setNotifOpen] = useState(false);
  const [userMenuOpen, setUserMenuOpen] = useState(false);

  const notifRef = useRef<HTMLDivElement>(null);
  const userMenuRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (notifRef.current && !notifRef.current.contains(e.target as Node)) setNotifOpen(false);
      if (userMenuRef.current && !userMenuRef.current.contains(e.target as Node)) setUserMenuOpen(false);
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  function handleLogout() {
    logout.mutate(undefined, { onSuccess: () => router.push("/login") });
  }

  const sidebarContent = (
    <div className="flex h-full flex-col pt-[65px]">
      <nav className="flex flex-1 flex-col gap-5 overflow-y-auto px-3 pb-4 pt-4">
        {INSTRUCTOR_NAV.map((section) => (
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
                      active ? "bg-gold text-ink" : "text-ink-soft hover:bg-paper-dim hover:text-ink"
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
            "mb-1 hidden w-full items-center gap-3 rounded-control px-2.5 py-2 text-[13px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-ink md:flex",
            collapsed && "justify-center"
          )}
        >
          {collapsed ? <ChevronRight size={16} strokeWidth={1.75} /> : <ChevronLeft size={16} strokeWidth={1.75} />}
          {!collapsed && "Collapse"}
        </button>
        <button
          type="button"
          onClick={handleLogout}
          className={cx(
            "flex w-full items-center gap-3 rounded-control px-2.5 py-2 text-[13px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-error",
            collapsed && "justify-center"
          )}
        >
          <LogOut size={16} strokeWidth={1.75} />
          {!collapsed && "Log out"}
        </button>
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

      <div className="sticky top-0 z-40 flex items-center justify-between gap-3 border-b border-line bg-card/95 px-4 py-3 backdrop-blur-sm md:px-6">
        <div className="flex min-w-0 items-center gap-3">
          <button
            type="button"
            onClick={() => setMobileOpen(true)}
            aria-label="Open menu"
            className="flex h-9 w-9 shrink-0 items-center justify-center rounded-control text-ink md:hidden"
          >
            <Menu size={18} strokeWidth={1.75} />
          </button>

          <Link href="/instructor/dashboard" className="hidden shrink-0 items-center gap-2 sm:flex">
            <span className="font-display text-[16px] font-bold text-ink">
              Saachi<span className="text-gold-dark">AI</span>
            </span>
            <span className="rounded-full bg-paper-dim px-2 py-0.5 text-[10px] font-semibold uppercase tracking-[0.06em] text-ink-soft">
              Instructor
            </span>
          </Link>
        </div>

        <div className="flex items-center gap-2 sm:gap-3">
          <div className="relative" ref={notifRef}>
            <button
              type="button"
              onClick={() => setNotifOpen((v) => !v)}
              aria-label="Notifications"
              className="relative flex h-9 w-9 items-center justify-center rounded-control text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-ink"
            >
              <Bell size={17} strokeWidth={1.75} />
              {NOTIFICATIONS.length > 0 && (
                <span className="absolute right-1.5 top-1.5 flex h-4 min-w-4 items-center justify-center rounded-full bg-gold-dark px-1 text-[9px] font-semibold text-white">
                  {NOTIFICATIONS.length}
                </span>
              )}
            </button>

            {notifOpen && (
              <div className="absolute right-0 top-[calc(100%+8px)] w-[300px] overflow-hidden rounded-card border border-line bg-card shadow-lg">
                <div className="border-b border-line px-4 py-3">
                  <p className="text-[13px] font-semibold text-ink">Notifications</p>
                </div>
                <div className="flex flex-col">
                  {NOTIFICATIONS.map((n) => (
                    <Link
                      key={n.id}
                      href={n.href}
                      onClick={() => setNotifOpen(false)}
                      className="flex items-start gap-2.5 border-b border-line px-4 py-3 text-[12.5px] text-ink transition-colors duration-100 ease-out last:border-0 hover:bg-paper-dim"
                    >
                      <span className="mt-1 h-1.5 w-1.5 shrink-0 rounded-full bg-gold-dark" />
                      <span>{n.label}</span>
                    </Link>
                  ))}
                </div>
              </div>
            )}
          </div>

          <AnimatedThemeToggler />

          <div className="relative" ref={userMenuRef}>
            <button
              type="button"
              onClick={() => setUserMenuOpen((v) => !v)}
              className="flex min-w-0 items-center gap-2 rounded-control px-1.5 py-1 transition-colors duration-150 ease-out hover:bg-paper-dim"
            >
              <div className="flex h-8 w-8 shrink-0 items-center justify-center overflow-hidden rounded-full border border-line bg-gold-tint text-[12px] font-semibold text-gold-dark">
                {session?.avatarUrl ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={session.avatarUrl} alt={session.fullName} className="h-full w-full object-cover" />
                ) : (
                  (session?.fullName ?? "I").charAt(0)
                )}
              </div>
              <div className="hidden min-w-0 text-left sm:block">
                <div className="truncate text-[12.5px] font-semibold leading-tight text-ink">
                  {session?.fullName ?? "Instructor"}
                </div>
                <div className="truncate text-[11px] leading-tight text-ink-soft">Instructor</div>
              </div>
              <ChevronDown size={13} strokeWidth={1.75} className="hidden shrink-0 text-ink-soft sm:block" />
            </button>

            {userMenuOpen && (
              <div className="absolute right-0 top-[calc(100%+8px)] w-[220px] overflow-hidden rounded-card border border-line bg-card shadow-lg">
                <div className="border-b border-line px-4 py-3">
                  <p className="truncate text-[13px] font-semibold text-ink">{session?.fullName ?? "Instructor"}</p>
                  <p className="truncate text-[12px] text-ink-soft">{session?.email}</p>
                </div>
                <div className="flex flex-col p-1.5">
                  <Link
                    href="/instructor/settings"
                    onClick={() => setUserMenuOpen(false)}
                    className="flex items-center gap-2.5 rounded-control px-3 py-2 text-[13px] text-ink transition-colors duration-100 ease-out hover:bg-paper-dim"
                  >
                    <Settings size={14} strokeWidth={1.75} /> Settings
                  </Link>
                  <Link
                    href="/dashboard"
                    onClick={() => setUserMenuOpen(false)}
                    className="flex items-center gap-2.5 rounded-control px-3 py-2 text-[13px] text-ink transition-colors duration-100 ease-out hover:bg-paper-dim"
                  >
                    <User size={14} strokeWidth={1.75} /> Switch to learner view
                  </Link>
                  <button
                    type="button"
                    onClick={handleLogout}
                    className="flex items-center gap-2.5 rounded-control px-3 py-2 text-left text-[13px] text-error transition-colors duration-100 ease-out hover:bg-error-tint"
                  >
                    <LogOut size={14} strokeWidth={1.75} /> Log out
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {mobileOpen && (
        <div className="fixed inset-0 z-50 flex md:hidden">
          <div
            className="absolute inset-0 bg-ink/40 transition-opacity duration-200 ease-out"
            onClick={() => setMobileOpen(false)}
          />
          <div className="relative flex h-full w-[280px] flex-col bg-card transition-transform duration-200 ease-out">
            <button
              type="button"
              onClick={() => setMobileOpen(false)}
              aria-label="Close menu"
              className="absolute right-3 top-3 flex h-9 w-9 items-center justify-center rounded-control text-ink"
            >
              <X size={18} strokeWidth={1.75} />
            </button>
            <InstructorTwoLevelSidebar onNavigate={() => setMobileOpen(false)} />
          </div>
        </div>
      )}

      <div className="transition-[padding] duration-200 ease-out md:pl-16">
        <main className="mx-auto max-w-[1200px] px-4 py-8 md:px-8 md:py-10">{children}</main>
      </div>
    </div>
  );
}
