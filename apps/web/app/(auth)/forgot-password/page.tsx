"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { useState } from "react";
import Link from "next/link";
import { forgotPasswordSchema, type ForgotPasswordInput } from "@saachi/utils";
import { apiRequest } from "@saachi/api-client";
import { Button, Card, Input } from "@saachi/ui";

export default function ForgotPasswordPage() {
  const [sent, setSent] = useState(false);
  const [serverError, setServerError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting }
  } = useForm<ForgotPasswordInput>({
    resolver: zodResolver(forgotPasswordSchema)
  });

  const onSubmit = async (data: ForgotPasswordInput) => {
    setServerError(null);
    try {
      await apiRequest("/auth/forgot-password", { method: "POST", body: data });
      setSent(true);
    } catch (err: any) {
      setServerError(err?.message ?? "Something went wrong. Please try again.");
    }
  };

  if (sent) {
    return (
      <Card className="w-full max-w-[420px] p-8">
        <h1 className="font-display text-[22px] font-semibold text-ink">Check your email</h1>
        <p className="mt-2 text-[14px] text-ink-soft">
          If an account exists for that email, we've sent a password reset link.
        </p>
        <div className="mt-6">
          <Link href="/login" className="text-[14px] font-semibold text-ink hover:text-gold-dark">
            Back to login
          </Link>
        </div>
      </Card>
    );
  }

  return (
    <Card className="w-full max-w-[420px] p-8">
      <h1 className="font-display text-[22px] font-semibold text-ink">Reset your password</h1>
      <p className="mb-6 mt-1 text-[14px] text-ink-soft">
        Enter your email and we'll send you a reset link.
      </p>

      <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
        <Input
          label="Email"
          type="email"
          placeholder="you@example.com"
          {...register("email")}
          error={errors.email?.message}
        />

        {serverError && <p className="text-[13px] text-error">{serverError}</p>}

        <Button type="submit" size="lg" disabled={isSubmitting}>
          {isSubmitting ? "Sendingâ€¦" : "Send Reset Link"}
        </Button>
      </form>

      <div className="mt-5 text-center text-[14px] text-ink-soft">
        <Link href="/login" className="hover:text-ink">
          Back to login
        </Link>
      </div>
    </Card>
  );
}