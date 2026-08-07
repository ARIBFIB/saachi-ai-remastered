"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { useRouter, useSearchParams } from "next/navigation";
import { useState } from "react";
import Link from "next/link";
import { resetPasswordSchema, type ResetPasswordInput } from "@saachi/utils";
import { Button, Card, Input } from "@saachi/ui";

export default function ResetPasswordPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [serverError, setServerError] = useState<string | null>(null);
  const [done, setDone] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting }
  } = useForm<ResetPasswordInput>({
    resolver: zodResolver(resetPasswordSchema),
    defaultValues: { token: searchParams.get("token") ?? "demo-token" }
  });

  const onSubmit = async (data: ResetPasswordInput) => {
    setServerError(null);
    // NOTE: demo-only. Replace with apiRequest("/auth/reset-password", ...) once backend exists.
    await new Promise((resolve) => setTimeout(resolve, 500));
    setDone(true);
  };

  if (done) {
    return (
      <Card className="w-full max-w-[420px] p-8 text-center">
        <h1 className="font-display text-[22px] font-semibold text-ink">Password updated</h1>
        <p className="mt-2 text-[14px] text-ink-soft">
          Your password has been reset. You can now log in with your new password.
        </p>
        <Button size="lg" className="mt-6 w-full" onClick={() => router.push("/login")}>
          Go to login
        </Button>
      </Card>
    );
  }

  return (
    <Card className="w-full max-w-[420px] p-8">
      <h1 className="font-display text-[22px] font-semibold text-ink">Set a new password</h1>
      <p className="mb-6 mt-1 text-[14px] text-ink-soft">Choose a strong password for your account.</p>

      <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
        <input type="hidden" {...register("token")} />
        <Input
          label="New password"
          type="password"
          placeholder="At least 8 characters"
          {...register("password")}
          error={errors.password?.message}
        />
        <Input
          label="Confirm new password"
          type="password"
          placeholder="Repeat new password"
          {...register("confirmPassword")}
          error={errors.confirmPassword?.message}
        />

        {serverError && <p className="text-[13px] text-error">{serverError}</p>}

        <Button type="submit" size="lg" disabled={isSubmitting}>
          {isSubmitting ? "Updating..." : "Update password"}
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