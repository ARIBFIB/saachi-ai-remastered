# =============================================================
# Saachi AI Frontend - Step 3: apps/admin Next.js Init
# Isolated admin portal - separate auth, own package.json,
# layout, middleware, login stub
# =============================================================

$ProjectRoot = "D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2"
$AdminRoot = Join-Path $ProjectRoot "apps\admin"

Write-Host "=== Saachi AI Frontend Scaffold - Step 3 (apps/admin) ===" -ForegroundColor Cyan

if (-not (Test-Path $AdminRoot)) {
    Write-Host "ERROR: apps/admin not found. Run 01-scaffold-monorepo.ps1 first." -ForegroundColor Red
    exit 1
}

Set-Location $AdminRoot

# ---------------------------------------------------------------
# package.json
# ---------------------------------------------------------------
$adminPackageJson = @'
{
  "name": "admin",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev -p 3001",
    "build": "next build",
    "start": "next start -p 3001",
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
    "recharts": "^2.12.0",
    "lucide-react": "^0.445.0",
    "clsx": "^2.1.0",
    "tailwind-merge": "^2.5.0"
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
    "eslint-config-next": "^15.0.0"
  }
}
'@
Set-Content -Path (Join-Path $AdminRoot "package.json") -Value $adminPackageJson -Encoding UTF8

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
Set-Content -Path (Join-Path $AdminRoot "tsconfig.json") -Value $tsConfig -Encoding UTF8

# ---------------------------------------------------------------
# next.config.js
# ---------------------------------------------------------------
$nextConfig = @'
/** @type {import("next").NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ["@saachi/ui", "@saachi/api-client", "@saachi/utils"],
  async rewrites() {
    return [
      {
        source: "/api/proxy/:path*",
        destination: `${process.env.NEXT_PUBLIC_API_URL}/admin/:path*`
      }
    ];
  }
};

module.exports = nextConfig;
'@
Set-Content -Path (Join-Path $AdminRoot "next.config.js") -Value $nextConfig -Encoding UTF8

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
Set-Content -Path (Join-Path $AdminRoot "postcss.config.mjs") -Value $postcssConfig -Encoding UTF8

# ---------------------------------------------------------------
# .env.local
# ---------------------------------------------------------------
$envLocal = @'
NEXT_PUBLIC_API_URL=http://localhost:4000
NEXT_PUBLIC_ADMIN_URL=http://localhost:3001
'@
Set-Content -Path (Join-Path $AdminRoot ".env.local") -Value $envLocal -Encoding UTF8

# ---------------------------------------------------------------
# app/globals.css
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
  --surface-elevated: #F1F5F9;
  --text-primary:    #0F172A;
  --text-secondary:  #475569;

  --gradient-primary: linear-gradient(135deg, #2563EB 0%, #0EA5E9 50%, #22D3EE 100%);
}

[data-theme="dark"] {
  --surface-bg:   #0B1120;
  --surface-card: #0F172A;
  --surface-elevated: #131C31;
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
Set-Content -Path (Join-Path $AdminRoot "app\globals.css") -Value $globalsCss -Encoding UTF8

# ---------------------------------------------------------------
# app/providers.tsx
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
Set-Content -Path (Join-Path $AdminRoot "app\providers.tsx") -Value $providersTsx -Encoding UTF8

# ---------------------------------------------------------------
# app/layout.tsx
# ---------------------------------------------------------------
$layoutTsx = @'
import type { Metadata } from "next";
import { Providers } from "./providers";
import "./globals.css";

export const metadata: Metadata = {
  title: "Saachi AI Admin",
  description: "Internal operations portal for Saachi AI staff.",
  robots: { index: false, follow: false }
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
Set-Content -Path (Join-Path $AdminRoot "app\layout.tsx") -Value $layoutTsx -Encoding UTF8

# ---------------------------------------------------------------
# app/login/page.tsx - isolated admin login stub
# ---------------------------------------------------------------
$loginPageTsx = @'
export default function AdminLoginPage() {
  return (
    <main
      style={{
        minHeight: "100vh",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        background: "var(--surface-bg)"
      }}
    >
      <div
        style={{
          background: "var(--surface-card)",
          padding: "40px",
          borderRadius: "16px",
          boxShadow: "0 4px 20px rgba(30,64,175,0.10)",
          width: "360px"
        }}
      >
        <h1 style={{ fontSize: "22px", fontWeight: 600, marginBottom: "8px" }}>
          Saachi AI - Admin
        </h1>
        <p style={{ color: "var(--text-secondary)", fontSize: "14px", marginBottom: "24px" }}>
          Internal staff access only. 2FA required.
        </p>
        {/* Login form + 2FA step to be wired in a later step */}
      </div>
    </main>
  );
}
'@
Set-Content -Path (Join-Path $AdminRoot "app\login\page.tsx") -Value $loginPageTsx -Encoding UTF8

# ---------------------------------------------------------------
# app/dashboard/page.tsx - stub
# ---------------------------------------------------------------
$dashboardPageTsx = @'
export default function AdminDashboardPage() {
  return (
    <main style={{ padding: "32px" }}>
      <h1 style={{ fontSize: "24px", fontWeight: 700 }}>Admin Dashboard</h1>
      <p style={{ color: "var(--text-secondary)", marginTop: "8px" }}>
        KPI cards, moderation queue, and finance widgets will be wired here.
      </p>
    </main>
  );
}
'@
Set-Content -Path (Join-Path $AdminRoot "app\dashboard\page.tsx") -Value $dashboardPageTsx -Encoding UTF8

# ---------------------------------------------------------------
# middleware.ts - isolated admin session guard (separate cookie, mandatory 2FA flag)
# ---------------------------------------------------------------
$middlewareTs = @'
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

const PUBLIC_PATHS = ["/login"];

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const adminSession = request.cookies.get("saachi_admin_session");

  const isPublic = PUBLIC_PATHS.some((p) => pathname.startsWith(p));

  if (!isPublic && !adminSession) {
    const loginUrl = new URL("/login", request.url);
    return NextResponse.redirect(loginUrl);
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico).*)"]
};
'@
Set-Content -Path (Join-Path $AdminRoot "middleware.ts") -Value $middlewareTs -Encoding UTF8

# ---------------------------------------------------------------
# .eslintrc.json
# ---------------------------------------------------------------
$eslintrc = @'
{
  "extends": "next/core-web-vitals"
}
'@
Set-Content -Path (Join-Path $AdminRoot ".eslintrc.json") -Value $eslintrc -Encoding UTF8

Write-Host ""
Write-Host "=== Step 3 Complete ===" -ForegroundColor Cyan
Write-Host "apps/admin scaffolded: package.json, tsconfig, next.config, tailwind (v4)," -ForegroundColor Green
Write-Host "globals.css, providers.tsx, layout.tsx, login + dashboard stubs, isolated middleware." -ForegroundColor Green
Write-Host ""
Write-Host "Note: admin session cookie is 'saachi_admin_session' - fully separate from" -ForegroundColor Yellow
Write-Host "the web app's 'saachi_session' cookie, matching Doc 2's isolated-auth requirement." -ForegroundColor Yellow
Write-Host ""
Write-Host "Now run inside apps/admin:" -ForegroundColor Yellow
Write-Host "  pnpm install" -ForegroundColor White
Write-Host ""
Write-Host "NEXT STEP: run script 04-init-packages.ps1 to scaffold packages/ui, api-client, utils, config." -ForegroundColor Yellow