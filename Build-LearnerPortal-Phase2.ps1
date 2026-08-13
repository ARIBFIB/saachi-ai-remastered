<#
  Build-LearnerPortal-Phase2.ps1
  ---------------------------------------------------------------------------
  Scaffolds the Learner Portal (apps/web) using existing @saachi/ui,
  @saachi/api-client, @saachi/store packages. Same simple/dynamic approach
  as Phase 1 — no new design system, reuses existing components.

  Does NOT touch apps/admin.

  Pages created (all under apps/web/app/(learner)/):
    /dashboard
    /my-courses
    /learn/[courseId]/[lessonId]
    /certificates
    /wishlist
    /cart
    /checkout
    /orders
    /notifications
    /settings

  Run from the SAI2 repo root:
    powershell -ExecutionPolicy Bypass -File .\Build-LearnerPortal-Phase2.ps1
#>

$ErrorActionPreference = "Stop"
$Root = (Get-Location).Path

function Write-Utf8NoBom {
    param([string]$RelativePath, [string]$Content)
    $fullPath = Join-Path $Root $RelativePath
    $dir = Split-Path $fullPath -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    [System.IO.File]::WriteAllText($fullPath, $Content, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "  wrote $RelativePath"
}

Write-Host "== SAI2 :: Learner Portal Phase 2 scaffold ==" -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. Learner layout — sidebar nav shared across all learner pages
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/(learner)/layout.tsx" @'
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import type { ReactNode } from "react";
import {
  LayoutDashboard,
  BookOpen,
  Award,
  Heart,
  ShoppingCart,
  Receipt,
  Bell,
  Settings
} from "lucide-react";
import { cn } from "@saachi/ui";

const NAV_ITEMS = [
  { href: "/dashboard", label: "Dashboard", icon: LayoutDashboard },
  { href: "/my-courses", label: "My Courses", icon: BookOpen },
  { href: "/certificates", label: "Certificates", icon: Award },
  { href: "/wishlist", label: "Wishlist", icon: Heart },
  { href: "/cart", label: "Cart", icon: ShoppingCart },
  { href: "/orders", label: "Orders", icon: Receipt },
  { href: "/notifications", label: "Notifications", icon: Bell },
  { href: "/settings", label: "Settings", icon: Settings }
];

export default function LearnerLayout({ children }: { children: ReactNode }) {
  const pathname = usePathname();

  return (
    <div className="mx-auto grid max-w-7xl grid-cols-1 gap-8 px-4 py-10 md:grid-cols-[220px_1fr] md:px-8">
      <aside className="h-fit rounded-card border border-line bg-card p-3 md:sticky md:top-24">
        <nav className="flex flex-row gap-1 overflow-x-auto md:flex-col md:overflow-visible">
          {NAV_ITEMS.map((item) => {
            const active = pathname === item.href;
            const Icon = item.icon;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  "flex shrink-0 items-center gap-2.5 rounded-control px-3 py-2.5 text-[14px] font-medium transition-colors",
                  active ? "bg-gold text-ink" : "text-ink-soft hover:bg-paper-dim"
                )}
              >
                <Icon size={16} strokeWidth={1.75} />
                {item.label}
              </Link>
            );
          })}
        </nav>
      </aside>

      <div>{children}</div>
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 2. Dashboard
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/(learner)/dashboard/page.tsx" @'
"use client";

import Link from "next/link";
import { BookOpen, Award, Bell } from "lucide-react";
import { useSession } from "@saachi/api-client";
import { useEnrollmentStore, useNotificationStore } from "@saachi/store";
import { Button, EmptyState, KpiCard } from "@saachi/ui";

export default function LearnerDashboardPage() {
  const { data: session } = useSession();
  const enrollments = useEnrollmentStore((s) => s.enrollments);
  const notifications = useNotificationStore((s) => s.items);

  const inProgress = enrollments.filter((e) => e.progressPercent > 0 && e.progressPercent < 100);
  const completed = enrollments.filter((e) => e.progressPercent === 100);
  const unreadCount = notifications.filter((n) => !n.read).length;

  return (
    <div>
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">
        Welcome back{session ? `, ${session.fullName}` : ""}
      </h1>
      <p className="mb-8 text-[14px] text-ink-soft">Here is where you left off.</p>

      <div className="mb-10 grid grid-cols-1 gap-4 sm:grid-cols-3">
        <KpiCard label="Enrolled courses" value={String(enrollments.length)} icon={BookOpen} />
        <KpiCard label="Completed" value={String(completed.length)} icon={Award} />
        <KpiCard label="Unread notifications" value={String(unreadCount)} icon={Bell} />
      </div>

      <h2 className="mb-4 font-display text-[20px] font-semibold text-ink">Continue learning</h2>
      {inProgress.length === 0 ? (
        <EmptyState
          title="No courses in progress"
          description="Enroll in a course to see it here."
          action={
            <Link href="/courses">
              <Button>Browse courses</Button>
            </Link>
          }
        />
      ) : (
        <div className="flex flex-col gap-3">
          {inProgress.map((e) => (
            <Link
              key={e.courseId}
              href={`/learn/${e.courseId}/lesson`}
              className="flex items-center gap-4 rounded-card border border-line bg-card p-4 transition-colors hover:border-gold-dark/40"
            >
              {e.thumbnailUrl && (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={e.thumbnailUrl} alt={e.title} className="h-16 w-28 shrink-0 rounded-control object-cover" />
              )}
              <div className="min-w-0 flex-1">
                <h3 className="truncate text-[15px] font-semibold text-ink">{e.title}</h3>
                <p className="text-[13px] text-ink-soft">{e.instructorName}</p>
                <div className="mt-2 h-1.5 w-full overflow-hidden rounded-full bg-paper-dim">
                  <div className="h-full rounded-full bg-gold" style={{ width: `${e.progressPercent}%` }} />
                </div>
              </div>
              <span className="shrink-0 text-[13px] font-semibold text-ink-soft">{e.progressPercent}%</span>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 3. My Courses
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/(learner)/my-courses/page.tsx" @'
"use client";

import Link from "next/link";
import { useState } from "react";
import { useEnrollmentStore } from "@saachi/store";
import { Button, EmptyState, Select } from "@saachi/ui";

const STATUS_OPTIONS = [
  { label: "All", value: "all" },
  { label: "In progress", value: "in_progress" },
  { label: "Completed", value: "completed" },
  { label: "Not started", value: "not_started" }
];

export default function MyCoursesPage() {
  const enrollments = useEnrollmentStore((s) => s.enrollments);
  const [status, setStatus] = useState("all");

  const filtered = enrollments.filter((e) => {
    if (status === "in_progress") return e.progressPercent > 0 && e.progressPercent < 100;
    if (status === "completed") return e.progressPercent === 100;
    if (status === "not_started") return e.progressPercent === 0;
    return true;
  });

  return (
    <div>
      <div className="mb-6 flex items-center justify-between">
        <h1 className="font-display text-[26px] font-bold text-ink">My Courses</h1>
        <Select options={STATUS_OPTIONS} value={status} onChange={(e) => setStatus(e.target.value)} className="w-48" />
      </div>

      {filtered.length === 0 ? (
        <EmptyState
          title="No courses here yet"
          description="Courses you enroll in will show up here."
          action={
            <Link href="/courses">
              <Button>Browse courses</Button>
            </Link>
          }
        />
      ) : (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {filtered.map((e) => (
            <Link
              key={e.courseId}
              href={`/learn/${e.courseId}/lesson`}
              className="flex flex-col overflow-hidden rounded-card border border-line bg-card transition-colors hover:border-gold-dark/40"
            >
              {e.thumbnailUrl && (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={e.thumbnailUrl} alt={e.title} className="aspect-video w-full object-cover" />
              )}
              <div className="p-4">
                <h3 className="line-clamp-2 text-[15px] font-semibold text-ink">{e.title}</h3>
                <p className="mt-1 text-[13px] text-ink-soft">{e.instructorName}</p>
                <div className="mt-3 h-1.5 w-full overflow-hidden rounded-full bg-paper-dim">
                  <div className="h-full rounded-full bg-gold" style={{ width: `${e.progressPercent}%` }} />
                </div>
                <p className="mt-1.5 text-[12px] text-ink-soft">{e.progressPercent}% complete</p>
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 4. Course Player (Learn)
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/(learner)/learn/[courseId]/[lessonId]/page.tsx" @'
"use client";

import { useMemo } from "react";
import { useParams, useRouter } from "next/navigation";
import { CheckCircle2, Circle, PlayCircle, FileText, HelpCircle, Paperclip } from "lucide-react";
import { useCourseDetail } from "@saachi/api-client";
import { useEnrollmentStore } from "@saachi/store";
import { Button, Loading, cn } from "@saachi/ui";

const LESSON_ICON = {
  video: PlayCircle,
  text: FileText,
  quiz: HelpCircle,
  resource: Paperclip
} as const;

export default function CoursePlayerPage() {
  const params = useParams<{ courseId: string; lessonId: string }>();
  const router = useRouter();
  const { data: course, isLoading } = useCourseDetail(params.courseId);
  const enrollment = useEnrollmentStore((s) => s.getEnrollment(params.courseId));
  const markLessonComplete = useEnrollmentStore((s) => s.markLessonComplete);

  const allLessons = useMemo(
    () => course?.curriculum?.flatMap((mod) => mod.lessons) ?? [],
    [course]
  );

  const currentLesson =
    allLessons.find((l) => l.id === params.lessonId) ?? allLessons[0];

  if (isLoading || !course) {
    return <Loading fullScreen label="Loading lesson..." />;
  }

  if (!currentLesson) {
    return <p className="p-10 text-center text-ink-soft">No lessons found for this course.</p>;
  }

  const isComplete = enrollment?.completedLessonIds.includes(currentLesson.id) ?? false;
  const Icon = LESSON_ICON[currentLesson.type];

  function goToLesson(lessonId: string) {
    router.push(`/learn/${params.courseId}/${lessonId}`);
  }

  return (
    <div className="mx-auto grid max-w-7xl grid-cols-1 gap-6 px-4 py-8 md:grid-cols-[1fr_320px] md:px-8">
      <div>
        <p className="mb-1 text-[13px] font-medium text-gold-dark">{course.title}</p>
        <h1 className="mb-4 font-display text-[24px] font-bold text-ink">{currentLesson.title}</h1>

        <div className="mb-6 flex aspect-video w-full items-center justify-center rounded-card border border-line bg-paper-dim">
          <Icon size={48} className="text-ink-soft/40" />
        </div>

        <Button
          onClick={() => markLessonComplete(params.courseId, currentLesson.id, allLessons.length)}
          disabled={isComplete}
        >
          {isComplete ? "Lesson completed" : "Mark as complete"}
        </Button>
      </div>

      <aside className="h-fit rounded-card border border-line bg-card p-4 md:sticky md:top-24">
        <h2 className="mb-3 text-[13px] font-semibold uppercase tracking-[0.06em] text-ink-soft/70">
          Curriculum
        </h2>
        <div className="flex flex-col gap-4">
          {course.curriculum?.map((mod) => (
            <div key={mod.id}>
              <p className="mb-2 text-[13px] font-semibold text-ink">{mod.title}</p>
              <ul className="flex flex-col gap-1">
                {mod.lessons.map((lesson) => {
                  const done = enrollment?.completedLessonIds.includes(lesson.id) ?? false;
                  const active = lesson.id === currentLesson.id;
                  return (
                    <li key={lesson.id}>
                      <button
                        type="button"
                        onClick={() => goToLesson(lesson.id)}
                        className={cn(
                          "flex w-full items-center gap-2 rounded-control px-2.5 py-2 text-left text-[13px]",
                          active ? "bg-gold-tint text-ink" : "text-ink-soft hover:bg-paper-dim"
                        )}
                      >
                        {done ? (
                          <CheckCircle2 size={15} className="shrink-0 text-teal" />
                        ) : (
                          <Circle size={15} className="shrink-0 text-line-strong" />
                        )}
                        <span className="truncate">{lesson.title}</span>
                      </button>
                    </li>
                  );
                })}
              </ul>
            </div>
          ))}
        </div>
      </aside>
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 5. Wishlist
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/(learner)/wishlist/page.tsx" @'
"use client";

import Link from "next/link";
import { X } from "lucide-react";
import { useCartStore, useWishlistStore } from "@saachi/store";
import { Button, EmptyState } from "@saachi/ui";

export default function WishlistPage() {
  const items = useWishlistStore((s) => s.items);
  const removeFromWishlist = useWishlistStore((s) => s.remove);
  const addToCart = useCartStore((s) => s.addItem);

  return (
    <div>
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Wishlist</h1>

      {items.length === 0 ? (
        <EmptyState
          title="Your wishlist is empty"
          description="Save courses you're interested in to find them here later."
          action={
            <Link href="/courses">
              <Button>Browse courses</Button>
            </Link>
          }
        />
      ) : (
        <div className="flex flex-col gap-3">
          {items.map((item) => (
            <div
              key={item.courseId}
              className="flex items-center gap-4 rounded-card border border-line bg-card p-4"
            >
              {item.thumbnailUrl && (
                // eslint-disable-next-line @next/next/no-img-element
                <img
                  src={item.thumbnailUrl}
                  alt={item.title}
                  className="h-16 w-28 shrink-0 rounded-control object-cover"
                />
              )}
              <div className="min-w-0 flex-1">
                <Link href={`/courses/${item.slug}`} className="truncate text-[15px] font-semibold text-ink hover:underline">
                  {item.title}
                </Link>
                <p className="text-[13px] text-ink-soft">{item.instructorName}</p>
              </div>
              <span className="font-mono text-[15px] font-semibold text-ink">
                {new Intl.NumberFormat("en-US", { style: "currency", currency: item.currency }).format(item.price)}
              </span>
              <Button
                size="sm"
                onClick={() =>
                  addToCart({
                    courseId: item.courseId,
                    slug: item.slug,
                    title: item.title,
                    thumbnailUrl: item.thumbnailUrl,
                    instructorName: item.instructorName,
                    price: item.price,
                    currency: item.currency
                  })
                }
              >
                Add to cart
              </Button>
              <button
                type="button"
                aria-label="Remove from wishlist"
                onClick={() => removeFromWishlist(item.courseId)}
                className="flex h-9 w-9 shrink-0 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim"
              >
                <X size={16} />
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 6. Cart
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/(learner)/cart/page.tsx" @'
"use client";

import Link from "next/link";
import { useState } from "react";
import { X } from "lucide-react";
import { useRouter } from "next/navigation";
import { useCartStore } from "@saachi/store";
import { Button, EmptyState, Input } from "@saachi/ui";

export default function CartPage() {
  const router = useRouter();
  const items = useCartStore((s) => s.items);
  const coupon = useCartStore((s) => s.coupon);
  const removeItem = useCartStore((s) => s.removeItem);
  const applyCoupon = useCartStore((s) => s.applyCoupon);
  const removeCoupon = useCartStore((s) => s.removeCoupon);
  const subtotal = useCartStore((s) => s.subtotal());
  const discount = useCartStore((s) => s.discount());
  const total = useCartStore((s) => s.total());

  const [couponCode, setCouponCode] = useState("");
  const [couponMessage, setCouponMessage] = useState<string | null>(null);

  function handleApplyCoupon() {
    const result = applyCoupon(couponCode);
    setCouponMessage(result.message);
  }

  const currency = items[0]?.currency ?? "USD";
  const fmt = (n: number) => new Intl.NumberFormat("en-US", { style: "currency", currency }).format(n);

  return (
    <div>
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Cart</h1>

      {items.length === 0 ? (
        <EmptyState
          title="Your cart is empty"
          description="Add a course to get started."
          action={
            <Link href="/courses">
              <Button>Browse courses</Button>
            </Link>
          }
        />
      ) : (
        <div className="grid grid-cols-1 gap-8 md:grid-cols-[1fr_320px]">
          <div className="flex flex-col gap-3">
            {items.map((item) => (
              <div key={item.courseId} className="flex items-center gap-4 rounded-card border border-line bg-card p-4">
                {item.thumbnailUrl && (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img
                    src={item.thumbnailUrl}
                    alt={item.title}
                    className="h-16 w-28 shrink-0 rounded-control object-cover"
                  />
                )}
                <div className="min-w-0 flex-1">
                  <Link href={`/courses/${item.slug}`} className="truncate text-[15px] font-semibold text-ink hover:underline">
                    {item.title}
                  </Link>
                  <p className="text-[13px] text-ink-soft">{item.instructorName}</p>
                </div>
                <span className="font-mono text-[15px] font-semibold text-ink">
                  {new Intl.NumberFormat("en-US", { style: "currency", currency: item.currency }).format(item.price)}
                </span>
                <button
                  type="button"
                  aria-label="Remove from cart"
                  onClick={() => removeItem(item.courseId)}
                  className="flex h-9 w-9 shrink-0 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim"
                >
                  <X size={16} />
                </button>
              </div>
            ))}
          </div>

          <aside className="h-fit rounded-card border border-line bg-card p-6">
            <h2 className="mb-4 text-[15px] font-semibold text-ink">Order summary</h2>

            {coupon ? (
              <div className="mb-4 flex items-center justify-between rounded-control bg-gold-tint px-3 py-2 text-[13px]">
                <span className="font-semibold text-gold-dark">{coupon.code} applied</span>
                <button type="button" onClick={removeCoupon} className="text-ink-soft hover:text-ink">
                  Remove
                </button>
              </div>
            ) : (
              <div className="mb-4 flex gap-2">
                <Input
                  placeholder="Coupon code"
                  value={couponCode}
                  onChange={(e) => setCouponCode(e.target.value)}
                  className="flex-1"
                />
                <Button variant="secondary" onClick={handleApplyCoupon}>
                  Apply
                </Button>
              </div>
            )}
            {couponMessage && <p className="mb-4 text-[12px] text-ink-soft">{couponMessage}</p>}

            <div className="flex flex-col gap-2 border-t border-line pt-4 text-[14px]">
              <div className="flex justify-between text-ink-soft">
                <span>Subtotal</span>
                <span>{fmt(subtotal)}</span>
              </div>
              {discount > 0 && (
                <div className="flex justify-between text-teal">
                  <span>Discount</span>
                  <span>-{fmt(discount)}</span>
                </div>
              )}
              <div className="mt-2 flex justify-between border-t border-line pt-2 text-[16px] font-semibold text-ink">
                <span>Total</span>
                <span>{fmt(total)}</span>
              </div>
            </div>

            <Button size="lg" className="mt-5 w-full" onClick={() => router.push("/checkout")}>
              Proceed to checkout
            </Button>
          </aside>
        </div>
      )}
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 7. Checkout
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/(learner)/checkout/page.tsx" @'
"use client";

import { useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { useCartStore, useEnrollmentStore, useOrderStore } from "@saachi/store";
import { Button, Input, Select } from "@saachi/ui";

const PAYMENT_METHODS = [
  { label: "Card (Stripe)", value: "stripe" },
  { label: "PayPal", value: "paypal" },
  { label: "Easypaisa", value: "easypaisa" },
  { label: "JazzCash", value: "jazzcash" }
];

export default function CheckoutPage() {
  const router = useRouter();
  const items = useCartStore((s) => s.items);
  const coupon = useCartStore((s) => s.coupon);
  const subtotal = useCartStore((s) => s.subtotal());
  const discount = useCartStore((s) => s.discount());
  const total = useCartStore((s) => s.total());
  const clearCart = useCartStore((s) => s.clear);
  const enroll = useEnrollmentStore((s) => s.enroll);
  const addOrder = useOrderStore((s) => s.addOrder);

  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [paymentMethod, setPaymentMethod] = useState("stripe");
  const [isProcessing, setIsProcessing] = useState(false);

  const currency = items[0]?.currency ?? "USD";
  const fmt = (n: number) => new Intl.NumberFormat("en-US", { style: "currency", currency }).format(n);

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (items.length === 0) return;
    setIsProcessing(true);

    // NOTE: demo-only checkout, no real payment gateway wired up yet.
    setTimeout(() => {
      const order = addOrder({
        items: items.map((i) => ({ courseId: i.courseId, title: i.title, price: i.price })),
        subtotal,
        discount,
        total,
        currency,
        paymentMethod
      });

      enroll(
        items.map((i) => ({
          courseId: i.courseId,
          slug: i.slug,
          title: i.title,
          thumbnailUrl: i.thumbnailUrl,
          instructorName: i.instructorName
        }))
      );

      clearCart();
      setIsProcessing(false);
      router.push(`/orders?success=${order.id}`);
    }, 800);
  }

  if (items.length === 0) {
    return (
      <div className="mx-auto max-w-md py-16 text-center">
        <p className="text-ink-soft">Your cart is empty. Add a course before checking out.</p>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 gap-8 md:grid-cols-[1fr_320px]">
      <div>
        <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Checkout</h1>
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <Input label="Full name" required value={fullName} onChange={(e) => setFullName(e.target.value)} />
          <Input
            label="Email"
            type="email"
            required
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
          <Select
            label="Payment method"
            options={PAYMENT_METHODS}
            value={paymentMethod}
            onChange={(e) => setPaymentMethod(e.target.value)}
          />
          <Button type="submit" size="lg" loading={isProcessing} className="mt-2">
            Pay {fmt(total)}
          </Button>
        </form>
      </div>

      <aside className="h-fit rounded-card border border-line bg-card p-6">
        <h2 className="mb-4 text-[15px] font-semibold text-ink">Order summary</h2>
        <div className="flex flex-col gap-3">
          {items.map((item) => (
            <div key={item.courseId} className="flex justify-between text-[13px]">
              <span className="text-ink-soft">{item.title}</span>
              <span className="font-medium text-ink">{fmt(item.price)}</span>
            </div>
          ))}
        </div>
        <div className="mt-4 flex flex-col gap-2 border-t border-line pt-4 text-[14px]">
          <div className="flex justify-between text-ink-soft">
            <span>Subtotal</span>
            <span>{fmt(subtotal)}</span>
          </div>
          {coupon && (
            <div className="flex justify-between text-teal">
              <span>Discount ({coupon.code})</span>
              <span>-{fmt(discount)}</span>
            </div>
          )}
          <div className="mt-2 flex justify-between border-t border-line pt-2 text-[16px] font-semibold text-ink">
            <span>Total</span>
            <span>{fmt(total)}</span>
          </div>
        </div>
      </aside>
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 8. Orders
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/(learner)/orders/page.tsx" @'
"use client";

import { useSearchParams } from "next/navigation";
import { CheckCircle2 } from "lucide-react";
import { useOrderStore } from "@saachi/store";
import { EmptyState } from "@saachi/ui";

export default function OrdersPage() {
  const orders = useOrderStore((s) => s.orders);
  const searchParams = useSearchParams();
  const successId = searchParams.get("success");

  return (
    <div>
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Order History</h1>

      {successId && (
        <div className="mb-6 flex items-center gap-3 rounded-card border border-teal/30 bg-teal-light px-4 py-3">
          <CheckCircle2 size={18} className="text-teal" />
          <p className="text-[14px] text-ink">
            Payment successful. Order <span className="font-semibold">{successId}</span> is confirmed - your
            courses are now available in My Courses.
          </p>
        </div>
      )}

      {orders.length === 0 ? (
        <EmptyState title="No orders yet" description="Your purchase history will show up here." />
      ) : (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          <table className="w-full text-left text-[13px]">
            <thead className="border-b border-line bg-paper-dim">
              <tr>
                <th className="px-4 py-3 font-semibold text-ink-soft">Order</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Items</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Total</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Status</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Date</th>
              </tr>
            </thead>
            <tbody>
              {orders.map((order) => (
                <tr key={order.id} className="border-b border-line last:border-0">
                  <td className="px-4 py-3.5 font-medium text-ink">{order.id}</td>
                  <td className="px-4 py-3.5 text-ink-soft">{order.items.map((i) => i.title).join(", ")}</td>
                  <td className="px-4 py-3.5 font-mono text-ink">
                    {new Intl.NumberFormat("en-US", { style: "currency", currency: order.currency }).format(order.total)}
                  </td>
                  <td className="px-4 py-3.5 capitalize text-ink-soft">{order.status}</td>
                  <td className="px-4 py-3.5 text-ink-soft">
                    {new Intl.DateTimeFormat("en-US", { dateStyle: "medium" }).format(new Date(order.createdAt))}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 9. Certificates
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/(learner)/certificates/page.tsx" @'
"use client";

import { Award, Download } from "lucide-react";
import { useEnrollmentStore } from "@saachi/store";
import { Button, EmptyState } from "@saachi/ui";

export default function CertificatesPage() {
  const enrollments = useEnrollmentStore((s) => s.enrollments);
  const completed = enrollments.filter((e) => e.progressPercent === 100);

  return (
    <div>
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Certificates</h1>

      {completed.length === 0 ? (
        <EmptyState
          title="No certificates yet"
          description="Complete a course to earn your first certificate."
        />
      ) : (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          {completed.map((e) => (
            <div key={e.courseId} className="flex items-center gap-4 rounded-card border border-line bg-card p-5">
              <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-full bg-gold-tint text-gold-dark">
                <Award size={22} />
              </div>
              <div className="min-w-0 flex-1">
                <h3 className="truncate text-[15px] font-semibold text-ink">{e.title}</h3>
                <p className="text-[13px] text-ink-soft">Completed - {e.instructorName}</p>
              </div>
              <Button size="sm" variant="secondary">
                <Download size={14} className="mr-1.5" />
                Download
              </Button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 10. Notifications
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/(learner)/notifications/page.tsx" @'
"use client";

import { Bell } from "lucide-react";
import { useNotificationStore } from "@saachi/store";
import { Button, EmptyState, cn } from "@saachi/ui";

export default function NotificationsPage() {
  const items = useNotificationStore((s) => s.items);
  const markRead = useNotificationStore((s) => s.markRead);
  const markAllRead = useNotificationStore((s) => s.markAllRead);

  return (
    <div>
      <div className="mb-6 flex items-center justify-between">
        <h1 className="font-display text-[26px] font-bold text-ink">Notifications</h1>
        <Button size="sm" variant="secondary" onClick={markAllRead}>
          Mark all as read
        </Button>
      </div>

      {items.length === 0 ? (
        <EmptyState title="No notifications" description="You're all caught up." />
      ) : (
        <div className="flex flex-col gap-2">
          {items.map((n) => (
            <button
              key={n.id}
              type="button"
              onClick={() => markRead(n.id)}
              className={cn(
                "flex items-start gap-3 rounded-card border border-line p-4 text-left transition-colors",
                n.read ? "bg-card" : "bg-gold-tint/40"
              )}
            >
              <div className="mt-0.5 flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-paper-dim text-ink-soft">
                <Bell size={14} />
              </div>
              <div className="min-w-0 flex-1">
                <p className="text-[14px] font-semibold text-ink">{n.title}</p>
                <p className="text-[13px] text-ink-soft">{n.body}</p>
                <p className="mt-1 text-[12px] text-ink-soft/60">
                  {new Intl.DateTimeFormat("en-US", { dateStyle: "medium", timeStyle: "short" }).format(
                    new Date(n.createdAt)
                  )}
                </p>
              </div>
              {!n.read && <span className="mt-1.5 h-2 w-2 shrink-0 rounded-full bg-gold-dark" />}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 11. Settings (profile overview - simple, single page for Phase 2)
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/(learner)/settings/page.tsx" @'
"use client";

import { useSession, useLogout } from "@saachi/api-client";
import { Button, Input, EmptyState } from "@saachi/ui";

export default function SettingsPage() {
  const { data: session } = useSession();
  const logout = useLogout();

  if (!session) {
    return <EmptyState title="Not logged in" description="Log in to view and edit your settings." />;
  }

  return (
    <div>
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Settings</h1>

      <div className="max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-4 text-[15px] font-semibold text-ink">Profile</h2>
        <div className="flex flex-col gap-4">
          <Input label="Full name" defaultValue={session.fullName} />
          <Input label="Email" defaultValue={session.email} type="email" />
          <Button className="self-start">Save changes</Button>
        </div>
      </div>

      <div className="mt-6 max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-2 text-[15px] font-semibold text-ink">Session</h2>
        <p className="mb-4 text-[13px] text-ink-soft">Logged in as {session.email}</p>
        <Button variant="danger" onClick={() => logout.mutate()}>
          Log out
        </Button>
      </div>
    </div>
  );
}
'@

Write-Host ""
Write-Host "== Done ==" -ForegroundColor Green
Write-Host "Pages created under apps/web/app/(learner)/:"
Write-Host "  layout.tsx (sidebar nav)"
Write-Host "  dashboard/page.tsx          -> /dashboard"
Write-Host "  my-courses/page.tsx         -> /my-courses"
Write-Host "  learn/[courseId]/[lessonId]/page.tsx -> /learn/[courseId]/[lessonId]"
Write-Host "  certificates/page.tsx       -> /certificates"
Write-Host "  wishlist/page.tsx           -> /wishlist"
Write-Host "  cart/page.tsx               -> /cart"
Write-Host "  checkout/page.tsx           -> /checkout"
Write-Host "  orders/page.tsx             -> /orders"
Write-Host "  notifications/page.tsx      -> /notifications"
Write-Host "  settings/page.tsx           -> /settings"
Write-Host ""
Write-Host "apps/admin was NOT touched."
Write-Host ""
Write-Host "Now run: pnpm --filter web dev"