"use client";

import { useParams } from "next/navigation";
import Link from "next/link";
import { Award, Download, ShieldCheck, CalendarDays } from "lucide-react";
import { useCertificateDetail } from "@saachi/api-client";
import { Button, Loading, EmptyState } from "@saachi/ui";

export default function CertificateDetailPage() {
  const params = useParams<{ id: string }>();
  const { data: certificate, isLoading } = useCertificateDetail(params.id);

  if (isLoading) {
    return (
      <div className="mx-auto max-w-3xl px-4 py-16 md:px-0">
        <Loading label="Loading certificate..." />
      </div>
    );
  }

  if (!certificate) {
    return (
      <div className="mx-auto max-w-3xl px-4 py-16 md:px-0">
        <EmptyState
          title="Certificate not found"
          description="This certificate ID is invalid or the certificate has been revoked."
          action={
            <Link href="/">
              <Button>Back to homepage</Button>
            </Link>
          }
        />
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-3xl px-4 py-16 md:px-0">
      <div className="mb-8 flex items-center gap-2 text-[13px] font-medium text-teal">
        <ShieldCheck size={16} />
        Verified certificate
      </div>

      <div className="rounded-card border-2 border-gold-dark/40 bg-card p-10 text-center">
        <div className="mx-auto mb-5 flex h-16 w-16 items-center justify-center rounded-full bg-gold-tint text-gold-dark">
          <Award size={30} />
        </div>

        <p className="mb-1 text-[13px] uppercase tracking-[0.08em] text-ink-soft">Certificate of Completion</p>
        <h1 className="mb-6 font-display text-[26px] font-bold text-ink">{certificate.courseTitle}</h1>

        <p className="mb-1 text-[13px] text-ink-soft">This certifies that</p>
        <p className="mb-6 font-display text-[22px] font-semibold text-ink">{certificate.learnerName}</p>

        <p className="mb-8 text-[14px] text-ink-soft">
          has successfully completed the course instructed by{" "}
          <span className="font-semibold text-ink">{certificate.instructorName}</span>
        </p>

        <div className="mb-8 flex flex-wrap items-center justify-center gap-6 text-[13px] text-ink-soft">
          <span className="flex items-center gap-1.5">
            <CalendarDays size={14} /> Issued {new Intl.DateTimeFormat("en-US", { dateStyle: "long" }).format(new Date(certificate.issuedAt))}
          </span>
          <span className="font-mono text-[12px]">ID: {certificate.verificationId}</span>
        </div>

        <Button size="lg">
          <Download size={15} className="mr-1.5" />
          Download PDF
        </Button>
      </div>

      <p className="mt-6 text-center text-[12.5px] text-ink-soft">
        Anyone with this link can verify the authenticity of this certificate via its unique verification ID.
      </p>
    </div>
  );
}