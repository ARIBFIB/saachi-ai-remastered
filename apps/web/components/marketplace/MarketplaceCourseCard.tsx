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
    <article className="flex flex-1 flex-col overflow-hidden rounded-xl border border-slate-300/30 bg-white shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
      <div className="relative h-40 w-full overflow-hidden bg-zinc-200">
        <Image
          src={image}
          alt={title}
          fill
          sizes="(max-width: 768px) 100vw, 400px"
          className="object-cover"
        />
        {badge && (
          <span
            className={`absolute left-2 top-2 rounded-sm px-2 pb-1 pt-[3px] text-xs font-medium shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)] ${
              badge.variant === "dark"
                ? "bg-emerald-700 text-emerald-300"
                : "bg-white/90 text-zinc-900 backdrop-blur-[2px]"
            }`}
          >
            {badge.label}
          </span>
        )}
      </div>

      <div className="flex flex-1 flex-col justify-between p-6">
        <div className="flex flex-col gap-2">
          <div className="flex items-start gap-2">
            <span className="bg-[#E0E7FF] px-2 pb-[2.39px] pt-px text-xs font-medium text-gray-500">
              {categoryTag}
            </span>
            <span className="bg-gray-200 px-2 pb-[2.39px] pt-px text-xs font-medium text-slate-600">
              {levelTag}
            </span>
          </div>

          <h3 className="line-clamp-2 text-lg font-bold leading-7 text-zinc-900">
            {title}
          </h3>

          <p className="text-sm text-slate-600">{provider}</p>
        </div>

        <div className="mt-4 flex flex-col gap-1">
          <div className="flex items-center gap-1">
            <Star className="h-[15px] w-[15px] text-[#3525CD]" fill="currentColor" strokeWidth={0} />
            <span className="text-sm font-semibold tracking-wide text-zinc-900">
              {rating}
            </span>
            <span className="text-xs font-medium text-gray-500">({reviews})</span>
          </div>

          <div className="flex items-baseline gap-1">
            <span className="text-2xl font-bold text-zinc-900">{price}</span>
            {priceSuffix && (
              <span className="text-base text-slate-600">{priceSuffix}</span>
            )}
          </div>
        </div>
      </div>
    </article>
  );
}
