<#
================================================================================
Apply-Saachi-Step2-Auth.ps1
STEP 2 of the design-system rollout: auth pages
  - app/(auth)/login/page.tsx
  - app/(auth)/register/page.tsx
  - app/(auth)/forgot-password/page.tsx
  - app/(auth)/verify-email/page.tsx

USAGE:
  1. Save this file into your repo root (same folder as Step 1), e.g.:
     D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2\Apply-Saachi-Step2-Auth.ps1
  2. In PowerShell (prompt: PS D:\...\SAI2>) run:
       .\Apply-Saachi-Step2-Auth.ps1
  3. Existing files that would be overwritten are backed up first into
     .\_backup_stepwise\<timestamp>\
================================================================================
#>

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
if (-not $root) { $root = Get-Location }

$backupDir = Join-Path $root ("_backup_stepwise\{0}" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
$writtenCount = 0

function Write-SaachiFile {
    param(
        [string]$RelativePath,
        [string]$Content
    )

    $fullPath = Join-Path $root $RelativePath
    $dir = Split-Path $fullPath -Parent

    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    if (Test-Path $fullPath) {
        $backupTarget = Join-Path $backupDir $RelativePath
        $backupTargetDir = Split-Path $backupTarget -Parent
        if (-not (Test-Path $backupTargetDir)) {
            New-Item -ItemType Directory -Path $backupTargetDir -Force | Out-Null
        }
        Copy-Item -Path $fullPath -Destination $backupTarget -Force
        Write-Host "  backed up existing: $RelativePath"
    }

    $Content = $Content.TrimStart("`r", "`n")
    Set-Content -Path $fullPath -Value $Content -Encoding UTF8 -NoNewline
    $script:writtenCount++
    Write-Host "  wrote: $RelativePath"
}

Write-Host "=== STEP 2: Auth pages ==="
Write-Host "Target repo root: $root"
Write-Host ""

# ------------------------------------------------------------------
# apps/web/app/(auth)/forgot-password/page.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\app\(auth)\forgot-password\page.tsx" @'
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
        <Link href="/" className="text-center text-3xl font-bold text-[var(--token-color-primary)]">
          Saachi AI
        </Link>

        <div className="overflow-hidden rounded-xl bg-[var(--token-color-surface)] px-10 py-10 shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
          {submitted ? (
            <div className="flex flex-col items-center gap-2 text-center">
              <CheckCircle2 className="h-10 w-10 text-[var(--token-color-success)]" />
              <h2 className="text-2xl font-semibold text-[var(--token-color-ink)]">Check your email</h2>
              <p className="text-base text-[var(--token-color-inkSoft)]">
                We&apos;ve sent a password reset link to <span className="font-semibold">{email}</span>.
              </p>

              <Link
                href="/login"
                className="mt-5 flex items-center gap-1 text-base text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]"
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
                      className="w-full rounded-lg border border-[var(--token-color-border)] bg-[var(--token-color-surface)] py-3.5 pl-10 pr-4 text-base text-[var(--token-color-ink)] placeholder:text-gray-500 focus:border-[var(--token-color-primary)] focus:outline-none"
                    />
                  </div>
                </div>

                <button
                  type="submit"
                  className="flex items-center justify-center gap-2 rounded-lg bg-[var(--token-color-primary)] px-4 py-3 text-sm font-semibold tracking-wide text-white hover:bg-[var(--token-color-primaryHover)]"
                >
                  Send Reset Link
                  <ArrowRight className="h-3 w-3" />
                </button>
              </form>

              <div className="flex flex-col items-center pb-1 pt-5">
                <Link
                  href="/login"
                  className="flex items-center gap-1 text-base text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]"
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
          <Link href="/contact" className="text-[var(--token-color-primary)]">
            Contact Support
          </Link>
        </p>
      </div>
    </div>
  );
}
'@

# ------------------------------------------------------------------
# apps/web/app/(auth)/login/page.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\app\(auth)\login\page.tsx" @'
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
'@

# ------------------------------------------------------------------
# apps/web/app/(auth)/register/page.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\app\(auth)\register\page.tsx" @'
"use client";

import { useState } from "react";
import Link from "next/link";
import { Form, Input, Checkbox, Button, Typography, Avatar, Divider } from "antd";
import { GraduationCap, Video } from "lucide-react";
import { useRegister } from "@saachi/api-client";
import { useRouter } from "next/navigation";

const { Title, Text } = Typography;

type Role = "learner" | "instructor";

interface RegisterFormValues {
  fullName: string;
  email: string;
  password: string;
  agree: boolean;
}

export default function CreateAccountPage() {
  const router = useRouter();
  const registerMutation = useRegister();
  const [role, setRole] = useState<Role>("learner");
  const [form] = Form.useForm<RegisterFormValues>();

  async function handleFinish(values: RegisterFormValues) {
    try {
      await registerMutation.mutateAsync({
        fullName: values.fullName,
        email: values.email,
        password: values.password,
        confirmPassword: values.password,
        role
      });
      router.push("/dashboard");
    } catch {
      // registerMutation.isError below drives the inline antd message
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-[var(--token-color-bg)] px-4 py-24">
      <div className="flex w-full max-w-[1000px] overflow-hidden rounded-2xl bg-[var(--token-color-surface)] shadow-[var(--token-shadow-md)]">
        {/* Left panel: brand + graphic */}
        <div
          className="relative hidden w-96 shrink-0 flex-col justify-between overflow-hidden p-10 md:flex"
          style={{
            background:
              "linear-gradient(160deg, var(--token-color-primary) 0%, var(--token-color-primaryDark) 100%)",
          }}
        >
          <div className="pointer-events-none absolute -top-32 left-1/2 h-64 w-64 -translate-x-1/2 rounded-full bg-[var(--token-color-surface)]/10 blur-[32px]" />
          <div className="pointer-events-none absolute -left-20 bottom-24 h-80 w-80 rounded-full bg-[var(--token-color-decorativeCyan)]/20 blur-[32px]" />

          <span className="relative text-2xl font-black text-[var(--token-color-surface)]">
            Saachi AI
          </span>

          <div className="relative flex flex-col gap-3.5 pb-6">
            <h1 className="text-3xl font-bold leading-10 text-[var(--token-color-surface)]">
              Empowering the
              <br />
              future of skills.
            </h1>
            <p className="text-lg leading-7 text-[var(--token-color-primaryTint)]">
              Join our network of learners and industry experts to accelerate
              your AI journey.
            </p>
          </div>

          <div className="relative flex items-center">
            <Avatar.Group>
              <Avatar src="https://i.pravatar.cc/64?img=12" />
              <Avatar src="https://i.pravatar.cc/64?img=32" />
              <Avatar src="https://i.pravatar.cc/64?img=45" />
              <Avatar
                style={{
                  backgroundColor: "var(--token-color-primaryHover)",
                  color: "var(--token-color-primaryTint)",
                }}
              >
                +5k
              </Avatar>
            </Avatar.Group>
          </div>
        </div>

        {/* Right panel: form */}
        <div className="flex w-full flex-col gap-6 px-8 py-12 sm:px-16">
          <div className="flex flex-col gap-2">
            <Title level={2} style={{ margin: 0, color: "var(--token-color-ink)" }}>
              Create an account
            </Title>
            <Text style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
              Join Saachi AI to start your journey.
            </Text>
          </div>

          {/* Role selector */}
          <div className="flex flex-col gap-2">
            <Text strong style={{ color: "var(--token-color-ink)", fontSize: "var(--token-font-size-sm)" }}>
              I am joining as a:
            </Text>
            <div className="flex gap-2">
              <RoleCard
                icon={<GraduationCap size={22} color="var(--token-color-primary)" />}
                label="Learner"
                selected={role === "learner"}
                onSelect={() => setRole("learner")}
              />
              <RoleCard
                icon={<Video size={20} color="var(--token-color-primary)" />}
                label="Instructor"
                selected={role === "instructor"}
                onSelect={() => setRole("instructor")}
              />
            </div>
          </div>

          <Form
            form={form}
            layout="vertical"
            requiredMark={false}
            onFinish={handleFinish}
            className="flex flex-col"
          >
            <Form.Item
              label="Full Name"
              name="fullName"
              rules={[{ required: true, message: "Please enter your full name" }]}
            >
              <Input size="large" placeholder="John Doe" />
            </Form.Item>

            <Form.Item
              label="Email Address"
              name="email"
              rules={[{ required: true, type: "email", message: "Please enter a valid email" }]}
            >
              <Input size="large" placeholder="john@example.com" />
            </Form.Item>

            <Form.Item
              label="Password"
              name="password"
              rules={[{ required: true, min: 8, message: "Must be at least 8 characters long." }]}
              extra={
                <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-xs)" }}>
                  Must be at least 8 characters long.
                </span>
              }
            >
              <Input.Password size="large" placeholder="Enter your password" />
            </Form.Item>

            <Form.Item
              name="agree"
              valuePropName="checked"
              rules={[
                {
                  validator: (_, value) =>
                    value ? Promise.resolve() : Promise.reject(new Error("You must agree before continuing")),
                },
              ]}
            >
              <Checkbox>
                <span style={{ color: "var(--token-color-inkSoft)" }}>
                  I agree to the{" "}
                  <Link href="/legal/terms" style={{ color: "var(--token-color-primary)" }}>
                    Terms of Service
                  </Link>{" "}
                  and{" "}
                  <Link href="/legal/privacy" style={{ color: "var(--token-color-primary)" }}>
                    Privacy Policy
                  </Link>
                  .
                </span>
              </Checkbox>
            </Form.Item>

            <Button type="primary" htmlType="submit" size="large" block>
              Create Account
            </Button>
          </Form>

          <Divider
            style={{ borderColor: "var(--token-color-border)" }}
            plain
          >
            <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-xs)" }}>
              Or continue with
            </span>
          </Divider>

          <div className="flex gap-4">
            <Button size="large" block icon={<GoogleIcon />}>
              Google
            </Button>
            <Button size="large" block icon={<GithubIcon />}>
              GitHub
            </Button>
          </div>

          <p className="text-center text-base" style={{ color: "var(--token-color-inkSoft)" }}>
            Already have an account?{" "}
            <Link href="/login" style={{ color: "var(--token-color-primary)" }}>
              Sign in
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}

function RoleCard({
  icon,
  label,
  selected,
  onSelect,
}: {
  icon: React.ReactNode;
  label: string;
  selected: boolean;
  onSelect: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onSelect}
      className="flex flex-1 flex-col items-center gap-2 rounded-lg border px-4 pb-4 pt-3.5 text-sm font-semibold tracking-wide transition"
      style={{
        backgroundColor: selected ? "var(--token-color-primaryTint)" : "var(--token-color-bg)",
        borderColor: selected ? "var(--token-color-primary)" : "var(--token-color-border)",
        color: "var(--token-color-ink)",
      }}
    >
      {icon}
      {label}
    </button>
  );
}

// Google and GitHub brand marks use their official fixed multi-color logos --
// these are not theme colors and are intentionally not tokenized, since
// substituting them would break brand recognition.
function GoogleIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M18.8 10.2083C18.8 9.55825 18.7417 8.93325 18.6333 8.33325H10V11.8833H14.9333C14.7167 13.0249 14.0667 13.9916 13.0917 14.6416V16.9499H16.0667C17.8 15.3499 18.8 12.9999 18.8 10.2083Z" fill="#4285F4" />
      <path d="M9.99974 19.1667C12.4747 19.1667 14.5497 18.35 16.0664 16.95L13.0914 14.6417C12.2747 15.1917 11.2331 15.525 9.99974 15.525C7.61641 15.525 5.59141 13.9167 4.86641 11.75H1.81641V14.1167C3.32474 17.1083 6.41641 19.1667 9.99974 19.1667Z" fill="#34A853" />
      <path d="M4.86634 11.7416C4.68301 11.1916 4.57467 10.6083 4.57467 9.99993C4.57467 9.3916 4.68301 8.80827 4.86634 8.25827V5.8916H1.81634C1.19134 7.12493 0.833008 8.5166 0.833008 9.99993C0.833008 11.4833 1.19134 12.8749 1.81634 14.1083L4.19134 12.2583L4.86634 11.7416Z" fill="#FBBC05" />
      <path d="M9.99974 4.48325C11.3497 4.48325 12.5497 4.94992 13.5081 5.84992L16.1331 3.22492C14.5414 1.74159 12.4747 0.833252 9.99974 0.833252C6.41641 0.833252 3.32474 2.89159 1.81641 5.89159L4.86641 8.25825C5.59141 6.09159 7.61641 4.48325 9.99974 4.48325Z" fill="#EA4335" />
    </svg>
  );
}

function GithubIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path
        fillRule="evenodd"
        clipRule="evenodd"
        d="M10.0003 1.66675C5.39783 1.66675 1.66699 5.40341 1.66699 10.0142C1.66699 13.7017 4.05449 16.8309 7.36616 17.9342C7.78282 18.0109 7.93449 17.7534 7.93449 17.5317C7.93449 17.3342 7.92783 16.8084 7.92366 16.1126C5.60533 16.6167 5.11616 14.9934 5.11616 14.9934C4.73783 14.0284 4.19116 13.7717 4.19116 13.7717C3.43449 13.2551 4.24866 13.2651 4.24866 13.2651C5.08449 13.3234 5.52449 14.1251 5.52449 14.1251C6.26783 15.4001 7.47533 15.0317 7.94949 14.8184C8.02616 14.2792 8.24116 13.9117 8.47949 13.7034C6.62949 13.4926 4.68366 12.7759 4.68366 9.57758C4.68366 8.66675 5.00866 7.92091 5.54116 7.33758C5.45533 7.12675 5.16949 6.27758 5.62283 5.12925C5.62283 5.12925 6.32283 4.90425 7.91449 5.98425C8.5943 5.79884 9.29569 5.70441 10.0003 5.70341C10.7087 5.70675 11.4212 5.79925 12.087 5.98425C13.6778 4.90425 14.3762 5.12841 14.3762 5.12841C14.8312 6.27758 14.5445 7.12675 14.4595 7.33758C14.9928 7.92091 15.3162 8.66675 15.3162 9.57758C15.3162 12.7842 13.367 13.4901 11.5112 13.6967C11.8103 13.9542 12.0762 14.4634 12.0762 15.2426C12.0762 16.3576 12.0662 17.2584 12.0662 17.5317C12.0662 17.7551 12.2162 18.0151 12.6395 17.9334C16.0424 16.792 18.3351 13.6035 18.3337 10.0142C18.3337 5.40341 14.602 1.66675 10.0003 1.66675Z"
        fill="#191C1E"
      />
    </svg>
  );
}
'@

# ------------------------------------------------------------------
# apps/web/app/(auth)/verify-email/page.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\app\(auth)\verify-email\page.tsx" @'
import Link from "next/link";
import { Check, ArrowRight } from "lucide-react";

export default function EmailVerifiedPage() {
  return (
    <div className="relative flex min-h-screen items-center justify-center overflow-hidden bg-[var(--token-color-surface)] p-12">
      <div
        className="pointer-events-none absolute -left-32 -top-60 h-[640px] w-[640px] rounded-full opacity-20 blur-[50px]"
        style={{ backgroundColor: "var(--token-color-primaryTint)" }}
      />
      <div
        className="pointer-events-none absolute -right-32 bottom-0 h-[768px] w-[768px] rounded-full opacity-10 blur-3xl"
        style={{ backgroundColor: "var(--token-color-successTint)" }}
      />

      <div className="relative flex w-96 max-w-96 flex-col items-center gap-6 rounded-2xl border border-[var(--token-color-border)] bg-[var(--token-color-surface)] p-10 shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
        <span className="relative flex h-20 w-20 items-center justify-center rounded-full bg-[var(--token-color-success)]/10">
          <Check className="h-9 w-9 text-[var(--token-color-success)]" strokeWidth={3} />
          <span className="absolute inset-0 rounded-full border-4 border-[var(--token-color-success)] opacity-20" />
        </span>

        <div className="flex flex-col items-center gap-2 text-center">
          <h1 className="text-3xl font-bold text-[var(--token-color-ink)]">Email Verified</h1>
          <p className="max-w-72 text-base leading-6 text-gray-700">
            Your email address has been successfully confirmed. You now have full access to Saachi AI.
          </p>
        </div>

        <Link
          href="/dashboard"
          className="flex w-full items-center justify-center gap-2 rounded-lg bg-[var(--token-color-primary)] px-6 py-4 text-sm font-semibold tracking-wide text-white shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)] hover:bg-[var(--token-color-primaryHover)]"
        >
          Continue to Dashboard
          <ArrowRight className="h-3 w-3" />
        </Link>
      </div>
    </div>
  );
}
'@

Write-Host ""
Write-Host "=== STEP 2 complete: $writtenCount file(s) written. ==="
if (Test-Path $backupDir) {
    Write-Host "Backups of any overwritten files: $backupDir"
}