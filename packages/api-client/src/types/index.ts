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

export type Paginated<T> = {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
};
