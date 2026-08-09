// Maps each dashboard widget (KPI, quick action, chart, notification, activity type)
// to the route-permission prefix that governs it. Dashboard content is derived from
// this file + canAccessModule() so it always stays in sync with the sidebar/route
// permission matrix in lib/permissions.ts - no per-role dashboard hardcoding.

export type DashboardModuleKey =
  | "/users"
  | "/finance"
  | "/courses"
  | "/support"
  | "/analytics"
  | "/marketing"
  | "/settings/commission-tiers";

export const KPI_MODULE_MAP: Record<string, DashboardModuleKey> = {
  signups: "/users",
  revenue: "/finance",
  approvals: "/courses",
  tickets: "/support"
};

export const QUICK_ACTION_MODULE_MAP: Record<string, DashboardModuleKey> = {
  approve_queue: "/courses",
  process_payouts: "/finance",
  view_tickets: "/support",
  export_report: "/analytics"
};

export const NOTIFICATION_MODULE_MAP: Record<string, DashboardModuleKey> = {
  n1: "/courses",   // moderation queue
  n2: "/finance",   // refund request
  n3: "/support",   // SLA breach
  n4: "/finance"    // payout batch
};

export const ACTIVITY_TYPE_MODULE_MAP: Record<string, DashboardModuleKey> = {
  transaction: "/finance",
  course: "/courses",
  ticket: "/support",
  user: "/users"
};

// Revenue/enrollment/pie charts are grouped under "/finance" and "/analytics"
// respectively since that's what governs their visibility per the permission matrix.
export const REVENUE_CHART_MODULE: DashboardModuleKey = "/finance";
export const PIE_CHART_MODULE: DashboardModuleKey = "/finance";
export const ENROLLMENT_CHART_MODULE: DashboardModuleKey = "/analytics";
