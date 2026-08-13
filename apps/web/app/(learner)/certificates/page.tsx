"use client";

import { Award, Download } from "lucide-react";
import { useEnrollmentStore } from "@saachi/store";
import { Button, EmptyState } from "@saachi/ui";

export default function CertificatesPage() {
  const enrollments = useEnrollmentStore((s) => s.enrollments);
  const completed = enrollments.filter((e) => e.progressPercent === 100);

  return (
    <div>
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Certificates</h1>

      {completed.length === 0 ? (
        <EmptyState
          title="No certificates yet"
          description="Complete a course to earn your first certificate."
        />
      ) : (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          {completed.map((e) => (
            <div key={e.courseId} className="flex items-center gap-4 rounded-card border border-line bg-card p-5">
              <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-full bg-gold-tint text-gold-dark">
                <Award size={22} />
              </div>
              <div className="min-w-0 flex-1">
                <h3 className="truncate text-[15px] font-semibold text-ink">{e.title}</h3>
                <p className="text-[13px] text-ink-soft">Completed - {e.instructorName}</p>
              </div>
              <Button size="sm" variant="secondary">
                <Download size={14} className="mr-1.5" />
                Download
              </Button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}