import Image from "next/image";
import { Star } from "lucide-react";

export interface CategoryCourseCardProps {
  title: string;
  description: string;
  levelTag: string;
  rating: number;
  reviews: string;
  price: string;
  image: string;
}

export function CategoryCourseCard({
  title,
  description,
  levelTag,
  rating,
  reviews,
  price,
  image,
}: CategoryCourseCardProps) {
  return (
    <article className="flex flex-1 flex-col overflow-hidden rounded-xl border-2 border-[var(--token-color-border)]/30 bg-[var(--token-color-surface)] shadow-[var(--token-shadow-[var(--token-shadow-sm)])]">
      <div className="relative h-40 w-full shrink-0 overflow-hidden bg-[var(--token-color-surfaceAlt)]">
        <Image
          src={image}
          alt={title}
          fill
          sizes="(max-width: 768px) 100vw, 320px"
          className="object-cover"
        />
        <span className="absolute right-2 top-2 bg-[var(--token-color-bg)]/90 px-2 pb-1 pt-[3px] text-xs font-medium text-[var(--token-color-ink)] backdrop-blur-[2px]">
          {levelTag}
        </span>
      </div>

      <div className="flex flex-1 flex-col justify-between p-6">
        <div className="flex flex-col gap-1 pb-4">
          <h3 className="line-clamp-2 text-2xl font-semibold leading-8 text-[var(--token-color-ink)]">
            {title}
          </h3>
          <p className="line-clamp-3 text-base text-[var(--token-color-inkSoft)]">
            {description}
          </p>
        </div>

        <div className="flex items-center justify-between border-t border-[var(--token-color-border)]/50 pt-4">
          <div className="flex items-center gap-1">
            <Star className="h-3.5 w-3.5 text-[var(--token-color-textMuted)]" fill="currentColor" strokeWidth={0} />
            <span className="text-xs font-medium text-[var(--token-color-inkSoft)]">
              {rating} ({reviews})
            </span>
          </div>
          <span className="text-sm font-bold tracking-wide text-[var(--token-color-primary)]">
            {price}
          </span>
        </div>
      </div>
    </article>
  );
}