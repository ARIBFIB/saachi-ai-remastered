"use client";

import { useState } from "react";
import { CreditCard, Pencil, Eye, EyeOff } from "lucide-react";
import { Button, Card, Input, Modal } from "@saachi/ui";

type Gateway = {
  id: string;
  name: string;
  region: string;
  enabled: boolean;
  apiKeyMasked: string;
};

const INITIAL_GATEWAYS: Gateway[] = [
  { id: "stripe", name: "Stripe", region: "International", enabled: true, apiKeyMasked: "sk_live_********4f21" },
  { id: "paypal", name: "PayPal", region: "International", enabled: true, apiKeyMasked: "client_********a9e0" },
  { id: "easypaisa", name: "Easypaisa", region: "Pakistan", enabled: false, apiKeyMasked: "not configured" },
  { id: "jazzcash", name: "JazzCash", region: "Pakistan", enabled: false, apiKeyMasked: "not configured" },
  { id: "bank_transfer", name: "Bank Transfer", region: "Pakistan", enabled: true, apiKeyMasked: "manual - no key" }
];

export default function PaymentGatewayConfigurationPage() {
  const [gateways, setGateways] = useState(INITIAL_GATEWAYS);
  const [editing, setEditing] = useState<Gateway | null>(null);
  const [newKey, setNewKey] = useState("");
  const [showKey, setShowKey] = useState(false);

  const toggleEnabled = (id: string) => {
    setGateways((prev) => prev.map((g) => (g.id === id ? { ...g, enabled: !g.enabled } : g)));
  };

  const openEdit = (gateway: Gateway) => {
    setEditing(gateway);
    setNewKey("");
    setShowKey(false);
  };

  const handleSaveKey = () => {
    if (!editing || !newKey.trim()) return;
    const masked = `********${newKey.trim().slice(-4)}`;
    setGateways((prev) => prev.map((g) => (g.id === editing.id ? { ...g, apiKeyMasked: masked } : g)));
    setEditing(null);
  };

  return (
    <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
          <CreditCard size={17} strokeWidth={1.75} />
        </div>
        <div>
          <h1 className="text-[22px] font-semibold text-ink">Payment Gateway Configuration</h1>
          <p className="mt-0.5 text-[13px] text-ink-soft">Enable gateways and manage API keys (masked at rest).</p>
        </div>
      </div>

      <div className="flex flex-col gap-3">
        {gateways.map((gateway) => (
          <Card key={gateway.id} className="flex flex-col gap-4 p-5 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <div className="flex items-center gap-2.5">
                <p className="text-[14px] font-semibold text-ink">{gateway.name}</p>
                <span className="rounded-full border border-line-strong px-2 py-0.5 text-[11px] text-ink-soft">{gateway.region}</span>
              </div>
              <p className="mt-1 font-mono text-[12.5px] text-ink-soft">{gateway.apiKeyMasked}</p>
            </div>
            <div className="flex shrink-0 items-center gap-3">
              <button
                type="button"
                onClick={() => toggleEnabled(gateway.id)}
                className={`relative h-6 w-11 shrink-0 rounded-full transition-colors duration-150 ease-out ${
                  gateway.enabled ? "bg-ink" : "bg-paper-dim"
                }`}
              >
                <span
                  className={`absolute top-0.5 h-5 w-5 rounded-full bg-paper transition-transform duration-150 ease-out ${
                    gateway.enabled ? "translate-x-[22px]" : "translate-x-0.5"
                  }`}
                />
              </button>
              <button
                type="button"
                onClick={() => openEdit(gateway)}
                className="flex h-8 w-8 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim hover:text-ink"
              >
                <Pencil size={14} strokeWidth={1.75} />
              </button>
            </div>
          </Card>
        ))}
      </div>

      <Modal
        open={Boolean(editing)}
        onClose={() => setEditing(null)}
        title={`Update API key - ${editing?.name ?? ""}`}
        footer={
          <>
            <Button variant="ghost" onClick={() => setEditing(null)}>Cancel</Button>
            <Button onClick={handleSaveKey} disabled={!newKey.trim()}>Save key</Button>
          </>
        }
      >
        <div className="relative">
          <Input
            label="New API key / secret"
            type={showKey ? "text" : "password"}
            value={newKey}
            onChange={(e) => setNewKey(e.target.value)}
            placeholder="Paste the new secret key"
          />
          <button
            type="button"
            onClick={() => setShowKey((v) => !v)}
            className="absolute right-3 top-[34px] text-ink-soft hover:text-ink"
          >
            {showKey ? <EyeOff size={15} strokeWidth={1.75} /> : <Eye size={15} strokeWidth={1.75} />}
          </button>
        </div>
      </Modal>
    </main>
  );
}