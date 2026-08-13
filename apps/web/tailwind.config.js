/** @type {import("tailwindcss").Config} */
module.exports = {
  content: [
    "./app/**/*.{ts,tsx}",
    "./hooks/**/*.{ts,tsx}",
    "./lib/**/*.{ts,tsx}",
    "../../packages/ui/src/**/*.{ts,tsx}"
  ],
  darkMode: ["selector", '[data-theme="dark"]'],
  theme: {
    extend: {
      colors: {
        ink: "var(--color-ink)",
        "ink-soft": "var(--color-ink-soft)",
        paper: "var(--color-paper)",
        "paper-dim": "var(--color-paper-dim)",
        card: "var(--color-card)",
        line: "var(--color-line)",
        "line-strong": "var(--color-line-strong)",
        gold: "var(--color-gold)",
        "gold-dark": "var(--color-gold-dark)",
        "gold-tint": "var(--color-gold-tint)",
        teal: "var(--color-teal)",
        "teal-light": "var(--color-teal-light)",
        success: "var(--color-success)",
        "success-tint": "var(--color-success-tint)",
        warning: "var(--color-warning)",
        "warning-tint": "var(--color-warning-tint)",
        error: "var(--color-error)",
        "error-tint": "var(--color-error-tint)",
        info: "var(--color-info)",
        "info-tint": "var(--color-info-tint)"
      },
      borderRadius: {
        card: "14px",
        control: "8px"
      },
      fontFamily: {
        display: ["var(--font-display)", "system-ui", "sans-serif"],
        sans: ["var(--font-sans)", "system-ui", "sans-serif"],
        mono: ["var(--font-mono)", "ui-monospace", "monospace"]
      },
      keyframes: {
        shimmer: { "100%": { transform: "translateX(100%)" } }
      },
      animation: {
        shimmer: "shimmer 1.4s infinite"
      }
    }
  },
  plugins: []
};