"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { useRouter } from "next/navigation";
import { useState } from "react";
import Link from "next/link";
import { loginSchema, type LoginInput } from "@saachi/utils";
import { useLogin } from "@saachi/api-client";
import { Button, Card, Input } from "@saachi/ui";

export default function LoginPage() {
  const router = useRouter();
  const loginMutation = useLogin();
  const [serverError, setServerError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting }
  } = useForm<LoginInput>({
    resolver: zodResolver(loginSchema)
  });

  const onSubmit = async (data: LoginInput) => {
    setServerError(null);
    try {
      const result = await loginMutation.mutateAsync(data);
      if ("requires2fa" in result && result.requires2fa) {
        router.push("/login/2fa");
        return;
      }
      router.push("/dashboard");
    } catch (err: any) {
      setServerError(err?.message ?? "Login failed. Please try again.");
    }
  };

  return (
    <Card className="w-full max-w-[420px] p-8">
      <h1 className="font-display text-[24px] font-semibold text-ink">Welcome back</h1>
      <p className="mb-6 mt-1 text-[14px] text-ink-soft">
        Log in to continue learning or teaching on Saachi AI.
      </p>

      <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
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
          placeholder="********"
          {...register("password")}
          error={errors.password?.message}
        />

        {serverError && <p className="text-[13px] text-error">{serverError}</p>}

        <Button type="submit" size="lg" disabled={isSubmitting || loginMutation.isPending}>
          {isSubmitting || loginMutation.isPending ? "Logging inâ€¦" : "Log In"}
        </Button>
      </form>

      <div className="mt-5 text-center text-[14px] text-ink-soft">
        <Link href="/forgot-password" className="hover:text-ink">
          Forgot password?
        </Link>
        <span className="mx-2">Â·</span>
        <Link href="/register" className="hover:text-ink">
          Create an account
        </Link>
      </div>
    </Card>
  );
}