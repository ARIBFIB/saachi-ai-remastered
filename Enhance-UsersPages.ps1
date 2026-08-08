# ============================================================
# Enhance-UsersPages.ps1
# 1) Enhances Users list page with report-style summary cards
# 2) Creates the missing User Detail page with edit capability
# ============================================================

$listPath = "apps\admin\app\(console)\users\page.tsx"
$detailDir = "apps\admin\app\(console)\users\[id]"
$detailPath = "$detailDir\page.tsx"

if (-not (Test-Path $detailDir)) {
    New-Item -ItemType Directory -Path $detailDir -Force | Out-Null
}

# ------------------------------------------------------------
# 1) Users List Page - report-style summary cards + export
# ------------------------------------------------------------
$listContent = @'
"use client";

import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { Search, UserCog, Users, GraduationCap, Briefcase, Building2, Download } from "lucide-react";
import type { ColumnDef } from "@tanstack/react-table";
import { useAdminUserList, type AdminUser } from "@saachi/api-client";
import { DataTable, StatusPill, Select, RefreshButton, HelpTooltip, Button, Card } from "@saachi/ui";
import { formatDate } from "@saachi/utils";

const ROLE_OPTIONS = [
  { label: "Learner", value: "learner" },
  { label: "Instructor", value: "instructor" },
  { label: "Corporate", value: "corporate" },
  { label: "Admin", value: "admin" }
];

const STATUS_OPTIONS = [
  { label: "Active", value: "active" },
  { label: "Suspended", value: "suspended" },
  { label: "Banned", value: "banned" },
  { label: "Pending", value: "pending" }
];

const STATUS_TONE: Record<AdminUser["status"], "success" | "warning" | "error" | "info"> = {
  active: "success",
  suspended: "warning",
  banned: "error",
  pending: "info"
};

export default function AdminUsersPage() {
  const router = useRouter();
  const [search, setSearch] = useState("");
  const [role, setRole] = useState("");
  const [status, setStatus] = useState("");

  const { data, isLoading } = useAdminUserList({
    search: search || undefined,
    role: role || undefined,
    status: status || undefined
  });

  const summary = useMemo(() => {
    const rows = data ?? [];
    return {
      total: rows.length,
      learners: rows.filter((r) => r.role === "learner").length,
      instructors: rows.filter((r) => r.role === "instructor").length,
      corporate: rows.filter((r) => r.role === "corporate").length
    };
  }, [data]);

  const handleExport = () => {
    const rows = data ?? [];
    const header = ["Name", "Email", "Role", "Status", "Location", "Joined", "Last Active"];
    const csvRows = rows.map((r) => [
      r.fullName,
      r.email,
      r.role,
      r.status,
      r.location ?? "",
      formatDate(r.joinedAt),
      formatDate(r.lastActiveAt)
    ]);
    const csv = [header, ...csvRows].map((row) => row.map((v) => `"${String(v).replace(/"/g, '""')}"`).join(",")).join("\n");
    const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = `saachi-users-${new Date().toISOString().slice(0, 10)}.csv`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
  };

  const columns = useMemo<ColumnDef<AdminUser, any>[]>(
    () => [
      {
        header: "Name",
        accessorKey: "fullName",
        cell: ({ row }) => (
          <div className="flex items-center gap-3">
            <div className="flex h-8 w-8 shrink-0 items-center justify-center overflow-hidden rounded-full border border-line bg-paper-dim text-[12px] font-semibold text-ink-soft">
              {row.original.avatarUrl ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={row.original.avatarUrl} alt={row.original.fullName} className="h-full w-full object-cover" />
              ) : (
                row.original.fullName.charAt(0)
              )}
            </div>
            <div>
              <div className="font-medium text-ink">{row.original.fullName}</div>
              <div className="text-[12px] text-ink-soft">{row.original.email}</div>
            </div>
          </div>
        )
      },
      {
        header: "Role",
        accessorKey: "role",
        cell: ({ getValue }) => <span className="capitalize text-ink-soft">{getValue()}</span>
      },
      {
        header: "Status",
        accessorKey: "status",
        cell: ({ getValue }) => {
          const value = getValue() as AdminUser["status"];
          return <StatusPill label={value} tone={STATUS_TONE[value]} />;
        }
      },
      {
        header: "Location",
        accessorKey: "location",
        cell: ({ getValue }) => <span className="text-ink-soft">{getValue() ?? "-"}</span>
      },
      {
        header: "Joined",
        accessorKey: "joinedAt",
        cell: ({ getValue }) => <span className="text-ink-soft">{formatDate(getValue() as string)}</span>
      },
      {
        header: "Last active",
        accessorKey: "lastActiveAt",
        cell: ({ getValue }) => <span className="text-ink-soft">{formatDate(getValue() as string)}</span>
      }
    ],
    []
  );

  return (
    <main className="mx-auto max-w-[1200px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <UserCog size={17} strokeWidth={1.75} />
          </div>
          <div>
            <div className="flex items-center gap-1.5">
              <h1 className="text-[22px] font-semibold text-ink">User Management</h1>
              <HelpTooltip text="All learners, instructors, and corporate accounts on the platform. Click a row to view full profile, activity, and moderation controls." />
            </div>
            <p className="mt-0.5 text-[13px] text-ink-soft">Learners, instructors, and corporate accounts.</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <Button size="sm" variant="secondary" onClick={handleExport}>
            <Download size={14} strokeWidth={1.75} /> Export CSV
          </Button>
          <RefreshButton />
        </div>
      </div>

      {/* Report-style summary cards */}
      <div className="mb-6 grid grid-cols-2 gap-4 lg:grid-cols-4">
        <Card className="p-5">
          <div className="flex items-center gap-2 text-[12px] text-ink-soft">
            <Users size={13} strokeWidth={1.75} /> Total users
          </div>
          <p className="mt-1.5 font-mono text-[22px] font-semibold text-ink">{summary.total}</p>
        </Card>
        <Card className="p-5">
          <div className="flex items-center gap-2 text-[12px] text-ink-soft">
            <GraduationCap size={13} strokeWidth={1.75} /> Learners
          </div>
          <p className="mt-1.5 font-mono text-[22px] font-semibold text-ink">{summary.learners}</p>
        </Card>
        <Card className="p-5">
          <div className="flex items-center gap-2 text-[12px] text-ink-soft">
            <Briefcase size={13} strokeWidth={1.75} /> Instructors
          </div>
          <p className="mt-1.5 font-mono text-[22px] font-semibold text-ink">{summary.instructors}</p>
        </Card>
        <Card className="p-5">
          <div className="flex items-center gap-2 text-[12px] text-ink-soft">
            <Building2 size={13} strokeWidth={1.75} /> Corporate
          </div>
          <p className="mt-1.5 font-mono text-[22px] font-semibold text-ink">{summary.corporate}</p>
        </Card>
      </div>

      <div className="admin-clickable-table">
        <DataTable
          columns={columns}
          data={data ?? []}
          isLoading={isLoading}
          emptyTitle="No users found"
          emptyDescription="Try adjusting your search or filters."
          onRowClick={(row) => router.push(`/users/${row.id}`)}
          toolbar={
            <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
              <div className="relative flex-1">
                <Search size={15} strokeWidth={1.75} className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-ink-soft" />
                <input
                  placeholder="Search by name or email"
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  className="h-10 w-full rounded-control border border-line bg-card pl-9 pr-3 text-[13px] text-ink outline-none placeholder:text-ink-soft/60 focus:border-line-strong"
                />
              </div>
              <div className="sm:w-[180px]">
                <Select placeholder="All roles" options={ROLE_OPTIONS} value={role} onChange={(e) => setRole(e.target.value)} />
              </div>
              <div className="sm:w-[180px]">
                <Select placeholder="All statuses" options={STATUS_OPTIONS} value={status} onChange={(e) => setStatus(e.target.value)} />
              </div>
            </div>
          }
        />
      </div>
    </main>
  );
}
'@

Set-Content -LiteralPath $listPath -Value $listContent -NoNewline
Write-Host "[OK] Users list page enhanced with report-style summary cards + CSV export." -ForegroundColor Green

# ------------------------------------------------------------
# 2) User Detail Page - editable profile
# ------------------------------------------------------------
$detailContent = @'
"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { toast } from "sonner";
import {
  ArrowLeft,
  Pencil,
  Save,
  X,
  Mail,
  MapPin,
  Calendar,
  Clock,
  ShieldAlert,
  Ban,
  CheckCircle2,
  History
} from "lucide-react";
import { Button, Card, Input, Select, StatusPill, Modal, Textarea, ShimmerKpiCard } from "@saachi/ui";
import { formatDate, formatRelativeTime } from "@saachi/utils";

type UserRole = "learner" | "instructor" | "corporate" | "admin";
type UserStatus = "active" | "suspended" | "banned" | "pending";

type UserDetail = {
  id: string;
  fullName: string;
  email: string;
  role: UserRole;
  status: UserStatus;
  location: string;
  joinedAt: string;
  lastActiveAt: string;
  coursesEnrolled: number;
  coursesPublished: number;
  totalSpent: number;
  notes: string;
};

const ROLE_OPTIONS = [
  { label: "Learner", value: "learner" },
  { label: "Instructor", value: "instructor" },
  { label: "Corporate", value: "corporate" },
  { label: "Admin", value: "admin" }
];

const STATUS_OPTIONS = [
  { label: "Active", value: "active" },
  { label: "Suspended", value: "suspended" },
  { label: "Banned", value: "banned" },
  { label: "Pending", value: "pending" }
];

const STATUS_TONE: Record<UserStatus, "success" | "warning" | "error" | "info"> = {
  active: "success",
  suspended: "warning",
  banned: "error",
  pending: "info"
};

const MOCK_ACTIVITY = [
  { id: "a1", label: "Logged in", createdAt: "2026-08-08T06:10:00Z" },
  { id: "a2", label: "Enrolled in \"AI Automation with n8n\"", createdAt: "2026-08-06T14:22:00Z" },
  { id: "a3", label: "Updated profile information", createdAt: "2026-08-02T09:15:00Z" },
  { id: "a4", label: "Account created", createdAt: "2026-06-14T11:00:00Z" }
];

function buildMockUser(id: string): UserDetail {
  return {
    id,
    fullName: "Fatima Noor",
    email: "fatima.noor@example.com",
    role: "learner",
    status: "active",
    location: "Lahore, Pakistan",
    joinedAt: "2026-06-14T11:00:00Z",
    lastActiveAt: "2026-08-08T06:10:00Z",
    coursesEnrolled: 6,
    coursesPublished: 0,
    totalSpent: 214,
    notes: ""
  };
}

export default function UserDetailPage() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const userId = params?.id ?? "";

  const [isLoading, setIsLoading] = useState(true);
  const [user, setUser] = useState<UserDetail | null>(null);
  const [isEditing, setIsEditing] = useState(false);
  const [draft, setDraft] = useState<UserDetail | null>(null);
  const [saving, setSaving] = useState(false);
  const [suspendModalOpen, setSuspendModalOpen] = useState(false);
  const [banModalOpen, setBanModalOpen] = useState(false);

  useEffect(() => {
    const t = setTimeout(() => {
      const mock = buildMockUser(userId);
      setUser(mock);
      setDraft(mock);
      setIsLoading(false);
    }, 500);
    return () => clearTimeout(t);
  }, [userId]);

  const startEdit = () => {
    setDraft(user);
    setIsEditing(true);
  };

  const cancelEdit = () => {
    setDraft(user);
    setIsEditing(false);
  };

  const handleSave = () => {
    if (!draft) return;
    setSaving(true);
    setTimeout(() => {
      setUser(draft);
      setSaving(false);
      setIsEditing(false);
      toast.success("Profile updated", { description: "Changes have been saved successfully." });
    }, 600);
  };

  const handleSuspend = () => {
    if (!user) return;
    const updated = { ...user, status: "suspended" as UserStatus };
    setUser(updated);
    setDraft(updated);
    setSuspendModalOpen(false);
    toast.success("User suspended", { description: `${user.fullName} can no longer log in until reactivated.` });
  };

  const handleBan = () => {
    if (!user) return;
    const updated = { ...user, status: "banned" as UserStatus };
    setUser(updated);
    setDraft(updated);
    setBanModalOpen(false);
    toast.success("User banned", { description: `${user.fullName} has been permanently banned from the platform.` });
  };

  const handleReactivate = () => {
    if (!user) return;
    const updated = { ...user, status: "active" as UserStatus };
    setUser(updated);
    setDraft(updated);
    toast.success("User reactivated", { description: `${user.fullName} can log in again.` });
  };

  if (isLoading || !user || !draft) {
    return (
      <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
        <div className="mb-6 flex flex-col gap-3">
          {Array.from({ length: 4 }).map((_, i) => (
            <ShimmerKpiCard key={i} />
          ))}
        </div>
      </main>
    );
  }

  return (
    <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
      <button
        type="button"
        onClick={() => router.push("/users")}
        className="mb-4 flex items-center gap-1.5 text-[12.5px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:text-ink"
      >
        <ArrowLeft size={14} strokeWidth={1.75} /> Back to Users
      </button>

      {/* Header card */}
      <Card className="mb-6 flex flex-col gap-5 p-6 sm:flex-row sm:items-start sm:justify-between">
        <div className="flex items-start gap-4">
          <div className="flex h-14 w-14 shrink-0 items-center justify-center rounded-full border border-line bg-paper-dim text-[18px] font-semibold text-ink-soft">
            {user.fullName.charAt(0)}
          </div>
          <div>
            <div className="flex flex-wrap items-center gap-2.5">
              <h1 className="text-[19px] font-semibold text-ink">{user.fullName}</h1>
              <StatusPill label={user.status} tone={STATUS_TONE[user.status]} />
            </div>
            <div className="mt-2 flex flex-wrap items-center gap-x-4 gap-y-1 text-[12.5px] text-ink-soft">
              <span className="flex items-center gap-1.5">
                <Mail size={13} strokeWidth={1.75} /> {user.email}
              </span>
              <span className="flex items-center gap-1.5">
                <MapPin size={13} strokeWidth={1.75} /> {user.location}
              </span>
              <span className="flex items-center gap-1.5">
                <Calendar size={13} strokeWidth={1.75} /> Joined {formatDate(user.joinedAt)}
              </span>
              <span className="flex items-center gap-1.5">
                <Clock size={13} strokeWidth={1.75} /> Active {formatRelativeTime(user.lastActiveAt)}
              </span>
            </div>
          </div>
        </div>

        <div className="flex shrink-0 flex-wrap gap-2">
          {!isEditing ? (
            <Button size="sm" variant="secondary" onClick={startEdit}>
              <Pencil size={14} strokeWidth={1.75} /> Edit profile
            </Button>
          ) : (
            <>
              <Button size="sm" variant="ghost" onClick={cancelEdit} disabled={saving}>
                <X size={14} strokeWidth={1.75} /> Cancel
              </Button>
              <Button size="sm" onClick={handleSave} disabled={saving}>
                <Save size={14} strokeWidth={1.75} /> {saving ? "Saving..." : "Save changes"}
              </Button>
            </>
          )}
        </div>
      </Card>

      {/* Report-style stat cards */}
      <div className="mb-6 grid grid-cols-3 gap-4">
        <Card className="p-5">
          <p className="text-[12px] text-ink-soft">Courses enrolled</p>
          <p className="mt-1 font-mono text-[20px] font-semibold text-ink">{user.coursesEnrolled}</p>
        </Card>
        <Card className="p-5">
          <p className="text-[12px] text-ink-soft">Courses published</p>
          <p className="mt-1 font-mono text-[20px] font-semibold text-ink">{user.coursesPublished}</p>
        </Card>
        <Card className="p-5">
          <p className="text-[12px] text-ink-soft">Total spent</p>
          <p className="mt-1 font-mono text-[20px] font-semibold text-ink">${user.totalSpent}</p>
        </Card>
      </div>

      {/* Editable profile fields */}
      <Card className="mb-6 p-6">
        <p className="mb-4 text-[14px] font-semibold text-ink">Profile details</p>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <Input
            label="Full name"
            value={draft.fullName}
            disabled={!isEditing}
            onChange={(e) => setDraft({ ...draft, fullName: e.target.value })}
          />
          <Input
            label="Email"
            type="email"
            value={draft.email}
            disabled={!isEditing}
            onChange={(e) => setDraft({ ...draft, email: e.target.value })}
          />
          <Select
            label="Role"
            options={ROLE_OPTIONS}
            value={draft.role}
            onChange={(e) => setDraft({ ...draft, role: e.target.value as UserRole })}
          />
          <Select
            label="Status"
            options={STATUS_OPTIONS}
            value={draft.status}
            onChange={(e) => setDraft({ ...draft, status: e.target.value as UserStatus })}
          />
          <Input
            label="Location"
            value={draft.location}
            disabled={!isEditing}
            onChange={(e) => setDraft({ ...draft, location: e.target.value })}
          />
        </div>
        <div className="mt-4">
          <Textarea
            label="Internal notes"
            placeholder="Add internal notes about this user (not visible to them)..."
            rows={3}
            value={draft.notes}
            disabled={!isEditing}
            onChange={(e) => setDraft({ ...draft, notes: e.target.value })}
          />
        </div>
      </Card>

      {/* Moderation actions */}
      <Card className="mb-6 p-6">
        <p className="mb-4 text-[14px] font-semibold text-ink">Account actions</p>
        <div className="flex flex-wrap gap-2">
          {user.status !== "active" && (
            <Button size="sm" variant="secondary" onClick={handleReactivate}>
              <CheckCircle2 size={14} strokeWidth={1.75} /> Reactivate account
            </Button>
          )}
          {user.status !== "suspended" && user.status !== "banned" && (
            <Button size="sm" variant="secondary" onClick={() => setSuspendModalOpen(true)}>
              <ShieldAlert size={14} strokeWidth={1.75} /> Suspend account
            </Button>
          )}
          {user.status !== "banned" && (
            <Button size="sm" variant="danger" onClick={() => setBanModalOpen(true)}>
              <Ban size={14} strokeWidth={1.75} /> Ban account
            </Button>
          )}
        </div>
      </Card>

      {/* Activity log */}
      <Card className="p-6">
        <div className="mb-4 flex items-center gap-2">
          <History size={15} strokeWidth={1.75} className="text-ink" />
          <p className="text-[14px] font-semibold text-ink">Activity log</p>
        </div>
        <div className="flex flex-col gap-3">
          {MOCK_ACTIVITY.map((a) => (
            <div key={a.id} className="flex items-center justify-between gap-3 border-b border-line pb-3 last:border-0 last:pb-0">
              <span className="text-[13px] text-ink">{a.label}</span>
              <span className="shrink-0 text-[12px] text-ink-soft">{formatRelativeTime(a.createdAt)}</span>
            </div>
          ))}
        </div>
      </Card>

      <Modal
        open={suspendModalOpen}
        onClose={() => setSuspendModalOpen(false)}
        title="Suspend this account?"
        footer={
          <>
            <Button variant="ghost" onClick={() => setSuspendModalOpen(false)}>
              Cancel
            </Button>
            <Button variant="danger" onClick={handleSuspend}>
              Suspend account
            </Button>
          </>
        }
      >
        <p className="text-[14px] text-ink-soft">
          <span className="font-semibold text-ink">{user.fullName}</span> will be temporarily unable to log in. You
          can reactivate their account at any time.
        </p>
      </Modal>

      <Modal
        open={banModalOpen}
        onClose={() => setBanModalOpen(false)}
        title="Ban this account?"
        footer={
          <>
            <Button variant="ghost" onClick={() => setBanModalOpen(false)}>
              Cancel
            </Button>
            <Button variant="danger" onClick={handleBan}>
              Ban account
            </Button>
          </>
        }
      >
        <p className="text-[14px] text-ink-soft">
          This is a more severe action than suspension. <span className="font-semibold text-ink">{user.fullName}</span>{" "}
          will be permanently banned from the platform unless manually reactivated by a Super Admin.
        </p>
      </Modal>
    </main>
  );
}
'@

Set-Content -LiteralPath $detailPath -Value $detailContent -NoNewline
Write-Host "[OK] User Detail page created with full edit capability at apps\admin\app\(console)\users\[id]\page.tsx" -ForegroundColor Green

Write-Host ""
Write-Host "Done." -ForegroundColor Cyan