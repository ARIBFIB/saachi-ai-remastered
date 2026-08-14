"use client";

import { useState } from "react";
import { MessageCircle } from "lucide-react";
import { Button, Input, EmptyState, Badge } from "@saachi/ui";

type Student = {
  id: string;
  name: string;
  courseTitle: string;
  progressPercent: number;
  lastActive: string;
};

// NOTE: demo-only dummy data. Replace with useInstructorStudents() once confirmed.
const STUDENTS: Student[] = [
  { id: "stu_1", name: "Hina Malik", courseTitle: "Automate Everything with n8n & AI", progressPercent: 100, lastActive: "2 days ago" },
  { id: "stu_2", name: "Omar Sheikh", courseTitle: "Automate Everything with n8n & AI", progressPercent: 65, lastActive: "Today" },
  { id: "stu_3", name: "Sara Iqbal", courseTitle: "AI Chatbots for WhatsApp Support", progressPercent: 40, lastActive: "5 days ago" },
  { id: "stu_4", name: "Noor Fatima", courseTitle: "Automate Everything with n8n & AI", progressPercent: 100, lastActive: "1 week ago" },
  { id: "stu_5", name: "Ali Raza", courseTitle: "AI Chatbots for WhatsApp Support", progressPercent: 20, lastActive: "Yesterday" }
];

export default function InstructorStudentsPage() {
  const [search, setSearch] = useState("");

  const filtered = STUDENTS.filter((s) =>
    s.name.toLowerCase().includes(search.toLowerCase()) || s.courseTitle.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div>
      <div className="mb-6 flex flex-wrap items-center justify-between gap-3">
        <h1 className="font-display text-[26px] font-bold text-ink">Students</h1>
        <Input
          placeholder="Search students or courses..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-64"
        />
      </div>

      {filtered.length === 0 ? (
        <EmptyState
          title="No students yet"
          description="Once learners enroll in your courses, they'll appear here."
        />
      ) : (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          <table className="w-full text-left text-[13px]">
            <thead className="border-b border-line bg-paper-dim">
              <tr>
                <th className="px-4 py-3 font-semibold text-ink-soft">Student</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Course</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Progress</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Last active</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((s) => (
                <tr key={s.id} className="border-b border-line last:border-0">
                  <td className="px-4 py-3.5 font-medium text-ink">{s.name}</td>
                  <td className="px-4 py-3.5 text-ink-soft">{s.courseTitle}</td>
                  <td className="px-4 py-3.5">
                    <div className="flex items-center gap-2">
                      <div className="h-1.5 w-24 overflow-hidden rounded-full bg-paper-dim">
                        <div className="h-full rounded-full bg-gold" style={{ width: `${s.progressPercent}%` }} />
                      </div>
                      <span className="text-ink-soft">{s.progressPercent}%</span>
                      {s.progressPercent === 100 && <Badge variant="success">Done</Badge>}
                    </div>
                  </td>
                  <td className="px-4 py-3.5 text-ink-soft">{s.lastActive}</td>
                  <td className="px-4 py-3.5">
                    <Button size="sm" variant="secondary">
                      <MessageCircle size={13} className="mr-1.5" />
                      Message
                    </Button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
