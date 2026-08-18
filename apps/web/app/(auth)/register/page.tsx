"use client";

import { useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { Button, Select, SocialLoginButtons } from "@saachi/ui";
import { useRegister } from "@saachi/api-client";
import { AuthField } from "@/components/ui/auth-field";
import { AuthVisualPanel } from "@/components/ui/auth-visual-panel";

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
  const [agreedToTerms, setAgreedToTerms] = useState(false);

  const passwordsMismatch = confirmPassword.length > 0 && password !== confirmPassword;

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (password !== confirmPassword || !agreedToTerms) return;
    register.mutate(
      { fullName, email, password, confirmPassword, role: role as "learner" | "instructor" },
      {
        onSuccess: () => {
          if (role === "learner") {
            window.localStorage.setItem("saachi-just-signed-up", "true");
          }
          router.push(role === "instructor" ? "/instructor/dashboard" : "/dashboard");
        }
      }
    );
  }

  return (
    <section className="min-h-screen bg-paper p-3">
      <div className="grid min-h-[calc(100vh-1.5rem)] gap-6 lg:grid-cols-[0.94fr_1.06fr]">
        <div className="flex min-h-[760px] items-start rounded-md border border-line bg-card px-6 py-12 sm:px-10 lg:min-h-0 lg:px-14 lg:py-20 xl:px-20">
          <div className="mx-auto w-full max-w-[560px]">
            <h1 className="font-display text-3xl font-medium tracking-[-0.03em] text-ink sm:text-4xl lg:text-[42px]">
              Create an account
            </h1>
            <p className="mt-3 text-[15px] leading-snug text-ink-soft sm:text-[17px]">
              Join the Saachi AI marketplace and start building.
            </p>

            <div className="mt-10 grid gap-4 sm:grid-cols-2">
              <SocialLoginButtons />
            </div>

            <div className="my-8 flex items-center gap-3">
              <div className="h-px flex-1 bg-line" />
              <span className="text-[13px] font-medium text-ink-soft">or</span>
              <div className="h-px flex-1 bg-line" />
            </div>

            <form onSubmit={handleSubmit} className="space-y-4">
              <AuthField
                label="Full name"
                required
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
              />
              <AuthField
                label="Email"
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />

              <Select label="I am joining as" options={ROLE_OPTIONS} value={role} onChange={(e) => setRole(e.target.value)} />

              <AuthField
                label="Password"
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
              <AuthField
                label="Confirm password"
                type="password"
                required
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
              />
              {passwordsMismatch && <p className="text-[13px] text-error">Passwords do not match</p>}

              <label className="flex items-start gap-3 pt-2 text-[13px] leading-5 text-ink-soft">
                <input
                  type="checkbox"
                  checked={agreedToTerms}
                  onChange={(e) => setAgreedToTerms(e.target.checked)}
                  required
                  className="mt-0.5 h-4 w-4 shrink-0 accent-accent-violet"
                />
                <span>
                  By creating an account, you agree to our{" "}
                  <Link href="/legal/terms" className="font-medium text-ink underline underline-offset-2">
                    Terms &amp; Conditions
                  </Link>{" "}
                  and{" "}
                  <Link href="/legal/privacy" className="font-medium text-ink underline underline-offset-2">
                    Privacy Policy
                  </Link>
                </span>
              </label>

              <Button type="submit" size="lg" loading={register.isPending} className="mt-4 w-full">
                Create account
              </Button>
            </form>

            <p className="mt-8 text-center text-[14px] text-ink-soft">
              Already have an account?{" "}
              <Link href="/login" className="font-semibold text-accent-violet hover:underline">
                Log in
              </Link>
            </p>
          </div>
        </div>

        <AuthVisualPanel
          headline={
            <>
              Think fast,
              <br />
              build faster.
            </>
          }
          tagline="1,280+ practical AI courses across automation, marketing, design, and development."
          ctaLabel="Browse the course marketplace"
          ctaHref="/courses"
        />
      </div>
    </section>
  );
}