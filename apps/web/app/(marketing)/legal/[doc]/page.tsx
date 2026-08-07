import { Navbar } from "../../_components/Navbar";
import { Footer } from "../../_components/Footer";

const LEGAL_DOCS: Record<string, { title: string; updated: string; body: string[] }> = {
  terms: {
    title: "Terms & Conditions",
    updated: "November 2025",
    body: [
      "These Terms & Conditions govern your use of the Saachi AI platform, including the public website, learner portal, and instructor portal.",
      "By creating an account, you agree to use the platform only for lawful purposes and in accordance with our content and community guidelines.",
      "Course content is owned by the instructor who created it. Saachi AI is granted a license to host, stream, and sell access to that content on the instructor's behalf.",
      "This is placeholder legal text for demo purposes. Final legal copy will be supplied by the client's legal counsel before production launch, per Doc 1, Section 20."
    ]
  },
  privacy: {
    title: "Privacy Policy",
    updated: "November 2025",
    body: [
      "Saachi AI collects account information, course activity, and payment metadata necessary to operate the marketplace.",
      "We do not sell personal data to third parties. Data may be shared with payment processors and infrastructure providers strictly to deliver the service.",
      "Users may request data export or account deletion at any time from Settings - Privacy, in line with GDPR-aligned data rights described in Doc 1.",
      "This is placeholder legal text for demo purposes and will be replaced with final counsel-approved copy."
    ]
  },
  "refund-policy": {
    title: "Refund Policy",
    updated: "November 2025",
    body: [
      "Learners may request a refund within a defined policy window after purchase, subject to a completion-percentage threshold.",
      "Approved refunds reverse the transaction and adjust the instructor's payout balance accordingly.",
      "Refund requests are reviewed by the Finance/Payout Officer role in the Admin Portal.",
      "This is placeholder legal text for demo purposes; final refund window and thresholds are pending client confirmation."
    ]
  },
  "instructor-agreement": {
    title: "Instructor Agreement",
    updated: "November 2025",
    body: [
      "By applying to become an instructor, you agree to submit only original content that you have the rights to distribute.",
      "Saachi AI retains a configurable commission on each course sale, varying by instructor trust tier (New, Verified, Top-Rated, Partner).",
      "Instructors are responsible for responding to learner Q&A and maintaining course quality standards set by the Admin content moderation policy.",
      "This is placeholder legal text for demo purposes and will be finalized with the client's legal counsel."
    ]
  }
};

export default function LegalDocPage({ params }: { params: { doc: string } }) {
  const doc = LEGAL_DOCS[params.doc] ?? {
    title: "Document not found",
    updated: "",
    body: ["This legal document doesn't exist yet."]
  };

  return (
    <>
      <Navbar />
      <main className="mx-auto max-w-[760px] px-6 py-16">
        <h1 className="font-display text-[28px] font-semibold text-ink">{doc.title}</h1>
        {doc.updated && <p className="mt-2 text-[13px] text-ink-soft">Last updated: {doc.updated}</p>}
        <div className="mt-8 flex flex-col gap-4">
          {doc.body.map((para, i) => (
            <p key={i} className="text-[15px] leading-relaxed text-ink-soft">
              {para}
            </p>
          ))}
        </div>
      </main>
      <Footer />
    </>
  );
}