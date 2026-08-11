import Image from "next/image";
import { Star, Users } from "lucide-react";

interface InstructorBioProps {
  name: string;
  title: string;
  rating: number;
  studentsCount: string;
  bio: string;
  avatar: string;
}

export function InstructorBio({
  name,
  title,
  rating,
  studentsCount,
  bio,
  avatar,
}: InstructorBioProps) {
  return (
    <section className="flex w-full gap-6 rounded-xl border border-slate-300/30 bg-slate-50 p-6 shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)]">
      <span className="relative block h-32 w-32 shrink-0 overflow-hidden rounded-full">
        <Image src={avatar} alt={name} fill sizes="128px" className="object-cover" />
      </span>

      <div className="flex flex-col">
        <h2 className="text-2xl font-semibold text-zinc-900">{name}</h2>
        <p className="text-sm font-semibold tracking-wide text-[#3525CD]">{title}</p>

        <div className="mt-4 flex items-center gap-4">
          <div className="flex items-center gap-1.5">
            <Star className="h-[18px] w-[18px] text-[#464555]" fill="currentColor" strokeWidth={0} />
            <span className="text-xs font-medium text-gray-700">
              {rating} Instructor Rating
            </span>
          </div>
          <div className="flex items-center gap-1.5">
            <Users className="h-[18px] w-[18px] text-[#464555]" />
            <span className="text-xs font-medium text-gray-700">
              {studentsCount} Students
            </span>
          </div>
        </div>

        <p className="mt-4 max-w-2xl text-base text-zinc-900">{bio}</p>
      </div>
    </section>
  );
}
