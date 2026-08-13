import { GraduationCap, Wrench, BadgeCheck } from "lucide-react";
import { SpecLabel } from "./BlueprintMark";

const reasons = [
  {
    icon: GraduationCap,
    title: "Taught by people who ship",
    description:
      "Instructors are practitioners with real, demonstrable work -- not narrators reading slides.",
  },
  {
    icon: Wrench,
    title: "Hands-on, from lesson one",
    description:
      "Every course ends in a working artifact: a bot, an automation, a deployed feature.",
  },
  {
    icon: BadgeCheck,
    title: "Verified, not just watched",
    description:
      "Certificates carry a verification ID tied to actual completion, not video runtime.",
  },
];

export function WhySaachi() {
  return (
    <section className="w-full py-16" style={{ backgroundColor: "var(--token-color-bg)" }}>
      <div className="mx-auto flex max-w-[1280px] flex-col gap-10 px-6">
        <div className="flex flex-col gap-3">
          <SpecLabel index="04" label="Why Saachi" />
          <h2
            className="text-3xl font-semibold"
            style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-inkDeep)" }}
          >
            Built for outcomes, not watch-time
          </h2>
        </div>

        <div className="grid grid-cols-1 gap-6 sm:grid-cols-3">
          {reasons.map(({ icon: Icon, title, description }) => (
            <div
              key={title}
              className="flex flex-col gap-4 border-t-2 p-6"
              style={{ borderColor: "var(--token-color-teal)", backgroundColor: "var(--token-color-surface)" }}
            >
              <Icon className="h-6 w-6" style={{ color: "var(--token-color-teal)" }} />
              <h3
                className="text-lg font-semibold"
                style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-inkDeep)" }}
              >
                {title}
              </h3>
              <p className="text-sm leading-6" style={{ color: "var(--token-color-inkDeepSoft)" }}>
                {description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}