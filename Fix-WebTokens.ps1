<#
  Fix-WebTokens.ps1
  ---------------------------------------------------------------------------
  Fixes the "Cannot find module .../generate-css-vars.mjs" error.

  apps/web/package.json already has a "tokens:sync" prebuild step wired in,
  but the script + the design tokens it generates never existed. The
  @saachi/ui components (Button, CourseCard, etc.) rely on Tailwind classes
  like bg-gold, text-ink, rounded-card and CSS vars like --color-ink — this
  script defines the MINIMUM tokens needed so those components render.
  This is wiring, not a redesign — no new visual styling is added.

  Run from the SAI2 repo root:
    powershell -ExecutionPolicy Bypass -File .\Fix-WebTokens.ps1
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

Write-Host "== SAI2 :: fixing apps/web design tokens ==" -ForegroundColor Cyan

# 1. Stub generator script (no-op — tokens are defined statically below,
#    this just satisfies the existing "tokens:sync" npm script so dev/build don't fail)
Write-Utf8NoBom "apps/web/lib/design-system/generate-css-vars.mjs" @'
// Stub: static tokens already live in app/globals.css + tailwind.config.js.
// This file exists only so `npm run tokens:sync` (wired into package.json's
// dev/build scripts) has something to execute. Safe no-op.
console.log("[tokens:sync] using static tokens in globals.css — nothing to generate.");
'@

# 2. Tailwind config with the custom tokens @saachi/ui expects
$tailwindPath = Join-Path $Root "apps/web/tailwind.config.js"
Write-Utf8NoBom "apps/web/tailwind.config.js" @'
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
'@

# 3. globals.css — static CSS variables (light + dark) + Tailwind directives
Write-Utf8NoBom "apps/web/app/globals.css" @'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root,
[data-theme="light"] {
  --color-ink: #1a1a1a;
  --color-ink-soft: #5c5c5c;
  --color-paper: #fafaf8;
  --color-paper-dim: #f0efec;
  --color-card: #ffffff;
  --color-line: #e6e4e0;
  --color-line-strong: #d3d0ca;

  --color-gold: #e8c468;
  --color-gold-dark: #b8933c;
  --color-gold-tint: #faf1dc;

  --color-teal: #2f7d6e;
  --color-teal-light: #e3f2ee;

  --color-success: #2f7d4f;
  --color-success-tint: #e4f4e8;
  --color-warning: #b8933c;
  --color-warning-tint: #faf1dc;
  --color-error: #c0392b;
  --color-error-tint: #fbe9e7;
  --color-info: #2f6f9e;
  --color-info-tint: #e6f1f8;

  --font-display: "Inter", system-ui, sans-serif;
  --font-sans: "Inter", system-ui, sans-serif;
  --font-mono: "IBM Plex Mono", ui-monospace, monospace;
}

[data-theme="dark"] {
  --color-ink: #f2f2f0;
  --color-ink-soft: #b3b0aa;
  --color-paper: #16151a;
  --color-paper-dim: #201f24;
  --color-card: #1c1b20;
  --color-line: #2c2b30;
  --color-line-strong: #3a3940;

  --color-gold: #e8c468;
  --color-gold-dark: #d9ac47;
  --color-gold-tint: #34301f;

  --color-teal: #4fb39c;
  --color-teal-light: #1c2f2b;

  --color-success: #4fb374;
  --color-success-tint: #1c2f22;
  --color-warning: #d9ac47;
  --color-warning-tint: #34301f;
  --color-error: #e0685a;
  --color-error-tint: #35201e;
  --color-info: #5fa3d9;
  --color-info-tint: #1c2733;
}

body {
  background-color: var(--color-paper);
  color: var(--color-ink);
}
'@

Write-Host ""
Write-Host "== Done ==" -ForegroundColor Green
Write-Host "Now run:"
Write-Host "  pnpm --filter web dev"