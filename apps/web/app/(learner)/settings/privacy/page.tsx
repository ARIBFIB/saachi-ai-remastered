"use client";

import { useState } from "react";
import { Download, ShieldAlert, Trash2 } from "lucide-react";
import { useSession } from "@saachi/api-client";
import { Button, EmptyState } from "@saachi/ui";

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
          <label className="flex items-center justify-between">
            <span className="text-[13px] text-ink-soft">Analytics cookies</span>
            <input
              type="checkbox"
              checked={cookiePrefs.analytics}
              onChange={(e) => setCookiePrefs((p) => ({ ...p, analytics: e.target.checked }))}
              aria-label="Toggle analytics cookies"
              className="h-4 w-4 accent-gold-dark"
            />
          </label>
          <label className="flex items-center justify-between">
            <span className="text-[13px] text-ink-soft">Marketing cookies</span>
            <input
              type="checkbox"
              checked={cookiePrefs.marketing}
              onChange={(e) => setCookiePrefs((p) => ({ ...p, marketing: e.target.checked }))}
              aria-label="Toggle marketing cookies"
              className="h-4 w-4 accent-gold-dark"
            />
          </label>
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