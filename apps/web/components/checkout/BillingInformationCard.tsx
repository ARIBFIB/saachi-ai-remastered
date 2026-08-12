"use client";

import { UserRound, ChevronDown } from "lucide-react";

export interface BillingDetails {
  fullName: string;
  email: string;
  country: string;
  zip: string;
}

interface BillingInformationCardProps {
  details: BillingDetails;
  onChange: (details: BillingDetails) => void;
}

// TODO: replace with a real country list from packages/utils or a countries API
const countries = [
  "United States",
  "United Kingdom",
  "Canada",
  "Pakistan",
  "India",
  "Australia",
];

export function BillingInformationCard({
  details,
  onChange,
}: BillingInformationCardProps) {
  function update<K extends keyof BillingDetails>(
    key: K,
    value: BillingDetails[K]
  ) {
    onChange({ ...details, [key]: value });
  }

  return (
    <section
      className="flex w-full flex-col gap-4 rounded-xl border-2 bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-sm)]"
      style={{ borderColor: "var(--token-color-border)" }}
    >
      <div className="flex items-center gap-2">
        <UserRound size={16} color="var(--token-color-primary)" />
        <h2
          className="text-2xl font-semibold"
          style={{ color: "var(--token-color-ink)" }}
        >
          Billing Information
        </h2>
      </div>

      <div className="flex flex-col gap-4">
        <Field label="Full Name">
          <input
            type="text"
            value={details.fullName}
            onChange={(e) => update("fullName", e.target.value)}
            placeholder="Jane Doe"
            className="w-full rounded-lg border-2 bg-[var(--token-color-bg)] px-3 py-2.5 text-base text-[var(--token-color-ink)] placeholder:text-gray-500 focus:outline-none focus:border-[var(--token-color-primary)]"
            style={{ borderColor: "var(--token-color-border)" }}
          />
        </Field>

        <Field label="Email Address">
          <input
            type="email"
            value={details.email}
            onChange={(e) => update("email", e.target.value)}
            placeholder="jane@example.com"
            className="w-full rounded-lg border-2 bg-[var(--token-color-bg)] px-3 py-2.5 text-base text-[var(--token-color-ink)] placeholder:text-gray-500 focus:outline-none focus:border-[var(--token-color-primary)]"
            style={{ borderColor: "var(--token-color-border)" }}
          />
        </Field>

        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <Field label="Country">
            <div className="relative">
              <select
                value={details.country}
                onChange={(e) => update("country", e.target.value)}
                className="w-full appearance-none rounded-lg border-2 bg-[var(--token-color-bg)] px-3 py-2.5 text-base text-[var(--token-color-ink)] focus:outline-none focus:border-[var(--token-color-primary)]"
                style={{ borderColor: "var(--token-color-border)" }}
              >
                {countries.map((c) => (
                  <option key={c} value={c}>
                    {c}
                  </option>
                ))}
              </select>
              <ChevronDown
                className="pointer-events-none absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2"
                color="var(--token-color-textMuted)"
              />
            </div>
          </Field>

          <Field label="Zip / Postal Code">
            <input
              type="text"
              value={details.zip}
              onChange={(e) => update("zip", e.target.value)}
              placeholder="10001"
              className="w-full rounded-lg border-2 bg-[var(--token-color-bg)] px-3 py-2.5 text-base text-[var(--token-color-ink)] placeholder:text-gray-500 focus:outline-none focus:border-[var(--token-color-primary)]"
              style={{ borderColor: "var(--token-color-border)" }}
            />
          </Field>
        </div>
      </div>
    </section>
  );
}

function Field({
  label,
  children,
}: {
  label: string;
  children: React.ReactNode;
}) {
  return (
    <div className="flex flex-col gap-1">
      <label
        className="text-sm font-semibold tracking-wide"
        style={{ color: "var(--token-color-inkSoft)" }}
      >
        {label}
      </label>
      {children}
    </div>
  );
}
