"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, useRef, useState, type ReactNode } from "react";
import { toast } from "sonner";
import {
  Menu,
  X,
  LogOut,
  Search,
  ChevronLeft,
  ChevronRight,
  Bell,
  User,
  Settings,
  ChevronDown,
  Command,
  Check
} from "lucide-react";
import { ThemeToggle } from "@saachi/ui";
import { ADMIN_NAV } from "../../lib/nav-config";
import {
  ROLE_LABEL,
  getAllowedRolesForRoute,
  isRouteAllowed,
  getCurrentRole,
  getCurrentName,
  getCurrentEmail,
  setCurrentRole,
  clearAuthCookies,
  type StaffRole
} from "../../lib/permissions";
import { CommandPalette } from "./CommandPalette";
import { AccessDenied } from "./AccessDenied";

function cx(...parts: Array<string | false | undefined>) {
  return parts.filter(Boolean).join(" ");
}

type NotificationItem = {
  id: string;
  label: string;
  tone: "warning" | "error" | "info";
  href: string;
};

const NOTIFICATIONS: NotificationItem[] = [
  { id: "n1", label: "3 courses pending moderation review", tone: "warning", href: "/courses/moderation" },
  { id: "n2", label: "1 refund request awaiting approval", tone: "error", href: "/finance/refunds" },
  { id: "n3", label: "2 support tickets breaching SLA", tone: "error", href: "/support/tickets" },
  { id: "n4", label: "Weekly payout batch ready to process", tone: "info", href: "/finance/payouts" }
];

const TONE_DOT: Record<NotificationItem["tone"], string> = {
  warning: "bg-warning",
  error: "bg-error",
  info: "bg-info"
};

const ROLE_LIST: StaffRole[] = ["super_admin", "admin", "finance_officer", "support_officer"];

export function AdminShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const [mobileOpen, setMobileOpen] = useState(false);
  const [collapsed, setCollapsed] = useState(false);
  const [notifOpen, setNotifOpen] = useState(false);
  const [userMenuOpen, setUserMenuOpen] = useState(false);
  const [currentRole, setCurrentRoleState] = useState<StaffRole>("super_admin");
  const [currentName, setCurrentName] = useState("Abdul Rehman Irfan");
  const [currentEmail, setCurrentEmail] = useState("abdulrehman@saachi.ai");
  const [mounted, setMounted] = useState(false);

  const notifRef = useRef<HTMLDivElement>(null);
  const userMenuRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    setCurrentRoleState(getCurrentRole());
    setCurrentName(getCurrentName());
    setCurrentEmail(getCurrentEmail());
    setMounted(true);
  }, []);

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (notifRef.current && !notifRef.current.contains(e.target as Node)) setNotifOpen(false);
      if (userMenuRef.current && !userMenuRef.current.contains(e.target as Node)) setUserMenuOpen(false);
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const handleLogout = () => {
    clearAuthCookies();
    router.push("/login");
  };

  const handleSwitchRole = (role: StaffRole) => {
    setCurrentRoleState(role);
    setCurrentRole(role);
    setUserMenuOpen(false);
    toast.success(`Switched to ${ROLE_LABEL[role]}`, {
      description: "Your view now reflects this role's permissions."
    });
    if (!isRouteAllowed(pathname ?? "/dashboard", role)) {
      router.push("/dashboard");
    }
  };

  const filteredNav = ADMIN_NAV.map((section) => ({
    ...section,
    items: section.items.filter((item) => getAllowedRolesForRoute(item.href).includes(currentRole))
  })).filter((section) => section.items.length > 0);

  const sidebarContent = (
    <div className="flex h-full flex-col pt-[65px]">
      <nav className="flex flex-1 flex-col gap-5 overflow-y-auto px-3 pb-4 pt-4">
        {filteredNav.map((navSection) => (
          <div key={navSection.title}>
            {!collapsed && (
              <div className="mb-1.5 px-2.5 text-[10px] font-semibold uppercase tracking-[0.08em] text-ink-soft/60">
                {navSection.title}
              </div>
            )}
            <div className="flex flex-col gap-0.5">
              {navSection.items.map((item) => {
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

  const allowed = mounted ? isRouteAllowed(pathname ?? "/dashboard", currentRole) : true;

  return (
    <div className="min-h-screen bg-paper">
      <CommandPalette />

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

          <div className="hidden shrink-0 items-center gap-2 sm:flex">
            <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full border border-ink text-[12px] font-bold text-ink">
              S
            </span>
            <span className="whitespace-nowrap text-[14px] font-semibold text-ink">Saachi Admin</span>
          </div>

          <div className="hidden h-6 w-px shrink-0 bg-line sm:block" />

          <div className="relative min-w-0" ref={userMenuRef}>
            <button
              type="button"
              onClick={() => setUserMenuOpen((v) => !v)}
              className="flex min-w-0 items-center gap-2 rounded-control px-1.5 py-1 transition-colors duration-150 ease-out hover:bg-paper-dim"
            >
              <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full border border-line text-[12px] font-semibold text-ink">
                {currentName.charAt(0)}
              </div>
              <div className="hidden min-w-0 text-left sm:block">
                <div className="truncate text-[12.5px] font-semibold leading-tight text-ink">{currentName}</div>
                <div className="truncate text-[11px] leading-tight text-ink-soft">{ROLE_LABEL[currentRole]}</div>
              </div>
              <ChevronDown size={13} strokeWidth={1.75} className="hidden shrink-0 text-ink-soft sm:block" />
            </button>

            {userMenuOpen && (
              <div className="absolute left-0 top-[calc(100%+8px)] w-[260px] overflow-hidden rounded-card border border-line bg-card shadow-lg">
                <div className="border-b border-line px-4 py-3">
                  <p className="truncate text-[13px] font-semibold text-ink">{currentName}</p>
                  <p className="truncate text-[12px] text-ink-soft">{currentEmail}</p>
                </div>

                <div className="border-b border-line px-4 py-3">
                  <p className="mb-2 text-[10.5px] font-semibold uppercase tracking-[0.06em] text-ink-soft/70">
                    Switch role (testing)
                  </p>
                  <div className="flex flex-col gap-0.5">
                    {ROLE_LIST.map((role) => (
                      <button
                        key={role}
                        type="button"
                        onClick={() => handleSwitchRole(role)}
                        className={cx(
                          "flex items-center justify-between gap-2 rounded-control px-2.5 py-1.5 text-left text-[12.5px] transition-colors duration-100 ease-out",
                          role === currentRole ? "bg-paper-dim text-ink" : "text-ink-soft hover:bg-paper-dim hover:text-ink"
                        )}
                      >
                        {ROLE_LABEL[role]}
                        {role === currentRole && <Check size={13} strokeWidth={2} className="shrink-0 text-ink" />}
                      </button>
                    ))}
                  </div>
                </div>

                <div className="flex flex-col p-1.5">
                  {getAllowedRolesForRoute("/settings/roles").includes(currentRole) && (
                    <Link
                      href="/settings/roles"
                      onClick={() => setUserMenuOpen(false)}
                      className="flex items-center gap-2.5 rounded-control px-3 py-2 text-[13px] text-ink transition-colors duration-100 ease-out hover:bg-paper-dim"
                    >
                      <User size={14} strokeWidth={1.75} /> Profile
                    </Link>
                  )}
                  {getAllowedRolesForRoute("/settings/platform").includes(currentRole) && (
                    <Link
                      href="/settings/platform"
                      onClick={() => setUserMenuOpen(false)}
                      className="flex items-center gap-2.5 rounded-control px-3 py-2 text-[13px] text-ink transition-colors duration-100 ease-out hover:bg-paper-dim"
                    >
                      <Settings size={14} strokeWidth={1.75} /> Settings
                    </Link>
                  )}
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

        <div className="flex items-center gap-2 sm:gap-3">
          <button
            type="button"
            onClick={() => window.dispatchEvent(new KeyboardEvent("keydown", { key: "k", metaKey: true }))}
            className="hidden items-center gap-2 rounded-control border border-line px-3 py-1.5 text-[12px] text-ink-soft transition-colors duration-150 ease-out hover:border-line-strong hover:text-ink sm:flex"
          >
            <Search size={13} strokeWidth={1.75} />
            <span>Search</span>
            <span className="ml-1.5 flex items-center gap-0.5 rounded border border-line-strong px-1 py-0.5 text-[10px]">
              <Command size={9} strokeWidth={2} />K
            </span>
          </button>

          <div className="relative" ref={notifRef}>
            <button
              type="button"
              onClick={() => setNotifOpen((v) => !v)}
              aria-label="Notifications"
              className="relative flex h-9 w-9 items-center justify-center rounded-control text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-ink"
            >
              <Bell size={17} strokeWidth={1.75} />
              {NOTIFICATIONS.length > 0 && (
                <span className="absolute right-1.5 top-1.5 flex h-4 min-w-4 items-center justify-center rounded-full bg-error px-1 text-[9px] font-semibold text-paper">
                  {NOTIFICATIONS.length}
                </span>
              )}
            </button>

            {notifOpen && (
              <div className="absolute right-0 top-[calc(100%+8px)] w-[320px] overflow-hidden rounded-card border border-line bg-card shadow-lg">
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
                      <span className={cx("mt-1 h-1.5 w-1.5 shrink-0 rounded-full", TONE_DOT[n.tone])} />
                      <span>{n.label}</span>
                    </Link>
                  ))}
                </div>
              </div>
            )}
          </div>

          <ThemeToggle />
        </div>
      </div>

      {mobileOpen && (
        <div className="fixed inset-0 z-50 flex md:hidden">
          <div className="absolute inset-0 bg-ink/40 transition-opacity duration-200 ease-out" onClick={() => setMobileOpen(false)} />
          <div className="relative flex h-full w-[280px] flex-col bg-card transition-transform duration-200 ease-out">
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
        {allowed ? children : <AccessDenied role={currentRole} />}
      </div>
    </div>
  );
}