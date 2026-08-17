"use client";

import Link from "next/link";
import { DollarSign, Users, Star, MessageCircle } from "lucide-react";
import { useSession } from "@saachi/api-client";
import { Button, KpiCard, EmptyState } from "@saachi/ui";
import { InstructorBentoCard } from "@/components/ui/instructor-bento-card";

// NOTE: demo-only dummy data. Replace with real analytics/enrollment hooks
// once packages/api-client hooks/useInstructorAnalytics.ts is confirmed.
const RECENT_REVIEWS = [
  { id: "r1", course: "Automate Everything with n8n & AI", author: "Bilal S.", rating: 5, comment: "Very practical, loved it." },
  { id: "r2", course: "AI Chatbots for WhatsApp Support", author: "Fatima R.", rating: 4, comment: "Good pacing, clear examples." },
  { id: "r3", course: "Automate Everything with n8n & AI", author: "Omar Sheikh", rating: 5, comment: "Best automation course I've taken." }
];

export default function InstructorDashboardPage() {
  const { data: session } = useSession();

  return (
    <div>
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">
        Welcome back{session ? `, ${session.fullName}` : ""}
      </h1>
      <p className="mb-8 text-[14px] text-ink-soft">Here is how your courses are performing.</p>

      <div className="mb-10 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <KpiCard label="Lifetime earnings" value="$8,420.00" icon={DollarSign} />
        <KpiCard label="Total students" value="654" icon={Users} />
        <KpiCard label="Average rating" value="4.7" icon={Star} />
        <KpiCard label="Pending Q&A" value="3" icon={MessageCircle} />
      </div>

      <div className="mb-10 flex flex-wrap gap-3">
        <Link href="/instructor/courses/new">
          <Button>Create a new course</Button>
        </Link>
        <Link href="/instructor/courses">
          <Button variant="secondary">View my courses</Button>
        </Link>
      </div>

      <h2 className="mb-4 font-display text-[20px] font-semibold text-ink">Recent reviews</h2>
      {RECENT_REVIEWS.length === 0 ? (
        <EmptyState title="No reviews yet" description="Reviews on your courses will show up here." />
      ) : (
        <div className="flex flex-col gap-3">
          {RECENT_REVIEWS.map((r) => (
            <div key={r.id} className="rounded-card border border-line bg-card p-4">
              <div className="mb-1 flex items-center justify-between">
                <p className="text-[14px] font-semibold text-ink">{r.course}</p>
                <span className="text-[12px] text-ink-soft">{"\u2605".repeat(r.rating)}</span>
              </div>
              <p className="text-[13px] text-ink-soft">
                {r.author} - {r.comment}
              </p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
