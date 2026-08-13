import { MentorshipBookingClient } from "./MentorshipBookingClient";

interface MentorshipBookingPageProps {
  params: Promise<{ instructorSlug: string }>;
}

export default async function MentorshipBookingPage({ params }: MentorshipBookingPageProps) {
  const { instructorSlug } = await params;
  return <MentorshipBookingClient instructorSlug={instructorSlug} />;
}