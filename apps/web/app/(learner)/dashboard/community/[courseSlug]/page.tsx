import { notFound } from "next/navigation";
import { CommunityQAClient } from "./CommunityQAClient";

// TODO: replace with useCourseCommunity(courseSlug) hook from @saachi/api-client
export interface QAThread {
  id: string;
  authorName: string;
  authorAvatar: string;
  question: string;
  timestamp: string;
  replyCount: number;
  upvotes: number;
}

export interface CommunityCourse {
  slug: string;
  title: string;
  threads: QAThread[];
}

const DUMMY_COMMUNITIES: Record<string, CommunityCourse> = {
  "prompt-engineering-masterclass": {
    slug: "prompt-engineering-masterclass",
    title: "Prompt Engineering Masterclass",
    threads: [
      {
        id: "t1",
        authorName: "Jordan Lee",
        authorAvatar: "https://i.pravatar.cc/64?img=15",
        question: "What's the difference between few-shot and chain-of-thought prompting in practice?",
        timestamp: "2 hours ago",
        replyCount: 4,
        upvotes: 12,
      },
      {
        id: "t2",
        authorName: "Priya Nair",
        authorAvatar: "https://i.pravatar.cc/64?img=25",
        question: "Anyone have a good template for reducing hallucinations in factual Q&A prompts?",
        timestamp: "Yesterday",
        replyCount: 7,
        upvotes: 21,
      },
    ],
  },
};

function getCommunityBySlug(slug: string): CommunityCourse | null {
  return DUMMY_COMMUNITIES[slug] ?? null;
}

interface CommunityPageProps {
  params: Promise<{ courseSlug: string }>;
}

export default async function CommunityPage({ params }: CommunityPageProps) {
  const { courseSlug } = await params;
  const community = getCommunityBySlug(courseSlug);

  if (!community) {
    notFound();
  }

  return <CommunityQAClient community={community} />;
}