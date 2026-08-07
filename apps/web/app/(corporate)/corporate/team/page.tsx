"use client";

import { useState } from "react";
import { UserPlus, Trash2 } from "lucide-react";
import { useCorporateStore } from "@saachi/store";
import { Button, Card, Input, Badge } from "@saachi/ui";

export default function TeamRosterPage() {
  const { team, account, inviteMember, removeMember } = useCorporateStore();
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");

  const seatsRemaining = account.seatsPurchased - account.seatsUsed;

  const handleInvite = (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim() || !email.trim() || seatsRemaining <= 0) return;
    inviteMember(name.trim(), email.trim());
    setName("");
    setEmail("");
  };

  return (
    <main className="mx-auto max-w-[900px] px-6 py-10 md:px-10">
      <div className="mb-8">
        <h1 className="font-display text-[26px] font-semibold text-ink">Team Roster</h1>
        <p className="mt-1 text-[14px] text-ink-soft">
          {seatsRemaining} of {account.seatsPurchased} seats available
        </p>
      </div>

      <Card className="mb-8 p-6">
        <h2 className="mb-4 text-[15px] font-semibold text-ink">Invite a team member</h2>
        <form onSubmit={handleInvite} className="flex flex-col gap-4 sm:flex-row sm:items-end">
          <Input label="Full name" placeholder="Team member's name" value={name} onChange={(e) => setName(e.target.value)} className="flex-1" />
          <Input label="Work email" type="email" placeholder="name@company.com" value={email} onChange={(e) => setEmail(e.target.value)} className="flex-1" />
          <Button type="submit" disabled={seatsRemaining <= 0}>
            <UserPlus size={16} /> Invite
          </Button>
        </form>
        {seatsRemaining <= 0 && (
          <p className="mt-3 text-[12px] text-error">No seats remaining - purchase more seats in Billing.</p>
        )}
      </Card>

      <div className="flex flex-col gap-3">
        {team.map((member) => (
          <Card key={member.id} className="flex items-center justify-between p-4">
            <div>
              <div className="flex items-center gap-2">
                <p className="text-[14px] font-semibold text-ink">{member.name}</p>
                <Badge variant={member.status === "active" ? "success" : "default"}>{member.status}</Badge>
              </div>
              <p className="mt-1 text-[12px] text-ink-soft">{member.email}</p>
            </div>
            <button
              type="button"
              onClick={() => removeMember(member.id)}
              className="flex h-8 w-8 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim hover:text-error"
              aria-label="Remove member"
            >
              <Trash2 size={15} />
            </button>
          </Card>
        ))}
      </div>
    </main>
  );
}