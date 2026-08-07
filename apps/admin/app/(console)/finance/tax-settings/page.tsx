"use client";

import { useState } from "react";
import { Percent, Plus, Pencil, Check, X } from "lucide-react";
import { useAdminTaxRules, useUpdateTaxRule, useCreateTaxRule, type TaxRule } from "@saachi/api-client";
import { Button, Card, Input, Modal, ShimmerTableRow , HelpTooltip } from "@saachi/ui";

export default function TaxSettingsPage() {
  const { data: rules, isLoading } = useAdminTaxRules();
  const updateRule = useUpdateTaxRule();
  const createRule = useCreateTaxRule();

  const [editing, setEditing] = useState<TaxRule | null>(null);
  const [editRate, setEditRate] = useState(0);
  const [editActive, setEditActive] = useState(true);

  const [showCreate, setShowCreate] = useState(false);
  const [newRegion, setNewRegion] = useState("");
  const [newRate, setNewRate] = useState(0);
  const [newAppliesTo, setNewAppliesTo] = useState("");

  const openEdit = (rule: TaxRule) => {
    setEditing(rule);
    setEditRate(rule.ratePercent);
    setEditActive(rule.active);
  };

  const handleSaveEdit = () => {
    if (!editing) return;
    updateRule.mutate({ id: editing.id, ratePercent: editRate, active: editActive });
    setEditing(null);
  };

  const handleCreate = () => {
    if (!newRegion.trim()) return;
    createRule.mutate({ region: newRegion.trim(), ratePercent: newRate, appliesTo: newAppliesTo.trim() || "All course sales" });
    setShowCreate(false);
    setNewRegion("");
    setNewRate(0);
    setNewAppliesTo("");
  };

  return (
    <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <Percent size={17} strokeWidth={1.75} />
          </div>
          <div>
            <div className="flex items-center gap-1.5"><h1 className="text-[22px] font-semibold text-ink">Tax / VAT Settings</h1><HelpTooltip text="Region-based tax rules that are applied automatically at checkout based on the buyer's location." /></div>
            <p className="mt-0.5 text-[13px] text-ink-soft">Region-based tax rules applied at checkout.</p>
          </div>
        </div>
        <Button size="sm" onClick={() => setShowCreate(true)}>
          <Plus size={14} strokeWidth={1.75} /> New rule
        </Button>
      </div>

      <div className="overflow-hidden rounded-card border border-line bg-card">
        {isLoading ? (
          Array.from({ length: 5 }).map((_, i) => <ShimmerTableRow key={i} columns={3} />)
        ) : (
          rules?.map((rule) => (
            <div key={rule.id} className="flex flex-col gap-3 border-b border-line px-5 py-4 last:border-0 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <div className="flex items-center gap-2.5">
                  <p className="text-[14px] font-semibold text-ink">{rule.region}</p>
                  <span
                    className={
                      rule.active
                        ? "rounded-full bg-success-tint px-2.5 py-0.5 text-[11px] font-semibold text-success"
                        : "rounded-full bg-paper-dim px-2.5 py-0.5 text-[11px] font-semibold text-ink-soft"
                    }
                  >
                    {rule.active ? "Active" : "Inactive"}
                  </span>
                </div>
                <p className="mt-1 text-[12px] text-ink-soft">{rule.appliesTo}</p>
              </div>
              <div className="flex shrink-0 items-center gap-4">
                <span className="font-mono text-[16px] font-semibold text-ink">{rule.ratePercent}%</span>
                <button
                  type="button"
                  onClick={() => openEdit(rule)}
                  className="flex h-8 w-8 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim hover:text-ink"
                >
                  <Pencil size={14} strokeWidth={1.75} />
                </button>
              </div>
            </div>
          ))
        )}
      </div>

      <Modal
        open={Boolean(editing)}
        onClose={() => setEditing(null)}
        title={`Edit tax rule - ${editing?.region ?? ""}`}
        footer={
          <>
            <Button variant="ghost" onClick={() => setEditing(null)}>
              Cancel
            </Button>
            <Button onClick={handleSaveEdit} disabled={updateRule.isPending}>
              Save changes
            </Button>
          </>
        }
      >
        <div className="flex flex-col gap-4">
          <Input
            label="Rate (%)"
            type="number"
            min={0}
            max={100}
            value={editRate}
            onChange={(e) => setEditRate(Number(e.target.value))}
          />
          <button
            type="button"
            onClick={() => setEditActive((v) => !v)}
            className="flex w-fit items-center gap-2 rounded-control border border-line-strong px-3.5 py-2 text-[13px] font-medium text-ink hover:border-ink"
          >
            {editActive ? <Check size={14} strokeWidth={2} className="text-success" /> : <X size={14} strokeWidth={2} className="text-ink-soft" />}
            {editActive ? "Active" : "Inactive"} - click to toggle
          </button>
        </div>
      </Modal>

      <Modal
        open={showCreate}
        onClose={() => setShowCreate(false)}
        title="New tax rule"
        footer={
          <>
            <Button variant="ghost" onClick={() => setShowCreate(false)}>
              Cancel
            </Button>
            <Button onClick={handleCreate} disabled={!newRegion.trim() || createRule.isPending}>
              Create rule
            </Button>
          </>
        }
      >
        <div className="flex flex-col gap-4">
          <Input label="Region" placeholder="e.g. Canada" value={newRegion} onChange={(e) => setNewRegion(e.target.value)} />
          <Input label="Rate (%)" type="number" min={0} max={100} value={newRate} onChange={(e) => setNewRate(Number(e.target.value))} />
          <Input label="Applies to" placeholder="e.g. Digital goods (GST)" value={newAppliesTo} onChange={(e) => setNewAppliesTo(e.target.value)} />
        </div>
      </Modal>
    </main>
  );
}