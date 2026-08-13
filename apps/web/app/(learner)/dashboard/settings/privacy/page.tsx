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
                  className="flex items-center gap-4 rounded-[var(--token-radius-md)] border-l-4 px-4 py-3 text-sm font-semibold tracking-wide transition"
                  style={{
                    borderColor: isActive ? "var(--token-color-amber)" : "transparent",
                    backgroundColor: isActive ? "var(--token-color-amberTint)" : "transparent",
                    color: isActive ? "var(--token-color-amber)" : "var(--token-color-inkSoft)",
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
            className="flex h-12 items-center gap-4 rounded-[var(--token-radius-md)] pl-4 text-sm font-semibold tracking-wide text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-surface)]"
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
                  className="relative flex flex-col gap-6 overflow-hidden rounded-[var(--token-radius-lg)] bg-[var(--token-color-surface)] px-10 pb-10 pt-14 shadow-[var(--token-shadow-md)]"
                  style={{ border: "2px solid var(--token-color-inkDeep)" }}
                >
                  <div
                    className="pointer-events-none absolute -right-8 -top-16 h-64 w-64 rounded-full blur-[32px]"
                    style={{ backgroundColor: "color-mix(in srgb, var(--token-color-amberTint) 20%, transparent)" }}
                  />

                  <div className="relative flex items-start gap-4">
                    <span
                      className="flex h-12 w-12 shrink-0 items-center justify-center rounded-[var(--token-radius-md)]"
                      style={{ backgroundColor: "var(--token-color-amberTint)" }}
                    >
                      <Eye size={20} color="var(--token-color-amber)" />
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
                    className="flex flex-col gap-4 rounded-[var(--token-radius-lg)] bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-md)]"
                    style={{ border: "2px solid var(--token-color-inkDeep)" }}
                  >
                    <span
                      className="flex h-10 w-10 items-center justify-center rounded-[var(--token-radius-md)]"
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
                    className="relative flex flex-col gap-4 overflow-hidden rounded-[var(--token-radius-lg)] bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-md)]"
                    style={{ border: "2px solid var(--token-color-error)" }}
                  >
                    <div
                      className="pointer-events-none absolute -right-2 -top-2 h-32 w-32 rounded-bl-full"
                      style={{ backgroundColor: "color-mix(in srgb, var(--token-color-errorTint) 50%, transparent)" }}
                    />

                    <span
                      className="relative flex h-10 w-10 items-center justify-center rounded-[var(--token-radius-md)]"
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
                      className="relative rounded-[var(--token-radius-md)] px-6 py-2 text-sm font-semibold tracking-wide"
                      style={{
                        backgroundColor: "var(--token-color-surfaceAlt)",
                        border: "2px solid var(--token-color-error)",
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
