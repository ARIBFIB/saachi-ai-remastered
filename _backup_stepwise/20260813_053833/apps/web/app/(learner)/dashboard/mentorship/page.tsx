"use client";

import Link from "next/link";
import Image from "next/image";
import { Button } from "antd";
import {
  LayoutGrid,
  GraduationCap,
  Heart,
  Settings,
  HelpCircle,
  Plus,
  History,
  Clock,
  FileText,
} from "lucide-react";

// TODO: replace with useMentorshipSessions() hook from @saachi/api-client
interface UpcomingSession {
  id: string;
  mentorName: string;
  mentorTitle: string;
  mentorAvatar: string;
  title: string;
  description: string;
  scheduledLabel: string;
  badge: "starting-now" | "tomorrow" | "scheduled";
  slug: string;
}

interface PastSession {
  id: string;
  month: string;
  day: string;
  title: string;
  mentorName: string;
  mentorAvatar: string;
  durationMinutes: number;
}

const upcomingSessions: UpcomingSession[] = [
  {
    id: "u1",
    mentorName: "Dr. Sarah Chen",
    mentorTitle: "Lead AI Architect",
    mentorAvatar: "https://i.pravatar.cc/96?img=32",
    title: "Advanced RAG Implementation",
    description: "Reviewing architecture choices for the new vector...",
    scheduledLabel: "Today, 10:00 AM PST",
    badge: "starting-now",
    slug: "dr-sarah-chen",
  },
  {
    id: "u2",
    mentorName: "Marcus Johnson",
    mentorTitle: "Sr. Data Scientist",
    mentorAvatar: "https://i.pravatar.cc/96?img=13",
    title: "Model Fine-Tuning Strategies",
    description: "Discussing LoRA vs full fine-tuning for domain-specific...",
    scheduledLabel: "Oct 24, 2:30 PM PST",
    badge: "tomorrow",
    slug: "marcus-johnson",
  },
];

const pastSessions: PastSession[] = [
  {
    id: "p1",
    month: "OCT",
    day: "18",
    title: "Career Progression in MLOps",
    mentorName: "Elena Rodriguez",
    mentorAvatar: "https://i.pravatar.cc/48?img=45",
    durationMinutes: 45,
  },
  {
    id: "p2",
    month: "OCT",
    day: "12",
    title: "Code Review: API Gateway Optimization",
    mentorName: "Dr. Sarah Chen",
    mentorAvatar: "https://i.pravatar.cc/48?img=32",
    durationMinutes: 60,
  },
];

const navItems = [
  { icon: LayoutGrid, label: "Dashboard", href: "/dashboard" },
  { icon: GraduationCap, label: "My Courses", href: "/dashboard/my-courses" },
  { icon: Heart, label: "Wishlist", href: "/dashboard/wishlist" },
  { icon: Settings, label: "Settings", href: "/dashboard/settings" },
];

export default function MentorshipSessionsPage() {
  function handleViewNotes(sessionId: string) {
    // TODO: wire to /dashboard/mentorship/notes/{sessionId} or a modal via @saachi/api-client
    console.log("view notes", sessionId);
  }

  return (
    <div className="flex min-h-screen bg-[var(--token-color-bg)]">
      {/* Sidebar -- kept white/light to match the rest of the dashboard */}
      <aside className="fixed inset-y-0 left-0 hidden w-72 flex-col border-r border-[var(--token-color-border)] bg-[var(--token-color-surfaceAlt)] lg:flex">
        <div className="flex items-center gap-4 border-b border-[var(--token-color-border)] p-6">
          <span className="relative block h-12 w-12 shrink-0 overflow-hidden rounded-full">
            <Image src="https://i.pravatar.cc/96?img=47" alt="Learner avatar" fill sizes="48px" className="object-cover" />
          </span>
          <div className="flex flex-col">
            <span className="text-2xl font-bold" style={{ color: "var(--token-color-ink)" }}>
              Learner Portal
            </span>
            <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
              Manage your skills
            </span>
          </div>
        </div>

        <nav className="flex flex-1 flex-col gap-2 py-4">
          {navItems.map(({ icon: Icon, label, href }) => {
            const isActive = label === "My Courses";
            return (
              <Link
                key={label}
                href={href}
                className="flex h-12 items-center gap-4 border-l-4 pl-4 pr-6 text-sm font-semibold tracking-wide transition"
                style={{
                  borderColor: isActive ? "var(--token-color-amber)" : "transparent",
                  backgroundColor: isActive ? "var(--token-color-amberTint)" : "transparent",
                  color: isActive ? "var(--token-color-amber)" : "var(--token-color-inkSoft)",
                }}
              >
                <Icon size={18} />
                {label}
              </Link>
            );
          })}
        </nav>

        <div className="border-t border-[var(--token-color-border)] p-4">
          <Link
            href="/support"
            className="flex h-12 items-center gap-4 pl-4 text-sm font-semibold tracking-wide text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-amber)]"
          >
            <HelpCircle size={18} />
            Help Center
          </Link>
        </div>
      </aside>

      {/* Main column */}
      <div className="flex w-full flex-col lg:pl-72">
        <main className="flex-1 px-12 py-10">
          <div className="flex flex-col gap-10">
            {/* Header */}
            <div className="flex items-start justify-between">
              <div className="flex flex-col gap-1">
                <h1 className="text-5xl font-bold leading-[52.8px]" style={{ color: "var(--token-color-ink)" }}>
                  Mentorship Sessions
                </h1>
                <p style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-lg)" }}>
                  Manage your upcoming technical guidance and view past session notes.
                </p>
              </div>

              <Link href="/dashboard/mentorship/book">
                <Button type="primary" size="large" icon={<Plus size={14} />}>
                  Book Session
                </Button>
              </Link>
            </div>

            {/* Upcoming sessions */}
            <section className="flex flex-col gap-6">
              <div className="flex items-center gap-2">
                <History size={20} color="var(--token-color-amber)" style={{ transform: "scaleX(-1)" }} />
                <h2 className="text-2xl font-semibold" style={{ color: "var(--token-color-ink)" }}>
                  Upcoming
                </h2>
              </div>

              <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
                {upcomingSessions.map((session) => (
                  <UpcomingSessionCard key={session.id} session={session} />
                ))}
              </div>
            </section>

            {/* Past sessions */}
            <section className="flex flex-col gap-6">
              <div className="flex items-center gap-2">
                <History size={18} color="var(--token-color-inkSoft)" />
                <h2 className="text-2xl font-semibold" style={{ color: "var(--token-color-ink)" }}>
                  Past Sessions
                </h2>
              </div>

              <div
                className="overflow-hidden rounded-[var(--token-radius-lg)] border bg-[var(--token-color-surface)] shadow-[var(--token-shadow-md)]"
                style={{ borderColor: "var(--token-color-border)" }}
              >
                {pastSessions.map((session, idx) => (
                  <div
                    key={session.id}
                    className="flex items-center justify-between px-6 py-6"
                    style={idx > 0 ? { borderTop: "1px solid var(--token-color-border)" } : undefined}
                  >
                    <div className="flex flex-1 items-center gap-6">
                      <div
                        className="flex h-16 w-16 shrink-0 flex-col items-center justify-center gap-0 rounded-[var(--token-radius-md)] py-3"
                        style={{ backgroundColor: "var(--token-color-surfaceAlt)" }}
                      >
                        <span
                          className="text-xs font-medium uppercase"
                          style={{ color: "var(--token-color-inkSoft)" }}
                        >
                          {session.month}
                        </span>
                        <span className="text-2xl font-bold" style={{ color: "var(--token-color-ink)" }}>
                          {session.day}
                        </span>
                      </div>

                      <div className="flex flex-col items-start gap-1">
                        <h4 className="text-2xl font-semibold" style={{ color: "var(--token-color-ink)" }}>
                          {session.title}
                        </h4>
                        <div className="flex items-center gap-4">
                          <span className="flex items-center gap-1">
                            <span className="relative block h-6 w-6 overflow-hidden rounded-full">
                              <Image
                                src={session.mentorAvatar}
                                alt={session.mentorName}
                                fill
                                sizes="24px"
                                className="object-cover"
                              />
                            </span>
                            <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
                              {session.mentorName}
                            </span>
                          </span>
                          <span
                            className="block h-1 w-1 rounded-full"
                            style={{ backgroundColor: "var(--token-color-textMuted)" }}
                          />
                          <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
                            {session.durationMinutes} mins
                          </span>
                        </div>
                      </div>
                    </div>

                    <Button
                      type="link"
                      icon={<FileText size={14} />}
                      onClick={() => handleViewNotes(session.id)}
                      style={{ color: "var(--token-color-amber)", fontWeight: 600 }}
                    >
                      View Notes
                    </Button>
                  </div>
                ))}
              </div>
            </section>
          </div>
        </main>
      </div>
    </div>
  );
}

function UpcomingSessionCard({ session }: { session: UpcomingSession }) {
  const isStartingNow = session.badge === "starting-now";

  return (
    <div
      className="flex flex-col justify-between rounded-[var(--token-radius-lg)] border bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-md)]"
      style={{
        borderColor: isStartingNow ? "var(--token-color-amber)" : "var(--token-color-border)",
        borderWidth: isStartingNow ? 1 : 1,
      }}
    >
      <div className="flex flex-col gap-4 pb-6">
        <div className="flex items-start justify-between">
          <div className="flex items-center gap-4">
            <span className="relative block h-12 w-12 shrink-0 overflow-hidden rounded-full">
              <Image
                src={session.mentorAvatar}
                alt={session.mentorName}
                fill
                sizes="48px"
                className="object-cover"
              />
            </span>
            <div className="flex flex-col">
              <span className="text-sm font-bold tracking-wide" style={{ color: "var(--token-color-ink)" }}>
                {session.mentorName}
              </span>
              <span className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
                {session.mentorTitle}
              </span>
            </div>
          </div>

          {isStartingNow ? (
            <span
              className="flex items-center gap-1.5 rounded-full px-3 py-1 text-xs font-medium"
              style={{ backgroundColor: "var(--token-color-amberTint)", color: "var(--token-color-amber)" }}
            >
              <span className="h-1.5 w-1.5 rounded-full" style={{ backgroundColor: "var(--token-color-amber)" }} />
              Starting Now
            </span>
          ) : (
            <span
              className="rounded-full px-2 py-1 text-xs font-medium"
              style={{ backgroundColor: "var(--token-color-surfaceAlt)", color: "var(--token-color-inkSoft)" }}
            >
              Tomorrow
            </span>
          )}
        </div>

        <div className="flex flex-col gap-2">
          <h5 className="text-2xl font-semibold" style={{ color: "var(--token-color-ink)" }}>
            {session.title}
          </h5>
          <p style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
            {session.description}
          </p>
        </div>
      </div>

      <div
        className="flex items-center justify-between pt-4"
        style={{ borderTop: "1px solid var(--token-color-border)" }}
      >
        <span className="flex items-center gap-2">
          <Clock size={14} color="var(--token-color-inkSoft)" />
          <span className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
            {session.scheduledLabel}
          </span>
        </span>

        {isStartingNow ? (
          <Button type="primary">Join Meeting</Button>
        ) : (
          <Link href={`/dashboard/mentorship/${session.slug}/reschedule`}>
            <Button>Reschedule</Button>
          </Link>
        )}
      </div>
    </div>
  );
}