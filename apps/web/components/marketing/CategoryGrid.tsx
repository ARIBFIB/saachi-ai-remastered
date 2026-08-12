import Link from "next/link";
import { MessageSquare, Eye, Bot, LineChart } from "lucide-react";
import { SpecLabel } from "./BlueprintMark";

const categories = [
  { label: "NLP & Language", icon: MessageSquare, href: "/categories/nlp" },
  { label: "Computer Vision", icon: Eye, href: "/categories/computer-vision" },
  { label: "Automation & Workflows", icon: Bot, href: "/categories/robotics" },
  { label: "AI Strategy", icon: LineChart, href: "/categories/ai-strategy" },
];

export function CategoryGrid() {
  return (
    <section className="w-full border-y py-16" style={{ borderColor: "var(--token-color-blueprintLineSoft)", backgroundColor: "var(--token-color-surface)" }}>
      <div className="mx-auto flex max-w-[1280px] flex-col gap-10 px-6">
        <div className="flex flex-col gap-3">
          <SpecLabel index="03" label="Categories" />
          <h2
            className="text-3xl font-semibold"
            style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-inkDeep)" }}
          >
            Pick a track, not a rabbit hole
          </h2>
        </div>

        <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
          {categories.map(({ label, icon: Icon, href }) => (
            <Link
              key={label}
              href={href}
              className="group flex flex-col items-start gap-6 border p-6 transition-colors"
              style={{ borderColor: "var(--token-color-blueprintLine)" }}
            >
              <span
                className="flex h-11 w-11 items-center justify-center transition-colors group-hover:text-white"
                style={{ backgroundColor: "var(--token-color-amberTint)" }}
              >
                <Icon className="h-5 w-5" style={{ color: "var(--token-color-amberDark)" }} />
              </span>
              <span
                className="text-sm font-semibold leading-5"
                style={{ fontFamily: "var(--token-font-bodyFamily)", color: "var(--token-color-inkDeep)" }}
              >
                {label}
              </span>
            </Link>
          ))}
        </div>
      </div>
    </section>
  );
}