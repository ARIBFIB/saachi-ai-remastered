"use client";

import { useState, type FormEvent } from "react";
import Link from "next/link";
import { Button, Input, EmptyState } from "@saachi/ui";

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState("");
  const [submitted, setSubmitted] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setSubmitting(true);
    // NOTE: demo-only, no backend password-reset-request mutation wired up yet.
    setTimeout(() => {
      setSubmitting(false);
      setSubmitted(true);
    }, 500);
  }

  if (submitted) {
    return (
      <div className="mx-auto max-w-md px-4 py-16 md:px-0">
        <EmptyState
          title="Check your email"
          description={`If an account exists for ${email}, we've sent a link to reset your password.`}
          action={
            <Link href="/login">
              <Button variant="secondary">Back to login</Button>
            </Link>
          }
        />
      </div>
    );
  }

  return (
    <div className="mx-auto flex max-w-md flex-col px-4 py-16 md:px-0">
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Forgot password</h1>
      <p className="mb-8 text-[14px] text-ink-soft">
        Enter your email and we&apos;ll send you a link to reset your password.
      </p>

      <form onSubmit={handleSubmit} className="flex flex-col gap-4">
        <Input
          label="Email"
          type="email"
          required
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="you@example.com"
        />
        <Button type="submit" size="lg" loading={submitting}>
          Send reset link
        </Button>
      </form>

      <p className="mt-8 text-center text-[14px] text-ink-soft">
        Remembered your password?{" "}
        <Link href="/login" className="font-semibold text-gold-dark hover:underline">
          Log in
        </Link>
      </p>
    </div>
  );
}