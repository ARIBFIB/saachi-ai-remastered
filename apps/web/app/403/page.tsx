import Link from "next/link";
import { Button } from "@saachi/ui";

export default function ForbiddenPage() {
  return (
    <div className="mx-auto flex max-w-lg flex-col items-center px-4 py-24 text-center md:px-0">
      <span className="font-mono text-[64px] font-bold text-gold-dark">403</span>
      <h1 className="mt-2 font-display text-[24px] font-bold text-ink">Access denied</h1>
      <p className="mt-2 text-[14px] text-ink-soft">
        You don&apos;t have permission to view this page.
      </p>
      <div className="mt-8 flex gap-3">
        <Link href="/dashboard">
          <Button>Back to dashboard</Button>
        </Link>
      </div>
    </div>
  );
}