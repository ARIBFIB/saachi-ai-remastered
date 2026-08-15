export type NewsArticle = {
  id: string;
  slug: string;
  title: string;
  excerpt: string;
  body: string;
  category: string;
  author: string;
  authorAvatarUrl?: string;
  imageUrl: string;
  publishedAt: string;
  readTime: string;
};

function img(seed: string): string {
  return `https://picsum.photos/seed/${encodeURIComponent(seed)}/800/450`;
}

export const DUMMY_NEWS: NewsArticle[] = [
  {
    id: "news_1", slug: "saachi-ai-crosses-42000-learners",
    title: "Saachi AI crosses 42,000 active learners milestone",
    excerpt: "The platform's course marketplace has grown 3x in the last two quarters, driven by demand for automation and prompt engineering skills.",
    body: "Saachi AI announced today that its learner base has surpassed 42,000 active accounts, a threefold increase since the start of the year. Growth has been led by the AI Automation & Workflow Tools category, which now accounts for nearly a third of all enrollments. Instructor payouts have also crossed the $2.1M mark cumulatively, with the platform's top instructors earning a full-time income teaching part-time.\n\nThe platform's leadership credited the growth to a shift in learner behavior away from passive watch-time courses toward project-based, outcome-driven learning. \"People don't want another 40-hour video course they'll never finish,\" said the team. \"They want five focused hours that end with something they can ship.\"",
    category: "Platform", author: "Saachi AI Team", imageUrl: img("news-42000-learners"),
    publishedAt: "2026-08-10T09:00:00.000Z", readTime: "3 min read"
  },
  {
    id: "news_2", slug: "instructor-payouts-hit-2-1-million",
    title: "Instructor payouts hit $2.1M as marketplace matures",
    excerpt: "A look at how commission tiers and trust badges are reshaping instructor earnings on Saachi AI.",
    body: "Since launch, Saachi AI has paid out over $2.1M to instructors across its four trust tiers - New, Verified, Top-Rated, and Partner. Verified and above instructors report significantly higher completion rates on their courses, likely due to the additional review process required to reach those tiers.\n\nThe platform is also piloting a new mentorship marketplace, allowing instructors to offer paid 1-on-1 sessions directly from their course pages. Early data shows mentorship bookings convert at a higher rate when the instructor has published at least three courses.",
    category: "Instructors", author: "Ayesha Khan", imageUrl: img("news-instructor-payouts"),
    publishedAt: "2026-08-05T09:00:00.000Z", readTime: "4 min read"
  },
  {
    id: "news_3", slug: "new-ai-automation-track-launches",
    title: "New AI Automation certification track launches",
    excerpt: "A guided, five-course path through n8n, prompt engineering, and agent-building - with a verified certificate at the end.",
    body: "Saachi AI has launched its first structured certification track, combining five existing courses into a guided sequence: Prompt Engineering Fundamentals, Automate Everything with n8n & AI, Build a WhatsApp AI Auto-Responder, Integrating OpenAI & Claude APIs into Node.js Apps, and a capstone project course.\n\nLearners who complete all five courses in order receive a Track Completion Certificate, distinct from individual course certificates, which can be independently verified via a public verification page.",
    category: "Product", author: "Saachi AI Team", imageUrl: img("news-automation-track"),
    publishedAt: "2026-07-28T09:00:00.000Z", readTime: "3 min read"
  },
  {
    id: "news_4", slug: "mentorship-marketplace-beta",
    title: "Mentorship marketplace enters public beta",
    excerpt: "Learners can now book paid 1-on-1 sessions directly with verified instructors from their course dashboard.",
    body: "The mentorship feature, previously available to a small group of pilot instructors, is now open to all Verified and Top-Rated instructors. Sessions are booked in 30, 45, or 60-minute blocks, with pricing set entirely by the instructor.\n\nEarly usage data shows the most-booked session topics are code review, portfolio feedback, and career transition advice - suggesting learners increasingly see Saachi AI courses as a stepping stone to freelance or full-time AI roles rather than a standalone credential.",
    category: "Product", author: "Saachi AI Team", imageUrl: img("news-mentorship-beta"),
    publishedAt: "2026-07-15T09:00:00.000Z", readTime: "3 min read"
  },
  {
    id: "news_5", slug: "top-instructor-spotlight-sana-rizvi",
    title: "Instructor spotlight: how Sana Rizvi built an 8,300-student course",
    excerpt: "Prompt Engineering Fundamentals is now the platform's highest-rated course. Here's how she built it.",
    body: "When Sana Rizvi published Prompt Engineering Fundamentals over a year ago, she expected a few hundred students. It now has over 8,300 enrolled learners and a 4.8-star average rating across 1,240 reviews.\n\nIn a recent interview, Rizvi credited the course's success to a strict \"no filler\" policy - every lesson had to directly produce something the learner could reuse at work, from a prompt library template to a knowledge-check quiz tied to a real business scenario. She's now working on an advanced follow-up course focused on agentic workflows.",
    category: "Community", author: "Saachi AI Team", imageUrl: img("news-sana-rizvi-spotlight"),
    publishedAt: "2026-07-02T09:00:00.000Z", readTime: "5 min read"
  },
  {
    id: "news_6", slug: "corporate-team-plans-launch",
    title: "Saachi AI Business launches for corporate teams",
    excerpt: "Bulk seat licenses, team completion dashboards, and custom invoicing - now available for organizations.",
    body: "Following demand from several mid-sized agencies already bulk-purchasing seats manually, Saachi AI has formalized its Business tier. Teams can now purchase seat bundles, assign specific courses to specific employees, and track completion across the whole team from a single dashboard.\n\nAcme Agency, an early corporate pilot customer, reported a 40% increase in course completion rates once managers could see team-wide progress rather than relying on self-reporting.",
    category: "Platform", author: "Saachi AI Team", imageUrl: img("news-business-launch"),
    publishedAt: "2026-06-20T09:00:00.000Z", readTime: "4 min read"
  },
  {
    id: "news_7", slug: "refund-policy-update",
    title: "Refund policy updated to a clearer 7-day / 30% window",
    excerpt: "Saachi AI simplifies its refund eligibility rules based on learner and instructor feedback.",
    body: "Following feedback from both learners and instructors about ambiguity in refund eligibility, Saachi AI has clarified its policy: refunds are available within 7 days of purchase, provided the learner has not completed more than 30% of the course content. Approved refunds are now processed within 5-7 business days, down from the previous 10-14 day window.",
    category: "Platform", author: "Saachi AI Team", imageUrl: img("news-refund-policy"),
    publishedAt: "2026-06-08T09:00:00.000Z", readTime: "2 min read"
  },
  {
    id: "news_8", slug: "ai-design-category-expands",
    title: "AI Design & Creative Tools category triples in size",
    excerpt: "New courses on Midjourney, Figma AI plugins, and AI-assisted brand identity design are now live.",
    body: "The AI Design & Creative Tools category has grown from 5 to 15 published courses this quarter, reflecting rising demand from freelance designers looking to speed up mockup and concept work with AI tools. Instructor Sara Iqbal's Midjourney for Product Mockups course has been a standout, with a 94% completion rate - well above the platform average of 61%.",
    category: "Product", author: "Saachi AI Team", imageUrl: img("news-design-category"),
    publishedAt: "2026-05-22T09:00:00.000Z", readTime: "3 min read"
  }
];