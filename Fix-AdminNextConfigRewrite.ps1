<#
  Fix-AdminNextConfigRewrite.ps1
  Adds a safe fallback for NEXT_PUBLIC_API_URL in apps/admin/next.config.js
  so a missing env var never breaks the Vercel build again.

  Usage:
    PS D:\...\SAI2> .\Fix-AdminNextConfigRewrite.ps1
#>

param(
    [string]$ProjectRoot = (Get-Location).Path
)

$configPath = Join-Path $ProjectRoot "apps\admin\next.config.js"


if (-not (Test-Path $configPath)) {
    Write-Host "ERROR: $configPath not found." -ForegroundColor Red
    exit 1
}

Copy-Item $configPath "$configPath.bak" -Force

$newConfig = @'
/** @type {import("next").NextConfig} */
const API_URL = process.env.NEXT_PUBLIC_API_URL || "https://api.saachi.ai";

const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ["@saachi/ui", "@saachi/api-client", "@saachi/utils", "@saachi/store"],
  async rewrites() {
    return [
      {
        source: "/api/proxy/:path*",
        destination: `${API_URL}/admin/:path*`
      }
    ];
  }
};

module.exports = nextConfig;
'@

Set-Content -LiteralPath $configPath -Value $newConfig -NoNewline
Write-Host "[OK] apps\admin\next.config.js patched with a safe fallback for NEXT_PUBLIC_API_URL." -ForegroundColor Green
Write-Host "Backup saved at $configPath.bak" -ForegroundColor Green
Write-Host ""
Write-Host "Now commit and push this change, then redeploy on Vercel." -ForegroundColor Cyan
Write-Host "Also still add NEXT_PUBLIC_API_URL in Vercel's Environment Variables with your real backend URL." -ForegroundColor Cyan