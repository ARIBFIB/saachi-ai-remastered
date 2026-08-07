"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { MailCheck, Loader2 } from "lucide-react";
import { Button, Card } from "@saachi/ui";

export default function VerifyEmailPage() {
  const router = useRouter();
  const [status, setStatus] = useState<"pending" | "verified">("pending");

  useEffect(() => {
    // NOTE: demo-only. Replace with apiRequest("/auth/verify-email", ...) using
    // the token from the URL once the backend is available.
    const timer = setTimeout(() => setStatus("verified"), 1200);
    return () => clearTimeout(timer);
  }, []);

  return (
    <Card className="w-full max-w-[420px] p-8 text-center">
      <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-teal-light text-teal">
        {status === "pending" ? <Loader2 size={22} className="animate-spin" /> : <MailCheck size={22} />}
      </div>

      {status === "pending" ? (
        <>
          <h1 className="font-display text-[22px] font-semibold text-ink">Verifying your email...</h1>
          <p className="mt-2 text-[14px] text-ink-soft">This will only take a moment.</p>
        </>
      ) : (
        <>
          <h1 className="font-display text-[22px] font-semibold text-ink">Email verified</h1>
          <p className="mt-2 text-[14px] text-ink-soft">
            Your email address has been confirmed. You're all set.
          </p>
          <Button size="lg" className="mt-6 w-full" onClick={() => router.push("/dashboard")}>
            Go to dashboard
          </Button>
        </>
      )}

      <div className="mt-5 text-center text-[14px] text-ink-soft">
        <Link href="/login" className="hover:text-ink">
          Back to login
        </Link>
      </div>
    </Card>
  );
}