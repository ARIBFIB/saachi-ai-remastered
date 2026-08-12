import { CommunityQAClient } from "./CommunityQAClient";

interface CommunityPageProps {
  params: Promise<{ courseSlug: string }>;
}

export default async function CommunityQAPage({ params }: CommunityPageProps) {
  const { courseSlug } = await params;
  return <CommunityQAClient courseSlug={courseSlug} />;
}