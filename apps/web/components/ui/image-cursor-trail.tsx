"use client";

import React, { createRef, useEffect, useRef, type ReactNode } from "react";
import { cn } from "@/lib/utils";

interface ImageMouseTrailProps {
  items: string[];
  children?: ReactNode;
  className?: string;
  imgClass?: string;
  distance?: number;
  maxNumberOfImages?: number;
  fadeAnimation?: boolean;
  /** When false, the component stops tracking/showing images (used for hover-triggered galleries). */
  active?: boolean;
}

export function ImageCursorTrail({
  items,
  children,
  className,
  maxNumberOfImages = 5,
  imgClass = "w-40 h-48",
  distance = 20,
  fadeAnimation = false,
  active = true,
}: ImageMouseTrailProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const refs = useRef(items.map(() => createRef<HTMLImageElement>()));
  const currentZIndexRef = useRef(1);
  const globalIndexRef = useRef(0);
  const lastRef = useRef({ x: 0, y: 0 });

  const activate = (image: HTMLImageElement, x: number, y: number) => {
    const containerRect = containerRef.current?.getBoundingClientRect();
    if (!containerRect) return;
    const relativeX = x - containerRect.left;
    const relativeY = y - containerRect.top;
    image.style.left = `${relativeX}px`;
    image.style.top = `${relativeY}px`;

    if (currentZIndexRef.current > 40) {
      currentZIndexRef.current = 1;
    }
    image.style.zIndex = String(currentZIndexRef.current);
    currentZIndexRef.current++;

    image.dataset.status = "active";
    if (fadeAnimation) {
      setTimeout(() => {
        image.dataset.status = "inactive";
      }, 1500);
    }
    lastRef.current = { x, y };
  };

  const deactivate = (image: HTMLImageElement) => {
    image.dataset.status = "inactive";
  };

  useEffect(() => {
    if (!active) {
      refs.current.forEach((r) => {
        if (r.current) r.current.dataset.status = "inactive";
      });
      return;
    }

    function handlePoint(clientX: number, clientY: number) {
      const rect = containerRef.current?.getBoundingClientRect();
      if (!rect) return;
      const inside =
        clientX >= rect.left &&
        clientX <= rect.right &&
        clientY >= rect.top &&
        clientY <= rect.bottom;
      if (!inside) return;

      const distFromLast = Math.hypot(clientX - lastRef.current.x, clientY - lastRef.current.y);
      if (distFromLast > window.innerWidth / distance) {
        const lead = refs.current[globalIndexRef.current % refs.current.length].current;
        const tail =
          refs.current[
            (globalIndexRef.current - maxNumberOfImages) % refs.current.length
          ]?.current;
        if (lead) activate(lead, clientX, clientY);
        if (tail) deactivate(tail);
        globalIndexRef.current++;
      }
    }

    function onMouseMove(e: MouseEvent) {
      handlePoint(e.clientX, e.clientY);
    }
    function onTouchMove(e: TouchEvent) {
      const t = e.touches[0];
      if (t) handlePoint(t.clientX, t.clientY);
    }

    window.addEventListener("mousemove", onMouseMove);
    window.addEventListener("touchmove", onTouchMove);
    return () => {
      window.removeEventListener("mousemove", onMouseMove);
      window.removeEventListener("touchmove", onTouchMove);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [active, distance, maxNumberOfImages, fadeAnimation]);

  return (
    <section
      ref={containerRef}
      className={cn(
        "relative grid h-[600px] w-full place-content-center overflow-hidden rounded-lg pointer-events-none",
        className
      )}
    >
      {items.map((item, index) => (
        {/* eslint-disable-next-line @next/next/no-img-element -- intentional: dynamic cursor-trail image, next/image not suitable here */}
        <img
          key={index}
          className={cn(
            "opacity:0 data-[status='active']:ease-out-expo pointer-events-none absolute -translate-x-[50%] -translate-y-[50%] scale-0 rounded-3xl object-cover transition-transform duration-300 data-[status='active']:scale-100 data-[status='active']:opacity-100 data-[status='active']:duration-500",
            imgClass
          )}
          data-index={index}
          data-status="inactive"
          src={item}
          alt={`saachi-ai-showcase-${index}`}
          ref={refs.current[index]}
        />
      ))}
      {children}
    </section>
  );
}

export default ImageCursorTrail;
