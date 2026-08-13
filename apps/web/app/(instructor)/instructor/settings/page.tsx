"use client";

import { useState } from "react";
import { useSession } from "@saachi/api-client";
import { Button, Input, Textarea, EmptyState } from "@saachi/ui";

export default function InstructorSettingsPage() {
  const { data: session } = useSession();

  const [bio, setBio] = useState("");
  const [portfolioUrl, setPortfolioUrl] = useState("");
  const [taxId, setTaxId] = useState("");
  const [emailNotifs, setEmailNotifs] = useState(true);
  const [qaNotifs, setQaNotifs] = useState(true);
  const [saved, setSaved] = useState(false);

  if (!session) {
    return <EmptyState title="Not logged in" description="Log in to view and edit your instructor settings." />;
  }

  function handleSave() {
    // NOTE: demo-only, no backend instructor-settings mutation wired up yet.
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  }

  return (
    <div>
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Instructor Settings</h1>

      <div className="max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-4 text-[15px] font-semibold text-ink">Profile</h2>
        <div className="flex flex-col gap-4">
          <Input label="Full name" defaultValue={session.fullName} />
          <Textarea label="Instructor bio" rows={4} value={bio} onChange={(e) => setBio(e.target.value)} placeholder="Tell learners about your background and expertise" />
          <Input label="Portfolio link" value={portfolioUrl} onChange={(e) => setPortfolioUrl(e.target.value)} placeholder="GitHub, LinkedIn, or personal site" />
        </div>
      </div>

      <div className="mt-6 max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-4 text-[15px] font-semibold text-ink">Payout tax info</h2>
        <Input label="Tax ID / NTN (optional)" value={taxId} onChange={(e) => setTaxId(e.target.value)} />
      </div>

      <div className="mt-6 max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-4 text-[15px] font-semibold text-ink">Notification preferences</h2>
        <div className="flex flex-col gap-3">
          <label className="flex items-center justify-between">
            <span className="text-[13px] text-ink-soft">Email me about new sales</span>
            <input
              type="checkbox"
              checked={emailNotifs}
              onChange={(e) => setEmailNotifs(e.target.checked)}
              aria-label="Toggle sales email notifications"
              className="h-4 w-4 accent-gold-dark"
            />
          </label>
          <label className="flex items-center justify-between">
            <span className="text-[13px] text-ink-soft">Email me about new Q&amp;A questions</span>
            <input
              type="checkbox"
              checked={qaNotifs}
              onChange={(e) => setQaNotifs(e.target.checked)}
              aria-label="Toggle Q&A email notifications"
              className="h-4 w-4 accent-gold-dark"
            />
          </label>
        </div>
      </div>

      <Button size="lg" className="mt-6" onClick={handleSave}>
        {saved ? "Saved" : "Save changes"}
      </Button>
    </div>
  );
}