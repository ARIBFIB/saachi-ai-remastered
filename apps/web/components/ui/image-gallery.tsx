"use client";

import { cn } from "@/lib/utils";

const GALLERY_IMAGES = [
  "https://images.unsplash.com/photo-1555949963-aa79dcee981c?q=80&h=800&w=800&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1531482615713-2afd69097998?q=80&h=800&w=800&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1526378722484-bd91ca387e72?q=80&h=800&w=800&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?q=80&h=800&w=800&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1550439062-609e1531270e?q=80&h=800&w=800&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&h=800&w=800&auto=format&fit=crop"
];

export function ImageGallery() {
  return (
    <div className={cn("flex items-center gap-2 h-[320px] w-full")}>
      {GALLERY_IMAGES.map((src, idx) => (
        <div
          key={idx}
          className="relative group flex-grow transition-all w-40 rounded-lg overflow-hidden h-[320px] duration-500 hover:w-full"
        >
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            className="h-full w-full object-cover object-center"
            src={src}
            alt={`saachi-ai-gallery-${idx}`}
          />
        </div>
      ))}
    </div>
  );
}

export default ImageGallery;