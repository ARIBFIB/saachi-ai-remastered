"use client";

import Link from "next/link";
import { Button } from "antd";
import { Award, Download, Share2, CheckCircle2, ArrowLeft } from "lucide-react";

// TODO: replace with useCertificate(certificateId) hook from @saachi/api-client
interface CertificateRecord {
  id: string;
  title: string;
  learnerName: string;
  issuedDate: string;
  verificationId: string;
  category: string;
}

function getDummyCertificate(certificateId: string): CertificateRecord {
  return {
    id: certificateId,
    title: "Advanced Machine Learning Architectures",
    learnerName: "Alex Morgan",
    issuedDate: "Oct 12, 2024",
    verificationId: `SAI-CERT-${certificateId.toUpperCase()}`,
    category: "AI & Data",
  };
}

export function CertificateDetailClient({ certificateId }: { certificateId: string }) {
  const certificate = getDummyCertificate(certificateId);

  function handleDownload() {
    // TODO: wire to useCertificate(certificateId).downloadPdf() from @saachi/api-client
    console.log("download certificate", certificate.id);
  }

  function handleShare() {
    // TODO: wire to share sheet / copy verification link
    console.log("share certificate", certificate.id);
  }

  return (
    <div className="flex min-h-screen flex-col items-center bg-[var(--token-color-bg)] px-6 py-16">
      <div className="flex w-full max-w-[720px] flex-col gap-6">
        <Link
          href="/dashboard/certificates"
          className="flex items-center gap-1 text-sm font-semibold"
          style={{ color: "var(--token-color-inkSoft)" }}
        >
          <ArrowLeft size={14} />
          Back to Certificates
        </Link>

        <div
          className="flex flex-col items-center gap-6 rounded-[var(--token-radius-lg)] border-2 bg-[var(--token-color-surface)] p-12 text-center shadow-[var(--token-shadow-md)]"
          style={{ borderColor: "var(--token-color-amber)" }}
        >
          <span
            className="flex h-16 w-16 items-center justify-center rounded-full"
            style={{ backgroundColor: "var(--token-color-amberTint)" }}
          >
            <Award size={28} color="var(--token-color-amber)" />
          </span>

          <div className="flex flex-col gap-1">
            <span
              className="text-xs font-semibold uppercase tracking-wide"
              style={{ color: "var(--token-color-inkSoft)" }}
            >
              Certificate of Completion
            </span>
            <h1 className="text-3xl font-bold" style={{ color: "var(--token-color-ink)" }}>
              {certificate.title}
            </h1>
          </div>

          <p style={{ color: "var(--token-color-inkSoft)" }}>
            Awarded to <span className="font-semibold">{certificate.learnerName}</span> on{" "}
            {certificate.issuedDate}
          </p>

          <div
            className="flex items-center gap-2 rounded-full px-4 py-2 text-xs font-semibold"
            style={{ backgroundColor: "var(--token-color-successTint)", color: "var(--token-color-success)" }}
          >
            <CheckCircle2 size={14} />
            Verified &middot; ID: {certificate.verificationId}
          </div>

          <div className="flex gap-4 pt-4">
            <Button type="primary" icon={<Download size={14} />} onClick={handleDownload}>
              Download PDF
            </Button>
            <Button icon={<Share2 size={14} />} onClick={handleShare}>
              Share
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}