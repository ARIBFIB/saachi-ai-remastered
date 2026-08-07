"use client";

import { useState } from "react";
import { CreditCard, FileText } from "lucide-react";
import { useCorporateStore } from "@saachi/store";
import { Button, Card, Input } from "@saachi/ui";
import { formatCurrency } from "@saachi/utils";

const SEAT_PRICE = 29;

export default function CorporateBillingPage() {
  const { account, purchaseSeats } = useCorporateStore();
  const [seatCount, setSeatCount] = useState(5);
  const [purchased, setPurchased] = useState(false);

  const handlePurchase = () => {
    purchaseSeats(seatCount);
    setPurchased(true);
    setTimeout(() => setPurchased(false), 2500);
  };

  return (
    <main className="mx-auto max-w-[800px] px-6 py-10 md:px-10">
      <h1 className="mb-8 font-display text-[26px] font-semibold text-ink">Billing</h1>

      <div className="mb-8 grid grid-cols-1 gap-4 sm:grid-cols-2">
        <Card className="p-5">
          <p className="text-[13px] text-ink-soft">Total seats</p>
          <p className="mt-1 font-mono text-[22px] font-semibold text-ink">{account.seatsPurchased}</p>
        </Card>
        <Card className="p-5">
          <p className="text-[13px] text-ink-soft">Seats used</p>
          <p className="mt-1 font-mono text-[22px] font-semibold text-ink">{account.seatsUsed}</p>
        </Card>
      </div>

      <Card className="mb-8 p-6">
        <h2 className="mb-4 text-[15px] font-semibold text-ink">Purchase additional seats</h2>
        <div className="flex flex-col gap-4 sm:flex-row sm:items-end">
          <Input
            label="Number of seats"
            type="number"
            min={1}
            value={seatCount}
            onChange={(e) => setSeatCount(Number(e.target.value))}
            className="sm:w-[180px]"
          />
          <div className="flex-1 text-[13px] text-ink-soft">
            {seatCount} seats &times; {formatCurrency(SEAT_PRICE, "USD")} ={" "}
            <span className="font-semibold text-ink">{formatCurrency(seatCount * SEAT_PRICE, "USD")}</span>
          </div>
          <Button onClick={handlePurchase}>
            <CreditCard size={16} /> Purchase seats
          </Button>
        </div>
        {purchased && <p className="mt-3 text-[13px] text-teal">Seats purchased (demo) - invoice sent to billing email.</p>}
      </Card>

      <Card className="p-6">
        <div className="flex items-center gap-3">
          <FileText size={18} className="text-ink-soft" />
          <div>
            <h2 className="text-[15px] font-semibold text-ink">PO-based billing</h2>
            <p className="text-[13px] text-ink-soft">
              Enterprise clients can request custom invoicing instead of card checkout - contact sales.
            </p>
          </div>
        </div>
      </Card>
    </main>
  );
}