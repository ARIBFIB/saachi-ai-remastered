"use client";

import type { ReactNode } from "react";
import { ChevronUp, ChevronDown, ChevronsUpDown } from "lucide-react";
import {
  flexRender,
  getCoreRowModel,
  getPaginationRowModel,
  getSortedRowModel,
  useReactTable,
  type ColumnDef,
  type SortingState
} from "@tanstack/react-table";
import { useState } from "react";
import { cn } from "../cn";
import { ShimmerTable } from "./Shimmer";
import { EmptyState } from "./EmptyState";
import { Button } from "./Button";

export type DataTableProps<T> = {
  columns: ColumnDef<T, any>[];
  data: T[];
  isLoading?: boolean;
  emptyTitle?: string;
  emptyDescription?: string;
  pageSize?: number;
  toolbar?: ReactNode;
  onRowClick?: (row: T) => void;
};

export function DataTable<T>({
  columns,
  data,
  isLoading,
  emptyTitle = "Nothing here yet",
  emptyDescription,
  pageSize = 10,
  toolbar,
  onRowClick
}: DataTableProps<T>) {
  const [sorting, setSorting] = useState<SortingState>([]);

  const table = useReactTable({
    data,
    columns,
    state: { sorting },
    onSortingChange: setSorting,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    initialState: { pagination: { pageSize } }
  });

  if (isLoading) {
    return (
      <div className="flex flex-col gap-4">
        {toolbar}
        <ShimmerTable rows={6} columns={columns.length} />
      </div>
    );
  }

  if (data.length === 0) {
    return (
      <div className="flex flex-col gap-4">
        {toolbar}
        <EmptyState title={emptyTitle} description={emptyDescription} />
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-4">
      {toolbar}
      <div className="overflow-hidden rounded-card border border-line bg-card">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-[13px]">
            <thead className="border-b border-line bg-paper-dim">
              {table.getHeaderGroups().map((headerGroup) => (
                <tr key={headerGroup.id}>
                  {headerGroup.headers.map((header) => {
                    const sortState = header.column.getIsSorted();
                    return (
                      <th key={header.id} className="whitespace-nowrap px-4 py-3 font-semibold text-ink-soft">
                        {header.isPlaceholder ? null : (
                          <button
                            type="button"
                            onClick={header.column.getToggleSortingHandler()}
                            className={cn(
                              "flex items-center gap-1.5",
                              header.column.getCanSort() ? "cursor-pointer select-none hover:text-ink" : "cursor-default"
                            )}
                          >
                            {flexRender(header.column.columnDef.header, header.getContext())}
                            {header.column.getCanSort() &&
                              (sortState === "asc" ? (
                                <ChevronUp size={13} />
                              ) : sortState === "desc" ? (
                                <ChevronDown size={13} />
                              ) : (
                                <ChevronsUpDown size={13} className="opacity-40" />
                              ))}
                          </button>
                        )}
                      </th>
                    );
                  })}
                </tr>
              ))}
            </thead>
            <tbody>
              {table.getRowModel().rows.map((row) => (
                <tr
                  key={row.id}
                  onClick={() => onRowClick?.(row.original)}
                  className={cn(
                    "border-b border-line last:border-0",
                    onRowClick && "cursor-pointer transition-colors duration-150 ease-out hover:bg-paper-dim"
                  )}
                >
                  {row.getVisibleCells().map((cell) => (
                    <td key={cell.id} className="whitespace-nowrap px-4 py-3.5 text-ink">
                      {flexRender(cell.column.columnDef.cell, cell.getContext())}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {table.getPageCount() > 1 && (
        <div className="flex items-center justify-between px-1">
          <span className="text-[12px] text-ink-soft">
            Page {table.getState().pagination.pageIndex + 1} of {table.getPageCount()}
          </span>
          <div className="flex gap-2">
            <Button size="sm" variant="secondary" onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()}>
              Previous
            </Button>
            <Button size="sm" variant="secondary" onClick={() => table.nextPage()} disabled={!table.getCanNextPage()}>
              Next
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}