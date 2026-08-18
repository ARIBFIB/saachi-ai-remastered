"use client";


import { useEffect } from "react";
import Link from "next/link";
import { BookOpen, Award, Bell } from "lucide-react";
import { useSession } from "@saachi/api-client";
import { useEnrollmentStore, useNotificationStore } from "@saachi/store";
import { Button, EmptyState, KpiCard } from "@saachi/ui";
import { LearnerOnboardingTour } from "@/components/ui/learner-onboarding-tour";
import { LearnerOnboardingChecklist } from "@/components/ui/learner-onboarding-checklist";
import { ActivityChartCard } from "@/components/ui/activity-chart-card";
import { BentoCard, BentoGrid } from "@/components/ui/bento-grid";
import {
  BookOpen as BentoBookOpen,
  Award as BentoAward,
  Users as BentoUsers,
  Heart as BentoHeart,
  MessageCircle as BentoMessageCircle,
  GraduationCap as BentoGraduationCap
} from "lucide-react";

export default function LearnerDashboardPage() {
  const { data: session } = useSession();
  const enrollments = useEnrollmentStore((s) => s.enrollments);
  const notifications = useNotificationStore((s) => s.items);

  const inProgress = enrollments.filter((e) => e.progressPercent > 0 && e.progressPercent < 100);
  const completed = enrollments.filter((e) => e.progressPercent === 100);
  const unreadCount = notifications.filter((n) => !n.read).length;

  useEffect(() => {
    window.localStorage.removeItem("saachi-just-signed-up");
  }, []);

  return (
    <div>
      <LearnerOnboardingTour />
            <LearnerOnboardingChecklist />

      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">
        Welcome back{session ? `, ${session.fullName}` : ""}
      </h1>
      <p className="mb-8 text-[14px] text-ink-soft">Here is where you left off.</p>

      <div data-onboard="kpi-row" className="mb-10 grid grid-cols-1 gap-4 sm:grid-cols-3">
        <KpiCard label="Enrolled courses" value={String(enrollments.length)} icon={BookOpen} />
        <KpiCard label="Completed" value={String(completed.length)} icon={Award} />
        <KpiCard label="Unread notifications" value={String(unreadCount)} icon={Bell} />
      </div>

      <div className="mb-10">
        <ActivityChartCard />
      </div>

      <h2 className="mb-4 font-display text-[20px] font-semibold text-ink">Explore</h2>
      <div className="mb-10">
        <BentoGrid>
          <BentoCard
            name="Continue learning"
            description="Jump back into your enrolled courses."
            Icon={BentoBookOpen}
            href="/my-courses"
            cta="Go to My Courses"
            className="md:col-span-2 md:row-span-2"
          />
          <BentoCard
            name="Certificates"
            description="View and download your earned certificates."
            Icon={BentoAward}
            href="/certificates"
            cta="View certificates"
          />
          <BentoCard
            name="Book mentorship"
            description="1-on-1 sessions with verified instructors."
            Icon={BentoUsers}
            href="/mentorship"
            cta="Find a mentor"
            className="md:row-span-2"
          />
          <BentoCard
            name="Wishlist"
            description="Courses you have saved for later."
            Icon={BentoHeart}
            href="/wishlist"
            cta="View wishlist"
          />
          <BentoCard
            name="Course community"
            description="Ask questions and get answers from instructors."
            Icon={BentoMessageCircle}
            href="/my-courses"
            cta="Browse my courses"
          />
          <BentoCard
            name="Become an instructor"
            description="Apply to teach and sell your own courses."
            Icon={BentoGraduationCap}
            href="/become-instructor"
            cta="Apply now"
          />
        </BentoGrid>
      </div>

      <h2 data-onboard="continue-learning" className="mb-4 font-display text-[20px] font-semibold text-ink">Continue learning</h2>
      {inProgress.length === 0 ? (
        <EmptyState
          title="No courses in progress"
          description="Enroll in a course to see it here."
          action={
            <Link href="/courses">
              <Button>Browse courses</Button>
            </Link>
          }
        />
      ) : (
        <div className="flex flex-col gap-3">
          {inProgress.map((e) => (
            <Link
              key={e.courseId}
              href={`/learn/${e.courseId}/lesson`}
              className="flex items-center gap-4 rounded-card border border-line bg-card p-4 transition-colors hover:border-gold-dark/40"
            >
              {e.thumbnailUrl && (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={e.thumbnailUrl} alt={e.title} className="h-16 w-28 shrink-0 rounded-control object-cover" />
              )}
              <div className="min-w-0 flex-1">
                <h3 className="truncate text-[15px] font-semibold text-ink">{e.title}</h3>
                <p className="text-[13px] text-ink-soft">{e.instructorName}</p>
                <div className="mt-2 h-1.5 w-full overflow-hidden rounded-full bg-paper-dim">
                  <div className="h-full rounded-full bg-gold" style={{ width: `${e.progressPercent}%` }} />
                </div>
              </div>
              <span className="shrink-0 text-[13px] font-semibold text-ink-soft">{e.progressPercent}%</span>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}



