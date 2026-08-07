"use client";

import { useMemo, useState } from "react";
import { Search, History } from "lucide-react";
import type { ColumnDef } from "@tanstack/react-table";
import { DataTable, Select , RefreshButton , HelpTooltip } from "@saachi/ui";
import { formatDate } from "@saachi/utils";

type AuditEntry = {
  id: string;
  actorName: string;
  actorRole: string;
  action: string;
  target: string;
  module: string;
  createdAt: string;
};

const MODULE_OPTIONS = [
  { label: "Users", value: "users" },
  { label: "Courses", value: "courses" },
  { label: "Finance", value: "finance" },
  { label: "Marketing", value: "marketing" },
  { label: "Settings", value: "settings" }
];

const AUDIT_LOG: AuditEntry[] = [
  { id: "log_1", actorName: "Abdul Rehman Irfan", actorRole: "Super Admin", action: "Approved payout batch", target: "PAYOUT-2026-0912", module: "finance", createdAt: "2026-08-06T14:20:00Z" },
  { id: "log_2", actorName: "Support Desk", actorRole: "Support Officer", action: "Resolved ticket", target: "TCK-4471", module: "users", createdAt: "2026-08-06T11:05:00Z" },
  { id: "log_3", actorName: "Finance Desk", actorRole: "Finance Officer", action: "Approved refund", target: "TXN-88213", module: "finance", createdAt: "2026-08-05T18:42:00Z" },
  { id: "log_4", actorName: "Abdul Rehman Irfan", actorRole: "Super Admin", action: "Updated commission tier", target: "Verified Instructor -> 25%", module: "settings", createdAt: "2026-08-05T09:15:00Z" },
  { id: "log_5", actorName: "Abdul Rehman Irfan", actorRole: "Super Admin", action: "Published homepage banner", target: "Founding Instructor Spots Open", module: "marketing", createdAt: "2026-08-04T16:30:00Z" },
  { id: "log_6", actorName: "Support Desk", actorRole: "Support Officer", action: "Suspended user account", target: "user_9910", module: "users", createdAt: "2026-08-03T10:02:00Z" },
  { id: "log_7", actorName: "Abdul Rehman Irfan", actorRole: "Super Admin", action: "Approved course for publish", target: "AI Automation with n8n", module: "courses", createdAt: "2026-08-02T13:48:00Z" }
];

export default function AuditLogViewerPage() {
  const [search, setSearch] = useState("");
  const [moduleFilter, setModuleFilter] = useState("");

  const filtered = useMemo(() => {
    return AUDIT_LOG.filter((entry) => {
      const matchesSearch =
        !search ||
        entry.actorName.toLowerCase().includes(search.toLowerCase()) ||
        entry.action.toLowerCase().includes(search.toLowerCase()) ||
        entry.target.toLowerCase().includes(search.toLowerCase());
      const matchesModule = !moduleFilter || entry.module === moduleFilter;
      return matchesSearch && matchesModule;
    });
  }, [search, moduleFilter]);

  const columns = useMemo<ColumnDef<AuditEntry, any>[]>(
    () => [
      {
        header: "Actor",
        accessorKey: "actorName",
        cell: ({ row }) => (
          <div>
            <div className="font-medium text-ink">{row.original.actorName}</div>
            <div className="text-[12px] text-ink-soft">{row.original.actorRole}</div>
          </div>
        )
      },
      { header: "Action", accessorKey: "action", cell: ({ getValue }) => <span className="text-ink">{getValue()}</span> },
      { header: "Target", accessorKey: "target", cell: ({ getValue }) => <span className="font-mono text-[12.5px] text-ink-soft">{getValue()}</span> },
      { header: "Module", accessorKey: "module", cell: ({ getValue }) => <span className="capitalize text-ink-soft">{getValue() as string}</span> },
      { header: "Timestamp", accessorKey: "createdAt", cell: ({ getValue }) => <span className="text-ink-soft">{formatDate(getValue() as string)}</span> }
    ],
    []
  );

  return (
    <main className="mx-auto max-w-[1100px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
          <History size={17} strokeWidth={1.75} />
        </div>
        <div>
          <div className="flex items-center gap-1.5"><h1 className="text-[22px] font-semibold text-ink">Audit Log</h1><HelpTooltip text="A searchable, system-wide record of every action taken by internal staff, for accountability and compliance." /></div>
          <p className="mt-0.5 text-[13px] text-ink-soft">Searchable system-wide record of internal staff actions.</p>
        </div>
      </div>
      <div className="mb-3 flex justify-end"><RefreshButton /></div>

      <DataTable
        columns={columns}
        data={filtered}
        isLoading={false}
        emptyTitle="No log entries found"
        emptyDescription="Try adjusting your search or filters."
        toolbar={
          <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
            <div className="relative flex-1">
              <Search size={15} strokeWidth={1.75} className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-ink-soft" />
              <input
                placeholder="Search by actor, action, or target"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="h-10 w-full rounded-control border border-line bg-card pl-9 pr-3 text-[13px] text-ink outline-none placeholder:text-ink-soft/60 focus:border-line-strong"
              />
            </div>
            <div className="sm:w-[180px]">
              <Select placeholder="All modules" options={MODULE_OPTIONS} value={moduleFilter} onChange={(e) => setModuleFilter(e.target.value)} />
            </div>
          </div>
        }
      />
    </main>
  );
}