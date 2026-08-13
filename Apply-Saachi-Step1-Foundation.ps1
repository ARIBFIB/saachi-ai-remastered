<#
================================================================================
Apply-Saachi-Step1-Foundation.ps1
STEP 1 of the design-system rollout: foundation / design-tokens files only.

USAGE:
  1. Save this file into your repo root, e.g.:
     D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2\Apply-Saachi-Step1-Foundation.ps1
  2. In PowerShell (prompt: PS D:\...\SAI2>) run:
       .\Apply-Saachi-Step1-Foundation.ps1
  3. Existing files that would be overwritten are backed up first into
     .\_backup_stepwise\<timestamp>\
================================================================================
#>

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
if (-not $root) { $root = Get-Location }

$backupDir = Join-Path $root ("_backup_stepwise\{0}" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
$writtenCount = 0

function Write-SaachiFile {
    param(
        [string]$RelativePath,
        [string]$Content
    )

    $fullPath = Join-Path $root $RelativePath
    $dir = Split-Path $fullPath -Parent

    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    if (Test-Path $fullPath) {
        $backupTarget = Join-Path $backupDir $RelativePath
        $backupTargetDir = Split-Path $backupTarget -Parent
        if (-not (Test-Path $backupTargetDir)) {
            New-Item -ItemType Directory -Path $backupTargetDir -Force | Out-Null
        }
        Copy-Item -Path $fullPath -Destination $backupTarget -Force
        Write-Host "  backed up existing: $RelativePath"
    }

    $Content = $Content.TrimStart("`r", "`n")
    Set-Content -Path $fullPath -Value $Content -Encoding UTF8 -NoNewline
    $script:writtenCount++
    Write-Host "  wrote: $RelativePath"
}

Write-Host "=== STEP 1: Foundation (design tokens) ==="
Write-Host "Target repo root: $root"
Write-Host ""

# ------------------------------------------------------------------
# apps/web/lib/design-system/tokens.ts
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\lib\design-system\tokens.ts" @'
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
 * ============================================================================
 */

export const tokens = {
  color: {
    // Brand / primary (legacy -- still used by learner/instructor dashboards,
    // Ant Design form controls, and the auth pages).
    primary: "#3525CD",
    primaryHover: "#2A1DA3",
    primaryTint: "#E0E7FF",
    primaryDark: "#1E1B4B",
    decorativeCyan: "#A5F3FC",

    success: "#005338",
    successTint: "#D1FAE5",
    completedBadgeBg: "#D1FAE5",

    ink: "#18181B",
    inkSoft: "#3F3F46",
    textMuted: "#64748B",

    bg: "#F8FAFC",
    surface: "#FFFFFF",
    surfaceAlt: "#F4F4F5",
    playerBg: "#0F172A",
    completedGreen: "#4EDEA3",

    border: "#CBD5E1",
    borderStrong: "#94A3B8",

    error: "#DC2626",
    notificationDot: "#BA1A1A",
    errorTint: "#FEE2E2",
    warning: "#D97706",
    warningTint: "#FEF3C7",

    // ------------------------------------------------------------------
    // "Blueprint" token group -- PUBLIC WEBSITE ONLY.
    // ------------------------------------------------------------------
    paper: "#E3ECFB",
    inkDeep: "#12141C",
    inkDeepSoft: "#4A4A55",
    amber: "#3E6BF0",
    amberDark: "#1F3FAE",
    amberTint: "#D9E4FB",
    teal: "#33C7C0",
    tealTint: "#DDEEEA",
    blueprintLine: "#12141C",
    blueprintLineSoft: "rgba(18,20,28,0.12)",

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

# ------------------------------------------------------------------
# apps/web/lib/design-system/antd-theme.ts
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\lib\design-system\antd-theme.ts" @'
import type { ThemeConfig } from "antd";
import { tokens } from "./tokens";

/**
 * Ant Design theme -- fully derived from tokens.ts.
 * Do NOT hardcode colors here. Change tokens.ts instead.
 */
export const antdTheme: ThemeConfig = {
  token: {
    colorPrimary: tokens.color.primary,
    colorPrimaryHover: tokens.color.primaryHover,
    colorSuccess: tokens.color.success,
    colorError: tokens.color.error,
    colorWarning: tokens.color.warning,
    colorText: tokens.color.ink,
    colorTextSecondary: tokens.color.inkSoft,
    colorTextTertiary: tokens.color.textMuted,
    colorBgBase: tokens.color.surface,
    colorBgLayout: tokens.color.bg,
    colorBorder: tokens.color.border,
    borderRadius: parseInt(tokens.radius.md),
    borderRadiusLG: parseInt(tokens.radius.lg),
    borderRadiusSM: parseInt(tokens.radius.sm),
    fontFamily: tokens.font.family,
    fontSize: parseInt(tokens.font.size.sm)
  },
  components: {
    Button: {
      borderRadius: parseInt(tokens.radius.md),
      controlHeight: 44,
      fontWeight: tokens.font.weight.semibold
    },
    Input: {
      borderRadius: parseInt(tokens.radius.md),
      controlHeight: 44
    },
    Card: {
      borderRadiusLG: parseInt(tokens.radius.xl)
    },
    Tag: {
      borderRadiusSM: parseInt(tokens.radius.sm)
    }
  }
};
'@

# ------------------------------------------------------------------
# apps/web/lib/design-system/AntdProvider.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\lib\design-system\AntdProvider.tsx" @'
"use client";

import { ConfigProvider } from "antd";
import { AntdRegistry } from "@ant-design/nextjs-registry";
import type { ReactNode } from "react";
import { antdTheme } from "./antd-theme";

export function AntdProvider({ children }: { children: ReactNode }) {
  return (
    <AntdRegistry>
      <ConfigProvider theme={antdTheme}>{children}</ConfigProvider>
    </AntdRegistry>
  );
}
'@

# ------------------------------------------------------------------
# apps/web/lib/design-system/index.ts
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\lib\design-system\index.ts" @'
export { tokens } from "./tokens";
export type { DesignTokens } from "./tokens";
export { antdTheme } from "./antd-theme";
export { AntdProvider } from "./AntdProvider";
'@

# ------------------------------------------------------------------
# apps/web/lib/design-system/generate-css-vars.mjs
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\lib\design-system\generate-css-vars.mjs" @'
// ============================================================================
// generate-css-vars.mjs
// Syncs lib/design-system/tokens.ts -> app/globals.css (Tailwind @theme block)
// Runs automatically before dev/build via npm scripts. Do not edit the
// generated block in globals.css by hand -- edit tokens.ts instead.
// ============================================================================
import { readFileSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const tokensPath = path.join(__dirname, "tokens.ts");
const cssPath = path.join(__dirname, "..", "..", "app", "globals.css");

const START_MARKER = "/* === AUTO-GENERATED TOKENS START (do not edit) === */";
const END_MARKER = "/* === AUTO-GENERATED TOKENS END === */";

async function loadTokens() {
  // Dynamic import works because tokens.ts is plain TS object literal,
  // executed here via a lightweight transpile-free eval of the exported object.
  const raw = readFileSync(tokensPath, "utf-8");
  const match = raw.match(/export const tokens = ({[\s\S]*?}) as const;/);
  if (!match) throw new Error("Could not parse tokens.ts");
  // eslint-disable-next-line no-eval
  const tokens = eval(`(${match[1]})`);
  return tokens;
}

function flatten(obj, prefix = "") {
  const out = {};
  for (const [key, value] of Object.entries(obj)) {
    const varName = prefix ? `${prefix}-${key}` : key;
    if (typeof value === "object" && value !== null) {
      Object.assign(out, flatten(value, varName));
    } else {
      out[varName] = value;
    }
  }
  return out;
}

const tokens = await loadTokens();
const flat = flatten(tokens);

const cssVars = Object.entries(flat)
  .map(([k, v]) => `  --token-${k}: ${v};`)
  .join("\n");

const block = `${START_MARKER}\n@theme {\n${cssVars}\n}\n${END_MARKER}`;

let css = readFileSync(cssPath, "utf-8");

if (css.includes(START_MARKER) && css.includes(END_MARKER)) {
  const regex = new RegExp(`${START_MARKER}[\\s\\S]*?${END_MARKER}`);
  css = css.replace(regex, block);
} else {
  css = `${block}\n\n${css}`;
}

writeFileSync(cssPath, css, "utf-8");
console.log(`[tokens:sync] ${Object.keys(flat).length} tokens written to globals.css`);
'@

# ------------------------------------------------------------------
# apps/web/app/globals.css
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\app\globals.css" @'
@import "tailwindcss";
@import url("https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&family=IBM+Plex+Sans:wght@400;500;600&family=IBM+Plex+Mono:wght@400;500&display=swap");

/* === AUTO-GENERATED TOKENS START (do not edit) === */
@theme {
}
/* === AUTO-GENERATED TOKENS END === */

html,
body {
  padding: 0;
  margin: 0;
  background: var(--token-color-bg);
  font-family: var(--token-font-bodyFamily);
}

* {
  box-sizing: border-box;
}
'@

Write-Host ""
Write-Host "=== STEP 1 complete: $writtenCount file(s) written. ==="
Write-Host "Next: run 'pnpm --filter web run tokens:sync' (or just 'pnpm dev') so"
Write-Host "globals.css gets the token CSS vars generated from tokens.ts."
if (Test-Path $backupDir) {
    Write-Host "Backups of any overwritten files: $backupDir"
}