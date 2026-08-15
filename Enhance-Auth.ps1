<#
============================================================================
 Enhance-Auth.ps1
 Saachi AI (SAI2) - Split-screen Login / Signup with GrainGradient panel
----------------------------------------------------------------------------
 Run from the repo root:
     PS D:\...\SAI2> .\Enhance-Auth.ps1

 What it does:
   1. Adds "@paper-design/shaders-react" to apps\web\package.json deps
   2. Adds apps\web\components\ui\auth-field.tsx     (floating-label input)
   3. Adds apps\web\components\ui\auth-visual-panel.tsx (GrainGradient panel)
   4. Backs up + rewrites:
      apps\web\app\(auth)\login\page.tsx
      apps\web\app\(auth)\register\page.tsx
      to use the new split-screen shell, still wired to the real
      useLogin / useRegister hooks.

 Safe to re-run: every touched page is backed up first.
============================================================================
#>

$ErrorActionPreference = "Stop"

$Root     = $PSScriptRoot
if (-not $Root) { $Root = Get-Location }

$WebApp   = Join-Path $Root "apps\web"
$AppDir   = Join-Path $WebApp "app"
$AuthDir  = Join-Path $AppDir "(auth)"
$LoginDir = Join-Path $AuthDir "login"
$RegDir   = Join-Path $AuthDir "register"
$UiDir    = Join-Path $WebApp "components\ui"
$PkgPath  = Join-Path $WebApp "package.json"

foreach ($dir in @($UiDir)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Write-Host "Created dir: $dir" -ForegroundColor DarkGray
    }
}

function Write-File {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )
    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $encoding = New-Object System.Text.UTF8Encoding($false)
    $stream = New-Object System.IO.FileStream($fullPath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
    try {
        $writer = New-Object System.IO.StreamWriter($stream, $encoding)
        try {
            $writer.Write($Content)
        }
        finally {
            $writer.Flush()
            $writer.Dispose()
        }
    }
    finally {
        $stream.Dispose()
    }
    Write-Host "Wrote: $fullPath" -ForegroundColor Green
}

function Backup-File {
    param([string]$Path)
    if (Test-Path $Path) {
        $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $backup = "$Path.bak-$stamp"
        Copy-Item $Path $backup
        Write-Host "Backed up $(Split-Path $Path -Leaf) -> $backup" -ForegroundColor Yellow
    }
}

# ---------------------------------------------------------------------------
# 0. Add @paper-design/shaders-react to package.json dependencies
# ---------------------------------------------------------------------------
if (Test-Path $PkgPath) {
    $pkgRaw = Get-Content -Path $PkgPath -Raw
    $pkgRaw = $pkgRaw.TrimStart([char]0xFEFF)
    $pkgJson = $pkgRaw | ConvertFrom-Json

    if (-not $pkgJson.dependencies) {
        $pkgJson | Add-Member -NotePropertyName "dependencies" -NotePropertyValue (New-Object PSObject)
    }

    $depsProps = $pkgJson.dependencies.PSObject.Properties.Name
    if ($depsProps -contains "@paper-design/shaders-react") {
        Write-Host "@paper-design/shaders-react already in package.json - skipping." -ForegroundColor DarkGray
    } else {
        $pkgJson.dependencies | Add-Member -NotePropertyName "@paper-design/shaders-react" -NotePropertyValue "^0.0.35"
        $newPkgContent = $pkgJson | ConvertTo-Json -Depth 20
        Write-File $PkgPath $newPkgContent
        Write-Host "Added @paper-design/shaders-react to package.json dependencies." -ForegroundColor Green
    }
} else {
    Write-Host "WARNING: package.json not found at $PkgPath - add @paper-design/shaders-react manually." -ForegroundColor Red
}

# ---------------------------------------------------------------------------
# 1. components/ui/auth-field.tsx  (floating-label input, controlled)
# ---------------------------------------------------------------------------
$authField = @'
"use client";

import { useState, type InputHTMLAttributes } from "react";
import { cn } from "@/lib/utils";

export type AuthFieldProps = InputHTMLAttributes<HTMLInputElement> & {
  label: string;
};

/**
 * Floating-label input box: while empty and unfocused, the label sits
 * centered inside the box like a placeholder. As soon as the field has
 * focus or a value, the label lifts to the right edge.
 */
export function AuthField({ label, className, value, onFocus, onBlur, id, ...props }: AuthFieldProps) {
  const [focused, setFocused] = useState(false);
  const hasValue = Boolean(value);
  const showFloatingLabel = focused || hasValue;
  const fieldId = id ?? props.name;

  return (
    <label
      htmlFor={fieldId}
      className={cn(
        "flex h-14 items-center justify-between gap-4 rounded-[10px] border border-line bg-card px-5 text-[16px] leading-none transition-colors",
        focused && "border-accent-violet",
        className
      )}
    >
      <input
        id={fieldId}
        value={value}
        onFocus={(e) => {
          setFocused(true);
          onFocus?.(e);
        }}
        onBlur={(e) => {
          setFocused(false);
          onBlur?.(e);
        }}
        aria-label={label}
        className="min-w-0 flex-1 truncate bg-transparent text-ink outline-none placeholder:text-transparent"
        {...props}
      />
      <span
        className={cn(
          "shrink-0 text-ink-soft transition-opacity",
          showFloatingLabel ? "text-[12px] font-medium uppercase tracking-wide" : "text-[16px]"
        )}
      >
        {label}
      </span>
    </label>
  );
}
'@
Write-File (Join-Path $UiDir "auth-field.tsx") $authField

# ---------------------------------------------------------------------------
# 2. components/ui/auth-visual-panel.tsx  (GrainGradient right panel)
# ---------------------------------------------------------------------------
$authVisualPanel = @'
"use client";

import Link from "next/link";
import { GrainGradient } from "@paper-design/shaders-react";
import { Sparkles } from "lucide-react";

export function AuthVisualPanel({
  headline,
  tagline,
  ctaLabel,
  ctaHref
}: {
  headline: React.ReactNode;
  tagline: string;
  ctaLabel: string;
  ctaHref: string;
}) {
  return (
    <div className="relative hidden min-h-[720px] overflow-hidden rounded-md bg-ink p-8 text-white sm:p-12 lg:flex">
      <GrainGradient
        speed={1}
        scale={1}
        rotation={0}
        offsetX={0}
        offsetY={0}
        softness={0.5}
        intensity={0.5}
        noise={0.25}
        shape="corners"
        frame={2854.5}
        colors={["#ffffff", "#7c3aed", "#ec4899", "#ffffff"]}
        colorBack="#00000000"
        className="absolute inset-0 bg-ink"
      />

      <div className="relative z-10 flex h-full w-full flex-col justify-between">
        <h2 className="max-w-[560px] pt-0 font-display text-4xl font-medium leading-[1.05] tracking-[-0.03em] text-white sm:text-5xl lg:pt-16 lg:text-[56px]">
          {headline}
        </h2>

        <div>
          <p className="mb-6 max-w-md text-[14.5px] text-white/75">{tagline}</p>
          <Link
            href={ctaHref}
            className="inline-flex h-12 max-w-full items-center gap-2.5 rounded-[10px] border border-white/25 px-5 text-[14px] font-medium text-white/90 backdrop-blur-sm transition-colors hover:border-white/45 hover:text-white"
          >
            <Sparkles size={16} className="shrink-0" />
            <span className="truncate whitespace-nowrap">{ctaLabel}</span>
          </Link>
        </div>
      </div>
    </div>
  );
}
'@
Write-File (Join-Path $UiDir "auth-visual-panel.tsx") $authVisualPanel

# ---------------------------------------------------------------------------
# 3. app/(auth)/login/page.tsx  (rewrite)
# ---------------------------------------------------------------------------
$LoginPath = Join-Path $LoginDir "page.tsx"
Backup-File $LoginPath

$loginPage = @'
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
'@
Write-File $LoginPath $loginPage

# ---------------------------------------------------------------------------
# 4. app/(auth)/register/page.tsx  (rewrite)
# ---------------------------------------------------------------------------
$RegisterPath = Join-Path $RegDir "page.tsx"
Backup-File $RegisterPath

$registerPage = @'
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
      { onSuccess: () => router.push(role === "instructor" ? "/instructor/dashboard" : "/dashboard") }
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
'@
Write-File $RegisterPath $registerPage

Write-Host ""
Write-Host "Done. New/updated files:" -ForegroundColor Cyan
Write-Host "  apps\web\package.json  (added @paper-design/shaders-react)"
Write-Host "  apps\web\components\ui\auth-field.tsx"
Write-Host "  apps\web\components\ui\auth-visual-panel.tsx"
Write-Host "  apps\web\app\(auth)\login\page.tsx     (backup saved alongside)"
Write-Host "  apps\web\app\(auth)\register\page.tsx  (backup saved alongside)"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  cd apps\web"
Write-Host "  pnpm install   # pulls in @paper-design/shaders-react"
Write-Host "  pnpm dev"