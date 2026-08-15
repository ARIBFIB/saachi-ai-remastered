# Update-GalleryImages.ps1
# Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Content
    )
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

$root = (Get-Location).Path
$webApp = Join-Path -Path $root -ChildPath "apps\web"
$galleryTrailPath = Join-Path -Path $webApp -ChildPath "components\ui\gallery-cursor-trail.tsx"

if (-not (Test-Path $galleryTrailPath)) {
    Write-Host "ERROR: $galleryTrailPath not found. Run from SAI2 repo root." -ForegroundColor Red
    exit 1
}

$content = [System.IO.File]::ReadAllText($galleryTrailPath)

$oldCardsBlock = @'
export const GALLERY_CARDS: GalleryCard[] = [
  {
    label: "News",
    src: "https://images.unsplash.com/photo-1495020689067-958852a7765e?q=80&h=800&w=800&auto=format&fit=crop",
    href: "/about",
    buttonLabel: "Read news"
  },
  {
    label: "Community",
    src: "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?q=80&h=800&w=800&auto=format&fit=crop",
    href: "/mentorship",
    buttonLabel: "Join community"
  },
  {
    label: "Courses",
    src: "https://images.unsplash.com/photo-1555949963-aa79dcee981c?q=80&h=800&w=800&auto=format&fit=crop",
    href: "/courses",
    buttonLabel: "Browse courses"
  },
  {
    label: "Certificate",
    src: "https://images.unsplash.com/photo-1546410531-bb4caa6b424d?q=80&h=800&w=800&auto=format&fit=crop",
    href: "/certificates",
    buttonLabel: "Get certified"
  }
];
'@

$newCardsBlock = @'
export const GALLERY_CARDS: GalleryCard[] = [
  {
    label: "News",
    src: "https://images.pexels.com/photos/3944425/pexels-photo-3944425.jpeg?cs=srgb&dl=pexels-cottonbro-3944425.jpg&fm=jpg",
    href: "/about",
    buttonLabel: "Read news"
  },
  {
    label: "Community",
    src: "https://benbellabooks.com/wp-content/uploads/2021/01/doing-ai-1.jpg",
    href: "/mentorship",
    buttonLabel: "Join community"
  },
  {
    label: "Courses",
    src: "https://verticalinstitute.com/wp-content/uploads/2025/12/why-opt-for-tech-course-in-singapore.webp",
    href: "/courses",
    buttonLabel: "Browse courses"
  },
  {
    label: "Certificate",
    src: "https://graphicsfamily.com/wp-content/uploads/edd/2021/01/Vertical-Modern-Certificate-of-Appreciation.jpg",
    href: "/certificates",
    buttonLabel: "Get certified"
  }
];
'@

if ($content.Contains($oldCardsBlock)) {
    $content = $content.Replace($oldCardsBlock, $newCardsBlock)
    Write-Host "Updated all 4 gallery card images." -ForegroundColor Green
} elseif ($content -match [regex]::Escape('verticalinstitute.com')) {
    Write-Host "Images already updated, skipping." -ForegroundColor Yellow
} else {
    Write-Host "ERROR: GALLERY_CARDS block not found in expected form - check file manually." -ForegroundColor Red
    exit 1
}

Write-Utf8NoBom -Path $galleryTrailPath -Content $content
Write-Host "Updated: $galleryTrailPath" -ForegroundColor Green

Write-Host "`nDone. cd apps\web ; pnpm dev to verify." -ForegroundColor Cyan