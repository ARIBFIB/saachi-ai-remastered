# Step3-ApplyBrandGradient.ps1
# Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2
#
# Wires the new brand tokens (from Step 2) into the actual UI:
#   1. Adds a "brand" variant to the shared <Button> component
#      (bg-gradient-brand, per the design-system skill).
#   2. Updates the homepage hero <h1> so the second line uses the
#      gradient text treatment (text-gradient-brand).
#   3. Updates the primary CTA buttons on the homepage + SiteHeader
#      to use the new "brand" variant instead of the default gold fill.
#
# Every edit is done with an exact string match. If a file has changed
# since the last export and a match isn't found, that specific edit is
# SKIPPED with a clear message -- nothing is guessed or forced, so you
# never end up with a half-broken file.

$ErrorActionPreference = "Stop"
$root = Get-Location

$buttonPath  = Join-Path $root "packages\ui\src\components\Button.tsx"
$headerPath  = Join-Path $root "apps\web\app\_components\SiteHeader.tsx"
$homePath    = Join-Path $root "apps\web\app\(marketing)\page.tsx"

foreach ($p in @($buttonPath, $headerPath, $homePath)) {
    if (-not (Test-Path -LiteralPath $p)) {
        Write-Error "File not found: $p`nRun this script from the SAI2 root, and confirm the path still matches your project."
        exit 1
    }
}

# ---------------------------------------------------------------------------
# Backups
# ---------------------------------------------------------------------------
$backupDir = Join-Path $root "theme-migration-backup\step3"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Copy-Item -LiteralPath $buttonPath -Destination (Join-Path $backupDir "Button.tsx.bak") -Force
Copy-Item -LiteralPath $headerPath -Destination (Join-Path $backupDir "SiteHeader.tsx.bak") -Force
Copy-Item -LiteralPath $homePath -Destination (Join-Path $backupDir "page.tsx.bak") -Force
Write-Host "Backups saved to: $backupDir"
Write-Host ""

function Try-Replace {
    param(
        [string]$FilePath,
        [string]$OldStr,
        [string]$NewStr,
        [string]$Label
    )
    $content = Get-Content -LiteralPath $FilePath -Raw
    if ($content -match [regex]::Escape($OldStr)) {
        $count = ([regex]::Matches($content, [regex]::Escape($OldStr))).Count
        if ($count -ne 1) {
            Write-Host "SKIPPED [$Label] -- match found $count times (need exactly 1), left unchanged to avoid a wrong edit."
            return
        }
        $updated = $content.Replace($OldStr, $NewStr)
        Set-Content -LiteralPath $FilePath -Value $updated -Encoding UTF8 -NoNewline
        Write-Host "OK [$Label] -- $FilePath"
    } else {
        Write-Host "SKIPPED [$Label] -- exact text not found in $FilePath (file may have changed). No edit made."
    }
}

# ---------------------------------------------------------------------------
# 1. Button.tsx -- add a "brand" gradient variant
# ---------------------------------------------------------------------------
Try-Replace -FilePath $buttonPath `
  -OldStr 'danger: "bg-error text-white hover:brightness-90"' `
  -NewStr @"
danger: "bg-error text-white hover:brightness-90",
    brand: "bg-gradient-brand text-white hover:brightness-110 shadow-[0_0_40px_-12px_rgba(124,58,237,0.5)]"
"@ `
  -Label "Button.tsx: add brand variant"

# ---------------------------------------------------------------------------
# 2. SiteHeader.tsx -- "Sign up" CTA uses the brand gradient
# ---------------------------------------------------------------------------
Try-Replace -FilePath $headerPath `
  -OldStr '<Link href="/register">
                <Button size="sm">Sign up</Button>
              </Link>' `
  -NewStr '<Link href="/register">
                <Button size="sm" variant="brand">Sign up</Button>
              </Link>' `
  -Label "SiteHeader.tsx: desktop Sign up button"

Try-Replace -FilePath $headerPath `
  -OldStr '<Link href="/register" className="flex-1">
                    <Button size="sm" className="w-full">
                      Sign up
                    </Button>
                  </Link>' `
  -NewStr '<Link href="/register" className="flex-1">
                    <Button size="sm" variant="brand" className="w-full">
                      Sign up
                    </Button>
                  </Link>' `
  -Label "SiteHeader.tsx: mobile Sign up button"

# ---------------------------------------------------------------------------
# 3. Homepage hero -- gradient headline + brand CTA
# ---------------------------------------------------------------------------
Try-Replace -FilePath $homePath `
  -OldStr '<h1 className="font-display text-[38px] font-bold leading-[1.1] text-ink md:text-[52px]">
            Learn practical AI skills. Sell what you know.
          </h1>' `
  -NewStr '<h1 className="font-display text-[38px] font-bold leading-[1.05] text-ink md:text-[64px]">
            Learn AI Skills.
            <br />
            <span className="text-gradient-brand">Build Real Projects.</span>
          </h1>' `
  -Label "page.tsx: gradient hero headline"

Try-Replace -FilePath $homePath `
  -OldStr '<Link href="/courses">
              <Button size="lg">Browse courses</Button>
            </Link>' `
  -NewStr '<Link href="/courses">
              <Button size="lg" variant="brand">Browse courses</Button>
            </Link>' `
  -Label "page.tsx: primary hero CTA"

Write-Host ""
Write-Host "Step 3 finished. Review the OK/SKIPPED lines above."
Write-Host "For anything SKIPPED, paste the current content of that file"
Write-Host "and I will give you a follow-up script targeted at what's"
Write-Host "actually there now."
Write-Host ""
Write-Host "Restart npm run dev and check the homepage hero + navbar Sign up button."