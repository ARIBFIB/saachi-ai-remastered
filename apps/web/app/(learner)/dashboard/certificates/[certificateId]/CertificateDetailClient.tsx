"use client";

import Link from "next/link";
import Image from "next/image";
import { Button } from "antd";
import { ArrowLeft, Download, Share2, BadgeCheck } from "lucide-react";
import type { CertificateDetail } from "./page";

interface CertificateDetailClientProps {
  certificate: CertificateDetail;
}

export function CertificateDetailClient({ certificate }: CertificateDetailClientProps) {
  function handleDownload() {
    // TODO: wire to useCertificates().download(certificate.id) from @saachi/api-client
    console.log("download certificate", certificate.id);
  }

  function handleShare() {
    // TODO: wire to share sheet / copy public credential link
    console.log("share certificate", certificate.id);
  }

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)] px-6 py-10">
      <div className="mx-auto flex w-full max-w-[900px] flex-col gap-6">
        <Link
          href="/dashboard/certificates"
          className="flex w-fit items-center gap-2 text-sm font-semibold text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]"
        >
          <ArrowLeft size={14} />
          Back to Certificates
        </Link>

        <div className="overflow-hidden rounded-2xl border bg-[var(--token-color-surface)] shadow-[var(--token-shadow-lg)]" style={{ borderColor: "var(--token-color-border)" }}>
          <div className="relative h-72 w-full bg-[var(--token-color-surfaceAlt)]">
            <Image src={certificate.image} alt={certificate.title} fill sizes="900px" className="object-cover" />
          </div>

          <div className="flex flex-col gap-6 p-8">
            <div className="flex items-start justify-between gap-4">
              <div className="flex flex-col gap-1">
                <span className="flex items-center gap-1.5 text-xs font-semibold uppercase tracking-wide" style={{ color: "var(--token-color-primary)" }}>
                  <BadgeCheck size={14} />
                  {certificate.category}
                </span>
                <h1 className="text-3xl font-bold" style={{ color: "var(--token-color-ink)" }}>
                  {certificate.title}
                </h1>
              </div>
            </div>

            <div className="grid grid-cols-1 gap-4 rounded-lg p-4 sm:grid-cols-3" style={{ backgroundColor: "var(--token-color-surfaceAlt)" }}>
              <DetailField label="Recipient" value={certificate.recipientName} />
              <DetailField label="Instructor" value={certificate.instructorName} />
              <DetailField label="Issued" value={certificate.issuedDate} />
            </div>

            <div className="flex items-center justify-between border-t pt-4" style={{ borderColor: "var(--token-color-border)" }}>
              <span className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
                Credential ID: {certificate.credentialId}
              </span>

              <div className="flex gap-2">
                <Button icon={<Share2 size={14} />} onClick={handleShare}>
                  Share
                </Button>
                <Button type="primary" icon={<Download size={14} />} onClick={handleDownload}>
                  Download PDF
                </Button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function DetailField({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex flex-col gap-0.5">
      <span className="text-xs font-medium uppercase tracking-wide" style={{ color: "var(--token-color-inkSoft)" }}>
        {label}
      </span>
      <span className="text-sm font-semibold" style={{ color: "var(--token-color-ink)" }}>
        {value}
      </span>
    </div>
  );
}