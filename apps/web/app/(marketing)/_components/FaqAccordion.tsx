"use client";

import { useState } from "react";
import { ChevronDown } from "lucide-react";

const FAQS = [
  {
    q: "Do I need any prior AI experience?",
    a: "No. Courses are organized by level -- Beginner, Intermediate, and Advanced -- so you can start exactly where you are."
  },
  {
    q: "Can I really earn money teaching on Saachi AI?",
    a: "Yes. Instructors set their own pricing and keep the majority of each sale after the platform commission, disclosed upfront at course submission."
  },
  {
    q: "Are certificates recognized?",
    a: "Every completed course issues a shareable completion certificate you can add to LinkedIn or your portfolio."
  },
  {
    q: "What if a course isn't what I expected?",
    a: "We offer refunds within 7 days of purchase, as long as you haven't completed more than 30% of the content."
  },
  {
    q: "Can I book 1-on-1 time with an instructor?",
    a: "Many instructors offer paid mentorship sessions -- book directly from their profile once you're enrolled."
  }
];

export function FaqAccordion() {
  const [openIndex, setOpenIndex] = useState<number | null>(0);

  return (
    <div className="flex flex-col divide-y divide-line rounded-card border border-line bg-card">
      {FAQS.map((item, i) => {
        const open = openIndex === i;
        return (
          <div key={item.q}>
            <button
              type="button"
              onClick={() => setOpenIndex(open ? null : i)}
              className="flex w-full items-center justify-between gap-4 px-5 py-4 text-left"
            >
              <span className="text-[14.5px] font-semibold text-ink">{item.q}</span>
              <ChevronDown
                size={17}
                className="shrink-0 text-ink-soft transition-transform duration-200"
                style={{ transform: open ? "rotate(180deg)" : "rotate(0deg)" }}
              />
            </button>
            <div
              className="overflow-hidden px-5 text-[13.5px] leading-relaxed text-ink-soft transition-all duration-200 ease-out"
              style={{
                maxHeight: open ? "200px" : "0px",
                paddingBottom: open ? "16px" : "0px",
                opacity: open ? 1 : 0
              }}
            >
              {item.a}
            </div>
          </div>
        );
      })}
    </div>
  );
}
