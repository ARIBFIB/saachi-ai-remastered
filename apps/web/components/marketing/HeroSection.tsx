import Link from "next/link";
import { BlueprintMark, SpecLabel } from "./BlueprintMark";

const buildLog = [
  "Certificate issued â€” Prompt Engineering Masterclass",
  "Course published â€” WhatsApp AI Auto-Responder",
  "Skill verified â€” n8n Workflow Automation",
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
            Practical, outcome-verified AI courses â€” automations, chatbots, AI-assisted apps â€”
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
              className="border-2 px-8 py-3.5 text-sm font-semibold tracking-wide"
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
          className="relative border-2 p-8"
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