"use client";

import { useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { Button, Input, Select, SocialLoginButtons } from "@saachi/ui";
import { useRegister } from "@saachi/api-client";

const ROLE_OPTIONS = [
  { label: "Learner - I want to learn AI skills", value: "learner" },
  { label: "Instructor - I want to teach and sell courses", value: "instructor" }
];

export default function RegisterPage() {
  const router = useRouter();
  const register = useRegister();
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [role, setRole] = useState("learner");

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (password !== confirmPassword) return;
    register.mutate(
      { fullName, email, password, confirmPassword, role: role as "learner" | "instructor" },
      { onSuccess: () => router.push("/dashboard") }
    );
  }

  return (
    <div className="mx-auto flex max-w-md flex-col px-4 py-16 md:px-0">
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Create your account</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Join the Saachi AI marketplace.</p>

      <form onSubmit={handleSubmit} className="flex flex-col gap-4">
        <Input
          label="Full name"
          required
          value={fullName}
          onChange={(e) => setFullName(e.target.value)}
          placeholder="Your full name"
        />
        <Input
          label="Email"
          type="email"
          required
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="you@example.com"
        />
        <Select label="I am joining as" options={ROLE_OPTIONS} value={role} onChange={(e) => setRole(e.target.value)} />
        <Input
          label="Password"
          type="password"
          required
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="At least 8 characters"
        />
        <Input
          label="Confirm password"
          type="password"
          required
          value={confirmPassword}
          onChange={(e) => setConfirmPassword(e.target.value)}
          error={confirmPassword && password !== confirmPassword ? "Passwords do not match" : undefined}
        />
        <Button type="submit" size="lg" loading={register.isPending}>
          Create account
        </Button>
      </form>

      <div className="mt-6">
        <SocialLoginButtons />
      </div>

      <p className="mt-8 text-center text-[14px] text-ink-soft">
        Already have an account?{" "}
        <Link href="/login" className="font-semibold text-gold-dark hover:underline">
          Log in
        </Link>
      </p>
    </div>
  );
}