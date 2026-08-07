# step6-mentorship-community-orders-2fa.ps1
# Run from: SAI2 root folder

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $fullPath = Join-Path -Path (Get-Location).Path -ChildPath $Path
    $dir = Split-Path -Parent $fullPath
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($fullPath, $Content, $enc)
    Write-Host "  wrote $fullPath"
}

function Patch-File {
    param([string]$Path, [string]$OldStr, [string]$NewStr, [string]$Label)
    $fullPath = Join-Path -Path (Get-Location).Path -ChildPath $Path
    if (-not (Test-Path $fullPath)) {
        Write-Host "  SKIP (file not found): $fullPath" -ForegroundColor Yellow
        return
    }
    $content = Get-Content -Path $fullPath -Raw
    if ($content.Contains($OldStr)) {
        $updated = $content.Replace($OldStr, $NewStr)
        $enc = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($fullPath, $updated, $enc)
        Write-Host "  patched ($Label): $fullPath"
    } else {
        Write-Host "  WARNING: pattern for '$Label' not found in $fullPath - skipped." -ForegroundColor Yellow
    }
}

Write-Host "Step 6: mentorship booking + community Q&A + order history + 2FA login step..." -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. useOrderStore - order history derived from checkout (separate from enrollment)
# ---------------------------------------------------------------------------
$orderStore = @'
import { create } from "zustand";
import { persist } from "zustand/middleware";

export type OrderLineItem = {
  courseId: string;
  title: string;
  price: number;
};

export type Order = {
  id: string;
  items: OrderLineItem[];
  subtotal: number;
  discount: number;
  total: number;
  currency: string;
  paymentMethod: string;
  createdAt: string;
  status: "paid" | "refunded";
};

type OrderState = {
  orders: Order[];
  addOrder: (order: Omit<Order, "id" | "createdAt" | "status">) => Order;
};

export const useOrderStore = create<OrderState>()(
  persist(
    (set, get) => ({
      orders: [],
      addOrder: (order) => {
        const newOrder: Order = {
          ...order,
          id: `ORD-${Date.now().toString(36).toUpperCase()}`,
          createdAt: new Date().toISOString(),
          status: "paid"
        };
        set({ orders: [newOrder, ...get().orders] });
        return newOrder;
      }
    }),
    { name: "saachi-orders" }
  )
);
'@
Write-Utf8NoBom -Path "packages\store\src\useOrderStore.ts" -Content $orderStore

# ---------------------------------------------------------------------------
# 2. useCommunityStore - per-course Q&A threads
# ---------------------------------------------------------------------------
$communityStore = @'
import { create } from "zustand";
import { persist } from "zustand/middleware";

export type CommunityAnswer = {
  id: string;
  authorName: string;
  isInstructor: boolean;
  body: string;
  createdAt: string;
  upvotes: number;
};

export type CommunityQuestion = {
  id: string;
  courseId: string;
  authorName: string;
  body: string;
  createdAt: string;
  upvotes: number;
  answers: CommunityAnswer[];
};

const SEED_QUESTIONS: CommunityQuestion[] = [
  {
    id: "q_1",
    courseId: "crs_001",
    authorName: "Hina Malik",
    body: "For few-shot prompting, how many examples is usually enough before it stops improving results?",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 30).toISOString(),
    upvotes: 6,
    answers: [
      {
        id: "a_1",
        authorName: "Sana Rizvi",
        isInstructor: true,
        body: "Usually 3-5 well-chosen examples get you most of the benefit - past that you're often better off improving instructions instead.",
        createdAt: new Date(Date.now() - 1000 * 60 * 60 * 20).toISOString(),
        upvotes: 9
      }
    ]
  },
  {
    id: "q_2",
    courseId: "crs_001",
    authorName: "Bilal Ahmed",
    body: "Does the prompt library template work with Claude and Gemini too, or is it ChatGPT-specific?",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 10).toISOString(),
    upvotes: 2,
    answers: []
  }
];

type CommunityState = {
  questions: CommunityQuestion[];
  addQuestion: (courseId: string, authorName: string, body: string) => void;
  addAnswer: (questionId: string, authorName: string, body: string) => void;
  upvoteQuestion: (questionId: string) => void;
};

function genId(prefix: string) {
  return `${prefix}_${Math.random().toString(36).slice(2, 9)}`;
}

export const useCommunityStore = create<CommunityState>()(
  persist(
    (set, get) => ({
      questions: SEED_QUESTIONS,

      addQuestion: (courseId, authorName, body) => {
        const newQuestion: CommunityQuestion = {
          id: genId("q"),
          courseId,
          authorName,
          body,
          createdAt: new Date().toISOString(),
          upvotes: 0,
          answers: []
        };
        set({ questions: [newQuestion, ...get().questions] });
      },

      addAnswer: (questionId, authorName, body) => {
        set({
          questions: get().questions.map((q) =>
            q.id === questionId
              ? {
                  ...q,
                  answers: [
                    ...q.answers,
                    {
                      id: genId("a"),
                      authorName,
                      isInstructor: false,
                      body,
                      createdAt: new Date().toISOString(),
                      upvotes: 0
                    }
                  ]
                }
              : q
          )
        });
      },

      upvoteQuestion: (questionId) => {
        set({
          questions: get().questions.map((q) =>
            q.id === questionId ? { ...q, upvotes: q.upvotes + 1 } : q
          )
        });
      }
    }),
    { name: "saachi-community" }
  )
);
'@
Write-Utf8NoBom -Path "packages\store\src\useCommunityStore.ts" -Content $communityStore

$storeIndexUpdated = @'
export * from "./useCartStore";
export * from "./useWishlistStore";
export * from "./useEnrollmentStore";
export * from "./useNotificationStore";
export * from "./useInstructorCourseStore";
export * from "./useCourseBuilderStore";
export * from "./useOrderStore";
export * from "./useCommunityStore";
'@
Write-Utf8NoBom -Path "packages\store\src\index.ts" -Content $storeIndexUpdated

# ---------------------------------------------------------------------------
# 3. Checkout page - now also records an Order (in addition to enrollment)
# ---------------------------------------------------------------------------
Patch-File -Path "apps\web\app\(learner)\checkout\page.tsx" `
  -OldStr 'import { useCartStore, useEnrollmentStore } from "@saachi/store";' `
  -NewStr 'import { useCartStore, useEnrollmentStore, useOrderStore } from "@saachi/store";' `
  -Label "import useOrderStore in checkout"

Patch-File -Path "apps\web\app\(learner)\checkout\page.tsx" `
  -OldStr '  const cart = useCartStore();
  const enrollment = useEnrollmentStore();' `
  -NewStr @'
  const cart = useCartStore();
  const enrollment = useEnrollmentStore();
  const orders = useOrderStore();
'@ `
  -Label "init useOrderStore in checkout"

Patch-File -Path "apps\web\app\(learner)\checkout\page.tsx" `
  -OldStr '    enrollment.enroll(
      cart.items.map((item) => ({
        courseId: item.courseId,
        slug: item.slug,
        title: item.title,
        thumbnailUrl: item.thumbnailUrl,
        instructorName: item.instructorName
      }))
    );

    cart.clear();' `
  -NewStr @'
    enrollment.enroll(
      cart.items.map((item) => ({
        courseId: item.courseId,
        slug: item.slug,
        title: item.title,
        thumbnailUrl: item.thumbnailUrl,
        instructorName: item.instructorName
      }))
    );

    orders.addOrder({
      items: cart.items.map((item) => ({
        courseId: item.courseId,
        title: item.title,
        price: item.price
      })),
      subtotal: cart.subtotal(),
      discount: cart.discount(),
      total: cart.total(),
      currency: currency,
      paymentMethod: method
    });

    cart.clear();
'@ `
  -Label "record order on successful checkout"

# ---------------------------------------------------------------------------
# 4. Order History page
# ---------------------------------------------------------------------------
$ordersPage = @'
"use client";

import Link from "next/link";
import { Receipt, Download } from "lucide-react";
import { useOrderStore } from "@saachi/store";
import { Button, Card, Badge, EmptyState } from "@saachi/ui";
import { formatCurrency, formatDate } from "@saachi/utils";

export default function OrdersPage() {
  const { orders } = useOrderStore();

  return (
    <main className="mx-auto max-w-[900px] px-6 py-10 md:px-10">
      <div className="mb-8">
        <h1 className="font-display text-[26px] font-semibold text-ink">Order History</h1>
        <p className="mt-1 text-[14px] text-ink-soft">All your past purchases on Saachi AI.</p>
      </div>

      {orders.length === 0 ? (
        <EmptyState
          icon={<Receipt size={22} />}
          title="No orders yet"
          description="Once you complete a purchase, it will show up here."
          action={
            <Link href="/courses">
              <Button>Browse courses</Button>
            </Link>
          }
        />
      ) : (
        <div className="flex flex-col gap-4">
          {orders.map((order) => (
            <Card key={order.id} className="p-5">
              <div className="mb-3 flex flex-wrap items-center justify-between gap-2">
                <div>
                  <p className="text-[14px] font-semibold text-ink">{order.id}</p>
                  <p className="mt-0.5 text-[12px] text-ink-soft">{formatDate(order.createdAt)}</p>
                </div>
                <div className="flex items-center gap-3">
                  <Badge variant={order.status === "paid" ? "success" : "error"}>
                    {order.status === "paid" ? "Paid" : "Refunded"}
                  </Badge>
                  <Button size="sm" variant="secondary">
                    <Download size={14} /> Invoice
                  </Button>
                </div>
              </div>

              <div className="flex flex-col gap-1 border-t border-line pt-3">
                {order.items.map((item) => (
                  <div key={item.courseId} className="flex justify-between text-[13px] text-ink-soft">
                    <span className="line-clamp-1 pr-2">{item.title}</span>
                    <span className="shrink-0 text-ink">{formatCurrency(item.price, order.currency)}</span>
                  </div>
                ))}
              </div>

              <div className="mt-3 flex justify-between border-t border-line pt-3 text-[14px] font-semibold text-ink">
                <span>Total ({order.paymentMethod.replace("_", " ")})</span>
                <span>{formatCurrency(order.total, order.currency)}</span>
              </div>
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(learner)\orders\page.tsx" -Content $ordersPage

# ---------------------------------------------------------------------------
# 5. LearnerShell - add Orders link to sidebar nav
# ---------------------------------------------------------------------------
Patch-File -Path "apps\web\app\(learner)\_components\LearnerShell.tsx" `
  -OldStr '  Award,
  Bell,
  Settings,
  LogOut,
  Menu,
  X
} from "lucide-react";' `
  -NewStr @'
  Award,
  Bell,
  Settings,
  LogOut,
  Menu,
  X,
  Receipt,
  Users2
} from "lucide-react";
'@ `
  -Label "add Receipt/Users2 icons import"

Patch-File -Path "apps\web\app\(learner)\_components\LearnerShell.tsx" `
  -OldStr '  { label: "Certificates", href: "/certificates", icon: Award },
  { label: "Notifications", href: "/notifications", icon: Bell },' `
  -NewStr @'
  { label: "Certificates", href: "/certificates", icon: Award },
  { label: "Orders", href: "/orders", icon: Receipt },
  { label: "Mentorship", href: "/mentorship", icon: Users2 },
  { label: "Notifications", href: "/notifications", icon: Bell },
'@ `
  -Label "add Orders + Mentorship nav items"

# ---------------------------------------------------------------------------
# 6. Mentorship booking page
# ---------------------------------------------------------------------------
$mentorshipPage = @'
"use client";

import { useState } from "react";
import Link from "next/link";
import { Users2, Clock, Video, CheckCircle2 } from "lucide-react";
import { Button, Card, EmptyState } from "@saachi/ui";
import { formatCurrency } from "@saachi/utils";

const MENTORS = [
  {
    id: "ins_003",
    name: "Ayesha Khan",
    expertise: "AI Automation & n8n Workflows",
    avatarSeed: "ayesha-khan-instructor",
    rate: 40,
    slots: ["Mon 3:00 PM", "Wed 11:00 AM", "Fri 4:30 PM"]
  },
  {
    id: "ins_004",
    name: "Bilal Ahmed",
    expertise: "AI Customer Support Systems",
    avatarSeed: "bilal-ahmed-instructor",
    rate: 55,
    slots: ["Tue 2:00 PM", "Thu 10:00 AM"]
  },
  {
    id: "ins_006",
    name: "Usman Ali",
    expertise: "AI API Integration for Developers",
    avatarSeed: "usman-ali",
    rate: 65,
    slots: ["Mon 6:00 PM", "Wed 7:00 PM", "Sat 12:00 PM"]
  }
];

export default function MentorshipPage() {
  const [booked, setBooked] = useState<Record<string, string>>({});

  const handleBook = (mentorId: string, slot: string) => {
    setBooked((prev) => ({ ...prev, [mentorId]: slot }));
  };

  return (
    <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
      <div className="mb-8">
        <h1 className="font-display text-[26px] font-semibold text-ink">Mentorship</h1>
        <p className="mt-1 text-[14px] text-ink-soft">
          Book 1-on-1 time with an instructor for personalized guidance.
        </p>
      </div>

      <div className="flex flex-col gap-4">
        {MENTORS.map((mentor) => {
          const bookedSlot = booked[mentor.id];
          return (
            <Card key={mentor.id} className="flex flex-col gap-4 p-5 sm:flex-row sm:items-center sm:justify-between">
              <div className="flex items-center gap-4">
                <div className="flex h-14 w-14 shrink-0 items-center justify-center overflow-hidden rounded-full bg-teal-light text-[16px] font-semibold text-teal">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img
                    src={`https://picsum.photos/seed/${mentor.avatarSeed}/150/150`}
                    alt={mentor.name}
                    className="h-full w-full object-cover"
                  />
                </div>
                <div>
                  <p className="text-[15px] font-semibold text-ink">{mentor.name}</p>
                  <p className="text-[13px] text-ink-soft">{mentor.expertise}</p>
                  <p className="mt-1 flex items-center gap-1 text-[12px] text-ink-soft">
                    <Clock size={12} /> {formatCurrency(mentor.rate, "USD")} / 30 min session
                  </p>
                </div>
              </div>

              {bookedSlot ? (
                <div className="flex items-center gap-2 rounded-control bg-teal-light px-4 py-2.5 text-[13px] font-semibold text-teal">
                  <CheckCircle2 size={16} /> Booked for {bookedSlot}
                </div>
              ) : (
                <div className="flex flex-wrap gap-2">
                  {mentor.slots.map((slot) => (
                    <button
                      key={slot}
                      type="button"
                      onClick={() => handleBook(mentor.id, slot)}
                      className="rounded-full border border-line-strong px-3.5 py-2 text-[12px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:border-ink hover:text-ink"
                    >
                      {slot}
                    </button>
                  ))}
                </div>
              )}
            </Card>
          );
        })}
      </div>

      {Object.keys(booked).length > 0 && (
        <Card className="mt-8 flex items-center gap-3 p-5">
          <Video size={18} className="shrink-0 text-teal" />
          <p className="text-[13px] text-ink-soft">
            This is a demo booking - no real calendar invite or payment was processed. Once the
            backend Mentorship module (Doc 1, Section 6.2) is live, this will generate a real
            video-call link and checkout.
          </p>
        </Card>
      )}
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(learner)\mentorship\page.tsx" -Content $mentorshipPage

# ---------------------------------------------------------------------------
# 7. Community / Course Q&A page
# ---------------------------------------------------------------------------
$communityPage = @'
"use client";

import { useState } from "react";
import { ArrowUp, MessageSquare, BadgeCheck } from "lucide-react";
import { useCourseDetail } from "@saachi/api-client";
import { useCommunityStore } from "@saachi/store";
import { useSession } from "@saachi/api-client";
import { Button, Card, Textarea, EmptyState, SkeletonText } from "@saachi/ui";
import { formatRelativeTime } from "@saachi/utils";

export default function CommunityPage({ params }: { params: { courseId: string } }) {
  const { data: course, isLoading } = useCourseDetail(params.courseId);
  const { data: session } = useSession();
  const community = useCommunityStore();
  const [newQuestion, setNewQuestion] = useState("");
  const [replyDrafts, setReplyDrafts] = useState<Record<string, string>>({});

  const questions = community.questions
    .filter((q) => q.courseId === params.courseId)
    .sort((a, b) => b.upvotes - a.upvotes);

  const handleAskQuestion = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newQuestion.trim()) return;
    community.addQuestion(params.courseId, session?.fullName ?? "You", newQuestion.trim());
    setNewQuestion("");
  };

  const handleReply = (questionId: string) => {
    const body = replyDrafts[questionId];
    if (!body?.trim()) return;
    community.addAnswer(questionId, session?.fullName ?? "You", body.trim());
    setReplyDrafts((prev) => ({ ...prev, [questionId]: "" }));
  };

  if (isLoading) {
    return (
      <main className="mx-auto max-w-[800px] px-6 py-10 md:px-10">
        <SkeletonText lines={4} />
      </main>
    );
  }

  return (
    <main className="mx-auto max-w-[800px] px-6 py-10 md:px-10">
      <div className="mb-8">
        <h1 className="font-display text-[24px] font-semibold text-ink">
          Q&A - {course?.title ?? "Course"}
        </h1>
        <p className="mt-1 text-[14px] text-ink-soft">Ask questions, get help from instructors and peers.</p>
      </div>

      <Card className="mb-8 p-5">
        <form onSubmit={handleAskQuestion} className="flex flex-col gap-3">
          <Textarea
            placeholder="Ask a question about this course..."
            value={newQuestion}
            onChange={(e) => setNewQuestion(e.target.value)}
            rows={3}
          />
          <Button type="submit" className="w-fit">
            Post question
          </Button>
        </form>
      </Card>

      {questions.length === 0 ? (
        <EmptyState
          icon={<MessageSquare size={22} />}
          title="No questions yet"
          description="Be the first to ask something about this course."
        />
      ) : (
        <div className="flex flex-col gap-4">
          {questions.map((q) => (
            <Card key={q.id} className="p-5">
              <div className="flex gap-4">
                <button
                  type="button"
                  onClick={() => community.upvoteQuestion(q.id)}
                  className="flex shrink-0 flex-col items-center gap-1 rounded-control border border-line-strong px-2.5 py-2 text-ink-soft hover:border-gold-dark hover:text-gold-dark"
                >
                  <ArrowUp size={14} />
                  <span className="text-[12px] font-semibold">{q.upvotes}</span>
                </button>
                <div className="flex-1">
                  <p className="text-[14px] text-ink">{q.body}</p>
                  <p className="mt-2 text-[12px] text-ink-soft">
                    {q.authorName} &middot; {formatRelativeTime(q.createdAt)}
                  </p>

                  {q.answers.length > 0 && (
                    <div className="mt-4 flex flex-col gap-3 border-l-2 border-line pl-4">
                      {q.answers.map((a) => (
                        <div key={a.id}>
                          <div className="flex items-center gap-1.5">
                            <span className="text-[13px] font-semibold text-ink">{a.authorName}</span>
                            {a.isInstructor && <BadgeCheck size={13} className="text-teal" />}
                          </div>
                          <p className="mt-1 text-[13px] text-ink-soft">{a.body}</p>
                          <p className="mt-1 text-[11px] text-ink-soft/60">{formatRelativeTime(a.createdAt)}</p>
                        </div>
                      ))}
                    </div>
                  )}

                  <div className="mt-4 flex items-center gap-2">
                    <Textarea
                      placeholder="Write a reply..."
                      rows={1}
                      value={replyDrafts[q.id] ?? ""}
                      onChange={(e) => setReplyDrafts((prev) => ({ ...prev, [q.id]: e.target.value }))}
                      className="flex-1"
                    />
                    <Button size="sm" variant="secondary" onClick={() => handleReply(q.id)}>
                      Reply
                    </Button>
                  </div>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(learner)\community\[courseId]\page.tsx" -Content $communityPage

# ---------------------------------------------------------------------------
# 8. Link to community from course player sidebar header
# ---------------------------------------------------------------------------
Patch-File -Path "apps\web\app\(learner)\learn\[courseId]\[lessonId]\page.tsx" `
  -OldStr '        <span className="text-[12px] text-ink-soft">
          Lesson {currentIndex + 1} of {flatLessons.length}
        </span>
      </header>' `
  -NewStr @'
        <div className="flex items-center gap-4">
          <Link
            href={`/community/${params.courseId}`}
            className="text-[12px] font-medium text-ink-soft hover:text-ink"
          >
            Q&A
          </Link>
          <span className="text-[12px] text-ink-soft">
            Lesson {currentIndex + 1} of {flatLessons.length}
          </span>
        </div>
      </header>
'@ `
  -Label "add Q&A link to course player header"

# ---------------------------------------------------------------------------
# 9. Login 2FA step page
# ---------------------------------------------------------------------------
$twoFaPage = @'
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { ShieldCheck } from "lucide-react";
import { twoFactorSchema, type TwoFactorInput } from "@saachi/utils";
import { Button, Card, Input } from "@saachi/ui";

export default function TwoFactorPage() {
  const router = useRouter();
  const [serverError, setServerError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting }
  } = useForm<TwoFactorInput>({
    resolver: zodResolver(twoFactorSchema)
  });

  const onSubmit = async (data: TwoFactorInput) => {
    setServerError(null);
    // NOTE: demo-only. In this build, useLogin never returns requires2fa: true,
    // so this screen is reachable directly for UI/QA purposes. Wire to real
    // Auth API 2FA verification once the backend is available.
    await new Promise((resolve) => setTimeout(resolve, 500));
    if (data.code !== "000000") {
      setServerError("Demo mode: enter 000000 to continue.");
      return;
    }
    router.push("/dashboard");
  };

  return (
    <Card className="w-full max-w-[400px] p-8 text-center">
      <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-teal-light text-teal">
        <ShieldCheck size={22} />
      </div>
      <h1 className="font-display text-[22px] font-semibold text-ink">Two-factor verification</h1>
      <p className="mb-6 mt-2 text-[14px] text-ink-soft">
        Enter the 6-digit code from your authenticator app.
      </p>

      <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4 text-left">
        <Input
          label="Verification code"
          placeholder="000000"
          maxLength={6}
          {...register("code")}
          error={errors.code?.message}
        />

        {serverError && <p className="text-[13px] text-error">{serverError}</p>}

        <Button type="submit" size="lg" disabled={isSubmitting}>
          {isSubmitting ? "Verifying..." : "Verify"}
        </Button>
      </form>
    </Card>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(auth)\login\2fa\page.tsx" -Content $twoFaPage

Write-Host ""
Write-Host "Step 6 done." -ForegroundColor Green
Write-Host "Run: pnpm dev:web" -ForegroundColor Green
Write-Host "Test: buy a course -> /orders, /mentorship (book a slot), open a course player -> Q&A link -> /community/[courseId] (ask + reply), /login/2fa (demo code 000000)" -ForegroundColor Green