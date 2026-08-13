"use client";

import Link from "next/link";
import Image from "next/image";
import { Button, Typography, Tag } from "antd";
import {
  LayoutGrid,
  GraduationCap,
  Award,
  Heart,
  Settings,
  HelpCircle,
  Filter,
  Download,
  Share2,
  Eye,
} from "lucide-react";

const { Title, Text } = Typography;

// TODO: replace with useCertificates() hook from @saachi/api-client
type CategoryVariant = "primary" | "success" | "neutral";

interface Certificate {
  id: string;
  title: string;
  category: string;
  categoryVariant: CategoryVariant;
  issuedDate: string;
  image: string;
}

const certificates: Certificate[] = [
  {
    id: "cert1",
    title: "Advanced Machine Learning Architectures",
    category: "AI & Data",
    categoryVariant: "primary",
    issuedDate: "Oct 12, 2024",
    image:
      "https://images.unsplash.com/photo-1620712943543-bcc4688e7485?auto=format&fit=crop&w=600&q=80",
  },
  {
    id: "cert2",
    title: "Ethical AI Governance & Policy",
    category: "Ethics",
    categoryVariant: "success",
    issuedDate: "Sep 05, 2024",
    image:
      "https://images.unsplash.com/photo-1450101499163-c8848c66ca85?auto=format&fit=crop&w=600&q=80",
  },
  {
    id: "cert3",
    title: "Python for Data Science Bootcamp",
    category: "Programming",
    categoryVariant: "neutral",
    issuedDate: "Jul 22, 2024",
    image:
      "https://images.unsplash.com/photo-1526379879527-8559ecfcaec0?auto=format&fit=crop&w=600&q=80",
  },
];

const navItems = [
  { icon: LayoutGrid, label: "Dashboard", href: "/dashboard" },
  { icon: GraduationCap, label: "My Courses", href: "/dashboard/my-courses" },
  { icon: Award, label: "Certificates", href: "/dashboard/certificates" },
  { icon: Heart, label: "Wishlist", href: "/dashboard/wishlist" },
  { icon: Settings, label: "Settings", href: "/dashboard/settings" },
];

// Category badge colors are derived entirely from design tokens (tokens.ts).
// Add/adjust variants here -- never hardcode hex values in the JSX below.
const categoryStyles: Record<CategoryVariant, { bg: string; color: string }> = {
  primary: {
    bg: "var(--token-color-amberTint)",
    color: "var(--token-color-amber)",
  },
  success: {
    bg: "var(--token-color-successTint)",
    color: "var(--token-color-success)",
  },
  neutral: {
    bg: "var(--token-color-surfaceAlt)",
    color: "var(--token-color-inkSoft)",
  },
};

export default function CertificatesPage() {
  return (
    <div className="flex min-h-screen bg-[var(--token-color-bg)]">
      {/* Sidebar */}
      <aside className="fixed inset-y-0 left-0 hidden w-72 flex-col border-r border-[var(--token-color-border)] bg-[var(--token-color-surfaceAlt)] lg:flex">
        <div className="flex flex-col gap-1.5 border-b border-[var(--token-color-border)] p-6">
          <Title level={2} style={{ margin: 0, color: "var(--token-color-ink)" }}>
            Learner Portal
          </Title>
          <Text
            style={{
              color: "var(--token-color-inkSoft)",
              fontSize: "var(--token-font-size-xs)",
            }}
          >
            Manage your skills
          </Text>
        </div>

        <nav className="flex flex-1 flex-col gap-2 py-6">
          {navItems.map(({ icon: Icon, label, href }) => {
            const isActive = label === "Certificates";
            return (
              <Link
                key={label}
                href={href}
                className="flex h-12 items-center gap-4 border-l-4 pl-4 pr-6 text-sm font-semibold tracking-wide transition"
                style={{
                  borderColor: isActive ? "var(--token-color-amber)" : "transparent",
                  backgroundColor: isActive
                    ? "var(--token-color-amberTint)"
                    : "transparent",
                  color: isActive
                    ? "var(--token-color-amber)"
                    : "var(--token-color-inkSoft)",
                }}
              >
                <Icon size={18} />
                {label}
              </Link>
            );
          })}
        </nav>

        <div className="border-t border-[var(--token-color-border)] p-6">
          <Link
            href="/support"
            className="flex items-center gap-4 text-sm font-semibold tracking-wide text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-amber)]"
          >
            <HelpCircle size={18} />
            Help Center
          </Link>
        </div>
      </aside>

      {/* Main column */}
      <div className="flex w-full flex-col lg:pl-72">
        <main className="flex-1 px-6 pb-14 pt-10">
          <div className="mx-auto flex max-w-[1000px] flex-col gap-10">
            {/* Header */}
            <div className="flex items-end justify-between">
              <div className="flex flex-col gap-1.5">
                <Title level={1} style={{ margin: 0, color: "var(--token-color-ink)" }}>
                  My Certificates
                </Title>
                <Text
                  style={{
                    color: "var(--token-color-inkSoft)",
                    fontSize: "var(--token-font-size-lg)",
                  }}
                >
                  A record of your achievements and completed learning paths.
                </Text>
              </div>

              <Button icon={<Filter size={14} />}>Filter</Button>
            </div>

            {/* Certificate grid */}
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 xl:grid-cols-3">
              {certificates.map((cert) => (
                <CertificateCard key={cert.id} certificate={cert} />
              ))}
            </div>
          </div>
        </main>

        {/* Footer */}
        <footer className="bg-[var(--token-color-surfaceAlt)]/60 px-6 py-10">
          <div className="mx-auto flex max-w-[1000px] flex-col gap-6 sm:flex-row sm:items-start sm:justify-between">
            <div className="flex flex-col gap-4">
              <span className="text-base font-bold text-[var(--token-color-amber)]">
                Saachi AI
              </span>
              <p
                style={{
                  color: "var(--token-color-inkSoft)",
                  fontSize: "var(--token-font-size-base)",
                }}
              >
                &copy; {new Date().getFullYear()} Saachi AI Marketplace.
                <br />
                Empowering the future of skills.
              </p>
            </div>

            <nav className="flex flex-wrap gap-6">
              <Link
                href="/about"
                className="text-xs font-medium text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-amber)]"
              >
                About Us
              </Link>
              <Link
                href="/careers"
                className="text-xs font-medium text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-amber)]"
              >
                Careers
              </Link>
              <Link
                href="/legal/privacy"
                className="text-xs font-medium text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-amber)]"
              >
                Privacy Policy
              </Link>
              <Link
                href="/legal/terms"
                className="text-xs font-medium text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-amber)]"
              >
                Terms of Service
              </Link>
              <Link
                href="/instructor/handbook"
                className="text-xs font-medium text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-amber)]"
              >
                Instructor Handbook
              </Link>
            </nav>
          </div>
        </footer>
      </div>
    </div>
  );
}

function CertificateCard({ certificate }: { certificate: Certificate }) {
  const style = categoryStyles[certificate.categoryVariant];

  return (
    <article
      className="flex flex-col overflow-hidden rounded-[var(--token-radius-lg)] border bg-[var(--token-color-surface)] shadow-[var(--token-shadow-md)]"
      style={{ borderColor: "var(--token-color-inkDeep)", borderWidth: "2px", borderStyle: "solid" }}
    >
      <div className="group relative h-48 w-full shrink-0 overflow-hidden bg-[var(--token-color-surfaceAlt)]">
        <Image
          src={certificate.image}
          alt={certificate.title}
          fill
          sizes="(max-width: 768px) 100vw, 33vw"
          className="object-cover opacity-90 transition duration-300 group-hover:scale-105"
        />
        <div className="absolute inset-0 flex items-end bg-gradient-to-t from-[var(--token-color-ink)]/40 to-transparent p-4 opacity-0 transition group-hover:opacity-100">
          <span className="flex items-center gap-1 rounded-full bg-white/20 px-3 pb-1 pt-[3px] text-xs font-medium text-white backdrop-blur-[6px]">
            <Eye size={12} />
            Preview
          </span>
        </div>
      </div>

      <div className="flex flex-1 flex-col gap-3 p-6">
        <Tag
          bordered={false}
          style={{
            backgroundColor: style.bg,
            color: style.color,
            width: "fit-content",
            margin: 0,
          }}
        >
          {certificate.category}
        </Tag>

        <h3
          className="line-clamp-2 min-h-[3.5rem] text-lg font-semibold leading-6"
          style={{ color: "var(--token-color-ink)" }}
        >
          {certificate.title}
        </h3>

        <span
          style={{
            color: "var(--token-color-inkSoft)",
            fontSize: "var(--token-font-size-base)",
          }}
        >
          Issued: {certificate.issuedDate}
        </span>

        <div
          className="mt-2 flex gap-2 border-t pt-4"
          style={{ borderColor: "var(--token-color-inkDeep)", borderWidth: "2px", borderStyle: "solid" }}
        >
          <Button type="primary" icon={<Download size={14} />} block>
            PDF
          </Button>
          <Button icon={<Share2 size={14} />} block>
            Share
          </Button>
        </div>
      </div>
    </article>
  );
}
