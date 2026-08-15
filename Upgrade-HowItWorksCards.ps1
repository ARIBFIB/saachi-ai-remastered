# Upgrade-HowItWorksCards.ps1
# Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Content
    )
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

$root = (Get-Location).Path
$webApp = Join-Path -Path $root -ChildPath "apps\web"
$howItWorksPath = Join-Path -Path $webApp -ChildPath "components\ui\how-it-works.tsx"

if (-not (Test-Path $howItWorksPath)) {
    Write-Host "ERROR: $howItWorksPath not found. Run from SAI2 repo root." -ForegroundColor Red
    exit 1
}

$content = @'
"use client";

import React, { useState } from "react";
import Link from "next/link";
import { LazyMotion, domAnimation, m, AnimatePresence } from "motion/react";
import { Info, ArrowUpRight } from "lucide-react";

interface CardProps {
  number: string;
  title: string;
  description: string;
  detail?: string;
  ctaLabel?: string;
  ctaHref?: string;
  className?: string;
  rotate?: string;
  colors?: { bg: string; text: string; border: string };
}

const Pin = ({ className }: { className?: string }) => (
  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="currentColor" className={className}>
    <path stroke="none" d="M0 0h24v24H0z" fill="none" />
    <path d="M16 3a1 1 0 0 1 .117 1.993l-.117 .007v4.764l1.894 3.789a1 1 0 0 1 .1 .331l.006 .116v2a1 1 0 0 1 -.883 .993l-.117 .007h-4v4a1 1 0 0 1 -1.993 .117l-.007 -.117v-4h-4a1 1 0 0 1 -.993 -.883l-.007 -.117v-2a1 1 0 0 1 .06 -.34l.046 -.107l1.894 -3.791v-4.762a1 1 0 0 1 -.117 -1.993l.117 -.007h8z" />
  </svg>
);

const DEFAULT_PALETTE = { bg: "bg-gold-tint", text: "text-accent-violet", border: "border-line-strong" };

const Card = ({ number, title, description, detail, ctaLabel, ctaHref, className, rotate, colors }: CardProps) => {
  const c = colors ?? DEFAULT_PALETTE;
  const [showDetail, setShowDetail] = useState(false);

  return (
    <div className={`relative w-full md:w-[300px] transition-transform duration-300 hover:z-30 hover:scale-105 ${rotate ?? ""} ${className ?? ""}`}>
      <div className="bg-card p-2 rounded-[25px] shadow-[0px_10px_20px_0px_rgba(124,58,237,0.12)] border border-line">
        <Pin className={`w-8 h-8 ${c.text} z-20 mb-6 mx-auto`} />

        <div className={`${c.bg} border ${c.border} rounded-[15px] p-[18px] h-full flex flex-col relative overflow-hidden`}>
          <div className="mb-4 flex items-start justify-between">
            <span className={`${c.text} font-display text-4xl font-bold leading-none`}>{number}</span>

            {detail && (
              <button
                type="button"
                onClick={() => setShowDetail((v) => !v)}
                onMouseEnter={() => setShowDetail(true)}
                onMouseLeave={() => setShowDetail(false)}
                aria-label="More details"
                className={`flex h-7 w-7 shrink-0 items-center justify-center rounded-full border ${c.border} bg-card/70 ${c.text} transition-transform duration-200 hover:scale-110`}
              >
                <Info size={14} strokeWidth={2.25} />
              </button>
            )}
          </div>

          <h3 className="font-display text-[22px] font-semibold tracking-[-0.01em] text-ink leading-tight mb-2.5">
            {title}
          </h3>
          <p className="text-ink-soft text-[14px]/[1.55] tracking-tight mb-5">{description}</p>

          {ctaLabel && ctaHref && (
            <Link
              href={ctaHref}
              className={`mt-auto inline-flex w-fit items-center gap-1.5 rounded-full border ${c.border} px-3.5 py-1.5 text-[12.5px] font-semibold ${c.text} transition-all duration-200 hover:gap-2.5 hover:bg-card`}
            >
              {ctaLabel}
              <ArrowUpRight size={13} />
            </Link>
          )}

          <AnimatePresence>
            {showDetail && detail && (
              <m.div
                initial={{ opacity: 0, y: 8 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: 8 }}
                transition={{ duration: 0.18, ease: "easeOut" }}
                className="absolute inset-x-2 bottom-2 z-10 rounded-[12px] border border-line bg-card/98 p-4 text-[13px] leading-relaxed text-ink shadow-lg backdrop-blur-sm"
              >
                {detail}
              </m.div>
            )}
          </AnimatePresence>
        </div>
      </div>
    </div>
  );
};

export interface Step {
  title: string;
  description: string;
  detail?: string;
  ctaLabel?: string;
  ctaHref?: string;
  colors?: { bg: string; text: string; border: string };
}

export interface StepPosition {
  className?: string;
  rotate?: string;
}

export interface HowItWorksProps {
  features?: Step[];
  className?: string;
  stepPositions?: StepPosition[];
}

const DEFAULT_CARD_POSITIONS: StepPosition[] = [
  { className: "md:absolute md:top-0 md:left-[15%]", rotate: "rotate-8" },
  { className: "md:absolute md:top-[120px] md:right-[15%]", rotate: "-rotate-8" },
  { className: "md:absolute md:top-[450px] md:left-[15%]", rotate: "rotate-8" },
  { className: "md:absolute md:top-[570px] md:right-[10%]", rotate: "-rotate-8" },
  { className: "md:absolute md:top-[850px] md:left-[15%]", rotate: "rotate-8" }
];

export default function HowItWorks({ features, className, stepPositions }: HowItWorksProps) {
  const defaultFeatures: Step[] = [
    {
      title: "Create account",
      description: "Sign up in minutes and pick learner or instructor.",
      detail: "No credit card required to sign up. Choose learner to start browsing courses instantly, or apply as an instructor - approval usually takes 2-3 business days.",
      ctaLabel: "Sign up",
      ctaHref: "/register"
    },
    {
      title: "Pick a skill",
      description: "Browse 1,200+ practical AI courses across every category.",
      detail: "Filter by category, skill level, and language. Every course shows real student ratings and a full curriculum preview before you buy.",
      ctaLabel: "Browse courses",
      ctaHref: "/courses"
    },
    {
      title: "Learn by building",
      description: "Every course ships real templates and projects, not just video.",
      detail: "Each module includes downloadable templates, starter files, and step-by-step project walkthroughs you can reuse on real client work.",
      ctaLabel: "See how it works",
      ctaHref: "/courses"
    },
    {
      title: "Get certified",
      description: "Finish a course and earn a shareable completion certificate.",
      detail: "Certificates include a unique verification ID that anyone can check, and can be added directly to LinkedIn with one click.",
      ctaLabel: "View certificates",
      ctaHref: "/certificates"
    },
    {
      title: "Earn or teach",
      description: "Turn what you learned into freelance work, or publish your own course.",
      detail: "Apply to become an instructor from your dashboard anytime. Instructors set their own pricing and keep the majority of every sale.",
      ctaLabel: "Become an instructor",
      ctaHref: "/register"
    }
  ];

  const data = features && features.length > 0 ? features : defaultFeatures;
  const positions = stepPositions || DEFAULT_CARD_POSITIONS;

  let height = 1130;
  if (data.length === 1) height = 400;
  else if (data.length === 2) height = 450;
  else if (data.length === 3) height = 800;
  else if (data.length === 4) height = 900;
  else height = 1130;

  return (
    <LazyMotion features={domAnimation}>
      <div className={`bg-paper max-md:pt-10 max-md:pb-25 md:py-20 px-8 relative ${className ?? ""}`}>
        <div
          className="absolute inset-0 pointer-events-none opacity-[0.06]"
          style={{ backgroundImage: "linear-gradient(var(--color-ink) 1px, transparent 1px)", backgroundSize: "100% 32px", marginTop: "4px" }}
        />
        <div className="from-paper pointer-events-none absolute inset-y-0 left-0 w-1/2 bg-gradient-to-r" />
        <div className="from-paper pointer-events-none absolute inset-y-0 right-0 w-1/2 bg-gradient-to-l" />

        <div className="max-w-6xl mx-auto relative z-10">
          <div className="mb-14 text-center md:mb-20">
            <span className="mb-3 inline-block rounded-full border border-line bg-card px-3.5 py-1.5 text-[12.5px] font-semibold text-accent-violet">
              How it works
            </span>
            <h2 className="font-display text-[28px] font-bold tracking-[-0.02em] text-ink md:text-[38px]">
              From sign-up to shipped project
            </h2>
            <p className="mx-auto mt-3 max-w-md text-[14.5px] text-ink-soft">
              Five steps, no fluff. Tap the info icon on each card for more detail.
            </p>
          </div>

          <div
            className="relative w-full max-w-[1000px] mx-auto flex flex-col space-y-8 md:space-y-0 md:block h-auto md:h-[var(--md-height)]"
            style={{ "--md-height": `${height}px` } as React.CSSProperties}
          >
            {data.length > 1 && (
              <svg className="absolute top-0 left-0 w-full h-full pointer-events-none hidden md:block z-0" viewBox={`0 0 1000 ${height}`} preserveAspectRatio="none">
                {(() => {
                  const pathD = data.reduce((acc, _, index) => {
                    if (index >= data.length - 1) return acc;
                    if (index === 0) return "M 290 150 C 500 150, 550 270, 710 270";
                    if (index === 1) return acc + " C 850 270, 500 350, 290 450";
                    if (index === 2) return acc + " C 290 600, 550 720, 750 720";
                    if (index === 3) return acc + " C 950 720, 500 800, 290 850";
                    return acc;
                  }, "");
                  return (
                    <m.path
                      d={pathD}
                      stroke="currentColor"
                      className="text-line-strong"
                      strokeWidth="2"
                      strokeDasharray="8 6"
                      fill="none"
                      strokeLinecap="round"
                      vectorEffect="non-scaling-stroke"
                      initial={{ strokeDashoffset: 0 }}
                      animate={{ strokeDashoffset: -140 }}
                      transition={{ duration: 3, repeat: Infinity, ease: "linear" }}
                    />
                  );
                })()}
              </svg>
            )}

            {data.map((step, index) => {
              const position = positions[index % positions.length];
              return (
                <Card
                  key={step.title}
                  number={`0${index + 1}`}
                  title={step.title}
                  description={step.description}
                  detail={step.detail}
                  ctaLabel={step.ctaLabel}
                  ctaHref={step.ctaHref}
                  colors={step.colors}
                  rotate={position.rotate}
                  className={position.className}
                />
              );
            })}
          </div>
        </div>
      </div>
    </LazyMotion>
  );
}
'@

Write-Utf8NoBom -Path $howItWorksPath -Content $content
Write-Host "Updated: $howItWorksPath" -ForegroundColor Green

Write-Host "`nDone. cd apps\web ; pnpm run build (or pnpm dev) to verify." -ForegroundColor Cyan