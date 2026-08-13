"use client";

import { useState, type FormEvent } from "react";
import { ShieldCheck, Smartphone } from "lucide-react";
import { useSession } from "@saachi/api-client";
import { Button, EmptyState, Input } from "@saachi/ui";

export default function SettingsSecurityPage() {
  const { data: session } = useSession();
  const [twoFactorEnabled, setTwoFactorEnabled] = useState(false);
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");

  if (!session) {
    return <EmptyState title="Not logged in" description="Log in to view and edit your security settings." />;
  }

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    // NOTE: demo-only, no backend auth mutation wired up yet.
    setCurrentPassword("");
    setNewPassword("");
  }

  return (
    <div>
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Security</h1>

      <div className="max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-4 flex items-center gap-2 text-[15px] font-semibold text-ink">
          <ShieldCheck size={16} />
          Change password
        </h2>
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <Input
            label="Current password"
            type="password"
            value={currentPassword}
            onChange={(e) => setCurrentPassword(e.target.value)}
          />
          <Input
            label="New password"
            type="password"
            value={newPassword}
            onChange={(e) => setNewPassword(e.target.value)}
          />
          <Button type="submit" className="self-start">
            Update password
          </Button>
        </form>
      </div>

      <div className="mt-6 max-w-lg rounded-card border border-line bg-card p-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Smartphone size={16} className="text-ink-soft" />
            <div>
              <p className="text-[14px] font-semibold text-ink">Two-factor authentication</p>
              <p className="text-[13px] text-ink-soft">Add an extra layer of security to your account.</p>
            </div>
          </div>
          <input
            type="checkbox"
            checked={twoFactorEnabled}
            onChange={(e) => setTwoFactorEnabled(e.target.checked)}
            aria-label="Toggle two-factor authentication"
            className="h-4 w-4 accent-gold-dark"
          />
        </div>
      </div>

      <div className="mt-6 max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-2 text-[15px] font-semibold text-ink">Active sessions</h2>
        <p className="text-[13px] text-ink-soft">This device - {session.email}</p>
      </div>
    </div>
  );
}