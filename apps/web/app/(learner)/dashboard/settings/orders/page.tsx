"use client";

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { Table, Tag, Button, Input } from "antd";
import type { ColumnsType } from "antd/es/table";
import {
  LayoutGrid,
  GraduationCap,
  Heart,
  Settings,
  HelpCircle,
  Search,
  ShoppingCart,
  Bell,
  Filter,
  Download,
  FileText,
  ChevronLeft,
  ChevronRight,
  HelpCircle as HelpIcon,
} from "lucide-react";

// TODO: replace with useOrders() hook from @saachi/api-client
type OrderStatus = "completed" | "recurring" | "refunded" | "failed";

interface OrderRecord {
  key: string;
  date: string;
  time: string;
  title: string;
  orderId: string;
  status: OrderStatus;
  amount: number;
  paymentMethod: string;
}

const orders: OrderRecord[] = [
  {
    key: "o1",
    date: "Oct 24, 2024",
    time: "10:42 AM",
    title: "Advanced Machine Learning Nanodegree",
    orderId: "ORD-8923-XZA",
    status: "completed",
    amount: 1299.0,
    paymentMethod: "Visa •••• 4242",
  },
  {
    key: "o2",
    date: "Sep 15, 2024",
    time: "02:15 PM",
    title: "Data Structures & Algorithms Mastery",
    orderId: "ORD-7712-BYK",
    status: "completed",
    amount: 499.5,
    paymentMethod: "PayPal",
  },
  {
    key: "o3",
    date: "Aug 02, 2024",
    time: "09:00 AM",
    title: "Annual Premium Subscription",
    orderId: "SUB-1109-MMM",
    status: "recurring",
    amount: 299.0,
    paymentMethod: "Visa •••• 4242",
  },
];

const navItems = [
  { icon: LayoutGrid, label: "Dashboard", href: "/dashboard" },
  { icon: GraduationCap, label: "My Courses", href: "/dashboard/my-courses" },
  { icon: Heart, label: "Wishlist", href: "/dashboard/wishlist" },
  { icon: Settings, label: "Settings", href: "/dashboard/settings" },
];

const statusStyles: Record<OrderStatus, { bg: string; color: string; label: string }> = {
  completed: {
    bg: "var(--token-color-successTint)",
    color: "var(--token-color-success)",
    label: "COMPLETED",
  },
  recurring: {
    bg: "var(--token-color-primaryTint)",
    color: "var(--token-color-inkSoft)",
    label: "RECURRING",
  },
  refunded: {
    bg: "var(--token-color-warningTint)",
    color: "var(--token-color-warning)",
    label: "REFUNDED",
  },
  failed: {
    bg: "var(--token-color-errorTint)",
    color: "var(--token-color-error)",
    label: "FAILED",
  },
};

const footerLinks = [
  { label: "About Us", href: "/about" },
  { label: "Careers", href: "/careers" },
  { label: "Privacy Policy", href: "/legal/privacy" },
  { label: "Terms of Service", href: "/legal/terms" },
  { label: "Instructor Handbook", href: "/instructor/handbook" },
];

const PAGE_SIZE = 3;
const TOTAL_ENTRIES = 12; // TODO: derive from API response meta once wired up

export default function OrderHistoryPage() {
  const [page, setPage] = useState(1);

  const rangeStart = (page - 1) * PAGE_SIZE + 1;
  const rangeEnd = Math.min(page * PAGE_SIZE, TOTAL_ENTRIES);

  function handleDownloadReceipt(orderId: string) {
    // TODO: wire to useOrders().downloadReceipt(orderId) from @saachi/api-client
    console.log("download receipt", orderId);
  }

  function handleExportAll() {
    // TODO: wire to useOrders().exportAll() from @saachi/api-client
    console.log("export all orders");
  }

  const columns: ColumnsType<OrderRecord> = [
    {
      title: "DATE",
      dataIndex: "date",
      key: "date",
      width: 180,
      render: (_, record) => (
        <div className="flex flex-col gap-0.5">
          <span className="text-base font-medium" style={{ color: "var(--token-color-ink)" }}>
            {record.date}
          </span>
          <span className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
            {record.time}
          </span>
        </div>
      ),
    },
    {
      title: "ORDER DETAILS",
      dataIndex: "title",
      key: "title",
      render: (_, record) => {
        const style = statusStyles[record.status];
        return (
          <div className="flex flex-col items-start gap-1">
            <span className="text-base font-medium" style={{ color: "var(--token-color-ink)" }}>
              {record.title}
            </span>
            <span
              className="text-xs font-medium"
              style={{ color: "var(--token-color-inkSoft)", fontFamily: "monospace" }}
            >
              ID: {record.orderId}
            </span>
            <Tag
              bordered={false}
              style={{
                backgroundColor: style.bg,
                color: style.color,
                fontSize: 10,
                fontWeight: 700,
                letterSpacing: "0.02em",
                margin: 0,
              }}
            >
              {style.label}
            </Tag>
          </div>
        );
      },
    },
    {
      title: "AMOUNT",
      dataIndex: "amount",
      key: "amount",
      align: "right",
      width: 160,
      render: (_, record) => (
        <div className="flex flex-col items-end gap-0.5">
          <span className="text-base font-bold" style={{ color: "var(--token-color-ink)" }}>
            ${record.amount.toFixed(2)}
          </span>
          <span className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
            {record.paymentMethod}
          </span>
        </div>
      ),
    },
    {
      title: "ACTION",
      key: "action",
      align: "right",
      width: 140,
      render: (_, record) => (
        <Button
          type="link"
          icon={<FileText size={14} />}
          onClick={() => handleDownloadReceipt(record.orderId)}
          style={{ color: "var(--token-color-primary)", fontWeight: 600, paddingRight: 0 }}
        >
          Receipt
        </Button>
      ),
    },
  ];

  return (
    <div className="flex min-h-screen bg-[var(--token-color-bg)]">
      {/* Header */}
      <header className="fixed inset-x-0 top-0 z-50 h-16 border-b border-[var(--token-color-border)] bg-[var(--token-color-bg)] shadow-[var(--token-shadow-sm)]">
        <div className="flex h-full items-center justify-between px-6">
          <div className="flex items-center gap-10">
            <Link href="/" className="text-2xl font-black" style={{ color: "var(--token-color-primary)" }}>
              Saachi AI
            </Link>
            <nav className="hidden items-center gap-6 md:flex">
              <Link
                href="/courses"
                className="text-sm font-semibold tracking-wide"
                style={{ color: "var(--token-color-inkSoft)" }}
              >
                Marketplace
              </Link>
              <Link
                href="/categories"
                className="text-sm font-semibold tracking-wide"
                style={{ color: "var(--token-color-inkSoft)" }}
              >
                Categories
              </Link>
            </nav>
          </div>

          <div className="hidden max-w-96 flex-1 px-6 md:block">
            <Input
              prefix={<Search size={16} color="var(--token-color-textMuted)" />}
              placeholder="Search..."
              size="large"
            />
          </div>

          <div className="flex items-center gap-4">
            <button aria-label="Cart" className="text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]">
              <ShoppingCart size={20} />
            </button>
            <button aria-label="Notifications" className="text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]">
              <Bell size={20} />
            </button>
            <Link href="/settings/profile">
              <span className="relative block h-8 w-8 overflow-hidden rounded-full border border-[var(--token-color-border)]">
                <Image src="https://i.pravatar.cc/64?img=47" alt="Profile" fill sizes="32px" className="object-cover" />
              </span>
            </Link>
          </div>
        </div>
      </header>

      {/* Sidebar */}
      <aside className="fixed inset-y-16 left-0 hidden w-72 flex-col border-r border-[var(--token-color-border)] bg-[var(--token-color-surfaceAlt)] lg:flex">
        <div className="flex items-center gap-4 border-b border-[var(--token-color-border)] p-6">
          <span className="relative block h-12 w-12 shrink-0 overflow-hidden rounded-full">
            <Image src="https://i.pravatar.cc/96?img=47" alt="Learner avatar" fill sizes="48px" className="object-cover" />
          </span>
          <div className="flex flex-col">
            <span className="text-lg font-bold" style={{ color: "var(--token-color-ink)" }}>
              Learner Portal
            </span>
            <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-xs)" }}>
              Manage your skills
            </span>
          </div>
        </div>

        <nav className="flex flex-1 flex-col gap-2 py-4">
          {navItems.map(({ icon: Icon, label, href }) => {
            const isActive = label === "Settings";
            return (
              <Link
                key={label}
                href={href}
                className="flex h-12 items-center gap-4 border-l-4 pl-4 pr-6 text-sm font-semibold tracking-wide transition"
                style={{
                  borderColor: isActive ? "var(--token-color-primary)" : "transparent",
                  backgroundColor: isActive ? "var(--token-color-primaryTint)" : "transparent",
                  color: isActive ? "var(--token-color-primary)" : "var(--token-color-inkSoft)",
                }}
              >
                <Icon size={18} />
                {label}
              </Link>
            );
          })}
        </nav>

        <div className="border-t border-[var(--token-color-border)] p-4">
          <Link
            href="/support"
            className="flex h-10 items-center gap-4 pl-4 text-sm font-semibold tracking-wide text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]"
          >
            <HelpCircle size={18} />
            Help Center
          </Link>
        </div>
      </aside>

      {/* Main column */}
      <div className="flex w-full flex-col pt-16 lg:pl-72">
        <main className="flex-1 px-12 pb-14 pt-12">
          <div className="mx-auto flex max-w-[896px] flex-col gap-6">
            {/* Page header */}
            <div className="flex items-end justify-between">
              <div className="flex flex-col gap-1">
                <h1 className="text-5xl font-bold leading-[52.8px]" style={{ color: "var(--token-color-ink)" }}>
                  Purchase History
                </h1>
                <p style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
                  Review your past transactions and download receipts.
                </p>
              </div>

              <div className="flex items-center gap-2">
                <Button icon={<Filter size={14} />}>Filter</Button>
                <Button icon={<Download size={14} />} onClick={handleExportAll}>
                  Export All
                </Button>
              </div>
            </div>

            {/* Orders table card */}
            <div
              className="overflow-hidden rounded-2xl border bg-[var(--token-color-surface)] shadow-[var(--token-shadow-md)]"
              style={{ borderColor: "var(--token-color-border)" }}
            >
              <Table<OrderRecord>
                columns={columns}
                dataSource={orders}
                pagination={false}
                rowKey="key"
              />

              {/* Custom pagination footer */}
              <div
                className="flex items-center justify-between border-t bg-[var(--token-color-surface)] p-4"
                style={{ borderColor: "var(--token-color-border)" }}
              >
                <span className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
                  Showing {rangeStart} to {rangeEnd} of {TOTAL_ENTRIES} entries
                </span>

                <div className="flex items-center gap-1">
                  <button
                    type="button"
                    aria-label="Previous page"
                    disabled={page === 1}
                    onClick={() => setPage((p) => Math.max(1, p - 1))}
                    className="flex h-8 w-8 items-center justify-center rounded-md transition hover:bg-[var(--token-color-surfaceAlt)] disabled:cursor-not-allowed disabled:opacity-50"
                  >
                    <ChevronLeft size={14} color="var(--token-color-inkSoft)" />
                  </button>
                  <button
                    type="button"
                    aria-label="Next page"
                    disabled={rangeEnd >= TOTAL_ENTRIES}
                    onClick={() => setPage((p) => p + 1)}
                    className="flex h-8 w-8 items-center justify-center rounded-md transition hover:bg-[var(--token-color-surfaceAlt)] disabled:cursor-not-allowed disabled:opacity-50"
                  >
                    <ChevronRight size={14} color="var(--token-color-inkSoft)" />
                  </button>
                </div>
              </div>
            </div>

            {/* Support banner */}
            <div
              className="flex items-center justify-between rounded-2xl border p-6"
              style={{ backgroundColor: "var(--token-color-surfaceAlt)", borderColor: "var(--token-color-border)" }}
            >
              <div className="flex items-center gap-4">
                <span
                  className="flex h-10 w-10 items-center justify-center rounded-full"
                  style={{ backgroundColor: "var(--token-color-primaryTint)" }}
                >
                  <HelpIcon size={18} color="var(--token-color-primary)" />
                </span>
                <div className="flex flex-col">
                  <span className="text-base font-bold" style={{ color: "var(--token-color-ink)" }}>
                    Need help with billing?
                  </span>
                  <span className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
                    Contact our support team for invoice disputes or refunds.
                  </span>
                </div>
              </div>

              <Link href="/contact">
                <Button>Contact Support</Button>
              </Link>
            </div>
          </div>
        </main>

        {/* Footer */}
        <footer className="bg-zinc-200 px-6 py-10 lg:pl-[19rem]">
          <div className="flex flex-col gap-4">
            <span className="text-base font-bold" style={{ color: "var(--token-color-primary)" }}>
              Saachi AI
            </span>
            <p style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
              &copy; {new Date().getFullYear()} Saachi AI Marketplace. Empowering the future of skills.
            </p>

            <nav className="flex flex-wrap justify-end gap-6">
              {footerLinks.map((link) => (
                <Link
                  key={link.label}
                  href={link.href}
                  className="text-xs font-medium hover:text-[var(--token-color-primary)]"
                  style={{ color: "var(--token-color-inkSoft)" }}
                >
                  {link.label}
                </Link>
              ))}
            </nav>
          </div>
        </footer>
      </div>
    </div>
  );
}