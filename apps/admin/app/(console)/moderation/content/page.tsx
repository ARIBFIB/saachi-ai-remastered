"use client";

import { useState } from "react";
import { ShieldCheck, FileWarning, CheckCircle2, Trash2, ShieldAlert } from "lucide-react";
import { Button, Card, Select, StatusPill, EmptyState, HelpTooltip } from "@saachi/ui";
import { formatRelativeTime } from "@saachi/utils";

type ContentType = "course_description" | "instructor_bio" | "banner_copy" | "certificate_note";
type FlagStatus = "pending" | "removed" | "dismissed" | "warned";

type FlaggedContent = {
  id: string;
  type: ContentType;
  title: string;
  body: string;
  author: string;
  flaggedBy: string;
  flagReason: string;
  status: FlagStatus;
  createdAt: string;
};

const TYPE_LABEL: Record<ContentType, string> = {
  course_description: "Course description",
  instructor_bio: "Instructor bio",
  banner_copy: "Banner copy",
  certificate_note: "Certificate note"
};

const STATUS_OPTIONS = [
  { label: "Pending", value: "pending" },
  { label: "Removed", value: "removed" },
  { label: "Dismissed", value: "dismissed" },
  { label: "Warned", value: "warned" }
];

const STATUS_TONE: Record<FlagStatus, "warning" | "error" | "neutral" | "info"> = {
  pending: "warning",
  removed: "error",
  dismissed: "neutral",
  warned: "info"
};

const INITIAL_CONTENT: FlaggedContent[] = [
  {
    id: "c1",
    type: "course_description",
    title: "AI Automation with n8n",
    body: "This course guarantees you will make $10,000 in your first month using these automation secrets nobody talks about.",
    author: "Zeeshan Tariq",
    flaggedBy: "Automated filter",
    flagReason: "Unverifiable earnings claim",
    status: "pending",
    createdAt: "2026-08-08T08:20:00Z"
  },
  {
    id: "c2",
    type: "instructor_bio",
    title: "Bilal Ahmed - Instructor Bio",
    body: "Ex-Google, ex-Meta, ex-OpenAI senior engineer with 15 years building production AI systems at scale.",
    author: "Bilal Ahmed",
    flaggedBy: "Fatima Noor",
    flagReason: "Unverified employment claims",
    status: "pending",
    createdAt: "2026-08-07T15:10:00Z"
  }
];

export default function ContentModerationPage() {
  const [content, setContent] = useState(INITIAL_CONTENT);
  const [statusFilter, setStatusFilter] = useState("pending");

  const filtered = content.filter((c) => !statusFilter || c.status === statusFilter);

  const resolve = (id: string, status: FlagStatus) => {
    setContent((prev) => prev.map((c) => (c.id === id ? { ...c, status } : c)));
  };

  return (
    <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <ShieldCheck size={17} strokeWidth={1.75} />
          </div>
          <div>
            <div className="flex items-center gap-1.5">
              <h1 className="text-[22px] font-semibold text-ink">Content Moderation</h1>
              <HelpTooltip text="Flagged platform content outside of reviews and forum posts - course descriptions, instructor bios, banner copy, and certificate notes." />
            </div>
            <p className="mt-0.5 text-[13px] text-ink-soft">Miscellaneous platform content flagged for policy review.</p>
          </div>
        </div>
        <div className="w-[180px]">
          <Select placeholder="All statuses" options={STATUS_OPTIONS} value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} />
        </div>
      </div>

      {filtered.length === 0 ? (
        <EmptyState icon={<FileWarning size={22} strokeWidth={1.75} />} title="Nothing flagged" description="No content matches this filter." />
      ) : (
        <div className="flex flex-col gap-4">
          {filtered.map((c) => (
            <Card key={c.id} className="flex flex-col gap-4 p-5">
              <div>
                <div className="flex flex-wrap items-center gap-2.5">
                  <p className="text-[14px] font-semibold text-ink">{c.title}</p>
                  <span className="rounded-full border border-line-strong px-2 py-0.5 text-[11px] text-ink-soft">
                    {TYPE_LABEL[c.type]}
                  </span>
                  <StatusPill label={c.status} tone={STATUS_TONE[c.status]} />
                </div>
                <p className="mt-1 text-[12.5px] text-ink-soft">
                  by {c.author} - {formatRelativeTime(c.createdAt)}
                </p>
              </div>

              <p className="rounded-control border border-line bg-paper-dim p-3.5 text-[13.5px] leading-relaxed text-ink">
                {c.body}
              </p>

              <div className="flex items-center gap-2 text-[12.5px] text-ink-soft">
                <ShieldAlert size={13} strokeWidth={1.75} className="shrink-0 text-error" />
                Flagged by {c.flaggedBy} - reason: {c.flagReason}
              </div>

              {c.status === "pending" && (
                <div className="flex flex-wrap gap-2">
                  <Button size="sm" variant="secondary" onClick={() => resolve(c.id, "dismissed")}>
                    <CheckCircle2 size={14} strokeWidth={1.75} /> Dismiss flag
                  </Button>
                  <Button size="sm" variant="secondary" onClick={() => resolve(c.id, "warned")}>
                    Warn author
                  </Button>
                  <Button size="sm" variant="danger" onClick={() => resolve(c.id, "removed")}>
                    <Trash2 size={14} strokeWidth={1.75} /> Remove content
                  </Button>
                </div>
              )}
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}