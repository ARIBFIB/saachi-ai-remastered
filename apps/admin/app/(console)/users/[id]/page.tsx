"use client";

import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ArrowLeft, Ban, ShieldCheck, History, Mail, MapPin, Calendar } from "lucide-react";
import { Button, Card, StatusPill, Modal, Select, Textarea, Badge } from "@saachi/ui";
import { formatDate, formatRelativeTime } from "@saachi/utils";

type UserStatus = "active" | "suspended" | "banned" | "pending";
type UserRole = "learner" | "instructor" | "corporate" | "admin";

const STATUS_TONE: Record<UserStatus, "success" | "warning" | "error" | "info"> = {
  active: "success",
  suspended: "warning",
  banned: "error",
  pending: "info"
};

const ROLE_OPTIONS = [
  { label: "Learner", value: "learner" },
  { label: "Instructor", value: "instructor" },
  { label: "Corporate", value: "corporate" },
  { label: "Admin", value: "admin" }
];

// Dummy user record - keyed by the [id] param, falls back to a generic profile.
const DUMMY_USER = {
  fullName: "Fatima Noor",
  email: "fatima.noor@example.com",
  role: "learner" as UserRole,
  status: "active" as UserStatus,
  location: "Lahore, Pakistan",
  joinedAt: "2026-03-14T00:00:00Z",
  lastActiveAt: "2026-08-09T18:20:00Z",
  coursesEnrolled: 6,
  coursesCompleted: 3,
  totalSpent: 214.5
};

const ACTIVITY_LOG = [
  { id: "a1", action: "Purchased \"AI Automation with n8n\"", createdAt: "2026-08-08T02:10:00Z" },
  { id: "a2", action: "Completed \"Prompt Engineering Basics\"", createdAt: "2026-08-05T14:30:00Z" },
  { id: "a3", action: "Left a 5-star review on \"AI Customer Support Bots\"", createdAt: "2026-08-02T11:00:00Z" },
  { id: "a4", action: "Updated profile picture", createdAt: "2026-07-28T09:15:00Z" },
  { id: "a5", action: "Account created", createdAt: "2026-03-14T00:00:00Z" }
];

const AUDIT_TRAIL = [
  { id: "au1", actor: "Support Desk", action: "Reset password on user request", createdAt: "2026-06-01T10:00:00Z" },
  { id: "au2", actor: "System", action: "Email verified", createdAt: "2026-03-14T00:05:00Z" }
];

export default function UserDetailPage() {
  const params = useParams();
  const router = useRouter();
  const userId = params?.id as string;

  const [role, setRole] = useState<UserRole>(DUMMY_USER.role);
  const [status, setStatus] = useState<UserStatus>(DUMMY_USER.status);
  const [showSuspend, setShowSuspend] = useState(false);
  const [showBan, setShowBan] = useState(false);
  const [reason, setReason] = useState("");

  const handleSuspend = () => {
    setStatus("suspended");
    setShowSuspend(false);
    setReason("");
  };

  const handleBan = () => {
    setStatus("banned");
    setShowBan(false);
    setReason("");
  };

  const handleReinstate = () => {
    setStatus("active");
  };

  return (
    <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
      <button
        type="button"
        onClick={() => router.push("/users")}
        className="mb-4 flex items-center gap-1.5 text-[12.5px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:text-ink"
      >
        <ArrowLeft size={14} strokeWidth={1.75} /> Back to users
      </button>

      <Card className="mb-6 flex flex-col gap-5 p-6 sm:flex-row sm:items-start sm:justify-between">
        <div className="flex items-start gap-4">
          <div className="flex h-14 w-14 shrink-0 items-center justify-center rounded-full border border-line bg-paper-dim text-[18px] font-semibold text-ink-soft">
            {DUMMY_USER.fullName.charAt(0)}
          </div>
          <div>
            <div className="flex flex-wrap items-center gap-2.5">
              <h1 className="text-[20px] font-semibold text-ink">{DUMMY_USER.fullName}</h1>
              <StatusPill label={status} tone={STATUS_TONE[status]} />
            </div>
            <p className="mt-1 flex items-center gap-1.5 text-[12.5px] text-ink-soft">
              <Mail size={12} strokeWidth={1.75} /> {DUMMY_USER.email}
            </p>
            <p className="mt-1 flex items-center gap-1.5 text-[12.5px] text-ink-soft">
              <MapPin size={12} strokeWidth={1.75} /> {DUMMY_USER.location}
            </p>
            <p className="mt-1 flex items-center gap-1.5 text-[12.5px] text-ink-soft">
              <Calendar size={12} strokeWidth={1.75} /> Joined {formatDate(DUMMY_USER.joinedAt)} - last active {formatRelativeTime(DUMMY_USER.lastActiveAt)}
            </p>
            <p className="mt-1.5 text-[11px] text-ink-soft/70">User ID: {userId}</p>
          </div>
        </div>

        <div className="flex shrink-0 flex-wrap gap-2">
          {status !== "active" && (
            <Button size="sm" variant="secondary" onClick={handleReinstate}>
              <ShieldCheck size={14} strokeWidth={1.75} /> Reinstate
            </Button>
          )}
          {status === "active" && (
            <Button size="sm" variant="secondary" onClick={() => setShowSuspend(true)}>
              Suspend
            </Button>
          )}
          {status !== "banned" && (
            <Button size="sm" variant="danger" onClick={() => setShowBan(true)}>
              <Ban size={14} strokeWidth={1.75} /> Ban
            </Button>
          )}
        </div>
      </Card>

      <div className="mb-6 grid grid-cols-2 gap-4 lg:grid-cols-4">
        <Card className="p-5">
          <p className="text-[12px] text-ink-soft">Courses enrolled</p>
          <p className="mt-1.5 font-mono text-[20px] font-semibold text-ink">{DUMMY_USER.coursesEnrolled}</p>
        </Card>
        <Card className="p-5">
          <p className="text-[12px] text-ink-soft">Courses completed</p>
          <p className="mt-1.5 font-mono text-[20px] font-semibold text-ink">{DUMMY_USER.coursesCompleted}</p>
        </Card>
        <Card className="p-5">
          <p className="text-[12px] text-ink-soft">Total spent</p>
          <p className="mt-1.5 font-mono text-[20px] font-semibold text-ink">${DUMMY_USER.totalSpent.toFixed(2)}</p>
        </Card>
        <Card className="p-5">
          <div className="mb-1.5 text-[12px] text-ink-soft">Role</div>
          <Select
            options={ROLE_OPTIONS}
            value={role}
            onChange={(e) => setRole(e.target.value as UserRole)}
          />
        </Card>
      </div>

      <div className="mb-6">
        <p className="mb-3 flex items-center gap-1.5 text-[14px] font-semibold text-ink">
          <History size={15} strokeWidth={1.75} /> Activity log
        </p>
        <div className="overflow-hidden rounded-card border border-line bg-card">
          {ACTIVITY_LOG.map((entry, i) => (
            <div key={entry.id} className={`flex items-center justify-between gap-4 px-5 py-3.5 ${i > 0 ? "border-t border-line" : ""}`}>
              <span className="text-[13px] text-ink">{entry.action}</span>
              <span className="shrink-0 text-[12px] text-ink-soft">{formatRelativeTime(entry.createdAt)}</span>
            </div>
          ))}
        </div>
      </div>

      <div>
        <p className="mb-3 text-[14px] font-semibold text-ink">Moderation audit trail</p>
        <div className="overflow-hidden rounded-card border border-line bg-card">
          {AUDIT_TRAIL.map((entry, i) => (
            <div key={entry.id} className={`flex flex-col gap-1 px-5 py-3.5 sm:flex-row sm:items-center sm:justify-between ${i > 0 ? "border-t border-line" : ""}`}>
              <div>
                <span className="text-[13px] text-ink">{entry.action}</span>
                <span className="ml-2 text-[12px] text-ink-soft">by {entry.actor}</span>
              </div>
              <span className="shrink-0 text-[12px] text-ink-soft">{formatDate(entry.createdAt)}</span>
            </div>
          ))}
        </div>
      </div>

      <Modal
        open={showSuspend}
        onClose={() => setShowSuspend(false)}
        title={`Suspend ${DUMMY_USER.fullName}?`}
        footer={
          <>
            <Button variant="ghost" onClick={() => setShowSuspend(false)}>Cancel</Button>
            <Button variant="danger" onClick={handleSuspend} disabled={!reason.trim()}>Suspend account</Button>
          </>
        }
      >
        <Textarea label="Reason for suspension" rows={4} value={reason} onChange={(e) => setReason(e.target.value)} placeholder="This is logged in the audit trail..." />
      </Modal>

      <Modal
        open={showBan}
        onClose={() => setShowBan(false)}
        title={`Ban ${DUMMY_USER.fullName}?`}
        footer={
          <>
            <Button variant="ghost" onClick={() => setShowBan(false)}>Cancel</Button>
            <Button variant="danger" onClick={handleBan} disabled={!reason.trim()}>Ban account</Button>
          </>
        }
      >
        <p className="mb-3 text-[13px] text-ink-soft">This is a more severe action than suspension and will revoke platform access entirely.</p>
        <Textarea label="Reason for ban" rows={4} value={reason} onChange={(e) => setReason(e.target.value)} placeholder="This is logged in the audit trail..." />
      </Modal>
    </main>
  );
}