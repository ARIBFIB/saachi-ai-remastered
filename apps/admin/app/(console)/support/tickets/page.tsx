"use client";

import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { Search, LifeBuoy, AlertTriangle } from "lucide-react";
import type { ColumnDef } from "@tanstack/react-table";
import { useAdminTickets, type SupportTicket } from "@saachi/api-client";
import { DataTable, StatusPill, Select , RefreshButton , HelpTooltip } from "@saachi/ui";
import { formatRelativeTime } from "@saachi/utils";

const STATUS_OPTIONS = [
  { label: "Open", value: "open" },
  { label: "In progress", value: "in_progress" },
  { label: "Resolved", value: "resolved" },
  { label: "Closed", value: "closed" }
];

const PRIORITY_OPTIONS = [
  { label: "Low", value: "low" },
  { label: "Medium", value: "medium" },
  { label: "High", value: "high" },
  { label: "Urgent", value: "urgent" }
];

const STATUS_TONE: Record<SupportTicket["status"], "warning" | "info" | "success" | "neutral"> = {
  open: "warning",
  in_progress: "info",
  resolved: "success",
  closed: "neutral"
};

const PRIORITY_TONE: Record<SupportTicket["priority"], "neutral" | "info" | "warning" | "error"> = {
  low: "neutral",
  medium: "info",
  high: "warning",
  urgent: "error"
};

export default function SupportTicketQueuePage() {
  const router = useRouter();
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("");
  const [priority, setPriority] = useState("");

  const { data, isLoading } = useAdminTickets({
    search: search || undefined,
    status: status || undefined,
    priority: priority || undefined
  });

  const columns = useMemo<ColumnDef<SupportTicket, any>[]>(
    () => [
      {
        header: "Subject",
        accessorKey: "subject",
        cell: ({ row }) => (
          <div className="max-w-[280px]">
            <div className="truncate font-medium text-ink">{row.original.subject}</div>
            <div className="text-[12px] text-ink-soft">{row.original.requesterName} - {row.original.category}</div>
          </div>
        )
      },
      {
        header: "Priority",
        accessorKey: "priority",
        cell: ({ getValue }) => {
          const value = getValue() as SupportTicket["priority"];
          return <StatusPill label={value} tone={PRIORITY_TONE[value]} />;
        }
      },
      {
        header: "Status",
        accessorKey: "status",
        cell: ({ getValue }) => {
          const value = getValue() as SupportTicket["status"];
          return <StatusPill label={value.replace("_", " ")} tone={STATUS_TONE[value]} />;
        }
      },
      {
        header: "Assigned to",
        accessorKey: "assignedTo",
        cell: ({ getValue }) => <span className="text-ink-soft">{(getValue() as string) ?? "Unassigned"}</span>
      },
      {
        header: "SLA",
        accessorKey: "slaDueAt",
        cell: ({ row }) => {
          const overdue = new Date(row.original.slaDueAt).getTime() < Date.now() && row.original.status !== "resolved" && row.original.status !== "closed";
          return overdue ? (
            <span className="flex items-center gap-1.5 font-medium text-error">
              <AlertTriangle size={13} strokeWidth={1.75} /> Overdue
            </span>
          ) : (
            <span className="text-ink-soft">{formatRelativeTime(row.original.slaDueAt)}</span>
          );
        }
      },
      {
        header: "Created",
        accessorKey: "createdAt",
        cell: ({ getValue }) => <span className="text-ink-soft">{formatRelativeTime(getValue() as string)}</span>
      }
    ],
    []
  );

  return (
    <main className="mx-auto max-w-[1200px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
          <LifeBuoy size={17} strokeWidth={1.75} />
        </div>
        <div>
          <div className="flex items-center gap-1.5"><h1 className="text-[22px] font-semibold text-ink">Support Ticket Queue</h1><HelpTooltip text="Learner and instructor support requests tracked against their SLA due time. Overdue tickets are highlighted in red." /></div>
          <p className="mt-0.5 text-[13px] text-ink-soft">Learner and instructor support requests, tracked against SLA.</p>
        </div>
      </div>

      <div className="admin-clickable-table"><DataTable 
        columns={columns}
        data={data ?? []}
        isLoading={isLoading}
        emptyTitle="No tickets found"
        emptyDescription="Try adjusting your search or filters."
        onRowClick={(row) => router.push(`/support/tickets/${row.id}`)}
        toolbar={
          <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
            <div className="relative flex-1">
              <Search size={15} strokeWidth={1.75} className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-ink-soft" />
              <input
                placeholder="Search by subject or requester"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="h-10 w-full rounded-control border border-line bg-card pl-9 pr-3 text-[13px] text-ink outline-none placeholder:text-ink-soft/60 focus:border-line-strong"
              />
            </div>
            <div className="sm:w-[180px]">
              <Select placeholder="All statuses" options={STATUS_OPTIONS} value={status} onChange={(e) => setStatus(e.target.value)} />
            </div>
            <div className="sm:w-[180px]">
              <Select placeholder="All priorities" options={PRIORITY_OPTIONS} value={priority} onChange={(e) => setPriority(e.target.value)} />
            </div>
          </div>
        }
      /></div>    </main>
  );
}