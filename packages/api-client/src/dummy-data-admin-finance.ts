export type TransactionStatus = "completed" | "pending" | "failed" | "refunded";

export type AdminTransaction = {
  id: string;
  courseTitle: string;
  learnerName: string;
  instructorName: string;
  amount: number;
  currency: string;
  commission: number;
  netToInstructor: number;
  gateway: "stripe" | "paypal" | "easypaisa" | "jazzcash" | "bank_transfer";
  status: TransactionStatus;
  createdAt: string;
};

export type PayoutStatus = "pending" | "approved" | "paid" | "rejected";

export type AdminPayout = {
  id: string;
  instructorName: string;
  instructorId: string;
  amount: number;
  currency: string;
  method: "bank_transfer" | "easypaisa" | "jazzcash" | "stripe_connect";
  status: PayoutStatus;
  requestedAt: string;
  processedAt?: string;
};

export type RefundStatus = "pending" | "approved" | "rejected";

export type AdminRefund = {
  id: string;
  transactionId: string;
  courseTitle: string;
  learnerName: string;
  amount: number;
  currency: string;
  reason: string;
  status: RefundStatus;
  requestedAt: string;
};

export type TaxRule = {
  id: string;
  region: string;
  ratePercent: number;
  appliesTo: string;
  active: boolean;
};

function daysAgoIso(n: number): string {
  return new Date(Date.now() - n * 24 * 60 * 60 * 1000).toISOString();
}

export const ADMIN_DUMMY_TRANSACTIONS: AdminTransaction[] = [
  { id: "txn_1001", courseTitle: "Prompt Engineering Fundamentals", learnerName: "Hina Malik", instructorName: "Sana Rizvi", amount: 29, currency: "USD", commission: 8.7, netToInstructor: 20.3, gateway: "stripe", status: "completed", createdAt: daysAgoIso(0) },
  { id: "txn_1002", courseTitle: "AI-Powered Marketing Campaigns", learnerName: "Omar Sheikh", instructorName: "Zara Farooq", amount: 49, currency: "USD", commission: 14.7, netToInstructor: 34.3, gateway: "easypaisa", status: "completed", createdAt: daysAgoIso(0) },
  { id: "txn_1003", courseTitle: "Automate Everything with n8n & AI", learnerName: "Fatima Noor", instructorName: "Ayesha Khan", amount: 39, currency: "USD", commission: 11.7, netToInstructor: 27.3, gateway: "jazzcash", status: "pending", createdAt: daysAgoIso(1) },
  { id: "txn_1004", courseTitle: "Build a WhatsApp AI Auto-Responder", learnerName: "Sara Iqbal", instructorName: "Bilal Ahmed", amount: 59, currency: "USD", commission: 17.7, netToInstructor: 41.3, gateway: "stripe", status: "completed", createdAt: daysAgoIso(1) },
  { id: "txn_1005", courseTitle: "Ship Your First AI-Powered Web App", learnerName: "Noor Fatima", instructorName: "Hamza Tariq", amount: 45, currency: "USD", commission: 13.5, netToInstructor: 31.5, gateway: "paypal", status: "failed", createdAt: daysAgoIso(2) },
  { id: "txn_1006", courseTitle: "Integrating OpenAI & Claude APIs into Node.js Apps", learnerName: "Ali Raza", instructorName: "Usman Ali", amount: 65, currency: "USD", commission: 19.5, netToInstructor: 45.5, gateway: "bank_transfer", status: "completed", createdAt: daysAgoIso(3) },
  { id: "txn_1007", courseTitle: "Prompt Engineering Fundamentals", learnerName: "Mahnoor Fatima", instructorName: "Sana Rizvi", amount: 29, currency: "USD", commission: 8.7, netToInstructor: 20.3, gateway: "stripe", status: "refunded", createdAt: daysAgoIso(5) },
  { id: "txn_1008", courseTitle: "AI-Powered Marketing Campaigns", learnerName: "Danish Raza", instructorName: "Zara Farooq", amount: 49, currency: "USD", commission: 14.7, netToInstructor: 34.3, gateway: "easypaisa", status: "completed", createdAt: daysAgoIso(6) },
  { id: "txn_1009", courseTitle: "Build a WhatsApp AI Auto-Responder", learnerName: "Hina Malik", instructorName: "Bilal Ahmed", amount: 59, currency: "USD", commission: 17.7, netToInstructor: 41.3, gateway: "jazzcash", status: "completed", createdAt: daysAgoIso(7) },
  { id: "txn_1010", courseTitle: "Automate Everything with n8n & AI", learnerName: "Omar Sheikh", instructorName: "Ayesha Khan", amount: 39, currency: "USD", commission: 11.7, netToInstructor: 27.3, gateway: "stripe", status: "pending", createdAt: daysAgoIso(8) }
];

export const ADMIN_DUMMY_PAYOUTS: AdminPayout[] = [
  { id: "po_2001", instructorName: "Ayesha Khan", instructorId: "usr_1001", amount: 420, currency: "USD", method: "bank_transfer", status: "pending", requestedAt: daysAgoIso(1) },
  { id: "po_2002", instructorName: "Sana Rizvi", instructorId: "usr_1005", amount: 890, currency: "USD", method: "stripe_connect", status: "pending", requestedAt: daysAgoIso(2) },
  { id: "po_2003", instructorName: "Bilal Ahmed", instructorId: "usr_1002", amount: 310, currency: "USD", method: "easypaisa", status: "approved", requestedAt: daysAgoIso(3) },
  { id: "po_2004", instructorName: "Zara Farooq", instructorId: "usr_1008", amount: 560, currency: "USD", method: "jazzcash", status: "paid", requestedAt: daysAgoIso(10), processedAt: daysAgoIso(7) },
  { id: "po_2005", instructorName: "Usman Ali", instructorId: "usr_1007", amount: 275, currency: "USD", method: "bank_transfer", status: "paid", requestedAt: daysAgoIso(20), processedAt: daysAgoIso(17) },
  { id: "po_2006", instructorName: "Hamza Tariq", instructorId: "usr_1011", amount: 150, currency: "USD", method: "easypaisa", status: "rejected", requestedAt: daysAgoIso(15) }
];

export const ADMIN_DUMMY_REFUNDS: AdminRefund[] = [
  { id: "rfd_3001", transactionId: "txn_1007", courseTitle: "Prompt Engineering Fundamentals", learnerName: "Mahnoor Fatima", amount: 29, currency: "USD", reason: "Course content did not match the description.", status: "approved", requestedAt: daysAgoIso(5) },
  { id: "rfd_3002", transactionId: "txn_1002", courseTitle: "AI-Powered Marketing Campaigns", learnerName: "Omar Sheikh", amount: 49, currency: "USD", reason: "Purchased by mistake, requesting refund within policy window.", status: "pending", requestedAt: daysAgoIso(0) },
  { id: "rfd_3003", transactionId: "txn_1009", courseTitle: "Build a WhatsApp AI Auto-Responder", learnerName: "Hina Malik", amount: 59, currency: "USD", reason: "Technical issues prevented course access.", status: "pending", requestedAt: daysAgoIso(1) },
  { id: "rfd_3004", transactionId: "txn_1004", courseTitle: "Build a WhatsApp AI Auto-Responder", learnerName: "Sara Iqbal", amount: 59, currency: "USD", reason: "Requesting refund after completing 80% of the course.", status: "rejected", requestedAt: daysAgoIso(12) }
];

export const ADMIN_DUMMY_TAX_RULES: TaxRule[] = [
  { id: "tax_pk", region: "Pakistan", ratePercent: 0, appliesTo: "All course sales", active: true },
  { id: "tax_us", region: "United States", ratePercent: 0, appliesTo: "All course sales", active: true },
  { id: "tax_eu", region: "European Union", ratePercent: 20, appliesTo: "Digital goods (VAT)", active: true },
  { id: "tax_gb", region: "United Kingdom", ratePercent: 20, appliesTo: "Digital goods (VAT)", active: true },
  { id: "tax_in", region: "India", ratePercent: 18, appliesTo: "Digital goods (GST)", active: false }
];