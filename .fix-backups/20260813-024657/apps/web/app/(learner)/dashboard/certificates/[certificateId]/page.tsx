"use client";

import Link from "next/link";
import { Button } from "antd";
import {
  ArrowLeft,
  X,
  ShieldCheck,
  Share2,
  Twitter,
  FileText,
  ImageIcon,
} from "lucide-react";

// TODO: replace with useCertificate(certificateId) hook from @saachi/api-client
interface CertificateData {
  recipientName: string;
  courseTitle: string;
  issuedDate: string;
  certificateId: string;
  signatoryName: string;
  signatoryTitle: string;
  signatureImage: string;
  sealImage: string;
}

const certificate: CertificateData = {
  recipientName: "Alex Morgan",
  courseTitle: "Advanced Machine Learning Algorithms",
  issuedDate: "October 24, 2024",
  certificateId: "SAI-8472-991",
  signatoryName: "Dr. Evelyn Reed",
  signatoryTitle: "Lead AI Instructor",
  signatureImage: "https://placehold.co/88x48",
  sealImage: "https://placehold.co/96x96",
};

export default function CertificateDetailsPage() {
  function handleVerify() {
    // TODO: wire to useCertificate().verify() from @saachi/api-client
    console.log("verify certificate", certificate.certificateId);
  }

  function handleAddToLinkedIn() {
    // TODO: open LinkedIn "Add to Profile" share URL with certificate details
    console.log("share to LinkedIn", certificate.certificateId);
  }

  function handleShareOnTwitter() {
    // TODO: open Twitter intent URL with certificate details
    console.log("share to Twitter", certificate.certificateId);
  }

  function handleDownload(format: "pdf" | "png") {
    // TODO: wire to useCertificate().download(format) from @saachi/api-client
    console.log("download certificate", format, certificate.certificateId);
  }

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      {/* Simplified top nav -- focused/transactional view */}
      <header className="sticky top-0 z-50 h-16 bg-[var(--token-color-bg)] shadow-[var(--token-shadow-sm)]">
        <div className="mx-auto flex h-full max-w-[1280px] items-center justify-between px-6">
          <Link href="/" className="text-2xl font-black" style={{ color: "var(--token-color-primary)" }}>
            Saachi AI
          </Link>
          <Link
            href="/dashboard/certificates"
            aria-label="Close"
            className="flex h-9 w-9 items-center justify-center rounded-full transition hover:bg-[var(--token-color-surfaceAlt)]"
          >
            <X size={18} color="var(--token-color-inkSoft)" />
          </Link>
        </div>
      </header>

      {/* Main content */}
      <main className="flex flex-1 flex-col items-center px-6 pb-24 pt-10">
        <div className="flex w-full max-w-[896px] flex-col gap-1.5 pb-6">
          <Link
            href="/dashboard/certificates"
            className="flex w-fit items-center gap-2 text-sm font-semibold tracking-wide"
            style={{ color: "var(--token-color-inkSoft)" }}
          >
            <ArrowLeft size={12} />
            Back to Dashboard
          </Link>
        </div>

        <div className="grid w-full max-w-[896px] grid-cols-1 gap-6 lg:grid-cols-12">
          {/* Main certificate visual (8 cols) */}
          <div
            className="relative flex min-h-[500px] flex-col items-center justify-center overflow-hidden rounded-xl border bg-[var(--token-color-surface)] px-10 py-16 shadow-[var(--token-shadow-md)] lg:col-span-8"
            style={{ borderColor: "var(--token-color-border)" }}
          >
            {/* Decorative corner overlays */}
            <div
              className="pointer-events-none absolute left-0 top-0 h-32 w-32 rounded-br-full"
              style={{ backgroundColor: "var(--token-color-primary)", opacity: 0.05 }}
            />
            <div
              className="pointer-events-none absolute bottom-0 right-0 h-48 w-48 rounded-tl-full"
              style={{ backgroundColor: "var(--token-color-primaryTint)", opacity: 0.4 }}
            />

            {/* Brand / org */}
            <div className="flex flex-col items-center gap-1.5 pb-4">
              <span
                className="text-2xl font-black uppercase tracking-wider"
                style={{ color: "var(--token-color-primary)" }}
              >
                Saachi AI
              </span>
              <span
                className="text-xs font-medium uppercase tracking-wider"
                style={{ color: "var(--token-color-inkSoft)" }}
              >
                Certificate of Completion
              </span>
            </div>

            {/* Recipient */}
            <div className="flex flex-col items-center gap-1.5 pt-6">
              <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
                This is to certify that
              </span>
              <h1
                className="text-5xl font-bold leading-[52.8px]"
                style={{ color: "var(--token-color-ink)", fontFamily: "'Liberation Serif', Georgia, serif" }}
              >
                {certificate.recipientName}
              </h1>
              <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
                has successfully completed the course
              </span>
            </div>

            {/* Course title */}
            <div className="max-w-96 pt-6">
              <h2
                className="text-center text-3xl font-bold leading-10"
                style={{ color: "var(--token-color-primaryHover)" }}
              >
                {certificate.courseTitle}
              </h2>
            </div>

            {/* Details */}
            <div className="flex items-center gap-10 pt-6">
              <div className="flex flex-col items-center gap-1">
                <span
                  className="text-xs font-medium uppercase tracking-tight"
                  style={{ color: "var(--token-color-inkSoft)" }}
                >
                  Date
                </span>
                <span
                  className="text-sm font-semibold tracking-wide"
                  style={{ color: "var(--token-color-ink)" }}
                >
                  {certificate.issuedDate}
                </span>
              </div>

              <span className="h-8 w-px" style={{ backgroundColor: "var(--token-color-border)" }} />

              <div className="flex flex-col items-center gap-1">
                <span
                  className="text-xs font-medium uppercase tracking-tight"
                  style={{ color: "var(--token-color-inkSoft)" }}
                >
                  Certificate ID
                </span>
                <span
                  className="text-sm font-semibold tracking-wide"
                  style={{ color: "var(--token-color-ink)", fontFamily: "monospace" }}
                >
                  {certificate.certificateId}
                </span>
              </div>
            </div>

            {/* Signature */}
            <div className="absolute bottom-10 left-10 flex flex-col items-center gap-0.5">
              <img
                src={certificate.signatureImage}
                alt={`${certificate.signatoryName} signature`}
                className="h-12 w-24 object-contain opacity-80"
              />
              <span className="mb-1 h-px w-32" style={{ backgroundColor: "var(--token-color-border)" }} />
              <span className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
                {certificate.signatoryName}
              </span>
              <span className="text-[10px]" style={{ color: "var(--token-color-inkSoft)" }}>
                {certificate.signatoryTitle}
              </span>
            </div>

            {/* Official seal */}
            <img
              src={certificate.sealImage}
              alt="Official seal"
              className="absolute bottom-10 right-10 h-24 w-24 shadow-[var(--token-shadow-md)]"
            />
          </div>

          {/* Context & actions sidebar (4 cols) */}
          <div className="flex flex-col gap-6 lg:col-span-4">
            {/* Verification badge panel */}
            <div
              className="flex flex-col items-center gap-2 rounded-xl border bg-[var(--token-color-surface)] p-6 text-center shadow-[var(--token-shadow-md)]"
              style={{ borderColor: "var(--token-color-border)" }}
            >
              <span
                className="mb-2 flex h-16 w-16 items-center justify-center rounded-full"
                style={{ backgroundColor: "var(--token-color-successTint)" }}
              >
                <ShieldCheck size={28} color="var(--token-color-success)" />
              </span>

              <h3 className="text-2xl font-semibold" style={{ color: "var(--token-color-ink)" }}>
                Official Certificate
              </h3>

              <p style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
                This certificate is cryptographically signed and verifiable.
              </p>

              <Button
                type="primary"
                block
                size="large"
                icon={<ShieldCheck size={14} />}
                onClick={handleVerify}
                className="mt-2"
              >
                Verify Certificate
              </Button>
            </div>

            {/* Sharing panel */}
            <div
              className="flex flex-col gap-4 rounded-xl border bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-md)]"
              style={{ borderColor: "var(--token-color-border)" }}
            >
              <h4
                className="text-sm font-semibold uppercase tracking-wide"
                style={{ color: "var(--token-color-ink)" }}
              >
                Share Your Achievement
              </h4>

              <div className="flex flex-col gap-2">
                <Button
                  block
                  size="large"
                  icon={<Share2 size={14} />}
                  onClick={handleAddToLinkedIn}
                  style={{ backgroundColor: "#0A66C2", borderColor: "#0A66C2", color: "#FFFFFF" }}
                >
                  Add to LinkedIn Profile
                </Button>
                <Button block size="large" icon={<Twitter size={14} />} onClick={handleShareOnTwitter}>
                  Share on Twitter
                </Button>
              </div>
            </div>

            {/* Downloads panel */}
            <div
              className="flex flex-col gap-4 rounded-xl border bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-md)]"
              style={{ borderColor: "var(--token-color-border)" }}
            >
              <h4
                className="text-sm font-semibold uppercase tracking-wide"
                style={{ color: "var(--token-color-ink)" }}
              >
                Downloads
              </h4>

              <div className="flex justify-center gap-2">
                <Button
                  className="flex-1"
                  size="large"
                  onClick={() => handleDownload("pdf")}
                  icon={<FileText size={18} />}
                >
                  PDF
                </Button>
                <Button
                  className="flex-1"
                  size="large"
                  onClick={() => handleDownload("png")}
                  icon={<ImageIcon size={18} />}
                >
                  PNG
                </Button>
              </div>
            </div>
          </div>
        </div>
      </main>

      {/* Minimal footer */}
      <footer className="bg-zinc-200 px-6 py-10">
        <div
          className="mx-auto flex h-12 max-w-[1280px] items-center justify-between border-t pt-6"
          style={{ borderColor: "var(--token-color-border)" }}
        >
          <span className="text-base font-bold" style={{ color: "var(--token-color-primary)" }}>
            Saachi AI
          </span>
          <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
            &copy; {new Date().getFullYear()} Saachi AI Marketplace. Empowering the future of skills.
          </span>
        </div>
      </footer>
    </div>
  );
}