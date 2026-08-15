"use client";

import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";
import {
  Search,
  UserCog,
  Users,
  GraduationCap,
  Briefcase,
  Building2,
  Download,
  Eye,
  Ban,
  ShieldCheck,
  KeyRound,
  X
} from "lucide-react";
import type { ColumnDef } from "@tanstack/react-table";
import { useAdminUserList, type AdminUser } from "@saachi/api-client";
import {
  DataTable,
  StatusPill,
  Select,
  RefreshButton,
  HelpTooltip,
  Button,
  Card,
  RowActionsMenu,
  type RowAction
} from "@saachi/ui";
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

const STATUS_CYCLE: AdminUser["status"][] = ["active", "suspended", "banned", "pending"];

export default function AdminUsersPage() {
  const router = useRouter();
  const [search, setSearch] = useState("");
  const [role, setRole] = useState("");
  const [status, setStatus] = useState("");
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());
  const [statusPopoverId, setStatusPopoverId] = useState<string | null>(null);
  const [localOverrides, setLocalOverrides] = useState<Record<string, AdminUser["status"]>>({});

  const { data, isLoading } = useAdminUserList({
    search: search || undefined,
    role: role || undefined,
    status: status || undefined
  });

  const rows = useMemo(() => {
    const base = data ?? [];
    return base.map((r) => (localOverrides[r.id] ? { ...r, status: localOverrides[r.id] } : r));
  }, [data, localOverrides]);

  const summary = useMemo(() => {
    return {
      total: rows.length,
      learners: rows.filter((r) => r.role === "learner").length,
      instructors: rows.filter((r) => r.role === "instructor").length,
      corporate: rows.filter((r) => r.role === "corporate").length
    };
  }, [rows]);

  const toggleSelected = (id: string) => {
    setSelectedIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) {
        next.delete(id);
      } else {
        next.add(id);
      }
      return next;
    });
  };

  const toggleSelectAll = () => {
    setSelectedIds((prev) => {
      if (prev.size === rows.length && rows.length > 0) return new Set();
      return new Set(rows.map((r) => r.id));
    });
  };

  const clearSelection = () => setSelectedIds(new Set());

  const setUserStatus = (id: string, newStatus: AdminUser["status"]) => {
    setLocalOverrides((prev) => ({ ...prev, [id]: newStatus }));
    setStatusPopoverId(null);
    toast.success(`Status updated to ${newStatus}`);
  };

  const handleResetPassword = (userRow: AdminUser) => {
    toast.success(`Password reset email sent to ${userRow.email}`);
  };

  const handleBulkSuspend = () => {
    setLocalOverrides((prev) => {
      const next = { ...prev };
      selectedIds.forEach((id) => {
        next[id] = "suspended";
      });
      return next;
    });
    toast.success(`${selectedIds.size} user(s) suspended`);
    clearSelection();
  };

  const handleBulkExport = () => {
    const targetRows = rows.filter((r) => selectedIds.has(r.id));
    const header = ["Name", "Email", "Role", "Status", "Location", "Joined", "Last Active"];
    const csvRows = targetRows.map((r) => [
      r.fullName,
      r.email,
      r.role,
      r.status,
      r.location ?? "",
      formatDate(r.joinedAt),
      formatDate(r.lastActiveAt)
    ]);
    const csv = [header, ...csvRows].map((rowArr) => rowArr.map((v) => `"${String(v).replace(/"/g, '""')}"`).join(",")).join("\n");
    const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = `saachi-users-selected-${new Date().toISOString().slice(0, 10)}.csv`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
  };

  const handleExportAll = () => {
    const targetRows = rows;
    const header = ["Name", "Email", "Role", "Status", "Location", "Joined", "Last Active"];
    const csvRows = targetRows.map((r) => [
      r.fullName,
      r.email,
      r.role,
      r.status,
      r.location ?? "",
      formatDate(r.joinedAt),
      formatDate(r.lastActiveAt)
    ]);
    const csv = [header, ...csvRows].map((rowArr) => rowArr.map((v) => `"${String(v).replace(/"/g, '""')}"`).join(",")).join("\n");
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

  const buildActions = (row: AdminUser): RowAction[] => [
    {
      id: "view",
      label: "View profile",
      icon: <Eye size={13} strokeWidth={1.75} />,
      onClick: () => router.push(`/users/${row.id}`)
    },
    {
      id: "reset",
      label: "Reset password",
      icon: <KeyRound size={13} strokeWidth={1.75} />,
      onClick: () => handleResetPassword(row)
    },
    {
      id: "suspend",
      label: row.status === "suspended" ? "Reinstate" : "Suspend",
      icon: <ShieldCheck size={13} strokeWidth={1.75} />,
      onClick: () => setUserStatus(row.id, row.status === "suspended" ? "active" : "suspended")
    },
    {
      id: "ban",
      label: row.status === "banned" ? "Unban" : "Ban",
      icon: <Ban size={13} strokeWidth={1.75} />,
      tone: "danger",
      onClick: () => setUserStatus(row.id, row.status === "banned" ? "active" : "banned")
    }
  ];

  const columns = useMemo<ColumnDef<AdminUser, any>[]>(
    () => [
      {
        id: "select",
        header: () => (
          <input
            type="checkbox"
            checked={rows.length > 0 && selectedIds.size === rows.length}
            onChange={(e) => {
              e.stopPropagation();
              toggleSelectAll();
            }}
            onClick={(e) => e.stopPropagation()}
            className="h-4 w-4 cursor-pointer rounded border-line-strong accent-[var(--color-ink)]"
          />
        ),
        cell: ({ row }) => (
          <input
            type="checkbox"
            checked={selectedIds.has(row.original.id)}
            onChange={(e) => {
              e.stopPropagation();
              toggleSelected(row.original.id);
            }}
            onClick={(e) => e.stopPropagation()}
            className="h-4 w-4 cursor-pointer rounded border-line-strong accent-[var(--color-ink)]"
          />
        )
      },
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
        cell: ({ row }) => {
          const value = row.original.status;
          const isOpen = statusPopoverId === row.original.id;
          return (
            <div className="relative">
              <button
                type="button"
                onClick={(e) => {
                  e.stopPropagation();
                  setStatusPopoverId(isOpen ? null : row.original.id);
                }}
                className="cursor-pointer"
              >
                <StatusPill label={value} tone={STATUS_TONE[value]} />
              </button>
              {isOpen && (
                <div
                  onClick={(e) => e.stopPropagation()}
                  className="absolute left-0 top-[calc(100%+4px)] z-30 w-[160px] overflow-hidden rounded-card border border-line bg-card shadow-lg"
                >
                  <div className="flex flex-col p-1.5">
                    {STATUS_CYCLE.map((s) => (
                      <button
                        key={s}
                        type="button"
                        onClick={() => setUserStatus(row.original.id, s)}
                        className={`flex items-center justify-between gap-2 rounded-control px-3 py-1.5 text-left text-[12.5px] capitalize transition-colors duration-100 ease-out ${
                          s === value ? "bg-paper-dim text-ink" : "text-ink-soft hover:bg-paper-dim hover:text-ink"
                        }`}
                      >
                        {s}
                      </button>
                    ))}
                  </div>
                </div>
              )}
            </div>
          );
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
      },
      {
        id: "actions",
        header: "",
        cell: ({ row }) => (
          <div className="flex justify-end">
            <RowActionsMenu actions={buildActions(row.original)} ariaLabel={`Actions for ${row.original.fullName}`} />
          </div>
        )
      }
    ],
    [rows, selectedIds, statusPopoverId, buildActions, toggleSelectAll]
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
              <HelpTooltip text="All learners, instructors, and corporate accounts on the platform. Click a row to view full profile, activity, and moderation controls. Use checkboxes to select multiple users for bulk actions." />
            </div>
            <p className="mt-0.5 text-[13px] text-ink-soft">Learners, instructors, and corporate accounts.</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <Button size="sm" variant="secondary" onClick={handleExportAll}>
            <Download size={14} strokeWidth={1.75} /> Export CSV
          </Button>
          <RefreshButton />
        </div>
      </div>

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

      {selectedIds.size > 0 && (
        <div className="sticky top-[70px] z-20 mb-4 flex flex-wrap items-center justify-between gap-3 rounded-control border border-ink bg-ink px-4 py-3 text-paper shadow-lg">
          <span className="text-[13px] font-medium">{selectedIds.size} user(s) selected</span>
          <div className="flex items-center gap-2">
            <Button size="sm" variant="secondary" onClick={handleBulkExport}>
              <Download size={14} strokeWidth={1.75} /> Export selected
            </Button>
            <Button size="sm" variant="danger" onClick={handleBulkSuspend}>
              <ShieldCheck size={14} strokeWidth={1.75} /> Bulk suspend
            </Button>
            <button
              type="button"
              onClick={clearSelection}
              className="flex h-8 w-8 items-center justify-center rounded-control text-paper/80 transition-colors duration-150 ease-out hover:bg-paper/10 hover:text-paper"
              aria-label="Clear selection"
            >
              <X size={15} strokeWidth={1.75} />
            </button>
          </div>
        </div>
      )}

      <div className="admin-clickable-table">
        <DataTable
          columns={columns}
          data={rows}
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
