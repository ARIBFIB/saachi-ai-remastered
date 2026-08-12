// ============================================================================
// instructor-lookup.ts
// Small shared helper for deriving an "instructor" record from the existing
// course dummy data (DUMMY_COURSES), since there is no dedicated instructors
// dataset yet. Used by both the instructor profile page and the mentorship
// booking page so the two stay consistent. Replace with a real
// useInstructor(slug) hook once an Instructors API exists.
// ============================================================================
import { DUMMY_COURSES, type DummyCourse } from "@saachi/api-client";

export function slugifyName(value: string): string {
  return value
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "");
}

export interface InstructorLookupResult {
  id: string;
  fullName: string;
  avatarUrl?: string;
  bio: string;
  courses: DummyCourse[];
}

export function findInstructorBySlug(slug: string): InstructorLookupResult | null {
  const match = DUMMY_COURSES.find((c) => slugifyName(c.instructor.fullName) === slug);
  if (!match) return null;

  const courses = DUMMY_COURSES.filter((c) => c.instructor.id === match.instructor.id);

  return {
    id: match.instructor.id,
    fullName: match.instructor.fullName,
    avatarUrl: match.instructor.avatarUrl,
    bio: match.instructorBio ?? "",
    courses
  };
}

export function courseDurationLabel(course: DummyCourse): string {
  const totalSeconds = (course.curriculum ?? []).reduce(
    (sum, mod) => sum + mod.lessons.reduce((s, l) => s + (l.durationSeconds ?? 0), 0),
    0
  );
  if (totalSeconds <= 0) return "Self-paced";
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  return hours > 0 ? `${hours}h ${minutes}m` : `${minutes}m`;
}