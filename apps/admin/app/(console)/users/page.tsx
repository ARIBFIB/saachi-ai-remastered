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