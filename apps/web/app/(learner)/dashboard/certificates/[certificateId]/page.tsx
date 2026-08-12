import { notFound } from "next/navigation";
import { CertificateDetailClient } from "./CertificateDetailClient";

// TODO: replace with useCertificate(certificateId) hook from @saachi/api-client
export interface CertificateDetail {
  id: string;
  title: string;
  category: string;
  issuedDate: string;
  recipientName: string;
  instructorName: string;
  credentialId: string;
  image: string;
}

const DUMMY_CERTIFICATES: Record<string, CertificateDetail> = {
  cert1: {
    id: "cert1",
    title: "Advanced Machine Learning Architectures",
    category: "AI & Data",
    issuedDate: "Oct 12, 2024",
    recipientName: "Alex Morgan",
    instructorName: "Dr. Sarah Chen",
    credentialId: "SAI-CERT-88213",
    image:
      "https://images.unsplash.com/photo-1620712943543-bcc4688e7485?auto=format&fit=crop&w=800&q=80",
  },
  cert2: {
    id: "cert2",
    title: "Ethical AI Governance & Policy",
    category: "Ethics",
    issuedDate: "Sep 05, 2024",
    recipientName: "Alex Morgan",
    instructorName: "Marcus Johnson",
    credentialId: "SAI-CERT-77104",
    image:
      "https://images.unsplash.com/photo-1450101499163-c8848c66ca85?auto=format&fit=crop&w=800&q=80",
  },
  cert3: {
    id: "cert3",
    title: "Python for Data Science Bootcamp",
    category: "Programming",
    issuedDate: "Jul 22, 2024",
    recipientName: "Alex Morgan",
    instructorName: "David Kim",
    credentialId: "SAI-CERT-65590",
    image:
      "https://images.unsplash.com/photo-1526379879527-8559ecfcaec0?auto=format&fit=crop&w=800&q=80",
  },
};

function getCertificateById(certificateId: string): CertificateDetail | null {
  return DUMMY_CERTIFICATES[certificateId] ?? null;
}

interface CertificateDetailPageProps {
  params: Promise<{ certificateId: string }>;
}

export default async function CertificateDetailPage({ params }: CertificateDetailPageProps) {
  const { certificateId } = await params;
  const certificate = getCertificateById(certificateId);

  if (!certificate) {
    notFound();
  }

  return <CertificateDetailClient certificate={certificate} />;
}