// Stub hooks - frontend-only placeholders so pages relying on these hooks
// render without crashing before the real backend + typed API client exist.
// Replace the dummy data below with real network calls once the NestJS
// backend (Doc 3) and OpenAPI-generated client are ready.

import { useQuery } from "@tanstack/react-query";

// ---- Types (self-contained; align with real API types once backend lands) ----

export type CourseModuleLessonStub = { id: string; title: string };
export type CourseModuleStub = { id: string; title: string; lessons: CourseModuleLessonStub[] };
export type CourseReviewStub = { id: string; authorName: string; rating: number; comment: string };

export type CourseDetailStub = {
  id: string;
  slug: string;
  title: string;
  subtitle?: string;
  categoryName?: string;
  level: string;
  language: string;
  durationMinutes?: number;
  rating?: number;
  ratingCount?: number;
  price: number;
  currency: string;
  thumbnailUrl?: string;
  instructor: { slug: string; fullName: string; bio?: string };
  modules?: CourseModuleStub[];
  reviews?: CourseReviewStub[];
};

export type InstructorProfile = {
  slug: string;
  fullName: string;
  headline?: string;
  bio?: string;
  avatarUrl?: string;
  averageRating?: number;
  studentCount?: number;
  courseCount?: number;
  courses?: {
    id: string;
    slug: string;
    title: string;
    thumbnailUrl?: string;
    price: number;
    currency: string;
    rating?: number;
    ratingCount?: number;
  }[];
  reviews?: CourseReviewStub[];
};

export type CertificateDetail = {
  id: string;
  verificationId: string;
  courseTitle: string;
  learnerName: string;
  instructorName: string;
  issuedAt: string;
};

// ---- Dummy data (demo-only, no backend wired up yet) ----

function buildDummyCourse(slug: string): CourseDetailStub {
  return {
    id: `course_${slug}`,
    slug,
    title: "AI Automation with n8n",
    subtitle: "Build end-to-end automations connecting AI models into no-code workflows.",
    categoryName: "AI Automation & Workflow Tools",
    level: "Intermediate",
    language: "en",
    durationMinutes: 420,
    rating: 4.7,
    ratingCount: 128,
    price: 49,
    currency: "USD",
    thumbnailUrl: "https://picsum.photos/seed/" + slug + "/800/450",
    instructor: {
      slug: "ayesha-khan",
      fullName: "Ayesha Khan",
      bio: "AI automation consultant with 6+ years building workflow systems for startups and agencies."
    },
    modules: [
      {
        id: "m1",
        title: "Getting started with n8n",
        lessons: [
          { id: "l1", title: "Installing and setting up n8n" },
          { id: "l2", title: "Your first workflow" }
        ]
      },
      {
        id: "m2",
        title: "Connecting AI models",
        lessons: [
          { id: "l3", title: "Calling the OpenAI API from n8n" },
          { id: "l4", title: "Building a WhatsApp AI auto-responder" }
        ]
      }
    ],
    reviews: [
      { id: "r1", authorName: "Bilal S.", rating: 5, comment: "Very practical, loved it." },
      { id: "r2", authorName: "Fatima R.", rating: 4, comment: "Good pacing, clear examples." }
    ]
  };
}

function buildDummyInstructor(slug: string): InstructorProfile {
  return {
    slug,
    fullName: "Ayesha Khan",
    headline: "AI Automation & Workflow Tools instructor",
    bio: "AI automation consultant with 6+ years building workflow systems for startups and agencies.",
    averageRating: 4.7,
    studentCount: 1240,
    courseCount: 3,
    courses: [
      {
        id: "course_1",
        slug: "ai-automation-with-n8n",
        title: "AI Automation with n8n",
        thumbnailUrl: "https://picsum.photos/seed/n8n/600/340",
        price: 49,
        currency: "USD",
        rating: 4.7,
        ratingCount: 128
      }
    ],
    reviews: [{ id: "r1", authorName: "Bilal S.", rating: 5, comment: "Clear, practical teaching style." }]
  };
}

function buildDummyCertificate(id: string): CertificateDetail {
  return {
    id,
    verificationId: `SAI-${id.toUpperCase()}`,
    courseTitle: "AI Automation with n8n",
    learnerName: "Learner Name",
    instructorName: "Ayesha Khan",
    issuedAt: new Date().toISOString()
  };
}

// ---- Hooks ----

export function useCourseDetailDemo(slug: string) {
  return useQuery({
    queryKey: ["course-detail", slug],
    queryFn: async () => buildDummyCourse(slug),
    enabled: Boolean(slug)
  });
}

export function useInstructorProfile(slug: string) {
  return useQuery({
    queryKey: ["instructor-profile", slug],
    queryFn: async () => buildDummyInstructor(slug),
    enabled: Boolean(slug)
  });
}

export function useCertificateDetail(id: string) {
  return useQuery({
    queryKey: ["certificate-detail", id],
    queryFn: async () => buildDummyCertificate(id),
    enabled: Boolean(id)
  });
}