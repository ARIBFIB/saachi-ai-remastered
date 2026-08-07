# step7-auth-completion-instructor-extras.ps1
# Run from: SAI2 root folder

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $fullPath = Join-Path -Path (Get-Location).Path -ChildPath $Path
    $dir = Split-Path -Parent $fullPath
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($fullPath, $Content, $enc)
    Write-Host "  wrote $fullPath"
}

function Patch-File {
    param([string]$Path, [string]$OldStr, [string]$NewStr, [string]$Label)
    $fullPath = Join-Path -Path (Get-Location).Path -ChildPath $Path
    if (-not (Test-Path $fullPath)) {
        Write-Host "  SKIP (file not found): $fullPath" -ForegroundColor Yellow
        return
    }
    $content = Get-Content -Path $fullPath -Raw
    if ($content.Contains($OldStr)) {
        $updated = $content.Replace($OldStr, $NewStr)
        $enc = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($fullPath, $updated, $enc)
        Write-Host "  patched ($Label): $fullPath"
    } else {
        Write-Host "  WARNING: pattern for '$Label' not found in $fullPath - skipped." -ForegroundColor Yellow
    }
}

Write-Host "Step 7: reset-password + verify-email + instructor promotions/mentorship-settings/verification..." -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. Reset password page
# ---------------------------------------------------------------------------
$resetPasswordPage = @'
"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { useRouter, useSearchParams } from "next/navigation";
import { useState } from "react";
import Link from "next/link";
import { resetPasswordSchema, type ResetPasswordInput } from "@saachi/utils";
import { Button, Card, Input } from "@saachi/ui";

export default function ResetPasswordPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [serverError, setServerError] = useState<string | null>(null);
  const [done, setDone] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting }
  } = useForm<ResetPasswordInput>({
    resolver: zodResolver(resetPasswordSchema),
    defaultValues: { token: searchParams.get("token") ?? "demo-token" }
  });

  const onSubmit = async (data: ResetPasswordInput) => {
    setServerError(null);
    // NOTE: demo-only. Replace with apiRequest("/auth/reset-password", ...) once backend exists.
    await new Promise((resolve) => setTimeout(resolve, 500));
    setDone(true);
  };

  if (done) {
    return (
      <Card className="w-full max-w-[420px] p-8 text-center">
        <h1 className="font-display text-[22px] font-semibold text-ink">Password updated</h1>
        <p className="mt-2 text-[14px] text-ink-soft">
          Your password has been reset. You can now log in with your new password.
        </p>
        <Button size="lg" className="mt-6 w-full" onClick={() => router.push("/login")}>
          Go to login
        </Button>
      </Card>
    );
  }

  return (
    <Card className="w-full max-w-[420px] p-8">
      <h1 className="font-display text-[22px] font-semibold text-ink">Set a new password</h1>
      <p className="mb-6 mt-1 text-[14px] text-ink-soft">Choose a strong password for your account.</p>

      <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
        <input type="hidden" {...register("token")} />
        <Input
          label="New password"
          type="password"
          placeholder="At least 8 characters"
          {...register("password")}
          error={errors.password?.message}
        />
        <Input
          label="Confirm new password"
          type="password"
          placeholder="Repeat new password"
          {...register("confirmPassword")}
          error={errors.confirmPassword?.message}
        />

        {serverError && <p className="text-[13px] text-error">{serverError}</p>}

        <Button type="submit" size="lg" disabled={isSubmitting}>
          {isSubmitting ? "Updating..." : "Update password"}
        </Button>
      </form>

      <div className="mt-5 text-center text-[14px] text-ink-soft">
        <Link href="/login" className="hover:text-ink">
          Back to login
        </Link>
      </div>
    </Card>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(auth)\reset-password\page.tsx" -Content $resetPasswordPage

# ---------------------------------------------------------------------------
# 2. Verify email page
# ---------------------------------------------------------------------------
$verifyEmailPage = @'
"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { MailCheck, Loader2 } from "lucide-react";
import { Button, Card } from "@saachi/ui";

export default function VerifyEmailPage() {
  const router = useRouter();
  const [status, setStatus] = useState<"pending" | "verified">("pending");

  useEffect(() => {
    // NOTE: demo-only. Replace with apiRequest("/auth/verify-email", ...) using
    // the token from the URL once the backend is available.
    const timer = setTimeout(() => setStatus("verified"), 1200);
    return () => clearTimeout(timer);
  }, []);

  return (
    <Card className="w-full max-w-[420px] p-8 text-center">
      <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-teal-light text-teal">
        {status === "pending" ? <Loader2 size={22} className="animate-spin" /> : <MailCheck size={22} />}
      </div>

      {status === "pending" ? (
        <>
          <h1 className="font-display text-[22px] font-semibold text-ink">Verifying your email...</h1>
          <p className="mt-2 text-[14px] text-ink-soft">This will only take a moment.</p>
        </>
      ) : (
        <>
          <h1 className="font-display text-[22px] font-semibold text-ink">Email verified</h1>
          <p className="mt-2 text-[14px] text-ink-soft">
            Your email address has been confirmed. You're all set.
          </p>
          <Button size="lg" className="mt-6 w-full" onClick={() => router.push("/dashboard")}>
            Go to dashboard
          </Button>
        </>
      )}

      <div className="mt-5 text-center text-[14px] text-ink-soft">
        <Link href="/login" className="hover:text-ink">
          Back to login
        </Link>
      </div>
    </Card>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(auth)\verify-email\page.tsx" -Content $verifyEmailPage

# ---------------------------------------------------------------------------
# 3. Instructor Promotions / Boost Courses page
# ---------------------------------------------------------------------------
$promotionsStore = @'
import { create } from "zustand";
import { persist } from "zustand/middleware";

export type ActivePromotion = {
  courseId: string;
  courseTitle: string;
  tier: "bronze" | "silver" | "gold";
  purchasedAt: string;
  expiresAt: string;
};

type PromotionState = {
  active: ActivePromotion[];
  purchase: (courseId: string, courseTitle: string, tier: ActivePromotion["tier"]) => void;
};

export const usePromotionStore = create<PromotionState>()(
  persist(
    (set, get) => ({
      active: [],
      purchase: (courseId, courseTitle, tier) => {
        const now = new Date();
        const expires = new Date(now.getTime() + 1000 * 60 * 60 * 24 * 14);
        set({
          active: [
            ...get().active.filter((p) => p.courseId !== courseId),
            { courseId, courseTitle, tier, purchasedAt: now.toISOString(), expiresAt: expires.toISOString() }
          ]
        });
      }
    }),
    { name: "saachi-promotions" }
  )
);
'@
Write-Utf8NoBom -Path "packages\store\src\usePromotionStore.ts" -Content $promotionsStore

$storeIndexUpdated = @'
export * from "./useCartStore";
export * from "./useWishlistStore";
export * from "./useEnrollmentStore";
export * from "./useNotificationStore";
export * from "./useInstructorCourseStore";
export * from "./useCourseBuilderStore";
export * from "./useOrderStore";
export * from "./useCommunityStore";
export * from "./usePromotionStore";
'@
Write-Utf8NoBom -Path "packages\store\src\index.ts" -Content $storeIndexUpdated

$promotionsPage = @'
"use client";

import { useState } from "react";
import { Rocket, Check, Crown } from "lucide-react";
import { useInstructorCourseStore, usePromotionStore } from "@saachi/store";
import { Button, Card, Select, Badge, EmptyState } from "@saachi/ui";
import { formatCurrency, formatDate } from "@saachi/utils";

const TIERS = [
  {
    id: "bronze" as const,
    name: "Bronze",
    price: 15,
    features: ["Category page pinning", "14-day boost"]
  },
  {
    id: "silver" as const,
    name: "Silver",
    price: 35,
    features: ["Everything in Bronze", "Top-of-search placement", "14-day boost"]
  },
  {
    id: "gold" as const,
    name: "Gold",
    price: 75,
    features: ["Everything in Silver", "Homepage featured slot", "14-day boost", "Priority support"]
  }
];

export default function InstructorPromotionsPage() {
  const { courses } = useInstructorCourseStore();
  const promotions = usePromotionStore();
  const [selectedCourseId, setSelectedCourseId] = useState(courses[0]?.id ?? "");

  const courseOptions = courses.map((c) => ({ label: c.title || "Untitled course", value: c.id }));

  const handlePurchase = (tier: (typeof TIERS)[number]) => {
    const course = courses.find((c) => c.id === selectedCourseId);
    if (!course) return;
    promotions.purchase(course.id, course.title, tier.id);
  };

  return (
    <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
      <div className="mb-8">
        <h1 className="font-display text-[26px] font-semibold text-ink">Promotions</h1>
        <p className="mt-1 text-[14px] text-ink-soft">Boost a course's visibility across the marketplace.</p>
      </div>

      {courses.length === 0 ? (
        <EmptyState
          icon={<Rocket size={22} />}
          title="No courses to promote yet"
          description="Create a course first, then come back here to boost it."
        />
      ) : (
        <>
          <div className="mb-6 max-w-[360px]">
            <Select
              label="Course to promote"
              options={courseOptions}
              value={selectedCourseId}
              onChange={(e) => setSelectedCourseId(e.target.value)}
            />
          </div>

          <div className="grid grid-cols-1 gap-6 sm:grid-cols-3">
            {TIERS.map((tier) => (
              <Card key={tier.id} className={tier.id === "gold" ? "border-2 border-ink p-6" : "p-6"}>
                {tier.id === "gold" && (
                  <span className="mb-3 flex w-fit items-center gap-1 rounded-full bg-gold px-3 py-1 text-[11px] font-bold uppercase tracking-[0.05em] text-ink">
                    <Crown size={12} /> Best value
                  </span>
                )}
                <h3 className="text-[16px] font-semibold text-ink">{tier.name}</h3>
                <p className="mt-1 font-mono text-[24px] font-semibold text-ink">
                  {formatCurrency(tier.price, "USD")}
                </p>
                <ul className="mt-4 flex flex-col gap-2">
                  {tier.features.map((f) => (
                    <li key={f} className="flex items-start gap-2 text-[13px] text-ink-soft">
                      <Check size={14} className="mt-0.5 shrink-0 text-teal" />
                      {f}
                    </li>
                  ))}
                </ul>
                <Button
                  className="mt-5 w-full"
                  variant={tier.id === "gold" ? "primary" : "secondary"}
                  onClick={() => handlePurchase(tier)}
                  disabled={!selectedCourseId}
                >
                  Boost with {tier.name}
                </Button>
              </Card>
            ))}
          </div>

          {promotions.active.length > 0 && (
            <div className="mt-10">
              <h2 className="mb-4 text-[16px] font-semibold text-ink">Active promotions</h2>
              <div className="flex flex-col gap-3">
                {promotions.active.map((p) => (
                  <Card key={p.courseId} className="flex items-center justify-between p-4">
                    <div>
                      <p className="text-[14px] font-semibold text-ink">{p.courseTitle}</p>
                      <p className="mt-1 text-[12px] text-ink-soft">
                        Expires {formatDate(p.expiresAt)}
                      </p>
                    </div>
                    <Badge variant="gold">{p.tier}</Badge>
                  </Card>
                ))}
              </div>
            </div>
          )}
        </>
      )}
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(instructor)\instructor\promotions\page.tsx" -Content $promotionsPage

# ---------------------------------------------------------------------------
# 4. Instructor Mentorship settings / availability
# ---------------------------------------------------------------------------
$instructorMentorshipPage = @'
"use client";

import { useState } from "react";
import { Users2, Plus, X } from "lucide-react";
import { Button, Card, Checkbox, Input } from "@saachi/ui";
import { formatCurrency } from "@saachi/utils";

const DAYS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

export default function InstructorMentorshipSettingsPage() {
  const [enabled, setEnabled] = useState(false);
  const [rate, setRate] = useState(40);
  const [slots, setSlots] = useState<string[]>(["Mon 3:00 PM", "Wed 11:00 AM"]);
  const [newSlot, setNewSlot] = useState("");
  const [saved, setSaved] = useState(false);

  const addSlot = () => {
    if (!newSlot.trim()) return;
    setSlots((prev) => [...prev, newSlot.trim()]);
    setNewSlot("");
  };

  const removeSlot = (slot: string) => {
    setSlots((prev) => prev.filter((s) => s !== slot));
  };

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    setSaved(true);
    setTimeout(() => setSaved(false), 2500);
  };

  return (
    <main className="mx-auto max-w-[720px] px-6 py-10 md:px-10">
      <div className="mb-8 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-control bg-teal-light text-teal">
          <Users2 size={18} />
        </div>
        <div>
          <h1 className="font-display text-[24px] font-semibold text-ink">Mentorship Settings</h1>
          <p className="mt-1 text-[13px] text-ink-soft">Offer paid 1-on-1 sessions to your students.</p>
        </div>
      </div>

      <form onSubmit={handleSave} className="flex flex-col gap-6">
        <Card className="p-6">
          <Checkbox
            label="Enable mentorship bookings for my profile"
            checked={enabled}
            onChange={(e) => setEnabled(e.target.checked)}
          />
        </Card>

        <Card className="p-6">
          <Input
            label="Hourly rate (USD)"
            type="number"
            min={0}
            value={rate}
            onChange={(e) => setRate(Number(e.target.value))}
            helperText={`Learners will see this shown as ${formatCurrency(rate, "USD")} / 30 min session.`}
          />
        </Card>

        <Card className="p-6">
          <h2 className="mb-4 text-[15px] font-semibold text-ink">Available time slots</h2>
          <div className="mb-4 flex flex-wrap gap-2">
            {slots.map((slot) => (
              <span
                key={slot}
                className="flex items-center gap-2 rounded-full border border-line-strong px-3 py-1.5 text-[12px] text-ink"
              >
                {slot}
                <button type="button" onClick={() => removeSlot(slot)} className="text-ink-soft hover:text-error">
                  <X size={12} />
                </button>
              </span>
            ))}
          </div>
          <div className="flex items-center gap-2">
            <Input
              placeholder="e.g. Tue 4:00 PM"
              value={newSlot}
              onChange={(e) => setNewSlot(e.target.value)}
              className="h-10 flex-1"
            />
            <Button type="button" size="sm" variant="secondary" onClick={addSlot}>
              <Plus size={14} /> Add slot
            </Button>
          </div>
          <p className="mt-3 text-[12px] text-ink-soft">
            Days for reference: {DAYS.join(", ")}
          </p>
        </Card>

        <div className="flex items-center gap-3">
          <Button type="submit">Save mentorship settings</Button>
          {saved && <span className="text-[13px] text-teal">Saved</span>}
        </div>
      </form>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(instructor)\instructor\mentorship\page.tsx" -Content $instructorMentorshipPage

# ---------------------------------------------------------------------------
# 5. Instructor Verification status page
# ---------------------------------------------------------------------------
$verificationPage = @'
"use client";

import { useState } from "react";
import { ShieldCheck, Upload, Clock, CheckCircle2 } from "lucide-react";
import { Button, Card, Input, Badge } from "@saachi/ui";

type VerificationStatus = "not_submitted" | "pending" | "verified";

const TIER_STEPS = [
  { tier: "New Instructor", requirement: "Just approved, 0-2 published courses" },
  { tier: "Verified Instructor", requirement: "ID verified, 3+ courses, 4.0+ average rating" },
  { tier: "Top-Rated Instructor", requirement: "10+ courses, 4.5+ rating, consistent sales" },
  { tier: "Partner Instructor", requirement: "Invited/negotiated status" }
];

export default function VerificationStatusPage() {
  const [status, setStatus] = useState<VerificationStatus>("not_submitted");
  const [idFile, setIdFile] = useState<string | null>(null);
  const [portfolioLink, setPortfolioLink] = useState("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setStatus("pending");
  };

  return (
    <main className="mx-auto max-w-[720px] px-6 py-10 md:px-10">
      <div className="mb-8 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-control bg-teal-light text-teal">
          <ShieldCheck size={18} />
        </div>
        <div>
          <h1 className="font-display text-[24px] font-semibold text-ink">Verification Status</h1>
          <p className="mt-1 text-[13px] text-ink-soft">Get verified to unlock lower commission rates.</p>
        </div>
      </div>

      <Card className="mb-6 p-6">
        {status === "not_submitted" && (
          <form onSubmit={handleSubmit} className="flex flex-col gap-4">
            <div>
              <label className="mb-1.5 block text-[13px] font-semibold text-ink">
                Government ID or business registration
              </label>
              <button
                type="button"
                onClick={() => setIdFile("id-document-demo.pdf")}
                className="flex w-full items-center justify-center gap-2 rounded-control border border-dashed border-line-strong py-6 text-[13px] text-ink-soft hover:border-ink"
              >
                <Upload size={16} />
                {idFile ? idFile : "Click to upload (demo)"}
              </button>
            </div>
            <Input
              label="Portfolio / proof-of-work link"
              placeholder="GitHub, LinkedIn, or personal site"
              value={portfolioLink}
              onChange={(e) => setPortfolioLink(e.target.value)}
            />
            <Button type="submit" disabled={!idFile}>
              Submit for verification
            </Button>
          </form>
        )}

        {status === "pending" && (
          <div className="flex items-center gap-3">
            <Clock size={20} className="text-gold-dark" />
            <div>
              <p className="text-[14px] font-semibold text-ink">Under review</p>
              <p className="text-[13px] text-ink-soft">
                Your documents were submitted (demo). Admin review typically takes 2-3 business days.
              </p>
            </div>
            <Button size="sm" variant="secondary" className="ml-auto" onClick={() => setStatus("verified")}>
              Simulate approval
            </Button>
          </div>
        )}

        {status === "verified" && (
          <div className="flex items-center gap-3">
            <CheckCircle2 size={20} className="text-teal" />
            <div>
              <p className="text-[14px] font-semibold text-ink">Verified Instructor</p>
              <p className="text-[13px] text-ink-soft">
                You now qualify for a reduced commission rate and the Verified badge.
              </p>
            </div>
            <Badge variant="success" className="ml-auto">
              Verified
            </Badge>
          </div>
        )}
      </Card>

      <h2 className="mb-4 text-[15px] font-semibold text-ink">Instructor trust tiers</h2>
      <div className="flex flex-col gap-3">
        {TIER_STEPS.map((t) => (
          <Card key={t.tier} className="flex items-center justify-between p-4">
            <div>
              <p className="text-[13px] font-semibold text-ink">{t.tier}</p>
              <p className="mt-0.5 text-[12px] text-ink-soft">{t.requirement}</p>
            </div>
          </Card>
        ))}
      </div>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(instructor)\instructor\verification\page.tsx" -Content $verificationPage

# ---------------------------------------------------------------------------
# 6. InstructorShell - add Promotions + Mentorship + Verification nav items
# ---------------------------------------------------------------------------
Patch-File -Path "apps\web\app\(instructor)\_components\InstructorShell.tsx" `
  -OldStr '  Users,
  Settings,
  LogOut,
  Menu,
  X
} from "lucide-react";' `
  -NewStr @'
  Users,
  Settings,
  LogOut,
  Menu,
  X,
  Rocket,
  Users2,
  ShieldCheck
} from "lucide-react";
'@ `
  -Label "add Rocket/Users2/ShieldCheck icons import"

Patch-File -Path "apps\web\app\(instructor)\_components\InstructorShell.tsx" `
  -OldStr '  { label: "Reviews", href: "/instructor/reviews", icon: Star },
  { label: "Students", href: "/instructor/students", icon: Users },
  { label: "Settings", href: "/instructor/settings", icon: Settings }' `
  -NewStr @'
  { label: "Promotions", href: "/instructor/promotions", icon: Rocket },
  { label: "Mentorship", href: "/instructor/mentorship", icon: Users2 },
  { label: "Reviews", href: "/instructor/reviews", icon: Star },
  { label: "Students", href: "/instructor/students", icon: Users },
  { label: "Verification", href: "/instructor/verification", icon: ShieldCheck },
  { label: "Settings", href: "/instructor/settings", icon: Settings }
'@ `
  -Label "add Promotions/Mentorship/Verification nav items"

Write-Host ""
Write-Host "Step 7 done." -ForegroundColor Green
Write-Host "Run: pnpm dev:web" -ForegroundColor Green
Write-Host "Test: /reset-password, /verify-email, /instructor/promotions (create a course first), /instructor/mentorship, /instructor/verification" -ForegroundColor Green