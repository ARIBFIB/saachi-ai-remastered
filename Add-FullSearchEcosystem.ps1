# Add-FullSearchEcosystem.ps1
# Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param([Parameter(Mandatory=$true)][string]$Path, [Parameter(Mandatory=$true)][string]$Content)
    $dir = Split-Path -Path $Path -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

$root = (Get-Location).Path
$webApp = Join-Path -Path $root -ChildPath "apps\web"
$apiClientSrc = Join-Path -Path $root -ChildPath "packages\api-client\src"

if (-not (Test-Path $webApp)) { Write-Host "ERROR: run from SAI2 repo root." -ForegroundColor Red; exit 1 }

Write-Host "=== PHASE 1: Dummy data ===" -ForegroundColor Cyan

# ------------------------------------------------------------------
# dummy-data-news.ts
# ------------------------------------------------------------------
$newsContent = @'
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
'@
Write-Utf8NoBom -Path (Join-Path $apiClientSrc "dummy-data-news.ts") -Content $newsContent
Write-Host "Created: dummy-data-news.ts" -ForegroundColor Green

# ------------------------------------------------------------------
# dummy-data-blog.ts
# ------------------------------------------------------------------
$blogContent = @'
export type BlogPost = {
  id: string;
  slug: string;
  title: string;
  excerpt: string;
  body: string;
  tag: string;
  author: string;
  authorAvatarUrl?: string;
  imageUrl: string;
  publishedAt: string;
  readTime: string;
};

function img(seed: string): string {
  return `https://picsum.photos/seed/${encodeURIComponent(seed)}/800/450`;
}

export const DUMMY_BLOG_POSTS: BlogPost[] = [
  {
    id: "blog_1", slug: "5-n8n-workflows-every-freelancer-should-automate-first",
    title: "5 n8n workflows every freelancer should automate first",
    excerpt: "Stop manually copying leads into spreadsheets. Here are the five automations that saved us the most hours.",
    body: "If you're a freelancer juggling client work and admin, these five n8n workflows will give you the fastest return on the time you spend setting them up:\n\n1. Lead qualification - auto-score inbound form submissions and route hot leads to Slack instantly.\n2. Invoice parsing - extract line items from PDF invoices straight into your bookkeeping sheet.\n3. Content repurposing - turn one long-form post into five social variants automatically.\n4. Support ticket routing - classify and assign incoming support emails by topic.\n5. Daily AI digest - a morning summary of your calendar, tasks, and inbox, delivered before you even open your laptop.\n\nEach of these is covered step-by-step in the Automate Everything with n8n & AI course, including downloadable workflow files.",
    tag: "Automation", author: "Ayesha Khan", imageUrl: img("blog-n8n-workflows"),
    publishedAt: "2026-08-01T09:00:00.000Z", readTime: "6 min read"
  },
  {
    id: "blog_2", slug: "how-we-structure-a-beginner-to-advanced-ai-curriculum",
    title: "How we structure a beginner-to-advanced AI curriculum",
    excerpt: "A behind-the-scenes look at how Saachi AI's course review team evaluates curriculum structure before approval.",
    body: "Every course submitted to Saachi AI goes through a curriculum structure review before it's approved for publishing. We look for three things: a clear progression from foundational to applied skills, at least one hands-on project per module, and a final capstone that ties everything together.\n\nCourses that pass this review tend to have significantly higher completion rates - our data shows a 22-point difference in average completion between courses with a capstone project and those without.",
    tag: "Teaching", author: "Saachi AI Team", imageUrl: img("blog-curriculum-structure"),
    publishedAt: "2026-07-24T09:00:00.000Z", readTime: "8 min read"
  },
  {
    id: "blog_3", slug: "from-student-to-instructor-ayeshas-story",
    title: "From student to instructor: Ayesha's story",
    excerpt: "How a freelance automation consultant became one of Saachi AI's most successful instructors.",
    body: "Before teaching on Saachi AI, Ayesha Khan was a freelance automation consultant building n8n workflows for e-commerce clients. After enrolling in a prompt engineering course as a student, she pitched her own course idea to the platform's instructor team.\n\nHer first course, Automate Everything with n8n & AI, now has over 650 enrollments and a 4.7-star rating. \"I built the course I wish existed when I was learning,\" she said. \"Every lesson is a workflow I actually shipped for a real client.\"",
    tag: "Community", author: "Saachi AI Team", imageUrl: img("blog-ayesha-story"),
    publishedAt: "2026-07-10T09:00:00.000Z", readTime: "4 min read"
  },
  {
    id: "blog_4", slug: "prompt-engineering-mistakes-beginners-make",
    title: "7 prompt engineering mistakes every beginner makes",
    excerpt: "From vague instructions to missing context - the most common issues we see in student-submitted prompts.",
    body: "After reviewing thousands of student prompt submissions in Prompt Engineering Fundamentals, a few mistakes come up again and again: vague instructions without a clear output format, missing context about the audience or use case, no examples for the model to follow, overly long prompts that bury the actual ask, and forgetting to specify tone or length constraints.\n\nThe fix for most of these is the same: treat your first draft as a rough brief, then rewrite it as if you were handing it to a new employee with zero context.",
    tag: "Fundamentals", author: "Sana Rizvi", imageUrl: img("blog-prompt-mistakes"),
    publishedAt: "2026-06-28T09:00:00.000Z", readTime: "5 min read"
  },
  {
    id: "blog_5", slug: "pricing-your-first-ai-course",
    title: "How to price your first AI course on Saachi AI",
    excerpt: "A practical framework for new instructors deciding between $19, $39, and $59 price points.",
    body: "New instructors consistently ask the same question: how do I price my first course? Our data suggests a simple framework: courses under 2 hours with a narrow, specific outcome (e.g. \"build one WhatsApp bot\") do best at $19-29. Courses in the 3-6 hour range covering a full workflow do best at $39-49. Anything over 6 hours with production-level depth can support $59+.\n\nUnderpricing is the more common mistake - learners often associate price with depth, and a $19 course promising \"master AI automation\" can actually hurt conversion versus a well-scoped $45 course.",
    tag: "Instructors", author: "Zara Farooq", imageUrl: img("blog-pricing-course"),
    publishedAt: "2026-06-14T09:00:00.000Z", readTime: "6 min read"
  },
  {
    id: "blog_6", slug: "whatsapp-ai-bots-for-small-business",
    title: "Why every small business should have a WhatsApp AI bot by 2027",
    excerpt: "Customer support response times are the biggest lever most small businesses aren't pulling yet.",
    body: "For small businesses across Pakistan and South Asia, WhatsApp is often the primary customer support channel - and the primary bottleneck. A well-built AI auto-responder can handle the 60-70% of inbound questions that are repetitive (order status, hours, pricing) while escalating anything complex to a human.\n\nBuild a WhatsApp AI Auto-Responder walks through the exact setup used by three Pakistani D2C brands, including the human handoff logic that keeps customers from getting stuck talking to a bot.",
    tag: "Automation", author: "Bilal Ahmed", imageUrl: img("blog-whatsapp-bots"),
    publishedAt: "2026-05-30T09:00:00.000Z", readTime: "7 min read"
  }
];
'@
Write-Utf8NoBom -Path (Join-Path $apiClientSrc "dummy-data-blog.ts") -Content $blogContent
Write-Host "Created: dummy-data-blog.ts" -ForegroundColor Green

# ------------------------------------------------------------------
# dummy-data-community.ts
# ------------------------------------------------------------------
$communityContent = @'
export type CommunityReply = {
  id: string;
  authorName: string;
  isInstructor: boolean;
  body: string;
  createdAt: string;
};

export type CommunityPost = {
  id: string;
  title: string;
  courseTitle?: string;
  category: string;
  authorName: string;
  body: string;
  createdAt: string;
  upvotes: number;
  replies: CommunityReply[];
};

export const DUMMY_COMMUNITY_POSTS: CommunityPost[] = [
  {
    id: "cmty_1", title: "How many few-shot examples is actually enough?",
    courseTitle: "Prompt Engineering Fundamentals", category: "Prompt Engineering",
    authorName: "Hina Malik",
    body: "For few-shot prompting, how many examples is usually enough before it stops improving results? I've been adding more and more and not seeing much difference past a certain point.",
    createdAt: "2026-08-09T10:00:00.000Z", upvotes: 14,
    replies: [
      { id: "r1", authorName: "Sana Rizvi", isInstructor: true, body: "Usually 3-5 well-chosen examples get you most of the benefit - past that you're often better off improving instructions instead of piling on more examples.", createdAt: "2026-08-09T14:00:00.000Z" },
      { id: "r2", authorName: "Omar Sheikh", isInstructor: false, body: "This matches what I found too. I went from 10 examples down to 4 and got basically the same output quality.", createdAt: "2026-08-10T08:00:00.000Z" }
    ]
  },
  {
    id: "cmty_2", title: "Does the n8n workflow template work outside the self-hosted version?",
    courseTitle: "Automate Everything with n8n & AI", category: "Automation",
    authorName: "Bilal Ahmed",
    body: "I'm using n8n cloud instead of self-hosted. Will the invoice parsing workflow from module 2 work without changes?",
    createdAt: "2026-08-07T09:00:00.000Z", upvotes: 9,
    replies: [
      { id: "r1", authorName: "Ayesha Khan", isInstructor: true, body: "Yes, it should work as-is on n8n cloud. Just double check your OpenAI node has its own credential set up since cloud doesn't share your local .env file.", createdAt: "2026-08-07T15:30:00.000Z" }
    ]
  },
  {
    id: "cmty_3", title: "Best way to structure a portfolio after finishing the design track?",
    courseTitle: "Midjourney for Product Mockups", category: "Design",
    authorName: "Noor Fatima",
    body: "Just finished the course and want to build a portfolio to start pitching freelance clients. Should I show before/after or just the final mockups?",
    createdAt: "2026-08-05T11:20:00.000Z", upvotes: 6,
    replies: []
  },
  {
    id: "cmty_4", title: "WhatsApp Business API approval taking longer than expected",
    courseTitle: "Build a WhatsApp AI Auto-Responder", category: "Support & Communication",
    authorName: "Sara Iqbal",
    body: "It's been 5 days and my WhatsApp Business API application is still pending. Is this normal? The course says it usually takes 1-2 days.",
    createdAt: "2026-08-03T13:00:00.000Z", upvotes: 11,
    replies: [
      { id: "r1", authorName: "Bilal Ahmed", isInstructor: true, body: "It varies a lot by region and business type - I've seen it take anywhere from same-day to 2 weeks. Nothing wrong on your end, just Meta's review queue.", createdAt: "2026-08-03T18:00:00.000Z" }
    ]
  },
  {
    id: "cmty_5", title: "Anyone else finding function/tool calling confusing at first?",
    courseTitle: "Integrating OpenAI & Claude APIs into Node.js Apps", category: "Development",
    authorName: "Ali Raza",
    body: "The tool calling section clicked for me on the second watch but I was pretty lost the first time through. Any extra resources people found helpful?",
    createdAt: "2026-07-30T10:15:00.000Z", upvotes: 8,
    replies: [
      { id: "r1", authorName: "Usman Ali", isInstructor: true, body: "Totally normal - it's the trickiest concept in the course. I'd recommend rebuilding the tool-calling example from scratch without looking at the solution first, that's what made it click for most students.", createdAt: "2026-07-30T16:40:00.000Z" },
      { id: "r2", authorName: "Danish Raza", isInstructor: false, body: "Same experience here, agree with rebuilding it from memory. Took me two tries but it stuck after that.", createdAt: "2026-07-31T09:00:00.000Z" }
    ]
  },
  {
    id: "cmty_6", title: "Is there a study group for the AI Automation track?",
    category: "General",
    authorName: "Fatima Noor",
    body: "Working through the automation certification track solo and wondering if there's an active study group or Discord for people going through it together.",
    createdAt: "2026-07-27T12:00:00.000Z", upvotes: 5,
    replies: []
  },
  {
    id: "cmty_7", title: "How strict is the 30% completion cutoff for refunds?",
    category: "Billing",
    authorName: "Omar Sheikh",
    body: "If I've watched a course but skipped around, does the 30% completion cutoff count time watched or lessons marked complete?",
    createdAt: "2026-07-22T09:30:00.000Z", upvotes: 4,
    replies: [
      { id: "r1", authorName: "Saachi AI Team", isInstructor: true, body: "It's based on lessons marked complete, not total watch time. You can check your exact progress percentage on the course page under My Courses.", createdAt: "2026-07-22T13:00:00.000Z" }
    ]
  },
  {
    id: "cmty_8", title: "Mentorship session was worth every rupee",
    courseTitle: "Automate Everything with n8n & AI", category: "General",
    authorName: "Hina Malik",
    body: "Just wanted to share - booked a 30 min mentorship session with Ayesha after finishing the course and it saved me hours of debugging on a client project. Highly recommend if you're on the fence.",
    createdAt: "2026-07-18T10:00:00.000Z", upvotes: 19,
    replies: [
      { id: "r1", authorName: "Ayesha Khan", isInstructor: true, body: "Thank you for the kind words! Always happy to help debug real client workflows.", createdAt: "2026-07-18T14:00:00.000Z" }
    ]
  }
];
'@
Write-Utf8NoBom -Path (Join-Path $apiClientSrc "dummy-data-community.ts") -Content $communityContent
Write-Host "Created: dummy-data-community.ts" -ForegroundColor Green

# ------------------------------------------------------------------
# dummy-data-certificates.ts
# ------------------------------------------------------------------
$certificatesContent = @'
export type CertificateRecord = {
  id: string;
  verificationId: string;
  courseTitle: string;
  courseSlug: string;
  learnerName: string;
  instructorName: string;
  issuedAt: string;
  category: string;
};

export const DUMMY_CERTIFICATES: CertificateRecord[] = [
  { id: "cert_1", verificationId: "SAI-8H2K1F", courseTitle: "Prompt Engineering Fundamentals", courseSlug: "prompt-engineering-fundamentals", learnerName: "Hina Malik", instructorName: "Sana Rizvi", issuedAt: "2026-07-20T00:00:00.000Z", category: "AI Fundamentals & Prompt Engineering" },
  { id: "cert_2", verificationId: "SAI-4M9P2Q", courseTitle: "AI-Powered Marketing Campaigns", courseSlug: "ai-powered-marketing-campaigns", learnerName: "Omar Sheikh", instructorName: "Zara Farooq", issuedAt: "2026-07-12T00:00:00.000Z", category: "AI for Marketing & Sales" },
  { id: "cert_3", verificationId: "SAI-9X3R7T", courseTitle: "Automate Everything with n8n & AI", courseSlug: "automate-everything-with-n8n-and-ai", learnerName: "Fatima Noor", instructorName: "Ayesha Khan", issuedAt: "2026-06-30T00:00:00.000Z", category: "AI Automation & Workflow Tools" },
  { id: "cert_4", verificationId: "SAI-2L6W4E", courseTitle: "Build a WhatsApp AI Auto-Responder", courseSlug: "build-a-whatsapp-ai-auto-responder", learnerName: "Sara Iqbal", instructorName: "Bilal Ahmed", issuedAt: "2026-06-18T00:00:00.000Z", category: "AI Customer Support & Communication" },
  { id: "cert_5", verificationId: "SAI-7Y1N8D", courseTitle: "Ship Your First AI-Powered Web App", courseSlug: "ship-your-first-ai-powered-web-app", learnerName: "Noor Fatima", instructorName: "Hamza Tariq", issuedAt: "2026-06-05T00:00:00.000Z", category: "AI Website & App Development" },
  { id: "cert_6", verificationId: "SAI-5K3B9C", courseTitle: "Integrating OpenAI & Claude APIs into Node.js Apps", courseSlug: "integrating-openai-and-claude-apis-into-node", learnerName: "Ali Raza", instructorName: "Usman Ali", issuedAt: "2026-05-22T00:00:00.000Z", category: "AI Integration for Developers" },
  { id: "cert_7", verificationId: "SAI-1Q8Z5A", courseTitle: "Prompt Engineering Fundamentals", courseSlug: "prompt-engineering-fundamentals", learnerName: "Mahnoor Fatima", instructorName: "Sana Rizvi", issuedAt: "2026-05-10T00:00:00.000Z", category: "AI Fundamentals & Prompt Engineering" },
  { id: "cert_8", verificationId: "SAI-6T2H4J", courseTitle: "Automate Everything with n8n & AI", courseSlug: "automate-everything-with-n8n-and-ai", learnerName: "Danish Raza", instructorName: "Ayesha Khan", issuedAt: "2026-04-28T00:00:00.000Z", category: "AI Automation & Workflow Tools" }
];
'@
Write-Utf8NoBom -Path (Join-Path $apiClientSrc "dummy-data-certificates.ts") -Content $certificatesContent
Write-Host "Created: dummy-data-certificates.ts" -ForegroundColor Green

Write-Host "`n=== PHASE 2: Hooks ===" -ForegroundColor Cyan

# ------------------------------------------------------------------
# useContentHubs.ts - hooks for news/blog/community/certificates
# ------------------------------------------------------------------
$hooksContent = @'
"use client";

import { useQuery } from "@tanstack/react-query";
import { DUMMY_NEWS, type NewsArticle } from "../dummy-data-news";
import { DUMMY_BLOG_POSTS, type BlogPost } from "../dummy-data-blog";
import { DUMMY_COMMUNITY_POSTS, type CommunityPost } from "../dummy-data-community";
import { DUMMY_CERTIFICATES, type CertificateRecord } from "../dummy-data-certificates";

function delay<T>(value: T, ms = 300): Promise<T> {
  return new Promise((resolve) => setTimeout(() => resolve(value), ms));
}

export type ContentSearchFilters = { search?: string };

export function useNewsList(filters: ContentSearchFilters = {}) {
  return useQuery({
    queryKey: ["news", "list", filters],
    queryFn: async () => {
      let items = [...DUMMY_NEWS];
      if (filters.search) {
        const q = filters.search.toLowerCase();
        items = items.filter((n) => n.title.toLowerCase().includes(q) || n.excerpt.toLowerCase().includes(q) || n.category.toLowerCase().includes(q));
      }
      return delay(items);
    }
  });
}

export function useNewsDetail(slug: string) {
  return useQuery({
    queryKey: ["news", "detail", slug],
    queryFn: async () => {
      const found = DUMMY_NEWS.find((n) => n.slug === slug);
      if (!found) throw new Error("Article not found");
      return delay(found);
    },
    enabled: Boolean(slug)
  });
}

export function useBlogList(filters: ContentSearchFilters = {}) {
  return useQuery({
    queryKey: ["blog", "list", filters],
    queryFn: async () => {
      let items = [...DUMMY_BLOG_POSTS];
      if (filters.search) {
        const q = filters.search.toLowerCase();
        items = items.filter((b) => b.title.toLowerCase().includes(q) || b.excerpt.toLowerCase().includes(q) || b.tag.toLowerCase().includes(q));
      }
      return delay(items);
    }
  });
}

export function useBlogDetail(slug: string) {
  return useQuery({
    queryKey: ["blog", "detail", slug],
    queryFn: async () => {
      const found = DUMMY_BLOG_POSTS.find((b) => b.slug === slug);
      if (!found) throw new Error("Post not found");
      return delay(found);
    },
    enabled: Boolean(slug)
  });
}

export function useCommunityList(filters: ContentSearchFilters = {}) {
  return useQuery({
    queryKey: ["community", "list", filters],
    queryFn: async () => {
      let items = [...DUMMY_COMMUNITY_POSTS];
      if (filters.search) {
        const q = filters.search.toLowerCase();
        items = items.filter((c) => c.title.toLowerCase().includes(q) || c.body.toLowerCase().includes(q) || c.category.toLowerCase().includes(q));
      }
      return delay(items);
    }
  });
}

export function useCommunityDetail(id: string) {
  return useQuery({
    queryKey: ["community", "detail", id],
    queryFn: async () => {
      const found = DUMMY_COMMUNITY_POSTS.find((c) => c.id === id);
      if (!found) throw new Error("Post not found");
      return delay(found);
    },
    enabled: Boolean(id)
  });
}

export function useCertificateList(filters: ContentSearchFilters = {}) {
  return useQuery({
    queryKey: ["certificates", "list", filters],
    queryFn: async () => {
      let items = [...DUMMY_CERTIFICATES];
      if (filters.search) {
        const q = filters.search.toLowerCase();
        items = items.filter((c) => c.courseTitle.toLowerCase().includes(q) || c.learnerName.toLowerCase().includes(q) || c.category.toLowerCase().includes(q));
      }
      return delay(items);
    }
  });
}

export type { NewsArticle, BlogPost, CommunityPost, CertificateRecord };
'@
Write-Utf8NoBom -Path (Join-Path $apiClientSrc "hooks\useContentHubs.ts") -Content $hooksContent
Write-Host "Created: hooks/useContentHubs.ts" -ForegroundColor Green

# --- wire new exports into api-client index.ts ---
$apiIndexPath = Join-Path $apiClientSrc "index.ts"
$apiIndexContent = [System.IO.File]::ReadAllText($apiIndexPath)
$newExports = @'

export * from "./dummy-data-news";
export * from "./dummy-data-blog";
export * from "./dummy-data-community";
export * from "./dummy-data-certificates";
export * from "./hooks/useContentHubs";
'@
if ($apiIndexContent -notmatch [regex]::Escape('useContentHubs')) {
    $apiIndexContent = $apiIndexContent.TrimEnd() + "`r`n" + $newExports
    Write-Utf8NoBom -Path $apiIndexPath -Content $apiIndexContent
    Write-Host "Updated: packages/api-client/src/index.ts" -ForegroundColor Green
} else {
    Write-Host "api-client index.ts already exports content hubs, skipping." -ForegroundColor Yellow
}

Write-Host "`n=== PHASE 3: Pages ===" -ForegroundColor Cyan

$marketingApp = Join-Path $webApp "app\(marketing)"

# --- /news list page ---
$newsListContent = @'
"use client";

import Link from "next/link";
import { useState } from "react";
import { Newspaper } from "lucide-react";
import { useNewsList } from "@saachi/api-client";
import { Input, Loading, EmptyState } from "@saachi/ui";

export default function NewsListPage() {
  const [search, setSearch] = useState("");
  const { data, isLoading } = useNewsList({ search: search || undefined });

  return (
    <div className="mx-auto max-w-6xl px-4 py-14 md:px-8">
      <div className="mb-8 flex items-center gap-2">
        <Newspaper size={22} className="text-accent-violet" />
        <h1 className="font-display text-[28px] font-bold text-ink">News</h1>
      </div>
      <Input
        placeholder="Search news..."
        value={search}
        onChange={(e) => setSearch(e.target.value)}
        className="mb-8 max-w-sm"
      />

      {isLoading ? (
        <Loading label="Loading news..." />
      ) : !data || data.length === 0 ? (
        <EmptyState title="No articles found" description="Try a different search term." />
      ) : (
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {data.map((article) => (
            <Link
              key={article.id}
              href={`/news/${article.slug}`}
              className="group overflow-hidden rounded-card border border-line bg-card transition-all hover:-translate-y-1 hover:shadow-lg"
            >
              <div className="aspect-video w-full overflow-hidden">
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img src={article.imageUrl} alt={article.title} className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105" />
              </div>
              <div className="p-5">
                <div className="mb-2 flex items-center justify-between">
                  <span className="rounded-full bg-gold-tint px-2.5 py-0.5 text-[10.5px] font-semibold text-gold-dark">{article.category}</span>
                  <span className="text-[11.5px] text-ink-soft">{article.readTime}</span>
                </div>
                <h3 className="line-clamp-2 text-[15px] font-semibold leading-snug text-ink">{article.title}</h3>
                <p className="mt-2 line-clamp-2 text-[13px] text-ink-soft">{article.excerpt}</p>
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
'@
Write-Utf8NoBom -Path (Join-Path $marketingApp "news\page.tsx") -Content $newsListContent
Write-Host "Created: (marketing)/news/page.tsx" -ForegroundColor Green

# --- /news/[slug] detail page ---
$newsDetailContent = @'
"use client";

import { use } from "react";
import Link from "next/link";
import { ArrowLeft } from "lucide-react";
import { useNewsDetail } from "@saachi/api-client";
import { Loading, EmptyState, Button } from "@saachi/ui";

export default function NewsDetailPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = use(params);
  const { data: article, isLoading } = useNewsDetail(slug);

  if (isLoading) return <Loading label="Loading article..." fullScreen />;
  if (!article) {
    return (
      <div className="mx-auto max-w-2xl px-4 py-24">
        <EmptyState title="Article not found" description="This news article may have been removed." action={<Link href="/news"><Button>Back to news</Button></Link>} />
      </div>
    );
  }

  return (
    <article className="mx-auto max-w-3xl px-4 py-14 md:px-0">
      <Link href="/news" className="mb-6 inline-flex items-center gap-1.5 text-[13px] font-medium text-ink-soft hover:text-ink">
        <ArrowLeft size={14} /> Back to news
      </Link>

      <span className="mb-3 inline-block rounded-full bg-gold-tint px-2.5 py-0.5 text-[10.5px] font-semibold text-gold-dark">{article.category}</span>
      <h1 className="mb-3 font-display text-[30px] font-bold leading-tight text-ink md:text-[38px]">{article.title}</h1>
      <p className="mb-6 text-[13px] text-ink-soft">
        {article.author} - {new Intl.DateTimeFormat("en-US", { dateStyle: "medium" }).format(new Date(article.publishedAt))} - {article.readTime}
      </p>

      <div className="mb-8 aspect-video w-full overflow-hidden rounded-card">
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img src={article.imageUrl} alt={article.title} className="h-full w-full object-cover" />
      </div>

      <div className="flex flex-col gap-4 text-[15px] leading-relaxed text-ink-soft">
        {article.body.split("\n\n").map((para, i) => (
          <p key={i}>{para}</p>
        ))}
      </div>
    </article>
  );
}
'@
Write-Utf8NoBom -Path (Join-Path $marketingApp "news\[slug]\page.tsx") -Content $newsDetailContent
Write-Host "Created: (marketing)/news/[slug]/page.tsx" -ForegroundColor Green

# --- /blog list page ---
$blogListContent = @'
"use client";

import Link from "next/link";
import { useState } from "react";
import { BookOpen } from "lucide-react";
import { useBlogList } from "@saachi/api-client";
import { Input, Loading, EmptyState } from "@saachi/ui";

export default function BlogListPage() {
  const [search, setSearch] = useState("");
  const { data, isLoading } = useBlogList({ search: search || undefined });

  return (
    <div className="mx-auto max-w-6xl px-4 py-14 md:px-8">
      <div className="mb-8 flex items-center gap-2">
        <BookOpen size={22} className="text-accent-violet" />
        <h1 className="font-display text-[28px] font-bold text-ink">Blog</h1>
      </div>
      <Input
        placeholder="Search blog posts..."
        value={search}
        onChange={(e) => setSearch(e.target.value)}
        className="mb-8 max-w-sm"
      />

      {isLoading ? (
        <Loading label="Loading posts..." />
      ) : !data || data.length === 0 ? (
        <EmptyState title="No posts found" description="Try a different search term." />
      ) : (
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {data.map((post) => (
            <Link
              key={post.id}
              href={`/blog/${post.slug}`}
              className="group overflow-hidden rounded-card border border-line bg-card transition-all hover:-translate-y-1 hover:shadow-lg"
            >
              <div className="aspect-video w-full overflow-hidden">
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img src={post.imageUrl} alt={post.title} className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105" />
              </div>
              <div className="p-5">
                <div className="mb-2 flex items-center justify-between">
                  <span className="rounded-full bg-gold-tint px-2.5 py-0.5 text-[10.5px] font-semibold text-gold-dark">{post.tag}</span>
                  <span className="text-[11.5px] text-ink-soft">{post.readTime}</span>
                </div>
                <h3 className="line-clamp-2 text-[15px] font-semibold leading-snug text-ink">{post.title}</h3>
                <p className="mt-2 line-clamp-2 text-[13px] text-ink-soft">{post.excerpt}</p>
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
'@
Write-Utf8NoBom -Path (Join-Path $marketingApp "blog\page.tsx") -Content $blogListContent
Write-Host "Created: (marketing)/blog/page.tsx" -ForegroundColor Green

# --- /blog/[slug] detail page ---
$blogDetailContent = @'
"use client";

import { use } from "react";
import Link from "next/link";
import { ArrowLeft } from "lucide-react";
import { useBlogDetail } from "@saachi/api-client";
import { Loading, EmptyState, Button } from "@saachi/ui";

export default function BlogDetailPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = use(params);
  const { data: post, isLoading } = useBlogDetail(slug);

  if (isLoading) return <Loading label="Loading post..." fullScreen />;
  if (!post) {
    return (
      <div className="mx-auto max-w-2xl px-4 py-24">
        <EmptyState title="Post not found" description="This blog post may have been removed." action={<Link href="/blog"><Button>Back to blog</Button></Link>} />
      </div>
    );
  }

  return (
    <article className="mx-auto max-w-3xl px-4 py-14 md:px-0">
      <Link href="/blog" className="mb-6 inline-flex items-center gap-1.5 text-[13px] font-medium text-ink-soft hover:text-ink">
        <ArrowLeft size={14} /> Back to blog
      </Link>

      <span className="mb-3 inline-block rounded-full bg-gold-tint px-2.5 py-0.5 text-[10.5px] font-semibold text-gold-dark">{post.tag}</span>
      <h1 className="mb-3 font-display text-[30px] font-bold leading-tight text-ink md:text-[38px]">{post.title}</h1>
      <p className="mb-6 text-[13px] text-ink-soft">
        {post.author} - {new Intl.DateTimeFormat("en-US", { dateStyle: "medium" }).format(new Date(post.publishedAt))} - {post.readTime}
      </p>

      <div className="mb-8 aspect-video w-full overflow-hidden rounded-card">
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img src={post.imageUrl} alt={post.title} className="h-full w-full object-cover" />
      </div>

      <div className="flex flex-col gap-4 text-[15px] leading-relaxed text-ink-soft">
        {post.body.split("\n\n").map((para, i) => (
          <p key={i}>{para}</p>
        ))}
      </div>
    </article>
  );
}
'@
Write-Utf8NoBom -Path (Join-Path $marketingApp "blog\[slug]\page.tsx") -Content $blogDetailContent
Write-Host "Created: (marketing)/blog/[slug]/page.tsx" -ForegroundColor Green

# --- /community list page ---
$communityListContent = @'
"use client";

import Link from "next/link";
import { useState } from "react";
import { Users, MessageCircle, ArrowBigUp } from "lucide-react";
import { useCommunityList } from "@saachi/api-client";
import { Input, Loading, EmptyState } from "@saachi/ui";

export default function CommunityListPage() {
  const [search, setSearch] = useState("");
  const { data, isLoading } = useCommunityList({ search: search || undefined });

  return (
    <div className="mx-auto max-w-4xl px-4 py-14 md:px-8">
      <div className="mb-8 flex items-center gap-2">
        <Users size={22} className="text-accent-violet" />
        <h1 className="font-display text-[28px] font-bold text-ink">Community</h1>
      </div>
      <Input
        placeholder="Search discussions..."
        value={search}
        onChange={(e) => setSearch(e.target.value)}
        className="mb-8 max-w-sm"
      />

      {isLoading ? (
        <Loading label="Loading discussions..." />
      ) : !data || data.length === 0 ? (
        <EmptyState title="No discussions found" description="Try a different search term." />
      ) : (
        <div className="flex flex-col gap-3">
          {data.map((post) => (
            <Link
              key={post.id}
              href={`/community/${post.id}`}
              className="flex items-start gap-4 rounded-card border border-line bg-card p-5 transition-colors hover:border-gold-dark/40"
            >
              <div className="flex shrink-0 flex-col items-center gap-1 text-ink-soft">
                <ArrowBigUp size={18} />
                <span className="text-[12px] font-semibold">{post.upvotes}</span>
              </div>
              <div className="min-w-0 flex-1">
                <div className="mb-1 flex flex-wrap items-center gap-2">
                  <span className="rounded-full bg-gold-tint px-2.5 py-0.5 text-[10.5px] font-semibold text-gold-dark">{post.category}</span>
                  {post.courseTitle && <span className="text-[11.5px] text-ink-soft">{post.courseTitle}</span>}
                </div>
                <h3 className="text-[15px] font-semibold text-ink">{post.title}</h3>
                <p className="mt-1 line-clamp-2 text-[13px] text-ink-soft">{post.body}</p>
                <div className="mt-2 flex items-center gap-3 text-[12px] text-ink-soft">
                  <span>{post.authorName}</span>
                  <span className="flex items-center gap-1">
                    <MessageCircle size={12} /> {post.replies.length}
                  </span>
                </div>
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
'@
Write-Utf8NoBom -Path (Join-Path $marketingApp "community\page.tsx") -Content $communityListContent
Write-Host "Created: (marketing)/community/page.tsx" -ForegroundColor Green

# --- /community/[id] detail (thread) page ---
$communityDetailContent = @'
"use client";

import { use } from "react";
import Link from "next/link";
import { ArrowLeft, ArrowBigUp, BadgeCheck } from "lucide-react";
import { useCommunityDetail } from "@saachi/api-client";
import { Loading, EmptyState, Button } from "@saachi/ui";

export default function CommunityDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const { data: post, isLoading } = useCommunityDetail(id);

  if (isLoading) return <Loading label="Loading discussion..." fullScreen />;
  if (!post) {
    return (
      <div className="mx-auto max-w-2xl px-4 py-24">
        <EmptyState title="Discussion not found" description="This community post may have been removed." action={<Link href="/community"><Button>Back to community</Button></Link>} />
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-3xl px-4 py-14 md:px-0">
      <Link href="/community" className="mb-6 inline-flex items-center gap-1.5 text-[13px] font-medium text-ink-soft hover:text-ink">
        <ArrowLeft size={14} /> Back to community
      </Link>

      <div className="mb-2 flex flex-wrap items-center gap-2">
        <span className="rounded-full bg-gold-tint px-2.5 py-0.5 text-[10.5px] font-semibold text-gold-dark">{post.category}</span>
        {post.courseTitle && <span className="text-[12px] text-ink-soft">{post.courseTitle}</span>}
      </div>
      <h1 className="mb-3 font-display text-[26px] font-bold leading-tight text-ink md:text-[32px]">{post.title}</h1>

      <div className="mb-6 flex items-center gap-4 rounded-card border border-line bg-card p-5">
        <div className="flex shrink-0 flex-col items-center gap-1 text-ink-soft">
          <ArrowBigUp size={18} />
          <span className="text-[12px] font-semibold">{post.upvotes}</span>
        </div>
        <div>
          <p className="text-[13px] font-semibold text-ink">{post.authorName}</p>
          <p className="mt-2 text-[14.5px] leading-relaxed text-ink-soft">{post.body}</p>
        </div>
      </div>

      <h2 className="mb-4 text-[15px] font-semibold text-ink">{post.replies.length} repl{post.replies.length === 1 ? "y" : "ies"}</h2>
      <div className="flex flex-col gap-3">
        {post.replies.map((reply) => (
          <div key={reply.id} className="rounded-card border border-line bg-card p-4">
            <div className="mb-1 flex items-center gap-1.5">
              <span className="text-[13px] font-semibold text-ink">{reply.authorName}</span>
              {reply.isInstructor && <BadgeCheck size={13} className="text-teal" />}
            </div>
            <p className="text-[13.5px] text-ink-soft">{reply.body}</p>
          </div>
        ))}
        {post.replies.length === 0 && (
          <p className="text-[13px] text-ink-soft">No replies yet.</p>
        )}
      </div>
    </div>
  );
}
'@
Write-Utf8NoBom -Path (Join-Path $marketingApp "community\[id]\page.tsx") -Content $communityDetailContent
Write-Host "Created: (marketing)/community/[id]/page.tsx" -ForegroundColor Green

Write-Host "`n=== PHASE 4: TopSearchBar overhaul (all sources + open-on-click) ===" -ForegroundColor Cyan

$searchBarPath = Join-Path $webApp "app\_components\TopSearchBar.tsx"
$searchBarContent = @'
"use client";

import { useEffect, useMemo, useRef, useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import {
  Search,
  ChevronDown,
  GraduationCap,
  Award,
  Newspaper,
  BookOpen,
  Users,
  ArrowUpRight
} from "lucide-react";
import { cn } from "@/lib/utils";
import {
  useCourseList,
  useNewsList,
  useBlogList,
  useCommunityList,
  useCertificateList
} from "@saachi/api-client";
import { CATEGORIES } from "../../lib/categories";

type FilterOption = { value: string; label: string; icon: typeof Search };

const FILTERS: FilterOption[] = [
  { value: "all", label: "All", icon: Search },
  { value: "courses", label: "Courses", icon: GraduationCap },
  { value: "certificates", label: "Certificates", icon: Award },
  { value: "news", label: "News", icon: Newspaper },
  { value: "blog", label: "Blog", icon: BookOpen },
  { value: "community", label: "Community", icon: Users }
];

function useHideOnScroll() {
  const [hidden, setHidden] = useState(false);
  const lastY = useRef(0);
  useEffect(() => {
    lastY.current = window.scrollY;
    function onScroll() {
      const y = window.scrollY;
      const goingDown = y > lastY.current;
      setHidden(goingDown && y > 80);
      lastY.current = y;
    }
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);
  return hidden;
}

export function TopSearchBar() {
  const router = useRouter();
  const hidden = useHideOnScroll();

  const [query, setQuery] = useState("");
  const [activeFilter, setActiveFilter] = useState("all");
  const [deptOpen, setDeptOpen] = useState(false);
  const [department, setDepartment] = useState<string | undefined>(undefined);
  const [dropdownOpen, setDropdownOpen] = useState(false);

  const wrapperRef = useRef<HTMLDivElement>(null);
  const deptRef = useRef<HTMLDivElement>(null);

  const courseQuery = useCourseList({ search: query.trim() || undefined, category: department, sort: "popular" });
  const newsQuery = useNewsList({ search: query.trim() || undefined });
  const blogQuery = useBlogList({ search: query.trim() || undefined });
  const communityQuery = useCommunityList({ search: query.trim() || undefined });
  const certQuery = useCertificateList({ search: query.trim() || undefined });

  const courseResults = useMemo(() => (courseQuery.data?.items ?? []).slice(0, 4), [courseQuery.data]);
  const newsResults = useMemo(() => (newsQuery.data ?? []).slice(0, 3), [newsQuery.data]);
  const blogResults = useMemo(() => (blogQuery.data ?? []).slice(0, 3), [blogQuery.data]);
  const communityResults = useMemo(() => (communityQuery.data ?? []).slice(0, 3), [communityQuery.data]);
  const certResults = useMemo(() => (certQuery.data ?? []).slice(0, 3), [certQuery.data]);

  const showCourses = activeFilter === "all" || activeFilter === "courses";
  const showNews = activeFilter === "all" || activeFilter === "news";
  const showBlog = activeFilter === "all" || activeFilter === "blog";
  const showCommunity = activeFilter === "all" || activeFilter === "community";
  const showCerts = activeFilter === "all" || activeFilter === "certificates";

  const totalResults =
    (showCourses ? courseResults.length : 0) +
    (showNews ? newsResults.length : 0) +
    (showBlog ? blogResults.length : 0) +
    (showCommunity ? communityResults.length : 0) +
    (showCerts ? certResults.length : 0);

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (wrapperRef.current && !wrapperRef.current.contains(e.target as Node)) setDropdownOpen(false);
      if (deptRef.current && !deptRef.current.contains(e.target as Node)) setDeptOpen(false);
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    const params = new URLSearchParams();
    if (query.trim()) params.set("q", query.trim());
    if (activeFilter !== "all") params.set("type", activeFilter);
    if (department) params.set("category", department);
    router.push(`/search?${params.toString()}`);
    setDropdownOpen(false);
  }

  const departmentLabel = department ? CATEGORIES.find((c) => c.id === department)?.name ?? "Department" : "All departments";

  return (
    <div
      className={cn(
        "sticky top-16 z-30 border-b border-black/10 transition-transform duration-300 ease-out",
        hidden ? "-translate-y-full" : "translate-y-0"
      )}
      style={{ backgroundImage: "var(--color-accent-gradient)" }}
    >
      <div className="mx-auto flex max-w-7xl flex-col gap-3 px-4 py-3.5 md:px-8">
        <form onSubmit={handleSubmit} className="flex items-center gap-2.5">
          <div ref={wrapperRef} className="relative w-full max-w-md">
            <div className="flex h-11 items-center gap-2 rounded-full border border-white/25 bg-white pl-4 pr-2 shadow-sm">
              <Search size={16} className="shrink-0 text-ink-soft" />
              <input
                value={query}
                onChange={(e) => {
                  setQuery(e.target.value);
                  setDropdownOpen(true);
                }}
                onFocus={() => setDropdownOpen(true)}
                onClick={() => setDropdownOpen(true)}
                placeholder="Search courses, certificates, news..."
                className="w-full bg-transparent text-[13.5px] text-ink placeholder:text-ink-soft/60 focus:outline-none"
              />

              <div ref={deptRef} className="relative shrink-0">
                <button
                  type="button"
                  onClick={() => setDeptOpen((v) => !v)}
                  className="flex items-center gap-1 rounded-full bg-paper-dim px-2.5 py-1.5 text-[11px] font-semibold text-ink-soft transition-colors hover:text-ink"
                >
                  <span className="hidden max-w-[90px] truncate sm:inline">{departmentLabel}</span>
                  <ChevronDown size={13} className={cn("transition-transform duration-200", deptOpen && "rotate-180")} />
                </button>

                {deptOpen && (
                  <div className="absolute right-0 top-[calc(100%+8px)] z-40 w-56 overflow-hidden rounded-card border border-line bg-card shadow-lg">
                    <button
                      type="button"
                      onClick={() => { setDepartment(undefined); setDeptOpen(false); }}
                      className={cn("flex w-full items-center px-4 py-2.5 text-left text-[13px] transition-colors hover:bg-paper-dim", !department ? "font-semibold text-accent-violet" : "text-ink")}
                    >
                      All departments
                    </button>
                    {CATEGORIES.map((cat) => (
                      <button
                        key={cat.id}
                        type="button"
                        onClick={() => { setDepartment(cat.id); setDeptOpen(false); }}
                        className={cn("flex w-full items-center px-4 py-2.5 text-left text-[13px] transition-colors hover:bg-paper-dim", department === cat.id ? "font-semibold text-accent-violet" : "text-ink")}
                      >
                        {cat.name}
                      </button>
                    ))}
                  </div>
                )}
              </div>
            </div>

            {dropdownOpen && (
              <div className="absolute left-0 right-0 top-[calc(100%+8px)] z-40 overflow-hidden rounded-card border border-line bg-card shadow-xl">
                {totalResults === 0 ? (
                  <div className="px-4 py-6 text-center text-[13px] text-ink-soft">
                    {query.trim() ? `No results found for "${query}".` : "Start typing to search across the whole platform."}
                  </div>
                ) : (
                  <div className="max-h-96 overflow-y-auto">
                    {showCourses && courseResults.length > 0 && (
                      <div>
                        <p className="px-4 pt-3 pb-1 text-[10.5px] font-semibold uppercase tracking-wide text-ink-soft/60">Courses</p>
                        {courseResults.map((course) => (
                          <Link key={course.id} href={`/courses/${course.slug}`} onClick={() => setDropdownOpen(false)} className="flex items-center justify-between gap-3 px-4 py-2.5 transition-colors hover:bg-paper-dim">
                            <div className="flex min-w-0 items-center gap-2">
                              <GraduationCap size={14} className="shrink-0 text-accent-violet" />
                              <span className="truncate text-[13px] font-medium text-ink">{course.title}</span>
                            </div>
                            <ArrowUpRight size={13} className="shrink-0 text-ink-soft" />
                          </Link>
                        ))}
                      </div>
                    )}
                    {showNews && newsResults.length > 0 && (
                      <div>
                        <p className="px-4 pt-3 pb-1 text-[10.5px] font-semibold uppercase tracking-wide text-ink-soft/60">News</p>
                        {newsResults.map((article) => (
                          <Link key={article.id} href={`/news/${article.slug}`} onClick={() => setDropdownOpen(false)} className="flex items-center justify-between gap-3 px-4 py-2.5 transition-colors hover:bg-paper-dim">
                            <div className="flex min-w-0 items-center gap-2">
                              <Newspaper size={14} className="shrink-0 text-accent-violet" />
                              <span className="truncate text-[13px] font-medium text-ink">{article.title}</span>
                            </div>
                            <ArrowUpRight size={13} className="shrink-0 text-ink-soft" />
                          </Link>
                        ))}
                      </div>
                    )}
                    {showBlog && blogResults.length > 0 && (
                      <div>
                        <p className="px-4 pt-3 pb-1 text-[10.5px] font-semibold uppercase tracking-wide text-ink-soft/60">Blog</p>
                        {blogResults.map((post) => (
                          <Link key={post.id} href={`/blog/${post.slug}`} onClick={() => setDropdownOpen(false)} className="flex items-center justify-between gap-3 px-4 py-2.5 transition-colors hover:bg-paper-dim">
                            <div className="flex min-w-0 items-center gap-2">
                              <BookOpen size={14} className="shrink-0 text-accent-violet" />
                              <span className="truncate text-[13px] font-medium text-ink">{post.title}</span>
                            </div>
                            <ArrowUpRight size={13} className="shrink-0 text-ink-soft" />
                          </Link>
                        ))}
                      </div>
                    )}
                    {showCommunity && communityResults.length > 0 && (
                      <div>
                        <p className="px-4 pt-3 pb-1 text-[10.5px] font-semibold uppercase tracking-wide text-ink-soft/60">Community</p>
                        {communityResults.map((post) => (
                          <Link key={post.id} href={`/community/${post.id}`} onClick={() => setDropdownOpen(false)} className="flex items-center justify-between gap-3 px-4 py-2.5 transition-colors hover:bg-paper-dim">
                            <div className="flex min-w-0 items-center gap-2">
                              <Users size={14} className="shrink-0 text-accent-violet" />
                              <span className="truncate text-[13px] font-medium text-ink">{post.title}</span>
                            </div>
                            <ArrowUpRight size={13} className="shrink-0 text-ink-soft" />
                          </Link>
                        ))}
                      </div>
                    )}
                    {showCerts && certResults.length > 0 && (
                      <div>
                        <p className="px-4 pt-3 pb-1 text-[10.5px] font-semibold uppercase tracking-wide text-ink-soft/60">Certificates</p>
                        {certResults.map((cert) => (
                          <Link key={cert.id} href={`/certificates/${cert.id}`} onClick={() => setDropdownOpen(false)} className="flex items-center justify-between gap-3 px-4 py-2.5 transition-colors hover:bg-paper-dim">
                            <div className="flex min-w-0 items-center gap-2">
                              <Award size={14} className="shrink-0 text-accent-violet" />
                              <span className="truncate text-[13px] font-medium text-ink">{cert.courseTitle} - {cert.learnerName}</span>
                            </div>
                            <ArrowUpRight size={13} className="shrink-0 text-ink-soft" />
                          </Link>
                        ))}
                      </div>
                    )}
                  </div>
                )}
                {query.trim() && (
                  <Link
                    href={`/search?q=${encodeURIComponent(query)}${activeFilter !== "all" ? `&type=${activeFilter}` : ""}${department ? `&category=${department}` : ""}`}
                    onClick={() => setDropdownOpen(false)}
                    className="flex items-center justify-center gap-2 border-t border-line bg-paper-dim px-4 py-2.5 text-[12px] font-semibold text-accent-violet hover:underline"
                  >
                    See all results for &quot;{query}&quot;
                  </Link>
                )}
              </div>
            )}
          </div>

          <button type="submit" className="group/searchbtn relative hidden h-11 shrink-0 items-center gap-1.5 overflow-hidden rounded-full bg-zinc-900 px-5 sm:flex">
            <span className="absolute inset-0 bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500 opacity-50 blur transition-opacity duration-500 group-hover/searchbtn:opacity-90" />
            <span className="relative flex items-center gap-1.5 text-[13px] font-semibold text-white">
              <Search size={14} />
              Search
            </span>
          </button>
        </form>

        <div className="flex flex-wrap items-center gap-2">
          {FILTERS.map((filter) => {
            const Icon = filter.icon;
            const active = activeFilter === filter.value;
            return (
              <button
                key={filter.value}
                type="button"
                onClick={() => setActiveFilter(filter.value)}
                className={cn(
                  "flex items-center gap-1.5 rounded-full border px-3.5 py-1.5 text-[12.5px] font-semibold transition-all duration-150",
                  active ? "border-white bg-white text-ink shadow-sm" : "border-white/40 bg-white/10 text-white/90 hover:border-white/70 hover:bg-white/20"
                )}
              >
                <Icon size={13} />
                {filter.label}
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}

export default TopSearchBar;
'@
Write-Utf8NoBom -Path $searchBarPath -Content $searchBarContent
Write-Host "Updated: TopSearchBar.tsx (all sources + click-to-open)" -ForegroundColor Green

Write-Host "`n=== PHASE 5: /search page overhaul ===" -ForegroundColor Cyan

$searchPagePath = Join-Path $marketingApp "search\page.tsx"
$searchPageContent = @'
"use client";

import { Suspense, useState } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import Link from "next/link";
import { Search as SearchIcon, GraduationCap, Award, Newspaper, BookOpen, Users } from "lucide-react";
import {
  useCourseList,
  useNewsList,
  useBlogList,
  useCommunityList,
  useCertificateList
} from "@saachi/api-client";
import { CourseCard, EmptyState, Input, Loading, cn } from "@saachi/ui";

const TABS = [
  { value: "all", label: "All", icon: SearchIcon },
  { value: "courses", label: "Courses", icon: GraduationCap },
  { value: "news", label: "News", icon: Newspaper },
  { value: "blog", label: "Blog", icon: BookOpen },
  { value: "community", label: "Community", icon: Users },
  { value: "certificates", label: "Certificates", icon: Award }
];

function SearchResults() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const initialQuery = searchParams.get("q") ?? "";
  const initialType = searchParams.get("type") ?? "all";
  const [query, setQuery] = useState(initialQuery);
  const [tab, setTab] = useState(initialType);

  const courseQuery = useCourseList({ search: initialQuery || undefined });
  const newsQuery = useNewsList({ search: initialQuery || undefined });
  const blogQuery = useBlogList({ search: initialQuery || undefined });
  const communityQuery = useCommunityList({ search: initialQuery || undefined });
  const certQuery = useCertificateList({ search: initialQuery || undefined });

  const isLoading = courseQuery.isLoading || newsQuery.isLoading || blogQuery.isLoading || communityQuery.isLoading || certQuery.isLoading;

  const courses = courseQuery.data?.items ?? [];
  const news = newsQuery.data ?? [];
  const blog = blogQuery.data ?? [];
  const community = communityQuery.data ?? [];
  const certs = certQuery.data ?? [];

  const totalCount = courses.length + news.length + blog.length + community.length + certs.length;

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    router.push(`/search?q=${encodeURIComponent(query)}${tab !== "all" ? `&type=${tab}` : ""}`);
  }

  return (
    <div className="mx-auto max-w-7xl px-4 py-10 md:px-8">
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Search</h1>

      <form onSubmit={handleSubmit} className="mb-6 flex max-w-lg gap-2">
        <Input value={query} onChange={(e) => setQuery(e.target.value)} placeholder="Search courses, news, blog, community, certificates..." className="flex-1" />
      </form>

      <div className="mb-8 flex flex-wrap gap-2">
        {TABS.map((t) => {
          const Icon = t.icon;
          const active = tab === t.value;
          return (
            <button
              key={t.value}
              type="button"
              onClick={() => setTab(t.value)}
              className={cn(
                "flex items-center gap-1.5 rounded-full border px-3.5 py-1.5 text-[12.5px] font-semibold transition-colors",
                active ? "border-transparent bg-gradient-brand text-white" : "border-line text-ink-soft hover:border-line-strong hover:text-ink"
              )}
            >
              <Icon size={13} />
              {t.label}
            </button>
          );
        })}
      </div>

      {!initialQuery ? (
        <EmptyState title="Search Saachi AI" description="Type a course, topic, article, or instructor name above to get started." />
      ) : isLoading ? (
        <Loading label="Searching..." />
      ) : totalCount === 0 ? (
        <EmptyState title={`No results for "${initialQuery}"`} description="Try a different search term." />
      ) : (
        <div className="flex flex-col gap-12">
          {(tab === "all" || tab === "courses") && courses.length > 0 && (
            <section>
              <h2 className="mb-4 flex items-center gap-2 text-[16px] font-semibold text-ink">
                <GraduationCap size={16} className="text-accent-violet" /> Courses
              </h2>
              <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 xl:grid-cols-3">
                {courses.map((course) => (
                  <CourseCard key={course.id} slug={course.slug} title={course.title} thumbnailUrl={course.thumbnailUrl} instructorName={course.instructor.fullName} price={course.price} currency={course.currency} rating={course.rating} ratingCount={course.ratingCount} />
                ))}
              </div>
            </section>
          )}

          {(tab === "all" || tab === "news") && news.length > 0 && (
            <section>
              <h2 className="mb-4 flex items-center gap-2 text-[16px] font-semibold text-ink">
                <Newspaper size={16} className="text-accent-violet" /> News
              </h2>
              <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 xl:grid-cols-3">
                {news.map((article) => (
                  <Link key={article.id} href={`/news/${article.slug}`} className="group overflow-hidden rounded-card border border-line bg-card transition-all hover:-translate-y-1 hover:shadow-lg">
                    <div className="aspect-video w-full overflow-hidden">
                      {/* eslint-disable-next-line @next/next/no-img-element */}
                      <img src={article.imageUrl} alt={article.title} className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105" />
                    </div>
                    <div className="p-4">
                      <h3 className="line-clamp-2 text-[14.5px] font-semibold text-ink">{article.title}</h3>
                      <p className="mt-1 line-clamp-2 text-[12.5px] text-ink-soft">{article.excerpt}</p>
                    </div>
                  </Link>
                ))}
              </div>
            </section>
          )}

          {(tab === "all" || tab === "blog") && blog.length > 0 && (
            <section>
              <h2 className="mb-4 flex items-center gap-2 text-[16px] font-semibold text-ink">
                <BookOpen size={16} className="text-accent-violet" /> Blog
              </h2>
              <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 xl:grid-cols-3">
                {blog.map((post) => (
                  <Link key={post.id} href={`/blog/${post.slug}`} className="group overflow-hidden rounded-card border border-line bg-card transition-all hover:-translate-y-1 hover:shadow-lg">
                    <div className="aspect-video w-full overflow-hidden">
                      {/* eslint-disable-next-line @next/next/no-img-element */}
                      <img src={post.imageUrl} alt={post.title} className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105" />
                    </div>
                    <div className="p-4">
                      <h3 className="line-clamp-2 text-[14.5px] font-semibold text-ink">{post.title}</h3>
                      <p className="mt-1 line-clamp-2 text-[12.5px] text-ink-soft">{post.excerpt}</p>
                    </div>
                  </Link>
                ))}
              </div>
            </section>
          )}

          {(tab === "all" || tab === "community") && community.length > 0 && (
            <section>
              <h2 className="mb-4 flex items-center gap-2 text-[16px] font-semibold text-ink">
                <Users size={16} className="text-accent-violet" /> Community
              </h2>
              <div className="flex flex-col gap-3">
                {community.map((post) => (
                  <Link key={post.id} href={`/community/${post.id}`} className="rounded-card border border-line bg-card p-4 transition-colors hover:border-gold-dark/40">
                    <h3 className="text-[14.5px] font-semibold text-ink">{post.title}</h3>
                    <p className="mt-1 line-clamp-2 text-[12.5px] text-ink-soft">{post.body}</p>
                  </Link>
                ))}
              </div>
            </section>
          )}

          {(tab === "all" || tab === "certificates") && certs.length > 0 && (
            <section>
              <h2 className="mb-4 flex items-center gap-2 text-[16px] font-semibold text-ink">
                <Award size={16} className="text-accent-violet" /> Certificates
              </h2>
              <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-3">
                {certs.map((cert) => (
                  <Link key={cert.id} href={`/certificates/${cert.id}`} className="rounded-card border border-line bg-card p-4 transition-colors hover:border-gold-dark/40">
                    <p className="text-[14px] font-semibold text-ink">{cert.courseTitle}</p>
                    <p className="mt-1 text-[12.5px] text-ink-soft">{cert.learnerName} - {cert.verificationId}</p>
                  </Link>
                ))}
              </div>
            </section>
          )}
        </div>
      )}
    </div>
  );
}

export default function SearchPage() {
  return (
    <Suspense fallback={<Loading label="Loading..." />}>
      <SearchResults />
    </Suspense>
  );
}
'@
Write-Utf8NoBom -Path $searchPagePath -Content $searchPageContent
Write-Host "Updated: (marketing)/search/page.tsx" -ForegroundColor Green

Write-Host "`nAll phases complete. cd apps\web ; pnpm run build (or pnpm dev) to verify." -ForegroundColor Cyan