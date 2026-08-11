"use client";

import { useState } from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";

export function Pagination({ totalPages = 12 }: { totalPages?: number }) {
  const [page, setPage] = useState(1);

  const pages = [1, 2, 3];

  return (
    <div className="flex items-center justify-center gap-2">
      <button
        aria-label="Previous page"
        onClick={() => setPage((p) => Math.max(1, p - 1))}
        className="flex h-10 w-8 items-center justify-center border border-slate-300 text-slate-600 hover:bg-gray-100"
      >
        <ChevronLeft className="h-3 w-3" />
      </button>

      {pages.map((p) => (
        <button
          key={p}
          onClick={() => setPage(p)}
          className={`flex h-10 w-10 items-center justify-center text-sm font-semibold tracking-wide ${
            page === p
              ? "bg-[#3525CD] font-bold text-white shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)]"
              : "border border-slate-300 text-slate-600 hover:bg-gray-100"
          }`}
        >
          {p}
        </button>
      ))}

      <span className="px-1 text-base text-gray-500">...</span>

      <button
        onClick={() => setPage(totalPages)}
        className={`flex h-10 w-10 items-center justify-center text-sm font-semibold tracking-wide ${
          page === totalPages
            ? "bg-[#3525CD] font-bold text-white shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)]"
            : "border border-slate-300 text-slate-600 hover:bg-gray-100"
        }`}
      >
        {totalPages}
      </button>

      <button
        aria-label="Next page"
        onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
        className="flex h-10 w-8 items-center justify-center border border-slate-300 text-slate-600 hover:bg-gray-100"
      >
        <ChevronRight className="h-3 w-3" />
      </button>
    </div>
  );
}
