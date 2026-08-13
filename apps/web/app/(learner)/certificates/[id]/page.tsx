"use client";

import { useParams } from "next/navigation";
import { Award, CheckCircle2, Download } from "lucide-react";
import { useEnrollmentStore } from "@saachi/store";
import { Button, EmptyState } from "@saachi/ui";

export default function CertificateVerificationPage() {
  const params = useParams<{ id: string }>();
  const enrollments = useEnrollmentStore((s) => s.enrollments);
  const certificate = enrollments.find(
    (e) => e.courseId === params.id && e.progressPercent === 100
  );

  if (!certificate) {
    return (
      <div className="mx-auto max-w-lg py-16">
        <EmptyState
          title="Certificate not found"
          description="This certificate ID doesn't match a completed course, or has been revoked."
        />
      </div>
    );
  }

  const verificationId = `SAI-CERT-${certificate.courseId.slice(0, 8).toUpperCase()}`;

  return (
    <div className="mx-auto max-w-2xl py-10">
      <div className="rounded-card border border-gold-dark/30 bg-gold-tint p-8 text-center">
        <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-card text-gold-dark">
          <Award size={30} />
        </div>
        <p className="text-[13px] font-semibold uppercase tracking-[0.08em] text-gold-dark">
          Certificate of Completion
        </p>
        <h1 className="mt-3 font-display text-[26px] font-bold text-ink">{certificate.title}</h1>
        <p className="mt-2 text-[14px] text-ink-soft">Instructed by {certificate.instructorName}</p>

        <div className="mx-auto mt-6 flex max-w-xs items-center justify-center gap-2 rounded-control bg-card px-4 py-2 text-[13px] text-ink-soft">
          <CheckCircle2 size={15} className="text-teal" />
          Verified - ID {verificationId}
        </div>

        <Button className="mt-6">
          <Download size={14} className="mr-1.5" />
          Download PDF
        </Button>
      </div>

      <p className="mt-6 text-center text-[12px] text-ink-soft/70">
        This certificate can be verified by anyone with this link. No login required.
      </p>
    </div>
  );
}