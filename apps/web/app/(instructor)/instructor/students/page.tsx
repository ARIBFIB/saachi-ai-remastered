"use client";

import { Card, Input, Badge } from "@saachi/ui";
import { Search } from "lucide-react";
import { useState } from "react";

const DEMO_STUDENTS = [
  { id: "std_1", name: "Bilal Ahmed", email: "bilal@example.com", course: "Prompt Engineering Fundamentals", progress: 80 },
  { id: "std_2", name: "Hina Malik", email: "hina@example.com", course: "Prompt Engineering Fundamentals", progress: 45 },
  { id: "std_3", name: "Omar Sheikh", email: "omar@example.com", course: "AI-Powered Marketing Campaigns", progress: 100 },
  { id: "std_4", name: "Fatima Noor", email: "fatima@example.com", course: "Automate Everything with n8n & AI", progress: 20 }
];

export default function InstructorStudentsPage() {
  const [search, setSearch] = useState("");

  const filtered = DEMO_STUDENTS.filter(
    (s) => s.name.toLowerCase().includes(search.toLowerCase()) || s.course.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
      <h1 className="mb-6 font-display text-[26px] font-semibold text-ink">Students</h1>

      <div className="relative mb-6 max-w-[360px]">
        <Search size={16} className="pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 text-ink-soft/60" />
        <Input placeholder="Search students or courses" value={search} onChange={(e) => setSearch(e.target.value)} className="pl-10" />
      </div>

      <div className="flex flex-col gap-3">
        {filtered.map((s) => (
          <Card key={s.id} className="flex flex-col gap-3 p-4 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <p className="text-[14px] font-semibold text-ink">{s.name}</p>
              <p className="text-[12px] text-ink-soft">{s.email}</p>
              <p className="mt-1 text-[12px] text-ink-soft">{s.course}</p>
            </div>
            <Badge variant={s.progress === 100 ? "success" : "default"}>{s.progress}% complete</Badge>
          </Card>
        ))}
      </div>
    </main>
  );
}