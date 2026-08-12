import { notFound } from "next/navigation";
import { MentorshipBookingClient } from "./MentorshipBookingClient";

// TODO: replace with useMentor(instructorSlug) hook from @saachi/api-client
export interface MentorTimeSlot {
  id: string;
  label: string;
}

export interface MentorProfile {
  slug: string;
  name: string;
  title: string;
  avatar: string;
  bio: string;
  rate: string;
  availableSlots: MentorTimeSlot[];
}

const DUMMY_MENTORS: Record<string, MentorProfile> = {
  "dr-sarah-chen": {
    slug: "dr-sarah-chen",
    name: "Dr. Sarah Chen",
    title: "Lead AI Architect",
    avatar: "https://i.pravatar.cc/128?img=32",
    bio: "Sarah offers 1:1 mentorship on LLM architecture, RAG systems, and prompt engineering best practices.",
    rate: "$120 / session",
    availableSlots: [
      { id: "s1", label: "Tomorrow, 10:00 AM EST" },
      { id: "s2", label: "Tomorrow, 2:00 PM EST" },
      { id: "s3", label: "Thursday, 11:30 AM EST" },
    ],
  },
  "marcus-johnson": {
    slug: "marcus-johnson",
    name: "Marcus Johnson",
    title: "Sr. Data Scientist",
    avatar: "https://i.pravatar.cc/128?img=13",
    bio: "Marcus specializes in model fine-tuning strategies and helping teams choose between LoRA and full fine-tuning.",
    rate: "$95 / session",
    availableSlots: [
      { id: "s1", label: "Friday, 9:00 AM EST" },
      { id: "s2", label: "Friday, 1:00 PM EST" },
    ],
  },
};

function getMentorBySlug(slug: string): MentorProfile | null {
  return DUMMY_MENTORS[slug] ?? null;
}

interface MentorshipBookingPageProps {
  params: Promise<{ instructorSlug: string }>;
}

export default async function MentorshipBookingPage({ params }: MentorshipBookingPageProps) {
  const { instructorSlug } = await params;
  const mentor = getMentorBySlug(instructorSlug);

  if (!mentor) {
    notFound();
  }

  return <MentorshipBookingClient mentor={mentor} />;
}