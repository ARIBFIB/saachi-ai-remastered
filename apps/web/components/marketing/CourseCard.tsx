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

const tagStyles: Record<NonNullable<CourseCardProps["tagVariant"]>, string> = {
  default: "bg-[#E0E7FF] text-gray-500",
  highlight: "bg-[#3525CD]/10 text-[#3525CD]",
  neutral: "bg-zinc-200 text-zinc-900",
};

export function CourseCard({
  title,
  instructor,
  rating,
  reviews,
  tag,
  tagVariant = "default",
  image,
}: CourseCardProps) {
  return (
    <article className="flex flex-1 flex-col overflow-hidden rounded-xl bg-[#FFFFFF] shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
      <div className="relative h-40 w-full overflow-hidden bg-gray-100">
        <Image
          src={image}
          alt={title}
          fill
          sizes="(max-width: 768px) 100vw, 288px"
          className="object-cover"
        />
      </div>

      <div className="flex flex-col gap-4 p-6">
        <span
          className={`inline-block w-fit rounded-sm px-2 pb-1 pt-[3px] text-xs font-medium ${tagStyles[tagVariant]}`}
        >
          {tag}
        </span>

        <h3 className="text-2xl font-semibold leading-8 text-[#18181B]">
          {title}
        </h3>

        <div className="flex flex-col gap-1">
          <p className="text-sm text-[#3F3F46]">{instructor}</p>
          <div className="flex items-center gap-2">
            <div className="flex items-center gap-1">
              <Star className="h-3.5 w-3.5 text-[#005338]" fill="currentColor" strokeWidth={0} />
              <span className="text-sm font-semibold tracking-wide text-[#005338]">
                {rating}
              </span>
            </div>
            <span className="text-sm text-gray-500">({reviews} reviews)</span>
          </div>
        </div>
      </div>
    </article>
  );
}
