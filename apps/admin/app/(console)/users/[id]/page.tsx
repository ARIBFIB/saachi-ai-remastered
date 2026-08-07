"use client";

import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ArrowLeft, ShieldBan, ShieldCheck, History, UserCog } from "lucide-react";
import {
  useAdminUserDetail,
  useSuspendUser,
  useBanUser,
  useReinstateUser,
  useUpdateUserRole,
  type AdminUser
} from "@saachi/api-client";
import { Button, Card, Select, StatusPill, Shimmer, Modal, Textarea, EmptyState } from "@saachi/ui";
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
  const router = useRouter();
  const params = useParams<{ id: string }>();
  const userId = params.id;

  const { data: user, isLoading } = useAdminUserDetail(userId);
  const suspendUser = useSuspendUser();
  const banUser = useBanUser();
  const reinstateUser = useReinstateUser();
  const updateRole = useUpdateUserRole();

  const [role, setRole] = useState<AdminUser["role"] | "">("");
  const [showSuspend, setShowSuspend] = useState(false);
  const [showBan, setShowBan] = useState(false);
  const [reason, setReason] = useState("");

  if (isLoading) {
    return (
      <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
        <Shimmer className="mb-6 h-10 w-40" />
        <div className="flex flex-col gap-4">
          <Shimmer className="h-40 w-full rounded-card" />
          <Shimmer className="h-64 w-full rounded-card" />
        </div>
      </main>
    );
  }

  if (!user) {
    return (
      <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
        <EmptyState icon={<UserCog size={22} strokeWidth={1.75} />} title="User not found" description="This account may have been deleted." />
      </main>
    );
  }

  const currentRole = role || user.role;

  const handleSaveRole = () => {
    if (!role || role === user.role) return;
    updateRole.mutate({ id: user.id, role });
  };

  const handleSuspend = () => {
    suspendUser.mutate({ id: user.id, reason });
    setShowSuspend(false);
    setReason("");
  };

  const handleBan = () => {
    banUser.mutate({ id: user.id, reason });
    setShowBan(false);
    setReason("");
  };

  return (
    <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
      <button
        type="button"
        onClick={() => router.push("/users")}
        className="mb-5 flex items-center gap-1.5 text-[13px] font-medium text-ink-soft hover:text-ink"
      >
        <ArrowLeft size={14} strokeWidth={1.75} /> Back to Users
      </button>

      <Card className="mb-5 flex flex-col gap-5 p-6 sm:flex-row sm:items-center sm:justify-between">
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
            <div className="flex items-center gap-2.5">
              <h1 className="text-[19px] font-semibold text-ink">{user.fullName}</h1>
              <StatusPill label={user.status} tone={STATUS_TONE[user.status]} />
            </div>
            <p className="mt-0.5 text-[13px] text-ink-soft">{user.email}</p>
            <p className="mt-1 text-[12px] text-ink-soft">
              Joined {formatDate(user.joinedAt)} - Last active {formatDate(user.lastActiveAt)} - {user.location ?? "Location unknown"}
            </p>
          </div>
        </div>

        <div className="flex shrink-0 gap-2">
          {user.status === "banned" || user.status === "suspended" ? (
            <Button size="sm" variant="secondary" onClick={() => reinstateUser.mutate(user.id)} disabled={reinstateUser.isPending}>
              <ShieldCheck size={14} strokeWidth={1.75} /> Reinstate
            </Button>
          ) : (
            <>
              <Button size="sm" variant="secondary" onClick={() => setShowSuspend(true)}>
                Suspend
              </Button>
              <Button size="sm" variant="danger" onClick={() => setShowBan(true)}>
                <ShieldBan size={14} strokeWidth={1.75} /> Ban
              </Button>
            </>
          )}
        </div>
      </Card>

      <Card className="mb-5 p-6">
        <p className="mb-4 text-[14px] font-semibold text-ink">Role assignment</p>
        <div className="flex flex-col gap-3 sm:flex-row sm:items-end">
          <div className="sm:w-[240px]">
            <Select
              label="Platform role"
              options={ROLE_OPTIONS}
              value={currentRole}
              onChange={(e) => setRole(e.target.value as AdminUser["role"])}
            />
          </div>
          <Button size="sm" variant="secondary" onClick={handleSaveRole} disabled={!role || role === user.role || updateRole.isPending}>
            {updateRole.isPending ? "Saving..." : "Update role"}
          </Button>
        </div>
      </Card>

      <Card className="p-6">
        <div className="mb-4 flex items-center gap-2">
          <History size={15} strokeWidth={1.75} className="text-ink-soft" />
          <p className="text-[14px] font-semibold text-ink">Activity & audit trail</p>
        </div>
        {!user.activityLog || user.activityLog.length === 0 ? (
          <p className="text-[13px] text-ink-soft">No recorded activity for this account yet.</p>
        ) : (
          <div className="flex flex-col gap-3">
            {user.activityLog.map((entry) => (
              <div key={entry.id} className="flex items-start justify-between gap-3 border-b border-line pb-3 last:border-0 last:pb-0">
                <div>
                  <p className="text-[13px] text-ink">{entry.action}</p>
                  {entry.actorName && <p className="mt-0.5 text-[12px] text-ink-soft">by {entry.actorName}</p>}
                </div>
                <span className="shrink-0 text-[12px] text-ink-soft">{formatRelativeTime(entry.createdAt)}</span>
              </div>
            ))}
          </div>
        )}
      </Card>

      <Modal
        open={showSuspend}
        onClose={() => setShowSuspend(false)}
        title="Suspend account"
        footer={
          <>
            <Button variant="ghost" onClick={() => setShowSuspend(false)}>Cancel</Button>
            <Button variant="danger" onClick={handleSuspend} disabled={!reason.trim() || suspendUser.isPending}>
              {suspendUser.isPending ? "Suspending..." : "Suspend account"}
            </Button>
          </>
        }
      >
        <p className="mb-4 text-[13px] text-ink-soft">
          <span className="font-semibold text-ink">{user.fullName}</span> will temporarily lose access. This can be reversed.
        </p>
        <Textarea label="Reason" placeholder="Why is this account being suspended?" rows={4} value={reason} onChange={(e) => setReason(e.target.value)} />
      </Modal>

      <Modal
        open={showBan}
        onClose={() => setShowBan(false)}
        title="Ban account"
        footer={
          <>
            <Button variant="ghost" onClick={() => setShowBan(false)}>Cancel</Button>
            <Button variant="danger" onClick={handleBan} disabled={!reason.trim() || banUser.isPending}>
              {banUser.isPending ? "Banning..." : "Ban account"}
            </Button>
          </>
        }
      >
        <p className="mb-4 text-[13px] text-ink-soft">
          <span className="font-semibold text-ink">{user.fullName}</span> will permanently lose access to the platform.
        </p>
        <Textarea label="Reason" placeholder="Why is this account being banned?" rows={4} value={reason} onChange={(e) => setReason(e.target.value)} />
      </Modal>
    </main>
  );
}