# fix-step3-heredoc.ps1
# Run from: SAI2 root folder — fixes the broken here-string in step3 script

$path = ".\step3-course-player-certificates-settings.ps1"
$content = Get-Content -Path $path -Raw

$old = @"
  const cartCount = useCartStore((s) => s.items.length);
  const [mobileOpen, setMobileOpen] = useState(false);'@ ``
"@

# The broken block ends with: ...useState(false);'@ ` (backtick continuation) then -Label line
$brokenPattern = "  const cartCount = useCartStore((s) => s.items.length);`r`n  const [mobileOpen, setMobileOpen] = useState(false);'@ ``"

if ($content.Contains($brokenPattern)) {
    $fixedBlock = "  const cartCount = useCartStore((s) => s.items.length);`r`n  const [mobileOpen, setMobileOpen] = useState(false);`r`n'@ ``"
    $content = $content.Replace($brokenPattern, $fixedBlock)
    [System.IO.File]::WriteAllText((Resolve-Path $path), $content, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "Fixed the here-string terminator. Now run: .\step3-course-player-certificates-settings.ps1" -ForegroundColor Green
} else {
    Write-Host "Pattern not found automatically. Use the manual fix below instead." -ForegroundColor Yellow
}