"use client";

import { useState, type FormEvent, Suspense } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";
import { Button, Input, EmptyState } from "@saachi/ui";

function ResetPasswordForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const token = searchParams.get("token");

  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [done, setDone] = useState(false);

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (password !== confirmPassword) return;
    setSubmitting(true);
    // NOTE: demo-only, no backend password-reset-confirm mutation wired up yet.
    setTimeout(() => {
      setSubmitting(false);
      setDone(true);
    }, 500);
  }

  if (!token) {
    return (
      <EmptyState
        title="Invalid or expired link"
        description="This password reset link is missing or no longer valid."
        action={
          <Link href="/forgot-password">
            <Button>Request a new link</Button>
          </Link>
        }
      />
    );
  }

  if (done) {
    return (
      <EmptyState
        title="Password updated"
        description="Your password has been reset. You can now log in."
        action={<Button onClick={() => router.push("/login")}>Go to login</Button>}
      />
    );
  }

  return (
    <>
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Reset password</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Choose a new password for your account.</p>

      <form onSubmit={handleSubmit} className="flex flex-col gap-4">
        <Input
          label="New password"
          type="password"
          required
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="At least 8 characters"
        />
        <Input
          label="Confirm new password"
          type="password"
          required
          value={confirmPassword}
          onChange={(e) => setConfirmPassword(e.target.value)}
          error={confirmPassword && password !== confirmPassword ? "Passwords do not match" : undefined}
        />
        <Button type="submit" size="lg" loading={submitting}>
          Reset password
        </Button>
      </form>
    </>
  );
}

export default function ResetPasswordPage() {
  return (
    <div className="mx-auto flex max-w-md flex-col px-4 py-16 md:px-0">
      <Suspense fallback={null}>
        <ResetPasswordForm />
      </Suspense>
    </div>
  );
}