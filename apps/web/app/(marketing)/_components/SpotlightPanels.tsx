"use client";

import Link from "next/link";
import { GraduationCap, Users, Building2 } from "lucide-react";
import { BorderBeamPanel } from "@/components/ui/border-beam-panel";

const PANELS = [
  {
    icon: GraduationCap,
    tag: "Certification",
    title: "AI Automation Track",
    desc: "A guided path through automation, prompt engineering, and agent-building -- finish with a verified certificate.",
    cta: "Explore track",
    href: "/courses",
    colors: ["#7c3aed", "#ec4899"] as [string, string]
  },
  {
    icon: Users,
    tag: "1-on-1",
    title: "Mentorship Sessions",
    desc: "Book paid sessions directly with verified instructors for code review, feedback, or career advice.",
    cta: "Book a mentor",
    href: "/mentorship",
    colors: ["#c026d3", "#22c7d9"] as [string, string]
  },
  {
    icon: Building2,
    tag: "For teams",
    title: "Saachi AI Business",
    desc: "Bulk seat licenses, team dashboards, and custom invoicing for organizations upskilling at scale.",
    cta: "Talk to sales",
    href: "/contact",
    colors: ["#009fb3", "#7c3aed"] as [string, string]
  }
];

export function SpotlightPanels() {
  return (
    <div className="grid grid-cols-1 gap-5 md:grid-cols-3">
      {PANELS.map((p) => (
        <BorderBeamPanel key={p.title} beams={2} thickness={2} radius={18} colors={p.colors} className="!bg-card !border-line">
          <div className="flex flex-col gap-4">
            <span className="flex w-fit items-center gap-1.5 rounded-full border border-line px-2.5 py-0.5 text-[10px] font-semibold uppercase tracking-[0.14em] text-ink-soft">
              <p.icon size={12} />
              {p.tag}
            </span>
            <h3 className="font-display text-[20px] font-semibold text-ink">{p.title}</h3>
            <p className="text-[13.5px] leading-relaxed text-ink-soft">{p.desc}</p>
            <Link
              href={p.href}
              className="mt-1 w-fit rounded-lg bg-ink px-4 py-2 text-[13px] font-medium text-paper transition-opacity hover:opacity-90"
            >
              {p.cta}
            </Link>
          </div>
        </BorderBeamPanel>
      ))}
    </div>
  );
}