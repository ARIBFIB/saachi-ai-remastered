"use client";

import { useSession, useLogout } from "@saachi/api-client";
import { Button, Input, EmptyState } from "@saachi/ui";

export default function SettingsPage() {
  const { data: session } = useSession();
  const logout = useLogout();

  if (!session) {
    return <EmptyState title="Not logged in" description="Log in to view and edit your settings." />;
  }

  return (
    <div>
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Settings</h1>

      <div className="max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-4 text-[15px] font-semibold text-ink">Profile</h2>
        <div className="flex flex-col gap-4">
          <Input label="Full name" defaultValue={session.fullName} />
          <Input label="Email" defaultValue={session.email} type="email" />
          <Button className="self-start">Save changes</Button>
        </div>
      </div>

      <div className="mt-6 max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-2 text-[15px] font-semibold text-ink">Session</h2>
        <p className="mb-4 text-[13px] text-ink-soft">Logged in as {session.email}</p>
        <Button variant="danger" onClick={() => logout.mutate()}>
          Log out
        </Button>
      </div>
    </div>
  );
}