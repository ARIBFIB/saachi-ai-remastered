"use client";

import { useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { Button, Input, SocialLoginButtons } from "@saachi/ui";
import { useLogin } from "@saachi/api-client";

export default function LoginPage() {
  const router = useRouter();
  const login = useLogin();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    login.mutate(
      { email, password },
      { onSuccess: () => router.push("/dashboard") }
    );
  }

  return (
    <div className="mx-auto flex max-w-md flex-col px-4 py-16 md:px-0">
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Log in</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Welcome back to Saachi AI.</p>

      <form onSubmit={handleSubmit} className="flex flex-col gap-4">
        <Input
          label="Email"
          type="email"
          required
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="you@example.com"
        />
        <Input
          label="Password"
          type="password"
          required
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="At least 8 characters"
        />
        <Button type="submit" size="lg" loading={login.isPending}>
          Log in
        </Button>
      </form>

      <div className="mt-6">
        <SocialLoginButtons />
      </div>

      <p className="mt-8 text-center text-[14px] text-ink-soft">
        Don&apos;t have an account?{" "}
        <Link href="/register" className="font-semibold text-gold-dark hover:underline">
          Sign up
        </Link>
      </p>
    </div>
  );
}