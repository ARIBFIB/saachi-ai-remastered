"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { useRouter } from "next/navigation";
import { useState } from "react";
import Link from "next/link";
import { registerSchema, type RegisterInput } from "@saachi/utils";
import { useRegister } from "@saachi/api-client";
import { Button, Card, Input, SocialLoginButtons } from "@saachi/ui";

export default function RegisterPage() {
  const router = useRouter();
  const registerMutation = useRegister();
  const [serverError, setServerError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting }
  } = useForm<RegisterInput>({
    resolver: zodResolver(registerSchema),
    defaultValues: { role: "learner" }
  });

  const onSubmit = async (data: RegisterInput) => {
    setServerError(null);
    try {
      await registerMutation.mutateAsync(data);
      router.push("/dashboard");
    } catch (err: any) {
      setServerError(err?.message ?? "Registration failed. Please try again.");
    }
  };

  return (
    <Card className="w-full max-w-[440px] p-8">
      <h1 className="font-display text-[24px] font-semibold text-ink">Create your account</h1>
      <p className="mb-6 mt-1 text-[14px] text-ink-soft">
        Join Saachi AI as a learner. You can apply to become an instructor later.
      </p>

      <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
        <Input label="Full name" placeholder="Your name" {...register("fullName")} error={errors.fullName?.message} />
        <Input
          label="Email"
          type="email"
          placeholder="you@example.com"
          {...register("email")}
          error={errors.email?.message}
        />
        <Input
          label="Password"
          type="password"
          placeholder="At least 8 characters"
          {...register("password")}
          error={errors.password?.message}
        />
        <Input
          label="Confirm password"
          type="password"
          placeholder="Repeat your password"
          {...register("confirmPassword")}
          error={errors.confirmPassword?.message}
        />

        {serverError && <p className="text-[13px] text-error">{serverError}</p>}

        <Button type="submit" size="lg" disabled={isSubmitting || registerMutation.isPending}>
          {isSubmitting || registerMutation.isPending ? "Creating accountÃ¢â‚¬Â¦" : "Create Account"}
        </Button>
      </form>

      <div className="mt-6">
        <SocialLoginButtons
          onGoogle={() =>
            onSubmit({ fullName: "Google User", email: "demo.google@saachi.ai", password: "demo-oauth123", confirmPassword: "demo-oauth123", role: "learner" })
          }
          onMicrosoft={() =>
            onSubmit({ fullName: "Microsoft User", email: "demo.microsoft@saachi.ai", password: "demo-oauth123", confirmPassword: "demo-oauth123", role: "learner" })
          }
        />
      </div>

      <div className="mt-5 text-center text-[14px] text-ink-soft">
        Already have an account?{" "}
        <Link href="/login" className="font-semibold text-ink hover:text-gold-dark">
          Log in
        </Link>
      </div>
    </Card>
  );
}