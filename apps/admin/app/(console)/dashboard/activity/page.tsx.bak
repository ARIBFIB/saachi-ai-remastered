"use client";

import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { Search, History, ArrowLeft } from "lucide-react";
import type { ColumnDef } from "@tanstack/react-table";
import { DataTable, Select, StatusPill } from "@saachi/ui";
import { formatRelativeTime } from "@saachi/utils";

type ActivityRow = {
  id: string;
  type: "transaction" | "course" | "ticket" | "user";
  description: string;
  actor: string;
  createdAt: string;
};

const TYPE_OPTIONS = [
  { label: "Transaction", value: "transaction" },
  { label: "Course", value: "course" },
  { label: "Ticket", value: "ticket" },
  { label: "User", value: "user" }
];

const TYPE_TONE: Record<ActivityRow["type"], "success" | "warning" | "error" | "info" | "neutral"> = {
  transaction: "success",
  course: "info",
  ticket: "warning",
  user: "neutral"
};

const ACTIVITY_ROUTE: Record<ActivityRow["type"], string> = {
  transaction: "/finance/transactions",
  course: "/courses/moderation",
  ticket: "/support/tickets",
  user: "/users"
};

const ACTORS = ["Fatima Noor", "Hassan Raza", "Ali Bukhari", "Sana Iqbal", "Zeeshan Tariq", "Ayesha Malik", "Bilal Ahmed", "Nida Khan"];

const DESCRIPTIONS: Record<ActivityRow["type"], string[]> = {
  transaction: [
    'Purchased "AI Automation with n8n"',
    'Purchased "Prompt Engineering for Marketers"',
    'Purchased "AI Customer Support Bots"',
    "Upgraded to Saachi AI Pro subscription"
  ],
  course: [
    "Submitted a new course for review",
    "Resubmitted course after feedback",
    "Published a free intro lesson"
  ],
  ticket: [
    "Opened ticket - payout not received",
    "Opened ticket - certificate not generated",
    "Opened ticket - refund status inquiry"
  ],
  user: [
    "New instructor application submitted",
    "New learner account registered",
    "Requested account verification"
  ]
};

function buildMockActivity(count: number): ActivityRow[] {
  const types: ActivityRow["type"][] = ["transaction", "course", "ticket", "user"];
  const rows: ActivityRow[] = [];
  for (let i = 0; i < count; i++) {
    const type = types[i % types.length];
    const descPool = DESCRIPTIONS[type];
    rows.push({
      id: `act_${i + 1}`,
      type,
      description: descPool[i % descPool.length],
      actor: ACTORS[i % ACTORS.length],
      createdAt: new Date(Date.now() - i * 3.7 * 60 * 60 * 1000).toISOString()
    });
  }
  return rows;
}

const ALL_ACTIVITY = buildMockActivity(64);

export default function DashboardActivityPage() {
  const router = useRouter();
  const [search, setSearch] = useState("");
  const [typeFilter, setTypeFilter] = useState("");

  const filtered = useMemo(() => {
    return ALL_ACTIVITY.filter((row) => {
      const matchesSearch =
        !search ||
        row.description.toLowerCase().includes(search.toLowerCase()) ||
        row.actor.toLowerCase().includes(search.toLowerCase());
      const matchesType = !typeFilter || row.type === typeFilter;
      return matchesSearch && matchesType;
    });
  }, [search, typeFilter]);

  const columns = useMemo<ColumnDef<ActivityRow, any>[]>(
    () => [
      {
        header: "Activity",
        accessorKey: "description",
        cell: ({ row }) => (
          <div className="max-w-[360px]">
            <div className="truncate font-medium text-ink">{row.original.description}</div>
            <div className="text-[12px] text-ink-soft">{row.original.actor}</div>
          </div>
        )
      },
      {
        header: "Type",
        accessorKey: "type",
        cell: ({ getValue }) => {
          const value = getValue() as ActivityRow["type"];
          return <StatusPill label={value} tone={TYPE_TONE[value]} />;
        }
      },
      {
        header: "When",
        accessorKey: "createdAt",
        cell: ({ getValue }) => <span className="text-ink-soft">{formatRelativeTime(getValue() as string)}</span>
      }
    ],
    []
  );

  return (
    <main className="mx-auto max-w-[1200px] px-4 py-8 md:px-8 md:py-10">
      <button
        type="button"
        onClick={() => router.push("/dashboard")}
        className="mb-4 flex items-center gap-1.5 text-[12.5px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:text-ink"
      >
        <ArrowLeft size={14} strokeWidth={1.75} /> Back to dashboard
      </button>

      <div className="mb-6 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
          <History size={17} strokeWidth={1.75} />
        </div>
        <div>
          <h1 className="text-[22px] font-semibold text-ink">Recent Activity</h1>
          <p className="mt-0.5 text-[13px] text-ink-soft">Full activity log across transactions, courses, tickets, and users.</p>
        </div>
      </div>

      <DataTable
        columns={columns}
        data={filtered}
        isLoading={false}
        emptyTitle="No activity found"
        emptyDescription="Try adjusting your search or filters."
        onRowClick={(row: ActivityRow) => router.push(ACTIVITY_ROUTE[row.type])}
        toolbar={
          <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
            <div className="relative flex-1">
              <Search size={15} strokeWidth={1.75} className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-ink-soft" />
              <input
                placeholder="Search by description or actor"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="h-10 w-full rounded-control border border-line bg-card pl-9 pr-3 text-[13px] text-ink outline-none placeholder:text-ink-soft/60 focus:border-line-strong"
              />
            </div>
            <div className="sm:w-[180px]">
              <Select placeholder="All types" options={TYPE_OPTIONS} value={typeFilter} onChange={(e) => setTypeFilter(e.target.value)} />
            </div>
          </div>
        }
      />
    </main>
  );
}