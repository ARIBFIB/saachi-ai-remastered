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