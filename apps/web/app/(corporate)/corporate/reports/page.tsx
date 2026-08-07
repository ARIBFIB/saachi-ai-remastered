"use client";

import { Download } from "lucide-react";
import { useCorporateStore } from "@saachi/store";
import { Button, Card } from "@saachi/ui";

export default function TeamReportsPage() {
  const { team } = useCorporateStore();

  return (
    <main className="mx-auto max-w-[900px] px-6 py-10 md:px-10">
      <div className="mb-8 flex items-center justify-between">
        <div>
          <h1 className="font-display text-[26px] font-semibold text-ink">Team Reports</h1>
          <p className="mt-1 text-[14px] text-ink-soft">Per-employee completion and compliance overview.</p>
        </div>
        <Button variant="secondary">
          <Download size={15} /> Export CSV
        </Button>
      </div>

      <Card className="overflow-hidden p-0">
        <table className="w-full text-left text-[13px]">
          <thead className="border-b border-line bg-paper-dim text-ink-soft">
            <tr>
              <th className="px-4 py-3 font-semibold">Name</th>
              <th className="px-4 py-3 font-semibold">Status</th>
              <th className="px-4 py-3 font-semibold">Assigned</th>
              <th className="px-4 py-3 font-semibold">Completed</th>
              <th className="px-4 py-3 font-semibold">Completion %</th>
            </tr>
          </thead>
          <tbody>
            {team.map((member) => {
              const pct =
                member.assignedCourseIds.length > 0
                  ? Math.round((member.completedCourseIds.length / member.assignedCourseIds.length) * 100)
                  : 0;
              return (
                <tr key={member.id} className="border-b border-line last:border-0">
                  <td className="px-4 py-3 text-ink">{member.name}</td>
                  <td className="px-4 py-3 capitalize text-ink-soft">{member.status}</td>
                  <td className="px-4 py-3 text-ink-soft">{member.assignedCourseIds.length}</td>
                  <td className="px-4 py-3 text-ink-soft">{member.completedCourseIds.length}</td>
                  <td className="px-4 py-3 font-semibold text-ink">{pct}%</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </Card>
    </main>
  );
}