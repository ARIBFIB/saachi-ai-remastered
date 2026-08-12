# ============================================================================
# create-privacy-settings-page.ps1
# Creates the Privacy & Data page for the Saachi AI web app, and updates the
# shared SettingsNav component to add a "Privacy & Data" entry.
# Route: /dashboard/settings/privacy
# ============================================================================
# USAGE:
#   Run this from the SAI2 repo root, i.e.:
#   PS D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2> .\create-privacy-settings-page.ps1
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
# 1) Update shared SettingsNav.tsx (adds "Privacy & Data" entry).
#    This OVERWRITES the existing file from create-security-settings-page.ps1
#    with an updated version that includes the new nav item. If you have
#    customized SettingsNav.tsx since then, back it up first.
# ----------------------------------------------------------------------------
$SettingsComponentsDir = Join-Path $RepoRoot "apps\web\components\settings"
$SettingsNavFile = Join-Path $SettingsComponentsDir "SettingsNav.tsx"

if (-not (Test-Path $SettingsComponentsDir)) {
    New-Item -ItemType Directory -Path $SettingsComponentsDir -Force | Out-Null
    Write-Host "[create-privacy-settings-page] Created directory: $SettingsComponentsDir" -ForegroundColor Cyan
}

if (Test-Path $SettingsNavFile) {
    Write-Host "[create-privacy-settings-page] Overwriting existing SettingsNav.tsx with Privacy & Data added." -ForegroundColor Yellow
}

$SettingsNavContent = @'
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

// TODO: as each page is built, its route below is already wired -- just add
// the matching page.tsx file under app/(learner)/dashboard/settings/<route>.
const settingsNavItems = [
  { label: "Profile Details", href: "/dashboard/settings/profile" },
  { label: "Security", href: "/dashboard/settings/security" },
  { label: "Notifications", href: "/dashboard/settings/notifications" },
  { label: "Billing & Payments", href: "/dashboard/settings/billing" },
  { label: "Privacy & Data", href: "/dashboard/settings/privacy" },
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
Write-Host "[create-privacy-settings-page] Written: $SettingsNavFile" -ForegroundColor Green

# ----------------------------------------------------------------------------
# 2) Privacy & Data page
# ----------------------------------------------------------------------------
$PrivacyPageDir = Join-Path $RepoRoot "apps\web\app\(learner)\dashboard\settings\privacy"
$PrivacyPageFile = Join-Path $PrivacyPageDir "page.tsx"

if (-not (Test-Path $PrivacyPageDir)) {
    New-Item -ItemType Directory -Path $PrivacyPageDir -Force | Out-Null
    Write-Host "[create-privacy-settings-page] Created directory: $PrivacyPageDir" -ForegroundColor Cyan
}

$PrivacyPageContent = @'
"use client";

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { Switch, Button as AntButton, Modal, message } from "antd";
import {
  LayoutGrid,
  GraduationCap,
  Heart,
  Settings,
  HelpCircle,
  Eye,
  Download,
  Trash2,
} from "lucide-react";
import { SettingsNav } from "@/components/settings/SettingsNav";

// TODO: replace with usePrivacySettings() hook from @saachi/api-client
interface PrivacyToggle {
  key: "publicProfile" | "showCourseProgress" | "displayAchievements";
  title: string;
  description: string;
  enabled: boolean;
}

const initialToggles: PrivacyToggle[] = [
  {
    key: "publicProfile",
    title: "Public Profile",
    description: "Allow your profile to be discoverable by other users.",
    enabled: true,
  },
  {
    key: "showCourseProgress",
    title: "Show Course Progress",
    description: "Let others see which courses you are currently taking.",
    enabled: false,
  },
  {
    key: "displayAchievements",
    title: "Display Achievements",
    description: "Show earned certificates and badges on your profile.",
    enabled: true,
  },
];

const navItems = [
  { icon: LayoutGrid, label: "Dashboard", href: "/dashboard" },
  { icon: GraduationCap, label: "My Courses", href: "/dashboard/my-courses" },
  { icon: Heart, label: "Wishlist", href: "/dashboard/wishlist" },
  { icon: Settings, label: "Settings", href: "/dashboard/settings" },
];

export default function PrivacySettingsPage() {
  const [toggles, setToggles] = useState(initialToggles);
  const [exporting, setExporting] = useState(false);
  const [modal, contextHolder] = Modal.useModal();

  function handleToggle(key: PrivacyToggle["key"], checked: boolean) {
    // TODO: wire to usePrivacySettings().update(key, checked) from @saachi/api-client
    setToggles((prev) => prev.map((t) => (t.key === key ? { ...t, enabled: checked } : t)));
  }

  function handleRequestExport() {
    // TODO: wire to usePrivacySettings().requestDataExport() from @saachi/api-client
    setExporting(true);
    setTimeout(() => {
      setExporting(false);
      message.success("Export requested. We'll email you a download link shortly.");
    }, 1200);
  }

  function handleDeleteAccount() {
    modal.confirm({
      title: "Delete your account?",
      content:
        "This will permanently delete your account and all associated data, including course history, certificates, and progress. This action cannot be undone.",
      okText: "Delete Account",
      okButtonProps: { danger: true },
      cancelText: "Cancel",
      onOk: () => {
        // TODO: wire to usePrivacySettings().deleteAccount() from @saachi/api-client
        console.log("delete account confirmed");
      },
    });
  }

  return (
    <div className="flex min-h-screen bg-[var(--token-color-bg)]">
      {contextHolder}

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
        <main className="flex-1 px-12 pb-20 pt-12">
          <div className="mx-auto flex w-full max-w-[896px] flex-col gap-6">
            {/* Header */}
            <div className="flex flex-col gap-1.5">
              <h1
                className="text-5xl font-bold leading-[52.8px]"
                style={{ color: "var(--token-color-ink)" }}
              >
                Privacy &amp; Data
              </h1>
              <p style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-lg)" }}>
                Manage how your data is used and your visibility within the Saachi AI community.
              </p>
            </div>

            <div className="flex flex-col gap-6 lg:flex-row lg:items-start">
              <SettingsNav />

              <div className="flex w-full flex-1 flex-col gap-6">
                {/* Community Visibility */}
                <section
                  className="relative flex flex-col gap-6 overflow-hidden rounded-xl bg-[var(--token-color-surface)] px-10 pb-10 pt-14 shadow-[var(--token-shadow-md)]"
                  style={{ border: "1px solid var(--token-color-border)" }}
                >
                  <div
                    className="pointer-events-none absolute -right-8 -top-16 h-64 w-64 rounded-full blur-[32px]"
                    style={{ backgroundColor: "color-mix(in srgb, var(--token-color-primaryTint) 20%, transparent)" }}
                  />

                  <div className="relative flex items-start gap-4">
                    <span
                      className="flex h-12 w-12 shrink-0 items-center justify-center rounded-lg"
                      style={{ backgroundColor: "var(--token-color-primaryTint)" }}
                    >
                      <Eye size={20} color="var(--token-color-primary)" />
                    </span>
                    <div className="flex flex-col gap-1">
                      <h2 className="text-2xl font-semibold leading-8" style={{ color: "var(--token-color-ink)" }}>
                        Community Visibility
                      </h2>
                      <p style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
                        Control what other learners and instructors can see about your profile.
                      </p>
                    </div>
                  </div>

                  <div className="relative flex flex-col">
                    {toggles.map((toggle, idx) => (
                      <div
                        key={toggle.key}
                        className="flex items-center justify-between gap-6 py-4"
                        style={
                          idx < toggles.length - 1
                            ? { borderBottom: "1px solid var(--token-color-border)" }
                            : undefined
                        }
                      >
                        <div className="flex flex-col gap-1">
                          <h3 className="text-sm font-semibold tracking-wide" style={{ color: "var(--token-color-ink)" }}>
                            {toggle.title}
                          </h3>
                          <p className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
                            {toggle.description}
                          </p>
                        </div>

                        <Switch
                          checked={toggle.enabled}
                          onChange={(checked) => handleToggle(toggle.key, checked)}
                        />
                      </div>
                    ))}
                  </div>
                </section>

                {/* Export Data + Danger Zone */}
                <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
                  {/* Export Data */}
                  <div
                    className="flex flex-col gap-4 rounded-xl bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-md)]"
                    style={{ border: "1px solid var(--token-color-border)" }}
                  >
                    <span
                      className="flex h-10 w-10 items-center justify-center rounded-lg"
                      style={{ backgroundColor: "var(--token-color-success)" }}
                    >
                      <Download size={16} color="var(--token-color-completedGreen)" />
                    </span>

                    <h2 className="text-2xl font-semibold leading-8" style={{ color: "var(--token-color-ink)" }}>
                      Export Data
                    </h2>

                    <p style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
                      Download a copy of your personal data, including course history, certificates, and
                      profile information.
                    </p>

                    <AntButton
                      type="primary"
                      block
                      loading={exporting}
                      onClick={handleRequestExport}
                    >
                      Request Export
                    </AntButton>
                  </div>

                  {/* Danger Zone */}
                  <div
                    className="relative flex flex-col gap-4 overflow-hidden rounded-xl bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-md)]"
                    style={{ border: "1px solid color-mix(in srgb, var(--token-color-error) 20%, transparent)" }}
                  >
                    <div
                      className="pointer-events-none absolute -right-2 -top-2 h-32 w-32 rounded-bl-full"
                      style={{ backgroundColor: "color-mix(in srgb, var(--token-color-errorTint) 50%, transparent)" }}
                    />

                    <span
                      className="relative flex h-10 w-10 items-center justify-center rounded-lg"
                      style={{ backgroundColor: "var(--token-color-errorTint)" }}
                    >
                      <Trash2 size={16} color="var(--token-color-error)" />
                    </span>

                    <h2 className="relative text-2xl font-semibold leading-8" style={{ color: "var(--token-color-ink)" }}>
                      Danger Zone
                    </h2>

                    <p className="relative" style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
                      Permanently delete your account and all associated data. This action cannot be
                      undone.
                    </p>

                    <button
                      type="button"
                      onClick={handleDeleteAccount}
                      className="relative rounded-lg px-6 py-2 text-sm font-semibold tracking-wide"
                      style={{
                        backgroundColor: "var(--token-color-surfaceAlt)",
                        border: "1px solid color-mix(in srgb, var(--token-color-error) 30%, transparent)",
                        color: "var(--token-color-error)",
                      }}
                    >
                      Delete Account
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </main>
      </div>
    </div>
  );
}

'@

Write-Utf8NoBom -Path $PrivacyPageFile -Content $PrivacyPageContent
Write-Host "[create-privacy-settings-page] Written: $PrivacyPageFile" -ForegroundColor Green

Write-Host ""
Write-Host "Route available at: /dashboard/settings/privacy" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. cd apps\web"
Write-Host "  2. pnpm dev"
Write-Host "  3. Visit http://localhost:3000/dashboard/settings/privacy"
Write-Host ""
Write-Host "Notes:" -ForegroundColor Yellow
Write-Host "  - SettingsNav.tsx now includes all 5 tabs: Profile Details, Security,"
Write-Host "    Notifications, Billing & Payments, Privacy & Data."
Write-Host "  - Community Visibility toggles use antd Switch, state is live in-memory."
Write-Host "  - Delete Account uses antd Modal.confirm() for a real confirmation step"
Write-Host "    before the destructive action fires -- never wire delete directly to"
Write-Host "    the button's onClick without this guard."
Write-Host "  - Request Export shows a loading state then a success message (stubbed"
Write-Host "    with setTimeout) -- replace with the real API call in handleRequestExport()."
Write-Host "  - All colors use var(--token-color-*) from packages/ui design tokens (tokens.ts)."