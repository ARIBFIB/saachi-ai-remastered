"use client";

import { useState } from "react";
import { Wallet, Landmark } from "lucide-react";
import { Button, Card, Input, Select, Badge } from "@saachi/ui";
import { formatCurrency, formatDate } from "@saachi/utils";

const PAYOUT_HISTORY = [
  { id: "po_1", amount: 420, date: "2026-06-01T00:00:00.000Z", status: "paid", method: "Bank Transfer" },
  { id: "po_2", amount: 610, date: "2026-05-01T00:00:00.000Z", status: "paid", method: "Easypaisa" },
  { id: "po_3", amount: 300, date: "2026-04-01T00:00:00.000Z", status: "paid", method: "Bank Transfer" }
];

export default function InstructorEarningsPage() {
  const [requested, setRequested] = useState(false);

  return (
    <main className="mx-auto max-w-[900px] px-6 py-10 md:px-10">
      <h1 className="mb-8 font-display text-[26px] font-semibold text-ink">Earnings & Payouts</h1>

      <div className="mb-8 grid grid-cols-1 gap-4 sm:grid-cols-3">
        <Card className="p-5">
          <p className="text-[13px] text-ink-soft">Available balance</p>
          <p className="mt-1 font-mono text-[22px] font-semibold text-ink">{formatCurrency(890, "USD")}</p>
        </Card>
        <Card className="p-5">
          <p className="text-[13px] text-ink-soft">Lifetime earnings</p>
          <p className="mt-1 font-mono text-[22px] font-semibold text-ink">{formatCurrency(4620, "USD")}</p>
        </Card>
        <Card className="p-5">
          <p className="text-[13px] text-ink-soft">Next payout</p>
          <p className="mt-1 font-mono text-[22px] font-semibold text-ink">Aug 1</p>
        </Card>
      </div>

      <Card className="mb-8 p-6">
        <h2 className="mb-4 text-[16px] font-semibold text-ink">Request a payout</h2>
        {requested ? (
          <p className="text-[14px] text-teal">Payout request submitted (demo) - Finance will process within 3-5 days.</p>
        ) : (
          <div className="flex flex-col gap-4 sm:flex-row sm:items-end">
            <Input label="Amount" type="number" defaultValue={890} className="sm:w-[200px]" />
            <Select
              label="Payout method"
              options={[
                { label: "Bank Transfer", value: "bank_transfer" },
                { label: "Easypaisa", value: "easypaisa" },
                { label: "JazzCash", value: "jazzcash" }
              ]}
              defaultValue="bank_transfer"
              className="sm:w-[220px]"
            />
            <Button onClick={() => setRequested(true)}>
              <Wallet size={16} /> Request payout
            </Button>
          </div>
        )}
      </Card>

      <Card className="mb-8 p-6">
        <div className="flex items-center gap-3">
          <Landmark size={20} className="text-teal" />
          <div>
            <h2 className="text-[15px] font-semibold text-ink">Payout method</h2>
            <p className="text-[13px] text-ink-soft">Bank Transfer - HBL â€¢â€¢â€¢â€¢ 4821 (demo)</p>
          </div>
        </div>
      </Card>

      <h2 className="mb-4 text-[16px] font-semibold text-ink">Payout history</h2>
      <div className="flex flex-col gap-3">
        {PAYOUT_HISTORY.map((p) => (
          <Card key={p.id} className="flex items-center justify-between p-4">
            <div>
              <p className="text-[14px] font-semibold text-ink">{formatCurrency(p.amount, "USD")}</p>
              <p className="mt-1 text-[12px] text-ink-soft">
                {p.method} &middot; {formatDate(p.date)}
              </p>
            </div>
            <Badge variant="success">Paid</Badge>
          </Card>
        ))}
      </div>
    </main>
  );
}