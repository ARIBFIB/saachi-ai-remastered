# =============================================================
# Saachi AI Frontend - Step 5: Wire Auth Pages + Homepage UI
# Login/Register pages using React Hook Form + Zod + api-client hooks.
# Homepage rebuilt using @saachi/ui components (Button, Card).
# =============================================================

$ProjectRoot = "D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2"
$WebRoot = Join-Path $ProjectRoot "apps\web"

Write-Host "=== Saachi AI Frontend Scaffold - Step 5 (Auth Pages + Homepage) ===" -ForegroundColor Cyan

if (-not (Test-Path $WebRoot)) {
    Write-Host "ERROR: apps/web not found. Run earlier steps first." -ForegroundColor Red
    exit 1
}

$AuthDir = Join-Path $WebRoot "app\(auth)"
$LoginDir = Join-Path $AuthDir "login"
$RegisterDir = Join-Path $AuthDir "register"
$ForgotDir = Join-Path $AuthDir "forgot-password"

foreach ($d in @($LoginDir, $RegisterDir, $ForgotDir)) {
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
}

# ---------------------------------------------------------------
# app/(auth)/layout.tsx - shared centered auth shell
# ---------------------------------------------------------------
$authLayout = @'
export default function AuthLayout({ children }: { children: React.ReactNode }) {
  return (
    <main
      style={{
        minHeight: "100vh",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        background: "var(--surface-bg)",
        padding: "24px"
      }}
    >
      <div style={{ width: "100%", maxWidth: "420px" }}>{children}</div>
    </main>
  );
}
'@
Set-Content -Path (Join-Path $AuthDir "layout.tsx") -Value $authLayout -Encoding UTF8

# ---------------------------------------------------------------
# app/(auth)/login/page.tsx
# ---------------------------------------------------------------
$loginPage = @'
"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { useRouter } from "next/navigation";
import { useState } from "react";
import Link from "next/link";
import { loginSchema, type LoginInput } from "@saachi/utils";
import { useLogin } from "@saachi/api-client";
import { Button, Card } from "@saachi/ui";

export default function LoginPage() {
  const router = useRouter();
  const loginMutation = useLogin();
  const [serverError, setServerError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting }
  } = useForm<LoginInput>({
    resolver: zodResolver(loginSchema)
  });

  const onSubmit = async (data: LoginInput) => {
    setServerError(null);
    try {
      const result = await loginMutation.mutateAsync(data);
      if ("requires2fa" in result && result.requires2fa) {
        router.push("/login/2fa");
        return;
      }
      router.push("/dashboard");
    } catch (err: any) {
      setServerError(err?.message ?? "Login failed. Please try again.");
    }
  };

  return (
    <Card>
      <h1 style={{ fontSize: "24px", fontWeight: 700, marginBottom: "4px" }}>Welcome back</h1>
      <p style={{ color: "var(--text-secondary)", fontSize: "14px", marginBottom: "24px" }}>
        Log in to continue learning or teaching on Saachi AI.
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
            placeholder="********"
          />
          {errors.password && (
            <p style={{ color: "#EF4444", fontSize: "13px", marginTop: "4px" }}>{errors.password.message}</p>
          )}
        </div>

        {serverError && (
          <p style={{ color: "#EF4444", fontSize: "13px" }}>{serverError}</p>
        )}

        <Button type="submit" size="lg" disabled={isSubmitting || loginMutation.isPending}>
          {isSubmitting || loginMutation.isPending ? "Logging in..." : "Log In"}
        </Button>
      </form>

      <div style={{ marginTop: "20px", fontSize: "14px", textAlign: "center", color: "var(--text-secondary)" }}>
        <Link href="/forgot-password">Forgot password?</Link>
        <span style={{ margin: "0 8px" }}>&middot;</span>
        <Link href="/register">Create an account</Link>
      </div>
    </Card>
  );
}
'@
Set-Content -Path (Join-Path $LoginDir "page.tsx") -Value $loginPage -Encoding UTF8

# ---------------------------------------------------------------
# app/(auth)/register/page.tsx
# ---------------------------------------------------------------
$registerPage = @'
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
'@
Set-Content -Path (Join-Path $RegisterDir "page.tsx") -Value $registerPage -Encoding UTF8

# ---------------------------------------------------------------
# app/(auth)/forgot-password/page.tsx
# ---------------------------------------------------------------
$forgotPage = @'
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
'@
Set-Content -Path (Join-Path $ForgotDir "page.tsx") -Value $forgotPage -Encoding UTF8

# ---------------------------------------------------------------
# Homepage rebuilt with @saachi/ui components
# ---------------------------------------------------------------
$homepagePath = Join-Path $WebRoot "app\(marketing)\page.tsx"
$homepage = @'
import Link from "next/link";
import { Button, Card, Badge } from "@saachi/ui";

const categories = [
  { title: "AI Automation & Workflow Tools", desc: "n8n, Zapier, Make.com" },
  { title: "AI for Marketing & Sales", desc: "Ad copy, lead gen, campaigns" },
  { title: "AI Website & App Development", desc: "Build with AI-assisted tools" },
  { title: "AI Integration for Developers", desc: "OpenAI, Claude, Gemini APIs" }
];

export default function HomePage() {
  return (
    <main>
      {/* Hero */}
      <section
        style={{
          textAlign: "center",
          padding: "96px 24px 64px",
          background:
            "radial-gradient(ellipse 60% 50% at 50% 0%, rgba(59,130,246,0.12), transparent 70%)"
        }}
      >
        <Badge variant="info">Now in early access</Badge>
        <h1
          style={{
            fontSize: "48px",
            fontWeight: 700,
            lineHeight: 1.12,
            marginTop: "20px",
            maxWidth: "760px",
            marginLeft: "auto",
            marginRight: "auto"
          }}
        >
          Learn practical{" "}
          <span
            style={{
              background: "linear-gradient(90deg, #60A5FA 0%, #22D3EE 50%, #818CF8 100%)",
              WebkitBackgroundClip: "text",
              backgroundClip: "text",
              color: "transparent"
            }}
          >
            AI skills
          </span>
          . Build real things. Get paid to teach.
        </h1>
        <p
          style={{
            color: "var(--text-secondary)",
            fontSize: "18px",
            maxWidth: "600px",
            margin: "24px auto 32px"
          }}
        >
          Saachi AI is a skills-first marketplace where practitioners teach and learners build,
          not just watch.
        </p>
        <div style={{ display: "flex", gap: "16px", justifyContent: "center" }}>
          <Link href="/register">
            <Button size="lg">Get Started</Button>
          </Link>
          <Link href="/courses">
            <Button size="lg" variant="secondary">
              Browse Courses
            </Button>
          </Link>
        </div>
      </section>

      {/* Category grid */}
      <section style={{ padding: "64px 24px", maxWidth: "1120px", margin: "0 auto" }}>
        <h2 style={{ fontSize: "28px", fontWeight: 700, textAlign: "center", marginBottom: "40px" }}>
          Explore top categories
        </h2>
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fit, minmax(240px, 1fr))",
            gap: "24px"
          }}
        >
          {categories.map((c) => (
            <Card key={c.title}>
              <h3 style={{ fontSize: "18px", fontWeight: 600, marginBottom: "8px" }}>{c.title}</h3>
              <p style={{ color: "var(--text-secondary)", fontSize: "14px" }}>{c.desc}</p>
            </Card>
          ))}
        </div>
      </section>
    </main>
  );
}
'@
Set-Content -Path $homepagePath -Value $homepage -Encoding UTF8

Write-Host ""
Write-Host "=== Step 5 Complete ===" -ForegroundColor Cyan
Write-Host "Created: (auth)/layout.tsx, login/page.tsx, register/page.tsx, forgot-password/page.tsx" -ForegroundColor Green
Write-Host "Rebuilt: (marketing)/page.tsx using @saachi/ui Button/Card/Badge" -ForegroundColor Green
Write-Host ""
Write-Host "Run:" -ForegroundColor Yellow
Write-Host "  pnpm dev:web" -ForegroundColor White
Write-Host "  Visit http://localhost:3000, /login, /register, /forgot-password" -ForegroundColor White
Write-Host ""
Write-Host "Note: forms will call NEXT_PUBLIC_API_URL - backend (Doc 3/NestJS) is not built yet," -ForegroundColor Yellow
Write-Host "so login/register submissions will fail until the backend is running. UI/validation" -ForegroundColor Yellow
Write-Host "flow can still be tested end-to-end once backend routes exist." -ForegroundColor Yellow
Write-Host ""
Write-Host "NEXT STEP: course marketplace listing page + CourseCard component (Doc 2 section 10.2)." -ForegroundColor Yellow