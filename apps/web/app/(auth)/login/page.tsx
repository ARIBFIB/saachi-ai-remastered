"use client";

import { useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { Button, SocialLoginButtons } from "@saachi/ui";
import { useLogin } from "@saachi/api-client";
import { AuthField } from "@/components/ui/auth-field";
import { AuthVisualPanel } from "@/components/ui/auth-visual-panel";

export default function LoginPage() {
  const router = useRouter();
  const login = useLogin();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    login.mutate(
      { email, password },
      {
        onSuccess: (session) =>
          router.push(session.role === "instructor" ? "/instructor/dashboard" : "/dashboard")
      }
    );
  }

  return (
    <section className="min-h-screen bg-paper p-3">
      <div className="grid min-h-[calc(100vh-1.5rem)] gap-6 lg:grid-cols-[0.94fr_1.06fr]">
        <div className="flex min-h-[760px] items-center rounded-md border border-line bg-card px-6 py-12 sm:px-10 lg:min-h-0 lg:px-14 xl:px-20">
          <div className="mx-auto w-full max-w-[480px]">
            <h1 className="font-display text-3xl font-medium tracking-[-0.03em] text-ink sm:text-4xl">
              Welcome back
            </h1>
            <p className="mt-3 text-[15px] leading-snug text-ink-soft sm:text-[17px]">
              Log in to keep learning where you left off.
            </p>

            <div className="mt-10">
              <SocialLoginButtons />
            </div>

            <div className="my-8 flex items-center gap-3">
              <div className="h-px flex-1 bg-line" />
              <span className="text-[13px] font-medium text-ink-soft">or</span>
              <div className="h-px flex-1 bg-line" />
            </div>

            <form onSubmit={handleSubmit} className="space-y-4">
              <AuthField
                label="Email"
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
              <AuthField
                label="Password"
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />

              <div className="flex justify-end pt-1">
                <Link href="/forgot-password" className="text-[13px] font-medium text-accent-violet hover:underline">
                  Forgot password?
                </Link>
              </div>

              <Button type="submit" size="lg" loading={login.isPending} className="mt-4 w-full">
                Log in
              </Button>
            </form>

            <p className="mt-8 text-center text-[14px] text-ink-soft">
              Don&apos;t have an account?{" "}
              <Link href="/register" className="font-semibold text-accent-violet hover:underline">
                Sign up
              </Link>
            </p>
          </div>
        </div>

        <AuthVisualPanel
          headline={
            <>
              Learn AI skills,
              <br />
              build real projects.
            </>
          }
          tagline="Join 42,000+ learners already building with AI on Saachi AI."
          ctaLabel="Explore the course marketplace"
          ctaHref="/courses"
        />
      </div>
    </section>
  );
}