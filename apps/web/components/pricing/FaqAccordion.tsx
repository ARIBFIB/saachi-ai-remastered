"use client";

import { useState } from "react";
import { ChevronDown } from "lucide-react";

interface FaqItem {
  question: string;
  answer: string;
}

const faqs: FaqItem[] = [
  {
    question: "Can I cancel my subscription at any time?",
    answer: "Yes, you can cancel your subscription at any time from your account settings. You'll retain access until the end of your current billing period.",
  },
  {
    question: "Do you offer refunds?",
    answer: "We offer a 30-day money-back guarantee on all paid plans. Contact support if you're not satisfied.",
  },
  {
    question: "Can I switch plans later?",
    answer: "Absolutely. You can upgrade or downgrade your plan at any time, and we'll prorate the difference.",
  },
];

export function FaqAccordion() {
  const [openIndex, setOpenIndex] = useState<number | null>(null);

  return (
    <section className="mx-auto flex w-full max-w-[768px] flex-col gap-6">
      <h2 className="text-center text-3xl font-bold leading-10 text-[var(--token-color-ink)]">
        Frequently Asked Questions
      </h2>

      <div className="flex flex-col gap-4">
        {faqs.map((faq, index) => {
          const isOpen = openIndex === index;
          return (
            <div
              key={faq.question}
              className="overflow-hidden rounded-lg border border-[var(--token-color-border)] bg-[var(--token-color-surface)]"
            >
              <button
                type="button"
                onClick={() => setOpenIndex(isOpen ? null : index)}
                className="flex w-full items-center justify-between px-6 py-4 text-left"
              >
                <span className="text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">
                  {faq.question}
                </span>
                <ChevronDown
                  className={`h-3 w-3 shrink-0 text-[var(--token-color-inkSoft)] transition-transform ${
                    isOpen ? "rotate-180" : ""
                  }`}
                />
              </button>

              {isOpen && (
                <div className="border-t border-[var(--token-color-border)]/50 px-6 py-4 text-sm text-[var(--token-color-inkSoft)]">
                  {faq.answer}
                </div>
              )}
            </div>
          );
        })}
      </div>
    </section>
  );
}