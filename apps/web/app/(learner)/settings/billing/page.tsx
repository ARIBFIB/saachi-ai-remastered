"use client";

import { CreditCard } from "lucide-react";
import { useSession } from "@saachi/api-client";
import { Button, EmptyState, Input } from "@saachi/ui";

export default function SettingsBillingPage() {
  const { data: session } = useSession();

  if (!session) {
    return <EmptyState title="Not logged in" description="Log in to view and edit your billing settings." />;
  }

  return (
    <div>
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Billing</h1>

      <div className="max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-4 flex items-center gap-2 text-[15px] font-semibold text-ink">
          <CreditCard size={16} />
          Saved payment methods
        </h2>
        <EmptyState
          title="No saved payment methods"
          description="Payment methods you use at checkout can be saved here for next time."
        />
      </div>

      <div className="mt-6 max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-4 text-[15px] font-semibold text-ink">Billing address</h2>
        <div className="flex flex-col gap-4">
          <Input label="Full name" defaultValue={session.fullName} />
          <Input label="Address line 1" placeholder="Street address" />
          <Input label="City" placeholder="City" />
          <Button className="self-start">Save address</Button>
        </div>
      </div>
    </div>
  );
}