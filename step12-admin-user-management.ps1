# step12-admin-user-management.ps1
# Run from: SAI2 root folder
# Builds: Admin User Management - list (searchable/filterable DataTable, bulk actions)
# + User Detail (profile, activity log, role assignment, suspend/ban, audit trail).

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $fullPath = Join-Path -Path (Get-Location).Path -ChildPath $Path
    $dir = Split-Path -Parent $fullPath
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($fullPath, $Content, $enc)
    Write-Host "  wrote $fullPath"
}

function Patch-File {
    param([string]$Path, [string]$OldStr, [string]$NewStr, [string]$Label)
    $fullPath = Join-Path -Path (Get-Location).Path -ChildPath $Path
    if (-not (Test-Path $fullPath)) {
        Write-Host "  SKIP (file not found): $fullPath" -ForegroundColor Yellow
        return
    }
    $content = Get-Content -Path $fullPath -Raw
    if ($content.Contains($OldStr)) {
        $updated = $content.Replace($OldStr, $NewStr)
        $enc = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($fullPath, $updated, $enc)
        Write-Host "  patched ($Label): $fullPath"
    } else {
        Write-Host "  WARNING: pattern for '$Label' not found - skipped." -ForegroundColor Yellow
    }
}

Write-Host "Step 12: Admin User Management (list + detail)..." -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. Admin dummy data - users, activity log, audit trail (shared api-client)
# ---------------------------------------------------------------------------
$adminDummyData = @'
export type AdminUserRole = "learner" | "instructor" | "corporate" | "admin";
export type AdminUserStatus = "active" | "suspended" | "banned" | "pending";

export type AdminUser = {
  id: string;
  fullName: string;
  email: string;
  avatarUrl?: string;
  role: AdminUserRole;
  status: AdminUserStatus;
  joinedAt: string;
  lastActiveAt: string;
  coursesEnrolled?: number;
  coursesPublished?: number;
  totalSpend?: number;
  totalEarnings?: number;
  location?: string;
};

export type AdminActivityLogEntry = {
  id: string;
  action: string;
  detail: string;
  createdAt: string;
};

export type AdminAuditLogEntry = {
  id: string;
  actor: string;
  action: string;
  target: string;
  createdAt: string;
  ip: string;
};

function img(seed: string): string {
  return `https://picsum.photos/seed/${encodeURIComponent(seed)}/150/150`;
}

function daysAgo(n: number): string {
  return new Date(Date.now() - n * 24 * 60 * 60 * 1000).toISOString();
}

export const ADMIN_DUMMY_USERS: AdminUser[] = [
  { id: "usr_1001", fullName: "Ayesha Khan", email: "ayesha.khan@example.com", avatarUrl: img("ayesha-khan-instructor"), role: "instructor", status: "active", joinedAt: daysAgo(210), lastActiveAt: daysAgo(0), coursesPublished: 3, totalEarnings: 4620, location: "Lahore, PK" },
  { id: "usr_1002", fullName: "Bilal Ahmed", email: "bilal.ahmed@example.com", avatarUrl: img("bilal-ahmed-instructor"), role: "instructor", status: "active", joinedAt: daysAgo(180), lastActiveAt: daysAgo(1), coursesPublished: 1, totalEarnings: 1450, location: "Karachi, PK" },
  { id: "usr_1003", fullName: "Hina Malik", email: "hina.malik@example.com", avatarUrl: img("hina-malik"), role: "learner", status: "active", joinedAt: daysAgo(95), lastActiveAt: daysAgo(0), coursesEnrolled: 4, totalSpend: 186, location: "Islamabad, PK" },
  { id: "usr_1004", fullName: "Omar Sheikh", email: "omar.sheikh@example.com", avatarUrl: img("omar-sheikh"), role: "learner", status: "active", joinedAt: daysAgo(60), lastActiveAt: daysAgo(3), coursesEnrolled: 2, totalSpend: 78, location: "Rawalpindi, PK" },
  { id: "usr_1005", fullName: "Sana Rizvi", email: "sana.rizvi@example.com", avatarUrl: img("sana-rizvi"), role: "instructor", status: "active", joinedAt: daysAgo(300), lastActiveAt: daysAgo(0), coursesPublished: 4, totalEarnings: 8300, location: "Lahore, PK" },
  { id: "usr_1006", fullName: "Fatima Noor", email: "fatima.noor@example.com", avatarUrl: img("fatima-noor"), role: "learner", status: "suspended", joinedAt: daysAgo(140), lastActiveAt: daysAgo(21), coursesEnrolled: 1, totalSpend: 39, location: "Multan, PK" },
  { id: "usr_1007", fullName: "Usman Ali", email: "usman.ali@example.com", avatarUrl: img("usman-ali"), role: "instructor", status: "pending", joinedAt: daysAgo(5), lastActiveAt: daysAgo(1), coursesPublished: 0, totalEarnings: 0, location: "Faisalabad, PK" },
  { id: "usr_1008", fullName: "Zara Farooq", email: "zara.farooq@example.com", avatarUrl: img("zara-farooq"), role: "instructor", status: "active", joinedAt: daysAgo(260), lastActiveAt: daysAgo(2), coursesPublished: 2, totalEarnings: 3100, location: "Karachi, PK" },
  { id: "usr_1009", fullName: "Danish Raza", email: "danish.raza@example.com", avatarUrl: img("danish-raza"), role: "learner", status: "banned", joinedAt: daysAgo(400), lastActiveAt: daysAgo(90), coursesEnrolled: 6, totalSpend: 340, location: "Lahore, PK" },
  { id: "usr_1010", fullName: "Sara Iqbal", email: "sara.iqbal@example.com", avatarUrl: img("sara-iqbal"), role: "learner", status: "active", joinedAt: daysAgo(30), lastActiveAt: daysAgo(0), coursesEnrolled: 1, totalSpend: 59, location: "Islamabad, PK" },
  { id: "usr_1011", fullName: "Hamza Tariq", email: "hamza.tariq@example.com", avatarUrl: img("hamza-tariq"), role: "instructor", status: "active", joinedAt: daysAgo(150), lastActiveAt: daysAgo(4), coursesPublished: 2, totalEarnings: 2900, location: "Peshawar, PK" },
  { id: "usr_1012", fullName: "Noor Fatima", email: "noor.fatima@example.com", avatarUrl: img("noor-fatima"), role: "learner", status: "active", joinedAt: daysAgo(12), lastActiveAt: daysAgo(0), coursesEnrolled: 3, totalSpend: 124, location: "Islamabad, PK" },
  { id: "usr_1013", fullName: "Acme Agency", email: "billing@acmeagency.com", role: "corporate", status: "active", joinedAt: daysAgo(500), lastActiveAt: daysAgo(2), location: "Lahore, PK" },
  { id: "usr_1014", fullName: "Mahnoor Fatima", email: "mahnoor.f@example.com", avatarUrl: img("mahnoor-fatima"), role: "learner", status: "pending", joinedAt: daysAgo(1), lastActiveAt: daysAgo(1), coursesEnrolled: 0, totalSpend: 0, location: "Quetta, PK" },
  { id: "usr_1015", fullName: "Ali Raza", email: "ali.raza@example.com", avatarUrl: img("ali-raza"), role: "learner", status: "active", joinedAt: daysAgo(80), lastActiveAt: daysAgo(5), coursesEnrolled: 2, totalSpend: 88, location: "Sialkot, PK" }
];

export function getAdminActivityLog(userId: string): AdminActivityLogEntry[] {
  return [
    { id: `${userId}_a1`, action: "Logged in", detail: "Signed in from a new device (Chrome, Windows)", createdAt: daysAgo(0) },
    { id: `${userId}_a2`, action: "Profile updated", detail: "Changed display name and avatar", createdAt: daysAgo(4) },
    { id: `${userId}_a3`, action: "Course enrolled", detail: "Enrolled in \"Prompt Engineering Fundamentals\"", createdAt: daysAgo(10) },
    { id: `${userId}_a4`, action: "Payment completed", detail: "Order ORD-8H2K1 - $29.00 via Stripe", createdAt: daysAgo(10) },
    { id: `${userId}_a5`, action: "Account created", detail: "Registered via email/password", createdAt: daysAgo(95) }
  ];
}

export function getAdminAuditLog(userId: string): AdminAuditLogEntry[] {
  return [
    { id: `${userId}_l1`, actor: "system", action: "flagged for review", target: userId, createdAt: daysAgo(21), ip: "10.4.2.19" },
    { id: `${userId}_l2`, actor: "admin@saachi.ai", action: "sent warning email", target: userId, createdAt: daysAgo(20), ip: "internal" }
  ];
}
'@
Write-Utf8NoBom -Path "packages\api-client\src\dummy-data-admin.ts" -Content $adminDummyData

Patch-File -Path "packages\api-client\src\index.ts" `
  -OldStr 'export * from "./dummy-data";' `
  -NewStr @'
export * from "./dummy-data";
export * from "./dummy-data-admin";
export * from "./hooks/useAdminUsers";
'@ `
  -Label "export admin dummy data + hooks"

# ---------------------------------------------------------------------------
# 2. useAdminUsers hooks - list (client-filtered) + detail + status mutation
# ---------------------------------------------------------------------------
$useAdminUsers = @'
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  ADMIN_DUMMY_USERS,
  getAdminActivityLog,
  getAdminAuditLog,
  type AdminUser,
  type AdminUserStatus
} from "../dummy-data-admin";

function delay<T>(value: T, ms = 350): Promise<T> {
  return new Promise((resolve) => setTimeout(() => resolve(value), ms));
}

// NOTE: demo-only, in-memory. Replace with real Admin-Users API (Doc 3) once available.
let USERS_STATE: AdminUser[] = [...ADMIN_DUMMY_USERS];

export const adminUserKeys = {
  all: ["admin", "users"] as const,
  list: (filters?: Record<string, unknown>) => ["admin", "users", "list", filters] as const,
  detail: (id: string) => ["admin", "users", "detail", id] as const,
  activity: (id: string) => ["admin", "users", "activity", id] as const,
  audit: (id: string) => ["admin", "users", "audit", id] as const
};

export type AdminUserListFilters = {
  search?: string;
  role?: string;
  status?: string;
};

export function useAdminUserList(filters: AdminUserListFilters = {}) {
  return useQuery({
    queryKey: adminUserKeys.list(filters),
    queryFn: async () => {
      let items = [...USERS_STATE];
      if (filters.search) {
        const q = filters.search.toLowerCase();
        items = items.filter((u) => u.fullName.toLowerCase().includes(q) || u.email.toLowerCase().includes(q));
      }
      if (filters.role) items = items.filter((u) => u.role === filters.role);
      if (filters.status) items = items.filter((u) => u.status === filters.status);
      return delay(items);
    }
  });
}

export function useAdminUserDetail(id: string) {
  return useQuery({
    queryKey: adminUserKeys.detail(id),
    queryFn: async () => {
      const found = USERS_STATE.find((u) => u.id === id);
      if (!found) throw new Error("User not found");
      return delay(found);
    },
    enabled: Boolean(id)
  });
}

export function useAdminUserActivity(id: string) {
  return useQuery({
    queryKey: adminUserKeys.activity(id),
    queryFn: async () => delay(getAdminActivityLog(id)),
    enabled: Boolean(id)
  });
}

export function useAdminUserAudit(id: string) {
  return useQuery({
    queryKey: adminUserKeys.audit(id),
    queryFn: async () => delay(getAdminAuditLog(id)),
    enabled: Boolean(id)
  });
}

export function useUpdateAdminUserStatus() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, status }: { id: string; status: AdminUserStatus }) => {
      USERS_STATE = USERS_STATE.map((u) => (u.id === id ? { ...u, status } : u));
      return delay({ id, status }, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminUserKeys.all });
    }
  });
}

export function useUpdateAdminUserRole() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, role }: { id: string; role: AdminUser["role"] }) => {
      USERS_STATE = USERS_STATE.map((u) => (u.id === id ? { ...u, role } : u));
      return delay({ id, role }, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminUserKeys.all });
    }
  });
}
'@
Write-Utf8NoBom -Path "packages\api-client\src\hooks\useAdminUsers.ts" -Content $useAdminUsers

# ---------------------------------------------------------------------------
# 3. Users list page - search, role/status filters, DataTable, row -> detail
# ---------------------------------------------------------------------------
$usersListPage = @'
"use client";

import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { Search, UserCog } from "lucide-react";
import type { ColumnDef } from "@tanstack/react-table";
import { useAdminUserList, type AdminUser } from "@saachi/api-client";
import { DataTable, StatusPill, Select } from "@saachi/ui";
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
      <div className="mb-6 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
          <UserCog size={17} strokeWidth={1.75} />
        </div>
        <div>
          <h1 className="text-[22px] font-semibold text-ink">User Management</h1>
          <p className="mt-0.5 text-[13px] text-ink-soft">Learners, instructors, and corporate accounts.</p>
        </div>
      </div>

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
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\admin\app\(console)\users\page.tsx" -Content $usersListPage

# ---------------------------------------------------------------------------
# 4. User detail page - profile, activity log, role assignment, suspend/ban,
#    audit trail. Confirm modal on destructive actions.
# ---------------------------------------------------------------------------
$userDetailPage = @'
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
'@
Write-Utf8NoBom -Path "apps\admin\app\(console)\users\[id]\page.tsx" -Content $userDetailPage

Write-Host ""
Write-Host "Step 12 done." -ForegroundColor Green
Write-Host "Run: pnpm install" -ForegroundColor Yellow
Write-Host "Then: pnpm dev:admin" -ForegroundColor Green
Write-Host ""
Write-Host "What this step built:" -ForegroundColor Cyan
Write-Host "  - Admin dummy data: 15 seeded users (learners/instructors/corporate), activity log, audit trail"
Write-Host "  - useAdminUsers hooks: list (search/role/status filters), detail, activity, audit, status + role mutations"
Write-Host "  - /users - searchable/filterable DataTable (shimmer while loading, click row -> detail)"
Write-Host "  - /users/[id] - profile card, role assignment dropdown, suspend/ban/reinstate with confirm modal,"
Write-Host "    activity log timeline, moderation audit trail"
Write-Host ""
Write-Host "Next: Step 13 - Course Moderation Queue + Catalog + Categories/Tags" -ForegroundColor Cyan