# =============================================================
# Saachi AI Frontend - Step 2: apps/web Next.js Init
# Creates package.json, tsconfig, next.config, tailwind config,
# root layout, globals.css, providers, middleware, homepage stub
# =============================================================

$ProjectRoot = "D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2"
$WebRoot = Join-Path $ProjectRoot "apps\web"

Write-Host "=== Saachi AI Frontend Scaffold - Step 2 (apps/web) ===" -ForegroundColor Cyan

if (-not (Test-Path $WebRoot)) {
    Write-Host "ERROR: apps/web not found. Run 01-scaffold-monorepo.ps1 first." -ForegroundColor Red
    exit 1
}

Set-Location $WebRoot

# ---------------------------------------------------------------
# package.json
# ---------------------------------------------------------------
$webPackageJson = @'
{
  "name": "web",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev -p 3000",
    "build": "next build",
    "start": "next start -p 3000",
    "lint": "next lint",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "next": "^15.0.0",
    "react": "^18.3.0",
    "react-dom": "^18.3.0",
    "@tanstack/react-query": "^5.56.0",
    "@tanstack/react-table": "^8.20.0",
    "zustand": "^4.5.0",
    "react-hook-form": "^7.53.0",
    "@hookform/resolvers": "^3.9.0",
    "zod": "^3.23.0",
    "framer-motion": "^11.5.0",
    "recharts": "^2.12.0",
    "lucide-react": "^0.445.0",
    "next-intl": "^3.19.0",
    "clsx": "^2.1.0",
    "tailwind-merge": "^2.5.0",
    "@tiptap/react": "^2.7.0",
    "@tiptap/starter-kit": "^2.7.0"
  },
  "devDependencies": {
    "@types/node": "^22.5.0",
    "@types/react": "^18.3.0",
    "@types/react-dom": "^18.3.0",
    "typescript": "^5.5.0",
    "tailwindcss": "^4.0.0",
    "@tailwindcss/postcss": "^4.0.0",
    "postcss": "^8.4.0",
    "eslint": "^9.9.0",
    "eslint-config-next": "^15.0.0",
    "vitest": "^2.0.0",
    "@testing-library/react": "^16.0.0",
    "playwright": "^1.47.0"
  }
}
'@
Set-Content -Path (Join-Path $WebRoot "package.json") -Value $webPackageJson -Encoding UTF8

# ---------------------------------------------------------------
# tsconfig.json
# ---------------------------------------------------------------
$tsConfig = @'
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": false,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "baseUrl": ".",
    "paths": {
      "@/*": ["./*"],
      "@saachi/ui": ["../../packages/ui/src"],
      "@saachi/ui/*": ["../../packages/ui/src/*"],
      "@saachi/api-client": ["../../packages/api-client/src"],
      "@saachi/api-client/*": ["../../packages/api-client/src/*"],
      "@saachi/utils": ["../../packages/utils/src"],
      "@saachi/utils/*": ["../../packages/utils/src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
'@
Set-Content -Path (Join-Path $WebRoot "tsconfig.json") -Value $tsConfig -Encoding UTF8

# ---------------------------------------------------------------
# next.config.js
# ---------------------------------------------------------------
$nextConfig = @'
/** @type {import("next").NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ["@saachi/ui", "@saachi/api-client", "@saachi/utils"],
  images: {
    remotePatterns: [
      { protocol: "https", hostname: "**.cloudfront.net" },
      { protocol: "https", hostname: "res.cloudinary.com" }
    ]
  },
  async rewrites() {
    return [
      {
        source: "/api/proxy/:path*",
        destination: `${process.env.NEXT_PUBLIC_API_URL}/:path*`
      }
    ];
  }
};

module.exports = nextConfig;
'@
Set-Content -Path (Join-Path $WebRoot "next.config.js") -Value $nextConfig -Encoding UTF8

# ---------------------------------------------------------------
# postcss.config.mjs (Tailwind v4)
# ---------------------------------------------------------------
$postcssConfig = @'
export default {
  plugins: {
    "@tailwindcss/postcss": {}
  }
};
'@
Set-Content -Path (Join-Path $WebRoot "postcss.config.mjs") -Value $postcssConfig -Encoding UTF8

# ---------------------------------------------------------------
# .env.local
# ---------------------------------------------------------------
$envLocal = @'
NEXT_PUBLIC_API_URL=http://localhost:4000
NEXT_PUBLIC_SITE_URL=http://localhost:3000
'@
Set-Content -Path (Join-Path $WebRoot ".env.local") -Value $envLocal -Encoding UTF8

# ---------------------------------------------------------------
# app/globals.css (Tailwind v4 + design tokens placeholder)
# ---------------------------------------------------------------
$globalsCss = @'
@import "tailwindcss";

:root {
  --blue-50:  #EFF6FF;
  --blue-500: #3B82F6;
  --blue-600: #2563EB;
  --cyan-400: #22D3EE;

  --surface-bg:      #F8FAFC;
  --surface-card:    #FFFFFF;
  --text-primary:    #0F172A;
  --text-secondary:  #475569;

  --gradient-primary: linear-gradient(135deg, #2563EB 0%, #0EA5E9 50%, #22D3EE 100%);
}

[data-theme="dark"] {
  --surface-bg:   #0B1120;
  --surface-card: #0F172A;
  --text-primary: #F1F5F9;
  --text-secondary: #94A3B8;
}

* {
  box-sizing: border-box;
}

body {
  background: var(--surface-bg);
  color: var(--text-primary);
  font-family: "Inter", -apple-system, "Segoe UI", Roboto, sans-serif;
}
'@
Set-Content -Path (Join-Path $WebRoot "app\globals.css") -Value $globalsCss -Encoding UTF8

# ---------------------------------------------------------------
# app/providers.tsx (TanStack Query provider)
# ---------------------------------------------------------------
$providersTsx = @'
"use client";

import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

export function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 30 * 1000,
            refetchOnWindowFocus: true,
            retry: 1
          }
        }
      })
  );

  return <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>;
}
'@
Set-Content -Path (Join-Path $WebRoot "app\providers.tsx") -Value $providersTsx -Encoding UTF8

# ---------------------------------------------------------------
# app/layout.tsx
# ---------------------------------------------------------------
$layoutTsx = @'
import type { Metadata } from "next";
import { Providers } from "./providers";
import "./globals.css";

export const metadata: Metadata = {
  title: "Saachi AI - Learn Practical AI Skills",
  description: "A skills-first marketplace to learn and monetize practical AI application skills."
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
'@
Set-Content -Path (Join-Path $WebRoot "app\layout.tsx") -Value $layoutTsx -Encoding UTF8

# ---------------------------------------------------------------
# app/(marketing)/page.tsx - homepage stub
# ---------------------------------------------------------------
$homepageTsx = @'
export default function HomePage() {
  return (
    <main style={{ padding: "80px 24px", textAlign: "center" }}>
      <h1 style={{ fontSize: "48px", fontWeight: 700 }}>Saachi AI</h1>
      <p style={{ color: "var(--text-secondary)", marginTop: "16px" }}>
        Learn practical AI skills. Build real things. Get paid to teach what you know.
      </p>
    </main>
  );
}
'@
Set-Content -Path (Join-Path $WebRoot "app\(marketing)\page.tsx") -Value $homepageTsx -Encoding UTF8

# ---------------------------------------------------------------
# middleware.ts (auth + role guard stub)
# ---------------------------------------------------------------
$middlewareTs = @'
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

const LEARNER_PREFIX = "/dashboard";
const INSTRUCTOR_PREFIX = "/instructor";

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const sessionCookie = request.cookies.get("saachi_session");

  const isProtected =
    pathname.startsWith(LEARNER_PREFIX) || pathname.startsWith(INSTRUCTOR_PREFIX);

  if (isProtected && !sessionCookie) {
    const loginUrl = new URL("/login", request.url);
    loginUrl.searchParams.set("redirect", pathname);
    return NextResponse.redirect(loginUrl);
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/dashboard/:path*", "/instructor/:path*"]
};
'@
Set-Content -Path (Join-Path $WebRoot "middleware.ts") -Value $middlewareTs -Encoding UTF8

# ---------------------------------------------------------------
# .eslintrc.json
# ---------------------------------------------------------------
$eslintrc = @'
{
  "extends": "next/core-web-vitals"
}
'@
Set-Content -Path (Join-Path $WebRoot ".eslintrc.json") -Value $eslintrc -Encoding UTF8

Write-Host ""
Write-Host "=== Step 2 Complete ===" -ForegroundColor Cyan
Write-Host "apps/web scaffolded: package.json, tsconfig, next.config, tailwind (v4), globals.css," -ForegroundColor Green
Write-Host "providers.tsx, layout.tsx, homepage stub, middleware.ts, eslint config." -ForegroundColor Green
Write-Host ""
Write-Host "Now run inside apps/web:" -ForegroundColor Yellow
Write-Host "  pnpm install" -ForegroundColor White
Write-Host ""
Write-Host "NEXT STEP: run script 03-init-admin-app.ps1 to scaffold apps/admin." -ForegroundColor Yellow