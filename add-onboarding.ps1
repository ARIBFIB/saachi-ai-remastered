<#
  SAI2 - Learner Onboarding Flow (frontend-only, dummy data)
  Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2
  Usage:    powershell -ExecutionPolicy Bypass -File .\add-onboarding.ps1
#>

$ErrorActionPreference = "Stop"

$root = Get-Location
Write-Host "Running in: $root" -ForegroundColor Cyan

$componentDir = Join-Path $root "apps\web\components\onboarding"
$routeDir     = Join-Path $root "apps\web\app\(auth)\onboarding"
$registerFile = Join-Path $root "apps\web\app\(auth)\register\page.tsx"

# --- sanity checks -----------------------------------------------------
if (-not (Test-Path (Join-Path $root "apps\web"))) {
    Write-Host "ERROR: 'apps\web' not found. Run this script from the SAI2 repo root." -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $registerFile)) {
    Write-Host "ERROR: register\page.tsx not found at expected path:`n$registerFile" -ForegroundColor Red
    exit 1
}

New-Item -ItemType Directory -Force -Path $componentDir | Out-Null
New-Item -ItemType Directory -Force -Path $routeDir | Out-Null

# =========================================================================
# 1) apps\web\components\onboarding\onboarding-form.tsx
# =========================================================================
$onboardingFormPath = Join-Path $componentDir "onboarding-form.tsx"

$onboardingFormContent = @'
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import { ChevronLeft, ChevronRight, Check, Loader2, Sparkles } from "lucide-react";
import { Button, Input, Textarea, Select, cn } from "@saachi/ui";

// NOTE: demo-only, frontend-only flow. No backend mutation wired up yet.
// All data below is dummy / local-state only and is discarded on submit
// besides a localStorage completion flag used to avoid re-showing this flow.

const STEPS = [
  { id: "personal", title: "About you" },
  { id: "interests", title: "Interests" },
  { id: "goals", title: "Goals" },
  { id: "experience", title: "Experience" },
  { id: "review", title: "Review" }
];

const INTEREST_OPTIONS = [
  "AI Automation",
  "Prompt Engineering",
  "Workflow Tools (n8n, Zapier)",
  "AI for Marketing",
  "AI for Developers",
  "No-code AI Apps",
  "Data & Analytics",
  "Design & Creative AI"
];

const GOAL_OPTIONS = [
  { value: "career", label: "Switch careers into AI" },
  { value: "upskill", label: "Upskill in my current role" },
  { value: "freelance", label: "Freelance / sell AI services" },
  { value: "hobby", label: "Just curious, learning for fun" }
];

const EXPERIENCE_OPTIONS = [
  { label: "Complete beginner", value: "beginner" },
  { label: "Some experience", value: "intermediate" },
  { label: "Comfortable building things", value: "advanced" }
];

type OnboardingData = {
  fullName: string;
  headline: string;
  interests: string[];
  goal: string;
  experience: string;
  weeklyHours: string;
  notes: string;
};

const contentVariants = {
  hidden: { opacity: 0, x: 40 },
  visible: { opacity: 1, x: 0, transition: { duration: 0.25 } },
  exit: { opacity: 0, x: -40, transition: { duration: 0.18 } }
};

function Pill({
  selected,
  onClick,
  children
}: {
  selected: boolean;
  onClick: () => void;
  children: React.ReactNode;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={cn(
        "rounded-control border px-3.5 py-2.5 text-left text-[13.5px] font-medium transition-colors",
        selected
          ? "border-gold-dark bg-gold-tint text-ink"
          : "border-line text-ink-soft hover:bg-paper-dim"
      )}
    >
      {children}
    </button>
  );
}

export function OnboardingForm() {
  const router = useRouter();
  const [step, setStep] = useState(0);
  const [submitting, setSubmitting] = useState(false);
  const [data, setData] = useState<OnboardingData>({
    fullName: "",
    headline: "",
    interests: [],
    goal: "",
    experience: "",
    weeklyHours: "3-5",
    notes: ""
  });

  const isFirst = step === 0;
  const isLast = step === STEPS.length - 1;

  function update<K extends keyof OnboardingData>(key: K, value: OnboardingData[K]) {
    setData((prev) => ({ ...prev, [key]: value }));
  }

  function toggleInterest(interest: string) {
    setData((prev) => ({
      ...prev,
      interests: prev.interests.includes(interest)
        ? prev.interests.filter((i) => i !== interest)
        : [...prev.interests, interest]
    }));
  }

  function isStepValid() {
    switch (step) {
      case 0:
        return data.fullName.trim() !== "";
      case 1:
        return data.interests.length > 0;
      case 2:
        return data.goal !== "";
      case 3:
        return data.experience !== "";
      default:
        return true;
    }
  }

  function next() {
    if (isLast) return handleFinish();
    setStep((s) => Math.min(s + 1, STEPS.length - 1));
  }

  function prev() {
    setStep((s) => Math.max(s - 1, 0));
  }

  function handleFinish() {
    setSubmitting(true);
    // NOTE: demo-only. Persist a local flag so the onboarding flow isn't
    // shown again; replace with a real profile-onboarding mutation once
    // the backend endpoint exists.
    setTimeout(() => {
      window.localStorage.setItem("saachi-onboarding-complete", "true");
      setSubmitting(false);
      router.push("/dashboard");
    }, 700);
  }

  return (
    <div className="mx-auto w-full max-w-xl">
      {/* Progress */}
      <div className="mb-8">
        <div className="mb-2 flex justify-between">
          {STEPS.map((s, index) => (
            <div key={s.id} className="flex flex-col items-center">
              <button
                type="button"
                onClick={() => index <= step && setStep(index)}
                aria-label={`Go to step ${index + 1}: ${s.title}`}
                className={cn(
                  "h-3 w-3 rounded-full transition-colors",
                  index < step
                    ? "bg-gold-dark"
                    : index === step
                    ? "bg-gold-dark ring-4 ring-gold-tint"
                    : "bg-paper-dim"
                )}
              />
              <span
                className={cn(
                  "mt-1.5 hidden text-[11px] sm:block",
                  index === step ? "font-semibold text-ink" : "text-ink-soft"
                )}
              >
                {s.title}
              </span>
            </div>
          ))}
        </div>
        <div className="mt-2 h-1.5 w-full overflow-hidden rounded-full bg-paper-dim">
          <motion.div
            className="h-full rounded-full bg-gold"
            initial={false}
            animate={{ width: `${(step / (STEPS.length - 1)) * 100}%` }}
            transition={{ duration: 0.25 }}
          />
        </div>
      </div>

      {/* Card */}
      <div className="overflow-hidden rounded-card border border-line bg-card">
        <AnimatePresence mode="wait">
          <motion.div
            key={step}
            initial="hidden"
            animate="visible"
            exit="exit"
            variants={contentVariants}
            className="p-6 sm:p-8"
          >
            {step === 0 && (
              <>
                <h2 className="mb-1 font-display text-[20px] font-semibold text-ink">
                  Tell us about yourself
                </h2>
                <p className="mb-6 text-[13.5px] text-ink-soft">
                  This helps us personalize your learning path.
                </p>
                <div className="flex flex-col gap-4">
                  <Input
                    label="Full name"
                    value={data.fullName}
                    onChange={(e) => update("fullName", e.target.value)}
                    placeholder="Your name"
                  />
                  <Input
                    label="What best describes you? (optional)"
                    value={data.headline}
                    onChange={(e) => update("headline", e.target.value)}
                    placeholder="e.g. Marketing manager, Freelancer, Student"
                  />
                </div>
              </>
            )}

            {step === 1 && (
              <>
                <h2 className="mb-1 font-display text-[20px] font-semibold text-ink">
                  What are you interested in?
                </h2>
                <p className="mb-6 text-[13.5px] text-ink-soft">Pick as many as apply.</p>
                <div className="grid grid-cols-1 gap-2 sm:grid-cols-2">
                  {INTEREST_OPTIONS.map((interest) => (
                    <Pill
                      key={interest}
                      selected={data.interests.includes(interest)}
                      onClick={() => toggleInterest(interest)}
                    >
                      {interest}
                    </Pill>
                  ))}
                </div>
              </>
            )}

            {step === 2 && (
              <>
                <h2 className="mb-1 font-display text-[20px] font-semibold text-ink">
                  What&apos;s your main goal?
                </h2>
                <p className="mb-6 text-[13.5px] text-ink-soft">
                  We&apos;ll tailor course recommendations around this.
                </p>
                <div className="flex flex-col gap-2">
                  {GOAL_OPTIONS.map((goal) => (
                    <Pill key={goal.value} selected={data.goal === goal.value} onClick={() => update("goal", goal.value)}>
                      {goal.label}
                    </Pill>
                  ))}
                </div>
              </>
            )}

            {step === 3 && (
              <>
                <h2 className="mb-1 font-display text-[20px] font-semibold text-ink">
                  Your experience level
                </h2>
                <p className="mb-6 text-[13.5px] text-ink-soft">
                  So we can pitch lessons at the right level.
                </p>
                <div className="mb-5 flex flex-col gap-2">
                  {EXPERIENCE_OPTIONS.map((exp) => (
                    <Pill
                      key={exp.value}
                      selected={data.experience === exp.value}
                      onClick={() => update("experience", exp.value)}
                    >
                      {exp.label}
                    </Pill>
                  ))}
                </div>
                <Select
                  label="Hours per week you can commit"
                  value={data.weeklyHours}
                  onChange={(e) => update("weeklyHours", e.target.value)}
                  options={[
                    { label: "Less than 3 hours", value: "<3" },
                    { label: "3-5 hours", value: "3-5" },
                    { label: "5-10 hours", value: "5-10" },
                    { label: "10+ hours", value: "10+" }
                  ]}
                />
              </>
            )}

            {step === 4 && (
              <>
                <div className="mb-5 flex items-center gap-2">
                  <div className="flex h-9 w-9 items-center justify-center rounded-full bg-gold-tint text-gold-dark">
                    <Sparkles size={16} />
                  </div>
                  <h2 className="font-display text-[20px] font-semibold text-ink">
                    You&apos;re all set{data.fullName ? `, ${data.fullName}` : ""}
                  </h2>
                </div>
                <div className="mb-4 flex flex-col gap-3 rounded-control border border-line bg-paper-dim/40 p-4 text-[13.5px]">
                  <div className="flex justify-between gap-4">
                    <span className="text-ink-soft">Interests</span>
                    <span className="text-right font-medium text-ink">
                      {data.interests.length > 0 ? data.interests.join(", ") : "-"}
                    </span>
                  </div>
                  <div className="flex justify-between gap-4">
                    <span className="text-ink-soft">Goal</span>
                    <span className="font-medium text-ink">
                      {GOAL_OPTIONS.find((g) => g.value === data.goal)?.label ?? "-"}
                    </span>
                  </div>
                  <div className="flex justify-between gap-4">
                    <span className="text-ink-soft">Experience</span>
                    <span className="font-medium text-ink">
                      {EXPERIENCE_OPTIONS.find((e) => e.value === data.experience)?.label ?? "-"}
                    </span>
                  </div>
                  <div className="flex justify-between gap-4">
                    <span className="text-ink-soft">Weekly commitment</span>
                    <span className="font-medium text-ink">{data.weeklyHours} hrs</span>
                  </div>
                </div>
                <Textarea
                  label="Anything else? (optional)"
                  rows={3}
                  value={data.notes}
                  onChange={(e) => update("notes", e.target.value)}
                  placeholder="Tell us anything else that would help us personalize your experience"
                />
              </>
            )}
          </motion.div>
        </AnimatePresence>

        <div className="flex items-center justify-between border-t border-line px-6 py-4 sm:px-8">
          <Button variant="secondary" onClick={prev} disabled={isFirst}>
            <ChevronLeft size={15} className="mr-1" />
            Back
          </Button>
          <Button onClick={next} disabled={!isStepValid() || submitting}>
            {submitting ? (
              <>
                <Loader2 size={15} className="mr-1.5 animate-spin" />
                Saving...
              </>
            ) : isLast ? (
              <>
                Finish
                <Check size={15} className="ml-1" />
              </>
            ) : (
              <>
                Next
                <ChevronRight size={15} className="ml-1" />
              </>
            )}
          </Button>
        </div>
      </div>

      <p className="mt-4 text-center text-[12.5px] text-ink-soft">
        Step {step + 1} of {STEPS.length}
      </p>

      <button
        type="button"
        onClick={handleFinish}
        className="mx-auto mt-3 block text-[12.5px] font-medium text-ink-soft underline-offset-2 hover:text-ink hover:underline"
      >
        Skip for now
      </button>
    </div>
  );
}

export default OnboardingForm;
'@

Set-Content -Path $onboardingFormPath -Value $onboardingFormContent -Encoding UTF8
Write-Host "Created: $onboardingFormPath" -ForegroundColor Green

# =========================================================================
# 2) apps\web\app\(auth)\onboarding\page.tsx
# =========================================================================
$onboardingPagePath = Join-Path $routeDir "page.tsx"

$onboardingPageContent = @'
"use client";

import { OnboardingForm } from "@/components/onboarding/onboarding-form";

export default function OnboardingPage() {
  return (
    <div className="mx-auto flex min-h-screen max-w-3xl flex-col justify-center px-4 py-16 md:px-0">
      <OnboardingForm />
    </div>
  );
}
'@

Set-Content -Path $onboardingPagePath -Value $onboardingPageContent -Encoding UTF8
Write-Host "Created: $onboardingPagePath" -ForegroundColor Green

# =========================================================================
# 3) Patch register/page.tsx -> redirect learners to /onboarding first
# =========================================================================
$registerContent = Get-Content -Path $registerFile -Raw

$oldBlock = 'onSuccess: () => {
          if (role === "learner") {
            window.localStorage.setItem("saachi-just-signed-up", "true");
          }
          router.push(role === "instructor" ? "/instructor/dashboard" : "/dashboard");
        }'

$newBlock = 'onSuccess: () => {
          if (role === "learner") {
            window.localStorage.setItem("saachi-just-signed-up", "true");
          }
          router.push(role === "instructor" ? "/instructor/dashboard" : "/onboarding");
        }'

if ($registerContent -notmatch [regex]::Escape($oldBlock)) {
    Write-Host "WARNING: register/page.tsx onSuccess block did not match exactly - skipping patch." -ForegroundColor Yellow
    Write-Host "You'll need to manually change the learner redirect target to '/onboarding'." -ForegroundColor Yellow
} else {
    $registerContent = $registerContent.Replace($oldBlock, $newBlock)
    Set-Content -Path $registerFile -Value $registerContent -Encoding UTF8
    Write-Host "Patched: $registerFile (learner -> /onboarding instead of /dashboard)" -ForegroundColor Green
}

# =========================================================================
# 4) Reminder about npm deps (framer-motion + lucide-react already used
#    elsewhere in the repo - e.g. learner-onboarding-tour.tsx - so no new
#    packages should be required. This is just a safety check.)
# =========================================================================
Write-Host ""
Write-Host "Done. Summary:" -ForegroundColor Cyan
Write-Host " - apps\web\components\onboarding\onboarding-form.tsx (new)"
Write-Host " - apps\web\app\(auth)\onboarding\page.tsx (new)"
Write-Host " - apps\web\app\(auth)\register\page.tsx (patched redirect)"
Write-Host ""
Write-Host "No new npm packages needed (framer-motion + lucide-react already in the repo)." -ForegroundColor Cyan
Write-Host "Frontend-only, dummy data - no backend calls added." -ForegroundColor Cyan