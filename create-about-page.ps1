<#
================================================================================
  create-about-page.ps1
  Scaffolds the "About Us" page for apps/web (SAI2).

  Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2

  Notes:
  - Colors use CSS variables from lib/design-system/tokens.ts (e.g.
    var(--token-color-primary)) so theme changes stay driven by tokens.ts.
  - Reuses existing Header and CompactFooter components for consistency.
================================================================================
#>

$ErrorActionPreference = "Stop"

$webRoot = Join-Path $PSScriptRoot "apps\web"
if (-not (Test-Path $webRoot)) {
    Write-Error "Could not find apps\web under $PSScriptRoot. Run this script from the SAI2 repo root."
}

function New-Dir($path) {
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}

function Write-File($path, [string]$content) {
    New-Dir (Split-Path $path -Parent)
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
    Write-Host "  [written] $path"
}

Write-Host "`nScaffolding About Us page..." -ForegroundColor Cyan

# ------------------------------------------------------------------------
# 1. components/about/AboutHero.tsx
# ------------------------------------------------------------------------
$aboutHero = @'
import Image from "next/image";

interface AboutHeroProps {
  heading: string;
  description: string;
  image: string;
}

export function AboutHero({ heading, description, image }: AboutHeroProps) {
  return (
    <section className="flex w-full items-center gap-10">
      <div className="flex flex-1 flex-col gap-6">
        <h1 className="max-w-[572px] text-5xl font-bold leading-[52.8px] text-[var(--token-color-ink)]">
          {heading}
        </h1>
        <p className="max-w-[572px] text-lg leading-7 text-[var(--token-color-inkSoft)]">
          {description}
        </p>
      </div>

      <div className="relative h-96 flex-1 overflow-hidden rounded-2xl shadow-lg">
        <Image src={image} alt="About Saachi AI" fill sizes="572px" className="object-cover" />
        <div className="absolute inset-0 bg-gradient-to-br from-[var(--token-color-primary)]/20 to-transparent" />
      </div>
    </section>
  );
}
'@
Write-File (Join-Path $webRoot "components\about\AboutHero.tsx") $aboutHero

# ------------------------------------------------------------------------
# 2. components/about/CoreDirectivesGrid.tsx
# ------------------------------------------------------------------------
$coreDirectivesGrid = @'
import type { LucideIcon } from "lucide-react";
import { Rocket, Shapes, BrainCircuit, ShieldCheck, Zap } from "lucide-react";

interface Value {
  icon: LucideIcon;
  iconColor: string;
  title: string;
  description: string;
}

const values: Value[] = [
  {
    icon: Shapes,
    iconColor: "var(--token-color-success)",
    title: "Structural Clarity",
    description: "We design systems that organize chaos. Learning is complex; the interface shouldn't be.",
  },
  {
    icon: BrainCircuit,
    iconColor: "var(--token-color-primary)",
    title: "Predictive Insight",
    description: "Anticipating learner bottlenecks before they happen using behavioral data models.",
  },
  {
    icon: ShieldCheck,
    iconColor: "var(--token-color-error)",
    title: "Trust by Design",
    description: "Professional environments require verifiable accuracy and data integrity at every level.",
  },
  {
    icon: Zap,
    iconColor: "var(--token-color-textMuted)",
    title: "Adaptive Velocity",
    description: "Moving at the speed of modern tech without sacrificing foundational knowledge.",
  },
];

interface CoreDirectivesGridProps {
  missionTitle: string;
  missionBody: string;
}

export function CoreDirectivesGrid({ missionTitle, missionBody }: CoreDirectivesGridProps) {
  return (
    <section className="flex w-full flex-col gap-6">
      <h2 className="text-3xl font-bold leading-10 text-[var(--token-color-ink)]">Our Core Directives</h2>

      <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
        <div className="flex flex-col justify-center gap-2 rounded-2xl border border-[var(--token-color-border)]/30 bg-[var(--token-color-surface)] p-10 shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)] md:col-span-2">
          <Rocket className="mb-2 h-[30px] w-[30px] text-[var(--token-color-primary)]" />
          <h3 className="text-2xl font-semibold leading-8 text-[var(--token-color-ink)]">{missionTitle}</h3>
          <p className="max-w-4xl text-base leading-6 text-[var(--token-color-inkSoft)]">{missionBody}</p>
        </div>

        {values.map(({ icon: Icon, iconColor, title, description }) => (
          <div
            key={title}
            className="flex flex-col gap-1 rounded-2xl border border-[var(--token-color-border)]/30 bg-[var(--token-color-surface)] p-6 shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]"
          >
            <Icon className="h-6 w-6" style={{ color: iconColor }} />
            <h4 className="pt-1 text-lg font-semibold leading-7 text-[var(--token-color-ink)]">{title}</h4>
            <p className="text-sm leading-5 text-[var(--token-color-inkSoft)]">{description}</p>
          </div>
        ))}
      </div>
    </section>
  );
}
'@
Write-File (Join-Path $webRoot "components\about\CoreDirectivesGrid.tsx") $coreDirectivesGrid

# ------------------------------------------------------------------------
# 3. components/about/TeamGrid.tsx
# ------------------------------------------------------------------------
$teamGrid = @'
import Image from "next/image";

export interface TeamMember {
  name: string;
  role: string;
  avatar: string;
}

interface TeamGridProps {
  heading: string;
  members: TeamMember[];
}

export function TeamGrid({ heading, members }: TeamGridProps) {
  return (
    <section className="flex w-full flex-col gap-6">
      <h2 className="text-3xl font-bold leading-10 text-[var(--token-color-ink)]">{heading}</h2>

      <div className="flex justify-center gap-6">
        {members.map((member) => (
          <div key={member.name} className="flex flex-1 flex-col items-center">
            <span className="relative mb-4 block h-48 w-48 overflow-hidden rounded-full shadow-sm ring-4 ring-[var(--token-color-surfaceAlt)]">
              <Image src={member.avatar} alt={member.name} fill sizes="192px" className="object-cover" />
            </span>
            <h3 className="text-xl font-semibold leading-7 text-[var(--token-color-ink)]">{member.name}</h3>
            <p className="pt-1 text-sm font-semibold tracking-wide text-[var(--token-color-primary)]">
              {member.role}
            </p>
          </div>
        ))}
      </div>
    </section>
  );
}
'@
Write-File (Join-Path $webRoot "components\about\TeamGrid.tsx") $teamGrid

# ------------------------------------------------------------------------
# 4. app/(marketing)/about/page.tsx
# ------------------------------------------------------------------------
$aboutPage = @'
import { Header } from "@/components/marketing/Header";
import { CompactFooter } from "@/components/marketing/CompactFooter";
import { AboutHero } from "@/components/about/AboutHero";
import { CoreDirectivesGrid } from "@/components/about/CoreDirectivesGrid";
import { TeamGrid, type TeamMember } from "@/components/about/TeamGrid";

const team: TeamMember[] = [
  {
    name: "Dr. Elena Rostova",
    role: "Chief Executive Officer",
    avatar:
      "https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=400&q=80",
  },
  {
    name: "Marcus Vance",
    role: "Chief Technology Officer",
    avatar:
      "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=400&q=80",
  },
  {
    name: "Sarah Jenkins",
    role: "Head of Product",
    avatar:
      "https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=400&q=80",
  },
  {
    name: "Raj Patel",
    role: "Lead Data Scientist",
    avatar:
      "https://images.unsplash.com/photo-1633332755192-727a05c4013d?auto=format&fit=crop&w=400&q=80",
  },
];

export default function AboutPage() {
  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <Header />

      <main className="mx-auto flex w-full max-w-[1280px] flex-1 flex-col gap-24 px-12 py-32">
        <AboutHero
          heading="Empowering the Future of Skills."
          description="Saachi AI is pioneering the intersection of artificial intelligence and professional development. We build predictive learning ecosystems that adapt to your career trajectory, cutting through noise to deliver targeted mastery."
          image="https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=1200&q=80"
        />

        <CoreDirectivesGrid
          missionTitle="Mission Statement"
          missionBody="To democratize access to high-tier professional mentorship through scalable, AI-driven learning pathways. We believe that mastery should not be gated by geography or timeline, but guided by intelligent, responsive curriculum."
        />

        <TeamGrid heading="Architects of Saachi" members={team} />
      </main>

      <CompactFooter />
    </div>
  );
}
'@
Write-File (Join-Path $webRoot "app\(marketing)\about\page.tsx") $aboutPage

Write-Host "`nDone. About Us page scaffolded at:" -ForegroundColor Green
Write-Host "  apps\web\app\(marketing)\about\page.tsx"
Write-Host "`nVisit /about after running 'pnpm --filter web dev'.`n"