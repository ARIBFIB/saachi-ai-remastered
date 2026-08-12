import { GraduationCap, Users, Star } from "lucide-react";

interface InstructorStatsGridProps {
  coursesCount: number;
  studentsCount: string;
  rating: number;
  reviewsCount: string;
}

export function InstructorStatsGrid({
  coursesCount,
  studentsCount,
  rating,
  reviewsCount,
}: InstructorStatsGridProps) {
  return (
    <div className="flex w-64 shrink-0 flex-col gap-4">
      <div className="flex gap-4">
        <StatCard
          icon={<GraduationCap className="h-[30px] w-[30px] text-[var(--token-color-primary)]" />}
          value={coursesCount}
          label="Courses"
        />
        <StatCard
          icon={<Users className="h-[26px] w-[30px] text-[var(--token-color-primary)]" />}
          value={studentsCount}
          label="Students"
        />
      </div>

      <div className="flex flex-col items-center gap-2 rounded-xl border border-[var(--token-color-border)]/30 bg-[var(--token-color-surface)] px-4 py-8 shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
        <div className="flex items-center gap-2">
          <Star className="h-[19px] w-5 text-[var(--token-color-warning)]" fill="currentColor" strokeWidth={0} />
          <span className="text-2xl font-semibold leading-8 text-[var(--token-color-ink)]">{rating}</span>
        </div>
        <span className="text-center text-xs font-medium uppercase tracking-wide text-[var(--token-color-inkSoft)]">
          Instructor Rating ({reviewsCount} reviews)
        </span>
      </div>
    </div>
  );
}

function StatCard({
  icon,
  value,
  label,
}: {
  icon: React.ReactNode;
  value: string | number;
  label: string;
}) {
  return (
    <div className="flex flex-1 flex-col items-center justify-center gap-2 rounded-xl border border-[var(--token-color-border)]/30 bg-[var(--token-color-surface)] py-8 shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
      {icon}
      <span className="text-2xl font-semibold leading-8 text-[var(--token-color-ink)]">{value}</span>
      <span className="text-xs font-medium uppercase tracking-wide text-[var(--token-color-inkSoft)]">{label}</span>
    </div>
  );
}