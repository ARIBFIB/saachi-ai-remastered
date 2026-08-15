# ============================================================
#  Saachi AI - Replace Testimonials with AnimatedTestimonials
#  Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2
#  PS> .\Replace-Testimonials.ps1
# ============================================================

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$web  = Join-Path $root "apps\web"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Saachi AI - Testimonials Upgrade" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

function Write-File($path, $content) {
    $dir = Split-Path $path -Parent
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [System.IO.File]::WriteAllText($path, $content, [System.Text.UTF8Encoding]::new($false))
    Write-Host "  [OK] $path" -ForegroundColor Green
}

# ============================================================
#  STEP 1 - Install npm dependencies
# ============================================================
Write-Host "STEP 1: Installing npm packages..." -ForegroundColor Yellow
Set-Location $web
npm install @radix-ui/react-avatar @radix-ui/react-separator --save --legacy-peer-deps
Write-Host "  Packages installed." -ForegroundColor Green
Set-Location $root
Write-Host ""

# ============================================================
#  STEP 2 - shadcn Avatar component
# ============================================================
Write-Host "STEP 2: Writing dependency components..." -ForegroundColor Yellow

$avatar = @'
"use client"

import * as React from "react"
import * as AvatarPrimitive from "@radix-ui/react-avatar"
import { cn } from "@/lib/utils"

const Avatar = React.forwardRef
  React.ElementRef<typeof AvatarPrimitive.Root>,
  React.ComponentPropsWithoutRef<typeof AvatarPrimitive.Root>
>(({ className, ...props }, ref) => (
  <AvatarPrimitive.Root
    ref={ref}
    className={cn("relative flex h-10 w-10 shrink-0 overflow-hidden rounded-full", className)}
    {...props}
  />
))
Avatar.displayName = AvatarPrimitive.Root.displayName

const AvatarImage = React.forwardRef
  React.ElementRef<typeof AvatarPrimitive.Image>,
  React.ComponentPropsWithoutRef<typeof AvatarPrimitive.Image>
>(({ className, ...props }, ref) => (
  <AvatarPrimitive.Image
    ref={ref}
    className={cn("aspect-square h-full w-full", className)}
    {...props}
  />
))
AvatarImage.displayName = AvatarPrimitive.Image.displayName

const AvatarFallback = React.forwardRef
  React.ElementRef<typeof AvatarPrimitive.Fallback>,
  React.ComponentPropsWithoutRef<typeof AvatarPrimitive.Fallback>
>(({ className, ...props }, ref) => (
  <AvatarPrimitive.Fallback
    ref={ref}
    className={cn("flex h-full w-full items-center justify-center rounded-full bg-paper-dim text-ink-soft text-sm font-semibold", className)}
    {...props}
  />
))
AvatarFallback.displayName = AvatarPrimitive.Fallback.displayName

export { Avatar, AvatarImage, AvatarFallback }
'@

Write-File "$web\components\ui\avatar.tsx" $avatar

# ============================================================
#  STEP 3 - shadcn Separator component
# ============================================================
$separator = @'
"use client"

import * as React from "react"
import * as SeparatorPrimitive from "@radix-ui/react-separator"
import { cn } from "@/lib/utils"

const Separator = React.forwardRef
  React.ElementRef<typeof SeparatorPrimitive.Root>,
  React.ComponentPropsWithoutRef<typeof SeparatorPrimitive.Root>
>(({ className, orientation = "horizontal", decorative = true, ...props }, ref) => (
  <SeparatorPrimitive.Root
    ref={ref}
    decorative={decorative}
    orientation={orientation}
    className={cn(
      "shrink-0 bg-line",
      orientation === "horizontal" ? "h-[1px] w-full" : "h-full w-[1px]",
      className
    )}
    {...props}
  />
))
Separator.displayName = SeparatorPrimitive.Root.displayName

export { Separator }
'@

Write-File "$web\components\ui\separator.tsx" $separator

# ============================================================
#  STEP 4 - AnimatedTestimonials component
# ============================================================
Write-Host "STEP 3: Writing AnimatedTestimonials component..." -ForegroundColor Yellow

$animatedTestimonials = @'
"use client"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Separator } from "@/components/ui/separator"
import { Quote, Star } from "lucide-react"
import { motion, useAnimation, useInView } from "framer-motion"
import { useEffect, useRef, useState } from "react"

export interface Testimonial {
  id: number
  name: string
  role: string
  company: string
  content: string
  rating: number
  avatar: string
}

export interface AnimatedTestimonialsProps {
  title?: string
  subtitle?: string
  badgeText?: string
  testimonials?: Testimonial[]
  autoRotateInterval?: number
  trustedCompanies?: string[]
  trustedCompaniesTitle?: string
  className?: string
}

export function AnimatedTestimonials({
  title = "Loved by the community",
  subtitle = "Don't just take our word for it. See what learners have to say.",
  badgeText = "Trusted by learners",
  testimonials = [],
  autoRotateInterval = 6000,
  trustedCompanies = [],
  trustedCompaniesTitle = "Trusted by learners from companies worldwide",
  className,
}: AnimatedTestimonialsProps) {
  const [activeIndex, setActiveIndex] = useState(0)

  const sectionRef = useRef(null)
  const isInView = useInView(sectionRef, { once: true, amount: 0.2 })
  const controls = useAnimation()

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: { staggerChildren: 0.1, delayChildren: 0.2 },
    },
  }

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: { duration: 0.5, ease: "easeOut" },
    },
  }

  useEffect(() => {
    if (isInView) controls.start("visible")
  }, [isInView, controls])

  useEffect(() => {
    if (autoRotateInterval <= 0 || testimonials.length <= 1) return
    const interval = setInterval(() => {
      setActiveIndex((current) => (current + 1) % testimonials.length)
    }, autoRotateInterval)
    return () => clearInterval(interval)
  }, [autoRotateInterval, testimonials.length])

  if (testimonials.length === 0) return null

  return (
    <section
      ref={sectionRef}
      id="testimonials"
      className={`py-24 overflow-hidden bg-paper-dim/40 ${className ?? ""}`}
    >
      <div className="mx-auto max-w-7xl px-4 md:px-8">
        <motion.div
          initial="hidden"
          animate={controls}
          variants={containerVariants}
          className="grid grid-cols-1 gap-16 w-full md:grid-cols-2 lg:gap-24"
        >
          <motion.div variants={itemVariants} className="flex flex-col justify-center">
            <div className="space-y-6">
              {badgeText && (
                <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[12px] font-semibold bg-gold-tint text-gold-dark border border-gold-dark/20">
                  <Star className="h-3.5 w-3.5 fill-gold-dark" />
                  {badgeText}
                </div>
              )}

              <h2 className="font-display text-3xl font-bold tracking-tight text-ink sm:text-4xl md:text-5xl">
                {title}
              </h2>

              <p className="max-w-[520px] text-[15px] leading-relaxed text-ink-soft md:text-[17px]">
                {subtitle}
              </p>

              <div className="flex items-center gap-3 pt-4">
                {testimonials.map((_, index) => (
                  <button
                    key={index}
                    onClick={() => setActiveIndex(index)}
                    className={`h-2.5 rounded-full transition-all duration-300 ${
                      activeIndex === index
                        ? "w-10 bg-accent-violet"
                        : "w-2.5 bg-line-strong"
                    }`}
                    aria-label={`View testimonial ${index + 1}`}
                  />
                ))}
              </div>
            </div>
          </motion.div>

          <motion.div
            variants={itemVariants}
            className="relative h-full mr-10 min-h-[300px] md:min-h-[400px]"
          >
            {testimonials.map((testimonial, index) => (
              <motion.div
                key={testimonial.id}
                className="absolute inset-0"
                initial={{ opacity: 0, x: 100 }}
                animate={{
                  opacity: activeIndex === index ? 1 : 0,
                  x: activeIndex === index ? 0 : 100,
                  scale: activeIndex === index ? 1 : 0.9,
                }}
                transition={{ duration: 0.5, ease: "easeInOut" }}
                style={{ zIndex: activeIndex === index ? 10 : 0 }}
              >
                <div className="rounded-card border border-line bg-card shadow-lg p-8 h-full flex flex-col">
                  <div className="mb-6 flex gap-1">
                    {Array(testimonial.rating)
                      .fill(0)
                      .map((_, i) => (
                        <Star key={i} className="h-5 w-5 fill-gold-dark text-gold-dark" />
                      ))}
                  </div>

                  <div className="relative mb-6 flex-1">
                    <Quote className="absolute -top-2 -left-2 h-8 w-8 text-accent-violet/20 rotate-180" />
                    <p className="relative z-10 text-[16px] font-medium leading-relaxed text-ink">
                      &ldquo;{testimonial.content}&rdquo;
                    </p>
                  </div>

                  <Separator className="my-4" />

                  <div className="flex items-center gap-4">
                    <Avatar className="h-12 w-12 border border-line">
                      <AvatarImage src={testimonial.avatar} alt={testimonial.name} />
                      <AvatarFallback>{testimonial.name.charAt(0)}</AvatarFallback>
                    </Avatar>
                    <div>
                      <h3 className="text-[14px] font-semibold text-ink">{testimonial.name}</h3>
                      <p className="text-[12.5px] text-ink-soft">
                        {testimonial.role}, {testimonial.company}
                      </p>
                    </div>
                  </div>
                </div>
              </motion.div>
            ))}

            <div className="absolute -bottom-6 -left-6 h-24 w-24 rounded-xl bg-accent-violet/5 pointer-events-none" />
            <div className="absolute -top-6 -right-6 h-24 w-24 rounded-xl bg-accent-pink/5 pointer-events-none" />
          </motion.div>
        </motion.div>

        {trustedCompanies.length > 0 && (
          <motion.div
            variants={itemVariants}
            initial="hidden"
            animate={controls}
            className="mt-24 text-center"
          >
            <h3 className="text-[12.5px] font-medium uppercase tracking-[0.08em] text-ink-soft/60 mb-8">
              {trustedCompaniesTitle}
            </h3>
            <div className="flex flex-wrap justify-center gap-x-12 gap-y-6">
              {trustedCompanies.map((company) => (
                <div
                  key={company}
                  className="font-display text-[18px] font-bold text-ink-soft/40 hover:text-ink-soft transition-colors"
                >
                  {company}
                </div>
              ))}
            </div>
          </motion.div>
        )}
      </div>
    </section>
  )
}
'@

Write-File "$web\components\ui\animated-testimonials.tsx" $animatedTestimonials

# ============================================================
#  STEP 5 - Patch landing page (page.tsx)
# ============================================================
Write-Host "STEP 4: Patching landing page..." -ForegroundColor Yellow

$landingPath = "$web\app\(marketing)\page.tsx"
$landing = [System.IO.File]::ReadAllText($landingPath)

# --- A) Add import after LimitedTimeOfferPricing import ---
$oldImport = 'import { LimitedTimeOfferPricing } from "@/components/ui/limited-time-offer-pricing";'
$newImport = 'import { LimitedTimeOfferPricing } from "@/components/ui/limited-time-offer-pricing";
import { AnimatedTestimonials } from "@/components/ui/animated-testimonials";'

if ($landing -notmatch 'animated-testimonials') {
    $landing = $landing.Replace($oldImport, $newImport)
    Write-Host "  [OK] Import added" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] Import already present" -ForegroundColor DarkGray
}

# --- B) Remove old TESTIMONIALS const block (with ...EXTRA_TESTIMONIALS spread) ---
$pattern = '(?s)const TESTIMONIALS = \[.*?\n\];\r?\n'
$landing = [regex]::Replace($landing, $pattern, "")
Write-Host "  [OK] Old TESTIMONIALS const removed (if present)" -ForegroundColor Green

# --- C) Remove old EXTRA_TESTIMONIALS import ---
$oldExtraImport = 'import { EXTRA_TESTIMONIALS } from "./_components/landing-fake-data";'
$landing = $landing.Replace($oldExtraImport, "")
Write-Host "  [OK] EXTRA_TESTIMONIALS import removed (if present)" -ForegroundColor Green

# --- D) Remove ShieldCheck as VerifiedIcon import alias ---
$landing = $landing -replace ',\s*ShieldCheck as VerifiedIcon', ''

# --- E) Replace the old testimonials JSX section ---
$sectionPattern = '(?s)\s*\{/\* Testimonials \*/\}\s*<section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">.*?</section>\r?\n'

$newSection = @'

      {/* Testimonials - AnimatedTestimonials */}
      <AnimatedTestimonials
        title="What learners are saying"
        subtitle="4.8 average rating across 12,000+ reviews. Real results from real people."
        badgeText="Verified reviews"
        autoRotateInterval={6000}
        testimonials={[
          {
            id: 1,
            name: "Fatima R.",
            role: "Freelance automation consultant",
            company: "Independent",
            content: "I landed 3 client projects within a month of finishing the n8n automation course. The invoice-parsing workflow alone paid for the course ten times over.",
            rating: 5,
            avatar: "https://i.pravatar.cc/150?img=5",
          },
          {
            id: 2,
            name: "Ali Raza",
            role: "Support team lead",
            company: "Local Retail Co.",
            content: "Our WhatsApp response time dropped by 70% after building the chatbot from the course. Practical, no fluff, straight to the point.",
            rating: 5,
            avatar: "https://i.pravatar.cc/150?img=22",
          },
          {
            id: 3,
            name: "Hina Malik",
            role: "Marketing manager",
            company: "Agency Partner",
            content: "Best structured AI marketing content I have found anywhere. Wish there were a couple more advanced modules, but genuinely worth it.",
            rating: 4,
            avatar: "https://i.pravatar.cc/150?img=25",
          },
          {
            id: 4,
            name: "Omar Sheikh",
            role: "Indie developer",
            company: "Self-employed",
            content: "Went from zero to shipping my own AI agent product in six weeks. The instructor actually answers Q&A - that made all the difference.",
            rating: 5,
            avatar: "https://i.pravatar.cc/150?img=15",
          },
          {
            id: 5,
            name: "Zara Ahmed",
            role: "Product designer",
            company: "Independent",
            content: "The design systems course completely changed how I hand off files to developers. Immediate ROI.",
            rating: 5,
            avatar: "https://i.pravatar.cc/150?img=48",
          },
          {
            id: 6,
            name: "Usman Tariq",
            role: "Agency owner",
            company: "Growth Agency",
            content: "We onboarded our whole team through Saachi AI Business. Certificates and dashboards made tracking easy.",
            rating: 5,
            avatar: "https://i.pravatar.cc/150?img=13",
          },
          {
            id: 7,
            name: "Mahnoor Khalid",
            role: "Content strategist",
            company: "Freelance",
            content: "Solid course library, wish there was more advanced copywriting content, but great value overall.",
            rating: 4,
            avatar: "https://i.pravatar.cc/150?img=45",
          },
          {
            id: 8,
            name: "Danish Iqbal",
            role: "Automation freelancer",
            company: "Freelance",
            content: "Booked a mentorship call the same week I finished the course. Instructor feedback was gold.",
            rating: 5,
            avatar: "https://i.pravatar.cc/150?img=33",
          },
        ]}
        trustedCompanies={["NovaWorks", "BrightStack", "Vertex Labs", "Cirrus Digital", "Ember Systems", "Northline Tech"]}
        trustedCompaniesTitle="Learners from companies worldwide"
      />

'@

if ([regex]::IsMatch($landing, $sectionPattern)) {
    $landing = [regex]::Replace($landing, $sectionPattern, $newSection)
    Write-Host "  [OK] Testimonials section replaced" -ForegroundColor Green
} else {
    Write-Host "  [WARN] Could not find old testimonials section - trying fallback anchor..." -ForegroundColor Yellow
    $fallbackAnchor = '      {/* Course spotlight stream */}'
    if ($landing -match [regex]::Escape($fallbackAnchor)) {
        $landing = $landing.Replace($fallbackAnchor, $newSection + "`n" + $fallbackAnchor)
        Write-Host "  [OK] Injected via fallback anchor" -ForegroundColor Green
    } else {
        Write-Host "  [SKIP] Could not auto-inject - add AnimatedTestimonials manually to page.tsx" -ForegroundColor Red
    }
}

# --- F) Remove now-unused imports (Quote, BadgeCheck) ---
$landing = $landing -replace ',\s*Quote\b', ''
$landing = $landing -replace ',\s*BadgeCheck\b', ''

[System.IO.File]::WriteAllText($landingPath, $landing, [System.Text.UTF8Encoding]::new($false))
Write-Host "  [OK] $landingPath written" -ForegroundColor Green

# ============================================================
#  Done
# ============================================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Done! Start dev server:" -ForegroundColor Cyan
Write-Host "  cd apps\web; npm run dev" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""