export type CategoryDef = {
  id: string;
  name: string;
  slug: string;
};

export const CATEGORIES: CategoryDef[] = [
  { id: "ai-fundamentals", name: "AI Fundamentals & Prompt Engineering", slug: "ai-fundamentals" },
  { id: "ai-marketing", name: "AI for Marketing & Sales", slug: "ai-marketing" },
  { id: "ai-automation", name: "AI Automation & Workflow Tools", slug: "ai-automation" },
  { id: "ai-support", name: "AI Customer Support & Communication", slug: "ai-support" },
  { id: "ai-dev", name: "AI Website & App Development", slug: "ai-dev" },
  { id: "ai-integration", name: "AI Integration for Developers", slug: "ai-integration" },
  { id: "ai-design", name: "AI Design & Creative Tools", slug: "ai-design" },
  { id: "ai-career", name: "AI for Careers & Job Search", slug: "ai-career" }
];

export function getCategoryBySlug(slug: string): CategoryDef | undefined {
  return CATEGORIES.find((c) => c.slug === slug);
}