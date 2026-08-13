"use client";

import { useState } from "react";
import { useParams } from "next/navigation";
import Link from "next/link";
import { ArrowLeft, Save } from "lucide-react";
import { Button, Input, Select } from "@saachi/ui";

const CURRENCY_OPTIONS = [
  { label: "USD", value: "USD" },
  { label: "PKR", value: "PKR" }
];

export default function CoursePricingPage() {
  const params = useParams<{ id: string }>();

  // NOTE: demo-only local state. Replace with useInstructorCoursePricing(params.id)
  // once the backend pricing endpoint and typed hook are available.
  const [price, setPrice] = useState("");
  const [currency, setCurrency] = useState("USD");
  const [includeInSubscription, setIncludeInSubscription] = useState(false);
  const [couponEligible, setCouponEligible] = useState(true);
  const [saved, setSaved] = useState(false);

  function handleSave() {
    // NOTE: demo-only, no backend pricing-update mutation wired up yet.
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  }

  return (
    <div className="mx-auto max-w-2xl">
      <Link
        href={`/instructor/courses/${params.id}/edit`}
        className="mb-4 inline-flex items-center gap-1.5 text-[13px] font-medium text-ink-soft hover:text-ink"
      >
        <ArrowLeft size={14} />
        Back to course
      </Link>

      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Pricing</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Course ID: {params.id}</p>

      <div className="flex flex-col gap-4 rounded-card border border-line bg-card p-6">
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <Input
            label="Price"
            type="number"
            required
            value={price}
            onChange={(e) => setPrice(e.target.value)}
            placeholder="49.00"
          />
          <Select
            label="Currency"
            options={CURRENCY_OPTIONS}
            value={currency}
            onChange={(e) => setCurrency(e.target.value)}
          />
        </div>

        <label className="flex items-center gap-2 text-[13px] text-ink-soft">
          <input
            type="checkbox"
            checked={includeInSubscription}
            onChange={(e) => setIncludeInSubscription(e.target.checked)}
            className="h-4 w-4 accent-gold-dark"
          />
          Include this course in the Saachi AI Pro subscription
        </label>

        <label className="flex items-center gap-2 text-[13px] text-ink-soft">
          <input
            type="checkbox"
            checked={couponEligible}
            onChange={(e) => setCouponEligible(e.target.checked)}
            className="h-4 w-4 accent-gold-dark"
          />
          Allow coupons and promotional codes on this course
        </label>
      </div>

      <Button size="lg" className="mt-6" onClick={handleSave}>
        <Save size={15} className="mr-1.5" />
        {saved ? "Saved" : "Save pricing"}
      </Button>
    </div>
  );
}