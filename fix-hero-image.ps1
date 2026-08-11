# ============================================================================
# fix-hero-image.ps1
# Fixes: hero image 404 (bad Unsplash photo ID) + missing 'sizes' prop warnings
# Run this from the SAI2 repo root:
#   PS D:\...\SAI2> .\fix-hero-image.ps1
# ============================================================================
$ErrorActionPreference = 'Stop'

function Write-CodeFile($Path, $Content) {
    $dir = Split-Path $Path -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Set-Content -Path $Path -Value $Content -Encoding UTF8 -NoNewline
    Write-Host "Updated: $Path"
}

# ---- apps/web/components/marketing/HeroSection.tsx ----
$content = @'
import Link from "next/link";
import { Sparkles } from "lucide-react";
import Image from "next/image";

export function HeroSection() {
  return (
    <section className="w-full border-b border-[#CBD5E1] bg-[#FFFFFF]">
      <div className="mx-auto flex min-h-[640px] max-w-[1280px] items-center justify-center gap-10 px-6 py-12">
        {/* Left: copy */}
        <div className="relative h-96 flex-1">
          <div className="inline-flex items-center gap-1 rounded-sm bg-[#E0E7FF] px-2 py-1">
            <Sparkles className="h-3.5 w-3.5 text-gray-500" />
            <span className="text-xs font-medium text-gray-500">
              New: Advanced Generative Models Path
            </span>
          </div>

          <h1 className="mt-6 w-[596px] max-w-full text-5xl font-bold leading-[52.8px] text-[#18181B]">
            Master AI,
            <br />
            Master the Future
          </h1>

          <p className="mt-6 max-w-96 text-lg leading-7 text-[#3F3F46]">
            The world&apos;s leading AI-skills marketplace. Join thousands of
            professionals accelerating their careers with cutting-edge,
            expert-led artificial intelligence courses.
          </p>

          <div className="mt-8 flex items-center gap-4">
            <Link
              href="/courses"
              className="rounded-lg bg-[#3525CD] px-10 py-4 text-sm font-semibold tracking-wide text-white shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)] hover:bg-[#2A1DA3]"
            >
              Explore Courses
            </Link>
            <Link
              href="/pricing"
              className="rounded-lg border border-[#CBD5E1] bg-[#F8FAFC] px-10 py-4 text-sm font-semibold tracking-wide text-slate-600 hover:bg-gray-100"
            >
              For Enterprise
            </Link>
          </div>
        </div>

        {/* Right: image */}
        <div className="relative min-h-96 flex-1 self-stretch overflow-hidden rounded-xl shadow-[0px_10px_32px_0px_rgba(15,23,42,0.12)]">
          <Image
            src="https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=1200&q=80"
            alt="AI Learning Concept"
            fill
            sizes="(max-width: 768px) 100vw, 596px"
            className="object-cover"
            priority
          />
          <div className="absolute inset-0 mix-blend-overlay bg-gradient-to-br from-[#3525CD]/10 to-transparent" />
        </div>
      </div>
    </section>
  );
}

'@
Write-CodeFile -Path "apps/web/components/marketing/HeroSection.tsx" -Content $content

# ---- apps/web/components/marketing/CourseCard.tsx ----
$content = @'
import Image from "next/image";
import { Star } from "lucide-react";

export interface CourseCardProps {
  title: string;
  instructor: string;
  rating: number;
  reviews: string;
  tag: string;
  tagVariant?: "default" | "highlight" | "neutral";
  image: string;
}

const tagStyles: Record<NonNullable<CourseCardProps["tagVariant"]>, string> = {
  default: "bg-[#E0E7FF] text-gray-500",
  highlight: "bg-[#3525CD]/10 text-[#3525CD]",
  neutral: "bg-zinc-200 text-zinc-900",
};

export function CourseCard({
  title,
  instructor,
  rating,
  reviews,
  tag,
  tagVariant = "default",
  image,
}: CourseCardProps) {
  return (
    <article className="flex flex-1 flex-col overflow-hidden rounded-xl bg-[#FFFFFF] shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
      <div className="relative h-40 w-full overflow-hidden bg-gray-100">
        <Image
          src={image}
          alt={title}
          fill
          sizes="(max-width: 768px) 100vw, 288px"
          className="object-cover"
        />
      </div>

      <div className="flex flex-col gap-4 p-6">
        <span
          className={`inline-block w-fit rounded-sm px-2 pb-1 pt-[3px] text-xs font-medium ${tagStyles[tagVariant]}`}
        >
          {tag}
        </span>

        <h3 className="text-2xl font-semibold leading-8 text-[#18181B]">
          {title}
        </h3>

        <div className="flex flex-col gap-1">
          <p className="text-sm text-[#3F3F46]">{instructor}</p>
          <div className="flex items-center gap-2">
            <div className="flex items-center gap-1">
              <Star className="h-3.5 w-3.5 text-[#005338]" fill="currentColor" strokeWidth={0} />
              <span className="text-sm font-semibold tracking-wide text-[#005338]">
                {rating}
              </span>
            </div>
            <span className="text-sm text-gray-500">({reviews} reviews)</span>
          </div>
        </div>
      </div>
    </article>
  );
}

'@
Write-CodeFile -Path "apps/web/components/marketing/CourseCard.tsx" -Content $content

Write-Host "`nDone. Restart your dev server:" -ForegroundColor Cyan
Write-Host "  Ctrl+C, then: pnpm --filter web dev"