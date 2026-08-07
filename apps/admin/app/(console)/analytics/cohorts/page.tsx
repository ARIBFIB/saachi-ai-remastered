"use client";

import { useEffect, useState } from "react";
import { Layers } from "lucide-react";
import { Shimmer , HelpTooltip } from "@saachi/ui";

type CohortRow = {
  cohort: string;
  size: number;
  weeks: number[];
};

const COHORT_DATA: CohortRow[] = [
  { cohort: "Jun 2026", size: 420, weeks: [100, 68, 54, 47, 41, 38] },
  { cohort: "Jul 2026", size: 512, weeks: [100, 71, 58, 50, 44, 0] },
  { cohort: "Aug 2026", size: 389, weeks: [100, 74, 61, 0, 0, 0] }
];

function heatColor(pct: number) {
  if (pct === 0) return "transparent";
  const alpha = Math.max(0.08, pct / 100);
  return `rgba(20, 23, 26, ${alpha})`;
}

export default function CohortAnalysisPage() {
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const t = setTimeout(() => setIsLoading(false), 600);
    return () => clearTimeout(t);
  }, []);

  return (
    <main className="mx-auto max-w-[1100px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
          <Layers size={17} strokeWidth={1.75} />
        </div>
        <div>
          <div className="flex items-center gap-1.5"><h1 className="text-[22px] font-semibold text-ink">Cohort Analysis</h1><HelpTooltip text="Shows what percentage of each signup cohort remains active week over week. Higher retention across later weeks means learners keep coming back." /></div>
          <p className="mt-0.5 text-[13px] text-ink-soft">Weekly retention percentage by learner signup cohort.</p>
        </div>
      </div>

      {isLoading ? (
        <div className="flex flex-col gap-2">
          {Array.from({ length: 3 }).map((_, i) => (
            <Shimmer key={i} className="h-14 w-full rounded-control" />
          ))}
        </div>
      ) : (
        <div className="overflow-x-auto rounded-card border border-line bg-card">
          <table className="w-full min-w-[640px] border-collapse text-[13px]">
            <thead>
              <tr className="border-b border-line text-left text-ink-soft">
                <th className="px-4 py-3 font-medium">Cohort</th>
                <th className="px-4 py-3 font-medium">Size</th>
                {Array.from({ length: 6 }).map((_, i) => (
                  <th key={i} className="px-4 py-3 font-medium">Wk {i}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {COHORT_DATA.map((row) => (
                <tr key={row.cohort} className="border-b border-line last:border-0">
                  <td className="px-4 py-3 font-medium text-ink">{row.cohort}</td>
                  <td className="px-4 py-3 text-ink-soft">{row.size}</td>
                  {row.weeks.map((pct, i) => (
                    <td key={i} className="px-4 py-3">
                      {pct > 0 ? (
                        <span
                          className="inline-flex h-8 w-14 items-center justify-center rounded-control text-[12px] font-medium text-ink"
                          style={{ backgroundColor: heatColor(pct) }}
                        >
                          {pct}%
                        </span>
                      ) : (
                        <span className="text-ink-soft/40">-</span>
                      )}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </main>
  );
}