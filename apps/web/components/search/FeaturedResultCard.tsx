import Image from "next/image";
import { GraduationCap, Star } from "lucide-react";

export interface FeaturedResultCardProps {
  badge?: string;
  pathLabel: string;
  title: string;
  description: string;
  instructorName: string;
  instructorAvatar: string;
  rating: number;
  reviews: string;
  image: string;
}

export function FeaturedResultCard({
  badge,
  pathLabel,
  title,
  description,
  instructorName,
  instructorAvatar,
  rating,
  reviews,
  image,
}: FeaturedResultCardProps) {
  return (
    <article className="flex h-96 overflow-hidden rounded-xl border-2 border-[var(--token-color-border)] bg-[var(--token-color-surface)] shadow-[var(--token-shadow-[var(--token-shadow-sm)])]">
      <div className="relative w-80 shrink-0">
        <Image src={image} alt={title} fill sizes="320px" className="object-cover" />
        {badge && (
          <span className="absolute left-4 top-4 bg-[var(--token-color-primary)] px-2 pb-1 pt-[3px] text-xs font-medium text-white">
            {badge}
          </span>
        )}
      </div>

      <div className="flex flex-1 flex-col justify-between p-6">
        <div className="flex flex-col gap-2 pb-4">
          <div className="flex items-center gap-1">
            <GraduationCap className="h-3 w-3.5 text-[var(--token-color-inkSoft)]" />
            <span className="text-xs font-medium text-[var(--token-color-inkSoft)]">{pathLabel}</span>
          </div>
          <h2 className="text-2xl font-semibold leading-8 text-[var(--token-color-ink)]">{title}</h2>
          <p className="text-base leading-6 text-[var(--token-color-inkSoft)]">{description}</p>
        </div>

        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className="relative block h-8 w-8 overflow-hidden rounded-full">
              <Image src={instructorAvatar} alt={instructorName} fill sizes="32px" className="object-cover" />
            </span>
            <span className="text-xs font-medium text-[var(--token-color-inkSoft)]">{instructorName}</span>
          </div>

          <div className="flex items-center gap-1">
            <Star className="h-3.5 w-3.5 text-[var(--token-color-primary)]" fill="currentColor" strokeWidth={0} />
            <span className="text-xs font-bold text-[var(--token-color-primary)]">
              {rating} ({reviews})
            </span>
          </div>
        </div>
      </div>
    </article>
  );
}