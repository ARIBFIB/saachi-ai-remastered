import Link from "next/link";
import { Star } from "lucide-react";
import { cn } from "../cn";

export type CourseCardProps = {
  slug: string;
  title: string;
  thumbnailUrl?: string;
  instructorName: string;
  price: number;
  currency?: string;
  rating: number;
  ratingCount: number;
  className?: string;
};

export function CourseCard({
  slug,
  title,
  thumbnailUrl,
  instructorName,
  price,
  currency = "USD",
  rating,
  ratingCount,
  className
}: CourseCardProps) {
  const formattedPrice = new Intl.NumberFormat("en-US", {
    style: "currency",
    currency,
    minimumFractionDigits: price % 1 === 0 ? 0 : 2
  }).format(price);

  return (
    <Link
      href={`/courses/${slug}`}
      className={cn(
        "group flex flex-col overflow-hidden rounded-2xl border bg-[var(--surface-card,#FFFFFF)]",
        "border-[var(--border-hairline,rgba(15,23,42,0.08))] shadow-[0_2px_8px_rgba(30,64,175,0.06)]",
        "transition-all duration-200 ease-out hover:-translate-y-0.5 hover:shadow-[0_4px_20px_rgba(30,64,175,0.10)] hover:border-[rgba(59,130,246,0.35)]",
        className
      )}
    >
      <div className="relative aspect-video w-full overflow-hidden bg-[var(--surface-elevated,#F1F5F9)]">
        {thumbnailUrl ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={thumbnailUrl}
            alt={title}
            className="h-full w-full object-cover transition-transform duration-300 ease-out group-hover:scale-[1.02]"
          />
        ) : (
          <div className="flex h-full w-full items-center justify-center text-[13px] text-[var(--text-muted,#94A3B8)]">
            No preview
          </div>
        )}
      </div>

      <div className="flex flex-1 flex-col gap-2 p-4">
        <h3 className="line-clamp-2 text-[15px] font-semibold leading-snug text-[var(--text-primary,#0F172A)]">
          {title}
        </h3>
        <p className="text-[13px] text-[var(--text-secondary,#475569)]">{instructorName}</p>

        <div className="flex items-center gap-1.5 text-[13px]">
          <Star size={14} className="fill-[var(--blue-500,#3B82F6)] text-[var(--blue-500,#3B82F6)]" />
          <span className="font-semibold text-[var(--text-primary,#0F172A)]">{rating.toFixed(1)}</span>
          <span className="text-[var(--text-muted,#94A3B8)]">({ratingCount.toLocaleString()})</span>
        </div>

        <div className="mt-auto pt-2 text-[17px] font-bold text-[var(--text-primary,#0F172A)]">
          {formattedPrice}
        </div>
      </div>
    </Link>
  );
}
