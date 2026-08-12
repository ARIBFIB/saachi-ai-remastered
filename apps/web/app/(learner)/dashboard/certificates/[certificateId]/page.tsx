import { CertificateDetailClient } from "./CertificateDetailClient";

interface CertificatePageProps {
  params: Promise<{ certificateId: string }>;
}

export default async function CertificateDetailsPage({ params }: CertificatePageProps) {
  const { certificateId } = await params;
  return <CertificateDetailClient certificateId={certificateId} />;
}