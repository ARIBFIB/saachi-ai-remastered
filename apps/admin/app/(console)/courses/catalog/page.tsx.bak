"use client";

import { useMemo, useState } from "react";
import { Search, LibraryBig, Star, Pin } from "lucide-react";
import type { ColumnDef } from "@tanstack/react-table";
import {
  useAdminCourseCatalog,
  useAdminCategoryList,
  useToggleCourseFlag,
  type AdminCourse
} from "@saachi/api-client";
import { DataTable, StatusPill, Select , RefreshButton } from "@saachi/ui";
import { formatCurrency, formatDate } from "@saachi/utils";

const STATUS_OPTIONS = [
  { label: "Draft", value: "draft" },
  { label: "Pending review", value: "pending_review" },
  { label: "Published", value: "published" },
  { label: "Rejected", value: "rejected" },
  { label: "Archived", value: "archived" }
];

const STATUS_TONE: Record<AdminCourse["status"], "success" | "warning" | "error" | "info" | "neutral"> = {
  draft: "neutral",
  pending_review: "warning",
  published: "success",
  rejected: "error",
  archived: "info"
};

export default function CourseCatalogPage() {
  const [search, setSearch] = useState("");
  const [categoryId, setCategoryId] = useState("");
  const [status, setStatus] = useState("");

  const { data: categories } = useAdminCategoryList();
  const { data, isLoading } = useAdminCourseCatalog({
    search: search || undefined,
    categoryId: categoryId || undefined,
    status: status || undefined
  });
  const toggleFlag = useToggleCourseFlag();

  const categoryOptions = useMemo(
    () => (categories ?? []).map((c) => ({ label: c.name, value: c.id })),
    [categories]
  );

  const columns = useMemo<ColumnDef<AdminCourse, any>[]>(
    () => [
      {
        header: "Course",
        accessorKey: "title",
        cell: ({ row }) => (
          <div className="flex items-center gap-3">
            <div className="h-9 w-16 shrink-0 overflow-hidden rounded-control border border-line bg-paper-dim">
              {row.original.thumbnailUrl && (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={row.original.thumbnailUrl} alt={row.original.title} className="h-full w-full object-cover" />
              )}
            </div>
            <div className="max-w-[260px]">
              <div className="truncate font-medium text-ink">{row.original.title}</div>
              <div className="text-[12px] text-ink-soft">{row.original.instructorName}</div>
            </div>
          </div>
        )
      },
      {
        header: "Category",
        accessorKey: "categoryId",
        cell: ({ getValue }) => <span className="text-ink-soft">{getValue()}</span>
      },
      {
        header: "Price",
        accessorKey: "price",
        cell: ({ row }) => (
          <span className="font-mono font-semibold text-ink">
            {formatCurrency(row.original.price, row.original.currency)}
          </span>
        )
      },
      {
        header: "Status",
        accessorKey: "status",
        cell: ({ getValue }) => {
          const value = getValue() as AdminCourse["status"];
          return <StatusPill label={value.replace("_", " ")} tone={STATUS_TONE[value]} />;
        }
      },
      {
        header: "Enrollments",
        accessorKey: "enrollmentCount",
        cell: ({ getValue }) => <span className="font-mono text-ink-soft">{(getValue() as number).toLocaleString()}</span>
      },
      {
        header: "Submitted",
        accessorKey: "submittedAt",
        cell: ({ getValue }) => <span className="text-ink-soft">{formatDate(getValue() as string)}</span>
      },
      {
        header: "Curate",
        id: "curate",
        cell: ({ row }) => (
          <div className="flex items-center gap-1.5">
            <button
              type="button"
              onClick={(e) => {
                e.stopPropagation();
                toggleFlag.mutate({ id: row.original.id, field: "featured" });
              }}
              title="Toggle featured"
              className={`flex h-7 w-7 items-center justify-center rounded-control border transition-colors duration-150 ease-out ${
                row.original.featured ? "border-ink bg-ink text-paper" : "border-line text-ink-soft hover:text-ink"
              }`}
            >
              <Star size={13} strokeWidth={1.75} />
            </button>
            <button
              type="button"
              onClick={(e) => {
                e.stopPropagation();
                toggleFlag.mutate({ id: row.original.id, field: "pinned" });
              }}
              title="Toggle pinned"
              className={`flex h-7 w-7 items-center justify-center rounded-control border transition-colors duration-150 ease-out ${
                row.original.pinned ? "border-ink bg-ink text-paper" : "border-line text-ink-soft hover:text-ink"
              }`}
            >
              <Pin size={13} strokeWidth={1.75} />
            </button>
          </div>
        )
      }
    ],
    [toggleFlag]
  );

  return (
    <main className="mx-auto max-w-[1200px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
          <LibraryBig size={17} strokeWidth={1.75} />
        </div>
        <div>
          <h1 className="text-[22px] font-semibold text-ink">Course Catalog</h1>
          <p className="mt-0.5 text-[13px] text-ink-soft">Full catalog across every status - feature or pin courses for curation.</p>
        </div>
      </div>
      <div className="mb-3 flex justify-end"><RefreshButton /></div>

      <DataTable
        columns={columns}
        data={data ?? []}
        isLoading={isLoading}
        emptyTitle="No courses found"
        emptyDescription="Try adjusting your search or filters."
        toolbar={
          <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
            <div className="relative flex-1">
              <Search size={15} strokeWidth={1.75} className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-ink-soft" />
              <input
                placeholder="Search by title or instructor"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="h-10 w-full rounded-control border border-line bg-card pl-9 pr-3 text-[13px] text-ink outline-none placeholder:text-ink-soft/60 focus:border-line-strong"
              />
            </div>
            <div className="sm:w-[220px]">
              <Select placeholder="All categories" options={categoryOptions} value={categoryId} onChange={(e) => setCategoryId(e.target.value)} />
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