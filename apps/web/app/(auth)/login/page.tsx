"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { GraduationCap, UserSquare2, Check, AlertCircle } from "lucide-react";
import { useLogin, useRegister } from "@saachi/api-client";

type Mode = "signin" | "register";
type Role = "learner" | "instructor";

export default function LoginPage() {
  const router = useRouter();
  const [mode, setMode] = useState<Mode>("signin");
  const [role, setRole] = useState<Role>("learner");

  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const login = useLogin();
  const register = useRegister();

  const isSubmitting = login.isPending || register.isPending;
  const errorMessage = login.isError
    ? "Could not sign in. Please try again."
    : register.isError
      ? "Could not create your account. Please try again."
      : null;

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();

    if (mode === "signin") {
      await login.mutateAsync({ email, password });
    } else {
      await register.mutateAsync({
        fullName: fullName || email.split("@")[0] || "New User",
        email,
        password,
        confirmPassword: password,
        role
      });
    }

    router.push("/dashboard");
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-slate-50 p-6">
      <div className="flex w-full max-w-[1200px] overflow-hidden rounded-xl bg-slate-50 shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
        {/* Left: Core auth */}
        <div className="flex-1 bg-white p-10">
          <div className="mb-8 flex flex-col gap-2">
            <Link href="/" className="text-3xl font-bold leading-10 text-[#3525CD]">
              Saachi AI
            </Link>
            <p className="text-base text-slate-600">
              {mode === "signin"
                ? "Sign in to continue your learning journey."
                : "Create an account to start learning or teaching."}
            </p>
          </div>

          {/* Toggle */}
          <div className="mb-6 flex rounded-lg bg-gray-100 p-1">
            <button
              type="button"
              onClick={() => setMode("signin")}
              className={`flex-1 rounded-sm py-2 text-sm font-semibold tracking-wide transition ${
                mode === "signin"
                  ? "bg-[#3525CD] text-white shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)]"
                  : "text-slate-600"
              }`}
            >
              Sign In
            </button>
            <button
              type="button"
              onClick={() => setMode("register")}
              className={`flex-1 rounded-sm py-2 text-sm font-semibold tracking-wide transition ${
                mode === "register"
                  ? "bg-[#3525CD] text-white shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)]"
                  : "text-slate-600"
              }`}
            >
              Create Account
            </button>
          </div>

          {/* Form */}
          <form onSubmit={handleSubmit} className="flex flex-col gap-4">
            {mode === "register" && (
              <div className="flex flex-col gap-1">
                <label htmlFor="fullName" className="text-sm font-semibold tracking-wide text-gray-700">
                  Full Name
                </label>
                <input
                  id="fullName"
                  type="text"
                  required
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  placeholder="Jane Doe"
                  className="rounded-lg border border-slate-300 bg-slate-50 px-4 py-2.5 text-base text-zinc-900 placeholder:text-gray-500 focus:border-[#3525CD] focus:outline-none"
                />
              </div>
            )}

            <div className="flex flex-col gap-1">
              <label htmlFor="email" className="text-sm font-semibold tracking-wide text-gray-700">
                Email Address
              </label>
              <input
                id="email"
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="name@company.com"
                className="rounded-lg border border-slate-300 bg-slate-50 px-4 py-2.5 text-base text-zinc-900 placeholder:text-gray-500 focus:border-[#3525CD] focus:outline-none"
              />
            </div>

            <div className="flex flex-col gap-1">
              <div className="flex items-center justify-between">
                <label htmlFor="password" className="text-sm font-semibold tracking-wide text-gray-700">
                  Password
                </label>
                {mode === "signin" && (
                  <Link href="/forgot-password" className="text-xs font-medium text-[#3525CD]">
                    Forgot?
                  </Link>
                )}
              </div>
              <input
                id="password"
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Enter your password"
                className="rounded-lg border border-slate-300 bg-slate-50 px-4 py-2.5 text-base text-zinc-900 placeholder:text-gray-500 focus:border-[#3525CD] focus:outline-none"
              />
            </div>

            {errorMessage && (
              <div className="flex items-center gap-2 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-600">
                <AlertCircle className="h-4 w-4 shrink-0" />
                {errorMessage}
              </div>
            )}

            <button
              type="submit"
              disabled={isSubmitting}
              className="rounded-lg bg-[#3525CD] py-4 text-sm font-semibold tracking-wide text-white shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)] hover:bg-[#2A1DA3] disabled:cursor-not-allowed disabled:opacity-60"
            >
              {isSubmitting
                ? "Please wait..."
                : mode === "signin"
                  ? "Sign In"
                  : "Create Account"}
            </button>
          </form>

          <div className="relative my-6 flex items-center justify-center">
            <span className="absolute inset-x-0 top-1/2 h-px -translate-y-1/2 border-t border-slate-300" />
            <span className="relative bg-white px-2 text-xs font-medium text-slate-600">
              Or continue with
            </span>
          </div>

          <div className="flex gap-4">
            <button
              type="button"
              className="flex-1 rounded-lg border border-slate-300 py-2 text-sm font-semibold text-zinc-900 hover:bg-gray-50"
            >
              Google
            </button>
            <button
              type="button"
              className="flex-1 rounded-lg border border-slate-300 py-2 text-sm font-semibold text-zinc-900 hover:bg-gray-50"
            >
              LinkedIn
            </button>
          </div>
        </div>

        {/* Right: role selection (register only visual context, always shown per design) */}
        <div className="relative hidden flex-1 flex-col justify-center overflow-hidden bg-gray-100 px-10 py-28 md:flex">
          <div className="pointer-events-none absolute left-0 top-0 h-full w-full bg-[radial-gradient(circle_at_100%_0%,rgba(53,37,205,0.2),transparent_50%)]" />

          <div className="relative flex flex-col gap-4">
            <h2 className="text-2xl font-semibold text-zinc-900">Join the ecosystem</h2>
            <p className="text-base text-slate-600">
              Select your path to get started with specialized tools and
              tailored experiences.
            </p>

            <div className="flex flex-col gap-4 pt-6">
              <RoleCard
                icon={<GraduationCap className="h-6 w-6 text-[#3525CD]" />}
                title="I am a Learner"
                description="Access courses, track progress, and build your skill portfolio."
                selected={role === "learner"}
                onSelect={() => setRole("learner")}
              />
              <RoleCard
                icon={<UserSquare2 className="h-6 w-6 text-[#565E74]" />}
                title="I am an Instructor"
                description="Create courses, manage analytics, and grow your audience."
                selected={role === "instructor"}
                onSelect={() => setRole("instructor")}
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function RoleCard({
  icon,
  title,
  description,
  selected,
  onSelect,
}: {
  icon: React.ReactNode;
  title: string;
  description: string;
  selected: boolean;
  onSelect: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onSelect}
      className={`flex items-start gap-4 rounded-xl border-2 bg-white p-4 text-left transition ${
        selected ? "border-[#3525CD]" : "border-transparent"
      }`}
    >
      <span
        className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-lg ${
          selected ? "bg-[#3525CD]/10" : "bg-gray-200"
        }`}
      >
        {icon}
      </span>

      <span className="flex-1">
        <span className="block text-sm font-semibold tracking-wide text-zinc-900">
          {title}
        </span>
        <span className="block text-sm text-slate-600">{description}</span>
      </span>

      <span
        className={`mt-1 flex h-5 w-5 shrink-0 items-center justify-center rounded-full border-2 ${
          selected ? "border-[#3525CD]" : "border-[#C7C4D8]"
        }`}
      >
        {selected && <span className="h-2.5 w-2.5 rounded-full bg-[#3525CD]" />}
      </span>
    </button>
  );
}