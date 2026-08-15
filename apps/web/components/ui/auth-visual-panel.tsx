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