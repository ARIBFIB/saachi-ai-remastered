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
        "group flex flex-col overflow-hidden rounded-card border border-line bg-card",
        "transition-all duration-200 ease-out hover:-translate-y-0.5 hover:border-gold-dark/40",
        className
      )}
    >
      <div className="relative aspect-video w-full overflow-hidden bg-paper-dim">
        {thumbnailUrl ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={thumbnailUrl}
            alt={title}
            className="h-full w-full object-cover transition-transform duration-300 ease-out group-hover:scale-[1.02]"
          />
        ) : (
          <div className="flex h-full w-full items-center justify-center text-[13px] text-ink-soft/60">
            No preview
          </div>
        )}
      </div>

      <div className="flex flex-1 flex-col gap-2 p-4">
        <h3 className="line-clamp-2 text-[15px] font-semibold leading-snug text-ink">{title}</h3>
        <p className="text-[13px] text-ink-soft">{instructorName}</p>

        <div className="flex items-center gap-1.5 text-[13px]">
          <Star size={14} className="fill-gold text-gold" />
          <span className="font-semibold text-ink">{rating.toFixed(1)}</span>
          <span className="text-ink-soft/60">({ratingCount.toLocaleString()})</span>
        </div>

        <div className="mt-auto pt-2 font-mono text-[17px] font-semibold text-ink">{formattedPrice}</div>
      </div>
    </Link>
  );
}