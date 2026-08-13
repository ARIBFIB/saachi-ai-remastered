"use client";

import { useState } from "react";
import { Download, ShieldAlert, Trash2 } from "lucide-react";
import { useSession } from "@saachi/api-client";
import { Button, EmptyState, Switch } from "@saachi/ui";

export default function SettingsPrivacyPage() {
  const { data: session } = useSession();
  const [cookiePrefs, setCookiePrefs] = useState({ analytics: true, marketing: false });
  const [exportRequested, setExportRequested] = useState(false);

  if (!session) {
    return <EmptyState title="Not logged in" description="Log in to view and edit your privacy settings." />;
  }

  return (
    <div>
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Privacy</h1>

      <div className="max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-3 text-[15px] font-semibold text-ink">Cookie preferences</h2>
        <div className="flex flex-col gap-3">
          <div className="flex items-center justify-between">
            <p className="text-[13px] text-ink-soft">Analytics cookies</p>
            <Switch
              checked={cookiePrefs.analytics}
              onChange={(v) => setCookiePrefs((p) => ({ ...p, analytics: v }))}
              aria-label="Toggle analytics cookies"
            />
          </div>
          <div className="flex items-center justify-between">
            <p className="text-[13px] text-ink-soft">Marketing cookies</p>
            <Switch
              checked={cookiePrefs.marketing}
              onChange={(v) => setCookiePrefs((p) => ({ ...p, marketing: v }))}
              aria-label="Toggle marketing cookies"
            />
          </div>
        </div>
      </div>

      <div className="mt-6 max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-2 flex items-center gap-2 text-[15px] font-semibold text-ink">
          <Download size={16} />
          Data export
        </h2>
        <p className="mb-4 text-[13px] text-ink-soft">
          Request a copy of the personal data associated with your account.
        </p>
        <Button variant="secondary" disabled={exportRequested} onClick={() => setExportRequested(true)}>
          {exportRequested ? "Export requested" : "Request data export"}
        </Button>
      </div>

      <div className="mt-6 max-w-lg rounded-card border border-error/30 bg-error-tint p-6">
        <h2 className="mb-2 flex items-center gap-2 text-[15px] font-semibold text-ink">
          <ShieldAlert size={16} />
          Delete account
        </h2>
        <p className="mb-4 text-[13px] text-ink-soft">
          Permanently delete your account and all associated data. This cannot be undone.
        </p>
        <Button variant="danger">
          <Trash2 size={14} className="mr-1.5" />
          Request account deletion
        </Button>
      </div>
    </div>
  );
}