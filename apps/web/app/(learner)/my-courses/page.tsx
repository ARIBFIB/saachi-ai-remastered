"use client";

import Link from "next/link";
import { useState } from "react";
import { useEnrollmentStore } from "@saachi/store";
import { Button, EmptyState, Select } from "@saachi/ui";

const STATUS_OPTIONS = [
  { label: "All", value: "all" },
  { label: "In progress", value: "in_progress" },
  { label: "Completed", value: "completed" },
  { label: "Not started", value: "not_started" }
];

export default function MyCoursesPage() {
  const enrollments = useEnrollmentStore((s) => s.enrollments);
  const [status, setStatus] = useState("all");

  const filtered = enrollments.filter((e) => {
    if (status === "in_progress") return e.progressPercent > 0 && e.progressPercent < 100;
    if (status === "completed") return e.progressPercent === 100;
    if (status === "not_started") return e.progressPercent === 0;
    return true;
  });

  return (
    <div>
      <div className="mb-6 flex items-center justify-between">
        <h1 className="font-display text-[26px] font-bold text-ink">My Courses</h1>
        <Select options={STATUS_OPTIONS} value={status} onChange={(e) => setStatus(e.target.value)} className="w-48" />
      </div>

      {filtered.length === 0 ? (
        <EmptyState
          title="No courses here yet"
          description="Courses you enroll in will show up here."
          action={
            <Link href="/courses">
              <Button>Browse courses</Button>
            </Link>
          }
        />
      ) : (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {filtered.map((e) => (
            <Link
              key={e.courseId}
              href={`/learn/${e.courseId}/lesson`}
              className="flex flex-col overflow-hidden rounded-card border border-line bg-card transition-colors hover:border-gold-dark/40"
            >
              {e.thumbnailUrl && (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={e.thumbnailUrl} alt={e.title} className="aspect-video w-full object-cover" />
              )}
              <div className="p-4">
                <h3 className="line-clamp-2 text-[15px] font-semibold text-ink">{e.title}</h3>
                <p className="mt-1 text-[13px] text-ink-soft">{e.instructorName}</p>
                <div className="mt-3 h-1.5 w-full overflow-hidden rounded-full bg-paper-dim">
                  <div className="h-full rounded-full bg-gold" style={{ width: `${e.progressPercent}%` }} />
                </div>
                <p className="mt-1.5 text-[12px] text-ink-soft">{e.progressPercent}% complete</p>
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}