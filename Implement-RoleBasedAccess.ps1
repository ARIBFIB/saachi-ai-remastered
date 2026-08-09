# ============================================================
# Implement-RoleBasedAccess.ps1
# 1) Creates lib/permissions.ts - dummy credentials + route permission matrix
# 2) Rewrites login page - real credential validation, sets role cookie
# 3) Rewrites AdminShell - filters sidebar by role, blocks unauthorized pages
# 4) Creates AccessDenied component
# ============================================================

param(
    [string]$ProjectRoot = (Get-Location).Path
)

$adminRoot = Join-Path $ProjectRoot "apps\admin"
$libDir = Join-Path $adminRoot "lib"
$componentsDir = Join-Path $adminRoot "app\_components"

if (-not (Test-Path $libDir)) { New-Item -ItemType Directory -Path $libDir -Force | Out-Null }

function Backup-IfExists {
    param([string]$Path)
    if (Test-Path $Path) {
        Copy-Item $Path "$Path.bak-roleaccess" -Force
        Write-Host "[BACKUP] $Path" -ForegroundColor Yellow
    }
}

# ------------------------------------------------------------
# 1) lib/permissions.ts
# ------------------------------------------------------------
$permissionsPath = Join-Path $libDir "permissions.ts"
Backup-IfExists $permissionsPath

$permissionsContent = @'
export type StaffRole = "super_admin" | "admin" | "finance_officer" | "support_officer";

export type StaffUser = {
  email: string;
  password: string;
  role: StaffRole;
  name: string;
};

export const ROLE_LABEL: Record<StaffRole, string> = {
  super_admin: "Super Admin",
  admin: "Admin",
  finance_officer: "Finance Officer",
  support_officer: "Support Officer"
};

// Dummy staff directory - no backend yet, credentials are hardcoded for demo/testing.
export const STAFF_USERS: StaffUser[] = [
  { email: "superadmin@saachi.ai", password: "super123", role: "super_admin", name: "Abdul Rehman Irfan" },
  { email: "admin@saachi.ai", password: "admin123", role: "admin", name: "Admin User" },
  { email: "finance@saachi.ai", password: "finance123", role: "finance_officer", name: "Finance Desk" },
  { email: "support@saachi.ai", password: "support123", role: "support_officer", name: "Support Desk" }
];

export function findStaffUser(email: string, password: string): StaffUser | null {
  const match = STAFF_USERS.find(
    (u) => u.email.toLowerCase() === email.trim().toLowerCase() && u.password === password
  );
  return match ?? null;
}

// Route prefix -> roles allowed to access it. Checked in order, first match wins.
// Any route not listed here is allowed for all roles (e.g. /dashboard).
const ROUTE_PERMISSIONS: { prefix: string; roles: StaffRole[] }[] = [
  // Settings - Super Admin only
  { prefix: "/settings/roles", roles: ["super_admin"] },
  { prefix: "/settings/commission-tiers", roles: ["super_admin"] },
  { prefix: "/settings/payment-gateways", roles: ["super_admin"] },
  { prefix: "/settings/platform", roles: ["super_admin"] },
  { prefix: "/settings/legal-documents", roles: ["super_admin"] },

  // Finance - Super Admin, Admin, Finance Officer
  { prefix: "/finance", roles: ["super_admin", "admin", "finance_officer"] },

  // Analytics - Super Admin, Admin, Finance Officer
  { prefix: "/analytics", roles: ["super_admin", "admin", "finance_officer"] },

  // Courses - Super Admin, Admin only
  { prefix: "/courses", roles: ["super_admin", "admin"] },

  // Marketing - Super Admin, Admin only
  { prefix: "/marketing", roles: ["super_admin", "admin"] },

  // Audit log - Super Admin, Admin only
  { prefix: "/logs/audit", roles: ["super_admin", "admin"] },

  // Users - Super Admin, Admin, Support Officer
  { prefix: "/users", roles: ["super_admin", "admin", "support_officer"] },

  // Moderation (reviews, forum, content) - Super Admin, Admin, Support Officer
  { prefix: "/moderation", roles: ["super_admin", "admin", "support_officer"] },

  // Support tickets - Super Admin, Admin, Support Officer
  { prefix: "/support", roles: ["super_admin", "admin", "support_officer"] }

  // /dashboard and anything else not listed above -> allowed for all roles
];

export function isRouteAllowed(pathname: string, role: StaffRole): boolean {
  const rule = ROUTE_PERMISSIONS.find((r) => pathname === r.prefix || pathname.startsWith(`${r.prefix}/`));
  if (!rule) return true; // not restricted -> everyone can access
  return rule.roles.includes(role);
}

export function getAllowedRolesForRoute(prefix: string): StaffRole[] {
  const rule = ROUTE_PERMISSIONS.find((r) => prefix === r.prefix || prefix.startsWith(`${r.prefix}/`) || r.prefix.startsWith(prefix));
  if (!rule) return ["super_admin", "admin", "finance_officer", "support_officer"];
  return rule.roles;
}

// ---- Cookie helpers (client-side, no backend) ----

const SESSION_COOKIE = "saachi_admin_session";
const ROLE_COOKIE = "saachi_admin_role";
const NAME_COOKIE = "saachi_admin_name";
const EMAIL_COOKIE = "saachi_admin_email";

export function setAuthCookies(user: StaffUser) {
  const maxAge = 60 * 60 * 24 * 7; // 7 days
  document.cookie = `${SESSION_COOKIE}=demo_token; path=/; max-age=${maxAge}`;
  document.cookie = `${ROLE_COOKIE}=${user.role}; path=/; max-age=${maxAge}`;
  document.cookie = `${NAME_COOKIE}=${encodeURIComponent(user.name)}; path=/; max-age=${maxAge}`;
  document.cookie = `${EMAIL_COOKIE}=${encodeURIComponent(user.email)}; path=/; max-age=${maxAge}`;
}

export function clearAuthCookies() {
  document.cookie = `${SESSION_COOKIE}=; path=/; max-age=0`;
  document.cookie = `${ROLE_COOKIE}=; path=/; max-age=0`;
  document.cookie = `${NAME_COOKIE}=; path=/; max-age=0`;
  document.cookie = `${EMAIL_COOKIE}=; path=/; max-age=0`;
}

function readCookie(name: string): string | null {
  if (typeof document === "undefined") return null;
  const match = document.cookie.match(new RegExp(`(?:^|; )${name}=([^;]*)`));
  return match ? decodeURIComponent(match[1]) : null;
}

export function getCurrentRole(): StaffRole {
  const stored = readCookie(ROLE_COOKIE) as StaffRole | null;
  const valid: StaffRole[] = ["super_admin", "admin", "finance_officer", "support_officer"];
  return stored && valid.includes(stored) ? stored : "super_admin";
}

export function getCurrentName(): string {
  return readCookie(NAME_COOKIE) ?? "Abdul Rehman Irfan";
}

export function getCurrentEmail(): string {
  return readCookie(EMAIL_COOKIE) ?? "abdulrehman@saachi.ai";
}

export function setCurrentRole(role: StaffRole) {
  const maxAge = 60 * 60 * 24 * 7;
  document.cookie = `${ROLE_COOKIE}=${role}; path=/; max-age=${maxAge}`;
}
'@

Set-Content -LiteralPath $permissionsPath -Value $permissionsContent -NoNewline
Write-Host "[OK] Created $permissionsPath" -ForegroundColor Green

# ------------------------------------------------------------
# 2) Login page - real credential validation
# ------------------------------------------------------------
$loginPath = Join-Path $adminRoot "app\login\page.tsx"
Backup-IfExists $loginPath

$loginContent = @'
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { ShieldCheck, AlertCircle } from "lucide-react";
import { Button, Card, Input, ThemeToggle } from "@saachi/ui";
import { findStaffUser, setAuthCookies, ROLE_LABEL, type StaffRole } from "../../lib/permissions";

const DEMO_CREDENTIALS: { role: StaffRole; email: string; password: string }[] = [
  { role: "super_admin", email: "superadmin@saachi.ai", password: "super123" },
  { role: "admin", email: "admin@saachi.ai", password: "admin123" },
  { role: "finance_officer", email: "finance@saachi.ai", password: "finance123" },
  { role: "support_officer", email: "support@saachi.ai", password: "support123" }
];

export default function AdminLoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    const user = findStaffUser(email, password);
    if (!user) {
      setError("Invalid email or password. Check the demo credentials below.");
      return;
    }

    setLoading(true);
    setAuthCookies(user);
    setTimeout(() => router.push("/dashboard"), 500);
  };

  const fillDemo = (cred: (typeof DEMO_CREDENTIALS)[number]) => {
    setEmail(cred.email);
    setPassword(cred.password);
    setError("");
  };

  return (
    <main className="flex min-h-screen items-center justify-center bg-paper px-4 py-10">
      <div className="absolute right-5 top-5">
        <ThemeToggle />
      </div>

      <div className="flex w-full max-w-[860px] flex-col gap-6 lg:flex-row lg:items-start">
        <Card className="w-full max-w-[400px] p-8 lg:mx-auto">
          <div className="mb-6 flex flex-col items-center text-center">
            <span className="mb-4 flex h-11 w-11 items-center justify-center rounded-full border border-ink text-[15px] font-bold text-ink">
              S
            </span>
            <h1 className="text-[20px] font-semibold text-ink">Saachi AI - Admin</h1>
            <p className="mt-1.5 text-[13px] text-ink-soft">Internal staff access only.</p>
          </div>

          <form onSubmit={handleSubmit} className="flex flex-col gap-4">
            <Input
              label="Email"
              type="email"
              placeholder="you@saachi.ai"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
            <Input
              label="Password"
              type="password"
              placeholder="********"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />

            {error && (
              <div className="flex items-start gap-2 rounded-control border border-error bg-error-tint px-3 py-2.5 text-[12.5px] text-error">
                <AlertCircle size={14} strokeWidth={1.75} className="mt-0.5 shrink-0" />
                <span>{error}</span>
              </div>
            )}

            <Button type="submit" size="lg" disabled={loading}>
              {loading ? "Verifying..." : "Continue"}
            </Button>
          </form>

          <div className="mt-5 flex items-center justify-center gap-1.5 text-[12px] text-ink-soft">
            <ShieldCheck size={13} strokeWidth={1.75} />
            Role-based access control demo
          </div>
        </Card>

        <Card className="w-full max-w-[400px] p-6 lg:mx-auto">
          <p className="mb-1 text-[13px] font-semibold text-ink">Demo credentials</p>
          <p className="mb-4 text-[12px] text-ink-soft">
            No backend yet - click a role below to auto-fill and try each access level.
          </p>
          <div className="flex flex-col gap-2">
            {DEMO_CREDENTIALS.map((cred) => (
              <button
                key={cred.role}
                type="button"
                onClick={() => fillDemo(cred)}
                className="flex flex-col items-start rounded-control border border-line px-3.5 py-2.5 text-left transition-colors duration-150 ease-out hover:border-line-strong hover:bg-paper-dim"
              >
                <span className="text-[13px] font-semibold text-ink">{ROLE_LABEL[cred.role]}</span>
                <span className="mt-0.5 font-mono text-[11.5px] text-ink-soft">{cred.email}</span>
                <span className="font-mono text-[11.5px] text-ink-soft">{cred.password}</span>
              </button>
            ))}
          </div>
        </Card>
      </div>
    </main>
  );
}
'@

Set-Content -LiteralPath $loginPath -Value $loginContent -NoNewline
Write-Host "[OK] Login page rewritten with credential validation." -ForegroundColor Green

# ------------------------------------------------------------
# 3) AccessDenied component
# ------------------------------------------------------------
$accessDeniedPath = Join-Path $componentsDir "AccessDenied.tsx"
Backup-IfExists $accessDeniedPath

$accessDeniedContent = @'
"use client";

import { useRouter } from "next/navigation";
import { ShieldAlert } from "lucide-react";
import { Button } from "@saachi/ui";
import { ROLE_LABEL, type StaffRole } from "../../lib/permissions";

type AccessDeniedProps = {
  role: StaffRole;
};

export function AccessDenied({ role }: AccessDeniedProps) {
  const router = useRouter();

  return (
    <main className="mx-auto flex max-w-[600px] flex-col items-center px-4 py-24 text-center">
      <div className="mb-5 flex h-14 w-14 items-center justify-center rounded-full border border-error text-error">
        <ShieldAlert size={24} strokeWidth={1.75} />
      </div>
      <h1 className="text-[20px] font-semibold text-ink">Access denied</h1>
      <p className="mt-2 text-[13.5px] leading-relaxed text-ink-soft">
        Your current role - <span className="font-semibold text-ink">{ROLE_LABEL[role]}</span> - does not have
        permission to view this page. Switch to a role with access, or contact a Super Admin if you believe this is
        a mistake.
      </p>
      <Button className="mt-6" onClick={() => router.push("/dashboard")}>
        Back to Dashboard
      </Button>
    </main>
  );
}
'@

Set-Content -LiteralPath $accessDeniedPath -Value $accessDeniedContent -NoNewline
Write-Host "[OK] Created $accessDeniedPath" -ForegroundColor Green

# ------------------------------------------------------------
# 4) AdminShell - filter nav by role + gate page content
# ------------------------------------------------------------
$shellPath = Join-Path $componentsDir "AdminShell.tsx"
Backup-IfExists $shellPath

$shellContent = @'
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
'@

Set-Content -LiteralPath $shellPath -Value $shellContent -NoNewline
Write-Host "[OK] AdminShell rewritten with role-based nav filtering + access guard." -ForegroundColor Green

Write-Host ""
Write-Host "Done. Restart your dev server and test:" -ForegroundColor Cyan
Write-Host "  1. Go to http://localhost:3001/login" -ForegroundColor Cyan
Write-Host "  2. Click a demo role card to auto-fill credentials, then Continue" -ForegroundColor Cyan
Write-Host "  3. Sidebar will only show links that role can access" -ForegroundColor Cyan
Write-Host "  4. Try manually visiting a restricted URL (e.g. Support Officer -> /settings/platform) to see Access Denied" -ForegroundColor Cyan