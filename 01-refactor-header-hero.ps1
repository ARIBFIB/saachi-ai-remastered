# ============================================================================
# 01-refactor-header-hero.ps1
# Public Website redesign — Step 1: Header + Hero (new "Blueprint" design system)
# Run from: SAI2 root (D:\...\SAI2>)
# ============================================================================

function Write-FileB64 {
    param([string]$Path, [string]$Content)
    # Use an absolute path resolved from $PSScriptRoot -- [System.IO.File]
    # does NOT follow PowerShell's current location, only the process's
    # working directory, which caused "Could not find a part of the path"
    # even though Test-Path/New-Item (which DO follow PS location) succeeded.
    $fullPath = Join-Path $PSScriptRoot $Path
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Content)
    $b64 = [Convert]::ToBase64String($bytes)
    $decoded = [Convert]::FromBase64String($b64)
    $dir = Split-Path -Path $fullPath -Parent
    if (-not (Test-Path -Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    [System.IO.File]::WriteAllBytes($fullPath, $decoded)
    Write-Host "Written: $Path"
}

$root = "apps\web"

# ----------------------------------------------------------------------------
# 1. tokens.ts — additive new palette (does not touch existing keys used
#    elsewhere in the app, so learner/instructor pages keep working).
# ----------------------------------------------------------------------------
$tokensPath = Join-Path $root "lib\design-system\tokens.ts"
$tokensContent = @'
/**
 * ============================================================================
 * DESIGN TOKENS -- SINGLE SOURCE OF TRUTH
 * ============================================================================
 * Edit ONLY this file to re-theme the entire app (Tailwind CSS vars +
 * Ant Design components both derive from this object).
 *
 * After editing colors here, run:
 *   pnpm --filter web run tokens:sync
 * (or it runs automatically via the "predev"/"prebuild" npm script)
 * ============================================================================
 */

export const tokens = {
  color: {
    // Brand / primary (legacy — still used by learner/instructor dashboards)
    primary: "#3525CD",
    primaryHover: "#2A1DA3",
    primaryTint: "#E0E7FF",
    primaryDark: "#1E1B4B",
    decorativeCyan: "#A5F3FC",

    // Secondary accent
    success: "#005338",
    successTint: "#D1FAE5",
    completedBadgeBg: "#D1FAE5",

    // Neutrals
    ink: "#18181B",
    inkSoft: "#3F3F46",
    textMuted: "#64748B",

    // Surfaces
    bg: "#F8FAFC",
    surface: "#FFFFFF",
    surfaceAlt: "#F4F4F5",
    playerBg: "#0F172A",
    completedGreen: "#4EDEA3",

    // Borders
    border: "#CBD5E1",
    borderStrong: "#94A3B8",

    // Status
    error: "#DC2626",
    notificationDot: "#BA1A1A",
    errorTint: "#FEE2E2",
    warning: "#D97706",
    warningTint: "#FEF3C7",

    // ---- NEW: "Blueprint" system — Public Website redesign only ----
    paper: "#EEF1EC",
    inkDeep: "#12182B",
    inkDeepSoft: "#454C63",
    amber: "#F2A93B",
    amberDark: "#D6890F",
    amberTint: "#FCEACB",
    teal: "#0E6E62",
    tealTint: "#DDEEEA",
    blueprintLine: "#B9C2C7",
    blueprintLineSoft: "#D8DEDB"
  },

  font: {
    family: "'Inter', -apple-system, 'Segoe UI', sans-serif",
    displayFamily: "'Space Grotesk', -apple-system, sans-serif",
    bodyFamily: "'IBM Plex Sans', -apple-system, sans-serif",
    monoFamily: "'IBM Plex Mono', 'Courier New', monospace",
    size: {
      xs: "12px",
      sm: "14px",
      base: "16px",
      lg: "18px",
      xl: "20px",
      "2xl": "24px",
      "3xl": "30px",
      "5xl": "48px"
    },
    weight: {
      normal: 400,
      medium: 500,
      semibold: 600,
      bold: 700,
      black: 900
    }
  },

  radius: {
    sm: "4px",
    md: "8px",
    lg: "12px",
    xl: "16px",
    full: "9999px"
  },

  shadow: {
    sm: "0px 1px 2px 0px rgba(0,0,0,0.05)",
    md: "0px 4px 20px 0px rgba(15,23,42,0.05)",
    lg: "0px 10px 32px 0px rgba(15,23,42,0.12)"
  },

  spacing: {
    section: "48px",
    sectionLg: "80px",
    container: "1280px"
  }
} as const;

export type DesignTokens = typeof tokens;
'@
Write-FileB64 -Path $tokensPath -Content $tokensContent

# ----------------------------------------------------------------------------
# 2. globals.css — load new fonts
# ----------------------------------------------------------------------------
$globalsPath = Join-Path $root "app\globals.css"
$globalsContent = @'
@import "tailwindcss";
@import url("https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&family=IBM+Plex+Sans:wght@400;500;600&family=IBM+Plex+Mono:wght@400;500&display=swap");

/* === AUTO-GENERATED TOKENS START (do not edit) === */
@theme {
}
/* === AUTO-GENERATED TOKENS END === */

html,
body {
  padding: 0;
  margin: 0;
  background: var(--token-color-bg);
  font-family: var(--token-font-bodyFamily);
}

* {
  box-sizing: border-box;
}
'@
Write-FileB64 -Path $globalsPath -Content $globalsContent

# ----------------------------------------------------------------------------
# 3. BlueprintMark.tsx — signature corner-tick component
# ----------------------------------------------------------------------------
$markPath = Join-Path $root "components\marketing\BlueprintMark.tsx"
$markContent = @'
// Signature element for the "Blueprint" design system: a small dimension-line
// crosshair mark, like a corner registration mark on a spec sheet. Used
// sparingly on hero cards and section dividers -- not decoration, it signals
// "this is measured / specified," matching Saachi's outcome-based identity.
interface BlueprintMarkProps {
  className?: string;
  color?: string;
}

export function BlueprintMark({ className = "", color = "var(--token-color-blueprintLine)" }: BlueprintMarkProps) {
  return (
    <svg
      className={className}
      width="20"
      height="20"
      viewBox="0 0 20 20"
      fill="none"
      aria-hidden="true"
    >
      <path d="M10 0V6" stroke={color} strokeWidth="1" />
      <path d="M10 14V20" stroke={color} strokeWidth="1" />
      <path d="M0 10H6" stroke={color} strokeWidth="1" />
      <path d="M14 10H20" stroke={color} strokeWidth="1" />
      <circle cx="10" cy="10" r="2" stroke={color} strokeWidth="1" />
    </svg>
  );
}

interface SpecLabelProps {
  index: string;
  label: string;
}

// Small mono-type "spec field" label -- reused as section eyebrows instead
// of a generic pill badge.
export function SpecLabel({ index, label }: SpecLabelProps) {
  return (
    <div className="flex items-center gap-2">
      <span
        className="text-xs font-medium"
        style={{ fontFamily: "var(--token-font-monoFamily)", color: "var(--token-color-amberDark)" }}
      >
        {index}
      </span>
      <span
        className="h-px w-6"
        style={{ backgroundColor: "var(--token-color-blueprintLine)" }}
      />
      <span
        className="text-xs font-semibold uppercase tracking-[0.12em]"
        style={{ color: "var(--token-color-inkDeepSoft)" }}
      >
        {label}
      </span>
    </div>
  );
}
'@
Write-FileB64 -Path $markPath -Content $markContent

# ----------------------------------------------------------------------------
# 4. Header.tsx — redesigned
# ----------------------------------------------------------------------------
$headerPath = Join-Path $root "components\marketing\Header.tsx"
$headerContent = @'
import Link from "next/link";
import { Search, ShoppingCart, Bell } from "lucide-react";

export function Header() {
  return (
    <header
      className="sticky top-0 z-50 w-full border-b"
      style={{
        backgroundColor: "var(--token-color-paper)",
        borderColor: "var(--token-color-blueprintLineSoft)",
      }}
    >
      <div className="mx-auto flex h-16 max-w-[1280px] items-center justify-between px-6">
        <div className="flex items-center gap-10">
          <Link href="/" className="flex items-center gap-2">
            <span
              className="flex h-6 w-6 items-center justify-center text-xs font-bold"
              style={{
                backgroundColor: "var(--token-color-amber)",
                color: "var(--token-color-inkDeep)",
                fontFamily: "var(--token-font-monoFamily)",
              }}
            >
              S
            </span>
            <span
              className="text-xl font-semibold tracking-tight"
              style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-inkDeep)" }}
            >
              Saachi AI
            </span>
          </Link>

          <div
            className="flex items-center gap-2 rounded-sm border px-3 py-1.5"
            style={{ borderColor: "var(--token-color-blueprintLine)", backgroundColor: "var(--token-color-surface)" }}
          >
            <Search size={14} color="var(--token-color-inkDeepSoft)" />
            <input
              type="text"
              placeholder="Search skills, e.g. 'WhatsApp AI bot'"
              className="w-64 bg-transparent text-sm placeholder:text-[var(--token-color-inkDeepSoft)] focus:outline-none"
              style={{ fontFamily: "var(--token-font-bodyFamily)", color: "var(--token-color-inkDeep)" }}
            />
          </div>
        </div>

        <div className="flex items-center gap-6">
          <nav className="flex items-center gap-5">
            <Link
              href="/courses"
              className="border-b-2 pb-[3px] text-sm font-semibold tracking-wide"
              style={{ borderColor: "var(--token-color-amber)", color: "var(--token-color-inkDeep)" }}
            >
              Marketplace
            </Link>
            <Link
              href="/categories"
              className="text-sm font-semibold tracking-wide hover:opacity-70"
              style={{ color: "var(--token-color-inkDeepSoft)" }}
            >
              Categories
            </Link>
            <Link
              href="/become-instructor"
              className="text-sm font-semibold tracking-wide hover:opacity-70"
              style={{ color: "var(--token-color-inkDeepSoft)" }}
            >
              Teach
            </Link>
          </nav>

          <div className="flex items-center gap-3">
            <button aria-label="Cart" className="p-2" style={{ color: "var(--token-color-inkDeepSoft)" }}>
              <ShoppingCart size={18} />
            </button>
            <button aria-label="Notifications" className="p-2" style={{ color: "var(--token-color-inkDeepSoft)" }}>
              <Bell size={18} />
            </button>

            <Link
              href="/login"
              className="ml-1 px-5 py-2 text-sm font-semibold tracking-wide"
              style={{ backgroundColor: "var(--token-color-inkDeep)", color: "var(--token-color-paper)" }}
            >
              Sign In
            </Link>
          </div>
        </div>
      </div>
    </header>
  );
}
'@
Write-FileB64 -Path $headerPath -Content $headerContent

# ----------------------------------------------------------------------------
# 5. HeroSection.tsx — redesigned
# ----------------------------------------------------------------------------
$heroPath = Join-Path $root "components\marketing\HeroSection.tsx"
$heroContent = @'
import Link from "next/link";
import { BlueprintMark, SpecLabel } from "./BlueprintMark";

const buildLog = [
  "Certificate issued — Prompt Engineering Masterclass",
  "Course published — WhatsApp AI Auto-Responder",
  "Skill verified — n8n Workflow Automation",
];

export function HeroSection() {
  return (
    <section
      className="w-full border-b"
      style={{ backgroundColor: "var(--token-color-paper)", borderColor: "var(--token-color-blueprintLineSoft)" }}
    >
      <div className="mx-auto grid max-w-[1280px] grid-cols-1 gap-10 px-6 py-20 lg:grid-cols-[1.1fr_0.9fr] lg:items-center">
        {/* Left: copy */}
        <div className="flex flex-col gap-6">
          <SpecLabel index="01" label="Skill Marketplace" />

          <h1
            className="max-w-[560px] text-5xl font-semibold leading-[1.05] tracking-tight"
            style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-inkDeep)" }}
          >
            Learn to build with AI.
            <br />
            Not just watch it.
          </h1>

          <p
            className="max-w-[460px] text-lg leading-7"
            style={{ fontFamily: "var(--token-font-bodyFamily)", color: "var(--token-color-inkDeepSoft)" }}
          >
            Practical, outcome-verified AI courses — automations, chatbots, AI-assisted apps —
            taught by people who ship them. No filler, just the skill and the proof you learned it.
          </p>

          <div className="flex items-center gap-4 pt-2">
            <Link
              href="/courses"
              className="px-8 py-3.5 text-sm font-semibold tracking-wide"
              style={{ backgroundColor: "var(--token-color-amber)", color: "var(--token-color-inkDeep)" }}
            >
              Explore Courses
            </Link>
            <Link
              href="/become-instructor"
              className="border px-8 py-3.5 text-sm font-semibold tracking-wide"
              style={{ borderColor: "var(--token-color-inkDeep)", color: "var(--token-color-inkDeep)" }}
            >
              Teach a Skill
            </Link>
          </div>

          {/* Build log ticker -- signature outcome-proof element */}
          <div
            className="mt-4 flex flex-col gap-1.5 border-t pt-4"
            style={{ borderColor: "var(--token-color-blueprintLineSoft)", fontFamily: "var(--token-font-monoFamily)" }}
          >
            {buildLog.map((line) => (
              <div key={line} className="flex items-center gap-2 text-xs" style={{ color: "var(--token-color-inkDeepSoft)" }}>
                <span style={{ color: "var(--token-color-teal)" }}>&#10003;</span>
                {line}
              </div>
            ))}
          </div>
        </div>

        {/* Right: "spec card" -- a labeled artifact instead of a stock photo */}
        <div
          className="relative border p-8"
          style={{ borderColor: "var(--token-color-blueprintLine)", backgroundColor: "var(--token-color-surface)" }}
        >
          <BlueprintMark className="absolute -left-2.5 -top-2.5" />
          <BlueprintMark className="absolute -right-2.5 -top-2.5" />
          <BlueprintMark className="absolute -bottom-2.5 -left-2.5" />
          <BlueprintMark className="absolute -bottom-2.5 -right-2.5" />

          <div className="flex items-center justify-between border-b pb-4" style={{ borderColor: "var(--token-color-blueprintLineSoft)" }}>
            <span
              className="text-xs font-semibold uppercase tracking-[0.12em]"
              style={{ color: "var(--token-color-inkDeepSoft)" }}
            >
              Course Spec
            </span>
            <span
              className="px-2 py-0.5 text-[10px] font-bold uppercase tracking-wide"
              style={{ backgroundColor: "var(--token-color-tealTint)", color: "var(--token-color-teal)" }}
            >
              Verified Outcome
            </span>
          </div>

          <h3
            className="pt-5 text-2xl font-semibold leading-8"
            style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-inkDeep)" }}
          >
            WhatsApp AI Auto-Responder for Small Business
          </h3>

          <div className="mt-6 grid grid-cols-2 gap-4" style={{ fontFamily: "var(--token-font-monoFamily)" }}>
            <SpecRow label="Duration" value="6h 40m" />
            <SpecRow label="Level" value="Intermediate" />
            <SpecRow label="Modules" value="9" />
            <SpecRow label="Completion" value="94%" />
          </div>

          <div className="mt-6 flex items-center justify-between border-t pt-5" style={{ borderColor: "var(--token-color-blueprintLineSoft)" }}>
            <span
              className="text-2xl font-semibold"
              style={{ fontFamily: "var(--token-font-monoFamily)", color: "var(--token-color-inkDeep)" }}
            >
              Rs 4,999
            </span>
            <Link
              href="/courses/whatsapp-ai-auto-responder"
              className="px-5 py-2 text-xs font-semibold tracking-wide"
              style={{ backgroundColor: "var(--token-color-inkDeep)", color: "var(--token-color-paper)" }}
            >
              View Course
            </Link>
          </div>
        </div>
      </div>
    </section>
  );
}

function SpecRow({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex flex-col gap-0.5">
      <span className="text-[10px] uppercase tracking-wide" style={{ color: "var(--token-color-inkDeepSoft)" }}>
        {label}
      </span>
      <span className="text-sm font-medium" style={{ color: "var(--token-color-inkDeep)" }}>
        {value}
      </span>
    </div>
  );
}
'@
Write-FileB64 -Path $heroPath -Content $heroContent

Write-Host ""
Write-Host "Step 1 done: tokens, fonts, Header, Hero, BlueprintMark refactored."
Write-Host "Next: TrendingCourses / CategoryGrid / WhySaachi / Newsletter / Footer in the same system."