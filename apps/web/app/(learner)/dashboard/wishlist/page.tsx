"use client";

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { Button, Typography } from "antd";
import {
  LayoutGrid,
  GraduationCap,
  Heart,
  Settings,
  HelpCircle,
  Star,
  Trash2,
  ShoppingCart,
} from "lucide-react";

const { Title, Text } = Typography;

// TODO: replace with useWishlist() hook from @saachi/api-client
interface WishlistItem {
  id: string;
  title: string;
  description: string;
  category: string;
  level: string;
  rating: number;
  price: number;
  instructor: string;
  instructorAvatar: string;
  image: string;
}

const initialItems: WishlistItem[] = [
  {
    id: "w1",
    title: "Introduction to Neural Networks",
    description: "Master the fundamentals of neural networks and start building your own models.",
    category: "AI & Data",
    level: "Beginner",
    rating: 4.8,
    price: 89.99,
    instructor: "Dr. Sarah Chen",
    instructorAvatar: "https://i.pravatar.cc/64?img=5",
    image:
      "https://images.unsplash.com/photo-1620712943543-bcc4688e7485?auto=format&fit=crop&w=600&q=80",
  },
  {
    id: "w2",
    title: "Advanced Design Systems in Figma",
    description: "Learn to build robust, scalable design systems with variables, modes, and UI kits.",
    category: "Design",
    level: "Intermediate",
    rating: 4.9,
    price: 119.0,
    instructor: "Marcus Johnson",
    instructorAvatar: "https://i.pravatar.cc/64?img=13",
    image:
      "https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=600&q=80",
  },
  {
    id: "w3",
    title: "Cloud Architecture: Scaling Enterprise Systems",
    description: "A comprehensive guide to designing and deploying highly available cloud infrastructure.",
    category: "Cloud",
    level: "Advanced",
    rating: 4.7,
    price: 149.5,
    instructor: "David Kim",
    instructorAvatar: "https://i.pravatar.cc/64?img=33",
    image:
      "https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=600&q=80",
  },
];

const navItems = [
  { icon: LayoutGrid, label: "Dashboard", href: "/dashboard" },
  { icon: GraduationCap, label: "My Courses", href: "/dashboard/my-courses" },
  { icon: Heart, label: "Wishlist", href: "/dashboard/wishlist" },
  { icon: Settings, label: "Settings", href: "/dashboard/settings" },
];

const footerLinks = [
  { label: "About Us", href: "/about" },
  { label: "Careers", href: "/careers" },
  { label: "Privacy Policy", href: "/legal/privacy" },
  { label: "Terms of Service", href: "/legal/terms" },
  { label: "Instructor Handbook", href: "/instructor/handbook" },
];

export default function WishlistPage() {
  const [items, setItems] = useState<WishlistItem[]>(initialItems);

  function handleRemove(id: string) {
    setItems((prev) => prev.filter((item) => item.id !== id));
  }

  function handleMoveToCart(id: string) {
    // TODO: wire to useCart().addItem() from @saachi/api-client, then remove from wishlist
    console.log("move to cart", id);
    setItems((prev) => prev.filter((item) => item.id !== id));
  }

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
              fontSize: "var(--token-font-size-sm)",
            }}
          >
            Manage your skills
          </Text>
        </div>

        <nav className="flex flex-1 flex-col gap-1 py-4">
          {navItems.map(({ icon: Icon, label, href }) => {
            const isActive = label === "Wishlist";
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
        <main className="flex-1 px-12 pb-24 pt-12">
          <div className="flex flex-col gap-10">
            {/* Header */}
            <div className="flex flex-col gap-1.5">
              <Title level={1} style={{ margin: 0, color: "var(--token-color-ink)" }}>
                Your Wishlist
              </Title>
              <Text
                style={{
                  color: "var(--token-color-inkSoft)",
                  fontSize: "var(--token-font-size-lg)",
                }}
              >
                Courses you&apos;ve saved for later. Ready to start learning?
              </Text>
            </div>

            {/* Wishlist grid */}
            {items.length === 0 ? (
              <EmptyWishlist />
            ) : (
              <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 xl:grid-cols-3">
                {items.map((item) => (
                  <WishlistCourseCard
                    key={item.id}
                    item={item}
                    onRemove={handleRemove}
                    onMoveToCart={handleMoveToCart}
                  />
                ))}
              </div>
            )}
          </div>
        </main>

        {/* Footer */}
        <footer className="bg-zinc-200 px-6 py-10">
          <div className="flex flex-col gap-4">
            <div className="border-b border-[var(--token-color-border)] pb-4">
              <span className="text-base font-bold text-[var(--token-color-amber)]">
                Saachi AI
              </span>
            </div>

            <p className="text-base text-gray-700">
              &copy; {new Date().getFullYear()} Saachi AI Marketplace. Empowering the future of
              skills.
            </p>

            <nav className="flex flex-wrap justify-end gap-6">
              {footerLinks.map((link) => (
                <Link
                  key={link.label}
                  href={link.href}
                  className="text-xs font-medium text-gray-700 hover:text-[var(--token-color-amber)]"
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

function WishlistCourseCard({
  item,
  onRemove,
  onMoveToCart,
}: {
  item: WishlistItem;
  onRemove: (id: string) => void;
  onMoveToCart: (id: string) => void;
}) {
  return (
    <article className="flex w-full flex-col overflow-hidden rounded-[var(--token-radius-lg)] border border-[var(--token-color-border)]/30 bg-[var(--token-color-surface)] shadow-[var(--token-shadow-md)]">
      <div className="relative h-48 w-full shrink-0 bg-[var(--token-color-surfaceAlt)]">
        <Image
          src={item.image}
          alt={item.title}
          fill
          sizes="(max-width: 768px) 100vw, 320px"
          className="object-cover"
        />
        <span className="absolute right-2 top-2 flex items-center gap-1 rounded-sm bg-[var(--token-color-surface)] px-2 pb-1 pt-[3px] text-xs font-medium shadow-[var(--token-shadow-sm)]"
          style={{ color: "var(--token-color-ink)" }}
        >
          <Star size={12} color="var(--token-color-warning)" fill="var(--token-color-warning)" />
          {item.rating}
        </span>
      </div>

      <div className="flex flex-1 flex-col gap-4 p-6">
        <div className="flex items-start gap-2">
          <span className="rounded-sm bg-[var(--token-color-amberTint)] px-2 pb-1 pt-[3px] text-xs font-medium text-[var(--token-color-amber)]">
            {item.category}
          </span>
          <span className="rounded-sm bg-[var(--token-color-surfaceAlt)] px-2 pb-1 pt-[3px] text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
            {item.level}
          </span>
        </div>

        <div className="flex flex-col gap-1">
          <h3
            className="line-clamp-2 text-2xl font-semibold leading-8"
            style={{ color: "var(--token-color-ink)" }}
          >
            {item.title}
          </h3>
          <p className="line-clamp-2 text-base" style={{ color: "var(--token-color-inkSoft)" }}>
            {item.description}
          </p>
        </div>

        <div className="flex items-center gap-2">
          <span className="relative block h-8 w-8 shrink-0 overflow-hidden rounded-full">
            <Image
              src={item.instructorAvatar}
              alt={item.instructor}
              fill
              sizes="32px"
              className="object-cover"
            />
          </span>
          <span
            className="text-sm font-semibold tracking-wide"
            style={{ color: "var(--token-color-inkSoft)" }}
          >
            {item.instructor}
          </span>
        </div>

        <div
          className="mt-auto flex items-center justify-between border-t pt-4"
          style={{ borderColor: "var(--token-color-border)" }}
        >
          <span className="text-2xl font-semibold" style={{ color: "var(--token-color-amber)" }}>
            ${item.price.toFixed(2)}
          </span>

          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={() => onRemove(item.id)}
              aria-label="Remove from wishlist"
              className="rounded-[var(--token-radius-md)] p-2 transition hover:bg-[var(--token-color-surfaceAlt)]"
              style={{ color: "var(--token-color-inkSoft)" }}
            >
              <Trash2 size={16} />
            </button>
            <Button
              type="primary"
              icon={<ShoppingCart size={14} />}
              onClick={() => onMoveToCart(item.id)}
            >
              Move to Cart
            </Button>
          </div>
        </div>
      </div>
    </article>
  );
}

function EmptyWishlist() {
  return (
    <div
      className="flex flex-col items-center gap-2 rounded-[var(--token-radius-lg)] border bg-[var(--token-color-surface)] py-20 text-center"
      style={{ borderColor: "var(--token-color-border)" }}
    >
      <p className="text-lg font-semibold" style={{ color: "var(--token-color-ink)" }}>
        Your wishlist is empty
      </p>
      <p style={{ color: "var(--token-color-inkSoft)" }}>
        Save courses you&apos;re interested in to find them here later.
      </p>
    </div>
  );
}
