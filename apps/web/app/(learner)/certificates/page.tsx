"use client";

import Link from "next/link";
import { Award, Download, ShieldCheck } from "lucide-react";
import { useEnrollmentStore } from "@saachi/store";
import { useSession } from "@saachi/api-client";
import { Button, Card, EmptyState } from "@saachi/ui";
import { formatDate } from "@saachi/utils";

function verificationId(courseId: string) {
  return `SAACHI-${courseId.toUpperCase().replace("CRS_", "")}-DEMO`;
}

export default function CertificatesPage() {
  const { enrollments } = useEnrollmentStore();
  const { data: session } = useSession();

  const completed = enrollments.filter((e) => e.progressPercent >= 100);

  return (
    <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
      <div className="mb-8">
        <h1 className="font-display text-[26px] font-semibold text-ink">Certificates</h1>
        <p className="mt-1 text-[14px] text-ink-soft">Courses you've fully completed.</p>
      </div>

      {completed.length === 0 ? (
        <EmptyState
          icon={<Award size={22} />}
          title="No certificates yet"
          description="Complete every lesson in a course to earn your certificate."
          action={
            <Link href="/my-courses">
              <Button>Go to My Courses</Button>
            </Link>
          }
        />
      ) : (
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
          {completed.map((course) => (
            <Card key={course.courseId} className="flex flex-col gap-4 border-2 border-ink bg-gold-tint p-6">
              <div className="flex items-center justify-between">
                <Award size={28} className="text-gold-dark" />
                <span className="text-[11px] font-semibold uppercase tracking-[0.05em] text-ink-soft">
                  Certificate of Completion
                </span>
              </div>
              <div>
                <h3 className="font-display text-[18px] font-semibold text-ink">{course.title}</h3>
                <p className="mt-1 text-[13px] text-ink-soft">Awarded to {session?.fullName ?? "Learner"}</p>
                <p className="mt-1 text-[12px] text-ink-soft/70">
                  Completed {formatDate(course.purchasedAt)}
                </p>
              </div>
              <div className="flex items-center gap-1.5 text-[11px] text-ink-soft">
                <ShieldCheck size={13} /> Verification ID: {verificationId(course.courseId)}
              </div>
              <Button size="sm" variant="secondary" className="mt-2 w-fit">
                <Download size={15} /> Download (demo)
              </Button>
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}