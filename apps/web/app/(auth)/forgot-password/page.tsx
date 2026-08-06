"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { useState } from "react";
import Link from "next/link";
import { forgotPasswordSchema, type ForgotPasswordInput } from "@saachi/utils";
import { apiRequest } from "@saachi/api-client";
import { Button, Card } from "@saachi/ui";

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
      <Card>
        <h1 style={{ fontSize: "22px", fontWeight: 700, marginBottom: "8px" }}>Check your email</h1>
        <p style={{ color: "var(--text-secondary)", fontSize: "14px" }}>
          If an account exists for that email, we&apos;ve sent a password reset link.
        </p>
        <div style={{ marginTop: "20px" }}>
          <Link href="/login">Back to login</Link>
        </div>
      </Card>
    );
  }

  return (
    <Card>
      <h1 style={{ fontSize: "22px", fontWeight: 700, marginBottom: "4px" }}>Reset your password</h1>
      <p style={{ color: "var(--text-secondary)", fontSize: "14px", marginBottom: "24px" }}>
        Enter your email and we&apos;ll send you a reset link.
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

        {serverError && <p style={{ color: "#EF4444", fontSize: "13px" }}>{serverError}</p>}

        <Button type="submit" size="lg" disabled={isSubmitting}>
          {isSubmitting ? "Sending..." : "Send Reset Link"}
        </Button>
      </form>

      <div style={{ marginTop: "20px", fontSize: "14px", textAlign: "center", color: "var(--text-secondary)" }}>
        <Link href="/login">Back to login</Link>
      </div>
    </Card>
  );
}
