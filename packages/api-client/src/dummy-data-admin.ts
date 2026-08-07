export type AdminUserRole = "learner" | "instructor" | "corporate" | "admin";
export type AdminUserStatus = "active" | "suspended" | "banned" | "pending";

export type AdminUser = {
  id: string;
  fullName: string;
  email: string;
  avatarUrl?: string;
  role: AdminUserRole;
  status: AdminUserStatus;
  joinedAt: string;
  lastActiveAt: string;
  coursesEnrolled?: number;
  coursesPublished?: number;
  totalSpend?: number;
  totalEarnings?: number;
  location?: string;
};

export type AdminActivityLogEntry = {
  id: string;
  action: string;
  detail: string;
  createdAt: string;
};

export type AdminAuditLogEntry = {
  id: string;
  actor: string;
  action: string;
  target: string;
  createdAt: string;
  ip: string;
};

function img(seed: string): string {
  return `https://picsum.photos/seed/${encodeURIComponent(seed)}/150/150`;
}

function daysAgo(n: number): string {
  return new Date(Date.now() - n * 24 * 60 * 60 * 1000).toISOString();
}

export const ADMIN_DUMMY_USERS: AdminUser[] = [
  { id: "usr_1001", fullName: "Ayesha Khan", email: "ayesha.khan@example.com", avatarUrl: img("ayesha-khan-instructor"), role: "instructor", status: "active", joinedAt: daysAgo(210), lastActiveAt: daysAgo(0), coursesPublished: 3, totalEarnings: 4620, location: "Lahore, PK" },
  { id: "usr_1002", fullName: "Bilal Ahmed", email: "bilal.ahmed@example.com", avatarUrl: img("bilal-ahmed-instructor"), role: "instructor", status: "active", joinedAt: daysAgo(180), lastActiveAt: daysAgo(1), coursesPublished: 1, totalEarnings: 1450, location: "Karachi, PK" },
  { id: "usr_1003", fullName: "Hina Malik", email: "hina.malik@example.com", avatarUrl: img("hina-malik"), role: "learner", status: "active", joinedAt: daysAgo(95), lastActiveAt: daysAgo(0), coursesEnrolled: 4, totalSpend: 186, location: "Islamabad, PK" },
  { id: "usr_1004", fullName: "Omar Sheikh", email: "omar.sheikh@example.com", avatarUrl: img("omar-sheikh"), role: "learner", status: "active", joinedAt: daysAgo(60), lastActiveAt: daysAgo(3), coursesEnrolled: 2, totalSpend: 78, location: "Rawalpindi, PK" },
  { id: "usr_1005", fullName: "Sana Rizvi", email: "sana.rizvi@example.com", avatarUrl: img("sana-rizvi"), role: "instructor", status: "active", joinedAt: daysAgo(300), lastActiveAt: daysAgo(0), coursesPublished: 4, totalEarnings: 8300, location: "Lahore, PK" },
  { id: "usr_1006", fullName: "Fatima Noor", email: "fatima.noor@example.com", avatarUrl: img("fatima-noor"), role: "learner", status: "suspended", joinedAt: daysAgo(140), lastActiveAt: daysAgo(21), coursesEnrolled: 1, totalSpend: 39, location: "Multan, PK" },
  { id: "usr_1007", fullName: "Usman Ali", email: "usman.ali@example.com", avatarUrl: img("usman-ali"), role: "instructor", status: "pending", joinedAt: daysAgo(5), lastActiveAt: daysAgo(1), coursesPublished: 0, totalEarnings: 0, location: "Faisalabad, PK" },
  { id: "usr_1008", fullName: "Zara Farooq", email: "zara.farooq@example.com", avatarUrl: img("zara-farooq"), role: "instructor", status: "active", joinedAt: daysAgo(260), lastActiveAt: daysAgo(2), coursesPublished: 2, totalEarnings: 3100, location: "Karachi, PK" },
  { id: "usr_1009", fullName: "Danish Raza", email: "danish.raza@example.com", avatarUrl: img("danish-raza"), role: "learner", status: "banned", joinedAt: daysAgo(400), lastActiveAt: daysAgo(90), coursesEnrolled: 6, totalSpend: 340, location: "Lahore, PK" },
  { id: "usr_1010", fullName: "Sara Iqbal", email: "sara.iqbal@example.com", avatarUrl: img("sara-iqbal"), role: "learner", status: "active", joinedAt: daysAgo(30), lastActiveAt: daysAgo(0), coursesEnrolled: 1, totalSpend: 59, location: "Islamabad, PK" },
  { id: "usr_1011", fullName: "Hamza Tariq", email: "hamza.tariq@example.com", avatarUrl: img("hamza-tariq"), role: "instructor", status: "active", joinedAt: daysAgo(150), lastActiveAt: daysAgo(4), coursesPublished: 2, totalEarnings: 2900, location: "Peshawar, PK" },
  { id: "usr_1012", fullName: "Noor Fatima", email: "noor.fatima@example.com", avatarUrl: img("noor-fatima"), role: "learner", status: "active", joinedAt: daysAgo(12), lastActiveAt: daysAgo(0), coursesEnrolled: 3, totalSpend: 124, location: "Islamabad, PK" },
  { id: "usr_1013", fullName: "Acme Agency", email: "billing@acmeagency.com", role: "corporate", status: "active", joinedAt: daysAgo(500), lastActiveAt: daysAgo(2), location: "Lahore, PK" },
  { id: "usr_1014", fullName: "Mahnoor Fatima", email: "mahnoor.f@example.com", avatarUrl: img("mahnoor-fatima"), role: "learner", status: "pending", joinedAt: daysAgo(1), lastActiveAt: daysAgo(1), coursesEnrolled: 0, totalSpend: 0, location: "Quetta, PK" },
  { id: "usr_1015", fullName: "Ali Raza", email: "ali.raza@example.com", avatarUrl: img("ali-raza"), role: "learner", status: "active", joinedAt: daysAgo(80), lastActiveAt: daysAgo(5), coursesEnrolled: 2, totalSpend: 88, location: "Sialkot, PK" }
];

export function getAdminActivityLog(userId: string): AdminActivityLogEntry[] {
  return [
    { id: `${userId}_a1`, action: "Logged in", detail: "Signed in from a new device (Chrome, Windows)", createdAt: daysAgo(0) },
    { id: `${userId}_a2`, action: "Profile updated", detail: "Changed display name and avatar", createdAt: daysAgo(4) },
    { id: `${userId}_a3`, action: "Course enrolled", detail: "Enrolled in \"Prompt Engineering Fundamentals\"", createdAt: daysAgo(10) },
    { id: `${userId}_a4`, action: "Payment completed", detail: "Order ORD-8H2K1 - $29.00 via Stripe", createdAt: daysAgo(10) },
    { id: `${userId}_a5`, action: "Account created", detail: "Registered via email/password", createdAt: daysAgo(95) }
  ];
}

export function getAdminAuditLog(userId: string): AdminAuditLogEntry[] {
  return [
    { id: `${userId}_l1`, actor: "system", action: "flagged for review", target: userId, createdAt: daysAgo(21), ip: "10.4.2.19" },
    { id: `${userId}_l2`, actor: "admin@saachi.ai", action: "sent warning email", target: userId, createdAt: daysAgo(20), ip: "internal" }
  ];
}