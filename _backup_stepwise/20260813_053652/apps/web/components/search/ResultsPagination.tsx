"use client";

import { useState } from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";

interface ResultsPaginationProps {
  totalPages?: number;
}

export function ResultsPagination({ totalPages = 12 }: ResultsPaginationProps) {
  const [page, setPage] = useState(1);
  const pages = [1, 2, 3];

  return (
    <div className="flex items-center justify-center gap-2 pt-4">
      <button
        type="button"
        aria-label="Previous page"
        onClick={() => setPage((p) => Math.max(1, p - 1))}
        className="flex h-10 w-8 items-center justify-center border-2 border-[var(--token-color-border)] text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-surfaceAlt)]"
      >
        <ChevronLeft className="h-3 w-3" />
      </button>

      {pages.map((p) => (
        <button
          key={p}
          type="button"
          onClick={() => setPage(p)}
          className={`flex h-10 w-10 items-center justify-center text-sm font-semibold tracking-wide ${
            page === p
              ? "bg-[var(--token-color-primary)] text-white"
              : "border-2 border-[var(--token-color-border)] text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-surfaceAlt)]"
          }`}
        >
          {p}
        </button>
      ))}

      <span className="px-1 text-base text-[var(--token-color-inkSoft)]">...</span>

      <button
        type="button"
        onClick={() => setPage(totalPages)}
        className={`flex h-10 w-10 items-center justify-center text-sm font-semibold tracking-wide ${
          page === totalPages
            ? "bg-[var(--token-color-primary)] text-white"
            : "border-2 border-[var(--token-color-border)] text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-surfaceAlt)]"
        }`}
      >
        {totalPages}
      </button>

      <button
        type="button"
        aria-label="Next page"
        onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
        className="flex h-10 w-8 items-center justify-center border-2 border-[var(--token-color-border)] text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-surfaceAlt)]"
      >
        <ChevronRight className="h-3 w-3" />
      </button>
    </div>
  );
}