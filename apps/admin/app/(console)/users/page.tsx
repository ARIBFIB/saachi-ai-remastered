"use client";

import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { Search, UserCog } from "lucide-react";
import type { ColumnDef } from "@tanstack/react-table";
import { useAdminUserList, type AdminUser } from "@saachi/api-client";
import { DataTable, StatusPill, Select , RefreshButton } from "@saachi/ui";
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

      <div className="admin-clickable-table"><DataTable 
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
      /></div>    </main>
  );
}