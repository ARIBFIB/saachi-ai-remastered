"use client";

import { useState, type FormEvent } from "react";
import { ShieldCheck, UploadCloud, Clock, CheckCircle2, XCircle } from "lucide-react";
import { Button, Input, Badge, cn } from "@saachi/ui";

type VerificationStatus = "not_submitted" | "pending" | "verified" | "rejected";

export default function InstructorVerificationPage() {
  // NOTE: demo-only local state. Replace with useInstructorVerification() once confirmed.
  const [status, setStatus] = useState<VerificationStatus>("not_submitted");
  const [idFileName, setIdFileName] = useState<string | null>(null);
  const [portfolioUrl, setPortfolioUrl] = useState("");
  const [introVideoUrl, setIntroVideoUrl] = useState("");

  function handleIdSelect(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (file) setIdFileName(file.name);
  }

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    // NOTE: demo-only, no backend verification-submission mutation wired up yet.
    setStatus("pending");
  }

  const STATUS_META: Record<VerificationStatus, { label: string; variant?: "gold" | "success" | "error"; icon: typeof Clock }> = {
    not_submitted: { label: "Not submitted", icon: ShieldCheck },
    pending: { label: "Pending review", variant: "gold", icon: Clock },
    verified: { label: "Verified", variant: "success", icon: CheckCircle2 },
    rejected: { label: "Rejected", variant: "error", icon: XCircle }
  };

  const meta = STATUS_META[status];
  const Icon = meta.icon;

  return (
    <div className="mx-auto max-w-lg">
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Verification Status</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Get verified to unlock a lower commission tier and a trust badge.</p>

      <div
        className={cn(
          "mb-8 flex items-center gap-3 rounded-card border p-5",
          status === "verified" ? "border-success/30 bg-success-tint" :
          status === "rejected" ? "border-error/30 bg-error-tint" :
          status === "pending" ? "border-gold-dark/30 bg-gold-tint" :
          "border-line bg-card"
        )}
      >
        <Icon size={22} className="shrink-0 text-ink" />
        <div className="flex-1">
          <p className="text-[14px] font-semibold text-ink">Current status</p>
          {meta.variant ? (
            <Badge variant={meta.variant} className="mt-1">{meta.label}</Badge>
          ) : (
            <Badge className="mt-1">{meta.label}</Badge>
          )}
        </div>
      </div>

      {(status === "not_submitted" || status === "rejected") && (
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <div>
            <p className="mb-2 text-[13px] font-medium text-ink">Government ID or business registration</p>
            <label className="flex cursor-pointer items-center gap-2 rounded-control border border-line px-4 py-3 text-[13px] text-ink-soft hover:border-gold-dark/40">
              <UploadCloud size={16} />
              {idFileName ?? "Upload ID document"}
              <input type="file" accept="image/*,.pdf" className="hidden" onChange={handleIdSelect} required />
            </label>
          </div>

          <Input
            label="Portfolio / proof-of-work link"
            required
            value={portfolioUrl}
            onChange={(e) => setPortfolioUrl(e.target.value)}
            placeholder="GitHub, LinkedIn, or past project samples"
          />

          <Input
            label="Intro video link (optional)"
            value={introVideoUrl}
            onChange={(e) => setIntroVideoUrl(e.target.value)}
            placeholder="A short video introducing yourself"
          />

          <Button type="submit" size="lg" className="self-start" disabled={!idFileName || !portfolioUrl.trim()}>
            Submit for verification
          </Button>
        </form>
      )}

      {status === "pending" && (
        <p className="text-[13px] text-ink-soft">
          Your submission is under review. This typically takes 2-3 business days.
        </p>
      )}
    </div>
  );
}