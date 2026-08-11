import { GraduationCap, Wrench, BadgeCheck } from "lucide-react";

const reasons = [
  {
    icon: GraduationCap,
    title: "Industry Experts",
    description:
      "Learn directly from senior engineers and researchers from top tech companies.",
  },
  {
    icon: Wrench,
    title: "Hands-on Projects",
    description:
      "Build real-world AI applications in cloud environments straight from your browser.",
  },
  {
    icon: BadgeCheck,
    title: "AI-Verified Certificates",
    description:
      "Earn credentials verified on the blockchain, trusted by top employers globally.",
  },
];

export function WhySaachi() {
  return (
    <section className="w-full bg-[#F8FAFC] pb-20 pt-12">
      <div className="mx-auto flex max-w-[1280px] flex-col gap-10 px-6">
        <h2 className="text-center text-2xl font-semibold text-[#18181B]">
          Why Learn with Saachi?
        </h2>

        <div className="flex justify-center gap-10 pt-6">
          {reasons.map(({ icon: Icon, title, description }) => (
            <div
              key={title}
              className="flex flex-1 flex-col items-center gap-4 p-6 text-center"
            >
              <span className="flex h-12 w-12 items-center justify-center rounded-sm bg-gray-200">
                <Icon className="h-6 w-6 text-[#3525CD]" />
              </span>
              <h3 className="text-lg font-semibold text-[#18181B]">
                {title}
              </h3>
              <p className="max-w-[280px] text-base text-[#3F3F46]">
                {description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
