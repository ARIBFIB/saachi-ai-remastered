# =============================================================
# Saachi AI Frontend - Step 1: Monorepo Scaffold
# Creates: apps/web, apps/admin, packages/ui, packages/api-client,
#          packages/config, packages/utils + root config files
# =============================================================

$ProjectRoot = "D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2"

Write-Host "=== Saachi AI Frontend Scaffold - Step 1 ===" -ForegroundColor Cyan
Write-Host "Target: $ProjectRoot" -ForegroundColor Yellow

if (-not (Test-Path $ProjectRoot)) {
    New-Item -ItemType Directory -Path $ProjectRoot -Force | Out-Null
    Write-Host "Created project root." -ForegroundColor Green
} else {
    Write-Host "Project root already exists, continuing..." -ForegroundColor Yellow
}

Set-Location $ProjectRoot

# ---------------------------------------------------------------
# Folder structure
# ---------------------------------------------------------------
$folders = @(
    "apps\web\app\(marketing)\courses",
    "apps\web\app\(marketing)\instructors",
    "apps\web\app\(marketing)\categories",
    "apps\web\app\(marketing)\legal",
    "apps\web\app\(auth)\login",
    "apps\web\app\(auth)\register",
    "apps\web\app\(auth)\forgot-password",
    "apps\web\app\(auth)\reset-password",
    "apps\web\app\(auth)\verify-email",
    "apps\web\app\(learner)\dashboard",
    "apps\web\app\(learner)\my-courses",
    "apps\web\app\(learner)\learn",
    "apps\web\app\(learner)\certificates",
    "apps\web\app\(learner)\wishlist",
    "apps\web\app\(learner)\cart",
    "apps\web\app\(learner)\checkout",
    "apps\web\app\(learner)\orders",
    "apps\web\app\(learner)\mentorship",
    "apps\web\app\(learner)\community",
    "apps\web\app\(learner)\notifications",
    "apps\web\app\(learner)\settings",
    "apps\web\app\(instructor)\instructor\dashboard",
    "apps\web\app\(instructor)\instructor\courses",
    "apps\web\app\(instructor)\instructor\analytics",
    "apps\web\app\(instructor)\instructor\earnings",
    "apps\web\app\(instructor)\instructor\payouts",
    "apps\web\app\(instructor)\instructor\promotions",
    "apps\web\app\(instructor)\instructor\mentorship",
    "apps\web\app\(instructor)\instructor\reviews",
    "apps\web\app\(instructor)\instructor\students",
    "apps\web\app\(instructor)\instructor\settings",
    "apps\web\public",
    "apps\web\lib",
    "apps\web\hooks",
    "apps\web\styles",

    "apps\admin\app\login",
    "apps\admin\app\dashboard",
    "apps\admin\app\users",
    "apps\admin\app\courses\moderation",
    "apps\admin\app\courses\catalog",
    "apps\admin\app\finance\transactions",
    "apps\admin\app\finance\payouts",
    "apps\admin\app\finance\refunds",
    "apps\admin\app\marketing\banners",
    "apps\admin\app\marketing\coupons",
    "apps\admin\app\moderation\content",
    "apps\admin\app\support\tickets",
    "apps\admin\app\analytics",
    "apps\admin\app\settings\platform",
    "apps\admin\app\settings\roles",
    "apps\admin\app\logs\audit",
    "apps\admin\public",
    "apps\admin\lib",

    "packages\ui\src\components",
    "packages\ui\src\styles",
    "packages\api-client\src\hooks",
    "packages\api-client\src\types",
    "packages\config",
    "packages\utils\src\schemas",
    "packages\utils\src\formatting"
)

foreach ($f in $folders) {
    $full = Join-Path $ProjectRoot $f
    if (-not (Test-Path $full)) {
        New-Item -ItemType Directory -Path $full -Force | Out-Null
    }
}
Write-Host "Folder structure created ($($folders.Count) folders)." -ForegroundColor Green

# ---------------------------------------------------------------
# Root package.json
# ---------------------------------------------------------------
$rootPackageJson = @'
{
  "name": "saachi-ai-frontend",
  "private": true,
  "packageManager": "pnpm@9.0.0",
  "scripts": {
    "dev": "turbo run dev",
    "dev:web": "turbo run dev --filter=web",
    "dev:admin": "turbo run dev --filter=admin",
    "build": "turbo run build",
    "lint": "turbo run lint",
    "type-check": "turbo run type-check",
    "test": "turbo run test"
  },
  "devDependencies": {
    "turbo": "^2.1.0",
    "typescript": "^5.5.0",
    "prettier": "^3.3.0"
  }
}
'@
Set-Content -Path (Join-Path $ProjectRoot "package.json") -Value $rootPackageJson -Encoding UTF8

# ---------------------------------------------------------------
# pnpm-workspace.yaml
# ---------------------------------------------------------------
$pnpmWorkspace = @'
packages:
  - "apps/*"
  - "packages/*"
'@
Set-Content -Path (Join-Path $ProjectRoot "pnpm-workspace.yaml") -Value $pnpmWorkspace -Encoding UTF8

# ---------------------------------------------------------------
# turbo.json
# ---------------------------------------------------------------
$turboJson = @'
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "dev": {
      "cache": false,
      "persistent": true
    },
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "!.next/cache/**", "dist/**"]
    },
    "lint": {
      "dependsOn": ["^build"]
    },
    "type-check": {
      "dependsOn": ["^build"]
    },
    "test": {
      "dependsOn": ["^build"]
    }
  }
}
'@
Set-Content -Path (Join-Path $ProjectRoot "turbo.json") -Value $turboJson -Encoding UTF8

# ---------------------------------------------------------------
# .gitignore
# ---------------------------------------------------------------
$gitignore = @'
node_modules
.next
dist
.env
.env.local
.turbo
*.log
.DS_Store
coverage
'@
Set-Content -Path (Join-Path $ProjectRoot ".gitignore") -Value $gitignore -Encoding UTF8

# ---------------------------------------------------------------
# .env.example (root reference, real apps get their own later)
# ---------------------------------------------------------------
$envExample = @'
NEXT_PUBLIC_API_URL=http://localhost:4000
NEXT_PUBLIC_SITE_URL=http://localhost:3000
NEXT_PUBLIC_ADMIN_URL=http://localhost:3001
'@
Set-Content -Path (Join-Path $ProjectRoot ".env.example") -Value $envExample -Encoding UTF8

Write-Host ""
Write-Host "=== Step 1 Complete ===" -ForegroundColor Cyan
Write-Host "Created: package.json, pnpm-workspace.yaml, turbo.json, .gitignore, .env.example" -ForegroundColor Green
Write-Host "Folder skeleton ready for apps/web, apps/admin, and shared packages." -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEP: run script 02-init-web-app.ps1 to scaffold the Next.js web app." -ForegroundColor Yellow