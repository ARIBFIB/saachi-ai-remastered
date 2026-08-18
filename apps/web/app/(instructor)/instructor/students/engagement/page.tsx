"use client";

import { useMemo, useState } from "react";
import { UserCheck, UserX, UserMinus, GraduationCap, MessageCircle } from "lucide-react";
import { Button, Input, EmptyState, Badge, KpiCard, Select } from "@saachi/ui";

type EngagementCategory = "active" | "inactive" | "dormant" | "completed";

type EngagedStudent = {
  id: string;
  name: string;
  courseTitle: string;
  lastActiveDays: number;
  progressPercent: number;
};

// NOTE: demo-only dummy data. Replace with useInstructorStudentEngagement() once confirmed.
const STUDENTS: EngagedStudent[] = [
  { id: "stu_1", name: "Hina Malik", courseTitle: "Automate Everything with n8n & AI", lastActiveDays: 1, progressPercent: 100 },
  { id: "stu_2", name: "Omar Sheikh", courseTitle: "Automate Everything with n8n & AI", lastActiveDays: 0, progressPercent: 65 },
  { id: "stu_3", name: "Sara Iqbal", courseTitle: "AI Chatbots for WhatsApp Support", lastActiveDays: 5, progressPercent: 40 },
  { id: "stu_4", name: "Noor Fatima", courseTitle: "Automate Everything with n8n & AI", lastActiveDays: 45, progressPercent: 30 },
  { id: "stu_5", name: "Ali Raza", courseTitle: "AI Chatbots for WhatsApp Support", lastActiveDays: 1, progressPercent: 20 },
  { id: "stu_6", name: "Danish Iqbal", courseTitle: "Prompt Engineering for Client Work", lastActiveDays: 12, progressPercent: 55 },
  { id: "stu_7", name: "Zara Ahmed", courseTitle: "Automate Everything with n8n & AI", lastActiveDays: 60, progressPercent: 15 },
  { id: "stu_8", name: "Usman Tariq", courseTitle: "AI Chatbots for WhatsApp Support", lastActiveDays: 3, progressPercent: 100 },
  { id: "stu_9", name: "Mahnoor Khalid", courseTitle: "Prompt Engineering for Client Work", lastActiveDays: 90, progressPercent: 10 },
  { id: "stu_10", name: "Bilal S.", courseTitle: "Automate Everything with n8n & AI", lastActiveDays: 2, progressPercent: 80 }
];

function categorize(student: EngagedStudent): EngagementCategory {
  if (student.progressPercent === 100) return "completed";
  if (student.lastActiveDays <= 7) return "active";
  if (student.lastActiveDays <= 30) return "inactive";
  return "dormant";
}

const CATEGORY_META: Record<EngagementCategory, { label: string; variant?: "success" | "gold" | "error" }> = {
  active: { label: "Active", variant: "success" },
  inactive: { label: "Inactive", variant: "gold" },
  dormant: { label: "At risk", variant: "error" },
  completed: { label: "Completed", variant: "success" }
};

const FILTER_OPTIONS = [
  { label: "All students", value: "all" },
  { label: "Active", value: "active" },
  { label: "Inactive", value: "inactive" },
  { label: "At risk / Dormant", value: "dormant" },
  { label: "Completed", value: "completed" }
];

function lastActiveLabel(days: number): string {
  if (days === 0) return "Today";
  if (days === 1) return "Yesterday";
  if (days < 7) return `${days} days ago`;
  if (days < 30) return `${Math.round(days / 7)} weeks ago`;
  return `${Math.round(days / 30)} months ago`;
}

export default function InstructorStudentsEngagementPage() {
  const [category, setCategory] = useState<string>("all");
  const [search, setSearch] = useState("");

  const categorized = useMemo(
    () => STUDENTS.map((s) => ({ ...s, category: categorize(s) })),
    []
  );

  const counts = useMemo(() => {
    return {
      active: categorized.filter((s) => s.category === "active").length,
      inactive: categorized.filter((s) => s.category === "inactive").length,
      dormant: categorized.filter((s) => s.category === "dormant").length,
      completed: categorized.filter((s) => s.category === "completed").length
    };
  }, [categorized]);

  const filtered = useMemo(() => {
    let items = [...categorized];
    if (category !== "all") items = items.filter((s) => s.category === category);
    if (search.trim()) {
      const q = search.toLowerCase();
      items = items.filter(
        (s) => s.name.toLowerCase().includes(q) || s.courseTitle.toLowerCase().includes(q)
      );
    }
    return items.sort((a, b) => a.lastActiveDays - b.lastActiveDays);
  }, [categorized, category, search]);

  return (
    <div>
      <div className="mb-6 flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Engagement Status</h1>
          <p className="text-[14px] text-ink-soft">
            See which students are active, inactive, or at risk of dropping off.
          </p>
        </div>
        <div className="flex flex-wrap items-center gap-2">
          <Input
            placeholder="Search students or courses..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-64"
          />
          <Select options={FILTER_OPTIONS} value={category} onChange={(e) => setCategory(e.target.value)} className="w-48" />
        </div>
      </div>

      <div className="mb-8 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <KpiCard label="Active (last 7 days)" value={String(counts.active)} icon={UserCheck} />
        <KpiCard label="Inactive (7-30 days)" value={String(counts.inactive)} icon={UserMinus} />
        <KpiCard label="At risk / Dormant" value={String(counts.dormant)} icon={UserX} />
        <KpiCard label="Completed course" value={String(counts.completed)} icon={GraduationCap} />
      </div>

      {filtered.length === 0 ? (
        <EmptyState
          title="No students in this view"
          description="Try a different filter or search term."
        />
      ) : (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          <table className="w-full text-left text-[13px]">
            <thead className="border-b border-line bg-paper-dim">
              <tr>
                <th className="px-4 py-3 font-semibold text-ink-soft">Student</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Course</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Status</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Last active</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Progress</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((s) => {
                const meta = CATEGORY_META[s.category];
                return (
                  <tr key={s.id} className="border-b border-line last:border-0">
                    <td className="px-4 py-3.5 font-medium text-ink">{s.name}</td>
                    <td className="px-4 py-3.5 text-ink-soft">{s.courseTitle}</td>
                    <td className="px-4 py-3.5">
                      {meta.variant ? <Badge variant={meta.variant}>{meta.label}</Badge> : <Badge>{meta.label}</Badge>}
                    </td>
                    <td className="px-4 py-3.5 text-ink-soft">{lastActiveLabel(s.lastActiveDays)}</td>
                    <td className="px-4 py-3.5">
                      <div className="flex items-center gap-2">
                        <div className="h-1.5 w-24 overflow-hidden rounded-full bg-paper-dim">
                          <div className="h-full rounded-full bg-gold" style={{ width: `${s.progressPercent}%` }} />
                        </div>
                        <span className="text-ink-soft">{s.progressPercent}%</span>
                      </div>
                    </td>
                    <td className="px-4 py-3.5">
                      <Button
                        size="sm"
                        variant="secondary"
                        onClick={() =>
                          (window.location.href = `/instructor/students/messages?to=${encodeURIComponent(s.name)}`)
                        }
                      >
                        <MessageCircle size={13} className="mr-1.5" />
                        Send nudge
                      </Button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}