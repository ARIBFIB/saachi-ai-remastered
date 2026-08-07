"use client";

import { useState } from "react";
import { SlidersHorizontal, Save } from "lucide-react";
import { Button, Card, Input, Select } from "@saachi/ui";

const CURRENCY_OPTIONS = [
  { label: "USD - US Dollar", value: "USD" },
  { label: "PKR - Pakistani Rupee", value: "PKR" },
  { label: "GBP - British Pound", value: "GBP" }
];

type FeatureFlag = { key: string; label: string; description: string; enabled: boolean };

const INITIAL_FLAGS: FeatureFlag[] = [
  { key: "corporate_accounts", label: "Corporate / Team Accounts", description: "Enable bulk seat purchase and team dashboards.", enabled: false },
  { key: "mentorship", label: "Mentorship Bookings", description: "Allow instructors to offer paid 1-on-1 sessions.", enabled: true },
  { key: "affiliate_program", label: "Affiliate Program", description: "Enable referral links and affiliate payouts.", enabled: false },
  { key: "ai_recommendations", label: "AI Recommendation Engine", description: "Personalized course suggestions on the homepage.", enabled: false }
];

export default function PlatformSettingsPage() {
  const [siteName, setSiteName] = useState("Saachi AI");
  const [defaultCurrency, setDefaultCurrency] = useState("USD");
  const [flags, setFlags] = useState(INITIAL_FLAGS);
  const [saving, setSaving] = useState(false);

  const toggleFlag = (key: string) => {
    setFlags((prev) => prev.map((f) => (f.key === key ? { ...f, enabled: !f.enabled } : f)));
  };

  const handleSave = () => {
    setSaving(true);
    setTimeout(() => setSaving(false), 700);
  };

  return (
    <main className="mx-auto max-w-[800px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <SlidersHorizontal size={17} strokeWidth={1.75} />
          </div>
          <div>
            <h1 className="text-[22px] font-semibold text-ink">Platform Settings</h1>
            <p className="mt-0.5 text-[13px] text-ink-soft">Site identity, default currency, and feature flags.</p>
          </div>
        </div>
        <Button size="sm" onClick={handleSave} disabled={saving}>
          <Save size={14} strokeWidth={1.75} /> {saving ? "Saving..." : "Save changes"}
        </Button>
      </div>

      <Card className="mb-5 flex flex-col gap-4 p-5">
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <Input label="Site name" value={siteName} onChange={(e) => setSiteName(e.target.value)} />
          <Select label="Default currency" options={CURRENCY_OPTIONS} value={defaultCurrency} onChange={(e) => setDefaultCurrency(e.target.value)} />
        </div>
      </Card>

      <Card className="p-5">
        <p className="mb-4 text-[14px] font-semibold text-ink">Feature flags</p>
        <div className="flex flex-col gap-1">
          {flags.map((flag, i) => (
            <div key={flag.key} className={`flex items-center justify-between gap-4 py-3 ${i > 0 ? "border-t border-line" : ""}`}>
              <div>
                <p className="text-[13.5px] font-medium text-ink">{flag.label}</p>
                <p className="mt-0.5 text-[12px] text-ink-soft">{flag.description}</p>
              </div>
              <button
                type="button"
                onClick={() => toggleFlag(flag.key)}
                className={`relative h-6 w-11 shrink-0 rounded-full transition-colors duration-150 ease-out ${
                  flag.enabled ? "bg-ink" : "bg-paper-dim"
                }`}
              >
                <span
                  className={`absolute top-0.5 h-5 w-5 rounded-full bg-paper transition-transform duration-150 ease-out ${
                    flag.enabled ? "translate-x-[22px]" : "translate-x-0.5"
                  }`}
                />
              </button>
            </div>
          ))}
        </div>
      </Card>
    </main>
  );
}