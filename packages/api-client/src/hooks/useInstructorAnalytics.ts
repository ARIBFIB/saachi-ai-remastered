"use client";

import { useQuery } from "@tanstack/react-query";

// NOTE: demo-only, in-memory dummy analytics data. Replace with real
// Instructor Analytics API (aggregation endpoints) once the backend is
// available. Follows the same delay()-based mock pattern as the other
// api-client hooks (see useAdminFinance.ts, useInstructorPayouts.ts).

export type AnalyticsPeriod = "7d" | "30d" | "90d";

export type EnrollmentTrendPoint = { label: string; enrollments: number; completions: number };
export type RevenueTrendPoint = { label: string; revenue: number };
export type TrafficSourceSlice = { name: string; value: number };
export type EngagementDayPoint = { day: string; activeMinutes: number };

export type InstructorAnalyticsSnapshot = {
  totalEnrollments: number;
  completionRate: number;
  revenue30d: number;
  topTrafficSource: string;
  enrollmentTrend: EnrollmentTrendPoint[];
  revenueTrend: RevenueTrendPoint[];
  trafficSources: TrafficSourceSlice[];
  engagementByDay: EngagementDayPoint[];
  topCourses: { id: string; title: string; enrollments: number; completionRate: number; revenue: number }[];
};

function delay<T>(value: T, ms = 400): Promise<T> {
  return new Promise((resolve) => setTimeout(() => resolve(value), ms));
}

const TRAFFIC_SOURCES: TrafficSourceSlice[] = [
  { name: "Search", value: 38 },
  { name: "Direct", value: 24 },
  { name: "Social", value: 16 },
  { name: "Referral", value: 13 },
  { name: "Email", value: 9 }
];

const ENGAGEMENT_BY_DAY: EngagementDayPoint[] = [
  { day: "Mon", activeMinutes: 420 },
  { day: "Tue", activeMinutes: 510 },
  { day: "Wed", activeMinutes: 380 },
  { day: "Thu", activeMinutes: 610 },
  { day: "Fri", activeMinutes: 540 },
  { day: "Sat", activeMinutes: 720 },
  { day: "Sun", activeMinutes: 660 }
];

const TOP_COURSES = [
  { id: "crs_i1", title: "Automate Everything with n8n & AI", enrollments: 654, completionRate: 58, revenue: 8420 },
  { id: "crs_i2", title: "AI Chatbots for WhatsApp Support", enrollments: 128, completionRate: 41, revenue: 1450 },
  { id: "crs_i3", title: "Prompt Engineering for Client Work", enrollments: 96, completionRate: 63, revenue: 980 }
];

function buildTrend(period: AnalyticsPeriod): { enrollmentTrend: EnrollmentTrendPoint[]; revenueTrend: RevenueTrendPoint[] } {
  const config: Record<AnalyticsPeriod, { points: number; labelFn: (i: number) => string; base: number; rev: number }> = {
    "7d": {
      points: 7,
      labelFn: (i) => ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][i],
      base: 12,
      rev: 140
    },
    "30d": {
      points: 10,
      labelFn: (i) => `Day ${i * 3 + 1}`,
      base: 40,
      rev: 480
    },
    "90d": {
      points: 12,
      labelFn: (i) => ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][i],
      base: 90,
      rev: 1100
    }
  };

  const { points, labelFn, base, rev } = config[period];
  const enrollmentTrend: EnrollmentTrendPoint[] = [];
  const revenueTrend: RevenueTrendPoint[] = [];

  let enroll = base;
  let revenue = rev;
  for (let i = 0; i < points; i++) {
    // gentle upward-trending pseudo-random walk, deterministic per index
    const wiggle = Math.sin(i * 1.3) * base * 0.25;
    enroll = Math.max(4, Math.round(base + i * (base * 0.18) + wiggle));
    const completions = Math.round(enroll * (0.45 + Math.sin(i * 0.7) * 0.08));
    revenue = Math.max(20, Math.round(rev + i * (rev * 0.16) + Math.cos(i * 1.1) * rev * 0.2));

    enrollmentTrend.push({ label: labelFn(i), enrollments: enroll, completions });
    revenueTrend.push({ label: labelFn(i), revenue });
  }

  return { enrollmentTrend, revenueTrend };
}

export function useInstructorAnalytics(period: AnalyticsPeriod = "30d") {
  return useQuery({
    queryKey: ["instructor", "analytics", period],
    queryFn: async () => {
      const { enrollmentTrend, revenueTrend } = buildTrend(period);
      const totalEnrollments = enrollmentTrend.reduce((sum, p) => sum + p.enrollments, 0);
      const totalCompletions = enrollmentTrend.reduce((sum, p) => sum + p.completions, 0);
      const completionRate = totalEnrollments > 0 ? Math.round((totalCompletions / totalEnrollments) * 100) : 0;
      const revenue30d = revenueTrend.reduce((sum, p) => sum + p.revenue, 0);

      const snapshot: InstructorAnalyticsSnapshot = {
        totalEnrollments,
        completionRate,
        revenue30d,
        topTrafficSource: TRAFFIC_SOURCES[0].name,
        enrollmentTrend,
        revenueTrend,
        trafficSources: TRAFFIC_SOURCES,
        engagementByDay: ENGAGEMENT_BY_DAY,
        topCourses: TOP_COURSES
      };

      return delay(snapshot);
    }
  });
}
