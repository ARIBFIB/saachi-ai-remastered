export type StaffRole = "super_admin" | "admin" | "finance_officer" | "support_officer";

export type StaffUser = {
  email: string;
  password: string;
  role: StaffRole;
  name: string;
};

export const ROLE_LABEL: Record<StaffRole, string> = {
  super_admin: "Super Admin",
  admin: "Admin",
  finance_officer: "Finance Officer",
  support_officer: "Support Officer"
};

// Dummy staff directory - no backend yet, credentials are hardcoded for demo/testing.
export const STAFF_USERS: StaffUser[] = [
  { email: "superadmin@saachi.ai", password: "super123", role: "super_admin", name: "Abdul Rehman Irfan" },
  { email: "admin@saachi.ai", password: "admin123", role: "admin", name: "Admin User" },
  { email: "finance@saachi.ai", password: "finance123", role: "finance_officer", name: "Finance Desk" },
  { email: "support@saachi.ai", password: "support123", role: "support_officer", name: "Support Desk" }
];

export function findStaffUser(email: string, password: string): StaffUser | null {
  const match = STAFF_USERS.find(
    (u) => u.email.toLowerCase() === email.trim().toLowerCase() && u.password === password
  );
  return match ?? null;
}

// Route prefix -> roles allowed to access it. Checked in order, first match wins.
// Any route not listed here is allowed for all roles (e.g. /dashboard).
const ROUTE_PERMISSIONS: { prefix: string; roles: StaffRole[] }[] = [
  // Settings - Super Admin only
  { prefix: "/settings/roles", roles: ["super_admin"] },
  { prefix: "/settings/commission-tiers", roles: ["super_admin"] },
  { prefix: "/settings/payment-gateways", roles: ["super_admin"] },
  { prefix: "/settings/platform", roles: ["super_admin"] },
  { prefix: "/settings/legal-documents", roles: ["super_admin"] },

  // Finance - Super Admin, Admin, Finance Officer
  { prefix: "/finance", roles: ["super_admin", "admin", "finance_officer"] },

  // Analytics - Super Admin, Admin, Finance Officer
  { prefix: "/analytics", roles: ["super_admin", "admin", "finance_officer"] },

  // Courses - Super Admin, Admin only
  { prefix: "/courses", roles: ["super_admin", "admin"] },

  // Marketing - Super Admin, Admin only
  { prefix: "/marketing", roles: ["super_admin", "admin"] },

  // Audit log - Super Admin, Admin only
  { prefix: "/logs/audit", roles: ["super_admin", "admin"] },

  // Users - Super Admin, Admin, Support Officer
  { prefix: "/users", roles: ["super_admin", "admin", "support_officer"] },

  // Moderation (reviews, forum, content) - Super Admin, Admin, Support Officer
  { prefix: "/moderation", roles: ["super_admin", "admin", "support_officer"] },

  // Support tickets - Super Admin, Admin, Support Officer
  { prefix: "/support", roles: ["super_admin", "admin", "support_officer"] }

  // /dashboard and anything else not listed above -> allowed for all roles
];

export function isRouteAllowed(pathname: string, role: StaffRole): boolean {
  const rule = ROUTE_PERMISSIONS.find((r) => pathname === r.prefix || pathname.startsWith(`${r.prefix}/`));
  if (!rule) return true; // not restricted -> everyone can access
  return rule.roles.includes(role);
}

export function getAllowedRolesForRoute(prefix: string): StaffRole[] {
  const rule = ROUTE_PERMISSIONS.find((r) => prefix === r.prefix || prefix.startsWith(`${r.prefix}/`) || r.prefix.startsWith(prefix));
  if (!rule) return ["super_admin", "admin", "finance_officer", "support_officer"];
  return rule.roles;
}

// ---- Cookie helpers (client-side, no backend) ----

const SESSION_COOKIE = "saachi_admin_session";
const ROLE_COOKIE = "saachi_admin_role";
const NAME_COOKIE = "saachi_admin_name";
const EMAIL_COOKIE = "saachi_admin_email";

export function setAuthCookies(user: StaffUser) {
  const maxAge = 60 * 60 * 24 * 7; // 7 days
  document.cookie = `${SESSION_COOKIE}=demo_token; path=/; max-age=${maxAge}`;
  document.cookie = `${ROLE_COOKIE}=${user.role}; path=/; max-age=${maxAge}`;
  document.cookie = `${NAME_COOKIE}=${encodeURIComponent(user.name)}; path=/; max-age=${maxAge}`;
  document.cookie = `${EMAIL_COOKIE}=${encodeURIComponent(user.email)}; path=/; max-age=${maxAge}`;
}

export function clearAuthCookies() {
  document.cookie = `${SESSION_COOKIE}=; path=/; max-age=0`;
  document.cookie = `${ROLE_COOKIE}=; path=/; max-age=0`;
  document.cookie = `${NAME_COOKIE}=; path=/; max-age=0`;
  document.cookie = `${EMAIL_COOKIE}=; path=/; max-age=0`;
}

function readCookie(name: string): string | null {
  if (typeof document === "undefined") return null;
  const match = document.cookie.match(new RegExp(`(?:^|; )${name}=([^;]*)`));
  return match ? decodeURIComponent(match[1]) : null;
}

export function getCurrentRole(): StaffRole {
  const stored = readCookie(ROLE_COOKIE) as StaffRole | null;
  const valid: StaffRole[] = ["super_admin", "admin", "finance_officer", "support_officer"];
  return stored && valid.includes(stored) ? stored : "super_admin";
}

export function getCurrentName(): string {
  return readCookie(NAME_COOKIE) ?? "Abdul Rehman Irfan";
}

export function getCurrentEmail(): string {
  return readCookie(EMAIL_COOKIE) ?? "abdulrehman@saachi.ai";
}

export function setCurrentRole(role: StaffRole) {
  const maxAge = 60 * 60 * 24 * 7;
  document.cookie = `${ROLE_COOKIE}=${role}; path=/; max-age=${maxAge}`;
}

// ---- Module-level access check (used by dashboard widgets, quick actions, charts) ----
// Reuses the same ROUTE_PERMISSIONS matrix as the sidebar/route guard, so there is a
// single source of truth for "who can see what."
export function canAccessModule(modulePrefix: string, role: StaffRole): boolean {
  return getAllowedRolesForRoute(modulePrefix).includes(role);
}
