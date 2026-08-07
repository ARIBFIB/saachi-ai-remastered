export type FlagStatus = "pending" | "removed" | "dismissed" | "warned";

export type FlaggedReview = {
  id: string;
  courseTitle: string;
  authorName: string;
  comment: string;
  rating: number;
  flagReason: string;
  flaggedBy: string;
  status: FlagStatus;
  createdAt: string;
};

export type FlaggedForumPost = {
  id: string;
  courseTitle: string;
  authorName: string;
  body: string;
  flagReason: string;
  flaggedBy: string;
  status: FlagStatus;
  createdAt: string;
};

export type TicketStatus = "open" | "in_progress" | "resolved" | "closed";
export type TicketPriority = "low" | "medium" | "high" | "urgent";

export type TicketMessage = {
  id: string;
  authorName: string;
  isInternal: boolean;
  isStaff: boolean;
  body: string;
  createdAt: string;
};

export type SupportTicket = {
  id: string;
  subject: string;
  requesterName: string;
  requesterEmail: string;
  category: string;
  priority: TicketPriority;
  status: TicketStatus;
  assignedTo?: string;
  createdAt: string;
  slaDueAt: string;
  messages: TicketMessage[];
};

function hoursAgoIso(n: number): string {
  return new Date(Date.now() - n * 60 * 60 * 1000).toISOString();
}

function hoursFromNowIso(n: number): string {
  return new Date(Date.now() + n * 60 * 60 * 1000).toISOString();
}

export const ADMIN_DUMMY_FLAGGED_REVIEWS: FlaggedReview[] = [
  { id: "frv_1", courseTitle: "Prompt Engineering Fundamentals", authorName: "Danish Raza", comment: "This course is a scam, don't waste your money, the instructor never responds and it's all recycled content from free YouTube videos.", rating: 1, flagReason: "Potentially defamatory / unverified claims", flaggedBy: "Sana Rizvi (instructor)", status: "pending", createdAt: hoursAgoIso(6) },
  { id: "frv_2", courseTitle: "AI-Powered Marketing Campaigns", authorName: "Anonymous User", comment: "Check out my own course instead, link in bio, way better content for half the price!", rating: 3, flagReason: "Self-promotion / spam", flaggedBy: "system", status: "pending", createdAt: hoursAgoIso(20) },
  { id: "frv_3", courseTitle: "Build a WhatsApp AI Auto-Responder", authorName: "Omar Sheikh", comment: "Genuinely one of the worst experiences, the guy is an idiot and clearly doesn't know what he's teaching.", rating: 1, flagReason: "Harassment / abusive language toward instructor", flaggedBy: "Bilal Ahmed (instructor)", status: "pending", createdAt: hoursAgoIso(30) },
  { id: "frv_4", courseTitle: "Automate Everything with n8n & AI", authorName: "Hina Malik", comment: "Solid course but the pricing section felt rushed.", rating: 4, flagReason: "Flagged in error by automated filter", flaggedBy: "system", status: "dismissed", createdAt: hoursAgoIso(72) }
];

export const ADMIN_DUMMY_FLAGGED_FORUM_POSTS: FlaggedForumPost[] = [
  { id: "ffp_1", courseTitle: "Prompt Engineering Fundamentals", authorName: "Noor Fatima", body: "Does anyone want to share their personal WhatsApp number so we can form a study group outside the platform?", flagReason: "Requesting off-platform contact info", flaggedBy: "system", status: "pending", createdAt: hoursAgoIso(10) },
  { id: "ffp_2", courseTitle: "AI Automation & Workflow Tools", authorName: "Ali Raza", body: "Here's a cracked version of the paid n8n cloud plan if anyone wants the download link.", flagReason: "Promoting pirated / unauthorized software", flaggedBy: "Ayesha Khan (instructor)", status: "pending", createdAt: hoursAgoIso(15) },
  { id: "ffp_3", courseTitle: "Build a WhatsApp AI Auto-Responder", authorName: "Sara Iqbal", body: "This module completely contradicts what was taught earlier, is this course even reviewed before publishing?", flagReason: "Flagged in error - legitimate question", flaggedBy: "system", status: "dismissed", createdAt: hoursAgoIso(48) },
  { id: "ffp_4", courseTitle: "AI-Powered Marketing Campaigns", authorName: "Fatima Noor", body: "Anyone else think the instructor is overselling results here? Feels dishonest tbh.", flagReason: "Reported by instructor as harassment", flaggedBy: "Zara Farooq (instructor)", status: "pending", createdAt: hoursAgoIso(5) }
];

export const ADMIN_DUMMY_TICKETS: SupportTicket[] = [
  {
    id: "tkt_5001",
    subject: "Payment charged twice for the same course",
    requesterName: "Hina Malik",
    requesterEmail: "hina.malik@example.com",
    category: "Billing",
    priority: "urgent",
    status: "open",
    assignedTo: undefined,
    createdAt: hoursAgoIso(2),
    slaDueAt: hoursFromNowIso(2),
    messages: [
      { id: "m1", authorName: "Hina Malik", isInternal: false, isStaff: false, body: "I was charged twice for Prompt Engineering Fundamentals - $29 shows up twice on my card statement. Please refund the duplicate.", createdAt: hoursAgoIso(2) }
    ]
  },
  {
    id: "tkt_5002",
    subject: "Can't access course after purchase",
    requesterName: "Omar Sheikh",
    requesterEmail: "omar.sheikh@example.com",
    category: "Technical",
    priority: "high",
    status: "in_progress",
    assignedTo: "admin@saachi.ai",
    createdAt: hoursAgoIso(18),
    slaDueAt: hoursFromNowIso(-2),
    messages: [
      { id: "m1", authorName: "Omar Sheikh", isInternal: false, isStaff: false, body: "I purchased AI-Powered Marketing Campaigns but my dashboard still shows it as locked.", createdAt: hoursAgoIso(18) },
      { id: "m2", authorName: "Admin", isInternal: false, isStaff: true, body: "Thanks for flagging this - can you confirm the email used at checkout matches your account email?", createdAt: hoursAgoIso(16) },
      { id: "m3", authorName: "Admin", isInternal: true, isStaff: true, body: "Checked transaction ledger - payment shows completed but enrollment record is missing. Escalating to backend team once available.", createdAt: hoursAgoIso(15) }
    ]
  },
  {
    id: "tkt_5003",
    subject: "Question about instructor payout timeline",
    requesterName: "Ayesha Khan",
    requesterEmail: "ayesha.khan@example.com",
    category: "Payouts",
    priority: "medium",
    status: "open",
    assignedTo: undefined,
    createdAt: hoursAgoIso(30),
    slaDueAt: hoursFromNowIso(18),
    messages: [
      { id: "m1", authorName: "Ayesha Khan", isInternal: false, isStaff: false, body: "I requested a payout 5 days ago and haven't heard anything - what's the usual processing time?", createdAt: hoursAgoIso(30) }
    ]
  },
  {
    id: "tkt_5004",
    subject: "Refund request follow-up",
    requesterName: "Sara Iqbal",
    requesterEmail: "sara.iqbal@example.com",
    category: "Billing",
    priority: "low",
    status: "resolved",
    assignedTo: "admin@saachi.ai",
    createdAt: hoursAgoIso(96),
    slaDueAt: hoursAgoIso(72),
    messages: [
      { id: "m1", authorName: "Sara Iqbal", isInternal: false, isStaff: false, body: "Following up on my refund request from last week.", createdAt: hoursAgoIso(96) },
      { id: "m2", authorName: "Admin", isInternal: false, isStaff: true, body: "Your refund was approved and processed - you should see it in 5-7 business days.", createdAt: hoursAgoIso(90) }
    ]
  },
  {
    id: "tkt_5005",
    subject: "How do I become a verified instructor?",
    requesterName: "Hamza Tariq",
    requesterEmail: "hamza.tariq@example.com",
    category: "Instructor",
    priority: "low",
    status: "closed",
    assignedTo: "admin@saachi.ai",
    createdAt: hoursAgoIso(200),
    slaDueAt: hoursAgoIso(176),
    messages: [
      { id: "m1", authorName: "Hamza Tariq", isInternal: false, isStaff: false, body: "What are the requirements to get the Verified Instructor badge?", createdAt: hoursAgoIso(200) },
      { id: "m2", authorName: "Admin", isInternal: false, isStaff: true, body: "You'll need ID verification, 3+ published courses, and a 4.0+ average rating. You can submit documents from the Verification tab.", createdAt: hoursAgoIso(195) }
    ]
  }
];