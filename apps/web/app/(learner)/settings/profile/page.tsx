"use client";

import { useState } from "react";
import Link from "next/link";
import { useSession } from "@saachi/api-client";
import { Button, Card, Input, Textarea } from "@saachi/ui";

const SETTINGS_TABS = [
  { label: "Profile", href: "/settings/profile" },
  { label: "Security", href: "/settings/security" }
];

export default function SettingsProfilePage() {
  const { data: session } = useSession();
  const [fullName, setFullName] = useState(session?.fullName ?? "");
  const [bio, setBio] = useState("");
  const [saved, setSaved] = useState(false);

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    // NOTE: demo-only, local state. Replace with Users API PATCH once backend exists.
    setSaved(true);
    setTimeout(() => setSaved(false), 2500);
  };

  return (
    <main className="mx-auto max-w-[720px] px-6 py-10 md:px-10">
      <h1 className="mb-6 font-display text-[26px] font-semibold text-ink">Settings</h1>

      <div className="mb-8 flex gap-2 border-b border-line">
        {SETTINGS_TABS.map((tab) => (
          <Link
            key={tab.href}
            href={tab.href}
            className="border-b-2 border-ink px-1 pb-3 text-[14px] font-semibold text-ink"
          >
            {tab.label}
          </Link>
        ))}
      </div>

      <Card className="p-6">
        <div className="mb-6 flex items-center gap-4">
          <div className="flex h-16 w-16 items-center justify-center overflow-hidden rounded-full bg-teal-light text-[20px] font-semibold text-teal">
            {session?.avatarUrl ? (
              // eslint-disable-next-line @next/next/no-img-element
              <img src={session.avatarUrl} alt={session.fullName} className="h-full w-full object-cover" />
            ) : (
              session?.fullName?.charAt(0) ?? "?"
            )}
          </div>
          <div>
            <p className="text-[14px] font-semibold text-ink">Profile photo</p>
            <p className="text-[12px] text-ink-soft">Demo avatar - upload not wired to a backend yet.</p>
          </div>
        </div>

        <form onSubmit={handleSave} className="flex flex-col gap-4">
          <Input label="Full name" value={fullName} onChange={(e) => setFullName(e.target.value)} />
          <Input label="Email" value={session?.email ?? ""} disabled />
          <Textarea
            label="Bio"
            placeholder="Tell us a bit about yourself..."
            value={bio}
            onChange={(e) => setBio(e.target.value)}
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