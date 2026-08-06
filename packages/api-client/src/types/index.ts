export type UserRole = "learner" | "instructor" | "admin" | "super_admin";

export type Session = {
  id: string;
  fullName: string;
  email: string;
  role: UserRole;
  avatarUrl?: string;
};

export type Course = {
  id: string;
  slug: string;
  title: string;
  subtitle?: string;
  thumbnailUrl?: string;
  price: number;
  currency: string;
  rating: number;
  ratingCount: number;
  instructor: {
    id: string;
    fullName: string;
    avatarUrl?: string;
  };
  status: "draft" | "pending_review" | "published" | "rejected" | "archived";
};

export type CourseLesson = {
  id: string;
  title: string;
  type: "video" | "text" | "quiz" | "resource";
  durationSeconds?: number;
  isPreview?: boolean;
};

export type CourseModule = {
  id: string;
  title: string;
  lessons: CourseLesson[];
};

export type RatingBreakdown = {
  5: number;
  4: number;
  3: number;
  2: number;
  1: number;
};

export type CourseReview = {
  id: string;
  authorName: string;
  authorAvatarUrl?: string;
  rating: number;
  comment: string;
  createdAt: string;
  verifiedPurchase?: boolean;
};

export type CourseFaqItem = {
  id: string;
  question: string;
  answer: string;
};

export type CourseDetail = Course & {
  description?: string;
  previewVideoUrl?: string;
  instructorBio?: string;
  instructorCourseCount?: number;
  instructorStudentCount?: number;
  curriculum?: CourseModule[];
  ratingBreakdown?: RatingBreakdown;
  reviews?: CourseReview[];
  faq?: CourseFaqItem[];
  relatedCourses?: Course[];
};

export type Paginated<T> = {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
};
