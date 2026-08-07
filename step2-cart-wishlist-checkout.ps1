# step2-cart-wishlist-checkout.ps1
# Run from: SAI2 root folder (only touches apps/web + packages, admin untouched)

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

Write-Host "Step 2: cart + wishlist (Zustand) + checkout flow + course detail rebuild..." -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 0. packages/store - new shared Zustand package
# ---------------------------------------------------------------------------
$storePackageJson = @'
{
  "name": "@saachi/store",
  "version": "0.1.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "dependencies": {
    "zustand": "^4.5.0"
  },
  "devDependencies": {
    "typescript": "^5.5.0"
  }
}
'@
Write-Utf8NoBom -Path "packages\store\package.json" -Content $storePackageJson

$storeTsconfig = @'
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["dom", "ES2020"],
    "module": "esnext",
    "moduleResolution": "bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "declaration": true,
    "jsx": "react-jsx"
  },
  "include": ["src"]
}
'@
Write-Utf8NoBom -Path "packages\store\tsconfig.json" -Content $storeTsconfig

# ---------------------------------------------------------------------------
# 1. useCartStore.ts
# ---------------------------------------------------------------------------
$cartStore = @'
import { create } from "zustand";
import { persist } from "zustand/middleware";

export type CartItem = {
  courseId: string;
  slug: string;
  title: string;
  thumbnailUrl?: string;
  instructorName: string;
  price: number;
  currency: string;
};

export type CouponState = {
  code: string;
  percentOff: number;
} | null;

// NOTE: demo-only coupon codes, validated client-side. Replace with a real
// Coupons API call once the backend (Doc 3) is available.
const KNOWN_COUPONS: Record<string, number> = {
  SAACHI10: 10,
  SAACHI25: 25
};

type CartState = {
  items: CartItem[];
  coupon: CouponState;
  addItem: (item: CartItem) => void;
  removeItem: (courseId: string) => void;
  clear: () => void;
  applyCoupon: (code: string) => { success: boolean; message: string };
  removeCoupon: () => void;
  isInCart: (courseId: string) => boolean;
  subtotal: () => number;
  discount: () => number;
  total: () => number;
};

export const useCartStore = create<CartState>()(
  persist(
    (set, get) => ({
      items: [],
      coupon: null,

      addItem: (item) => {
        const exists = get().items.some((i) => i.courseId === item.courseId);
        if (exists) return;
        set({ items: [...get().items, item] });
      },

      removeItem: (courseId) => {
        set({ items: get().items.filter((i) => i.courseId !== courseId) });
      },

      clear: () => set({ items: [], coupon: null }),

      applyCoupon: (code) => {
        const normalized = code.trim().toUpperCase();
        const percentOff = KNOWN_COUPONS[normalized];
        if (!percentOff) {
          return { success: false, message: "That coupon code isn't valid." };
        }
        set({ coupon: { code: normalized, percentOff } });
        return { success: true, message: `${percentOff}% discount applied.` };
      },

      removeCoupon: () => set({ coupon: null }),

      isInCart: (courseId) => get().items.some((i) => i.courseId === courseId),

      subtotal: () => get().items.reduce((sum, i) => sum + i.price, 0),

      discount: () => {
        const coupon = get().coupon;
        if (!coupon) return 0;
        return Math.round(get().subtotal() * (coupon.percentOff / 100) * 100) / 100;
      },

      total: () => Math.max(0, get().subtotal() - get().discount())
    }),
    { name: "saachi-cart" }
  )
);
'@
Write-Utf8NoBom -Path "packages\store\src\useCartStore.ts" -Content $cartStore

# ---------------------------------------------------------------------------
# 2. useWishlistStore.ts
# ---------------------------------------------------------------------------
$wishlistStore = @'
import { create } from "zustand";
import { persist } from "zustand/middleware";

export type WishlistItem = {
  courseId: string;
  slug: string;
  title: string;
  thumbnailUrl?: string;
  instructorName: string;
  price: number;
  currency: string;
  rating: number;
  ratingCount: number;
};

type WishlistState = {
  items: WishlistItem[];
  toggle: (item: WishlistItem) => void;
  remove: (courseId: string) => void;
  isWishlisted: (courseId: string) => boolean;
};

export const useWishlistStore = create<WishlistState>()(
  persist(
    (set, get) => ({
      items: [],

      toggle: (item) => {
        const exists = get().items.some((i) => i.courseId === item.courseId);
        if (exists) {
          set({ items: get().items.filter((i) => i.courseId !== item.courseId) });
        } else {
          set({ items: [...get().items, item] });
        }
      },

      remove: (courseId) => {
        set({ items: get().items.filter((i) => i.courseId !== courseId) });
      },

      isWishlisted: (courseId) => get().items.some((i) => i.courseId === courseId)
    }),
    { name: "saachi-wishlist" }
  )
);
'@
Write-Utf8NoBom -Path "packages\store\src\useWishlistStore.ts" -Content $wishlistStore

# ---------------------------------------------------------------------------
# 3. useEnrollmentStore.ts (tracks "purchased" courses after mock checkout)
# ---------------------------------------------------------------------------
$enrollmentStore = @'
import { create } from "zustand";
import { persist } from "zustand/middleware";

export type EnrollmentRecord = {
  courseId: string;
  slug: string;
  title: string;
  thumbnailUrl?: string;
  instructorName: string;
  progressPercent: number;
  purchasedAt: string;
};

type EnrollmentState = {
  enrollments: EnrollmentRecord[];
  isEnrolled: (courseId: string) => boolean;
  enroll: (records: Omit<EnrollmentRecord, "progressPercent" | "purchasedAt">[]) => void;
};

export const useEnrollmentStore = create<EnrollmentState>()(
  persist(
    (set, get) => ({
      enrollments: [],

      isEnrolled: (courseId) => get().enrollments.some((e) => e.courseId === courseId),

      enroll: (records) => {
        const now = new Date().toISOString();
        const existingIds = new Set(get().enrollments.map((e) => e.courseId));
        const fresh = records
          .filter((r) => !existingIds.has(r.courseId))
          .map((r) => ({ ...r, progressPercent: 0, purchasedAt: now }));
        if (fresh.length === 0) return;
        set({ enrollments: [...get().enrollments, ...fresh] });
      }
    }),
    { name: "saachi-enrollments" }
  )
);
'@
Write-Utf8NoBom -Path "packages\store\src\useEnrollmentStore.ts" -Content $enrollmentStore

$storeIndex = @'
export * from "./useCartStore";
export * from "./useWishlistStore";
export * from "./useEnrollmentStore";
'@
Write-Utf8NoBom -Path "packages\store\src\index.ts" -Content $storeIndex

# ---------------------------------------------------------------------------
# 4. Wire @saachi/store into apps/web package.json + tsconfig paths
# ---------------------------------------------------------------------------
Patch-File -Path "apps\web\package.json" `
  -OldStr '"zustand": "^4.5.0",' `
  -NewStr @'
"zustand": "^4.5.0",
    "@saachi/store": "workspace:*",
'@ `
  -Label "add @saachi/store dependency"

Patch-File -Path "apps\web\tsconfig.json" `
  -OldStr '"@saachi/utils": ["../../packages/utils/src"],
      "@saachi/utils/*": ["../../packages/utils/src/*"]' `
  -NewStr @'
"@saachi/utils": ["../../packages/utils/src"],
      "@saachi/utils/*": ["../../packages/utils/src/*"],
      "@saachi/store": ["../../packages/store/src"],
      "@saachi/store/*": ["../../packages/store/src/*"]
'@ `
  -Label "add @saachi/store path"

Patch-File -Path "apps\web\next.config.js" `
  -OldStr 'transpilePackages: ["@saachi/ui", "@saachi/api-client", "@saachi/utils"],' `
  -NewStr 'transpilePackages: ["@saachi/ui", "@saachi/api-client", "@saachi/utils", "@saachi/store"],' `
  -Label "transpile @saachi/store"

# ---------------------------------------------------------------------------
# 5. Course detail page - rebuilt with cart + wishlist wired in
# ---------------------------------------------------------------------------
$courseDetailPage = @'
"use client";

import { useState } from "react";
import Link from "next/link";
import { Star, Clock, PlayCircle, CheckCircle2, Globe, BarChart3, Heart, ShoppingCart } from "lucide-react";
import { useCourseDetail } from "@saachi/api-client";
import {
  Button,
  Card,
  Badge,
  Accordion,
  ReviewCard,
  CourseCard,
  SkeletonText,
  EmptyState
} from "@saachi/ui";
import { formatDuration } from "@saachi/utils";
import { useCartStore, useWishlistStore } from "@saachi/store";
import { Navbar } from "../../_components/Navbar";
import { Footer } from "../../_components/Footer";

export default function CourseDetailPage({ params }: { params: { slug: string } }) {
  const { data: course, isLoading, isError } = useCourseDetail(params.slug);
  const [justAdded, setJustAdded] = useState(false);

  const cart = useCartStore();
  const wishlist = useWishlistStore();

  if (isLoading) {
    return (
      <>
        <Navbar />
        <main className="mx-auto max-w-[1140px] px-6 py-16">
          <SkeletonText lines={4} />
        </main>
        <Footer />
      </>
    );
  }

  if (isError || !course) {
    return (
      <>
        <Navbar />
        <main className="mx-auto max-w-[1140px] px-6 py-16">
          <EmptyState
            title="Course not found"
            description="This course may have been moved or is no longer available."
            action={
              <Link href="/courses">
                <Button>Browse courses</Button>
              </Link>
            }
          />
        </main>
        <Footer />
      </>
    );
  }

  const formattedPrice = new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: course.currency,
    minimumFractionDigits: course.price % 1 === 0 ? 0 : 2
  }).format(course.price);

  const inCart = cart.isInCart(course.id);
  const wishlisted = wishlist.isWishlisted(course.id);

  const handleAddToCart = () => {
    cart.addItem({
      courseId: course.id,
      slug: course.slug,
      title: course.title,
      thumbnailUrl: course.thumbnailUrl,
      instructorName: course.instructor.fullName,
      price: course.price,
      currency: course.currency
    });
    setJustAdded(true);
  };

  const handleToggleWishlist = () => {
    wishlist.toggle({
      courseId: course.id,
      slug: course.slug,
      title: course.title,
      thumbnailUrl: course.thumbnailUrl,
      instructorName: course.instructor.fullName,
      price: course.price,
      currency: course.currency,
      rating: course.rating,
      ratingCount: course.ratingCount
    });
  };

  const curriculumItems = (course.curriculum ?? []).map((mod) => ({
    id: mod.id,
    title: mod.title,
    meta: <span className="text-[12px] text-ink-soft/60">{mod.lessons.length} lessons</span>,
    content: (
      <ul className="flex flex-col gap-2">
        {mod.lessons.map((lesson) => (
          <li key={lesson.id} className="flex items-center justify-between text-[14px] text-ink">
            <span className="flex items-center gap-2">
              <PlayCircle size={15} className="text-ink-soft" />
              {lesson.title}
              {lesson.isPreview && <Badge variant="gold">Preview</Badge>}
            </span>
            {lesson.durationSeconds && (
              <span className="text-[12px] text-ink-soft/60">{formatDuration(lesson.durationSeconds)}</span>
            )}
          </li>
        ))}
      </ul>
    )
  }));

  const faqItems = (course.faq ?? []).map((item) => ({
    id: item.id,
    title: item.question,
    content: item.answer
  }));

  return (
    <>
      <Navbar />
      <main className="mx-auto max-w-[1140px] px-6 py-12">
        <div className="grid grid-cols-1 gap-10 lg:grid-cols-[1fr_360px]">
          <div>
            <div className="mb-3 flex flex-wrap items-center gap-2">
              <Badge variant="gold">{course.status === "published" ? "Published" : course.status}</Badge>
              <span className="flex items-center gap-1 text-[13px] text-ink-soft">
                <Star size={14} className="fill-gold text-gold" />
                <strong className="text-ink">{course.rating.toFixed(1)}</strong>
                ({course.ratingCount.toLocaleString()} ratings)
              </span>
            </div>

            <h1 className="font-display text-[32px] font-semibold leading-tight text-ink md:text-[40px]">
              {course.title}
            </h1>
            {course.subtitle && (
              <p className="mt-3 text-[16px] leading-relaxed text-ink-soft">{course.subtitle}</p>
            )}

            <div className="mt-6 flex items-center gap-3">
              <div className="flex h-10 w-10 items-center justify-center overflow-hidden rounded-full bg-teal-light text-[14px] font-semibold text-teal">
                {course.instructor.avatarUrl ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={course.instructor.avatarUrl} alt={course.instructor.fullName} className="h-full w-full object-cover" />
                ) : (
                  course.instructor.fullName.charAt(0)
                )}
              </div>
              <div>
                <div className="text-[14px] font-semibold text-ink">{course.instructor.fullName}</div>
                <div className="text-[12px] text-ink-soft">
                  {course.instructorCourseCount ?? 1} courses &middot;{" "}
                  {(course.instructorStudentCount ?? 0).toLocaleString()} students
                </div>
              </div>
            </div>

            {course.description && (
              <div className="mt-8">
                <h2 className="mb-3 font-display text-[20px] font-semibold text-ink">About this course</h2>
                <p className="whitespace-pre-line text-[15px] leading-relaxed text-ink-soft">
                  {course.description}
                </p>
              </div>
            )}

            {curriculumItems.length > 0 && (
              <div className="mt-10">
                <h2 className="mb-3 font-display text-[20px] font-semibold text-ink">Curriculum</h2>
                <Accordion items={curriculumItems} defaultOpenId={curriculumItems[0]?.id} />
              </div>
            )}

            {course.reviews && course.reviews.length > 0 && (
              <div className="mt-10">
                <h2 className="mb-4 font-display text-[20px] font-semibold text-ink">Reviews</h2>
                <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                  {course.reviews.map((review) => (
                    <ReviewCard key={review.id} {...review} />
                  ))}
                </div>
              </div>
            )}

            {faqItems.length > 0 && (
              <div className="mt-10">
                <h2 className="mb-3 font-display text-[20px] font-semibold text-ink">FAQ</h2>
                <Accordion items={faqItems} />
              </div>
            )}

            {course.relatedCourses && course.relatedCourses.length > 0 && (
              <div className="mt-10">
                <h2 className="mb-4 font-display text-[20px] font-semibold text-ink">Related courses</h2>
                <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
                  {course.relatedCourses.map((related) => (
                    <CourseCard
                      key={related.id}
                      slug={related.slug}
                      title={related.title}
                      thumbnailUrl={related.thumbnailUrl}
                      instructorName={related.instructor.fullName}
                      price={related.price}
                      currency={related.currency}
                      rating={related.rating}
                      ratingCount={related.ratingCount}
                    />
                  ))}
                </div>
              </div>
            )}
          </div>

          <div className="lg:sticky lg:top-24 lg:self-start">
            <Card className="p-6">
              <div className="mb-4 aspect-video w-full overflow-hidden rounded-control bg-paper-dim">
                {course.thumbnailUrl ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={course.thumbnailUrl} alt={course.title} className="h-full w-full object-cover" />
                ) : (
                  <div className="flex h-full w-full items-center justify-center text-[13px] text-ink-soft/60">
                    No preview
                  </div>
                )}
              </div>

              <div className="mb-5 flex items-center justify-between">
                <span className="font-mono text-[28px] font-semibold text-ink">{formattedPrice}</span>
                <button
                  type="button"
                  onClick={handleToggleWishlist}
                  aria-label="Toggle wishlist"
                  className="flex h-10 w-10 items-center justify-center rounded-full border border-line-strong text-ink-soft transition-colors duration-150 ease-out hover:border-error hover:text-error"
                >
                  <Heart size={18} className={wishlisted ? "fill-error text-error" : ""} />
                </button>
              </div>

              {inCart || justAdded ? (
                <div className="flex flex-col gap-2">
                  <div className="flex items-center gap-2 rounded-control bg-teal-light px-4 py-3 text-[14px] font-semibold text-teal">
                    <CheckCircle2 size={18} /> In your cart
                  </div>
                  <Link href="/cart">
                    <Button size="lg" variant="secondary" className="w-full">
                      <ShoppingCart size={17} /> Go to cart
                    </Button>
                  </Link>
                </div>
              ) : (
                <Button size="lg" className="w-full" onClick={handleAddToCart}>
                  <ShoppingCart size={17} /> Add to cart
                </Button>
              )}

              <ul className="mt-6 flex flex-col gap-3 text-[13px] text-ink-soft">
                <li className="flex items-center gap-2">
                  <Globe size={15} /> Language: English
                </li>
                <li className="flex items-center gap-2">
                  <BarChart3 size={15} /> Level: All levels
                </li>
                <li className="flex items-center gap-2">
                  <Clock size={15} /> Lifetime access
                </li>
              </ul>
            </Card>
          </div>
        </div>
      </main>
      <Footer />
    </>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(marketing)\courses\[slug]\page.tsx" -Content $courseDetailPage

# ---------------------------------------------------------------------------
# 6. Wishlist page
# ---------------------------------------------------------------------------
$wishlistPage = @'
"use client";

import Link from "next/link";
import { Heart } from "lucide-react";
import { useWishlistStore, useCartStore } from "@saachi/store";
import { Button, Card, EmptyState, CourseCard } from "@saachi/ui";

export default function WishlistPage() {
  const wishlist = useWishlistStore();
  const cart = useCartStore();

  const moveToCart = (item: (typeof wishlist.items)[number]) => {
    cart.addItem({
      courseId: item.courseId,
      slug: item.slug,
      title: item.title,
      thumbnailUrl: item.thumbnailUrl,
      instructorName: item.instructorName,
      price: item.price,
      currency: item.currency
    });
    wishlist.remove(item.courseId);
  };

  return (
    <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
      <div className="mb-8">
        <h1 className="font-display text-[26px] font-semibold text-ink">Wishlist</h1>
        <p className="mt-1 text-[14px] text-ink-soft">Courses you've saved for later.</p>
      </div>

      {wishlist.items.length === 0 ? (
        <EmptyState
          icon={<Heart size={22} />}
          title="Your wishlist is empty"
          description="Save courses you're interested in and come back to them anytime."
          action={
            <Link href="/courses">
              <Button>Browse courses</Button>
            </Link>
          }
        />
      ) : (
        <div className="flex flex-col gap-4">
          {wishlist.items.map((item) => (
            <Card key={item.courseId} className="flex flex-col gap-4 p-4 sm:flex-row sm:items-center">
              <Link href={`/courses/${item.slug}`} className="block h-[90px] w-[160px] shrink-0 overflow-hidden rounded-control bg-paper-dim">
                {item.thumbnailUrl && (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={item.thumbnailUrl} alt={item.title} className="h-full w-full object-cover" />
                )}
              </Link>
              <div className="flex-1">
                <Link href={`/courses/${item.slug}`} className="text-[15px] font-semibold text-ink hover:text-gold-dark">
                  {item.title}
                </Link>
                <p className="mt-1 text-[13px] text-ink-soft">{item.instructorName}</p>
                <p className="mt-1 font-mono text-[15px] font-semibold text-ink">
                  {new Intl.NumberFormat("en-US", { style: "currency", currency: item.currency }).format(item.price)}
                </p>
              </div>
              <div className="flex shrink-0 gap-2">
                <Button size="sm" onClick={() => moveToCart(item)}>
                  Add to cart
                </Button>
                <Button size="sm" variant="ghost" onClick={() => wishlist.remove(item.courseId)}>
                  Remove
                </Button>
              </div>
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(learner)\wishlist\page.tsx" -Content $wishlistPage

# ---------------------------------------------------------------------------
# 7. Cart page
# ---------------------------------------------------------------------------
$cartPage = @'
"use client";

import { useState } from "react";
import Link from "next/link";
import { ShoppingCart, X, Tag } from "lucide-react";
import { useRouter } from "next/navigation";
import { useCartStore } from "@saachi/store";
import { Button, Card, Input, EmptyState } from "@saachi/ui";
import { formatCurrency } from "@saachi/utils";

export default function CartPage() {
  const router = useRouter();
  const cart = useCartStore();
  const [couponInput, setCouponInput] = useState("");
  const [couponMessage, setCouponMessage] = useState<{ text: string; ok: boolean } | null>(null);

  const currency = cart.items[0]?.currency ?? "USD";

  const handleApplyCoupon = () => {
    if (!couponInput.trim()) return;
    const result = cart.applyCoupon(couponInput);
    setCouponMessage({ text: result.message, ok: result.success });
  };

  if (cart.items.length === 0) {
    return (
      <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
        <h1 className="mb-8 font-display text-[26px] font-semibold text-ink">Your cart</h1>
        <EmptyState
          icon={<ShoppingCart size={22} />}
          title="Your cart is empty"
          description="Browse the marketplace and add a course to get started."
          action={
            <Link href="/courses">
              <Button>Browse courses</Button>
            </Link>
          }
        />
      </main>
    );
  }

  return (
    <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
      <h1 className="mb-8 font-display text-[26px] font-semibold text-ink">
        Your cart <span className="text-ink-soft">({cart.items.length})</span>
      </h1>

      <div className="grid grid-cols-1 gap-8 lg:grid-cols-[1fr_320px]">
        <div className="flex flex-col gap-4">
          {cart.items.map((item) => (
            <Card key={item.courseId} className="flex flex-col gap-4 p-4 sm:flex-row sm:items-center">
              <Link href={`/courses/${item.slug}`} className="block h-[90px] w-[160px] shrink-0 overflow-hidden rounded-control bg-paper-dim">
                {item.thumbnailUrl && (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={item.thumbnailUrl} alt={item.title} className="h-full w-full object-cover" />
                )}
              </Link>
              <div className="flex-1">
                <Link href={`/courses/${item.slug}`} className="text-[15px] font-semibold text-ink hover:text-gold-dark">
                  {item.title}
                </Link>
                <p className="mt-1 text-[13px] text-ink-soft">{item.instructorName}</p>
              </div>
              <div className="flex shrink-0 items-center gap-4">
                <span className="font-mono text-[16px] font-semibold text-ink">
                  {formatCurrency(item.price, item.currency)}
                </span>
                <button
                  type="button"
                  onClick={() => cart.removeItem(item.courseId)}
                  aria-label="Remove from cart"
                  className="flex h-8 w-8 items-center justify-center rounded-full text-ink-soft transition-colors hover:bg-paper-dim hover:text-error"
                >
                  <X size={16} />
                </button>
              </div>
            </Card>
          ))}
        </div>

        <div className="lg:sticky lg:top-6 lg:self-start">
          <Card className="p-6">
            <h2 className="mb-4 text-[16px] font-semibold text-ink">Order summary</h2>

            <div className="mb-4 flex flex-col gap-2">
              <div className="flex items-center gap-2">
                <Tag size={15} className="text-ink-soft" />
                <Input
                  placeholder="Coupon code"
                  value={couponInput}
                  onChange={(e) => setCouponInput(e.target.value)}
                  className="h-10"
                />
                <Button size="sm" variant="secondary" onClick={handleApplyCoupon}>
                  Apply
                </Button>
              </div>
              {couponMessage && (
                <p className={couponMessage.ok ? "text-[12px] text-teal" : "text-[12px] text-error"}>
                  {couponMessage.text}
                </p>
              )}
              {cart.coupon && (
                <div className="flex items-center justify-between text-[13px] text-ink-soft">
                  <span>Applied: {cart.coupon.code}</span>
                  <button type="button" onClick={() => cart.removeCoupon()} className="text-error hover:underline">
                    Remove
                  </button>
                </div>
              )}
            </div>

            <div className="flex flex-col gap-2 border-t border-line pt-4 text-[14px]">
              <div className="flex justify-between text-ink-soft">
                <span>Subtotal</span>
                <span>{formatCurrency(cart.subtotal(), currency)}</span>
              </div>
              {cart.coupon && (
                <div className="flex justify-between text-teal">
                  <span>Discount ({cart.coupon.percentOff}%)</span>
                  <span>-{formatCurrency(cart.discount(), currency)}</span>
                </div>
              )}
              <div className="flex justify-between border-t border-line pt-2 text-[16px] font-semibold text-ink">
                <span>Total</span>
                <span>{formatCurrency(cart.total(), currency)}</span>
              </div>
            </div>

            <Button size="lg" className="mt-6 w-full" onClick={() => router.push("/checkout")}>
              Proceed to checkout
            </Button>
          </Card>
        </div>
      </div>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(learner)\cart\page.tsx" -Content $cartPage

# ---------------------------------------------------------------------------
# 8. Checkout page
# ---------------------------------------------------------------------------
$checkoutPage = @'
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { CreditCard, Wallet, Building2, ShieldCheck } from "lucide-react";
import { useCartStore, useEnrollmentStore } from "@saachi/store";
import { useSession } from "@saachi/api-client";
import { Button, Card, Input, EmptyState } from "@saachi/ui";
import { formatCurrency } from "@saachi/utils";

const PAYMENT_METHODS = [
  { id: "card", label: "Credit / Debit Card", icon: CreditCard },
  { id: "easypaisa", label: "Easypaisa", icon: Wallet },
  { id: "bank_transfer", label: "Bank Transfer", icon: Building2 }
] as const;

export default function CheckoutPage() {
  const router = useRouter();
  const cart = useCartStore();
  const enrollment = useEnrollmentStore();
  const { data: session } = useSession();

  const [method, setMethod] = useState<(typeof PAYMENT_METHODS)[number]["id"]>("card");
  const [isPaying, setIsPaying] = useState(false);
  const [billingName, setBillingName] = useState(session?.fullName ?? "");
  const [billingEmail, setBillingEmail] = useState(session?.email ?? "");

  const currency = cart.items[0]?.currency ?? "USD";

  if (cart.items.length === 0) {
    return (
      <main className="mx-auto max-w-[720px] px-6 py-10 md:px-10">
        <EmptyState
          title="Nothing to check out"
          description="Your cart is empty. Add a course before starting checkout."
          action={
            <Link href="/courses">
              <Button>Browse courses</Button>
            </Link>
          }
        />
      </main>
    );
  }

  const handlePay = async () => {
    setIsPaying(true);
    // NOTE: demo-only. Replace with real Payments/Orders API call (Doc 3)
    // once the backend is available.
    await new Promise((resolve) => setTimeout(resolve, 1200));

    enrollment.enroll(
      cart.items.map((item) => ({
        courseId: item.courseId,
        slug: item.slug,
        title: item.title,
        thumbnailUrl: item.thumbnailUrl,
        instructorName: item.instructorName
      }))
    );

    cart.clear();
    setIsPaying(false);
    router.push("/checkout/confirmation");
  };

  return (
    <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
      <h1 className="mb-8 font-display text-[26px] font-semibold text-ink">Checkout</h1>

      <div className="grid grid-cols-1 gap-8 lg:grid-cols-[1fr_360px]">
        <div className="flex flex-col gap-8">
          <Card className="p-6">
            <h2 className="mb-4 text-[16px] font-semibold text-ink">Billing details</h2>
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
              <Input label="Full name" value={billingName} onChange={(e) => setBillingName(e.target.value)} />
              <Input
                label="Email"
                type="email"
                value={billingEmail}
                onChange={(e) => setBillingEmail(e.target.value)}
              />
            </div>
          </Card>

          <Card className="p-6">
            <h2 className="mb-4 text-[16px] font-semibold text-ink">Payment method</h2>
            <div className="flex flex-col gap-3">
              {PAYMENT_METHODS.map((pm) => (
                <button
                  key={pm.id}
                  type="button"
                  onClick={() => setMethod(pm.id)}
                  className={[
                    "flex items-center gap-3 rounded-control border px-4 py-3.5 text-left text-[14px] font-medium transition-colors duration-150 ease-out",
                    method === pm.id
                      ? "border-gold bg-gold-tint text-ink"
                      : "border-line-strong text-ink-soft hover:border-ink"
                  ].join(" ")}
                >
                  <pm.icon size={18} />
                  {pm.label}
                </button>
              ))}
            </div>
            <p className="mt-4 flex items-center gap-2 text-[12px] text-ink-soft">
              <ShieldCheck size={14} /> This is a demo checkout - no real payment is processed.
            </p>
          </Card>
        </div>

        <div className="lg:sticky lg:top-6 lg:self-start">
          <Card className="p-6">
            <h2 className="mb-4 text-[16px] font-semibold text-ink">Order summary</h2>
            <div className="flex flex-col gap-3 border-b border-line pb-4">
              {cart.items.map((item) => (
                <div key={item.courseId} className="flex justify-between text-[13px] text-ink-soft">
                  <span className="line-clamp-1 pr-2">{item.title}</span>
                  <span className="shrink-0 text-ink">{formatCurrency(item.price, item.currency)}</span>
                </div>
              ))}
            </div>
            <div className="flex flex-col gap-2 py-4 text-[14px]">
              <div className="flex justify-between text-ink-soft">
                <span>Subtotal</span>
                <span>{formatCurrency(cart.subtotal(), currency)}</span>
              </div>
              {cart.coupon && (
                <div className="flex justify-between text-teal">
                  <span>Discount</span>
                  <span>-{formatCurrency(cart.discount(), currency)}</span>
                </div>
              )}
              <div className="flex justify-between border-t border-line pt-2 text-[16px] font-semibold text-ink">
                <span>Total</span>
                <span>{formatCurrency(cart.total(), currency)}</span>
              </div>
            </div>
            <Button size="lg" className="w-full" onClick={handlePay} disabled={isPaying}>
              {isPaying ? "Processing..." : `Pay ${formatCurrency(cart.total(), currency)}`}
            </Button>
          </Card>
        </div>
      </div>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(learner)\checkout\page.tsx" -Content $checkoutPage

# ---------------------------------------------------------------------------
# 9. Order confirmation page
# ---------------------------------------------------------------------------
$confirmationPage = @'
"use client";

import Link from "next/link";
import { CheckCircle2 } from "lucide-react";
import { Button, Card } from "@saachi/ui";

export default function OrderConfirmationPage() {
  return (
    <main className="mx-auto flex max-w-[640px] flex-col items-center px-6 py-16 text-center md:px-10">
      <div className="mb-6 flex h-16 w-16 items-center justify-center rounded-full bg-teal-light text-teal">
        <CheckCircle2 size={32} />
      </div>
      <h1 className="font-display text-[26px] font-semibold text-ink">Payment successful</h1>
      <p className="mt-2 text-[14px] text-ink-soft">
        You're enrolled. Your course is now available under My Courses.
      </p>

      <Card className="mt-8 w-full p-6 text-left">
        <p className="text-[13px] text-ink-soft">
          This is demo data - no real order or invoice was generated. Once the backend is
          connected, this page will show the real order ID and invoice download link.
        </p>
      </Card>

      <div className="mt-8 flex flex-col gap-3 sm:flex-row">
        <Link href="/my-courses">
          <Button size="lg">Go to My Courses</Button>
        </Link>
        <Link href="/courses">
          <Button size="lg" variant="secondary">
            Browse more courses
          </Button>
        </Link>
      </div>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(learner)\checkout\confirmation\page.tsx" -Content $confirmationPage

# ---------------------------------------------------------------------------
# 10. My Courses page
# ---------------------------------------------------------------------------
$myCoursesPage = @'
"use client";

import Link from "next/link";
import { BookOpen } from "lucide-react";
import { useEnrollmentStore } from "@saachi/store";
import { Button, Card, EmptyState } from "@saachi/ui";

export default function MyCoursesPage() {
  const { enrollments } = useEnrollmentStore();

  return (
    <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
      <div className="mb-8">
        <h1 className="font-display text-[26px] font-semibold text-ink">My Courses</h1>
        <p className="mt-1 text-[14px] text-ink-soft">Everything you're enrolled in, in one place.</p>
      </div>

      {enrollments.length === 0 ? (
        <EmptyState
          icon={<BookOpen size={22} />}
          title="No courses yet"
          description="Once you purchase a course, it will show up here with your progress."
          action={
            <Link href="/courses">
              <Button>Browse courses</Button>
            </Link>
          }
        />
      ) : (
        <div className="flex flex-col gap-4">
          {enrollments.map((course) => (
            <Card key={course.courseId} className="flex flex-col gap-4 p-4 sm:flex-row sm:items-center">
              <Link href={`/courses/${course.slug}`} className="block h-[90px] w-[160px] shrink-0 overflow-hidden rounded-control bg-paper-dim">
                {course.thumbnailUrl && (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={course.thumbnailUrl} alt={course.title} className="h-full w-full object-cover" />
                )}
              </Link>
              <div className="flex-1">
                <Link href={`/courses/${course.slug}`} className="text-[15px] font-semibold text-ink hover:text-gold-dark">
                  {course.title}
                </Link>
                <p className="mt-1 text-[13px] text-ink-soft">{course.instructorName}</p>
                <div className="mt-3 flex items-center gap-3">
                  <div className="h-2 w-full max-w-[220px] overflow-hidden rounded-full bg-paper-dim">
                    <div
                      className="h-full rounded-full bg-gold"
                      style={{ width: `${course.progressPercent}%` }}
                    />
                  </div>
                  <span className="shrink-0 text-[12px] text-ink-soft">{course.progressPercent}% complete</span>
                </div>
              </div>
              <Button size="sm" variant="secondary" className="shrink-0">
                {course.progressPercent === 0 ? "Start course" : "Continue"}
              </Button>
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(learner)\my-courses\page.tsx" -Content $myCoursesPage

Write-Host ""
Write-Host "Step 2 done." -ForegroundColor Green
Write-Host "Run: pnpm install (new @saachi/store package needs linking), then pnpm dev:web" -ForegroundColor Green
Write-Host "Test flow: /courses -> open a course -> Add to cart -> /cart -> Proceed to checkout -> Pay -> /checkout/confirmation -> /my-courses" -ForegroundColor Green