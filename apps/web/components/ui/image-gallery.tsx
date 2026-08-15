"use client";

import { cn } from "@/lib/utils";
import { GALLERY_IMAGES } from "@/components/ui/gallery-cursor-trail";

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