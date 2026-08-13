"use client";

import { TrendingUp, Users, CheckCircle2, Globe } from "lucide-react";
import { KpiCard, EmptyState } from "@saachi/ui";

export default function InstructorAnalyticsPage() {
  return (
    <div>
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Analytics</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Enrollment, completion, and revenue trends across your courses.</p>

      <div className="mb-10 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <KpiCard label="Total enrollments" value="0" icon={Users} />
        <KpiCard label="Completion rate" value="â€”" icon={CheckCircle2} />
        <KpiCard label="Revenue (30d)" value="$0.00" icon={TrendingUp} />
        <KpiCard label="Top traffic source" value="â€”" icon={Globe} />
      </div>

      <EmptyState
        title="Not enough data yet"
        description="Charts for enrollment trends, completion rate, revenue, and student engagement will appear here once your courses start getting enrollments."
      />
    </div>
  );
}