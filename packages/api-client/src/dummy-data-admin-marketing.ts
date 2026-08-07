export type BannerStatus = "scheduled" | "active" | "expired" | "draft";

export type AdminBanner = {
  id: string;
  title: string;
  subtitle?: string;
  imageUrl: string;
  linkUrl: string;
  status: BannerStatus;
  startsAt: string;
  endsAt: string;
  order: number;
};

export type CouponType = "percent" | "fixed";

export type AdminCoupon = {
  id: string;
  code: string;
  type: CouponType;
  value: number;
  scope: "platform_wide" | "category" | "course";
  usageLimit: number;
  usageCount: number;
  expiresAt: string;
  active: boolean;
};

export type PromotionTier = "bronze" | "silver" | "gold";

export type PromotionSale = {
  id: string;
  courseTitle: string;
  instructorName: string;
  tier: PromotionTier;
  amount: number;
  currency: string;
  purchasedAt: string;
  expiresAt: string;
};

function img(seed: string): string {
  return `https://picsum.photos/seed/${encodeURIComponent(seed)}/1200/400`;
}

function daysAgoIso(n: number): string {
  return new Date(Date.now() - n * 24 * 60 * 60 * 1000).toISOString();
}

function daysFromNowIso(n: number): string {
  return new Date(Date.now() + n * 24 * 60 * 60 * 1000).toISOString();
}

export const ADMIN_DUMMY_BANNERS: AdminBanner[] = [
  { id: "ban_1", title: "Founding Instructor Spots Open", subtitle: "Join early access and get featured placement", imageUrl: img("founding-instructor-banner"), linkUrl: "/register", status: "active", startsAt: daysAgoIso(5), endsAt: daysFromNowIso(10), order: 1 },
  { id: "ban_2", title: "New: AI Automation Track", subtitle: "Five new n8n + AI courses just launched", imageUrl: img("automation-track-banner"), linkUrl: "/categories/ai-automation", status: "active", startsAt: daysAgoIso(2), endsAt: daysFromNowIso(12), order: 2 },
  { id: "ban_3", title: "Ramadan Learning Sale", subtitle: "25% off with code SAACHI25", imageUrl: img("ramadan-sale-banner"), linkUrl: "/courses", status: "scheduled", startsAt: daysFromNowIso(20), endsAt: daysFromNowIso(35), order: 3 },
  { id: "ban_4", title: "Saachi AI Pro Launch", subtitle: "Unlimited access to Standard-tier courses", imageUrl: img("pro-launch-banner"), linkUrl: "/pricing", status: "expired", startsAt: daysAgoIso(60), endsAt: daysAgoIso(30), order: 4 },
  { id: "ban_5", title: "Corporate Team Plans", subtitle: "Bulk seats for your team - contact sales", imageUrl: img("corporate-banner"), linkUrl: "/contact", status: "draft", startsAt: daysFromNowIso(5), endsAt: daysFromNowIso(45), order: 5 }
];

export const ADMIN_DUMMY_COUPONS: AdminCoupon[] = [
  { id: "cpn_1", code: "SAACHI10", type: "percent", value: 10, scope: "platform_wide", usageLimit: 1000, usageCount: 412, expiresAt: daysFromNowIso(60), active: true },
  { id: "cpn_2", code: "SAACHI25", type: "percent", value: 25, scope: "platform_wide", usageLimit: 500, usageCount: 88, expiresAt: daysFromNowIso(15), active: true },
  { id: "cpn_3", code: "AUTOMATE20", type: "percent", value: 20, scope: "category", usageLimit: 200, usageCount: 200, expiresAt: daysAgoIso(3), active: false },
  { id: "cpn_4", code: "WELCOME5", type: "fixed", value: 5, scope: "platform_wide", usageLimit: 2000, usageCount: 1560, expiresAt: daysFromNowIso(90), active: true },
  { id: "cpn_5", code: "WHATSAPP15", type: "fixed", value: 15, scope: "course", usageLimit: 100, usageCount: 34, expiresAt: daysFromNowIso(30), active: true }
];

export const ADMIN_DUMMY_PROMOTION_SALES: PromotionSale[] = [
  { id: "ps_1", courseTitle: "Prompt Engineering Fundamentals", instructorName: "Sana Rizvi", tier: "gold", amount: 75, currency: "USD", purchasedAt: daysAgoIso(1), expiresAt: daysFromNowIso(13) },
  { id: "ps_2", courseTitle: "Automate Everything with n8n & AI", instructorName: "Ayesha Khan", tier: "silver", amount: 35, currency: "USD", purchasedAt: daysAgoIso(3), expiresAt: daysFromNowIso(11) },
  { id: "ps_3", courseTitle: "AI-Powered Marketing Campaigns", instructorName: "Zara Farooq", tier: "bronze", amount: 15, currency: "USD", purchasedAt: daysAgoIso(5), expiresAt: daysFromNowIso(9) },
  { id: "ps_4", courseTitle: "Integrating OpenAI & Claude APIs into Node.js Apps", instructorName: "Usman Ali", tier: "gold", amount: 75, currency: "USD", purchasedAt: daysAgoIso(8), expiresAt: daysFromNowIso(6) },
  { id: "ps_5", courseTitle: "Build a WhatsApp AI Auto-Responder", instructorName: "Bilal Ahmed", tier: "silver", amount: 35, currency: "USD", purchasedAt: daysAgoIso(20), expiresAt: daysAgoIso(6) },
  { id: "ps_6", courseTitle: "Ship Your First AI-Powered Web App", instructorName: "Hamza Tariq", tier: "bronze", amount: 15, currency: "USD", purchasedAt: daysAgoIso(25), expiresAt: daysAgoIso(11) }
];