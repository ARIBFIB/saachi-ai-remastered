import Link from "next/link";
import { MessageSquare, Eye, Bot, LineChart } from "lucide-react";

const categories = [
  { label: "NLP & Language", icon: MessageSquare, href: "/categories/nlp" },
  { label: "Computer Vision", icon: Eye, href: "/categories/computer-vision" },
  { label: "Robotics", icon: Bot, href: "/categories/robotics" },
  { label: "AI Strategy", icon: LineChart, href: "/categories/ai-strategy" },
];

export function CategoryGrid() {
  return (
    <section className="w-full border-b border-t border-[#CBD5E1] bg-[#FFFFFF] py-12">
      <div className="mx-auto flex max-w-[1280px] flex-col gap-10 px-6">
        <div className="mx-auto flex max-w-[672px] flex-col items-center gap-2 text-center">
          <h2 className="text-2xl font-semibold text-[#18181B]">
            Explore by Category
          </h2>
          <p className="text-base text-[#3F3F46]">
            Find specialized tracks tailored to your career goals.
          </p>
        </div>

        <div className="flex justify-center gap-4">
          {categories.map(({ label, icon: Icon, href }) => (
            <Link
              key={label}
              href={href}
              className="flex flex-1 flex-col items-center gap-3.5 rounded-xl border border-[#CBD5E1] bg-[#F8FAFC] p-10 transition hover:border-[#3525CD]"
            >
              <span className="flex h-16 w-16 items-center justify-center rounded-full bg-[#3525CD]/10">
                <Icon className="h-7 w-7 text-[#3525CD]" />
              </span>
              <span className="text-sm font-semibold tracking-wide text-[#18181B]">
                {label}
              </span>
            </Link>
          ))}
        </div>
      </div>
    </section>
  );
}
