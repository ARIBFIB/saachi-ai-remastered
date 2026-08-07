export type AdminCourseStatus = "draft" | "pending_review" | "published" | "rejected" | "archived";

export type AdminCourse = {
  id: string;
  title: string;
  instructorName: string;
  instructorId: string;
  categoryId: string;
  price: number;
  currency: string;
  status: AdminCourseStatus;
  submittedAt: string;
  thumbnailUrl?: string;
  featured: boolean;
  pinned: boolean;
  rating: number;
  enrollmentCount: number;
  rejectionReason?: string;
};

export type AdminCategory = {
  id: string;
  name: string;
  slug: string;
  courseCount: number;
  tags: string[];
};

function img(seed: string): string {
  return `https://picsum.photos/seed/${encodeURIComponent(seed)}/400/225`;
}

function daysAgoIso(n: number): string {
  return new Date(Date.now() - n * 24 * 60 * 60 * 1000).toISOString();
}

export const ADMIN_DUMMY_CATEGORIES: AdminCategory[] = [
  { id: "ai-fundamentals", name: "AI Fundamentals & Prompt Engineering", slug: "ai-fundamentals", courseCount: 14, tags: ["prompting", "chatgpt", "beginner"] },
  { id: "ai-marketing", name: "AI for Marketing & Sales", slug: "ai-marketing", courseCount: 9, tags: ["copywriting", "ads", "leadgen"] },
  { id: "ai-automation", name: "AI Automation & Workflow Tools", slug: "ai-automation", courseCount: 11, tags: ["n8n", "zapier", "make.com"] },
  { id: "ai-support", name: "AI Customer Support & Communication", slug: "ai-support", courseCount: 6, tags: ["whatsapp", "chatbot", "callcenter"] },
  { id: "ai-dev", name: "AI Website & App Development", slug: "ai-dev", courseCount: 8, tags: ["nocode", "builder", "scaffolding"] },
  { id: "ai-integration", name: "AI Integration for Developers", slug: "ai-integration", courseCount: 7, tags: ["api", "openai", "nodejs"] },
  { id: "ai-design", name: "AI Design & Creative Tools", slug: "ai-design", courseCount: 5, tags: ["midjourney", "figma", "dalle"] },
  { id: "ai-career", name: "AI for Careers & Job Search", slug: "ai-career", courseCount: 3, tags: ["resume", "interview"] }
];

export const ADMIN_DUMMY_COURSES: AdminCourse[] = [
  { id: "crs_a1", title: "WhatsApp AI Auto-Responder for Local Retailers", instructorName: "Bilal Ahmed", instructorId: "usr_1002", categoryId: "ai-support", price: 59, currency: "USD", status: "pending_review", submittedAt: daysAgoIso(1), thumbnailUrl: img("whatsapp-ai-retail"), featured: false, pinned: false, rating: 0, enrollmentCount: 0 },
  { id: "crs_a2", title: "Cold Email Sequences with Claude & GPT-4", instructorName: "Zara Farooq", instructorId: "usr_1008", categoryId: "ai-marketing", price: 39, currency: "USD", status: "pending_review", submittedAt: daysAgoIso(2), thumbnailUrl: img("cold-email-ai"), featured: false, pinned: false, rating: 0, enrollmentCount: 0 },
  { id: "crs_a3", title: "n8n + OpenAI: Five Production Automations", instructorName: "Ayesha Khan", instructorId: "usr_1001", categoryId: "ai-automation", price: 45, currency: "USD", status: "pending_review", submittedAt: daysAgoIso(3), thumbnailUrl: img("n8n-openai-automations"), featured: false, pinned: false, rating: 0, enrollmentCount: 0 },
  { id: "crs_a4", title: "Prompt Engineering Fundamentals", instructorName: "Sana Rizvi", instructorId: "usr_1005", categoryId: "ai-fundamentals", price: 29, currency: "USD", status: "published", submittedAt: daysAgoIso(180), thumbnailUrl: img("prompt-engineering-fundamentals"), featured: true, pinned: true, rating: 4.8, enrollmentCount: 1240 },
  { id: "crs_a5", title: "AI-Powered Marketing Campaigns", instructorName: "Zara Farooq", instructorId: "usr_1008", categoryId: "ai-marketing", price: 49, currency: "USD", status: "published", submittedAt: daysAgoIso(150), thumbnailUrl: img("ai-powered-marketing-campaigns"), featured: false, pinned: false, rating: 4.6, enrollmentCount: 812 },
  { id: "crs_a6", title: "Automate Everything with n8n & AI", instructorName: "Ayesha Khan", instructorId: "usr_1001", categoryId: "ai-automation", price: 39, currency: "USD", status: "published", submittedAt: daysAgoIso(140), thumbnailUrl: img("automate-everything-with-n8n-and-ai"), featured: true, pinned: false, rating: 4.7, enrollmentCount: 654 },
  { id: "crs_a7", title: "Build a WhatsApp AI Auto-Responder", instructorName: "Bilal Ahmed", instructorId: "usr_1002", categoryId: "ai-support", price: 59, currency: "USD", status: "published", submittedAt: daysAgoIso(120), thumbnailUrl: img("build-a-whatsapp-ai-auto-responder"), featured: false, pinned: false, rating: 4.9, enrollmentCount: 401 },
  { id: "crs_a8", title: "Ship Your First AI-Powered Web App", instructorName: "Hamza Tariq", instructorId: "usr_1011", categoryId: "ai-dev", price: 45, currency: "USD", status: "published", submittedAt: daysAgoIso(100), thumbnailUrl: img("ship-your-first-ai-powered-web-app"), featured: false, pinned: false, rating: 4.5, enrollmentCount: 588 },
  { id: "crs_a9", title: "Integrating OpenAI & Claude APIs into Node.js Apps", instructorName: "Usman Ali", instructorId: "usr_1007", categoryId: "ai-integration", price: 65, currency: "USD", status: "published", submittedAt: daysAgoIso(90), thumbnailUrl: img("integrating-openai-and-claude-apis-into-node"), featured: true, pinned: false, rating: 4.9, enrollmentCount: 320 },
  { id: "crs_a10", title: "AI Video Scripts for YouTube Growth", instructorName: "Danish Raza", instructorId: "usr_1009", categoryId: "ai-marketing", price: 35, currency: "USD", status: "rejected", submittedAt: daysAgoIso(14), thumbnailUrl: img("ai-video-scripts"), featured: false, pinned: false, rating: 0, enrollmentCount: 0, rejectionReason: "Curriculum lacked hands-on exercises; resubmit with a project-based module." },
  { id: "crs_a11", title: "Midjourney for Product Mockups", instructorName: "Sara Iqbal", instructorId: "usr_1010", categoryId: "ai-design", price: 25, currency: "USD", status: "draft", submittedAt: daysAgoIso(0), thumbnailUrl: img("midjourney-product-mockups"), featured: false, pinned: false, rating: 0, enrollmentCount: 0 },
  { id: "crs_a12", title: "AI Resume & Interview Prep Toolkit", instructorName: "Hina Malik", instructorId: "usr_1003", categoryId: "ai-career", price: 19, currency: "USD", status: "archived", submittedAt: daysAgoIso(365), thumbnailUrl: img("ai-resume-toolkit"), featured: false, pinned: false, rating: 4.1, enrollmentCount: 210 }
];