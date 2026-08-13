import type { LucideIcon } from "lucide-react";
import { Rocket, Shapes, BrainCircuit, ShieldCheck, Zap } from "lucide-react";

interface Value {
  icon: LucideIcon;
  iconColor: string;
  title: string;
  description: string;
}

const values: Value[] = [
  {
    icon: Shapes,
    iconColor: "var(--token-color-success)",
    title: "Structural Clarity",
    description: "We design systems that organize chaos. Learning is complex; the interface shouldn't be.",
  },
  {
    icon: BrainCircuit,
    iconColor: "var(--token-color-amber)",
    title: "Predictive Insight",
    description: "Anticipating learner bottlenecks before they happen using behavioral data models.",
  },
  {
    icon: ShieldCheck,
    iconColor: "var(--token-color-error)",
    title: "Trust by Design",
    description: "Professional environments require verifiable accuracy and data integrity at every level.",
  },
  {
    icon: Zap,
    iconColor: "var(--token-color-textMuted)",
    title: "Adaptive Velocity",
    description: "Moving at the speed of modern tech without sacrificing foundational knowledge.",
  },
];

interface CoreDirectivesGridProps {
  missionTitle: string;
  missionBody: string;
}

export function CoreDirectivesGrid({ missionTitle, missionBody }: CoreDirectivesGridProps) {
  return (
    <section className="flex w-full flex-col gap-6">
      <h2 className="text-3xl font-bold leading-10 text-[var(--token-color-ink)]">Our Core Directives</h2>

      <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
        <div className="flex flex-col justify-center gap-2 rounded-[var(--token-radius-lg)] border-2 border-[var(--token-color-border)]/30 bg-[var(--token-color-surface)] p-10 shadow-[var(--token-shadow-sm)] md:col-span-2">
          <Rocket className="mb-2 h-[30px] w-[30px] text-[var(--token-color-amber)]" />
          <h3 className="text-2xl font-semibold leading-8 text-[var(--token-color-ink)]">{missionTitle}</h3>
          <p className="max-w-4xl text-base leading-6 text-[var(--token-color-inkSoft)]">{missionBody}</p>
        </div>

        {values.map(({ icon: Icon, iconColor, title, description }) => (
          <div
            key={title}
            className="flex flex-col gap-1 rounded-[var(--token-radius-lg)] border-2 border-[var(--token-color-border)]/30 bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-sm)]"
          >
            <Icon className="h-6 w-6" style={{ color: iconColor }} />
            <h4 className="pt-1 text-lg font-semibold leading-7 text-[var(--token-color-ink)]">{title}</h4>
            <p className="text-sm leading-5 text-[var(--token-color-inkSoft)]">{description}</p>
          </div>
        ))}
      </div>
    </section>
  );
}