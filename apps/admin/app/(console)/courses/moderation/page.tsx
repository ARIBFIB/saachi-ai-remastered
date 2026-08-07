"use client";

import { useState } from "react";
import { CheckCircle2, XCircle, ClipboardCheck, User, Tag } from "lucide-react";
import { useAdminModerationQueue, useModerateCourse, type AdminCourse } from "@saachi/api-client";
import { Button, Card, Textarea, Modal, EmptyState, ShimmerKpiCard , HelpTooltip } from "@saachi/ui";
import { formatCurrency, formatDate } from "@saachi/utils";

export default function CourseModerationQueuePage() {
  const { data: queue, isLoading } = useAdminModerationQueue();
  const moderate = useModerateCourse();
  const [rejectTarget, setRejectTarget] = useState<AdminCourse | null>(null);
  const [reason, setReason] = useState("");

  const handleApprove = (course: AdminCourse) => {
    moderate.mutate({ id: course.id, decision: "published" });
  };

  const handleRejectSubmit = () => {
    if (!rejectTarget) return;
    moderate.mutate({ id: rejectTarget.id, decision: "rejected", reason });
    setRejectTarget(null);
    setReason("");
  };

  return (
    <main className="mx-auto max-w-[1100px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
          <ClipboardCheck size={17} strokeWidth={1.75} />
        </div>
        <div>
          <div className="flex items-center gap-1.5"><h1 className="text-[22px] font-semibold text-ink">Course Moderation Queue</h1><HelpTooltip text="Courses submitted by instructors that are waiting for approval before they go live. Approve to publish, or reject with feedback so the instructor can revise." /></div>
          <p className="mt-0.5 text-[13px] text-ink-soft">Review newly submitted courses before they go live.</p>
        </div>
      </div>

      {isLoading ? (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          {Array.from({ length: 3 }).map((_, i) => (
            <ShimmerKpiCard key={i} />
          ))}
        </div>
      ) : !queue || queue.length === 0 ? (
        <EmptyState
          icon={<ClipboardCheck size={22} strokeWidth={1.75} />}
          title="Queue is clear"
          description="No courses are currently pending review."
        />
      ) : (
        <div className="flex flex-col gap-4">
          {queue.map((course) => (
            <Card key={course.id} className="flex flex-col gap-4 p-5 sm:flex-row sm:items-center">
              <div className="h-[90px] w-[160px] shrink-0 overflow-hidden rounded-control border border-line bg-paper-dim">
                {course.thumbnailUrl && (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={course.thumbnailUrl} alt={course.title} className="h-full w-full object-cover" />
                )}
              </div>

              <div className="flex-1">
                <h3 className="text-[15px] font-semibold text-ink">{course.title}</h3>
                <div className="mt-1.5 flex flex-wrap items-center gap-x-4 gap-y-1 text-[12.5px] text-ink-soft">
                  <span className="flex items-center gap-1.5">
                    <User size={13} strokeWidth={1.75} /> {course.instructorName}
                  </span>
                  <span className="flex items-center gap-1.5">
                    <Tag size={13} strokeWidth={1.75} /> {course.categoryId}
                  </span>
                  <span>Submitted {formatDate(course.submittedAt)}</span>
                  <span className="font-mono font-semibold text-ink">
                    {formatCurrency(course.price, course.currency)}
                  </span>
                </div>
              </div>

              <div className="flex shrink-0 gap-2">
                <Button size="sm" variant="secondary" onClick={() => setRejectTarget(course)}>
                  <XCircle size={14} strokeWidth={1.75} /> Reject
                </Button>
                <Button size="sm" onClick={() => handleApprove(course)} disabled={moderate.isPending}>
                  <CheckCircle2 size={14} strokeWidth={1.75} /> Approve
                </Button>
              </div>
            </Card>
          ))}
        </div>
      )}

      <Modal
        open={Boolean(rejectTarget)}
        onClose={() => setRejectTarget(null)}
        title="Reject course submission"
        footer={
          <>
            <Button variant="ghost" onClick={() => setRejectTarget(null)}>
              Cancel
            </Button>
            <Button variant="danger" onClick={handleRejectSubmit} disabled={!reason.trim() || moderate.isPending}>
              {moderate.isPending ? "Sending..." : "Send feedback & reject"}
            </Button>
          </>
        }
      >
        <p className="mb-4 text-[13px] text-ink-soft">
          Rejecting <span className="font-semibold text-ink">{rejectTarget?.title}</span>. This feedback is sent to
          the instructor so they can revise and resubmit.
        </p>
        <Textarea
          label="Feedback for instructor"
          placeholder="Explain what needs to change before this course can be approved..."
          rows={5}
          value={reason}
          onChange={(e) => setReason(e.target.value)}
        />
      </Modal>
    </main>
  );
}