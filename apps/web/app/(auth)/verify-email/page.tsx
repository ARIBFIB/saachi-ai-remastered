import Link from "next/link";
import { Check, ArrowRight } from "lucide-react";

export default function EmailVerifiedPage() {
  return (
    <div className="relative flex min-h-screen items-center justify-center overflow-hidden bg-[var(--token-color-surface)] p-12">
      <div
        className="pointer-events-none absolute -left-32 -top-60 h-[640px] w-[640px] rounded-full opacity-20 blur-[50px]"
        style={{ backgroundColor: "var(--token-color-amberTint)" }}
      />
      <div
        className="pointer-events-none absolute -right-32 bottom-0 h-[768px] w-[768px] rounded-full opacity-10 blur-3xl"
        style={{ backgroundColor: "var(--token-color-successTint)" }}
      />

      <div className="relative flex w-96 max-w-96 flex-col items-center gap-6 rounded-[var(--token-radius-lg)] border border-[var(--token-color-border)] bg-[var(--token-color-surface)] p-10 shadow-[var(--token-shadow-sm)]">
        <span className="relative flex h-20 w-20 items-center justify-center rounded-full bg-[var(--token-color-success)]/10">
          <Check className="h-9 w-9 text-[var(--token-color-success)]" strokeWidth={3} />
          <span className="absolute inset-0 rounded-full border-4 border-[var(--token-color-success)] opacity-20" />
        </span>

        <div className="flex flex-col items-center gap-2 text-center">
          <h1 className="text-3xl font-bold text-[var(--token-color-ink)]">Email Verified</h1>
          <p className="max-w-72 text-base leading-6 text-gray-700">
            Your email address has been successfully confirmed. You now have full access to Saachi AI.
          </p>
        </div>

        <Link
          href="/dashboard"
          className="flex w-full items-center justify-center gap-2 rounded-[var(--token-radius-md)] bg-[var(--token-color-amber)] px-6 py-4 text-sm font-semibold tracking-wide text-white shadow-[var(--token-shadow-sm)] hover:bg-[var(--token-color-amberDark)]"
        >
          Continue to Dashboard
          <ArrowRight className="h-3 w-3" />
        </Link>
      </div>
    </div>
  );
}