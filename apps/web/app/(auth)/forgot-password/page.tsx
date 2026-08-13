"use client";

import { useState } from "react";
import Link from "next/link";
import { Mail, ArrowRight, ArrowLeft, CheckCircle2 } from "lucide-react";

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState("");
  const [submitted, setSubmitted] = useState(false);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    // TODO: wire to useAuth().requestPasswordReset() from @saachi/api-client
    console.log("request password reset", { email });
    setSubmitted(true);
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-[var(--token-color-bg)] px-12 py-32">
      <div className="flex w-96 max-w-96 flex-col gap-6">
        <Link href="/" className="text-center text-3xl font-bold text-[var(--token-color-amber)]">
          Saachi AI
        </Link>

        <div className="overflow-hidden rounded-[var(--token-radius-lg)] bg-[var(--token-color-surface)] px-10 py-10 shadow-[var(--token-shadow-sm)]">
          {submitted ? (
            <div className="flex flex-col items-center gap-2 text-center">
              <CheckCircle2 className="h-10 w-10 text-[var(--token-color-success)]" />
              <h2 className="text-2xl font-semibold text-[var(--token-color-ink)]">Check your email</h2>
              <p className="text-base text-[var(--token-color-inkSoft)]">
                We&apos;ve sent a password reset link to <span className="font-semibold">{email}</span>.
              </p>

              <Link
                href="/login"
                className="mt-5 flex items-center gap-1 text-base text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-amber)]"
              >
                <ArrowLeft className="h-3 w-3" />
                Back to Login
              </Link>
            </div>
          ) : (
            <div className="flex flex-col gap-1">
              <h2 className="text-2xl font-semibold text-[var(--token-color-ink)]">Reset your password</h2>
              <p className="text-base text-[var(--token-color-inkSoft)]">
                Enter your email address and we&apos;ll send you a link to securely reset your password.
              </p>

              <form onSubmit={handleSubmit} className="flex flex-col gap-6 pt-9">
                <div className="flex flex-col gap-2">
                  <label htmlFor="email" className="text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">
                    Email address
                  </label>
                  <div className="relative">
                    <Mail className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-[var(--token-color-textMuted)]" />
                    <input
                      id="email"
                      type="email"
                      required
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder="name@company.com"
                      className="w-full rounded-[var(--token-radius-md)] border border-[var(--token-color-border)] bg-[var(--token-color-surface)] py-3.5 pl-10 pr-4 text-base text-[var(--token-color-ink)] placeholder:text-gray-500 focus:border-[var(--token-color-amber)] focus:outline-none"
                    />
                  </div>
                </div>

                <button
                  type="submit"
                  className="flex items-center justify-center gap-2 rounded-[var(--token-radius-md)] bg-[var(--token-color-amber)] px-4 py-3 text-sm font-semibold tracking-wide text-white hover:bg-[var(--token-color-amberDark)]"
                >
                  Send Reset Link
                  <ArrowRight className="h-3 w-3" />
                </button>
              </form>

              <div className="flex flex-col items-center pb-1 pt-5">
                <Link
                  href="/login"
                  className="flex items-center gap-1 text-base text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-amber)]"
                >
                  <ArrowLeft className="h-3 w-3" />
                  Back to Login
                </Link>
              </div>
            </div>
          )}
        </div>

        <p className="text-center text-xs font-medium text-[var(--token-color-inkSoft)]">
          Need help?{" "}
          <Link href="/contact" className="text-[var(--token-color-amber)]">
            Contact Support
          </Link>
        </p>
      </div>
    </div>
  );
}