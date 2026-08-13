"use client";

import Link from "next/link";
import { useState } from "react";
import { Button, EmptyState, Select, Badge } from "@saachi/ui";

type CourseStatus = "draft" | "pending_review" | "published" | "rejected" | "archived";

type InstructorCourse = {
  id: string;
  title: string;
  status: CourseStatus;
  enrollments: number;
  price: number;
  currency: string;
};

// NOTE: demo-only dummy data. Replace with useInstructorCourses() once
// packages/api-client's instructor-course hooks are confirmed.
const COURSES: InstructorCourse[] = [];

const STATUS_OPTIONS = [
  { label: "All", value: "all" },
  { label: "Draft", value: "draft" },
  { label: "Pending review", value: "pending_review" },
  { label: "Published", value: "published" },
  { label: "Rejected", value: "rejected" },
  { label: "Archived", value: "archived" }
];

// NOTE: only using Badge variants confirmed to exist ("gold" | "success" | "error").
// Draft/archived fall back to no variant prop (component default styling).
const STATUS_VARIANT: Partial<Record<CourseStatus, "gold" | "success" | "error">> = {
  pending_review: "gold",
  published: "success",
  rejected: "error"
};

const STATUS_LABEL: Record<CourseStatus, string> = {
  draft: "Draft",
  pending_review: "Pending review",
  published: "Published",
  rejected: "Rejected",
  archived: "Archived"
};

export default function InstructorMyCoursesPage() {
  const [status, setStatus] = useState("all");

  const filtered = COURSES.filter((c) => status === "all" || c.status === status);

  return (
    <div>
      <div className="mb-6 flex flex-wrap items-center justify-between gap-3">
        <h1 className="font-display text-[26px] font-bold text-ink">My Courses</h1>
        <div className="flex items-center gap-3">
          <Select options={STATUS_OPTIONS} value={status} onChange={(e) => setStatus(e.target.value)} className="w-48" />
          <Link href="/instructor/courses/new">
            <Button>New course</Button>
          </Link>
        </div>
      </div>

      {filtered.length === 0 ? (
        <EmptyState
          title="No courses yet"
          description="Create your first course to start selling on Saachi AI."
          action={
            <Link href="/instructor/courses/new">
              <Button>Create a course</Button>
            </Link>
          }
        />
      ) : (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          <table className="w-full text-left text-[13px]">
            <thead className="border-b border-line bg-paper-dim">
              <tr>
                <th className="px-4 py-3 font-semibold text-ink-soft">Course</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Status</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Enrollments</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Price</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((c) => (
                <tr key={c.id} className="border-b border-line last:border-0">
                  <td className="px-4 py-3.5 font-medium text-ink">{c.title}</td>
                  <td className="px-4 py-3.5">
                    {STATUS_VARIANT[c.status] ? (
                      <Badge variant={STATUS_VARIANT[c.status]}>{STATUS_LABEL[c.status]}</Badge>
                    ) : (
                      <Badge>{STATUS_LABEL[c.status]}</Badge>
                    )}
                  </td>
                  <td className="px-4 py-3.5 text-ink-soft">{c.enrollments}</td>
                  <td className="px-4 py-3.5 font-mono text-ink">
                    {new Intl.NumberFormat("en-US", { style: "currency", currency: c.currency }).format(c.price)}
                  </td>
                  <td className="px-4 py-3.5">
                    <Link href={`/instructor/courses/${c.id}/edit`} className="text-gold-dark hover:underline">
                      Edit
                    </Link>
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