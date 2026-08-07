"use client";

import { useState } from "react";
import { ShieldCheck, Upload, Clock, CheckCircle2 } from "lucide-react";
import { Button, Card, Input, Badge } from "@saachi/ui";

type VerificationStatus = "not_submitted" | "pending" | "verified";

const TIER_STEPS = [
  { tier: "New Instructor", requirement: "Just approved, 0-2 published courses" },
  { tier: "Verified Instructor", requirement: "ID verified, 3+ courses, 4.0+ average rating" },
  { tier: "Top-Rated Instructor", requirement: "10+ courses, 4.5+ rating, consistent sales" },
  { tier: "Partner Instructor", requirement: "Invited/negotiated status" }
];

export default function VerificationStatusPage() {
  const [status, setStatus] = useState<VerificationStatus>("not_submitted");
  const [idFile, setIdFile] = useState<string | null>(null);
  const [portfolioLink, setPortfolioLink] = useState("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setStatus("pending");
  };

  return (
    <main className="mx-auto max-w-[720px] px-6 py-10 md:px-10">
      <div className="mb-8 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-control bg-teal-light text-teal">
          <ShieldCheck size={18} />
        </div>
        <div>
          <h1 className="font-display text-[24px] font-semibold text-ink">Verification Status</h1>
          <p className="mt-1 text-[13px] text-ink-soft">Get verified to unlock lower commission rates.</p>
        </div>
      </div>

      <Card className="mb-6 p-6">
        {status === "not_submitted" && (
          <form onSubmit={handleSubmit} className="flex flex-col gap-4">
            <div>
              <label className="mb-1.5 block text-[13px] font-semibold text-ink">
                Government ID or business registration
              </label>
              <button
                type="button"
                onClick={() => setIdFile("id-document-demo.pdf")}
                className="flex w-full items-center justify-center gap-2 rounded-control border border-dashed border-line-strong py-6 text-[13px] text-ink-soft hover:border-ink"
              >
                <Upload size={16} />
                {idFile ? idFile : "Click to upload (demo)"}
              </button>
            </div>
            <Input
              label="Portfolio / proof-of-work link"
              placeholder="GitHub, LinkedIn, or personal site"
              value={portfolioLink}
              onChange={(e) => setPortfolioLink(e.target.value)}
            />
            <Button type="submit" disabled={!idFile}>
              Submit for verification
            </Button>
          </form>
        )}

        {status === "pending" && (
          <div className="flex items-center gap-3">
            <Clock size={20} className="text-gold-dark" />
            <div>
              <p className="text-[14px] font-semibold text-ink">Under review</p>
              <p className="text-[13px] text-ink-soft">
                Your documents were submitted (demo). Admin review typically takes 2-3 business days.
              </p>
            </div>
            <Button size="sm" variant="secondary" className="ml-auto" onClick={() => setStatus("verified")}>
              Simulate approval
            </Button>
          </div>
        )}

        {status === "verified" && (
          <div className="flex items-center gap-3">
            <CheckCircle2 size={20} className="text-teal" />
            <div>
              <p className="text-[14px] font-semibold text-ink">Verified Instructor</p>
              <p className="text-[13px] text-ink-soft">
                You now qualify for a reduced commission rate and the Verified badge.
              </p>
            </div>
            <Badge variant="success" className="ml-auto">
              Verified
            </Badge>
          </div>
        )}
      </Card>

      <h2 className="mb-4 text-[15px] font-semibold text-ink">Instructor trust tiers</h2>
      <div className="flex flex-col gap-3">
        {TIER_STEPS.map((t) => (
          <Card key={t.tier} className="flex items-center justify-between p-4">
            <div>
              <p className="text-[13px] font-semibold text-ink">{t.tier}</p>
              <p className="mt-0.5 text-[12px] text-ink-soft">{t.requirement}</p>
            </div>
          </Card>
        ))}
      </div>
    </main>
  );
}