"use client";

import { useParams, useRouter } from "next/navigation";
import { ArrowLeft, Ban, ShieldCheck, History } from "lucide-react";
import {
  useAdminUserDetail,
  useAdminUserActivity,
  useAdminUserAudit,
  useUpdateUserStatus,
  type AdminUser
} from "@saachi/api-client";
import { Button, Card, StatusPill, Shimmer, EmptyState } from "@saachi/ui";
import { formatDate, formatRelativeTime } from "@saachi/utils";

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
  const { data: activity, isLoading: activityLoading } = useAdminUserActivity(userId);
  const { data: audit, isLoading: auditLoading } = useAdminUserAudit(userId);
  const updateStatus = useUpdateUserStatus();

  if (isLoading) {
    return (
      <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
        <Shimmer className="mb-6 h-8 w-48" />
        <Shimmer className="h-40 w-full rounded-card" />
      </main>
    );
  }

  if (!user) {
    return (
      <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
        <EmptyState title="User not found" description="This account may have been removed." />
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
        <ArrowLeft size={14} strokeWidth={1.75} /> Back to users
      </button>

      <Card className="mb-6 flex flex-col gap-4 p-6 sm:flex-row sm:items-center sm:justify-between">
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
            <p className="mt-0.5 text-[12px] capitalize text-ink-soft">{user.role} - joined {formatDate(user.joinedAt)}</p>
          </div>
        </div>
        <div className="flex shrink-0 gap-2">
          {user.status !== "suspended" && (
            <Button size="sm" variant="secondary" onClick={() => updateStatus.mutate({ id: userId, status: "suspended" })}>
              <Ban size={14} strokeWidth={1.75} /> Suspend
            </Button>
          )}
          {user.status !== "active" && (
            <Button size="sm" onClick={() => updateStatus.mutate({ id: userId, status: "active" })}>
              <ShieldCheck size={14} strokeWidth={1.75} /> Reactivate
            </Button>
          )}
        </div>
      </Card>

      <div className="mb-6">
        <p className="mb-3 text-[14px] font-semibold text-ink">Recent activity</p>
        {activityLoading ? (
          <Shimmer className="h-24 w-full rounded-card" />
        ) : !activity || activity.length === 0 ? (
          <EmptyState title="No activity yet" description="This user has no recorded activity." />
        ) : (
          <Card className="divide-y divide-line p-0">
            {activity.map((item) => (
              <div key={item.id} className="flex items-center justify-between px-5 py-3 text-[13px]">
                <span className="text-ink">{item.description}</span>
                <span className="text-ink-soft">{formatRelativeTime(item.createdAt)}</span>
              </div>
            ))}
          </Card>
        )}
      </div>

      <div>
        <p className="mb-3 flex items-center gap-1.5 text-[14px] font-semibold text-ink">
          <History size={14} strokeWidth={1.75} /> Audit trail
        </p>
        {auditLoading ? (
          <Shimmer className="h-24 w-full rounded-card" />
        ) : !audit || audit.length === 0 ? (
          <EmptyState title="No audit entries" description="No admin actions recorded for this account." />
        ) : (
          <Card className="divide-y divide-line p-0">
            {audit.map((entry) => (
              <div key={entry.id} className="flex items-center justify-between px-5 py-3 text-[13px]">
                <div>
                  <span className="text-ink">{entry.action}</span>
                  <span className="ml-2 text-[12px] text-ink-soft">by {entry.actorName}</span>
                </div>
                <span className="text-ink-soft">{formatDate(entry.createdAt)}</span>
              </div>
            ))}
          </Card>
        )}
      </div>
    </main>
  );
}