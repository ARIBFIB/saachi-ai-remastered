"use client";

import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ArrowLeft, Ban, ShieldOff, ShieldCheck, History } from "lucide-react";
import {
  useAdminUserDetail,
  useUpdateUserStatus,
  useUpdateUserRole,
  type AdminUser
} from "@saachi/api-client";
import { Button, Card, Modal, StatusPill, Select, Shimmer, EmptyState } from "@saachi/ui";
import { formatDate, formatRelativeTime } from "@saachi/utils";

const ROLE_OPTIONS = [
  { label: "Learner", value: "learner" },
  { label: "Instructor", value: "instructor" },
  { label: "Corporate", value: "corporate" },
  { label: "Admin", value: "admin" }
];

const STATUS_TONE: Record<AdminUser["status"], "success" | "warning" | "error" | "info"> = {
  active: "success",
  suspended: "warning",
  banned: "error",
  pending: "info"
};

export default function AdminUserDetailPage() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const { data: user, isLoading } = useAdminUserDetail(params.id);
  const updateStatus = useUpdateUserStatus();
  const updateRole = useUpdateUserRole();

  const [confirmAction, setConfirmAction] = useState<"suspend" | "ban" | "reinstate" | null>(null);

  const handleConfirm = () => {
    if (!confirmAction || !user) return;
    const nextStatus =
      confirmAction === "suspend" ? "suspended" : confirmAction === "ban" ? "banned" : "active";
    updateStatus.mutate({ id: user.id, status: nextStatus });
    setConfirmAction(null);
  };

  if (isLoading) {
    return (
      <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
        <Shimmer className="mb-6 h-8 w-48" />
        <div className="flex flex-col gap-3">
          {Array.from({ length: 4 }).map((_, i) => (
            <Shimmer key={i} className="h-16 w-full rounded-card" />
          ))}
        </div>
      </main>
    );
  }

  if (!user) {
    return (
      <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
        <EmptyState icon={<ShieldOff size={22} strokeWidth={1.75} />} title="User not found" description="This account may have been deleted." />
      </main>
    );
  }

  return (
    <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
      <button
        type="button"
        onClick={() => router.push("/users")}
        className="mb-5 flex items-center gap-1.5 text-[13px] font-medium text-ink-soft hover:text-ink"
      >
        <ArrowLeft size={14} strokeWidth={1.75} /> Back to User Management
      </button>

      <Card className="mb-6 flex flex-col gap-5 p-6 sm:flex-row sm:items-center sm:justify-between">
        <div className="flex items-center gap-4">
          <div className="flex h-14 w-14 shrink-0 items-center justify-center overflow-hidden rounded-full border border-line bg-paper-dim text-[18px] font-semibold text-ink-soft">
            {user.avatarUrl ? (
              // eslint-disable-next-line @next/next/no-img-element
              <img src={user.avatarUrl} alt={user.fullName} className="h-full w-full object-cover" />
            ) : (
              user.fullName.charAt(0)
            )}
          </div>
          <div>
            <div className="flex flex-wrap items-center gap-2.5">
              <h1 className="text-[19px] font-semibold text-ink">{user.fullName}</h1>
              <StatusPill label={user.status} tone={STATUS_TONE[user.status]} />
            </div>
            <p className="mt-0.5 text-[13px] text-ink-soft">{user.email}</p>
            <p className="mt-1 text-[12px] text-ink-soft">
              Joined {formatDate(user.joinedAt)} - Last active {formatRelativeTime(user.lastActiveAt)}
            </p>
          </div>
        </div>

        <div className="flex shrink-0 gap-2">
          {user.status !== "banned" && (
            <>
              {user.status === "active" ? (
                <Button size="sm" variant="secondary" onClick={() => setConfirmAction("suspend")}>
                  <ShieldOff size={14} strokeWidth={1.75} /> Suspend
                </Button>
              ) : (
                <Button size="sm" variant="secondary" onClick={() => setConfirmAction("reinstate")}>
                  <ShieldCheck size={14} strokeWidth={1.75} /> Reinstate
                </Button>
              )}
              <Button size="sm" variant="danger" onClick={() => setConfirmAction("ban")}>
                <Ban size={14} strokeWidth={1.75} /> Ban
              </Button>
            </>
          )}
          {user.status === "banned" && (
            <Button size="sm" variant="secondary" onClick={() => setConfirmAction("reinstate")}>
              <ShieldCheck size={14} strokeWidth={1.75} /> Reinstate
            </Button>
          )}
        </div>
      </Card>

      <div className="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-3">
        <Card className="p-5">
          <p className="text-[12px] text-ink-soft">Role</p>
          <div className="mt-2">
            <Select
              options={ROLE_OPTIONS}
              value={user.role}
              onChange={(e) => updateRole.mutate({ id: user.id, role: e.target.value as AdminUser["role"] })}
            />
          </div>
        </Card>
        <Card className="p-5">
          <p className="text-[12px] text-ink-soft">Location</p>
          <p className="mt-2 text-[15px] font-medium text-ink">{user.location ?? "Unknown"}</p>
        </Card>
        <Card className="p-5">
          <p className="text-[12px] text-ink-soft">Account ID</p>
          <p className="mt-2 font-mono text-[13px] text-ink">{user.id}</p>
        </Card>
      </div>

      <div className="mb-3 flex items-center gap-2">
        <History size={15} strokeWidth={1.75} className="text-ink-soft" />
        <p className="text-[14px] font-semibold text-ink">Activity log</p>
      </div>
      {!user.activityLog || user.activityLog.length === 0 ? (
        <EmptyState icon={<History size={20} strokeWidth={1.75} />} title="No recorded activity" description="Actions on this account will appear here." />
      ) : (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          {user.activityLog.map((entry, i) => (
            <div
              key={entry.id}
              className={`flex flex-col gap-1 px-5 py-3.5 sm:flex-row sm:items-center sm:justify-between ${i > 0 ? "border-t border-line" : ""}`}
            >
              <span className="text-[13px] text-ink">{entry.description}</span>
              <span className="text-[12px] text-ink-soft">{formatRelativeTime(entry.createdAt)}</span>
            </div>
          ))}
        </div>
      )}

      <Modal
        open={Boolean(confirmAction)}
        onClose={() => setConfirmAction(null)}
        title={
          confirmAction === "suspend"
            ? "Suspend this account?"
            : confirmAction === "ban"
              ? "Ban this account?"
              : "Reinstate this account?"
        }
        footer={
          <>
            <Button variant="ghost" onClick={() => setConfirmAction(null)}>
              Cancel
            </Button>
            <Button
              variant={confirmAction === "reinstate" ? "primary" : "danger"}
              onClick={handleConfirm}
              disabled={updateStatus.isPending}
            >
              {updateStatus.isPending ? "Applying..." : "Confirm"}
            </Button>
          </>
        }
      >
        <p className="text-[14px] text-ink-soft">
          {confirmAction === "suspend" &&
            "The user will be temporarily locked out and their courses/listings hidden until reinstated."}
          {confirmAction === "ban" &&
            "This permanently restricts account access. This action is logged in the audit trail."}
          {confirmAction === "reinstate" && "This restores full access to the account."}
        </p>
      </Modal>
    </main>
  );
}