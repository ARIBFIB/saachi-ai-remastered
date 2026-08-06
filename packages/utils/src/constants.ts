export const INSTRUCTOR_TRUST_TIERS = [
  "new",
  "verified",
  "top_rated",
  "partner"
] as const;
export type InstructorTrustTier = (typeof INSTRUCTOR_TRUST_TIERS)[number];

export const ADMIN_ROLES = [
  "super_admin",
  "admin",
  "finance_officer",
  "support_officer"
] as const;
export type AdminRole = (typeof ADMIN_ROLES)[number];

export const COURSE_STATUS = [
  "draft",
  "pending_review",
  "published",
  "rejected",
  "archived"
] as const;
export type CourseStatus = (typeof COURSE_STATUS)[number];

export const PAYMENT_GATEWAYS = [
  "stripe",
  "paypal",
  "easypaisa",
  "jazzcash",
  "bank_transfer"
] as const;
export type PaymentGateway = (typeof PAYMENT_GATEWAYS)[number];
