import type { Course, CourseDetail, Session } from "./types";

function img(seed: string, w: number, h: number): string {
  return `https://picsum.photos/seed/${encodeURIComponent(seed)}/${w}/${h}`;
}

export const DUMMY_SESSION: Session = {
  id: "usr_demo_001",
  fullName: "Ayesha Khan",
  email: "demo@saachi.ai",
  role: "learner",
  avatarUrl: img("ayesha-khan-demo", 150, 150)
};

export type DummyCourse = CourseDetail & {
  categoryId: string;
  level: "beginner" | "intermediate" | "advanced";
  language: "en" | "ur";
};

function toCourseSummary(course: DummyCourse): Course {
  return {
    id: course.id,
    slug: course.slug,
    title: course.title,
    subtitle: course.subtitle,
    thumbnailUrl: course.thumbnailUrl,
    price: course.price,
    currency: course.currency,
    rating: course.rating,
    ratingCount: course.ratingCount,
    instructor: course.instructor,
    status: course.status
  };
}

const BASE_COURSES: DummyCourse[] = [
  {
    id: "crs_001",
    slug: "prompt-engineering-fundamentals",
    title: "Prompt Engineering Fundamentals",
    subtitle: "Go from zero to confident with ChatGPT, Claude, and Gemini.",
    price: 29,
    currency: "USD",
    rating: 4.8,
    ratingCount: 1240,
    categoryId: "ai-fundamentals",
    level: "beginner",
    language: "en",
    status: "published",
    thumbnailUrl: img("prompt-engineering-fundamentals", 800, 450),
    instructor: { id: "ins_001", fullName: "Sana Rizvi", avatarUrl: img("sana-rizvi", 150, 150) },
    description:
      "Learn how to write prompts that actually get useful, reliable output from modern AI models. You will practice on real business tasks - writing, research, summarization, and structured data extraction - and finish with a personal prompt library you can reuse on the job.",
    instructorBio: "AI marketing consultant and instructor with 6+ years teaching applied AI workflows.",
    instructorCourseCount: 4,
    instructorStudentCount: 8300,
    curriculum: [
      {
        id: "mod_1",
        title: "Getting Started",
        lessons: [
          { id: "les_1", title: "Why prompting is a skill", type: "video", durationSeconds: 420, isPreview: true },
          { id: "les_2", title: "Setting up your workspace", type: "text", durationSeconds: 180 }
        ]
      },
      {
        id: "mod_2",
        title: "Core Prompting Techniques",
        lessons: [
          { id: "les_3", title: "Instructions vs. context", type: "video", durationSeconds: 540 },
          { id: "les_4", title: "Few-shot examples", type: "video", durationSeconds: 480 },
          { id: "les_5", title: "Knowledge check", type: "quiz" }
        ]
      },
      {
        id: "mod_3",
        title: "Applying It To Real Work",
        lessons: [
          { id: "les_6", title: "Writing a research prompt", type: "video", durationSeconds: 600 },
          { id: "les_7", title: "Prompt library template", type: "resource" }
        ]
      }
    ],
    ratingBreakdown: { 5: 900, 4: 250, 3: 60, 2: 20, 1: 10 },
    reviews: [
      {
        id: "rev_1",
        authorName: "Bilal Ahmed",
        authorAvatarUrl: img("bilal-ahmed", 100, 100),
        rating: 5,
        comment: "Clear, practical, and I actually use the prompt library every week now.",
        createdAt: "2026-06-12T10:00:00.000Z",
        verifiedPurchase: true
      },
      {
        id: "rev_2",
        authorName: "Hina Malik",
        authorAvatarUrl: img("hina-malik", 100, 100),
        rating: 4,
        comment: "Great intro course. Wish there was more on API usage, but perfect for beginners.",
        createdAt: "2026-05-28T10:00:00.000Z",
        verifiedPurchase: true
      }
    ],
    faq: [
      { id: "faq_1", question: "Do I need any prior experience?", answer: "No - this course starts from zero." },
      { id: "faq_2", question: "Which AI tools does it cover?", answer: "ChatGPT, Claude, and Gemini, with transferable techniques for any model." }
    ]
  },
  {
    id: "crs_002",
    slug: "ai-powered-marketing-campaigns",
    title: "AI-Powered Marketing Campaigns",
    subtitle: "Plan, write, and launch full campaigns with AI copilots.",
    price: 49,
    currency: "USD",
    rating: 4.6,
    ratingCount: 812,
    categoryId: "ai-marketing",
    level: "intermediate",
    language: "en",
    status: "published",
    thumbnailUrl: img("ai-powered-marketing-campaigns", 800, 450),
    instructor: { id: "ins_002", fullName: "Zara Farooq", avatarUrl: img("zara-farooq", 150, 150) },
    description:
      "A hands-on workflow for using AI to plan a campaign calendar, generate ad copy variants, draft email sequences, and analyze performance - the exact process working marketers use for client accounts.",
    instructorBio: "Runs a 4-person AI-first marketing agency serving South Asian SMEs.",
    instructorCourseCount: 2,
    instructorStudentCount: 3100,
    curriculum: [
      {
        id: "mod_1",
        title: "Campaign Planning with AI",
        lessons: [
          { id: "les_1", title: "Building a campaign brief", type: "video", durationSeconds: 500, isPreview: true },
          { id: "les_2", title: "Audience research prompts", type: "video", durationSeconds: 420 }
        ]
      },
      {
        id: "mod_2",
        title: "Content Generation",
        lessons: [
          { id: "les_3", title: "Ad copy variants at scale", type: "video", durationSeconds: 460 },
          { id: "les_4", title: "Email sequence workflow", type: "text", durationSeconds: 300 }
        ]
      }
    ],
    ratingBreakdown: { 5: 560, 4: 180, 3: 50, 2: 15, 1: 7 },
    reviews: [
      {
        id: "rev_1",
        authorName: "Omar Sheikh",
        authorAvatarUrl: img("omar-sheikh", 100, 100),
        rating: 5,
        comment: "Cut my campaign prep time in half. Worth every rupee.",
        createdAt: "2026-06-02T10:00:00.000Z",
        verifiedPurchase: true
      }
    ],
    faq: [
      { id: "faq_1", question: "Which AI tools are used?", answer: "ChatGPT and Claude, plus a spreadsheet template - no paid tools required." }
    ]
  },
  {
    id: "crs_003",
    slug: "automate-everything-with-n8n-and-ai",
    title: "Automate Everything with n8n & AI",
    subtitle: "Connect AI models into no-code workflows that run themselves.",
    price: 39,
    currency: "USD",
    rating: 4.7,
    ratingCount: 654,
    categoryId: "ai-automation",
    level: "intermediate",
    language: "en",
    status: "published",
    thumbnailUrl: img("automate-everything-with-n8n-and-ai", 800, 450),
    instructor: { id: "ins_003", fullName: "Ayesha Khan", avatarUrl: img("ayesha-khan-instructor", 150, 150) },
    description:
      "Build five real automations step by step: lead qualification, content repurposing, invoice parsing, support ticket routing, and a daily AI digest - all inside n8n, wired up to OpenAI.",
    instructorBio: "Freelance automation consultant, builds n8n workflows for e-commerce clients.",
    instructorCourseCount: 3,
    instructorStudentCount: 5200,
    curriculum: [
      {
        id: "mod_1",
        title: "n8n Basics",
        lessons: [
          { id: "les_1", title: "Installing and connecting n8n", type: "video", durationSeconds: 380, isPreview: true },
          { id: "les_2", title: "Your first AI node", type: "video", durationSeconds: 340 }
        ]
      },
      {
        id: "mod_2",
        title: "Five Real Automations",
        lessons: [
          { id: "les_3", title: "Lead qualification bot", type: "video", durationSeconds: 620 },
          { id: "les_4", title: "Invoice parsing pipeline", type: "video", durationSeconds: 580 },
          { id: "les_5", title: "Starter workflow files", type: "resource" }
        ]
      }
    ],
    ratingBreakdown: { 5: 460, 4: 140, 3: 35, 2: 12, 1: 7 },
    reviews: [
      {
        id: "rev_1",
        authorName: "Fatima Noor",
        authorAvatarUrl: img("fatima-noor", 100, 100),
        rating: 5,
        comment: "The invoice parsing workflow alone paid for the course.",
        createdAt: "2026-05-15T10:00:00.000Z",
        verifiedPurchase: true
      }
    ],
    faq: [
      { id: "faq_1", question: "Is n8n free to use?", answer: "Yes, the self-hosted version is free and used throughout this course." }
    ]
  },
  {
    id: "crs_004",
    slug: "build-a-whatsapp-ai-auto-responder",
    title: "Build a WhatsApp AI Auto-Responder",
    subtitle: "Ship a working AI customer-support bot on WhatsApp.",
    price: 59,
    currency: "USD",
    rating: 4.9,
    ratingCount: 401,
    categoryId: "ai-support",
    level: "advanced",
    language: "en",
    status: "published",
    thumbnailUrl: img("build-a-whatsapp-ai-auto-responder", 800, 450),
    instructor: { id: "ins_004", fullName: "Bilal Ahmed", avatarUrl: img("bilal-ahmed-instructor", 150, 150) },
    description:
      "A complete build: connect the WhatsApp Business API, wire it to an AI model with your own knowledge base, and deploy a bot that can answer real customer questions and escalate to a human when needed.",
    instructorBio: "Built AI support systems for three Pakistani D2C brands.",
    instructorCourseCount: 1,
    instructorStudentCount: 1450,
    curriculum: [
      {
        id: "mod_1",
        title: "WhatsApp API Setup",
        lessons: [
          { id: "les_1", title: "WhatsApp Business API basics", type: "video", durationSeconds: 400, isPreview: true },
          { id: "les_2", title: "Webhook configuration", type: "text", durationSeconds: 260 }
        ]
      },
      {
        id: "mod_2",
        title: "Building the AI Layer",
        lessons: [
          { id: "les_3", title: "Knowledge base + retrieval", type: "video", durationSeconds: 560 },
          { id: "les_4", title: "Human handoff logic", type: "video", durationSeconds: 400 }
        ]
      }
    ],
    ratingBreakdown: { 5: 360, 4: 30, 3: 6, 2: 3, 1: 2 },
    reviews: [
      {
        id: "rev_1",
        authorName: "Sara Iqbal",
        authorAvatarUrl: img("sara-iqbal", 100, 100),
        rating: 5,
        comment: "Most technical course on the platform, but explained really well.",
        createdAt: "2026-06-20T10:00:00.000Z",
        verifiedPurchase: true
      }
    ],
    faq: [
      { id: "faq_1", question: "Do I need coding experience?", answer: "Basic JavaScript helps, but each step is explained from scratch." }
    ]
  },
  {
    id: "crs_005",
    slug: "ship-your-first-ai-powered-web-app",
    title: "Ship Your First AI-Powered Web App",
    subtitle: "From idea to a deployed app using AI-assisted development.",
    price: 45,
    currency: "USD",
    rating: 4.5,
    ratingCount: 588,
    categoryId: "ai-dev",
    level: "intermediate",
    language: "en",
    status: "published",
    thumbnailUrl: img("ship-your-first-ai-powered-web-app", 800, 450),
    instructor: { id: "ins_005", fullName: "Hamza Tariq", avatarUrl: img("hamza-tariq", 150, 150) },
    description:
      "Use AI coding tools to plan, build, and deploy a small full-stack app in a weekend - covering scaffolding, debugging with AI, and shipping to production.",
    instructorBio: "Full-stack developer teaching AI-assisted development workflows.",
    instructorCourseCount: 2,
    instructorStudentCount: 2700,
    curriculum: [
      {
        id: "mod_1",
        title: "Planning with AI",
        lessons: [
          { id: "les_1", title: "Turning an idea into a spec", type: "video", durationSeconds: 360, isPreview: true }
        ]
      },
      {
        id: "mod_2",
        title: "Build & Deploy",
        lessons: [
          { id: "les_2", title: "Scaffolding the app", type: "video", durationSeconds: 500 },
          { id: "les_3", title: "Deploying to production", type: "video", durationSeconds: 320 }
        ]
      }
    ],
    ratingBreakdown: { 5: 400, 4: 140, 3: 35, 2: 8, 1: 5 },
    reviews: [
      {
        id: "rev_1",
        authorName: "Noor Fatima",
        authorAvatarUrl: img("noor-fatima", 100, 100),
        rating: 4,
        comment: "Fast-paced but I had a working app by the end.",
        createdAt: "2026-04-30T10:00:00.000Z",
        verifiedPurchase: true
      }
    ],
    faq: [
      { id: "faq_1", question: "Which AI coding tool is used?", answer: "The course covers general techniques that work with any modern AI coding assistant." }
    ]
  },
  {
    id: "crs_006",
    slug: "integrating-openai-and-claude-apis-into-node",
    title: "Integrating OpenAI & Claude APIs into Node.js Apps",
    subtitle: "Production patterns for adding AI features to real applications.",
    price: 65,
    currency: "USD",
    rating: 4.9,
    ratingCount: 320,
    categoryId: "ai-integration",
    level: "advanced",
    language: "en",
    status: "published",
    thumbnailUrl: img("integrating-openai-and-claude-apis-into-node", 800, 450),
    instructor: { id: "ins_006", fullName: "Usman Ali", avatarUrl: img("usman-ali", 150, 150) },
    description:
      "Covers authentication, streaming responses, function/tool calling, error handling, cost control, and testing - everything needed to ship an AI feature that survives production traffic.",
    instructorBio: "Backend engineer, has shipped AI features at two Series-A startups.",
    instructorCourseCount: 3,
    instructorStudentCount: 1900,
    curriculum: [
      {
        id: "mod_1",
        title: "Foundations",
        lessons: [
          { id: "les_1", title: "Auth and API key management", type: "video", durationSeconds: 300, isPreview: true },
          { id: "les_2", title: "Streaming responses", type: "video", durationSeconds: 420 }
        ]
      },
      {
        id: "mod_2",
        title: "Production Concerns",
        lessons: [
          { id: "les_3", title: "Tool calling patterns", type: "video", durationSeconds: 540 },
          { id: "les_4", title: "Cost control and rate limits", type: "text", durationSeconds: 260 }
        ]
      }
    ],
    ratingBreakdown: { 5: 290, 4: 22, 3: 5, 2: 2, 1: 1 },
    reviews: [
      {
        id: "rev_1",
        authorName: "Danish Raza",
        authorAvatarUrl: img("danish-raza", 100, 100),
        rating: 5,
        comment: "Exactly the production-level detail I couldn't find anywhere else.",
        createdAt: "2026-06-25T10:00:00.000Z",
        verifiedPurchase: true
      }
    ],
    faq: [
      { id: "faq_1", question: "Is this course Python or Node.js?", answer: "Node.js / TypeScript throughout." }
    ]
  }
];

export const DUMMY_COURSES: DummyCourse[] = BASE_COURSES.map((course, index) => {
  const others = BASE_COURSES.filter((c) => c.id !== course.id);
  const related = [others[index % others.length], others[(index + 1) % others.length]].filter(Boolean);
  return { ...course, relatedCourses: related.map(toCourseSummary) };
});