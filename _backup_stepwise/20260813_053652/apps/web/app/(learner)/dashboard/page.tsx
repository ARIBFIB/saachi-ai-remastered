"use client";

import Link from "next/link";
import Image from "next/image";
import { Progress, Button, Typography } from "antd";
import {
  LayoutGrid,
  GraduationCap,
  Heart,
  Settings,
  HelpCircle,
  Search,
  Bell,
  Sparkles,
  Calendar,
  BookOpen,
  Award,
  Timer,
  Star,
  ArrowRight,
  Bookmark,
} from "lucide-react";

const { Title, Text } = Typography;

// TODO: replace with useCourses() / a future useLearnerDashboard() hook from @saachi/api-client
const continueLearning = {
  track: "Generative AI Track",
  title: "Prompt Engineering Masterclass",
  description: "Master the art of crafting precise instructions for large language models...",
  progress: 45,
  image: "https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=600&q=80",
  href: "/courses/prompt-engineering-masterclass/learn",
};

const upcomingSession = {
  title: "1:1 Mentorship",
  mentorName: "Dr. Sarah Jenkins",
  mentorAvatar: "https://i.pravatar.cc/96?img=13",
  sessionTitle: "Model Fine-Tuning Review",
  sessionTime: "Tomorrow, 10:00 AM EST",
};

const stats = [
  { icon: BookOpen, label: "Active Courses", value: "3", tint: "primaryTint" as const },
  { icon: Award, label: "Certificates Earned", value: "12", tint: "successTint" as const },
  { icon: Timer, label: "Learning Hours", value: "148", tint: "surfaceAlt" as const },
];

interface RecommendedCourse {
  id: string;
  category: string;
  title: string;
  provider: string;
  level: string;
  rating: number;
  image: string;
}

const recommended: RecommendedCourse[] = [
  {
    id: "r1",
    category: "Data Science",
    title: "Applied Machine Learning Algorithms",
    provider: "Stanford Online",
    level: "Advanced",
    rating: 4.9,
    image: "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=600&q=80",
  },
  {
    id: "r2",
    category: "AI Ethics",
    title: "Responsible AI Implementation",
    provider: "Google Cloud",
    level: "Intermediate",
    rating: 4.8,
    image: "https://images.unsplash.com/photo-1620712943543-bcc4688e7485?auto=format&fit=crop&w=600&q=80",
  },
  {
    id: "r3",
    category: "Cloud Architecture",
    title: "Deploying LLMs at Scale",
    provider: "AWS Training",
    level: "Advanced",
    rating: 4.7,
    image: "https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=600&q=80",
  },
];

const navItems = [
  { icon: LayoutGrid, label: "Dashboard", href: "/dashboard" },
  { icon: GraduationCap, label: "My Courses", href: "/dashboard/my-courses" },
  { icon: Heart, label: "Wishlist", href: "/dashboard/wishlist" },
  { icon: Settings, label: "Settings", href: "/dashboard/settings" },
];

export default function LearnerDashboardPage() {
  return (
    <div className="flex min-h-screen bg-[var(--token-color-bg)]">
      {/* Sidebar */}
      <aside className="fixed inset-y-0 left-0 hidden w-72 flex-col border-r border-[var(--token-color-border)] bg-[var(--token-color-surfaceAlt)] lg:flex">
        <div className="flex items-center gap-4 border-b border-[var(--token-color-border)]/30 p-6">
          <span className="relative block h-10 w-10 shrink-0 overflow-hidden rounded-full ring-1 ring-[var(--token-color-border)]/50">
            <Image src="https://i.pravatar.cc/80?img=47" alt="Learner avatar" fill sizes="40px" className="object-cover" />
          </span>
          <div className="flex flex-col">
            <span className="font-bold" style={{ color: "var(--token-color-ink)", fontSize: "var(--token-font-size-lg)" }}>
              Learner Portal
            </span>
            <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-xs)" }}>
              Manage your skills
            </span>
          </div>
        </div>

        <nav className="flex flex-1 flex-col gap-1 py-4">
          {navItems.map(({ icon: Icon, label, href }) => {
            const isActive = label === "Dashboard";
            return (
              <Link
                key={label}
                href={href}
                className="flex items-center gap-4 border-l-4 px-4 py-3 text-sm font-semibold tracking-wide transition"
                style={{
                  borderColor: isActive ? "var(--token-color-primary)" : "transparent",
                  backgroundColor: isActive ? "var(--token-color-primaryTint)" : "transparent",
                  color: isActive ? "var(--token-color-primary)" : "var(--token-color-inkSoft)",
                }}
              >
                <Icon size={18} />
                {label}
              </Link>
            );
          })}
        </nav>

        <div className="border-t border-[var(--token-color-border)]/30 p-4">
          <Link
            href="/support"
            className="flex items-center gap-4 rounded-lg px-4 py-3 text-sm font-semibold tracking-wide text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-surface)]"
          >
            <HelpCircle size={18} />
            Help Center
          </Link>
        </div>
      </aside>

      {/* Main content */}
      <main className="w-full lg:pl-72">
        <div className="mx-auto flex max-w-[1100px] flex-col gap-10 p-12">
          {/* Welcome section */}
          <div className="flex items-end justify-between">
            <div className="flex flex-col gap-1.5">
              <Title level={1} style={{ margin: 0, color: "var(--token-color-ink)" }}>
                Welcome back, Alex.
              </Title>
              <Text style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-lg)" }}>
                Ready to pick up where you left off?
              </Text>
            </div>

            <div className="flex items-center gap-2">
              <button
                aria-label="Search"
                className="flex h-10 w-10 items-center justify-center rounded-full bg-[var(--token-color-surface)] shadow-[var(--token-shadow-md)]"
              >
                <Search size={18} color="var(--token-color-inkSoft)" />
              </button>
              <button
                aria-label="Notifications"
                className="relative flex h-10 w-10 items-center justify-center rounded-full bg-[var(--token-color-surface)] shadow-[var(--token-shadow-md)]"
              >
                <Bell size={18} color="var(--token-color-inkSoft)" />
                <span
                  className="absolute right-2 top-2 block h-2 w-2 rounded-full"
                  style={{ backgroundColor: "var(--token-color-notificationDot)" }}
                />
              </button>
            </div>
          </div>

          {/* Bento: continue learning + mentorship */}
          <div className="grid grid-cols-1 gap-6 xl:grid-cols-12">
            {/* Continue learning (spans 8) */}
            <div className="flex overflow-hidden rounded-xl border bg-[var(--token-color-surface)] shadow-[var(--token-shadow-md)] xl:col-span-8"
              style={{ borderColor: "var(--token-color-border)" }}
            >
              <div className="relative hidden w-60 shrink-0 bg-[var(--token-color-surfaceAlt)] sm:block">
                <Image src={continueLearning.image} alt={continueLearning.title} fill sizes="240px" className="object-cover" />
                <span className="absolute left-4 top-4 flex items-center gap-1 rounded-full bg-[var(--token-color-surface)]/90 px-3 pb-1 pt-[3px] text-xs font-medium text-[var(--token-color-primary)] shadow-[var(--token-shadow-sm)] backdrop-blur-[2px]">
                  <Sparkles size={12} />
                  In Progress
                </span>
              </div>

              <div className="flex flex-1 flex-col justify-between p-6">
                <div className="flex flex-col gap-2">
                  <div className="flex items-center gap-2">
                    <Sparkles size={12} color="var(--token-color-inkSoft)" />
                    <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-xs)" }}>
                      {continueLearning.track}
                    </span>
                  </div>
                  <Title level={3} style={{ margin: 0, color: "var(--token-color-ink)" }}>
                    {continueLearning.title}
                  </Title>
                  <Text style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
                    {continueLearning.description}
                  </Text>
                </div>

                <div className="flex flex-col gap-3 pt-6">
                  <div className="flex items-center justify-between">
                    <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-xs)" }}>
                      Course Progress
                    </span>
                    <span
                      className="font-bold"
                      style={{ color: "var(--token-color-primary)", fontSize: "var(--token-font-size-xs)" }}
                    >
                      {continueLearning.progress}%
                    </span>
                  </div>
                  <Progress percent={continueLearning.progress} showInfo={false} strokeColor="var(--token-color-primary)" />
                  <Link href={continueLearning.href}>
                    <Button type="primary" icon={<ArrowRight size={12} />} iconPosition="end">
                      Resume Learning
                    </Button>
                  </Link>
                </div>
              </div>
            </div>

            {/* Mentorship (spans 4) */}
            <div className="relative flex flex-col justify-between overflow-hidden rounded-xl border bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-md)] xl:col-span-4"
              style={{ borderColor: "var(--token-color-border)" }}
            >
              <div className="pointer-events-none absolute -right-8 -top-8 h-32 w-32 rounded-bl-full bg-[var(--token-color-primaryTint)]/30" />

              <div className="relative flex flex-col gap-1 pb-6">
                <span className="flex w-fit items-center gap-2 rounded-full bg-[var(--token-color-primaryTint)] px-3 py-1 text-xs font-medium text-[var(--token-color-primary)]">
                  <Calendar size={14} />
                  Upcoming Session
                </span>

                <Title level={3} style={{ margin: 0, paddingTop: 12, color: "var(--token-color-ink)" }}>
                  {upcomingSession.title}
                </Title>
                <Text style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)", paddingBottom: 12 }}>
                  with {upcomingSession.mentorName}
                </Text>

                <div className="flex items-start gap-4 rounded-lg border bg-[var(--token-color-bg)] p-4"
                  style={{ borderColor: "var(--token-color-border)" }}
                >
                  <span className="relative block h-12 w-12 shrink-0 overflow-hidden rounded-full">
                    <Image src={upcomingSession.mentorAvatar} alt={upcomingSession.mentorName} fill sizes="48px" className="object-cover" />
                  </span>
                  <div className="flex flex-col">
                    <span
                      className="font-semibold"
                      style={{ color: "var(--token-color-ink)", fontSize: "var(--token-font-size-sm)" }}
                    >
                      {upcomingSession.sessionTitle}
                    </span>
                    <span className="flex items-center gap-1" style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-xs)" }}>
                      <Timer size={12} />
                      {upcomingSession.sessionTime}
                    </span>
                  </div>
                </div>
              </div>

              <Button block>Join Meeting Room</Button>
            </div>
          </div>

          {/* Quick stats */}
          <div className="grid grid-cols-1 gap-6 sm:grid-cols-3">
            {stats.map(({ icon: Icon, label, value, tint }) => (
              <div
                key={label}
                className="flex items-center gap-6 rounded-xl border bg-[var(--token-color-surface)] p-4 shadow-[var(--token-shadow-md)]"
                style={{ borderColor: "var(--token-color-border)" }}
              >
                <span
                  className="flex h-12 w-12 shrink-0 items-center justify-center rounded-full"
                  style={{ backgroundColor: `var(--token-color-${tint})` }}
                >
                  <Icon size={20} color="var(--token-color-primary)" />
                </span>
                <div className="flex flex-col">
                  <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-xs)" }}>
                    {label}
                  </span>
                  <span className="font-bold" style={{ color: "var(--token-color-ink)", fontSize: "var(--token-font-size-3xl)" }}>
                    {value}
                  </span>
                </div>
              </div>
            ))}
          </div>

          {/* Recommended for you */}
          <div className="flex flex-col gap-6">
            <div className="flex items-center justify-between">
              <Title level={2} style={{ margin: 0, color: "var(--token-color-ink)" }}>
                Recommended for You
              </Title>
              <Link
                href="/courses"
                className="flex items-center gap-1 text-sm font-semibold tracking-wide text-[var(--token-color-primary)]"
              >
                View All
                <ArrowRight size={11} />
              </Link>
            </div>

            <div className="flex gap-6 overflow-x-auto pb-4">
              {recommended.map((course) => (
                <RecommendedCard key={course.id} course={course} />
              ))}
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}

function RecommendedCard({ course }: { course: RecommendedCourse }) {
  return (
    <article className="flex w-72 shrink-0 flex-col overflow-hidden rounded-xl border bg-[var(--token-color-surface)] shadow-[var(--token-shadow-md)]"
      style={{ borderColor: "var(--token-color-border)" }}
    >
      <div className="relative h-36 w-full bg-[var(--token-color-surfaceAlt)]">
        <Image src={course.image} alt={course.title} fill sizes="288px" className="object-cover" />
        <span className="absolute right-2 top-2 flex items-center gap-1 rounded-sm bg-[var(--token-color-surface)]/90 px-2 pb-1 pt-[3px] text-xs font-bold text-[var(--token-color-ink)] shadow-[var(--token-shadow-sm)]">
          {course.rating}
          <Star size={10} color="var(--token-color-warning)" fill="var(--token-color-warning)" />
        </span>
      </div>

      <div className="flex flex-1 flex-col justify-between gap-2 p-4">
        <div className="flex flex-col gap-1">
          <span style={{ color: "var(--token-color-primary)", fontSize: "var(--token-font-size-xs)" }}>
            {course.category}
          </span>
          <h4 className="line-clamp-2 text-lg font-semibold leading-6" style={{ color: "var(--token-color-ink)" }}>
            {course.title}
          </h4>
          <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-xs)" }}>
            {course.provider}
          </span>
        </div>

        <div className="flex items-center justify-between border-t pt-4" style={{ borderColor: "var(--token-color-border)" }}>
          <span className="font-bold tracking-wide" style={{ color: "var(--token-color-ink)", fontSize: "var(--token-font-size-sm)" }}>
            {course.level}
          </span>
          <button aria-label="Save course" className="text-[var(--token-color-textMuted)] hover:text-[var(--token-color-primary)]">
            <Bookmark size={16} />
          </button>
        </div>
      </div>
    </article>
  );
}