"use client";

import { useParams } from "next/navigation";
import Link from "next/link";
import { ArrowLeft, Send, Star, Clock, BarChart3, Globe2, PlayCircle } from "lucide-react";
import { Button, EmptyState } from "@saachi/ui";

export default function CoursePreviewPage() {
  const params = useParams<{ id: string }>();

  // NOTE: demo-only preview shell. Replace with useInstructorCourseDetail(params.id)
  // once the backend endpoint and typed hook are available, to render the
  // real title/curriculum/pricing exactly as learners will see it.

  function handleSubmitForReview() {
    // NOTE: demo-only, no backend submit-for-review mutation wired up yet.
  }

  return (
    <div className="mx-auto max-w-3xl">
      <Link
        href={`/instructor/courses/${params.id}/edit`}
        className="mb-4 inline-flex items-center gap-1.5 text-[13px] font-medium text-ink-soft hover:text-ink"
      >
        <ArrowLeft size={14} />
        Back to course
      </Link>

      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="font-display text-[26px] font-bold text-ink">Preview</h1>
          <p className="text-[14px] text-ink-soft">Course ID: {params.id}</p>
        </div>
        <Button onClick={handleSubmitForReview}>
          <Send size={14} className="mr-1.5" />
          Submit for review
        </Button>
      </div>

      <div className="rounded-card border border-line bg-card p-8">
        <p className="mb-2 text-[13px] font-medium text-gold-dark">Preview mode</p>
        <h2 className="mb-3 font-display text-[26px] font-bold text-ink">Untitled course</h2>

        <div className="mb-6 flex flex-wrap items-center gap-4 text-[13px] text-ink-soft">
          <span className="flex items-center gap-1.5">
            <Star size={14} className="text-gold-dark" fill="currentColor" />
            New
          </span>
          <span className="flex items-center gap-1.5">
            <BarChart3 size={14} /> Beginner
          </span>
          <span className="flex items-center gap-1.5">
            <Globe2 size={14} /> English
          </span>
          <span className="flex items-center gap-1.5">
            <Clock size={14} /> 0h total
          </span>
        </div>

        <div className="mb-8 flex aspect-video w-full items-center justify-center rounded-card border border-line bg-paper-dim text-ink-soft">
          <PlayCircle size={48} strokeWidth={1.25} />
        </div>

        <EmptyState
          title="Nothing to preview yet"
          description="Add a title, description, and curriculum to see how learners will view this course."
        />
      </div>
    </div>
  );
}