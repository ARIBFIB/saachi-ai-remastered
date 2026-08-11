import { Header } from "@/components/marketing/Header";
import { CompactFooter } from "@/components/marketing/CompactFooter";
import { AboutHero } from "@/components/about/AboutHero";
import { CoreDirectivesGrid } from "@/components/about/CoreDirectivesGrid";
import { TeamGrid, type TeamMember } from "@/components/about/TeamGrid";

const team: TeamMember[] = [
  {
    name: "Dr. Elena Rostova",
    role: "Chief Executive Officer",
    avatar:
      "https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=400&q=80",
  },
  {
    name: "Marcus Vance",
    role: "Chief Technology Officer",
    avatar:
      "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=400&q=80",
  },
  {
    name: "Sarah Jenkins",
    role: "Head of Product",
    avatar:
      "https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=400&q=80",
  },
  {
    name: "Raj Patel",
    role: "Lead Data Scientist",
    avatar:
      "https://images.unsplash.com/photo-1633332755192-727a05c4013d?auto=format&fit=crop&w=400&q=80",
  },
];

export default function AboutPage() {
  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <Header />

      <main className="mx-auto flex w-full max-w-[1280px] flex-1 flex-col gap-24 px-12 py-32">
        <AboutHero
          heading="Empowering the Future of Skills."
          description="Saachi AI is pioneering the intersection of artificial intelligence and professional development. We build predictive learning ecosystems that adapt to your career trajectory, cutting through noise to deliver targeted mastery."
          image="https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=1200&q=80"
        />

        <CoreDirectivesGrid
          missionTitle="Mission Statement"
          missionBody="To democratize access to high-tier professional mentorship through scalable, AI-driven learning pathways. We believe that mastery should not be gated by geography or timeline, but guided by intelligent, responsive curriculum."
        />

        <TeamGrid heading="Architects of Saachi" members={team} />
      </main>

      <CompactFooter />
    </div>
  );
}