import { ReactNode } from "react";
import Link from "next/link";
import { ArrowRight } from "lucide-react";
import { cn } from "@saachi/ui";

const BentoGrid = ({ children, className }: { children: ReactNode; className?: string }) => {
  return (
    <div className={cn("grid w-full auto-rows-[14rem] grid-cols-1 gap-4 md:auto-rows-[15rem] md:grid-cols-3", className)}>
      {children}
    </div>
  );
};

const BentoCard = ({
  name,
  className,
  Icon,
  description,
  href,
  cta
}: {
  name: string;
  className?: string;
  Icon: any;
  description: string;
  href: string;
  cta: string;
}) => (
  <div
    className={cn(
      "group relative col-span-1 flex flex-col justify-between overflow-hidden rounded-card border border-line bg-card transition-colors hover:border-gold-dark/40",
      className
    )}
  >
    <div className="pointer-events-none z-10 flex flex-col gap-1.5 p-6 transition-transform duration-300 ease-out group-hover:-translate-y-6">
      <Icon size={26} strokeWidth={1.5} className="mb-1 text-gold-dark transition-transform duration-300 ease-out group-hover:scale-90" />
      <h3 className="text-[15px] font-semibold text-ink">{name}</h3>
      <p className="text-[13px] text-ink-soft">{description}</p>
    </div>

    <div className="pointer-events-none absolute bottom-0 flex w-full translate-y-8 items-center p-5 opacity-0 transition-all duration-300 ease-out group-hover:translate-y-0 group-hover:opacity-100">
      <Link href={href} className="pointer-events-auto flex items-center gap-1.5 text-[13px] font-semibold text-gold-dark hover:underline">
        {cta}
        <ArrowRight size={14} />
      </Link>
    </div>
  </div>
);

export { BentoCard, BentoGrid };
