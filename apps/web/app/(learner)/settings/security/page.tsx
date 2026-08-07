"use client";

import { useState } from "react";
import Link from "next/link";
import { ShieldCheck } from "lucide-react";
import { Button, Card, Input } from "@saachi/ui";

const SETTINGS_TABS = [
  { label: "Profile", href: "/settings/profile" },
  { label: "Security", href: "/settings/security" }
];

export default function SettingsSecurityPage() {
  const [saved, setSaved] = useState(false);

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    // NOTE: demo-only. Replace with real Auth/Users API call once backend exists.
    setSaved(true);
    setTimeout(() => setSaved(false), 2500);
  };

  return (
    <main className="mx-auto max-w-[720px] px-6 py-10 md:px-10">
      <h1 className="mb-6 font-display text-[26px] font-semibold text-ink">Settings</h1>

      <div className="mb-8 flex gap-6 border-b border-line">
        {SETTINGS_TABS.map((tab) => (
          <Link
            key={tab.href}
            href={tab.href}
            className={
              tab.label === "Security"
                ? "border-b-2 border-ink px-1 pb-3 text-[14px] font-semibold text-ink"
                : "px-1 pb-3 text-[14px] font-medium text-ink-soft hover:text-ink"
            }
          >
            {tab.label}
          </Link>
        ))}
      </div>

      <Card className="mb-6 p-6">
        <h2 className="mb-4 text-[16px] font-semibold text-ink">Change password</h2>
        <form onSubmit={handleSave} className="flex flex-col gap-4">
          <Input label="Current password" type="password" placeholder="********" />
          <Input label="New password" type="password" placeholder="At least 8 characters" />
          <Input label="Confirm new password" type="password" placeholder="Repeat new password" />
          <div className="mt-2 flex items-center gap-3">
            <Button type="submit">Update password</Button>
            {saved && <span className="text-[13px] text-teal">Saved</span>}
          </div>
        </form>
      </Card>

      <Card className="p-6">
        <div className="flex items-center gap-3">
          <ShieldCheck size={20} className="text-teal" />
          <div>
            <h2 className="text-[15px] font-semibold text-ink">Two-factor authentication</h2>
            <p className="text-[13px] text-ink-soft">Not enabled - available once the backend auth flow is live.</p>
          </div>
        </div>
      </Card>
    </main>
  );
}