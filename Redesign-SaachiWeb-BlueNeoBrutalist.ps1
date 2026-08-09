<#
  Redesign-SaachiWeb-BlueNeoBrutalist.ps1
  ----------------------------------------
  Applies the "Blue Neo-Brutalist SaaS" design system to apps/web by rewriting
  globals.css: swaps color/radius/shadow tokens onto the SAME CSS variable
  names already used across the 66 existing page/component files (--color-gold,
  --color-teal, --color-ink, --radius-card, etc.) and adds a global override
  layer that forces thick black borders + hard offset shadows onto the
  existing card / button / input / badge class patterns already in use.

  This does NOT touch packages/ui/src (not available in this workspace yet) —
  once that package is exported, a follow-up pass can restyle the component
  primitives themselves for a pixel-perfect match.

  USAGE:
    Run from your repo root (the folder containing "apps"):
      PS D:\...\SAI2> .\Redesign-SaachiWeb-BlueNeoBrutalist.ps1

  WHAT IT DOES:
    1. Locates apps\web\app\globals.css
    2. Backs it up to globals.css.bak-<timestamp>
    3. Writes the new blue-neo-brutalist globals.css
    4. Prints a summary + next-step notes
#>

[CmdletBinding()]
param(
    [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "    OK: $msg" -ForegroundColor Green }
function Write-Warn2($msg){ Write-Host "    WARN: $msg" -ForegroundColor Yellow }

Write-Step "Locating apps\web\app\globals.css under: $RepoRoot"

$globalsPath = Join-Path $RepoRoot "apps\web\app\globals.css"

if (-not (Test-Path $globalsPath)) {
    Write-Warn2 "Not found at expected path: $globalsPath"
    Write-Warn2 "Searching repo for globals.css under apps\web ..."
    $found = Get-ChildItem -Path $RepoRoot -Recurse -Filter "globals.css" -ErrorAction SilentlyContinue |
             Where-Object { $_.FullName -match "\\apps\\web\\" } |
             Select-Object -First 1
    if (-not $found) {
        Write-Error "Could not find apps\web\app\globals.css anywhere under $RepoRoot. Run this script from the folder that contains 'apps' (e.g. ...\SAI2)."
    }
    $globalsPath = $found.FullName
}

Write-Ok "Found: $globalsPath"

# ---------------------------------------------------------------------------
# 1. Backup
# ---------------------------------------------------------------------------
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = "$globalsPath.bak-$timestamp"
Copy-Item -Path $globalsPath -Destination $backupPath -Force
Write-Ok "Backed up existing file to: $backupPath"

# ---------------------------------------------------------------------------
# 2. New globals.css content (Blue Neo-Brutalist tokens mapped onto the
#    existing variable names used across apps/web components/pages)
# ---------------------------------------------------------------------------
$newCss = @'
@import url("https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700;800&family=Inter:wght@400;500;600;700&family=IBM+Plex+Mono:wght@500;600&display=swap");
@import "tailwindcss";

/*
  ============================================================================
  Blue Neo-Brutalist SaaS System — Saachi AI (apps/web)
  ============================================================================
  Tokens are mapped onto the SAME variable names the existing 60+ page/
  component files already reference (--color-gold, --color-teal, --color-ink,
  --radius-card, etc.) so this file alone reskins the app without touching
  every consuming file. Component PRIMITIVES (Card/Button/Input in
  packages/ui) should be restyled next for a pixel-perfect match — this layer
  gets ~90% of the way there via tokens + a global override block below.
  ============================================================================
*/

@theme {
  /* Ink / text */
  --color-ink: #12141C;
  --color-ink-soft: #4A4A55;

  /* Surfaces */
  --color-paper: #E3ECFB;       /* default section bg -> blue-light */
  --color-paper-dim: #FBF9F5;   /* cream alt surface */
  --color-card: #ffffff;

  /* Lines */
  --color-line: #12141C;        /* borders are now solid ink, not soft grey */
  --color-line-strong: #12141C;

  /* Primary accent -> repurposed as the cobalt "gold" slot so `bg-gold`,
     `text-gold-dark`, `border-gold` etc. across existing files become blue */
  --color-gold: #3E6BF0;        /* accent-blue */
  --color-gold-dark: #1F3FAE;   /* accent-blue-deep (hover/pressed) */
  --color-gold-tint: #E3ECFB;   /* blue-light */

  /* Secondary accent -> stays teal-family, remapped to system teal */
  --color-teal: #33C7C0;
  --color-teal-light: #D8F5F3;

  /* New supporting accents (available as bg-orange / bg-purple / bg-green
     utility classes via Tailwind v4 @theme token generation) */
  --color-orange: #F5A25C;
  --color-purple: #A594F9;
  --color-green: #6FCB6B;

  /* Status */
  --color-error: #F5716C;
  --color-error-tint: #FCE7E6;

  /* Type */
  --font-display: "Space Grotesk", "Inter", -apple-system, sans-serif;
  --font-body: "Inter", -apple-system, "Segoe UI", sans-serif;
  --font-mono: "IBM Plex Mono", "SFMono-Regular", monospace;

  /* Radius -> pill-forward system */
  --radius-card: 20px;     /* --radius-lg */
  --radius-control: 999px; /* --radius-pill (buttons/inputs/badges default to pill) */
}

/* Small/medium card & tile radius used by some existing components that
   don't need a full pill (kept as a plain CSS var since it isn't part of
   the default Tailwind color/radius scale generation). */
:root {
  --radius-md: 14px;
  --shadow-hard: 4px 4px 0 var(--color-ink);
  --shadow-hard-sm: 2px 2px 0 var(--color-ink);
  --bg-dark: #0F1420;
}

* {
  box-sizing: border-box;
}

html {
  scroll-behavior: smooth;
}

body {
  background: var(--color-paper);
  color: var(--color-ink);
  font-family: var(--font-body);
}

h1, h2, h3 {
  font-family: var(--font-display);
  text-transform: uppercase;
  letter-spacing: -0.01em;
}

::selection {
  background: var(--color-gold-tint);
  color: var(--color-ink);
}

/*
  ============================================================================
  Global override layer — Neo-Brutalist treatment for existing component
  class patterns (Card / Button / Input / Badge primitives from @saachi/ui)
  without needing to edit those source files directly.
  ============================================================================
*/

/* Cards: thick ink border + hard offset shadow, never a blurred shadow */
.rounded-card,
[class*="rounded-card"] {
  border: 2px solid var(--color-ink) !important;
  box-shadow: var(--shadow-hard);
  background-color: var(--color-card);
}

/* Small controls (inputs, small tiles) */
.rounded-control {
  border-radius: var(--radius-control);
}

/* Buttons: pill shape, solid ink border, hard-shadow hover lift */
button,
.btn,
a[class*="Button"] {
  border-radius: var(--radius-control);
}

button:not(:disabled):hover,
.btn:not(:disabled):hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-hard-sm);
  transition: transform 150ms ease, box-shadow 150ms ease;
}

/* Inputs / selects / textareas: pill border, hard-shadow focus ring instead
   of a soft blurred outline */
input,
select,
textarea {
  border: 2px solid var(--color-ink) !important;
  border-radius: var(--radius-control);
  background: var(--color-card);
}

input:focus,
select:focus,
textarea:focus {
  outline: none !important;
  box-shadow: var(--shadow-hard-sm) !important;
  border-color: var(--color-ink) !important;
}

/* Badges / pills */
[class*="badge"],
[class*="Badge"] {
  border: 2px solid var(--color-ink) !important;
  border-radius: var(--radius-control) !important;
  font-weight: 600;
}

/* Kill any lingering blurred shadows from the previous soft design so they
   don't stack with the new hard-shadow system */
.shadow, .shadow-sm, .shadow-md, .shadow-lg, .shadow-xl {
  box-shadow: var(--shadow-hard) !important;
}

/* Dark section helper — use bg-[var(--bg-dark)] via arbitrary Tailwind value,
   or apply this utility class directly: <section class="section-dark"> */
.section-dark {
  background: var(--bg-dark);
  color: #FFFFFF;
}
.section-dark h1, .section-dark h2, .section-dark h3 {
  color: #FFFFFF;
}

/* Eyebrow pill label helper, matches references/components.md #3 */
.eyebrow {
  display: inline-block;
  border: 2px solid var(--color-ink);
  border-radius: var(--radius-control);
  padding: 6px 18px;
  font-size: 12px;
  font-weight: 600;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  background: var(--color-card);
  margin-bottom: 20px;
}

/* Browser mockup frame helper, matches references/components.md #4 */
.browser-mockup {
  border: 2px solid var(--color-ink);
  border-radius: var(--radius-card);
  overflow: hidden;
  background: var(--color-card);
}
.browser-mockup__topbar {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  border-bottom: 2px solid var(--color-ink);
  background: var(--color-paper);
}
.browser-mockup__topbar .dot {
  width: 10px; height: 10px; border-radius: 50%; border: 1.5px solid var(--color-ink);
}
.browser-mockup__topbar .dot--red { background: #F5716C; }
.browser-mockup__topbar .dot--yellow { background: #F5C56C; }
.browser-mockup__topbar .dot--green { background: #6FCB6B; }
.browser-mockup__body { padding: 0; background: var(--color-paper-dim); }

@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
'@

# ---------------------------------------------------------------------------
# 3. Write file (UTF-8, no BOM to match existing repo convention)
# ---------------------------------------------------------------------------
Write-Step "Writing new blue-neo-brutalist globals.css"

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($globalsPath, $newCss, $utf8NoBom)

Write-Ok "globals.css updated."

Write-Host ""
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host " Done. Summary:" -ForegroundColor Magenta
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host " Updated : $globalsPath"
Write-Host " Backup  : $backupPath"
Write-Host ""
Write-Host " What changed:" -ForegroundColor Magenta
Write-Host "  - Palette remapped onto existing var names (gold->cobalt blue," 
Write-Host "    teal->system teal), + new --color-orange/--color-purple/--color-green"
Write-Host "  - Borders: all cards/inputs/badges now solid 2px ink border"
Write-Host "  - Shadows: hard offset only (4px 4px 0 ink) - no blur anywhere"
Write-Host "  - Radius: cards 20px, buttons/inputs/badges fully pill-shaped"
Write-Host "  - Headings: uppercase, Space Grotesk display font"
Write-Host "  - Added helper classes: .eyebrow, .browser-mockup, .section-dark"
Write-Host ""
Write-Host " NOT changed (needs a follow-up pass once available):" -ForegroundColor Yellow
Write-Host "  - packages/ui/src component source (Button/Card/Input primitives)"
Write-Host "    was not present in this export, so only token-level + CSS-override"
Write-Host "    reskinning was applied here. For pixel-perfect match (exact button"
Write-Host "    padding, mockup frames, pricing bars, etc.) export packages/ui/src"
Write-Host "    next and we'll restyle the primitives directly."
Write-Host "  - apps/admin was left untouched (this pass targeted apps/web only,"
Write-Host "    per your request)."
Write-Host ""
Write-Host " Next: run 'pnpm dev' inside apps/web and check a few pages" -ForegroundColor Cyan
Write-Host " (homepage, pricing, dashboard) to confirm the shift looks right"
Write-Host " before we move on to building out the missing pages."
Write-Host ""