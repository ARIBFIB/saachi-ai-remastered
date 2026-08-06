"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { useRouter } from "next/navigation";
import { useState } from "react";
import Link from "next/link";
import { registerSchema, type RegisterInput } from "@saachi/utils";
import { useRegister } from "@saachi/api-client";
import { Button, Card } from "@saachi/ui";

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
    <Card>
      <h1 style={{ fontSize: "24px", fontWeight: 700, marginBottom: "4px" }}>Create your account</h1>
      <p style={{ color: "var(--text-secondary)", fontSize: "14px", marginBottom: "24px" }}>
        Join Saachi AI as a learner. You can apply to become an instructor later.
      </p>

      <form onSubmit={handleSubmit(onSubmit)} style={{ display: "flex", flexDirection: "column", gap: "16px" }}>
        <div>
          <label style={{ display: "block", fontSize: "13px", fontWeight: 600, marginBottom: "6px" }}>
            Full name
          </label>
          <input
            type="text"
            {...register("fullName")}
            style={{
              width: "100%",
              height: "44px",
              padding: "0 14px",
              borderRadius: "10px",
              border: "1px solid rgba(15,23,42,0.14)",
              fontSize: "15px"
            }}
            placeholder="Your name"
          />
          {errors.fullName && (
            <p style={{ color: "#EF4444", fontSize: "13px", marginTop: "4px" }}>{errors.fullName.message}</p>
          )}
        </div>

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
            placeholder="At least 8 characters"
          />
          {errors.password && (
            <p style={{ color: "#EF4444", fontSize: "13px", marginTop: "4px" }}>{errors.password.message}</p>
          )}
        </div>

        <div>
          <label style={{ display: "block", fontSize: "13px", fontWeight: 600, marginBottom: "6px" }}>
            Confirm password
          </label>
          <input
            type="password"
            {...register("confirmPassword")}
            style={{
              width: "100%",
              height: "44px",
              padding: "0 14px",
              borderRadius: "10px",
              border: "1px solid rgba(15,23,42,0.14)",
              fontSize: "15px"
            }}
            placeholder="Repeat your password"
          />
          {errors.confirmPassword && (
            <p style={{ color: "#EF4444", fontSize: "13px", marginTop: "4px" }}>
              {errors.confirmPassword.message}
            </p>
          )}
        </div>

        {serverError && <p style={{ color: "#EF4444", fontSize: "13px" }}>{serverError}</p>}

        <Button type="submit" size="lg" disabled={isSubmitting || registerMutation.isPending}>
          {isSubmitting || registerMutation.isPending ? "Creating account..." : "Create Account"}
        </Button>
      </form>

      <div style={{ marginTop: "20px", fontSize: "14px", textAlign: "center", color: "var(--text-secondary)" }}>
        Already have an account? <Link href="/login">Log in</Link>
      </div>
    </Card>
  );
}
