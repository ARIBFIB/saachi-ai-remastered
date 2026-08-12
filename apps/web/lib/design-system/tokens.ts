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
 * ============================================================================
 */

export const tokens = {
  color: {
    // Brand / primary
    primary: "#3525CD",       // indigo-700 (buttons, links, active states)
    primaryHover: "#2A1DA3",
    primaryTint: "#E0E7FF",   // indigo-100 (badges, soft backgrounds)
    primaryDark: "#1E1B4B",    // deep indigo/violet (gradient end, dark panels)
    decorativeCyan: "#A5F3FC", // cyan-200 (soft decorative blur accents)

    // Secondary accent
    success: "#005338",       // emerald-900 (ratings, success states)
    successTint: "#D1FAE5",
    completedBadgeBg: "#D1FAE5", // emerald-100 (Completed pill on course cards)

    // Neutrals
    ink: "#18181B",           // zinc-900 (headings)
    inkSoft: "#3F3F46",       // gray-700 (body text)
    textMuted: "#64748B",     // gray-500 (captions, meta text)

    // Surfaces
    bg: "#F8FAFC",            // slate-50 (page background)
    surface: "#FFFFFF",       // card background
    surfaceAlt: "#F4F4F5",    // zinc-100 (icon backgrounds)
    playerBg: "#0F172A",       // slate-900 (video stage background)
    completedGreen: "#4EDEA3", // bright mint (lesson-completed ticks)

    // Borders
    border: "#CBD5E1",        // slate-300
    borderStrong: "#94A3B8",

    // Status
    error: "#DC2626",
    notificationDot: "#BA1A1A", // red badge dot on the notification bell
    errorTint: "#FEE2E2",
    warning: "#D97706",
    warningTint: "#FEF3C7"
  },

  font: {
    family: "'Inter', -apple-system, 'Segoe UI', sans-serif",
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
    md: "8px",
    lg: "12px",
    xl: "16px",
    full: "9999px"
  },

  shadow: {
    sm: "0px 1px 2px 0px rgba(0,0,0,0.05)",
    md: "0px 4px 20px 0px rgba(15,23,42,0.05)",
    lg: "0px 10px 32px 0px rgba(15,23,42,0.12)"
  },

  spacing: {
    section: "48px",       // py-12 sections
    sectionLg: "80px",     // py-20 sections
    container: "1280px"    // max-w container
  }
} as const;

export type DesignTokens = typeof tokens;