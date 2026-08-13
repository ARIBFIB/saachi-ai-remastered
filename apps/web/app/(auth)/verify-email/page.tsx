"use client";

import { Suspense, useEffect, useState } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import { MailCheck, MailWarning } from "lucide-react";
import { Button, Loading, EmptyState } from "@saachi/ui";

function VerifyEmailContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const token = searchParams.get("token");
  const [status, setStatus] = useState<"checking" | "success" | "error">("checking");

  useEffect(() => {
    if (!token) {
      setStatus("error");
      return;
    }
    // NOTE: demo-only, no backend email-verification mutation wired up yet.
    const timer = setTimeout(() => setStatus("success"), 800);
    return () => clearTimeout(timer);
  }, [token]);

  if (status === "checking") {
    return <Loading label="Verifying your email..." />;
  }

  if (status === "error") {
    return (
      <EmptyState
        title="Verification link invalid"
        description="This email verification link is missing or has expired."
        action={<Button onClick={() => router.push("/login")}>Back to login</Button>}
      />
    );
  }

  return (
    <div className="flex flex-col items-center text-center">
      <div className="mb-4 flex h-14 w-14 items-center justify-center rounded-full bg-teal-light text-teal">
        <MailCheck size={26} />
      </div>
      <h1 className="mb-2 font-display text-[24px] font-bold text-ink">Email verified</h1>
      <p className="mb-8 max-w-sm text-[14px] text-ink-soft">
        Your email address has been confirmed. You can now access your account.
      </p>
      <Button onClick={() => router.push("/dashboard")}>Go to dashboard</Button>
    </div>
  );
}

export default function VerifyEmailPage() {
  return (
    <div className="mx-auto flex max-w-md flex-col px-4 py-20 md:px-0">
      <Suspense
        fallback={
          <div className="flex flex-col items-center text-center text-ink-soft">
            <MailWarning size={26} className="mb-3" />
            Loading...
          </div>
        }
      >
        <VerifyEmailContent />
      </Suspense>
    </div>
  );
}