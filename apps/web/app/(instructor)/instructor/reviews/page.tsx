"use client";

import { useState } from "react";
import { Star } from "lucide-react";
import { Button, Textarea, EmptyState } from "@saachi/ui";

type Review = {
  id: string;
  courseTitle: string;
  author: string;
  rating: number;
  comment: string;
  reply?: string;
};

// NOTE: demo-only dummy data. Replace with useInstructorReviews() once confirmed.
const REVIEWS: Review[] = [
  {
    id: "rev_i1",
    courseTitle: "Automate Everything with n8n & AI",
    author: "Bilal S.",
    rating: 5,
    comment: "Very practical, loved it. The invoice parsing workflow alone was worth the price."
  },
  {
    id: "rev_i2",
    courseTitle: "Automate Everything with n8n & AI",
    author: "Fatima R.",
    rating: 4,
    comment: "Good pacing, clear examples. Wish there was a bit more on error handling.",
    reply: "Thanks Fatima! Adding an error-handling lesson is on my list for the next update."
  },
  {
    id: "rev_i3",
    courseTitle: "AI Chatbots for WhatsApp Support",
    author: "Omar Sheikh",
    rating: 5,
    comment: "Best WhatsApp bot course I've taken - clear, practical, and well structured."
  }
];

export default function InstructorReviewsPage() {
  const [replies, setReplies] = useState<Record<string, string>>({});
  const [submittedIds, setSubmittedIds] = useState<Set<string>>(new Set());

  function handleReplyChange(id: string, value: string) {
    setReplies((prev) => ({ ...prev, [id]: value }));
  }

  function handleSubmitReply(id: string) {
    // NOTE: demo-only, no backend review-reply mutation wired up yet.
    setSubmittedIds((prev) => new Set(prev).add(id));
  }

  return (
    <div>
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Reviews</h1>
      <p className="mb-8 text-[14px] text-ink-soft">View and respond to reviews on your courses.</p>

      {REVIEWS.length === 0 ? (
        <EmptyState title="No reviews yet" description="Reviews from learners on your courses will appear here." />
      ) : (
        <div className="flex flex-col gap-4">
          {REVIEWS.map((r) => (
            <div key={r.id} className="rounded-card border border-line bg-card p-5">
              <div className="mb-1 flex items-center justify-between">
                <p className="text-[14px] font-semibold text-ink">{r.courseTitle}</p>
                <span className="flex items-center gap-0.5 text-gold-dark">
                  {Array.from({ length: 5 }).map((_, i) => (
                    <Star key={i} size={13} fill={i < r.rating ? "currentColor" : "none"} />
                  ))}
                </span>
              </div>
              <p className="mb-1 text-[13px] font-medium text-ink-soft">{r.author}</p>
              <p className="mb-3 text-[14px] text-ink">{r.comment}</p>

              {r.reply || submittedIds.has(r.id) ? (
                <div className="rounded-control bg-paper-dim px-3 py-2 text-[13px] text-ink-soft">
                  <span className="font-semibold text-ink">Your reply: </span>
                  {r.reply ?? replies[r.id]}
                </div>
              ) : (
                <div className="flex flex-col gap-2">
                  <Textarea
                    rows={2}
                    placeholder="Write a reply..."
                    value={replies[r.id] ?? ""}
                    onChange={(e) => handleReplyChange(r.id, e.target.value)}
                  />
                  <Button size="sm" className="self-start" disabled={!replies[r.id]?.trim()} onClick={() => handleSubmitReply(r.id)}>
                    Post reply
                  </Button>
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
