# ============================================================================
# create-security-settings-page.ps1
# Creates the Security Settings page + shared SettingsNav component for the
# Saachi AI web app.
# Route: /dashboard/settings/security
# ============================================================================
# USAGE:
#   Run this from the SAI2 repo root, i.e.:
#   PS D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2> .\create-security-settings-page.ps1
# ============================================================================

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

$RepoRoot = (Get-Location).Path

# ----------------------------------------------------------------------------
# 1) Shared SettingsNav component
#    (used by Security page now; Profile Details / Notifications / Billing
#    pages will reuse the same component once they are built)
# ----------------------------------------------------------------------------
$SettingsComponentsDir = Join-Path $RepoRoot "apps\web\components\settings"
$SettingsNavFile = Join-Path $SettingsComponentsDir "SettingsNav.tsx"

if (-not (Test-Path $SettingsComponentsDir)) {
    New-Item -ItemType Directory -Path $SettingsComponentsDir -Force | Out-Null
    Write-Host "[create-security-settings-page] Created directory: $SettingsComponentsDir" -ForegroundColor Cyan
}

$SettingsNavContent = @'
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

// TODO: as Profile Details / Notifications / Billing & Payments pages are built,
// their routes below are already wired -- just add the matching page.tsx files.
const settingsNavItems = [
  { label: "Profile Details", href: "/dashboard/settings/profile" },
  { label: "Security", href: "/dashboard/settings/security" },
  { label: "Notifications", href: "/dashboard/settings/notifications" },
  { label: "Billing & Payments", href: "/dashboard/settings/billing" },
];

export function SettingsNav() {
  const pathname = usePathname();

  return (
    <nav className="flex w-56 shrink-0 flex-col gap-2">
      {settingsNavItems.map((item) => {
        const isActive = pathname === item.href;
        return (
          <Link
            key={item.href}
            href={item.href}
            className="rounded-lg px-4 py-5 text-sm tracking-wide transition"
            style={{
              backgroundColor: isActive ? "var(--token-color-surfaceAlt)" : "transparent",
              borderLeft: isActive ? "4px solid var(--token-color-primary)" : "4px solid transparent",
              color: isActive ? "var(--token-color-ink)" : "var(--token-color-inkSoft)",
              fontWeight: isActive ? 700 : 600,
            }}
          >
            {item.label}
          </Link>
        );
      })}
    </nav>
  );
}

'@

Write-Utf8NoBom -Path $SettingsNavFile -Content $SettingsNavContent
Write-Host "[create-security-settings-page] Written: $SettingsNavFile" -ForegroundColor Green

# ----------------------------------------------------------------------------
# 2) Security Settings page
# ----------------------------------------------------------------------------
$SecurityPageDir = Join-Path $RepoRoot "apps\web\app\(learner)\dashboard\settings\security"
$SecurityPageFile = Join-Path $SecurityPageDir "page.tsx"

if (-not (Test-Path $SecurityPageDir)) {
    New-Item -ItemType Directory -Path $SecurityPageDir -Force | Out-Null
    Write-Host "[create-security-settings-page] Created directory: $SecurityPageDir" -ForegroundColor Cyan
}

$SecurityPageContent = @'
"use client";

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { Form, Input, Button as AntButton, Tag, message } from "antd";
import {
  LayoutGrid,
  GraduationCap,
  Heart,
  Settings,
  HelpCircle,
  ShieldCheck,
  Smartphone,
  Monitor,
  LogOut,
} from "lucide-react";
import { SettingsNav } from "@/components/settings/SettingsNav";

// TODO: replace with useAuth() / useSessions() hooks from @saachi/api-client
interface Session {
  id: string;
  device: string;
  location: string;
  lastActive: string;
  isCurrent: boolean;
  deviceType: "desktop" | "mobile";
}

const initialSessions: Session[] = [
  {
    id: "session-1",
    device: "Mac OS - Safari",
    location: "New York, USA",
    lastActive: "Active Now",
    isCurrent: true,
    deviceType: "desktop",
  },
  {
    id: "session-2",
    device: "iOS - Safari",
    location: "New York, USA",
    lastActive: "Last seen 2h ago",
    isCurrent: false,
    deviceType: "mobile",
  },
];

const navItems = [
  { icon: LayoutGrid, label: "Dashboard", href: "/dashboard" },
  { icon: GraduationCap, label: "My Courses", href: "/dashboard/my-courses" },
  { icon: Heart, label: "Wishlist", href: "/dashboard/wishlist" },
  { icon: Settings, label: "Settings", href: "/dashboard/settings" },
];

interface PasswordFormValues {
  currentPassword: string;
  newPassword: string;
  confirmPassword: string;
}

export default function SecuritySettingsPage() {
  const [form] = Form.useForm<PasswordFormValues>();
  const [twoFactorEnabled, setTwoFactorEnabled] = useState(false);
  const [sessions, setSessions] = useState<Session[]>(initialSessions);

  function handlePasswordSubmit(values: PasswordFormValues) {
    // TODO: wire to useAuth().changePassword() from @saachi/api-client
    console.log("update password", values);
    message.success("Password updated successfully.");
    form.resetFields();
  }

  function handleToggleTwoFactor() {
    // TODO: wire to useAuth().toggleTwoFactor() from @saachi/api-client
    setTwoFactorEnabled((prev) => !prev);
  }

  function handleRevokeSession(sessionId: string) {
    // TODO: wire to useSessions().revoke(sessionId) from @saachi/api-client
    setSessions((prev) => prev.filter((s) => s.id !== sessionId));
  }

  function handleRevokeAllSessions() {
    // TODO: wire to useSessions().revokeAll() from @saachi/api-client
    setSessions((prev) => prev.filter((s) => s.isCurrent));
  }

  const otherSessionsCount = sessions.filter((s) => !s.isCurrent).length;

  return (
    <div className="flex min-h-screen bg-[var(--token-color-bg)]">
      {/* Sidebar */}
      <aside className="fixed inset-y-0 left-0 hidden w-72 flex-col justify-between border-r border-[var(--token-color-border)] bg-[var(--token-color-surfaceAlt)] lg:flex">
        <div className="flex flex-col">
          <div className="flex items-center gap-4 border-b border-[var(--token-color-border)] p-6">
            <span className="relative block h-12 w-12 shrink-0 overflow-hidden rounded-full">
              <Image
                src="https://i.pravatar.cc/96?img=47"
                alt="Learner avatar"
                fill
                sizes="48px"
                className="object-cover"
              />
            </span>
            <div className="flex flex-col">
              <span className="text-lg font-bold" style={{ color: "var(--token-color-ink)" }}>
                Learner Portal
              </span>
              <span
                style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-xs)" }}
              >
                Manage your skills
              </span>
            </div>
          </div>

          <nav className="flex flex-col gap-2 p-4">
            {navItems.map(({ icon: Icon, label, href }) => {
              const isActive = label === "Settings";
              return (
                <Link
                  key={label}
                  href={href}
                  className="flex items-center gap-4 rounded-lg border-l-4 px-4 py-3 text-sm font-semibold tracking-wide transition"
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

      {/* Main column */}
      <div className="flex w-full flex-col lg:pl-72">
        <main className="flex-1 px-12 pb-16 pt-12">
          <div className="flex flex-col gap-10">
            {/* Header */}
            <div className="flex flex-col gap-1.5">
              <h1
                className="text-5xl font-bold leading-[52.8px]"
                style={{ color: "var(--token-color-ink)" }}
              >
                Security Settings
              </h1>
              <p style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-lg)" }}>
                Manage your password, authentication, and active sessions.
              </p>
            </div>

            {/* Nav + content */}
            <div className="flex flex-col gap-10 lg:flex-row lg:items-start">
              <SettingsNav />

              <div className="flex w-full flex-1 flex-col gap-10">
                {/* Change Password */}
                <section
                  className="flex flex-col gap-3.5 rounded-xl bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-sm)]"
                  style={{ border: "1px solid color-mix(in srgb, var(--token-color-border) 30%, transparent)" }}
                >
                  <h2 className="text-2xl font-semibold leading-8" style={{ color: "var(--token-color-ink)" }}>
                    Change Password
                  </h2>

                  <Form
                    form={form}
                    layout="vertical"
                    requiredMark={false}
                    onFinish={handlePasswordSubmit}
                    className="flex w-full max-w-96 flex-col"
                  >
                    <Form.Item
                      label="Current Password"
                      name="currentPassword"
                      rules={[{ required: true, message: "Please enter your current password" }]}
                    >
                      <Input.Password size="large" />
                    </Form.Item>

                    <Form.Item
                      label="New Password"
                      name="newPassword"
                      rules={[
                        { required: true, message: "Please enter a new password" },
                        { min: 8, message: "Must be at least 8 characters long." },
                      ]}
                    >
                      <Input.Password size="large" />
                    </Form.Item>

                    <Form.Item
                      label="Confirm New Password"
                      name="confirmPassword"
                      dependencies={["newPassword"]}
                      rules={[
                        { required: true, message: "Please confirm your new password" },
                        ({ getFieldValue }) => ({
                          validator(_, value) {
                            if (!value || getFieldValue("newPassword") === value) {
                              return Promise.resolve();
                            }
                            return Promise.reject(new Error("Passwords do not match"));
                          },
                        }),
                      ]}
                    >
                      <Input.Password size="large" />
                    </Form.Item>

                    <div className="flex justify-end pt-px">
                      <AntButton type="primary" htmlType="submit">
                        Update Password
                      </AntButton>
                    </div>
                  </Form>
                </section>

                {/* Two-Factor Authentication */}
                <section
                  className="flex flex-col gap-4 rounded-xl bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-sm)]"
                  style={{ border: "1px solid color-mix(in srgb, var(--token-color-border) 30%, transparent)" }}
                >
                  <div className="flex items-center justify-between gap-4">
                    <div className="flex flex-col gap-1">
                      <h2 className="flex items-center gap-2 text-2xl font-semibold leading-8" style={{ color: "var(--token-color-ink)" }}>
                        <ShieldCheck size={20} color="var(--token-color-primary)" />
                        Two-Factor Authentication
                      </h2>
                      <p style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
                        Add an extra layer of security to your account.
                      </p>
                    </div>

                    <Tag
                      bordered={false}
                      style={{
                        backgroundColor: twoFactorEnabled
                          ? "var(--token-color-successTint)"
                          : "var(--token-color-primaryTint)",
                        color: twoFactorEnabled ? "var(--token-color-success)" : "var(--token-color-textMuted)",
                        margin: 0,
                      }}
                    >
                      Status: {twoFactorEnabled ? "Enabled" : "Disabled"}
                    </Tag>
                  </div>

                  <div
                    className="flex items-center justify-between gap-4 rounded-lg p-4"
                    style={{
                      backgroundColor: "var(--token-color-bg)",
                      border: "1px solid color-mix(in srgb, var(--token-color-border) 50%, transparent)",
                    }}
                  >
                    <div className="flex items-center gap-4">
                      <span
                        className="flex h-12 w-12 shrink-0 items-center justify-center rounded-full"
                        style={{ backgroundColor: "var(--token-color-primaryTint)" }}
                      >
                        <Smartphone size={20} color="var(--token-color-primary)" />
                      </span>
                      <div className="flex flex-col">
                        <span className="text-sm font-semibold tracking-wide" style={{ color: "var(--token-color-ink)" }}>
                          Authenticator App
                        </span>
                        <span className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
                          Use an app like Google Authenticator.
                        </span>
                      </div>
                    </div>

                    <AntButton onClick={handleToggleTwoFactor}>
                      {twoFactorEnabled ? "Disable" : "Enable"}
                    </AntButton>
                  </div>
                </section>

                {/* Active Sessions */}
                <section
                  className="flex flex-col gap-6 rounded-xl bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-sm)]"
                  style={{ border: "1px solid color-mix(in srgb, var(--token-color-border) 30%, transparent)" }}
                >
                  <div className="flex items-center justify-between">
                    <h2 className="text-2xl font-semibold leading-8" style={{ color: "var(--token-color-ink)" }}>
                      Active Sessions
                    </h2>

                    {otherSessionsCount > 0 && (
                      <button
                        type="button"
                        onClick={handleRevokeAllSessions}
                        className="text-sm font-semibold tracking-wide"
                        style={{ color: "var(--token-color-error)" }}
                      >
                        Revoke All
                      </button>
                    )}
                  </div>

                  <div className="flex flex-col gap-4">
                    {sessions.map((session) => (
                      <div
                        key={session.id}
                        className="flex items-center justify-between gap-4 rounded-lg p-4"
                        style={{
                          backgroundColor: "var(--token-color-bg)",
                          border: session.isCurrent
                            ? "1px solid color-mix(in srgb, var(--token-color-primary) 20%, transparent)"
                            : "1px solid color-mix(in srgb, var(--token-color-border) 50%, transparent)",
                        }}
                      >
                        <div className="flex items-center gap-4">
                          {session.deviceType === "desktop" ? (
                            <Monitor size={22} color={session.isCurrent ? "var(--token-color-primary)" : "var(--token-color-inkSoft)"} />
                          ) : (
                            <Smartphone size={20} color={session.isCurrent ? "var(--token-color-primary)" : "var(--token-color-inkSoft)"} />
                          )}
                          <div className="flex flex-col">
                            <span className="text-sm font-semibold tracking-wide" style={{ color: "var(--token-color-ink)" }}>
                              {session.device}
                            </span>
                            <span className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
                              {session.location} &bull; {session.lastActive}
                            </span>
                          </div>
                        </div>

                        {session.isCurrent ? (
                          <span className="text-xs font-bold" style={{ color: "var(--token-color-primary)" }}>
                            Current
                          </span>
                        ) : (
                          <button
                            type="button"
                            aria-label={`Revoke ${session.device} session`}
                            onClick={() => handleRevokeSession(session.id)}
                            className="flex h-9 w-9 items-center justify-center rounded-full transition hover:bg-[var(--token-color-surfaceAlt)]"
                          >
                            <LogOut size={18} color="var(--token-color-inkSoft)" />
                          </button>
                        )}
                      </div>
                    ))}

                    {sessions.length === 0 && (
                      <p style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-sm)" }}>
                        No active sessions.
                      </p>
                    )}
                  </div>
                </section>
              </div>
            </div>
          </div>
        </main>
      </div>
    </div>
  );
}

'@

Write-Utf8NoBom -Path $SecurityPageFile -Content $SecurityPageContent
Write-Host "[create-security-settings-page] Written: $SecurityPageFile" -ForegroundColor Green

Write-Host ""
Write-Host "Route available at: /dashboard/settings/security" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. cd apps\web"
Write-Host "  2. pnpm dev"
Write-Host "  3. Visit http://localhost:3000/dashboard/settings/security"
Write-Host ""
Write-Host "Notes:" -ForegroundColor Yellow
Write-Host "  - SettingsNav.tsx is shared -> reuse it in Profile Details / Notifications / Billing"
Write-Host "    pages when you build them (routes already wired: /dashboard/settings/profile,"
Write-Host "    /dashboard/settings/notifications, /dashboard/settings/billing)."
Write-Host "  - All colors use var(--token-color-*) from packages/ui design tokens (tokens.ts)."
Write-Host "  - Password form uses antd Form with built-in validation (min length, match check)."
Write-Host "  - Dummy sessions/2FA state is in-file with // TODO markers -> wire to useAuth() /"
Write-Host "    useSessions() hooks once added to @saachi/api-client."