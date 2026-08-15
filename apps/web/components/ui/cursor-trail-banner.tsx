"use client";

import { ImageCursorTrail } from "@/components/ui/image-cursor-trail";

// Course/AI-relevant imagery (same visual family already used across the
// landing page trending carousel + blog preview), instead of generic
// unsplash portraits.
const SHOWCASE_IMAGES = [
  "https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1531482615713-2afd69097998?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1526378722484-bd91ca387e72?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1550439062-609e1531270e?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1571171637578-41bc2dd41cd2?w=480&h=600&fit=crop&q=70&auto=format"
];

export function CursorTrailBanner() {
  return (
    <section className="relative mx-auto w-full max-w-7xl px-4 pt-6 md:px-8">
      <div className="relative overflow-hidden rounded-[24px] border border-line bg-card shadow-sm">
        <ImageCursorTrail
          items={SHOWCASE_IMAGES}
          maxNumberOfImages={5}
          distance={25}
          imgClass="sm:w-40 w-28 sm:h-48 h-36"
          className="!h-[420px] max-w-none rounded-[24px] bg-paper-dim md:!h-[480px]"
        >
          <div className="pointer-events-none absolute inset-0 flex flex-col items-center justify-center gap-2 text-center">
            <span className="rounded-full border border-line bg-card/90 px-3.5 py-1.5 text-[12.5px] font-semibold text-accent-violet backdrop-blur-sm">
              Move your cursor
            </span>
            <h2 className="font-display text-[26px] font-bold text-ink md:text-[38px]">
              Learn AI Skills. <span className="text-gradient-brand">Build Real Projects.</span>
            </h2>
          </div>
        </ImageCursorTrail>
      </div>
    </section>
  );
}

export default CursorTrailBanner;