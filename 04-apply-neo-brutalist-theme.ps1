<#
================================================================================
 04-apply-neo-brutalist-theme.ps1
================================================================================
 Applies the "Blue Neo-Brutalist SaaS" design system to the PUBLIC WEBSITE
 only (apps/web -- marketing/marketplace/course-detail/search/pricing/cart/
 checkout/legal/support/about/instructor-facing pages + components).

 Learner dashboard, auth pages, and the Admin app are intentionally left
 untouched (they use the shared indigo `primary` token, not the
 "Blueprint"-prefixed tokens this script targets).

 WHAT THIS SCRIPT DOES
 ----------------------------------------------------------------------------
 1. Overwrites apps/web/lib/design-system/tokens.ts with the new Blue
    Neo-Brutalist token values (single source of truth -- see comments
    inside that file). This alone re-themes colors/shadows/radius
    site-wide for every component that already reads the tokens.
 2. Walks a fixed list of public-site component/page files and:
      - Thickens borders: bare `border ` / `border-[...]` classes that sit
        alongside `blueprintLine`/`border-color` styling get bumped to
        `border-2` (2px = --border-normal) so the black-outline look
        actually reads as "neo-brutalist" instead of a 1px hairline.
      - Converts soft/blurred shadow utility values
        (`shadow-[0px_4px_20px_0px_rgba(...)]` etc.) to the token-driven
        hard offset shadow `shadow-[var(--token-shadow-md)]`.
 3. Creates a timestamped .bak copy of every file it touches before
    editing, and prints a summary of what changed.

 USAGE
 ----------------------------------------------------------------------------
   cd D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2
   pwsh .\04-apply-neo-brutalist-theme.ps1
   # or preview without writing anything:
   pwsh .\04-apply-neo-brutalist-theme.ps1 -WhatIf

 After running:
   pnpm --filter web run tokens:sync   # (also runs automatically on dev/build)
   pnpm --filter web dev
================================================================================
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

function Write-Section($text) {
  Write-Host ""
  Write-Host "== $text ==" -ForegroundColor Cyan
}

function Backup-File([string]$path) {
  if (Test-Path $path) {
    $bak = "$path.bak-$timestamp"
    Copy-Item -Path $path -Destination $bak -Force
    return $bak
  }
  return $null
}

# ------------------------------------------------------------------------
# 0. Resolve paths
# ------------------------------------------------------------------------
$webRoot    = Join-Path $RepoRoot "apps\web"
$tokensPath = Join-Path $webRoot "lib\design-system\tokens.ts"

if (-not (Test-Path $webRoot)) {
  throw "Could not find apps\web under '$RepoRoot'. Run this script from the SAI2 repo root, or pass -RepoRoot."
}
if (-not (Test-Path $tokensPath)) {
  throw "Could not find $tokensPath"
}

# ------------------------------------------------------------------------
# 1. Write the new tokens.ts (single source of truth)
# ------------------------------------------------------------------------
Write-Section "Step 1/3: Updating design tokens ($tokensPath)"

$tokensContent = @'
/**
 * ============================================================================
 * DESIGN TOKENS -- SINGLE SOURCE OF TRUTH
 * ============================================================================
 * Edit ONLY this file to re-theme the entire app (Tailwind CSS vars +
 * Ant Design components both derive from this object).
 *
 * After editing colors here, run:
 *   pnpm --filter web run tokens:sync
 * (or it runs automatically via the "predev"/"prebuild" npm script)
 *
 * ----------------------------------------------------------------------------
 * PUBLIC WEBSITE THEME: "Blue Neo-Brutalist SaaS"
 * ----------------------------------------------------------------------------
 * The public marketing site (Header, HeroSection, CourseCard,
 * MarketplaceCourseCard, CategoryGrid, WhySaachi, Footer/CompactFooter,
 * FilterSidebar, Pagination, SortDropdown, Pricing, Cart, Search, Legal
 * pages, etc.) reads the "Blueprint"-prefixed tokens below
 * (paper / inkDeep / inkDeepSoft / amber* / teal* / blueprintLine*).
 *
 * To re-theme the ENTIRE public site, change ONLY the values in this
 * block -- every component listed above automatically follows, since
 * none of them hardcode colors; they all reference these CSS vars.
 *
 * Design system reference: Blue Neo-Brutalist SaaS
 *   - Thick black (--ink) borders on every surface, never soft/blurred
 *     shadows -- only hard offset shadows (see shadow.hard below).
 *   - Blue leads (~40-50% of colored surfaces) but is never alone --
 *     teal / orange / purple / green always show up somewhere.
 *   - Flat color blocks only. No gradients, no glassmorphism.
 * ============================================================================
 */

export const tokens = {
  color: {
    // Brand / primary (legacy -- still used by learner/instructor dashboards,
    // Ant Design form controls, and the auth pages). Left as the original
    // indigo so the logged-in product experience is untouched by the public
    // site's Neo-Brutalist re-theme.
    primary: "#3525CD",
    primaryHover: "#2A1DA3",
    primaryTint: "#E0E7FF",
    primaryDark: "#1E1B4B",
    decorativeCyan: "#A5F3FC",

    // Secondary accent
    success: "#005338",
    successTint: "#D1FAE5",
    completedBadgeBg: "#D1FAE5",

    // Neutrals
    ink: "#18181B",
    inkSoft: "#3F3F46",
    textMuted: "#64748B",

    // Surfaces
    bg: "#F8FAFC",
    surface: "#FFFFFF",
    surfaceAlt: "#F4F4F5",
    playerBg: "#0F172A",
    completedGreen: "#4EDEA3",

    // Borders
    border: "#CBD5E1",
    borderStrong: "#94A3B8",

    // Status
    error: "#DC2626",
    notificationDot: "#BA1A1A",
    errorTint: "#FEE2E2",
    warning: "#D97706",
    warningTint: "#FEF3C7",

    // ------------------------------------------------------------------
    // "Blueprint" token group -- PUBLIC WEBSITE ONLY.
    // Repainted here to the Blue Neo-Brutalist SaaS palette. Change these
    // values and the whole marketing site re-themes.
    // ------------------------------------------------------------------

    // Default section background across the public site.
    paper: "#E3ECFB",

    // Primary heading / ink color -- also used for every card/mockup
    // border, since this system uses solid black borders everywhere.
    inkDeep: "#12141C",

    // Muted body copy color.
    inkDeepSoft: "#4A4A55",

    // PRIMARY accent -- "S" logo mark, hero CTA button, category icons,
    // star ratings, price highlights. This is --accent-blue: a warmer,
    // more saturated cobalt, NOT default Tailwind blue-500.
    amber: "#3E6BF0",
    amberDark: "#1F3FAE",
    amberTint: "#D9E4FB",

    // Secondary blue-family accent -- integrations/partners, "New"
    // badges, WhySaachi feature borders.
    teal: "#33C7C0",
    tealTint: "#DDEEEA",

    // Card / mockup-frame / divider border color. Always solid ink black.
    blueprintLine: "#12141C",
    blueprintLineSoft: "rgba(18,20,28,0.12)",

    // ------------------------------------------------------------------
    // Extra Neo-Brutalist palette for new sections (pricing tiers, stat
    // banners, AI/insight cards, dark contrast section).
    // ------------------------------------------------------------------
    accentOrange: "#F5A25C",
    accentOrangeTint: "#FCEACB",
    accentPurple: "#A594F9",
    accentPurpleTint: "#EDE9FE",
    accentGreen: "#6FCB6B",
    accentGreenTint: "#E3F6E1",
    bgDark: "#0F1420",
    bgCream: "#FBF9F5"
  },

  font: {
    family: "'Inter', -apple-system, 'Segoe UI', sans-serif",
    displayFamily: "'Space Grotesk', -apple-system, sans-serif",
    bodyFamily: "'IBM Plex Sans', -apple-system, sans-serif",
    monoFamily: "'IBM Plex Mono', 'Courier New', monospace",
    size: {
      xs: "12px",
      sm: "14px",
      base: "16px",
      lg: "18px",
      xl: "20px",
      "2xl": "24px",
      "3xl": "30px",
      "5xl": "48px"
    },
    weight: {
      normal: 400,
      medium: 500,
      semibold: 600,
      bold: 700,
      black: 900
    }
  },

  radius: {
    sm: "4px",
    md: "14px",
    lg: "20px",
    xl: "20px",
    full: "9999px"
  },

  shadow: {
    sm: "2px 2px 0 var(--token-color-blueprintLine)",
    md: "4px 4px 0 var(--token-color-blueprintLine)",
    lg: "4px 4px 0 var(--token-color-blueprintLine)"
  },

  spacing: {
    section: "48px",
    sectionLg: "80px",
    container: "1280px"
  }
} as const;

export type DesignTokens = typeof tokens;
'@

if ($PSCmdlet.ShouldProcess($tokensPath, "Overwrite with Neo-Brutalist tokens")) {
  $bak = Backup-File $tokensPath
  Set-Content -Path $tokensPath -Value $tokensContent -Encoding UTF8 -NoNewline
  Write-Host "  Updated tokens.ts" -ForegroundColor Green
  if ($bak) { Write-Host "  Backup: $bak" -ForegroundColor DarkGray }
}

# ------------------------------------------------------------------------
# 2. Public-site files to thicken borders / harden shadows on
# ------------------------------------------------------------------------
Write-Section "Step 2/3: Thickening borders + hardening shadows on public site files"

$relativeFiles = @(
  # (marketing) route pages
  "app\(marketing)\page.tsx"
  "app\(marketing)\about\page.tsx"
  "app\(marketing)\become-instructor\page.tsx"
  "app\(marketing)\cart\page.tsx"
  "app\(marketing)\checkout\page.tsx"
  "app\(marketing)\contact\page.tsx"
  "app\(marketing)\courses\page.tsx"
  "app\(marketing)\order-confirmation\page.tsx"
  "app\(marketing)\pricing\page.tsx"
  "app\(marketing)\search\page.tsx"
  "app\(marketing)\legal\terms\page.tsx"
  "app\not-found.tsx"

  # marketing components
  "components\marketing\CategoryGrid.tsx"
  "components\marketing\CompactFooter.tsx"
  "components\marketing\CourseCard.tsx"
  "components\marketing\Footer.tsx"
  "components\marketing\Header.tsx"
  "components\marketing\HeroSection.tsx"
  "components\marketing\Newsletter.tsx"
  "components\marketing\TrendingCourses.tsx"
  "components\marketing\WhySaachi.tsx"

  # marketplace components
  "components\marketplace\CategoryBanner.tsx"
  "components\marketplace\CategoryChips.tsx"
  "components\marketplace\CategoryCourseCard.tsx"
  "components\marketplace\FilterSidebar.tsx"
  "components\marketplace\MarketplaceCourseCard.tsx"
  "components\marketplace\Pagination.tsx"
  "components\marketplace\SortDropdown.tsx"

  # course detail
  "components\course-detail\CourseCurriculum.tsx"
  "components\course-detail\CourseHero.tsx"
  "components\course-detail\DetailFooter.tsx"
  "components\course-detail\InstructorBio.tsx"
  "components\course-detail\PurchaseCard.tsx"
  "components\course-detail\WhatYoullLearn.tsx"

  # cart / checkout
  "components\cart\CartHeader.tsx"
  "components\cart\CartItemCard.tsx"
  "components\cart\OrderSummary.tsx"
  "components\checkout\BillingInformationCard.tsx"
  "components\checkout\CheckoutFooter.tsx"
  "components\checkout\CheckoutHeader.tsx"
  "components\checkout\CheckoutOrderSummary.tsx"
  "components\checkout\PaymentMethodCard.tsx"

  # pricing
  "components\pricing\BillingToggle.tsx"
  "components\pricing\FaqAccordion.tsx"
  "components\pricing\FeatureComparisonTable.tsx"
  "components\pricing\PricingCard.tsx"

  # search
  "components\search\FeaturedResultCard.tsx"
  "components\search\InstructorResultCard.tsx"
  "components\search\ResultFilterTabs.tsx"
  "components\search\ResultsPagination.tsx"
  "components\search\StandardResultCard.tsx"

  # instructor (public profile)
  "components\instructor\InstructorCourseCard.tsx"
  "components\instructor\InstructorProfileCard.tsx"
  "components\instructor\InstructorStatsGrid.tsx"

  # legal / support / about
  "components\legal\LegalSection.tsx"
  "components\legal\LegalSidebar.tsx"
  "components\support\ContactForm.tsx"
  "components\support\DirectContactCard.tsx"
  "components\support\OfficeMapCard.tsx"
  "components\support\SupportFooter.tsx"
  "components\support\SupportHeader.tsx"
  "components\about\AboutHero.tsx"
  "components\about\CoreDirectivesGrid.tsx"
  "components\about\TeamGrid.tsx"
)

# Regex replacements applied to every file above, in order.
# 1) Bare Tailwind "border" utility (not already border-2/border-4/etc, and
#    not "border-t/-b/-l/-r/-x/-y" side-specific utilities) -> border-2.
# 2) Soft/blurred arbitrary box-shadow utilities -> token-driven hard shadow.
$replacements = @(
  @{
    # className="... border border-[var(--token-color-blueprintLine)] ..."
    # or className="... border border-[var(--token-color-border)]/30 ..."
    Pattern     = '(?<![\w-])border(?![\w-])'
    Replacement = 'border-2'
    Description = 'bare "border" -> "border-2" (thick neo-brutalist outline)'
  },
  @{
    Pattern     = 'shadow-\[0px_4px_20px_0px_rgba\(15,23,42,0\.05\)\]'
    Replacement = 'shadow-[var(--token-shadow-md)]'
    Description = 'soft card shadow -> hard offset shadow'
  },
  @{
    Pattern     = 'shadow-\[0px_1px_2px_0px_rgba\(0,0,0,0\.05\)\]'
    Replacement = 'shadow-[var(--token-shadow-sm)]'
    Description = 'soft small shadow -> hard offset shadow (sm)'
  },
  @{
    Pattern     = 'shadow-\[0px_10px_32px_0px_rgba\(15,23,42,0\.12\)\]'
    Replacement = 'shadow-[var(--token-shadow-lg)]'
    Description = 'soft large shadow -> hard offset shadow (lg)'
  },
  @{
    Pattern     = 'shadow-lg(?![\w-])'
    Replacement = 'shadow-[var(--token-shadow-md)]'
    Description = 'Tailwind shadow-lg -> hard offset shadow'
  },
  @{
    Pattern     = 'shadow-md(?![\w-])'
    Replacement = 'shadow-[var(--token-shadow-sm)]'
    Description = 'Tailwind shadow-md -> hard offset shadow (sm)'
  }
)

$touched = 0
$skipped = 0
$missing = 0

foreach ($rel in $relativeFiles) {
  $full = Join-Path $webRoot $rel

  if (-not (Test-Path $full)) {
    Write-Host "  [skip-missing] $rel" -ForegroundColor DarkYellow
    $missing++
    continue
  }

  $original = Get-Content -Path $full -Raw -Encoding UTF8
  $updated  = $original
  $fileChanged = $false

  foreach ($r in $replacements) {
    $new = [regex]::Replace($updated, $r.Pattern, $r.Replacement)
    if ($new -ne $updated) {
      $fileChanged = $true
      $updated = $new
    }
  }

  if (-not $fileChanged) {
    Write-Host "  [no-change]   $rel" -ForegroundColor DarkGray
    $skipped++
    continue
  }

  if ($PSCmdlet.ShouldProcess($full, "Apply Neo-Brutalist border/shadow refactor")) {
    Backup-File $full | Out-Null
    Set-Content -Path $full -Value $updated -Encoding UTF8 -NoNewline
    Write-Host "  [updated]     $rel" -ForegroundColor Green
    $touched++
  }
}

# ------------------------------------------------------------------------
# 3. Summary
# ------------------------------------------------------------------------
Write-Section "Step 3/3: Summary"
Write-Host "  Tokens file updated : $tokensPath"
Write-Host "  Files updated        : $touched"
Write-Host "  Files unchanged      : $skipped"
Write-Host "  Files not found      : $missing"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  pnpm --filter web run tokens:sync"
Write-Host "  pnpm --filter web dev"
Write-Host ""
Write-Host "Note: dashboard-only files (app/(learner), app/(auth), apps/admin) were" -ForegroundColor DarkGray
Write-Host "NOT touched by this script by design." -ForegroundColor DarkGray