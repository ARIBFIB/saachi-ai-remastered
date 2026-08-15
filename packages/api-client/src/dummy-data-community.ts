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