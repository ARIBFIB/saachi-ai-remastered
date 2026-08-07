"use client";

import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from "recharts";
import { Card } from "@saachi/ui";

const ENROLLMENT_TREND = [
  { month: "Feb", enrollments: 40 },
  { month: "Mar", enrollments: 62 },
  { month: "Apr", enrollments: 58 },
  { month: "May", enrollments: 91 },
  { month: "Jun", enrollments: 120 },
  { month: "Jul", enrollments: 148 }
];

const REVENUE_TREND = [
  { month: "Feb", revenue: 620 },
  { month: "Mar", revenue: 980 },
  { month: "Apr", revenue: 890 },
  { month: "May", revenue: 1450 },
  { month: "Jun", revenue: 1980 },
  { month: "Jul", revenue: 2340 }
];

export default function InstructorAnalyticsPage() {
  return (
    <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
      <div className="mb-8">
        <h1 className="font-display text-[26px] font-semibold text-ink">Analytics</h1>
        <p className="mt-1 text-[14px] text-ink-soft">
          Demo data - connects to the real Analytics/Enrollments API once the backend is live.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        <Card className="p-6">
          <h2 className="mb-4 text-[15px] font-semibold text-ink">Enrollment trend</h2>
          <ResponsiveContainer width="100%" height={240}>
            <LineChart data={ENROLLMENT_TREND}>
              <CartesianGrid strokeDasharray="3 3" stroke="var(--color-line)" />
              <XAxis dataKey="month" stroke="var(--color-ink-soft)" fontSize={12} />
              <YAxis stroke="var(--color-ink-soft)" fontSize={12} />
              <Tooltip />
              <Line type="monotone" dataKey="enrollments" stroke="var(--color-teal)" strokeWidth={2} dot={false} />
            </LineChart>
          </ResponsiveContainer>
        </Card>

        <Card className="p-6">
          <h2 className="mb-4 text-[15px] font-semibold text-ink">Revenue trend</h2>
          <ResponsiveContainer width="100%" height={240}>
            <LineChart data={REVENUE_TREND}>
              <CartesianGrid strokeDasharray="3 3" stroke="var(--color-line)" />
              <XAxis dataKey="month" stroke="var(--color-ink-soft)" fontSize={12} />
              <YAxis stroke="var(--color-ink-soft)" fontSize={12} />
              <Tooltip />
              <Line type="monotone" dataKey="revenue" stroke="var(--color-gold-dark)" strokeWidth={2} dot={false} />
            </LineChart>
          </ResponsiveContainer>
        </Card>
      </div>
    </main>
  );
}