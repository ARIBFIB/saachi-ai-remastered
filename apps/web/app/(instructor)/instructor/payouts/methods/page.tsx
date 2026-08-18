"use client";

import { useState, type FormEvent } from "react";
import Link from "next/link";
import { ArrowLeft, Landmark, Smartphone, CreditCard, Star, Trash2, Plus } from "lucide-react";
import {
  useInstructorPayoutMethods,
  useAddPayoutMethod,
  useSetDefaultPayoutMethod,
  useRemovePayoutMethod,
  type PayoutMethodType
} from "@saachi/api-client";
import { Button, Input, Select, EmptyState, Badge } from "@saachi/ui";

const METHOD_TYPE_OPTIONS: { label: string; value: PayoutMethodType }[] = [
  { label: "Bank transfer", value: "bank_transfer" },
  { label: "Easypaisa", value: "easypaisa" },
  { label: "JazzCash", value: "jazzcash" },
  { label: "Stripe Connect", value: "stripe_connect" }
];

const METHOD_ICON: Record<PayoutMethodType, typeof Landmark> = {
  bank_transfer: Landmark,
  easypaisa: Smartphone,
  jazzcash: Smartphone,
  stripe_connect: CreditCard
};

export default function InstructorPayoutMethodsPage() {
  const { data: methods, isLoading } = useInstructorPayoutMethods();
  const setDefault = useSetDefaultPayoutMethod();
  const removeMethod = useRemovePayoutMethod();

  const [formOpen, setFormOpen] = useState(false);

  return (
    <div className="mx-auto max-w-2xl">
      <Link href="/instructor/payouts" className="mb-4 inline-flex items-center gap-1.5 text-[13px] font-medium text-ink-soft hover:text-ink">
        <ArrowLeft size={14} />
        Back to payouts
      </Link>

      <div className="mb-8 flex items-center justify-between">
        <div>
          <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Payout Methods</h1>
          <p className="text-[14px] text-ink-soft">Manage where your earnings are sent.</p>
        </div>
        {!formOpen && (
          <Button onClick={() => setFormOpen(true)}>
            <Plus size={14} className="mr-1.5" />
            Add method
          </Button>
        )}
      </div>

      {formOpen && <AddMethodForm onDone={() => setFormOpen(false)} />}

      {isLoading ? (
        <div className="mt-6 rounded-card border border-line bg-card p-10 text-center text-[13px] text-ink-soft">
          Loading payout methods...
        </div>
      ) : !methods || methods.length === 0 ? (
        <div className="mt-6">
          <EmptyState
            title="No payout methods yet"
            description="Add a bank account or mobile wallet to start requesting payouts."
          />
        </div>
      ) : (
        <div className="mt-6 flex flex-col gap-3">
          {methods.map((m) => {
            const Icon = METHOD_ICON[m.type];
            return (
              <div key={m.id} className="flex items-center gap-4 rounded-card border border-line bg-card p-5">
                <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-gold-tint text-gold-dark">
                  <Icon size={18} />
                </div>
                <div className="min-w-0 flex-1">
                  <div className="flex items-center gap-2">
                    <p className="text-[14px] font-semibold text-ink">{m.label}</p>
                    {m.isDefault && <Badge variant="gold">Default</Badge>}
                  </div>
                  <p className="mt-0.5 text-[13px] text-ink-soft">
                    {m.accountName} Â· {m.accountNumber}
                  </p>
                </div>
                <div className="flex shrink-0 items-center gap-2">
                  {!m.isDefault && (
                    <Button
                      size="sm"
                      variant="secondary"
                      onClick={() => setDefault.mutate(m.id)}
                      disabled={setDefault.isPending}
                    >
                      <Star size={13} className="mr-1.5" />
                      Make default
                    </Button>
                  )}
                  <button
                    type="button"
                    aria-label="Remove payout method"
                    onClick={() => removeMethod.mutate(m.id)}
                    disabled={removeMethod.isPending}
                    className="flex h-9 w-9 items-center justify-center rounded-control text-ink-soft transition-colors hover:bg-error-tint hover:text-error"
                  >
                    <Trash2 size={15} />
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

function AddMethodForm({ onDone }: { onDone: () => void }) {
  const addMethod = useAddPayoutMethod();

  const [type, setType] = useState<PayoutMethodType>("bank_transfer");
  const [label, setLabel] = useState("");
  const [accountName, setAccountName] = useState("");
  const [accountNumber, setAccountNumber] = useState("");
  const [error, setError] = useState<string | null>(null);

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setError(null);
    if (!label.trim() || !accountName.trim() || !accountNumber.trim()) {
      setError("All fields are required");
      return;
    }
    addMethod.mutate(
      { type, label: label.trim(), accountName: accountName.trim(), accountNumber: accountNumber.trim() },
      {
        onSuccess: () => {
          setLabel("");
          setAccountName("");
          setAccountNumber("");
          onDone();
        }
      }
    );
  }

  return (
    <form onSubmit={handleSubmit} className="mb-2 flex flex-col gap-4 rounded-card border border-line bg-card p-6">
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        <Select
          label="Method type"
          options={METHOD_TYPE_OPTIONS}
          value={type}
          onChange={(e) => setType(e.target.value as PayoutMethodType)}
        />
        <Input
          label="Label"
          value={label}
          onChange={(e) => setLabel(e.target.value)}
          placeholder="e.g. Meezan Bank"
        />
      </div>
      <Input
        label="Account holder name"
        value={accountName}
        onChange={(e) => setAccountName(e.target.value)}
        placeholder="Full name on the account"
      />
      <Input
        label="Account / mobile number"
        value={accountNumber}
        onChange={(e) => setAccountNumber(e.target.value)}
        placeholder="Only the last 4 digits will be shown after saving"
      />
      {error && <p className="text-[13px] text-error">{error}</p>}
      <div className="flex gap-2">
        <Button type="submit" loading={addMethod.isPending}>
          Save method
        </Button>
        <Button type="button" variant="secondary" onClick={onDone}>
          Cancel
        </Button>
      </div>
    </form>
  );
}
