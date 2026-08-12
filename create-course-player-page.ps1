<#
================================================================================
 create-course-player-page.ps1
 Creates the Course Player (lesson playback) page for apps/web, fully
 token-driven and built with Ant Design components -- zero hardcoded hex
 colors in the page itself (every color/spacing/shadow reads from
 lib/design-system/tokens.ts via --token-* CSS vars + antdTheme.ts).

 WHAT THIS SCRIPT DOES:
   1. Adds two new named tokens to lib/design-system/tokens.ts (idempotent):
        - color.playerBg        deep near-black used for the video stage
        - color.completedGreen  bright mint used for "lesson completed" ticks
      (kept separate from the existing "ink" and "success" tokens on
      purpose -- those carry different semantic meaning elsewhere, e.g.
      "success" is also used for star ratings. Changing the whole app's
      theme later is still a one-file edit in tokens.ts.)
   2. Creates apps/web/app/courses/[slug]/learn/page.tsx using:
        - Ant Design: Tabs, Collapse, Button, Input.TextArea, Typography
        - Tailwind classes referencing var(--token-color-*) /
          var(--token-shadow-*) instead of literal hex/rgba values
        - lucide-react icons throughout (player controls, sidebar states,
          top nav icons)
      Demo lesson/module data is inline and clearly marked with TODO
      comments for wiring to @saachi/api-client (useCourses / a future
      useLessonPlayer hook).

 USAGE:
   Place this script at the SAI2 monorepo root (same level as apps/,
   packages/) and run:
     powershell -ExecutionPolicy Bypass -File .\create-course-player-page.ps1

 SAFE TO RE-RUN.
================================================================================
#>

$ErrorActionPreference = "Stop"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$webRoot    = Join-Path $PSScriptRoot "apps\web"
$tokensPath = Join-Path $webRoot "lib\design-system\tokens.ts"
$pageDir    = Join-Path $webRoot "app\courses\[slug]\learn"
$pagePath   = Join-Path $pageDir "page.tsx"

if (-not (Test-Path -LiteralPath $tokensPath)) {
    Write-Host "ERROR: Could not find $tokensPath. Place this script at the SAI2 monorepo root." -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------------------
# STEP 1: Add new tokens to tokens.ts (idempotent)
# ------------------------------------------------------------------------
$tokensContent = [System.IO.File]::ReadAllText($tokensPath, [System.Text.Encoding]::UTF8)

if ($tokensContent -notmatch "playerBg") {
    $anchor = '    surfaceAlt: "#F4F4F5",    // zinc-100 (icon backgrounds)'
    if ($tokensContent.Contains($anchor)) {
        $insertion = $anchor + "`r`n" +
            '    playerBg: "#0F172A",       // slate-900 (video stage background)' + "`r`n" +
            '    completedGreen: "#4EDEA3", // bright mint (lesson-completed ticks)'
        $tokensContent = $tokensContent.Replace($anchor, $insertion)
        [System.IO.File]::WriteAllText($tokensPath, $tokensContent, $utf8NoBom)
        Write-Host "Added playerBg + completedGreen tokens to tokens.ts" -ForegroundColor Green
        Write-Host "Remember to run 'pnpm --filter web run tokens:sync' (or 'pnpm dev') so globals.css picks up the new CSS vars." -ForegroundColor Yellow
    } else {
        Write-Host "WARNING: Could not find the expected anchor line in tokens.ts. Add these manually to the color block:" -ForegroundColor Yellow
        Write-Host '  playerBg: "#0F172A",' -ForegroundColor Yellow
        Write-Host '  completedGreen: "#4EDEA3",' -ForegroundColor Yellow
    }
} else {
    Write-Host "tokens.ts already has playerBg -- skipping token insertion." -ForegroundColor Cyan
}

# ------------------------------------------------------------------------
# STEP 2: Create the course player page
# ------------------------------------------------------------------------
if (-not (Test-Path -LiteralPath $pageDir)) {
    New-Item -ItemType Directory -Path $pageDir -Force | Out-Null
}

$pageContent = @'
"use client";

import { useState } from "react";
import Link from "next/link";
import { Tabs, Collapse, Button, Input, Typography } from "antd";
import type { CollapseProps } from "antd";
import {
  Play,
  Pause,
  Volume2,
  Subtitles,
  Settings,
  Maximize,
  CheckCircle2,
  PlayCircle,
  Lock,
  Clock,
  FileText,
  ChevronDown,
  ShoppingCart,
  Bell,
} from "lucide-react";

const { Text, Title } = Typography;
const { TextArea } = Input;

// TODO: replace with useCourses() / a future useLessonPlayer() hook from @saachi/api-client
interface Lesson {
  id: string;
  title: string;
  meta: string;
  status: "completed" | "active" | "locked";
}

interface ModuleData {
  id: string;
  label: string;
  title: string;
  lessons: Lesson[];
}

const modules: ModuleData[] = [
  {
    id: "module-1",
    label: "Module 1",
    title: "Foundations of AI",
    lessons: [
      { id: "l1", title: "History of Machine Learning", meta: "10:20", status: "completed" },
      { id: "l2", title: "Introduction to LLMs", meta: "15:30", status: "active" },
      { id: "l3", title: "Understanding Neural Networks", meta: "Reading", status: "locked" },
    ],
  },
  {
    id: "module-2",
    label: "Module 2",
    title: "Transformers in Depth",
    lessons: [],
  },
  {
    id: "module-3",
    label: "Module 3",
    title: "Prompt Engineering",
    lessons: [],
  },
];

export default function CoursePlayerPage() {
  const [isPlaying, setIsPlaying] = useState(false);
  const [notes, setNotes] = useState("");

  const tabItems = [
    {
      key: "overview",
      label: "Overview",
      children: (
        <div className="flex flex-col gap-4 p-6">
          <Title level={5} style={{ margin: 0, color: "var(--token-color-ink)" }}>
            About this lesson
          </Title>
          <Text style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
            In this foundational lesson, we explore the core architecture of Large Language Models. You
            will learn how transformer networks process sequential data and the mathematical principles
            behind attention mechanisms.
          </Text>
          <div className="flex gap-4 pt-2">
            <InfoPill icon={<Clock size={20} color="var(--token-color-primary)" />} label="Duration" value="15:30 mins" />
            <InfoPill icon={<FileText size={18} color="var(--token-color-primary)" />} label="Difficulty" value="Intermediate" />
          </div>
        </div>
      ),
    },
    {
      key: "resources",
      label: "Resources",
      children: (
        <div className="p-6">
          <Text style={{ color: "var(--token-color-inkSoft)" }}>
            No resources have been attached to this lesson yet.
          </Text>
        </div>
      ),
    },
    {
      key: "notes",
      label: "Notes",
      children: (
        <div className="flex flex-col gap-4 p-6">
          <TextArea
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            placeholder="Type your personal notes here. They will be saved automatically..."
            autoSize={{ minRows: 4, maxRows: 10 }}
          />
          <div className="flex justify-end">
            <Button
              onClick={() => {
                // TODO: wire to notes-save endpoint via @saachi/api-client
                console.log("save notes", notes);
              }}
            >
              Save Notes
            </Button>
          </div>
        </div>
      ),
    },
    {
      key: "qa",
      label: "Q&A",
      children: (
        <div className="p-6">
          <Text style={{ color: "var(--token-color-inkSoft)" }}>
            No questions have been asked on this lesson yet.
          </Text>
        </div>
      ),
    },
  ];

  const collapseItems: CollapseProps["items"] = modules.map((mod) => ({
    key: mod.id,
    label: (
      <div className="flex flex-col">
        <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-xs)" }}>
          {mod.label}
        </span>
        <span
          className="font-bold tracking-wide"
          style={{ color: "var(--token-color-ink)", fontSize: "var(--token-font-size-sm)" }}
        >
          {mod.title}
        </span>
      </div>
    ),
    children:
      mod.lessons.length > 0 ? (
        <div className="flex flex-col">
          {mod.lessons.map((lesson) => (
            <LessonRow key={lesson.id} lesson={lesson} />
          ))}
        </div>
      ) : undefined,
  }));

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      {/* Top nav */}
      <header className="sticky top-0 z-50 flex h-16 items-center justify-between bg-[var(--token-color-bg)] px-6 shadow-[var(--token-shadow-sm)]">
        <div className="flex items-center gap-4">
          <Link href="/" className="text-2xl font-black text-[var(--token-color-primary)]">
            Saachi AI
          </Link>
          <nav className="flex items-center gap-6 pl-10">
            <Link href="/courses" className="text-sm font-semibold tracking-wide text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]">
              Marketplace
            </Link>
            <Link href="/categories" className="text-sm font-semibold tracking-wide text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]">
              Categories
            </Link>
          </nav>
        </div>

        <div className="flex items-center gap-4">
          <button aria-label="Cart" className="rounded-full p-2 text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-surfaceAlt)]">
            <ShoppingCart size={20} />
          </button>
          <button aria-label="Notifications" className="rounded-full p-2 text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-surfaceAlt)]">
            <Bell size={20} />
          </button>
          <Button type="primary">Sign In</Button>
        </div>
      </header>

      {/* Main content */}
      <div className="flex flex-1">
        {/* Left: video + tabs */}
        <div className="flex flex-1 flex-col border-r border-[var(--token-color-border)] bg-[var(--token-color-surface)]">
          {/* Video stage */}
          <div className="group relative flex flex-col justify-center overflow-hidden bg-[var(--token-color-playerBg)]">
            <img
              src="https://placehold.co/959x540"
              alt="Lesson video placeholder"
              className="aspect-video w-full opacity-90"
            />

            <div className="absolute inset-0 flex flex-col justify-end bg-gradient-to-t from-black/80 via-black/0 to-black/0 p-6 opacity-0 transition-opacity group-hover:opacity-100">
              <div className="flex items-center justify-between pb-2">
                <div className="flex items-center gap-4">
                  <button aria-label={isPlaying ? "Pause" : "Play"} onClick={() => setIsPlaying((p) => !p)}>
                    {isPlaying ? (
                      <Pause size={40} color="var(--token-color-surface)" fill="var(--token-color-surface)" />
                    ) : (
                      <Play size={40} color="var(--token-color-surface)" fill="var(--token-color-surface)" />
                    )}
                  </button>
                  <span className="text-xs font-medium text-[var(--token-color-surface)]">
                    02:14 / 15:30
                  </span>
                </div>

                <div className="flex items-center gap-4">
                  <button aria-label="Volume"><Volume2 size={18} color="var(--token-color-surface)" /></button>
                  <button aria-label="Subtitles"><Subtitles size={18} color="var(--token-color-surface)" /></button>
                  <button aria-label="Settings"><Settings size={20} color="var(--token-color-surface)" /></button>
                  <button aria-label="Fullscreen"><Maximize size={18} color="var(--token-color-surface)" /></button>
                </div>
              </div>

              <div className="relative h-1 rounded-full bg-[var(--token-color-surface)]/30">
                <div className="absolute left-0 top-0 h-1 w-2/5 rounded-full bg-[var(--token-color-primaryTint)]" />
                <div className="absolute left-[38%] top-1/2 h-3 w-3 -translate-y-1/2 rounded-full bg-[var(--token-color-surface)] shadow-[var(--token-shadow-sm)]" />
              </div>
            </div>
          </div>

          {/* Lesson header */}
          <div className="flex flex-col gap-1 border-b border-[var(--token-color-border)] p-6">
            <Title level={4} style={{ margin: 0, color: "var(--token-color-ink)" }}>
              Module 1: Introduction to LLMs
            </Title>
            <Text style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
              Advanced AI Architecture Fundamentals
            </Text>
          </div>

          {/* Tabs */}
          <div className="flex-1 overflow-hidden px-2">
            <Tabs items={tabItems} defaultActiveKey="overview" />
          </div>
        </div>

        {/* Right: curriculum sidebar */}
        <aside className="flex w-80 shrink-0 flex-col border-l border-[var(--token-color-border)] bg-[var(--token-color-surface)]">
          <div className="flex items-center justify-between border-b border-[var(--token-color-border)] bg-[var(--token-color-surfaceAlt)] p-6">
            <Title level={4} style={{ margin: 0, color: "var(--token-color-ink)" }}>
              Course Content
            </Title>
          </div>

          <Collapse
            items={collapseItems}
            defaultActiveKey={["module-1"]}
            bordered={false}
            expandIcon={({ isActive }) => (
              <ChevronDown
                size={12}
                color="var(--token-color-inkSoft)"
                style={{ transform: isActive ? "rotate(180deg)" : undefined, transition: "transform 0.2s" }}
              />
            )}
            expandIconPosition="end"
          />
        </aside>
      </div>
    </div>
  );
}

function InfoPill({ icon, label, value }: { icon: React.ReactNode; label: string; value: string }) {
  return (
    <div className="flex flex-1 items-center gap-2 rounded-lg bg-[var(--token-color-surfaceAlt)] p-4">
      {icon}
      <div className="flex flex-col">
        <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-xs)" }}>{label}</span>
        <span
          className="font-semibold tracking-wide"
          style={{ color: "var(--token-color-ink)", fontSize: "var(--token-font-size-sm)" }}
        >
          {value}
        </span>
      </div>
    </div>
  );
}

function LessonRow({ lesson }: { lesson: Lesson }) {
  const isActive = lesson.status === "active";
  const isCompleted = lesson.status === "completed";
  const isLocked = lesson.status === "locked";

  return (
    <div
      className="flex items-start gap-4 px-4 py-2"
      style={{
        backgroundColor: isActive ? "var(--token-color-primaryTint)" : "transparent",
        borderLeft: isActive ? "4px solid var(--token-color-primary)" : "4px solid transparent",
      }}
    >
      {isCompleted && <CheckCircle2 size={20} color="var(--token-color-completedGreen)" style={{ marginTop: 2 }} />}
      {isActive && <PlayCircle size={20} color="var(--token-color-primary)" style={{ marginTop: 2 }} />}
      {isLocked && <Lock size={16} color="var(--token-color-textMuted)" style={{ marginTop: 4 }} />}

      <div className="flex flex-col">
        <span
          style={{
            color: isActive
              ? "var(--token-color-primary)"
              : isCompleted
              ? "var(--token-color-inkSoft)"
              : "var(--token-color-inkSoft)",
            fontWeight: isActive ? 600 : 400,
            textDecoration: isCompleted ? "line-through" : "none",
            fontSize: "var(--token-font-size-base)",
          }}
        >
          {lesson.title}
        </span>
        <span
          style={{
            color: isActive ? "var(--token-color-primary)" : "var(--token-color-inkSoft)",
            fontSize: "var(--token-font-size-xs)",
          }}
        >
          {lesson.meta}
        </span>
      </div>
    </div>
  );
}
'@

[System.IO.File]::WriteAllText($pagePath, $pageContent, $utf8NoBom)
Write-Host "Created $pagePath" -ForegroundColor Green

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "Done." -ForegroundColor Cyan
Write-Host "Page:   apps/web/app/courses/[slug]/learn/page.tsx" -ForegroundColor Cyan
Write-Host "Route:  /courses/:slug/learn" -ForegroundColor Cyan
Write-Host ""
Write-Host "NOTE 1: This route is currently NOT protected by middleware.ts (which only" -ForegroundColor Yellow
Write-Host "guards /dashboard and /instructor). Add '/courses/:path*/learn' to the" -ForegroundColor Yellow
Write-Host "matcher in apps/web/middleware.ts once enrollment gating is ready." -ForegroundColor Yellow
Write-Host ""
Write-Host "NOTE 2: Confirm AntdProvider wraps children in apps/web/app/layout.tsx so" -ForegroundColor Yellow
Write-Host "Tabs/Collapse/Button pick up antdTheme derived from tokens.ts automatically." -ForegroundColor Yellow
Write-Host "================================================================================" -ForegroundColor Cyan