"use client";

import { TrendingUp, Users, CheckCircle2, Globe } from "lucide-react";
import { KpiCard, EmptyState } from "@saachi/ui";

export default function InstructorAnalyticsPage() {
  return (
    <div>
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Analytics</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Enrollment, completion, and revenue trends across your courses.</p>

      <div className="mb-10 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <KpiCard label="Total enrollments" value="654" icon={Users} />
        <KpiCard label="Completion rate" value="58%" icon={CheckCircle2} />
        <KpiCard label="Revenue (30d)" value="$1,240.00" icon={TrendingUp} />
        <KpiCard label="Top traffic source" value="Search" icon={Globe} />
      </div>

      <EmptyState
        title="Detailed charts coming soon"
        description="Enrollment trends, completion rate over time, revenue history, and student engagement heatmaps will render here once the analytics chart module is wired up."
      />
    </div>
  );
}
