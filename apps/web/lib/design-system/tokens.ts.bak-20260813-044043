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
    // Brand / primary (legacy â€” still used by learner/instructor dashboards)
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

    // ---- NEW: "Blueprint" system â€” Public Website redesign only ----
    paper: "#EEF1EC",
    inkDeep: "#12182B",
    inkDeepSoft: "#454C63",
    amber: "#F2A93B",
    amberDark: "#D6890F",
    amberTint: "#FCEACB",
    teal: "#0E6E62",
    tealTint: "#DDEEEA",
    blueprintLine: "#B9C2C7",
    blueprintLineSoft: "#D8DEDB"
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
    section: "48px",
    sectionLg: "80px",
    container: "1280px"
  }
} as const;

export type DesignTokens = typeof tokens;