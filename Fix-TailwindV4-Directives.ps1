<#
  Fix-TailwindV4-Directives.ps1  (corrected)
  ---------------------------------------------------------------------------
  Same fix as before: globals.css used Tailwind v3 @tailwind directives but
  Tailwind v4 is installed, so styling silently generated almost nothing.
  Switches to Tailwind v4's @import syntax + @config to keep using the
  existing JS tailwind.config.js (colors, radii, fonts).

  Run from the SAI2 repo root:
    powershell -ExecutionPolicy Bypass -File .\Fix-TailwindV4-Directives.ps1
#>

$ErrorActionPreference = "Stop"
$Root = (Get-Location).Path

function Write-Utf8NoBom {
    param([string]$RelativePath, [string]$Content)
    $fullPath = Join-Path $Root $RelativePath
    [System.IO.File]::WriteAllText($fullPath, $Content, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "  wrote $RelativePath"
}

Write-Host "== SAI2 :: switching globals.css to Tailwind v4 syntax ==" -ForegroundColor Cyan

Write-Utf8NoBom "apps/web/app/globals.css" @'
@import "tailwindcss";
@config "../tailwind.config.js";

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
  font-family: var(--font-sans);
}

* {
  border-color: var(--color-line);
}
'@

Write-Host ""
Write-Host "== Done ==" -ForegroundColor Green
Write-Host "Now run: pnpm --filter web dev"
Write-Host "Check localhost 3000 - styling should now render correctly."
Write-Host "Then: git add -A"
Write-Host "Then: git commit -m fix-tailwind-v4-syntax"
Write-Host "Then: git push"