"use client";

import { useState } from "react";
import Link from "next/link";
import { cn } from "@/lib/utils";
import { ImageCursorTrail } from "@/components/ui/image-cursor-trail";
import { ButtonColorful } from "@/components/ui/button-colorful";

export type GalleryCard = {
  label: string;
  src: string;
  href: string;
  buttonLabel: string;
};

// Four content-relevant cards: News, Community, Courses, Certificate.
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

export const GALLERY_IMAGES = GALLERY_CARDS.map((c) => c.src);

/**
 * Horizontal, compact card strip (fits the right-side hero column).
 * On hover: the hovered card expands slightly, shows its label and a
 * ButtonColorful CTA, and triggers a small cursor-trail using that
 * same image. A mask-image gradient fades the whole strip out toward
 * the left (text column) side so it never overlaps the headline,
 * paragraph, or CTA buttons even if the mouse drifts that way.
 */
export function GalleryCursorTrail() {
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null);

  return (
    <div
      className="relative flex h-[400px] w-full max-w-[620px] items-stretch gap-2"
      style={{
        maskImage: "linear-gradient(to left, black 70%, transparent 100%)",
        WebkitMaskImage: "linear-gradient(to left, black 70%, transparent 100%)"
      }}
    >
      {GALLERY_CARDS.map((card, idx) => {
        const isHovered = hoveredIndex === idx;
        return (
          <div
            key={card.label}
            onMouseEnter={() => setHoveredIndex(idx)}
            onMouseLeave={() => setHoveredIndex(null)}
            className={cn(
              "group relative h-full flex-grow overflow-hidden rounded-lg transition-all duration-500 ease-out",
              isHovered ? "w-[260px] flex-grow-[3]" : "w-20 flex-grow"
            )}
          >
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              className="h-full w-full object-cover object-center transition-transform duration-500 group-hover:scale-105"
              src={card.src}
              alt={card.label}
            />

            <div
              className={cn(
                "pointer-events-none absolute inset-0 bg-gradient-to-t from-black/70 via-black/10 to-transparent transition-opacity duration-300",
                isHovered ? "opacity-100" : "opacity-60"
              )}
            />

            <span
              className={cn(
                "absolute left-2.5 top-2.5 rounded-full bg-black/40 px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wide text-white backdrop-blur-sm transition-opacity duration-300",
                isHovered ? "opacity-0" : "opacity-100"
              )}
            >
              {card.label}
            </span>

            <div
              className={cn(
                "pointer-events-none absolute inset-x-0 bottom-0 flex flex-col gap-2 p-3 transition-all duration-300",
                isHovered ? "translate-y-0 opacity-100" : "translate-y-2 opacity-0"
              )}
            >
              <span className="text-[13px] font-semibold text-white">{card.label}</span>
              <Link href={card.href} className="pointer-events-auto w-fit">
                <ButtonColorful label={card.buttonLabel} />
              </Link>
            </div>

            <ImageCursorTrail
              items={[card.src, card.src, card.src]}
              active={isHovered}
              maxNumberOfImages={3}
              distance={16}
              imgClass="w-16 h-20"
              className="!absolute !inset-0 !h-full !w-full !rounded-lg !bg-transparent"
            />
          </div>
        );
      })}
    </div>
  );
}

export default GalleryCursorTrail;