import { notFound } from "next/navigation";
import { CoursePlayerClient } from "./CoursePlayerClient";

// TODO: replace with useCoursePlayer(slug) hook from @saachi/api-client
export interface PlayerLesson {
  id: string;
  title: string;
  durationLabel: string;
  completed: boolean;
}

export interface PlayerModule {
  id: string;
  title: string;
  lessons: PlayerLesson[];
}

export interface PlayerCourse {
  slug: string;
  title: string;
  videoUrl: string;
  modules: PlayerModule[];
}

const DUMMY_PLAYER_COURSES: Record<string, PlayerCourse> = {
  "prompt-engineering-masterclass": {
    slug: "prompt-engineering-masterclass",
    title: "Prompt Engineering Masterclass",
    videoUrl: "",
    modules: [
      {
        id: "m1",
        title: "Module 1: Introduction to Large Language Models",
        lessons: [
          { id: "l1", title: "What is a Large Language Model?", durationLabel: "8:12", completed: true },
          { id: "l2", title: "Tokens, Context Windows & Limits", durationLabel: "11:45", completed: true },
          { id: "l3", title: "Zero-shot vs Few-shot Prompting", durationLabel: "14:03", completed: false },
        ],
      },
      {
        id: "m2",
        title: "Module 2: Anatomy of a Perfect Prompt",
        lessons: [
          { id: "l4", title: "Structuring Instructions", durationLabel: "9:30", completed: false },
          { id: "l5", title: "Chain-of-Thought Reasoning", durationLabel: "16:20", completed: false },
        ],
      },
    ],
  },
};

function getPlayerCourseBySlug(slug: string): PlayerCourse | null {
  return DUMMY_PLAYER_COURSES[slug] ?? null;
}

interface CoursePlayerPageProps {
  params: Promise<{ slug: string }>;
}

export default async function CoursePlayerPage({ params }: CoursePlayerPageProps) {
  const { slug } = await params;
  const course = getPlayerCourseBySlug(slug);

  if (!course) {
    notFound();
  }

  return <CoursePlayerClient course={course} />;
}