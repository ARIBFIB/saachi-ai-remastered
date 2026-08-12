import Image from "next/image";
import { Star } from "lucide-react";

export interface CourseCardProps {
  title: string;
  instructor: string;
  rating: number;
  reviews: string;
  tag: string;
  tagVariant?: "default" | "highlight" | "neutral";
  image: string;
}

export function CourseCard({
  title,
  instructor,
  rating,
  reviews,
  tag,
  image,
}: CourseCardProps) {
  return (
    <article
      className="group flex flex-1 flex-col overflow-hidden border transition-colors"
      style={{ borderColor: "var(--token-color-blueprintLine)", backgroundColor: "var(--token-color-surface)" }}
    >
      <div className="relative h-40 w-full overflow-hidden" style={{ backgroundColor: "var(--token-color-blueprintLineSoft)" }}>
        <Image
          src={image}
          alt={title}
          fill
          sizes="(max-width: 768px) 100vw, 288px"
          className="object-cover transition-transform duration-300 group-hover:scale-[1.03]"
        />
        <span
          className="absolute left-0 top-0 px-2.5 py-1 text-[10px] font-semibold uppercase tracking-wide"
          style={{ backgroundColor: "var(--token-color-inkDeep)", color: "var(--token-color-paper)" }}
        >
          {tag}
        </span>
      </div>

      <div className="flex flex-col gap-3 border-t p-5" style={{ borderColor: "var(--token-color-blueprintLineSoft)" }}>
        <h3
          className="line-clamp-2 text-lg font-semibold leading-6"
          style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-inkDeep)" }}
        >
          {title}
        </h3>

        <p className="text-sm" style={{ color: "var(--token-color-inkDeepSoft)" }}>
          {instructor}
        </p>

        <div
          className="flex items-center justify-between border-t pt-3"
          style={{ borderColor: "var(--token-color-blueprintLineSoft)", fontFamily: "var(--token-font-monoFamily)" }}
        >
          <div className="flex items-center gap-1.5">
            <Star className="h-3.5 w-3.5" style={{ color: "var(--token-color-amberDark)" }} fill="currentColor" strokeWidth={0} />
            <span className="text-sm font-medium" style={{ color: "var(--token-color-inkDeep)" }}>
              {rating}
            </span>
            <span className="text-xs" style={{ color: "var(--token-color-inkDeepSoft)" }}>
              ({reviews})
            </span>
          </div>
        </div>
      </div>
    </article>
  );
}