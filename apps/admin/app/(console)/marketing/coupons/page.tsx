"use client";

import { useState } from "react";
import { Ticket, Plus, Trash2, Search } from "lucide-react";
import {
  useAdminCoupons,
  useCreateCoupon,
  useToggleCouponActive,
  useDeleteCoupon,
  type AdminCoupon
} from "@saachi/api-client";
import { Button, Card, Input, Select, Modal, ShimmerTableRow, EmptyState } from "@saachi/ui";
import { formatDate } from "@saachi/utils";

const TYPE_OPTIONS = [
  { label: "Percent off", value: "percent" },
  { label: "Fixed amount off", value: "fixed" }
];

const SCOPE_OPTIONS = [
  { label: "Platform-wide", value: "platform_wide" },
  { label: "Category", value: "category" },
  { label: "Course", value: "course" }
];

export default function CouponManagementPage() {
  const [search, setSearch] = useState("");
  const { data: coupons, isLoading } = useAdminCoupons({ search: search || undefined });
  const createCoupon = useCreateCoupon();
  const toggleActive = useToggleCouponActive();
  const deleteCoupon = useDeleteCoupon();

  const [showCreate, setShowCreate] = useState(false);
  const [code, setCode] = useState("");
  const [type, setType] = useState<AdminCoupon["type"]>("percent");
  const [value, setValue] = useState(10);
  const [scope, setScope] = useState<AdminCoupon["scope"]>("platform_wide");
  const [usageLimit, setUsageLimit] = useState(100);
  const [expiresAt, setExpiresAt] = useState(new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10));
  const [deleteTarget, setDeleteTarget] = useState<AdminCoupon | null>(null);

  const resetForm = () => {
    setCode("");
    setType("percent");
    setValue(10);
    setScope("platform_wide");
    setUsageLimit(100);
    setExpiresAt(new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10));
  };

  const handleCreate = () => {
    if (!code.trim()) return;
    createCoupon.mutate({
      code: code.trim().toUpperCase(),
      type,
      value,
      scope,
      usageLimit,
      expiresAt: new Date(expiresAt).toISOString(),
      active: true
    });
    setShowCreate(false);
    resetForm();
  };

  const handleDelete = () => {
    if (!deleteTarget) return;
    deleteCoupon.mutate(deleteTarget.id);
    setDeleteTarget(null);
  };

  return (
    <main className="mx-auto max-w-[1100px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <Ticket size={17} strokeWidth={1.75} />
          </div>
          <div>
            <h1 className="text-[22px] font-semibold text-ink">Coupon Management</h1>
            <p className="mt-0.5 text-[13px] text-ink-soft">Platform-wide and scoped promotional codes.</p>
          </div>
        </div>
        <Button size="sm" onClick={() => setShowCreate(true)}>
          <Plus size={14} strokeWidth={1.75} /> New coupon
        </Button>
      </div>

      <div className="relative mb-5 max-w-[320px]">
        <Search size={15} strokeWidth={1.75} className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-ink-soft" />
        <input
          placeholder="Search coupon code"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="h-10 w-full rounded-control border border-line bg-card pl-9 pr-3 text-[13px] text-ink outline-none placeholder:text-ink-soft/60 focus:border-line-strong"
        />
      </div>

      {isLoading ? (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          {Array.from({ length: 4 }).map((_, i) => (
            <ShimmerTableRow key={i} columns={5} />
          ))}
        </div>
      ) : !coupons || coupons.length === 0 ? (
        <EmptyState icon={<Ticket size={22} strokeWidth={1.75} />} title="No coupons found" description="Try a different search, or create a new coupon." />
      ) : (
        <div className="flex flex-col gap-3">
          {coupons.map((coupon) => {
            const usagePct = coupon.usageLimit > 0 ? Math.round((coupon.usageCount / coupon.usageLimit) * 100) : 0;
            return (
              <Card key={coupon.id} className="flex flex-col gap-4 p-4 sm:flex-row sm:items-center sm:justify-between">
                <div>
                  <div className="flex items-center gap-2.5">
                    <span className="rounded-control border border-line-strong px-2.5 py-1 font-mono text-[13px] font-semibold text-ink">
                      {coupon.code}
                    </span>
                    <span
                      className={
                        coupon.active
                          ? "rounded-full bg-success-tint px-2.5 py-0.5 text-[11px] font-semibold text-success"
                          : "rounded-full bg-paper-dim px-2.5 py-0.5 text-[11px] font-semibold text-ink-soft"
                      }
                    >
                      {coupon.active ? "Active" : "Inactive"}
                    </span>
                  </div>
                  <p className="mt-1.5 text-[12.5px] text-ink-soft">
                    {coupon.type === "percent" ? `${coupon.value}% off` : `$${coupon.value} off`} - {coupon.scope.replace("_", " ")} -
                    {" "}{coupon.usageCount}/{coupon.usageLimit} used ({usagePct}%) - expires {formatDate(coupon.expiresAt)}
                  </p>
                </div>

                <div className="flex shrink-0 items-center gap-2">
                  <Button size="sm" variant="secondary" onClick={() => toggleActive.mutate(coupon.id)}>
                    {coupon.active ? "Deactivate" : "Activate"}
                  </Button>
                  <button
                    type="button"
                    onClick={() => setDeleteTarget(coupon)}
                    className="flex h-9 w-9 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim hover:text-error"
                  >
                    <Trash2 size={15} strokeWidth={1.75} />
                  </button>
                </div>
              </Card>
            );
          })}
        </div>
      )}

      <Modal
        open={showCreate}
        onClose={() => setShowCreate(false)}
        title="New coupon"
        footer={
          <>
            <Button variant="ghost" onClick={() => setShowCreate(false)}>
              Cancel
            </Button>
            <Button onClick={handleCreate} disabled={!code.trim() || createCoupon.isPending}>
              Create coupon
            </Button>
          </>
        }
      >
        <div className="flex flex-col gap-4">
          <Input label="Coupon code" value={code} onChange={(e) => setCode(e.target.value.toUpperCase())} placeholder="e.g. SUMMER20" />
          <div className="grid grid-cols-2 gap-4">
            <Select label="Discount type" options={TYPE_OPTIONS} value={type} onChange={(e) => setType(e.target.value as AdminCoupon["type"])} />
            <Input
              label={type === "percent" ? "Percent off" : "Amount off ($)"}
              type="number"
              min={0}
              value={value}
              onChange={(e) => setValue(Number(e.target.value))}
            />
          </div>
          <Select label="Scope" options={SCOPE_OPTIONS} value={scope} onChange={(e) => setScope(e.target.value as AdminCoupon["scope"])} />
          <div className="grid grid-cols-2 gap-4">
            <Input label="Usage limit" type="number" min={1} value={usageLimit} onChange={(e) => setUsageLimit(Number(e.target.value))} />
            <Input label="Expires" type="date" value={expiresAt} onChange={(e) => setExpiresAt(e.target.value)} />
          </div>
        </div>
      </Modal>

      <Modal
        open={Boolean(deleteTarget)}
        onClose={() => setDeleteTarget(null)}
        title="Delete coupon?"
        footer={
          <>
            <Button variant="ghost" onClick={() => setDeleteTarget(null)}>
              Cancel
            </Button>
            <Button variant="danger" onClick={handleDelete} disabled={deleteCoupon.isPending}>
              Delete
            </Button>
          </>
        }
      >
        <p className="text-[14px] text-ink-soft">
          This will permanently remove <span className="font-semibold text-ink">{deleteTarget?.code}</span>. It can no
          longer be applied at checkout.
        </p>
      </Modal>
    </main>
  );
}