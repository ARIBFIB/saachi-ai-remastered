"use client";

import { Megaphone, Crown } from "lucide-react";
import { useAdminPromotionSales, type PromotionSale } from "@saachi/api-client";
import { Card, StatusPill, ShimmerKpiCard, ShimmerTableRow, EmptyState } from "@saachi/ui";
import { formatCurrency, formatDate } from "@saachi/utils";

const TIER_TONE: Record<PromotionSale["tier"], "warning" | "info" | "success"> = {
  bronze: "warning",
  silver: "info",
  gold: "success"
};

export default function PromotionSalesPage() {
  const { data: sales, isLoading } = useAdminPromotionSales();

  const now = Date.now();
  const active = (sales ?? []).filter((s) => new Date(s.expiresAt).getTime() > now);
  const totalRevenue = (sales ?? []).reduce((sum, s) => sum + s.amount, 0);
  const tierCounts = {
    gold: (sales ?? []).filter((s) => s.tier === "gold").length,
    silver: (sales ?? []).filter((s) => s.tier === "silver").length,
    bronze: (sales ?? []).filter((s) => s.tier === "bronze").length
  };

  return (
    <main className="mx-auto max-w-[1100px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
          <Megaphone size={17} strokeWidth={1.75} />
        </div>
        <div>
          <h1 className="text-[22px] font-semibold text-ink">Promotion Package Sales</h1>
          <p className="mt-0.5 text-[13px] text-ink-soft">Instructor purchases of Bronze/Silver/Gold visibility boosts.</p>
        </div>
      </div>

      {isLoading ? (
        <div className="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {Array.from({ length: 4 }).map((_, i) => (
            <ShimmerKpiCard key={i} />
          ))}
        </div>
      ) : (
        <div className="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <Card className="p-5">
            <p className="text-[12px] text-ink-soft">Total revenue</p>
            <p className="mt-1 font-mono text-[22px] font-semibold text-ink">{formatCurrency(totalRevenue, "USD")}</p>
          </Card>
          <Card className="p-5">
            <p className="text-[12px] text-ink-soft">Currently active</p>
            <p className="mt-1 font-mono text-[22px] font-semibold text-ink">{active.length}</p>
          </Card>
          <Card className="p-5">
            <p className="flex items-center gap-1.5 text-[12px] text-ink-soft">
              <Crown size={12} strokeWidth={1.75} /> Gold sold
            </p>
            <p className="mt-1 font-mono text-[22px] font-semibold text-ink">{tierCounts.gold}</p>
          </Card>
          <Card className="p-5">
            <p className="text-[12px] text-ink-soft">Silver + Bronze sold</p>
            <p className="mt-1 font-mono text-[22px] font-semibold text-ink">{tierCounts.silver + tierCounts.bronze}</p>
          </Card>
        </div>
      )}

      {isLoading ? (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          {Array.from({ length: 5 }).map((_, i) => (
            <ShimmerTableRow key={i} columns={4} />
          ))}
        </div>
      ) : !sales || sales.length === 0 ? (
        <EmptyState icon={<Megaphone size={22} strokeWidth={1.75} />} title="No promotion sales yet" description="Boost package purchases will show up here." />
      ) : (
        <div className="flex flex-col gap-3">
          {sales.map((sale) => {
            const isActive = new Date(sale.expiresAt).getTime() > now;
            return (
              <Card key={sale.id} className="flex flex-col gap-3 p-4 sm:flex-row sm:items-center sm:justify-between">
                <div className="min-w-0">
                  <div className="flex items-center gap-2.5">
                    <p className="truncate text-[14px] font-semibold text-ink">{sale.courseTitle}</p>
                    <StatusPill label={sale.tier} tone={TIER_TONE[sale.tier]} />
                    {!isActive && <span className="text-[11px] font-medium text-ink-soft">Expired</span>}
                  </div>
                  <p className="mt-1 text-[12.5px] text-ink-soft">
                    {sale.instructorName} - purchased {formatDate(sale.purchasedAt)} - {isActive ? "expires" : "expired"} {formatDate(sale.expiresAt)}
                  </p>
                </div>
                <span className="shrink-0 font-mono text-[15px] font-semibold text-ink">
                  {formatCurrency(sale.amount, sale.currency)}
                </span>
              </Card>
            );
          })}
        </div>
      )}
    </main>
  );
}