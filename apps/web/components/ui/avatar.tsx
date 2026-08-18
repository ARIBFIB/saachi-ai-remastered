"use client";

import * as React from "react";
import * as AvatarPrimitive from "@radix-ui/react-avatar";
import { cn } from "@saachi/ui";

type AvatarRootProps = React.ComponentPropsWithoutRef<typeof AvatarPrimitive.Root>;
type AvatarImageProps = React.ComponentPropsWithoutRef<typeof AvatarPrimitive.Image>;
type AvatarFallbackProps = React.ComponentPropsWithoutRef<typeof AvatarPrimitive.Fallback>;

const Avatar = React.forwardRef<React.ElementRef<typeof AvatarPrimitive.Root>, AvatarRootProps>(function Avatar(
  { className, ...props },
  ref
) {
  return (
    <AvatarPrimitive.Root
      ref={ref}
      className={cn("relative flex h-10 w-10 shrink-0 overflow-hidden rounded-full", className)}
      {...props}
    />
  );
});
Avatar.displayName = AvatarPrimitive.Root.displayName;

const AvatarImage = React.forwardRef<React.ElementRef<typeof AvatarPrimitive.Image>, AvatarImageProps>(
  function AvatarImage({ className, ...props }, ref) {
    return <AvatarPrimitive.Image ref={ref} className={cn("aspect-square h-full w-full object-cover", className)} {...props} />;
  }
);
AvatarImage.displayName = AvatarPrimitive.Image.displayName;

const AvatarFallback = React.forwardRef<React.ElementRef<typeof AvatarPrimitive.Fallback>, AvatarFallbackProps>(
  function AvatarFallback({ className, ...props }, ref) {
    return (
      <AvatarPrimitive.Fallback
        ref={ref}
        className={cn(
          "flex h-full w-full items-center justify-center rounded-full bg-gold-tint text-[13px] font-semibold text-gold-dark",
          className
        )}
        {...props}
      />
    );
  }
);
AvatarFallback.displayName = AvatarPrimitive.Fallback.displayName;

export { Avatar, AvatarImage, AvatarFallback };
