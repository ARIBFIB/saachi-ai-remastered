"use client";

import { useMemo, useState } from "react";
import { MessageSquare, ArrowBigUp, CheckCircle2, Search } from "lucide-react";
import { useCommunityStore, type CommunityQuestion } from "@saachi/store";
import { useInstructorCourseStore } from "@saachi/store";
import { Button, Input, Select, EmptyState, Badge, Textarea, cn } from "@saachi/ui";

const FILTER_OPTIONS = [
  { label: "All questions", value: "all" },
  { label: "Unanswered", value: "unanswered" },
  { label: "Answered", value: "answered" }
];

// NOTE: demo-only "current instructor" identity used when posting a reply.
// Replace with the real authenticated instructor's name once auth/session
// (useSession from @saachi/api-client) is wired through this screen.
const CURRENT_INSTRUCTOR_NAME = "Ayesha Khan";

export default function InstructorCommunityPage() {
  const questions = useCommunityStore((s) => s.questions);
  const myCourses = useInstructorCourseStore((s) => s.courses);

  const [filter, setFilter] = useState("all");
  const [search, setSearch] = useState("");
  const [courseFilter, setCourseFilter] = useState("all");

  const myCourseIds = useMemo(() => new Set(myCourses.map((c) => c.id)), [myCourses]);

  const myQuestions = useMemo(
    () => questions.filter((q) => myCourseIds.has(q.courseId)),
    [questions, myCourseIds]
  );

  const filtered = useMemo(() => {
    let items = [...myQuestions];
    if (filter === "unanswered") items = items.filter((q) => q.answers.length === 0);
    if (filter === "answered") items = items.filter((q) => q.answers.length > 0);
    if (courseFilter !== "all") items = items.filter((q) => q.courseId === courseFilter);
    if (search.trim()) {
      const s = search.toLowerCase();
      items = items.filter((q) => q.body.toLowerCase().includes(s) || q.authorName.toLowerCase().includes(s));
    }
    return items.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
  }, [myQuestions, filter, courseFilter, search]);

  const unansweredCount = myQuestions.filter((q) => q.answers.length === 0).length;

  const courseOptions = [
    { label: "All courses", value: "all" },
    ...myCourses.map((c) => ({ label: c.title, value: c.id }))
  ];

  return (
    <div>
      <div className="mb-6 flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Community Q&amp;A</h1>
          <p className="text-[14px] text-ink-soft">
            Answer learner questions across all of your courses.
            {unansweredCount > 0 && (
              <span className="ml-2 font-semibold text-gold-dark">{unansweredCount} awaiting a reply</span>
            )}
          </p>
        </div>
        <div className="flex flex-wrap items-center gap-2">
          <div className="relative">
            <Search size={14} className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-ink-soft" />
            <input
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search questions..."
              className="h-10 w-56 rounded-control border border-line-strong bg-card pl-9 pr-3 text-[13px] text-ink outline-none placeholder:text-ink-soft/50 focus:border-gold"
            />
          </div>
          <Select options={courseOptions} value={courseFilter} onChange={(e) => setCourseFilter(e.target.value)} className="w-52" />
        </div>
      </div>

      <div className="mb-6 flex gap-1.5">
        {FILTER_OPTIONS.map((opt) => (
          <button
            key={opt.value}
            type="button"
            onClick={() => setFilter(opt.value)}
            className={cn(
              "rounded-full px-3.5 py-1.5 text-[12.5px] font-semibold transition-colors duration-150 ease-out",
              filter === opt.value ? "bg-ink text-paper" : "bg-paper-dim text-ink-soft hover:text-ink"
            )}
          >
            {opt.label}
          </button>
        ))}
      </div>

      {filtered.length === 0 ? (
        <EmptyState
          title="No questions here"
          description="Once learners ask questions on your courses, they'll show up here."
        />
      ) : (
        <div className="flex flex-col gap-4">
          {filtered.map((q) => (
            <QuestionCard key={q.id} question={q} />
          ))}
        </div>
      )}
    </div>
  );
}

function QuestionCard({ question }: { question: CommunityQuestion }) {
  const addAnswer = useCommunityStore((s) => s.addAnswer);
  const upvoteQuestion = useCommunityStore((s) => s.upvoteQuestion);

  const [replying, setReplying] = useState(false);
  const [reply, setReply] = useState("");

  const isAnswered = question.answers.length > 0;

  function handleSubmitReply() {
    if (!reply.trim()) return;
    addAnswer(question.id, CURRENT_INSTRUCTOR_NAME, reply.trim(), true);
    setReply("");
    setReplying(false);
  }

  return (
    <div className="rounded-card border border-line bg-card p-5">
      <div className="flex gap-4">
        <div className="flex shrink-0 flex-col items-center gap-1 pt-1">
          <button
            type="button"
            onClick={() => upvoteQuestion(question.id)}
            aria-label="Upvote question"
            className="flex flex-col items-center gap-0.5 text-ink-soft transition-colors hover:text-gold-dark"
          >
            <ArrowBigUp size={18} />
            <span className="text-[12px] font-semibold">{question.upvotes}</span>
          </button>
        </div>

        <div className="min-w-0 flex-1">
          <div className="mb-1.5 flex flex-wrap items-center gap-2">
            {question.courseTitle && (
              <span className="rounded-full bg-gold-tint px-2.5 py-0.5 text-[10.5px] font-semibold text-gold-dark">
                {question.courseTitle}
              </span>
            )}
            {isAnswered ? (
              <Badge variant="success">
                <CheckCircle2 size={11} className="mr-1" />
                Answered
              </Badge>
            ) : (
              <Badge variant="gold">Needs reply</Badge>
            )}
            <span className="text-[11.5px] text-ink-soft/60">
              {new Intl.DateTimeFormat("en-US", { dateStyle: "medium" }).format(new Date(question.createdAt))}
            </span>
          </div>

          <p className="mb-1 text-[13px] font-semibold text-ink">{question.authorName}</p>
          <p className="mb-3 text-[14px] leading-relaxed text-ink">{question.body}</p>

          {question.answers.length > 0 && (
            <div className="mb-3 flex flex-col gap-2.5 border-l-2 border-line pl-4">
              {question.answers.map((a) => (
                <div key={a.id}>
                  <div className="mb-0.5 flex items-center gap-1.5">
                    <span className="text-[12.5px] font-semibold text-ink">{a.authorName}</span>
                    {a.isInstructor && (
                      <span className="rounded-full bg-teal-light px-1.5 py-0.5 text-[10px] font-semibold text-teal">
                        Instructor
                      </span>
                    )}
                  </div>
                  <p className="text-[13px] text-ink-soft">{a.body}</p>
                </div>
              ))}
            </div>
          )}

          {replying ? (
            <div className="flex flex-col gap-2">
              <Textarea
                autoFocus
                rows={3}
                placeholder="Write a reply..."
                value={reply}
                onChange={(e) => setReply(e.target.value)}
              />
              <div className="flex gap-2">
                <Button size="sm" disabled={!reply.trim()} onClick={handleSubmitReply}>
                  Post reply
                </Button>
                <Button size="sm" variant="secondary" onClick={() => setReplying(false)}>
                  Cancel
                </Button>
              </div>
            </div>
          ) : (
            <Button size="sm" variant="secondary" onClick={() => setReplying(true)}>
              <MessageSquare size={13} className="mr-1.5" />
              {isAnswered ? "Add another reply" : "Reply"}
            </Button>
          )}
        </div>
      </div>
    </div>
  );
}
