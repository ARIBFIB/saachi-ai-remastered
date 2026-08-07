"use client";

import { Users, BookOpen, TrendingUp, CreditCard } from "lucide-react";
import { useCorporateStore } from "@saachi/store";
import { Card } from "@saachi/ui";

export default function CorporateDashboardPage() {
  const { account, team } = useCorporateStore();

  const totalAssignments = team.reduce((sum, m) => sum + m.assignedCourseIds.length, 0);
  const totalCompletions = team.reduce((sum, m) => sum + m.completedCourseIds.length, 0);
  const completionRate = totalAssignments > 0 ? Math.round((totalCompletions / totalAssignments) * 100) : 0;
  const activeMembers = team.filter((m) => m.status === "active").length;

  const stats = [
    { label: "Team members", value: `${activeMembers}/${team.length}`, icon: Users },
    { label: "Seats available", value: `${account.seatsPurchased - account.seatsUsed}`, icon: CreditCard },
    { label: "Course assignments", value: String(totalAssignments), icon: BookOpen },
    { label: "Completion rate", value: `${completionRate}%`, icon: TrendingUp }
  ];

  return (
    <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
      <div className="mb-8">
        <h1 className="font-display text-[26px] font-semibold text-ink">{account.companyName} Dashboard</h1>
        <p className="mt-1 text-[14px] text-ink-soft">Team learning overview and seat usage.</p>
      </div>

      <div className="mb-10 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => (
          <Card key={stat.label} className="p-5">
            <div className="mb-3 flex h-9 w-9 items-center justify-center rounded-control bg-paper-dim text-ink">
              <stat.icon size={17} />
            </div>
            <div className="font-mono text-[22px] font-semibold text-ink">{stat.value}</div>
            <div className="mt-1 text-[13px] text-ink-soft">{stat.label}</div>
          </Card>
        ))}
      </div>

      <h2 className="mb-4 font-display text-[18px] font-semibold text-ink">Recent activity</h2>
      <div className="flex flex-col gap-3">
        {team.slice(0, 5).map((member) => (
          <Card key={member.id} className="flex items-center justify-between p-4">
            <div>
              <p className="text-[14px] font-semibold text-ink">{member.name}</p>
              <p className="mt-0.5 text-[12px] text-ink-soft">
                {member.completedCourseIds.length} of {member.assignedCourseIds.length} assigned courses completed
              </p>
            </div>
            <span className="text-[12px] capitalize text-ink-soft">{member.status}</span>
          </Card>
        ))}
      </div>
    </main>
  );
}