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