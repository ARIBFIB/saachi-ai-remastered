import Image from "next/image";
import { Star, Play } from "lucide-react";

interface CourseHeroProps {
  category: string;
  levelBadge: string;
  title: string;
  description: string;
  rating: number;
  ratingsCount: string;
  studentsCount: string;
  instructorName: string;
  instructorAvatar: string;
  previewImage: string;
}

export function CourseHero({
  category,
  levelBadge,
  title,
  description,
  rating,
  ratingsCount,
  studentsCount,
  instructorName,
  instructorAvatar,
  previewImage,
}: CourseHeroProps) {
  return (
    <section className="w-full bg-gray-100 px-6 py-12">
      <div className="mx-auto flex max-w-[1280px] flex-col gap-6 lg:flex-row lg:items-start">
        <div className="flex flex-1 flex-col gap-6">
          <div className="flex items-start gap-2">
            <span className="rounded-sm bg-[#E0E7FF] px-2 pb-1 pt-[3px] text-xs font-medium text-gray-500">
              {category}
            </span>
            <span className="rounded-sm bg-zinc-200 px-2 pb-1 pt-[3px] text-xs font-medium text-zinc-900">
              {levelBadge}
            </span>
          </div>

          <h1 className="text-5xl font-bold leading-[52.8px] text-zinc-900">
            {title}
          </h1>

          <p className="max-w-[700px] text-lg leading-7 text-gray-700">
            {description}
          </p>

          <div className="flex items-center gap-4">
            <div className="flex items-center gap-1">
              <Star className="h-5 w-5 text-[#005338]" fill="currentColor" strokeWidth={0} />
              <span className="text-base font-bold text-emerald-900">{rating}</span>
              <span className="pl-1 text-base text-gray-700">({ratingsCount} ratings)</span>
            </div>
            <span className="text-gray-700">•</span>
            <span className="text-base text-gray-700">{studentsCount} Students Enrolled</span>
          </div>

          <div className="flex items-center gap-3">
            <span className="relative block h-10 w-10 overflow-hidden rounded-full">
              <Image src={instructorAvatar} alt={instructorName} fill sizes="40px" className="object-cover" />
            </span>
            <span className="text-sm font-semibold tracking-wide text-zinc-900">
              Created by {instructorName}
            </span>
          </div>
        </div>

        <div className="w-full lg:w-96">
          <button
            type="button"
            className="group relative block aspect-video w-full overflow-hidden rounded-xl shadow-[var(--token-shadow-sm)]"
          >
            <Image
              src={previewImage}
              alt={`${title} preview`}
              fill
              sizes="(max-width: 1024px) 100vw, 384px"
              className="object-cover"
            />
            <span className="absolute inset-0 bg-zinc-900/20 transition group-hover:bg-zinc-900/30" />
            <span className="absolute inset-0 flex items-center justify-center">
              <span className="flex h-[46px] w-[46px] items-center justify-center rounded-full bg-white shadow-[var(--token-shadow-sm)]">
                <Play className="ml-0.5 h-5 w-5 text-zinc-900" fill="currentColor" />
              </span>
            </span>
          </button>
        </div>
      </div>
    </section>
  );
}
