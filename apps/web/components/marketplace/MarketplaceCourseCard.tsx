import Image from "next/image";
import { Star } from "lucide-react";

export interface MarketplaceCourseCardProps {
  title: string;
  provider: string;
  rating: number;
  reviews: string;
  price: string;
  priceSuffix?: string;
  categoryTag: string;
  levelTag: string;
  badge?: { label: string; variant: "dark" | "light" };
  image: string;
}

export function MarketplaceCourseCard({
  title,
  provider,
  rating,
  reviews,
  price,
  priceSuffix,
  categoryTag,
  levelTag,
  badge,
  image,
}: MarketplaceCourseCardProps) {
  return (
    <article className="group flex flex-1 flex-col overflow-hidden border-2" style={{ borderColor: "var(--token-color-blueprintLine)", backgroundColor: "var(--token-color-surface)" }}>
      <div className="relative h-40 w-full overflow-hidden" style={{ backgroundColor: "var(--token-color-blueprintLineSoft)" }}>
        <Image src={image} alt={title} fill sizes="(max-width: 768px) 100vw, 400px" className="object-cover transition-transform duration-300 group-hover:scale-[1.03]" />
        {badge && (
          <span
            className="absolute left-0 top-0 px-2.5 py-1 text-[10px] font-semibold uppercase tracking-wide"
            style={
              badge.variant === "dark"
                ? { backgroundColor: "var(--token-color-teal)", color: "var(--token-color-tealTint)" }
                : { backgroundColor: "var(--token-color-inkDeep)", color: "var(--token-color-paper)" }
            }
          >
            {badge.label}
          </span>
        )}
      </div>

      <div className="flex flex-1 flex-col justify-between p-6">
        <div className="flex flex-col gap-2">
          <div className="flex items-start gap-2" style={{ fontFamily: "var(--token-font-monoFamily)" }}>
            <span className="px-2 py-0.5 text-[10px] font-medium" style={{ backgroundColor: "var(--token-color-amberTint)", color: "var(--token-color-amberDark)" }}>
              {categoryTag}
            </span>
            <span className="px-2 py-0.5 text-[10px] font-medium" style={{ backgroundColor: "var(--token-color-bg)", color: "var(--token-color-inkDeepSoft)" }}>
              {levelTag}
            </span>
          </div>

          <h3
            className="line-clamp-2 text-lg font-semibold leading-7"
            style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-inkDeep)" }}
          >
            {title}
          </h3>

          <p className="text-sm" style={{ color: "var(--token-color-inkDeepSoft)" }}>{provider}</p>
        </div>

        <div className="mt-4 flex flex-col gap-1 border-t pt-4" style={{ borderColor: "var(--token-color-blueprintLineSoft)" }}>
          <div className="flex items-center gap-1">
            <Star className="h-[15px] w-[15px]" style={{ color: "var(--token-color-amberDark)" }} fill="currentColor" strokeWidth={0} />
            <span className="text-sm font-semibold" style={{ color: "var(--token-color-inkDeep)" }}>{rating}</span>
            <span className="text-xs" style={{ color: "var(--token-color-inkDeepSoft)" }}>({reviews})</span>
          </div>

          <div className="flex items-baseline gap-1" style={{ fontFamily: "var(--token-font-monoFamily)" }}>
            <span className="text-2xl font-semibold" style={{ color: "var(--token-color-inkDeep)" }}>{price}</span>
            {priceSuffix && <span className="text-sm" style={{ color: "var(--token-color-inkDeepSoft)" }}>{priceSuffix}</span>}
          </div>
        </div>
      </div>
    </article>
  );
}