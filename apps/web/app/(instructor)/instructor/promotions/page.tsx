"use client";

import { useState } from "react";
import { Rocket, Check } from "lucide-react";
import { Button, Select, EmptyState, Badge, cn } from "@saachi/ui";

type PackageTier = "bronze" | "silver" | "gold";

const PACKAGES: {
  tier: PackageTier;
  name: string;
  price: string;
  perks: string[];
}[] = [
  { tier: "bronze", name: "Bronze Boost", price: "$19", perks: ["Category page pinning (7 days)", "Basic visibility badge"] },
  { tier: "silver", name: "Silver Boost", price: "$49", perks: ["Everything in Bronze", "Top-of-search placement (7 days)", "Silver visibility badge"] },
  { tier: "gold", name: "Gold Boost", price: "$99", perks: ["Everything in Silver", "Homepage featured slot (7 days)", "Gold visibility badge"] }
];

// NOTE: demo-only dummy data. Replace with useInstructorCourses() once confirmed.
const COURSE_OPTIONS = [
  { label: "Select a course...", value: "" },
  { label: "Automate Everything with n8n & AI", value: "crs_i1" },
  { label: "AI Chatbots for WhatsApp Support", value: "crs_i2" }
];

// NOTE: demo-only dummy data. Replace with useInstructorPromotions() once confirmed.
const ACTIVE_PROMOTIONS: { id: string; courseTitle: string; tier: PackageTier; expiresIn: string }[] = [
  { id: "promo_1", courseTitle: "Automate Everything with n8n & AI", tier: "silver", expiresIn: "4 days" }
];

export default function InstructorPromotionsPage() {
  const [selectedCourse, setSelectedCourse] = useState("");
  const [purchasing, setPurchasing] = useState<PackageTier | null>(null);
  const [purchased, setPurchased] = useState<PackageTier | null>(null);

  function handlePurchase(tier: PackageTier) {
    if (!selectedCourse) return;
    setPurchasing(tier);
    // NOTE: demo-only, no backend promotion-purchase mutation wired up yet.
    setTimeout(() => {
      setPurchasing(null);
      setPurchased(tier);
    }, 700);
  }

  return (
    <div>
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Promotions</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Boost your course visibility with a promotion package.</p>

      <div className="mb-8 max-w-sm">
        <Select
          label="Course to promote"
          options={COURSE_OPTIONS}
          value={selectedCourse}
          onChange={(e) => setSelectedCourse(e.target.value)}
        />
      </div>

      <div className="grid grid-cols-1 gap-5 md:grid-cols-3">
        {PACKAGES.map((pkg) => (
          <div
            key={pkg.tier}
            className={cn(
              "flex flex-col rounded-card border p-6",
              pkg.tier === "gold" ? "border-gold-dark/50 bg-gold-tint" : "border-line bg-card"
            )}
          >
            {pkg.tier === "gold" && (
              <Badge variant="gold" className="mb-3 self-start">
                Best value
              </Badge>
            )}
            <h2 className="font-display text-[18px] font-semibold text-ink">{pkg.name}</h2>
            <p className="mt-1 font-mono text-[24px] font-bold text-ink">{pkg.price}</p>
            <ul className="my-5 flex flex-1 flex-col gap-2 text-[13px] text-ink-soft">
              {pkg.perks.map((perk) => (
                <li key={perk} className="flex items-start gap-2">
                  <Check size={14} className="mt-0.5 shrink-0 text-teal" />
                  {perk}
                </li>
              ))}
            </ul>
            <Button
              variant={pkg.tier === "gold" ? "primary" : "secondary"}
              disabled={!selectedCourse || purchasing !== null}
              onClick={() => handlePurchase(pkg.tier)}
              className="w-full"
            >
              <Rocket size={14} className="mr-1.5" />
              {purchased === pkg.tier ? "Purchased" : purchasing === pkg.tier ? "Processing..." : "Boost course"}
            </Button>
          </div>
        ))}
      </div>

      <h2 className="mb-4 mt-12 font-display text-[20px] font-semibold text-ink">Active promotions</h2>
      {ACTIVE_PROMOTIONS.length === 0 ? (
        <EmptyState title="No active promotions" description="Purchased boost packages will appear here." />
      ) : (
        <div className="flex flex-col gap-3">
          {ACTIVE_PROMOTIONS.map((p) => (
            <div key={p.id} className="flex items-center justify-between gap-4 rounded-card border border-line bg-card p-4">
              <div>
                <p className="text-[14px] font-semibold text-ink">{p.courseTitle}</p>
                <p className="mt-1 text-[13px] text-ink-soft">Expires in {p.expiresIn}</p>
              </div>
              <Badge variant={p.tier === "gold" ? "gold" : undefined}>{p.tier} boost</Badge>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
