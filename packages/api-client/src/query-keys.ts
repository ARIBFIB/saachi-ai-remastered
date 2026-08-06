export const courseKeys = {
  all: ["courses"] as const,
  list: (filters?: Record<string, unknown>) => ["courses", "list", filters] as const,
  detail: (id: string) => ["courses", "detail", id] as const,
  curriculum: (id: string) => ["courses", "curriculum", id] as const
};

export const authKeys = {
  session: ["auth", "session"] as const
};

export const cartKeys = {
  current: ["cart"] as const
};

export const enrollmentKeys = {
  myCourses: ["enrollments", "my-courses"] as const,
  progress: (courseId: string) => ["enrollments", "progress", courseId] as const
};

export const instructorKeys = {
  analytics: (instructorId: string) => ["instructor", "analytics", instructorId] as const,
  earnings: (instructorId: string) => ["instructor", "earnings", instructorId] as const,
  payouts: (instructorId: string) => ["instructor", "payouts", instructorId] as const
};

export const adminKeys = {
  users: (filters?: Record<string, unknown>) => ["admin", "users", filters] as const,
  moderationQueue: ["admin", "moderation-queue"] as const,
  transactions: (filters?: Record<string, unknown>) => ["admin", "transactions", filters] as const
};

export const notificationKeys = {
  list: ["notifications"] as const
};
