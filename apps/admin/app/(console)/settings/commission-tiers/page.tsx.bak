"use client";

import { useEffect, useState } from "react";
import { toast } from "sonner";
import { Landmark, Save } from "lucide-react";
import { Button, Card, Input, ShimmerKpiCard } from "@saachi/ui";

type Tier = {
  id: string;
  name: string;
  criteria: string;
  ratePercent: number;
};

const INITIAL_TIERS: Tier[] = [
  { id: "new", name: "New Instructor", criteria: "Just approved, 0-2 published courses", ratePercent: 30 },
  { id: "verified", name: "Verified Instructor", criteria: "Identity verified, 3+ courses, 4.0+ rating", ratePercent: 25 },
  { id: "top_rated", name: "Top-Rated Instructor", criteria: "10+ courses, 4.5+ rating, consistent sales", ratePercent: 20 },
  { id: "partner", name: "Partner Instructor", criteria: "Invited/negotiated status", ratePercent: 15 }
];

export default function CommissionTierConfigurationPage() {
  const [isLoading, setIsLoading] = useState(true);
  const [tiers, setTiers] = useState(INITIAL_TIERS);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    const t = setTimeout(() => setIsLoading(false), 500);
    return () => clearTimeout(t);
  }, []);

  const updateRate = (id: string, value: number) => {
    setTiers((prev) => prev.map((t) => (t.id === id ? { ...t, ratePercent: value } : t)));
  };

  const handleSave = () => {
    setSaving(true);
    setTimeout(() => {
      setSaving(false);
      toast.success("Commission tiers updated");
    }, 700);
  };

  return (
    <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <Landmark size={17} strokeWidth={1.75} />
          </div>
          <div>
            <h1 className="text-[22px] font-semibold text-ink">Commission Tier Configuration</h1>
            <p className="mt-0.5 text-[13px] text-ink-soft">Trust-tier commission rates applied to instructor course sales.</p>
          </div>
        </div>
        <Button size="sm" onClick={handleSave} disabled={saving || isLoading}>
          <Save size={14} strokeWidth={1.75} /> {saving ? "Saving..." : "Save changes"}
        </Button>
      </div>

      {isLoading ? (
        <div className="flex flex-col gap-3">
          {Array.from({ length: 4 }).map((_, i) => (
            <ShimmerKpiCard key={i} />
          ))}
        </div>
      ) : (
        <div className="flex flex-col gap-3">
          {tiers.map((tier) => (
            <Card key={tier.id} className="flex flex-col gap-4 p-5 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <p className="text-[14px] font-semibold text-ink">{tier.name}</p>
                <p className="mt-1 text-[12.5px] text-ink-soft">{tier.criteria}</p>
              </div>
              <div className="w-full sm:w-[140px]">
                <Input
                  label="Commission %"
                  type="number"
                  min={0}
                  max={100}
                  value={tier.ratePercent}
                  onChange={(e) => updateRate(tier.id, Number(e.target.value))}
                />
              </div>
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}