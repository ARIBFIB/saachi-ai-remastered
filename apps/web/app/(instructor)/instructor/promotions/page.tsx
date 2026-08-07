"use client";

import { useState } from "react";
import { Rocket, Check, Crown } from "lucide-react";
import { useInstructorCourseStore, usePromotionStore } from "@saachi/store";
import { Button, Card, Select, Badge, EmptyState } from "@saachi/ui";
import { formatCurrency, formatDate } from "@saachi/utils";

const TIERS = [
  {
    id: "bronze" as const,
    name: "Bronze",
    price: 15,
    features: ["Category page pinning", "14-day boost"]
  },
  {
    id: "silver" as const,
    name: "Silver",
    price: 35,
    features: ["Everything in Bronze", "Top-of-search placement", "14-day boost"]
  },
  {
    id: "gold" as const,
    name: "Gold",
    price: 75,
    features: ["Everything in Silver", "Homepage featured slot", "14-day boost", "Priority support"]
  }
];

export default function InstructorPromotionsPage() {
  const { courses } = useInstructorCourseStore();
  const promotions = usePromotionStore();
  const [selectedCourseId, setSelectedCourseId] = useState(courses[0]?.id ?? "");

  const courseOptions = courses.map((c) => ({ label: c.title || "Untitled course", value: c.id }));

  const handlePurchase = (tier: (typeof TIERS)[number]) => {
    const course = courses.find((c) => c.id === selectedCourseId);
    if (!course) return;
    promotions.purchase(course.id, course.title, tier.id);
  };

  return (
    <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
      <div className="mb-8">
        <h1 className="font-display text-[26px] font-semibold text-ink">Promotions</h1>
        <p className="mt-1 text-[14px] text-ink-soft">Boost a course's visibility across the marketplace.</p>
      </div>

      {courses.length === 0 ? (
        <EmptyState
          icon={<Rocket size={22} />}
          title="No courses to promote yet"
          description="Create a course first, then come back here to boost it."
        />
      ) : (
        <>
          <div className="mb-6 max-w-[360px]">
            <Select
              label="Course to promote"
              options={courseOptions}
              value={selectedCourseId}
              onChange={(e) => setSelectedCourseId(e.target.value)}
            />
          </div>

          <div className="grid grid-cols-1 gap-6 sm:grid-cols-3">
            {TIERS.map((tier) => (
              <Card key={tier.id} className={tier.id === "gold" ? "border-2 border-ink p-6" : "p-6"}>
                {tier.id === "gold" && (
                  <span className="mb-3 flex w-fit items-center gap-1 rounded-full bg-gold px-3 py-1 text-[11px] font-bold uppercase tracking-[0.05em] text-ink">
                    <Crown size={12} /> Best value
                  </span>
                )}
                <h3 className="text-[16px] font-semibold text-ink">{tier.name}</h3>
                <p className="mt-1 font-mono text-[24px] font-semibold text-ink">
                  {formatCurrency(tier.price, "USD")}
                </p>
                <ul className="mt-4 flex flex-col gap-2">
                  {tier.features.map((f) => (
                    <li key={f} className="flex items-start gap-2 text-[13px] text-ink-soft">
                      <Check size={14} className="mt-0.5 shrink-0 text-teal" />
                      {f}
                    </li>
                  ))}
                </ul>
                <Button
                  className="mt-5 w-full"
                  variant={tier.id === "gold" ? "primary" : "secondary"}
                  onClick={() => handlePurchase(tier)}
                  disabled={!selectedCourseId}
                >
                  Boost with {tier.name}
                </Button>
              </Card>
            ))}
          </div>

          {promotions.active.length > 0 && (
            <div className="mt-10">
              <h2 className="mb-4 text-[16px] font-semibold text-ink">Active promotions</h2>
              <div className="flex flex-col gap-3">
                {promotions.active.map((p) => (
                  <Card key={p.courseId} className="flex items-center justify-between p-4">
                    <div>
                      <p className="text-[14px] font-semibold text-ink">{p.courseTitle}</p>
                      <p className="mt-1 text-[12px] text-ink-soft">
                        Expires {formatDate(p.expiresAt)}
                      </p>
                    </div>
                    <Badge variant="gold">{p.tier}</Badge>
                  </Card>
                ))}
              </div>
            </div>
          )}
        </>
      )}
    </main>
  );
}