"use client";

import { useState } from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";

export function Pagination({ totalPages = 12 }: { totalPages?: number }) {
  const [page, setPage] = useState(1);
  const pages = [1, 2, 3];

  const lineColor = "var(--token-color-blueprintLine)";
  const inkSoft = "var(--token-color-inkDeepSoft)";

  return (
    <div className="flex items-center justify-center gap-2" style={{ fontFamily: "var(--token-font-monoFamily)" }}>
      <button
        aria-label="Previous page"
        onClick={() => setPage((p) => Math.max(1, p - 1))}
        className="flex h-10 w-8 items-center justify-center border-2"
        style={{ borderColor: lineColor, color: inkSoft }}
      >
        <ChevronLeft className="h-3 w-3" />
      </button>

      {pages.map((p) => (
        <button
          key={p}
          onClick={() => setPage(p)}
          className="flex h-10 w-10 items-center justify-center text-sm font-semibold"
          style={
            page === p
              ? { backgroundColor: "var(--token-color-inkDeep)", color: "var(--token-color-paper)" }
              : { borderWidth: "1px", borderStyle: "solid", borderColor: lineColor, color: inkSoft }
          }
        >
          {p}
        </button>
      ))}

      <span className="px-1 text-base" style={{ color: inkSoft }}>...</span>

      <button
        onClick={() => setPage(totalPages)}
        className="flex h-10 w-10 items-center justify-center text-sm font-semibold"
        style={
          page === totalPages
            ? { backgroundColor: "var(--token-color-inkDeep)", color: "var(--token-color-paper)" }
            : { borderWidth: "1px", borderStyle: "solid", borderColor: lineColor, color: inkSoft }
        }
      >
        {totalPages}
      </button>

      <button
        aria-label="Next page"
        onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
        className="flex h-10 w-8 items-center justify-center border-2"
        style={{ borderColor: lineColor, color: inkSoft }}
      >
        <ChevronRight className="h-3 w-3" />
      </button>
    </div>
  );
}