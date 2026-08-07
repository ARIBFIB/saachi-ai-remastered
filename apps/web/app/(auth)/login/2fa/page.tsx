"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { ShieldCheck } from "lucide-react";
import { twoFactorSchema, type TwoFactorInput } from "@saachi/utils";
import { Button, Card, Input } from "@saachi/ui";

export default function TwoFactorPage() {
  const router = useRouter();
  const [serverError, setServerError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting }
  } = useForm<TwoFactorInput>({
    resolver: zodResolver(twoFactorSchema)
  });

  const onSubmit = async (data: TwoFactorInput) => {
    setServerError(null);
    // NOTE: demo-only. In this build, useLogin never returns requires2fa: true,
    // so this screen is reachable directly for UI/QA purposes. Wire to real
    // Auth API 2FA verification once the backend is available.
    await new Promise((resolve) => setTimeout(resolve, 500));
    if (data.code !== "000000") {
      setServerError("Demo mode: enter 000000 to continue.");
      return;
    }
    router.push("/dashboard");
  };

  return (
    <Card className="w-full max-w-[400px] p-8 text-center">
      <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-teal-light text-teal">
        <ShieldCheck size={22} />
      </div>
      <h1 className="font-display text-[22px] font-semibold text-ink">Two-factor verification</h1>
      <p className="mb-6 mt-2 text-[14px] text-ink-soft">
        Enter the 6-digit code from your authenticator app.
      </p>

      <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4 text-left">
        <Input
          label="Verification code"
          placeholder="000000"
          maxLength={6}
          {...register("code")}
          error={errors.code?.message}
        />

        {serverError && <p className="text-[13px] text-error">{serverError}</p>}

        <Button type="submit" size="lg" disabled={isSubmitting}>
          {isSubmitting ? "Verifying..." : "Verify"}
        </Button>
      </form>
    </Card>
  );
}