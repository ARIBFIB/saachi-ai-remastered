"use client";

import { useState, type FormEvent } from "react";
import { Button, Input, Select } from "@saachi/ui";

const METHOD_OPTIONS = [
  { label: "Bank transfer", value: "bank" },
  { label: "Mobile wallet (Easypaisa / JazzCash)", value: "wallet" },
  { label: "Stripe Connect", value: "stripe" }
];

export default function PayoutMethodSettingsPage() {
  const [method, setMethod] = useState("bank");

  // Bank fields
  const [bankName, setBankName] = useState("");
  const [accountTitle, setAccountTitle] = useState("");
  const [accountNumber, setAccountNumber] = useState("");
  const [iban, setIban] = useState("");

  // Wallet fields
  const [walletProvider, setWalletProvider] = useState("easypaisa");
  const [walletNumber, setWalletNumber] = useState("");

  const [saved, setSaved] = useState(false);

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    // NOTE: demo-only, no backend payout-method mutation wired up yet.
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  }

  return (
    <div className="mx-auto max-w-lg">
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Payout Method</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Configure how you receive your earnings.</p>

      <form onSubmit={handleSubmit} className="flex flex-col gap-4">
        <Select label="Payout method" options={METHOD_OPTIONS} value={method} onChange={(e) => setMethod(e.target.value)} />

        {method === "bank" && (
          <>
            <Input label="Bank name" required value={bankName} onChange={(e) => setBankName(e.target.value)} placeholder="e.g. UBL, HBL, Allied Bank" />
            <Input label="Account title" required value={accountTitle} onChange={(e) => setAccountTitle(e.target.value)} />
            <Input label="Account number" required value={accountNumber} onChange={(e) => setAccountNumber(e.target.value)} />
            <Input label="IBAN (optional)" value={iban} onChange={(e) => setIban(e.target.value)} />
          </>
        )}

        {method === "wallet" && (
          <>
            <Select
              label="Wallet provider"
              options={[
                { label: "Easypaisa", value: "easypaisa" },
                { label: "JazzCash", value: "jazzcash" }
              ]}
              value={walletProvider}
              onChange={(e) => setWalletProvider(e.target.value)}
            />
            <Input label="Wallet number" required value={walletNumber} onChange={(e) => setWalletNumber(e.target.value)} placeholder="03XXXXXXXXX" />
          </>
        )}

        {method === "stripe" && (
          <p className="rounded-control border border-line bg-paper-dim p-4 text-[13px] text-ink-soft">
            You&apos;ll be redirected to Stripe Connect to link your account once this integration is wired up.
          </p>
        )}

        <Button type="submit" size="lg" className="self-start">
          {saved ? "Saved" : "Save payout method"}
        </Button>
      </form>
    </div>
  );
}