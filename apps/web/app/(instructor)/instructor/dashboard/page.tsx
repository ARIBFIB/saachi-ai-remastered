"use client";

import Link from "next/link";
import { DollarSign, BookOpen, Users, Star, PlusCircle } from "lucide-react";
import { useSession } from "@saachi/api-client";
import { useInstructorCourseStore } from "@saachi/store";
import { Button, Card } from "@saachi/ui";
import { formatCurrency } from "@saachi/utils";

export default function InstructorDashboardPage() {
  const { data: session } = useSession();
  const { courses } = useInstructorCourseStore();

  const totalRevenue = courses.reduce((sum, c) => sum + c.revenue, 0);
  const totalEnrollments = courses.reduce((sum, c) => sum + c.enrollmentCount, 0);
  const avgRating = courses.length
    ? (courses.reduce((sum, c) => sum + c.rating, 0) / courses.length).toFixed(1)
    : "â€”";
  const published = courses.filter((c) => c.status === "published").length;

  const stats = [
    { label: "Total earnings", value: formatCurrency(totalRevenue, "USD"), icon: DollarSign },
    { label: "Published courses", value: String(published), icon: BookOpen },
    { label: "Total students", value: totalEnrollments.toLocaleString(), icon: Users },
    { label: "Average rating", value: avgRating, icon: Star }
  ];

  return (
    <main className="mx-auto max-w-[1100px] px-6 py-10 md:px-10">
      <div className="mb-8 flex flex-col items-start justify-between gap-4 sm:flex-row sm:items-center">
        <div>
          <h1 className="font-display text-[26px] font-semibold text-ink">
            Welcome back{session?.fullName ? `, ${session.fullName.split(" ")[0]}` : ""}
          </h1>
          <p className="mt-1 text-[14px] text-ink-soft">Here's how your courses are performing.</p>
        </div>
        <Link href="/instructor/courses/new">
          <Button>
            <PlusCircle size={16} /> Create course
          </Button>
        </Link>
      </div>

      <div className="mb-10 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => (
          <Card key={stat.label} className="p-5">
            <div className="mb-3 flex h-9 w-9 items-center justify-center rounded-control bg-teal-light text-teal">
              <stat.icon size={17} />
            </div>
            <div className="font-mono text-[22px] font-semibold text-ink">{stat.value}</div>
            <div className="mt-1 text-[13px] text-ink-soft">{stat.label}</div>
          </Card>
        ))}
      </div>

      <h2 className="mb-4 font-display text-[18px] font-semibold text-ink">Your courses</h2>
      {courses.length === 0 ? (
        <Card className="p-6 text-center">
          <p className="mb-4 text-[14px] text-ink-soft">
            You haven't created any courses yet. This is demo data - courses you create here are
            stored locally in your browser.
          </p>
          <Link href="/instructor/courses/new">
            <Button>Create your first course</Button>
          </Link>
        </Card>
      ) : (
        <div className="flex flex-col gap-3">
          {courses.slice(0, 5).map((course) => (
            <Card key={course.id} className="flex items-center justify-between p-4">
              <div>
                <p className="text-[14px] font-semibold text-ink">{course.title || "Untitled course"}</p>
                <p className="mt-1 text-[12px] capitalize text-ink-soft">{course.status.replace("_", " ")}</p>
              </div>
              <span className="font-mono text-[14px] font-semibold text-ink">
                {formatCurrency(course.revenue, course.currency)}
              </span>
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}