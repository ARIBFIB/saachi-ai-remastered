"use client";

import { useState } from "react";
import { Users2, Plus, X } from "lucide-react";
import { Button, Card, Checkbox, Input } from "@saachi/ui";
import { formatCurrency } from "@saachi/utils";

const DAYS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

export default function InstructorMentorshipSettingsPage() {
  const [enabled, setEnabled] = useState(false);
  const [rate, setRate] = useState(40);
  const [slots, setSlots] = useState<string[]>(["Mon 3:00 PM", "Wed 11:00 AM"]);
  const [newSlot, setNewSlot] = useState("");
  const [saved, setSaved] = useState(false);

  const addSlot = () => {
    if (!newSlot.trim()) return;
    setSlots((prev) => [...prev, newSlot.trim()]);
    setNewSlot("");
  };

  const removeSlot = (slot: string) => {
    setSlots((prev) => prev.filter((s) => s !== slot));
  };

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    setSaved(true);
    setTimeout(() => setSaved(false), 2500);
  };

  return (
    <main className="mx-auto max-w-[720px] px-6 py-10 md:px-10">
      <div className="mb-8 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-control bg-teal-light text-teal">
          <Users2 size={18} />
        </div>
        <div>
          <h1 className="font-display text-[24px] font-semibold text-ink">Mentorship Settings</h1>
          <p className="mt-1 text-[13px] text-ink-soft">Offer paid 1-on-1 sessions to your students.</p>
        </div>
      </div>

      <form onSubmit={handleSave} className="flex flex-col gap-6">
        <Card className="p-6">
          <Checkbox
            label="Enable mentorship bookings for my profile"
            checked={enabled}
            onChange={(e) => setEnabled(e.target.checked)}
          />
        </Card>

        <Card className="p-6">
          <Input
            label="Hourly rate (USD)"
            type="number"
            min={0}
            value={rate}
            onChange={(e) => setRate(Number(e.target.value))}
            helperText={`Learners will see this shown as ${formatCurrency(rate, "USD")} / 30 min session.`}
          />
        </Card>

        <Card className="p-6">
          <h2 className="mb-4 text-[15px] font-semibold text-ink">Available time slots</h2>
          <div className="mb-4 flex flex-wrap gap-2">
            {slots.map((slot) => (
              <span
                key={slot}
                className="flex items-center gap-2 rounded-full border border-line-strong px-3 py-1.5 text-[12px] text-ink"
              >
                {slot}
                <button type="button" onClick={() => removeSlot(slot)} className="text-ink-soft hover:text-error">
                  <X size={12} />
                </button>
              </span>
            ))}
          </div>
          <div className="flex items-center gap-2">
            <Input
              placeholder="e.g. Tue 4:00 PM"
              value={newSlot}
              onChange={(e) => setNewSlot(e.target.value)}
              className="h-10 flex-1"
            />
            <Button type="button" size="sm" variant="secondary" onClick={addSlot}>
              <Plus size={14} /> Add slot
            </Button>
          </div>
          <p className="mt-3 text-[12px] text-ink-soft">
            Days for reference: {DAYS.join(", ")}
          </p>
        </Card>

        <div className="flex items-center gap-3">
          <Button type="submit">Save mentorship settings</Button>
          {saved && <span className="text-[13px] text-teal">Saved</span>}
        </div>
      </form>
    </main>
  );
}