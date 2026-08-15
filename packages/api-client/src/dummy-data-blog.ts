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