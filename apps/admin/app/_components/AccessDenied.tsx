"use client";

import { useRouter } from "next/navigation";
import { ShieldAlert } from "lucide-react";
import { Button } from "@saachi/ui";
import { ROLE_LABEL, type StaffRole } from "../../lib/permissions";

type AccessDeniedProps = {
  role: StaffRole;
};

export function AccessDenied({ role }: AccessDeniedProps) {
  const router = useRouter();

  return (
    <main className="mx-auto flex max-w-[600px] flex-col items-center px-4 py-24 text-center">
      <div className="mb-5 flex h-14 w-14 items-center justify-center rounded-full border border-error text-error">
        <ShieldAlert size={24} strokeWidth={1.75} />
      </div>
      <h1 className="text-[20px] font-semibold text-ink">Access denied</h1>
      <p className="mt-2 text-[13.5px] leading-relaxed text-ink-soft">
        Your current role - <span className="font-semibold text-ink">{ROLE_LABEL[role]}</span> - does not have
        permission to view this page. Switch to a role with access, or contact a Super Admin if you believe this is
        a mistake.
      </p>
      <Button className="mt-6" onClick={() => router.push("/dashboard")}>
        Back to Dashboard
      </Button>
    </main>
  );
}