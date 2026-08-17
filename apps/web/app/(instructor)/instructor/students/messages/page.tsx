"use client";

import { EmptyState } from "@saachi/ui";

// Phase 1 scaffold - placeholder route so sidebar navigation works end-to-end.
// Real content/dummy data for this screen is filled in a later phase.
export default function InstructorStudentsMessagesPage() {
  return (
    <div>
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Message Students</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Send messages to individual students or broadcast to a whole course.</p>

      <EmptyState
        title="Coming soon"
        description="This section is scaffolded and will be filled in during a later phase."
      />
    </div>
  );
}
