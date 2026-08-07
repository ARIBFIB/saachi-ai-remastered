"use client";

import { use, useState } from "react";
import Link from "next/link";
import {
  ArrowLeft,
  Ban,
  ShieldAlert,
  ShieldCheck,
  Clock,
  History,
  BookOpen,
  DollarSign
} from "lucide-react";
import {
  useAdminUserDetail,
  useAdminUserActivity,
  useAdminUserAudit,
  useUpdateAdminUserStatus,
  useUpdateAdminUserRole,
  type AdminUserStatus,
  type AdminUserRole
} from "@saachi/api-client";
import { Button, Card, Select, StatusPill, Modal, ShimmerText, Shimmer } from "@saachi/ui";
import { formatDate, formatCurrency } from "@saachi/utils";

const ROLE_OPTIONS = [
  { label: "Learner", value: "learner" },
  { label: "Instructor", value: "instructor" },
  { label: "Corporate", value: "corporate" },
  { label: "Admin", value: "admin" }
];

const STATUS_TONE: Record<AdminUserStatus, "success" | "warning" | "error" | "info"> = {
  active: "success",
  suspended: "warning",
  banned: "error",
  pending: "info"
};

export default function AdminUserDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const { data: user, isLoading } = useAdminUserDetail(id);
  const { data: activity, isLoading: activityLoading } = useAdminUserActivity(id);
  const { data: audit } = useAdminUserAudit(id);
  const updateStatus = useUpdateAdminUserStatus();
  const updateRole = useUpdateAdminUserRole();

  const [confirmAction, setConfirmAction] = useState<AdminUserStatus | null>(null);

  const handleRoleChange = (role: string) => {
    updateRole.mutate({ id, role: role as AdminUserRole });
  };

  const handleConfirm = () => {
    if (!confirmAction) return;
    updateStatus.mutate({ id, status: confirmAction });
    setConfirmAction(null);
  };

  return (
    <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
      <Link href="/users" className="mb-6 inline-flex items-center gap-1.5 text-[13px] text-ink-soft hover:text-ink">
        <ArrowLeft size={14} strokeWidth={1.75} /> Back to users
      </Link>

      {isLoading || !user ? (
        <Card className="p-6">
          <div className="flex items-center gap-4">
            <Shimmer className="h-16 w-16 rounded-full" />
            <div className="flex-1">
              <Shimmer className="mb-2 h-5 w-48" />
              <Shimmer className="h-3.5 w-64" />
            </div>
          </div>
        </Card>
      ) : (
        <>
          <Card className="mb-6 p-6">
            <div className="flex flex-col gap-5 sm:flex-row sm:items-start sm:justify-between">
              <div className="flex items-center gap-4">
                <div className="flex h-16 w-16 shrink-0 items-center justify-center overflow-hidden rounded-full border border-line bg-paper-dim text-[18px] font-semibold text-ink-soft">
                  {user.avatarUrl ? (
                    // eslint-disable-next-line @next/next/no-img-element
                    <img src={user.avatarUrl} alt={user.fullName} className="h-full w-full object-cover" />
                  ) : (
                    user.fullName.charAt(0)
                  )}
                </div>
                <div>
                  <div className="flex items-center gap-2.5">
                    <h1 className="text-[20px] font-semibold text-ink">{user.fullName}</h1>
                    <StatusPill label={user.status} tone={STATUS_TONE[user.status]} />
                  </div>
                  <p className="mt-1 text-[13px] text-ink-soft">{user.email}</p>
                  <p className="mt-0.5 text-[12px] text-ink-soft/70">
                    {user.location ?? "Unknown location"} &middot; Joined {formatDate(user.joinedAt)}
                  </p>
                </div>
              </div>

              <div className="flex shrink-0 gap-2">
                {user.status !== "suspended" && (
                  <Button size="sm" variant="secondary" onClick={() => setConfirmAction("suspended")}>
                    <ShieldAlert size={14} strokeWidth={1.75} /> Suspend
                  </Button>
                )}
                {user.status !== "banned" && (
                  <Button size="sm" variant="danger" onClick={() => setConfirmAction("banned")}>
                    <Ban size={14} strokeWidth={1.75} /> Ban
                  </Button>
                )}
                {user.status !== "active" && (
                  <Button size="sm" onClick={() => setConfirmAction("active")}>
                    <ShieldCheck size={14} strokeWidth={1.75} /> Reinstate
                  </Button>
                )}
              </div>
            </div>

            <div className="mt-6 grid grid-cols-2 gap-4 border-t border-line pt-5 sm:grid-cols-4">
              <div>
                <p className="text-[11px] uppercase tracking-[0.05em] text-ink-soft/60">Role</p>
                <div className="mt-1.5 max-w-[160px]">
                  <Select options={ROLE_OPTIONS} value={user.role} onChange={(e) => handleRoleChange(e.target.value)} />
                </div>
              </div>
              {user.coursesEnrolled !== undefined && (
                <div>
                  <p className="text-[11px] uppercase tracking-[0.05em] text-ink-soft/60">Courses enrolled</p>
                  <p className="mt-1.5 flex items-center gap-1.5 font-mono text-[15px] font-semibold text-ink">
                    <BookOpen size={14} strokeWidth={1.75} className="text-ink-soft" /> {user.coursesEnrolled}
                  </p>
                </div>
              )}
              {user.coursesPublished !== undefined && (
                <div>
                  <p className="text-[11px] uppercase tracking-[0.05em] text-ink-soft/60">Courses published</p>
                  <p className="mt-1.5 flex items-center gap-1.5 font-mono text-[15px] font-semibold text-ink">
                    <BookOpen size={14} strokeWidth={1.75} className="text-ink-soft" /> {user.coursesPublished}
                  </p>
                </div>
              )}
              {(user.totalSpend !== undefined || user.totalEarnings !== undefined) && (
                <div>
                  <p className="text-[11px] uppercase tracking-[0.05em] text-ink-soft/60">
                    {user.totalEarnings !== undefined ? "Total earnings" : "Total spend"}
                  </p>
                  <p className="mt-1.5 flex items-center gap-1.5 font-mono text-[15px] font-semibold text-ink">
                    <DollarSign size={14} strokeWidth={1.75} className="text-ink-soft" />
                    {formatCurrency(user.totalEarnings ?? user.totalSpend ?? 0, "USD")}
                  </p>
                </div>
              )}
              <div>
                <p className="text-[11px] uppercase tracking-[0.05em] text-ink-soft/60">Last active</p>
                <p className="mt-1.5 flex items-center gap-1.5 text-[13px] text-ink">
                  <Clock size={14} strokeWidth={1.75} className="text-ink-soft" /> {formatDate(user.lastActiveAt)}
                </p>
              </div>
            </div>
          </Card>

          <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
            <Card className="p-6">
              <h2 className="mb-4 flex items-center gap-2 text-[14px] font-semibold text-ink">
                <History size={15} strokeWidth={1.75} /> Activity log
              </h2>
              {activityLoading ? (
                <ShimmerText lines={5} />
              ) : (
                <div className="flex flex-col gap-4">
                  {activity?.map((entry) => (
                    <div key={entry.id} className="flex gap-3 border-l-2 border-line pl-3.5">
                      <div className="flex-1">
                        <p className="text-[13px] font-medium text-ink">{entry.action}</p>
                        <p className="mt-0.5 text-[12px] text-ink-soft">{entry.detail}</p>
                        <p className="mt-1 text-[11px] text-ink-soft/60">{formatDate(entry.createdAt)}</p>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </Card>

            <Card className="p-6">
              <h2 className="mb-4 flex items-center gap-2 text-[14px] font-semibold text-ink">
                <ShieldAlert size={15} strokeWidth={1.75} /> Moderation audit trail
              </h2>
              {!audit || audit.length === 0 ? (
                <p className="text-[13px] text-ink-soft">No moderation actions on this account.</p>
              ) : (
                <div className="flex flex-col gap-3">
                  {audit.map((entry) => (
                    <div key={entry.id} className="rounded-control border border-line px-3.5 py-3 text-[12.5px]">
                      <p className="text-ink">
                        <span className="font-semibold">{entry.actor}</span> {entry.action}
                      </p>
                      <p className="mt-1 text-ink-soft/70">
                        {formatDate(entry.createdAt)} &middot; IP {entry.ip}
                      </p>
                    </div>
                  ))}
                </div>
              )}
            </Card>
          </div>
        </>
      )}

      <Modal
        open={Boolean(confirmAction)}
        onClose={() => setConfirmAction(null)}
        title={
          confirmAction === "banned"
            ? "Ban this user?"
            : confirmAction === "suspended"
              ? "Suspend this user?"
              : "Reinstate this user?"
        }
        footer={
          <>
            <Button variant="ghost" onClick={() => setConfirmAction(null)}>
              Cancel
            </Button>
            <Button
              variant={confirmAction === "active" ? "primary" : "danger"}
              onClick={handleConfirm}
              disabled={updateStatus.isPending}
            >
              {updateStatus.isPending ? "Applying..." : "Confirm"}
            </Button>
          </>
        }
      >
        <p className="text-[14px] text-ink-soft">
          {confirmAction === "banned" &&
            "This will permanently restrict the user's access to the platform. This action is logged in the audit trail."}
          {confirmAction === "suspended" &&
            "This will temporarily restrict the user's access. They can be reinstated at any time."}
          {confirmAction === "active" && "This will restore full platform access for this user."}
        </p>
      </Modal>
    </main>
  );
}