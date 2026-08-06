"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { useRouter } from "next/navigation";
import { useState } from "react";
import Link from "next/link";
import { loginSchema, type LoginInput } from "@saachi/utils";
import { useLogin } from "@saachi/api-client";
import { Button, Card } from "@saachi/ui";

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
    <Card>
      <h1 style={{ fontSize: "24px", fontWeight: 700, marginBottom: "4px" }}>Welcome back</h1>
      <p style={{ color: "var(--text-secondary)", fontSize: "14px", marginBottom: "24px" }}>
        Log in to continue learning or teaching on Saachi AI.
      </p>

      <form onSubmit={handleSubmit(onSubmit)} style={{ display: "flex", flexDirection: "column", gap: "16px" }}>
        <div>
          <label style={{ display: "block", fontSize: "13px", fontWeight: 600, marginBottom: "6px" }}>
            Email
          </label>
          <input
            type="email"
            {...register("email")}
            style={{
              width: "100%",
              height: "44px",
              padding: "0 14px",
              borderRadius: "10px",
              border: "1px solid rgba(15,23,42,0.14)",
              fontSize: "15px"
            }}
            placeholder="you@example.com"
          />
          {errors.email && (
            <p style={{ color: "#EF4444", fontSize: "13px", marginTop: "4px" }}>{errors.email.message}</p>
          )}
        </div>

        <div>
          <label style={{ display: "block", fontSize: "13px", fontWeight: 600, marginBottom: "6px" }}>
            Password
          </label>
          <input
            type="password"
            {...register("password")}
            style={{
              width: "100%",
              height: "44px",
              padding: "0 14px",
              borderRadius: "10px",
              border: "1px solid rgba(15,23,42,0.14)",
              fontSize: "15px"
            }}
            placeholder="********"
          />
          {errors.password && (
            <p style={{ color: "#EF4444", fontSize: "13px", marginTop: "4px" }}>{errors.password.message}</p>
          )}
        </div>

        {serverError && (
          <p style={{ color: "#EF4444", fontSize: "13px" }}>{serverError}</p>
        )}

        <Button type="submit" size="lg" disabled={isSubmitting || loginMutation.isPending}>
          {isSubmitting || loginMutation.isPending ? "Logging in..." : "Log In"}
        </Button>
      </form>

      <div style={{ marginTop: "20px", fontSize: "14px", textAlign: "center", color: "var(--text-secondary)" }}>
        <Link href="/forgot-password">Forgot password?</Link>
        <span style={{ margin: "0 8px" }}>&middot;</span>
        <Link href="/register">Create an account</Link>
      </div>
    </Card>
  );
}
