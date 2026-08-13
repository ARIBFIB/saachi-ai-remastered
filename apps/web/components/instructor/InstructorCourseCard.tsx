import Image from "next/image";
import { Star } from "lucide-react";

export interface InstructorCourseCardProps {
  title: string;
  description: string;
  category: string;
  price: string;
  rating: number;
  reviews: string;
  duration: string;
  image: string;
  badge?: { label: string; variant: "light" | "dark" };
}

export function InstructorCourseCard({
  title,
  description,
  category,
  price,
  rating,
  reviews,
  duration,
  image,
  badge,
}: InstructorCourseCardProps) {
  return (
    <article className="flex w-96 flex-col overflow-hidden rounded-[var(--token-radius-lg)] border-2 border-[var(--token-color-border)]/30 bg-[var(--token-color-surface)] shadow-[var(--token-shadow-sm)]">
      <div className="relative h-48 w-full bg-[var(--token-color-surfaceAlt)]">
        <Image src={image} alt={title} fill sizes="384px" className="object-cover" />
        {badge && (
          <span
            className={`absolute right-4 top-4 rounded-sm px-2 pb-1 pt-[3px] text-xs font-bold ${
              badge.variant === "dark"
                ? "bg-[var(--token-color-success)] text-white"
                : "bg-[var(--token-color-surface)]/90 text-[var(--token-color-ink)] backdrop-blur-[2px]"
            }`}
          >
            {badge.label}
          </span>
        )}
      </div>

      <div className="flex flex-col gap-4 p-6">
        <div className="flex items-center justify-between">
          <span className="text-xs font-medium uppercase tracking-wide text-[var(--token-color-amber)]">
            {category}
          </span>
          <span className="text-sm font-bold tracking-wide text-[var(--token-color-ink)]">{price}</span>
        </div>

        <div className="flex flex-col gap-2">
          <h3 className="line-clamp-2 text-lg font-semibold leading-7 text-[var(--token-color-ink)]">
            {title}
          </h3>
          <p className="line-clamp-2 text-base text-[var(--token-color-inkSoft)]">{description}</p>
        </div>

        <div className="flex items-center gap-2">
          <Star className="h-3.5 w-3.5 text-[var(--token-color-warning)]" fill="currentColor" strokeWidth={0} />
          <span className="text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">
            {rating} <span className="text-[var(--token-color-inkSoft)]">({reviews})</span>
          </span>
          <span className="text-[var(--token-color-inkSoft)]">&bull;</span>
          <span className="text-xs font-medium text-[var(--token-color-inkSoft)]">{duration} Total</span>
        </div>

        <button
          type="button"
          className="w-full rounded-[var(--token-radius-md)] border-2 border-[var(--token-color-border)] bg-[var(--token-color-surfaceAlt)] py-2 text-sm font-semibold tracking-wide text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-border)]/20"
        >
          View Course
        </button>
      </div>
    </article>
  );
}