// Landing-page dummy content. All names, numbers, quotes, and logos here are
// fictional placeholders for UI/UX purposes only -- swap for real API data
// once the backend endpoints (courses, reviews, activity feed) are wired up.

export type TrendingCourse = {
  id: string;
  title: string;
  category: string;
  instructor: string;
  price: string;
  rating: number;
  students: string;
  badge: "Bestseller" | "New" | "Hot" | "Staff pick";
  image: string;
};

export const TRENDING_COURSES: TrendingCourse[] = [
  { id: "t1", title: "Automate Everything with n8n & AI", category: "Automation", instructor: "Ayesha Khan", price: "$39", rating: 4.8, students: "6.2k", badge: "Bestseller", image: "https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=480&h=320&fit=crop&q=70&auto=format" },
  { id: "t2", title: "Build AI Agents with LangChain", category: "Development", instructor: "Omar Sheikh", price: "$59", rating: 4.9, students: "3.2k", badge: "Hot", image: "https://images.unsplash.com/photo-1531482615713-2afd69097998?w=480&h=320&fit=crop&q=70&auto=format" },
  { id: "t3", title: "AI Chatbots for WhatsApp Support", category: "Automation", instructor: "Ayesha Khan", price: "$49", rating: 4.7, students: "1.6k", badge: "New", image: "https://images.unsplash.com/photo-1526378722484-bd91ca387e72?w=480&h=320&fit=crop&q=70&auto=format" },
  { id: "t4", title: "AI Design Systems in Figma", category: "Design", instructor: "Noor Fatima", price: "$45", rating: 4.7, students: "1.1k", badge: "Staff pick", image: "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=480&h=320&fit=crop&q=70&auto=format" },
  { id: "t5", title: "Prompt Engineering for Client Work", category: "Fundamentals", instructor: "Hamza Malik", price: "$29", rating: 4.6, students: "980", badge: "Bestseller", image: "https://images.unsplash.com/photo-1550439062-609e1531270e?w=480&h=320&fit=crop&q=70&auto=format" },
  { id: "t6", title: "Voice AI & Call Automation", category: "Automation", instructor: "Hina Malik", price: "$55", rating: 4.6, students: "890", badge: "New", image: "https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=480&h=320&fit=crop&q=70&auto=format" }
];

export type ActivityItem = { id: string; text: string };

export const ACTIVITY_FEED: ActivityItem[] = [
  { id: "a1", text: "Bilal S. just enrolled in \"Automate Everything with n8n & AI\"" },
  { id: "a2", text: "Fatima R. earned a certificate in \"AI Chatbots for WhatsApp Support\"" },
  { id: "a3", text: "Omar Sheikh booked a mentorship session with Ayesha Khan" },
  { id: "a4", text: "Hina Malik just enrolled in \"Voice AI & Call Automation\"" },
  { id: "a5", text: "Sara Iqbal left a 5-star review on \"Prompt Engineering for Client Work\"" },
  { id: "a6", text: "Ali Raza just enrolled in \"Build AI Agents with LangChain\"" },
  { id: "a7", text: "Noor Fatima earned a certificate in \"AI Design Systems in Figma\"" }
];

export const COMPANY_LOGOS: string[] = [
  "NovaWorks", "BrightStack", "Vertex Labs", "Cirrus Digital", "Ember Systems",
  "Northline Tech", "Quill & Co", "Fenwick Studio"
];

export type BlogPost = {
  id: string;
  title: string;
  tag: string;
  readTime: string;
  image: string;
};

export const BLOG_POSTS: BlogPost[] = [
  { id: "b1", title: "5 n8n workflows every freelancer should automate first", tag: "Automation", readTime: "6 min read", image: "https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=480&h=320&fit=crop&q=70&auto=format" },
  { id: "b2", title: "How we structure a beginner-to-advanced AI curriculum", tag: "Teaching", readTime: "8 min read", image: "https://images.unsplash.com/photo-1531482615713-2afd69097998?w=480&h=320&fit=crop&q=70&auto=format" },
  { id: "b3", title: "From student to instructor: Ayesha's story", tag: "Community", readTime: "4 min read", image: "https://images.unsplash.com/photo-1526378722484-bd91ca387e72?w=480&h=320&fit=crop&q=70&auto=format" }
];

export type ExtraTestimonial = {
  name: string;
  role: string;
  avatar: string;
  rating: number;
  quote: string;
  verified?: boolean;
};

export const EXTRA_TESTIMONIALS: ExtraTestimonial[] = [
  { name: "Zara Ahmed", role: "Product designer", avatar: "https://i.pravatar.cc/64?img=48", rating: 5, verified: true, quote: "The design systems course completely changed how I hand off files to developers. Immediate ROI." },
  { name: "Usman Tariq", role: "Agency owner", avatar: "https://i.pravatar.cc/64?img=13", rating: 5, verified: true, quote: "We onboarded our whole team through Saachi AI Business. Certificates and dashboards made tracking easy." },
  { name: "Mahnoor Khalid", role: "Content strategist", avatar: "https://i.pravatar.cc/64?img=45", rating: 4, verified: false, quote: "Solid course library, wish there was more advanced copywriting content, but great value overall." },
  { name: "Danish Iqbal", role: "Automation freelancer", avatar: "https://i.pravatar.cc/64?img=33", rating: 5, verified: true, quote: "Booked a mentorship call the same week I finished the course. Instructor feedback was gold." }
];

export const EXTRA_FAQS: { q: string; a: string }[] = [
  { q: "Do certificates expire?", a: "No -- once issued, your completion certificate is yours to keep and share forever." },
  { q: "Can I switch from learner to instructor later?", a: "Yes, anytime. Apply from your dashboard and our team reviews applications within a few business days." },
  { q: "Is there a mobile app?", a: "The platform is fully responsive today; native apps are on our roadmap." }
];