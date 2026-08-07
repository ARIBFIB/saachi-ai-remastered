"use client";

import { useState } from "react";
import { useSession } from "@saachi/api-client";
import { Button, Card, Input, Textarea } from "@saachi/ui";

export default function InstructorSettingsPage() {
  const { data: session } = useSession();
  const [bio, setBio] = useState("");
  const [portfolio, setPortfolio] = useState("");
  const [saved, setSaved] = useState(false);

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    setSaved(true);
    setTimeout(() => setSaved(false), 2500);
  };

  return (
    <main className="mx-auto max-w-[720px] px-6 py-10 md:px-10">
      <h1 className="mb-8 font-display text-[26px] font-semibold text-ink">Instructor Settings</h1>

      <Card className="p-6">
        <form onSubmit={handleSave} className="flex flex-col gap-4">
          <Input label="Full name" defaultValue={session?.fullName ?? ""} />
          <Input label="Email" defaultValue={session?.email ?? ""} disabled />
          <Textarea
            label="Instructor bio"
            placeholder="Tell learners about your background and expertise..."
            value={bio}
            onChange={(e) => setBio(e.target.value)}
          />
          <Input
            label="Portfolio link"
            placeholder="https://github.com/you or LinkedIn"
            value={portfolio}
            onChange={(e) => setPortfolio(e.target.value)}
          />
          <div className="mt-2 flex items-center gap-3">
            <Button type="submit">Save changes</Button>
            {saved && <span className="text-[13px] text-teal">Saved</span>}
          </div>
        </form>
      </Card>
    </main>
  );
}