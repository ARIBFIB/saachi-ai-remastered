"use client";

import * as React from "react";
import * as DropdownMenuPrimitive from "@radix-ui/react-dropdown-menu";
import { Circle } from "lucide-react";
import { cn } from "@saachi/ui";

const DropdownMenu = DropdownMenuPrimitive.Root;
const DropdownMenuTrigger = DropdownMenuPrimitive.Trigger;
const DropdownMenuGroup = DropdownMenuPrimitive.Group;
const DropdownMenuPortal = DropdownMenuPrimitive.Portal;
const DropdownMenuRadioGroup = DropdownMenuPrimitive.RadioGroup;

type DropdownContentProps = React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.Content>;
type DropdownItemProps = React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.Item> & { inset?: boolean };
type DropdownRadioItemProps = React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.RadioItem>;
type DropdownLabelProps = React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.Label> & { inset?: boolean };
type DropdownSeparatorProps = React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.Separator>;

const DropdownMenuContent = React.forwardRef<React.ElementRef<typeof DropdownMenuPrimitive.Content>, DropdownContentProps>(
  function DropdownMenuContent({ className, sideOffset = 6, ...props }, ref) {
    return (
      <DropdownMenuPrimitive.Portal>
        <DropdownMenuPrimitive.Content
          ref={ref}
          sideOffset={sideOffset}
          className={cn(
            "z-50 min-w-[8rem] overflow-hidden rounded-card border border-line bg-card p-1 shadow-lg",
            "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
            "data-[side=bottom]:slide-in-from-top-2 data-[side=top]:slide-in-from-bottom-2",
            className
          )}
          {...props}
        />
      </DropdownMenuPrimitive.Portal>
    );
  }
);
DropdownMenuContent.displayName = DropdownMenuPrimitive.Content.displayName;

const DropdownMenuItem = React.forwardRef<React.ElementRef<typeof DropdownMenuPrimitive.Item>, DropdownItemProps>(
  function DropdownMenuItem({ className, inset, ...props }, ref) {
    return (
      <DropdownMenuPrimitive.Item
        ref={ref}
        className={cn(
          "relative flex cursor-pointer select-none items-center gap-1.5 rounded-control px-2.5 py-2 text-[13.5px] font-medium text-ink outline-none transition-colors",
          "focus:bg-paper-dim data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
          inset && "pl-8",
          className
        )}
        {...props}
      />
    );
  }
);
DropdownMenuItem.displayName = DropdownMenuPrimitive.Item.displayName;

const DropdownMenuRadioItem = React.forwardRef<React.ElementRef<typeof DropdownMenuPrimitive.RadioItem>, DropdownRadioItemProps>(
  function DropdownMenuRadioItem({ className, children, ...props }, ref) {
    return (
      <DropdownMenuPrimitive.RadioItem
        ref={ref}
        className={cn(
          "relative flex cursor-pointer select-none items-center gap-1.5 rounded-control py-2 pl-8 pr-2.5 text-[13.5px] font-medium text-ink outline-none transition-colors",
          "focus:bg-paper-dim data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
          className
        )}
        {...props}
      >
        <span className="absolute left-2.5 flex h-3.5 w-3.5 items-center justify-center">
          <DropdownMenuPrimitive.ItemIndicator>
            <Circle className="h-2 w-2 fill-current text-gold-dark" />
          </DropdownMenuPrimitive.ItemIndicator>
        </span>
        {children}
      </DropdownMenuPrimitive.RadioItem>
    );
  }
);
DropdownMenuRadioItem.displayName = DropdownMenuPrimitive.RadioItem.displayName;

const DropdownMenuLabel = React.forwardRef<React.ElementRef<typeof DropdownMenuPrimitive.Label>, DropdownLabelProps>(
  function DropdownMenuLabel({ className, inset, ...props }, ref) {
    return (
      <DropdownMenuPrimitive.Label
        ref={ref}
        className={cn("px-2.5 py-1.5 text-[12px] font-semibold text-ink-soft", inset && "pl-8", className)}
        {...props}
      />
    );
  }
);
DropdownMenuLabel.displayName = DropdownMenuPrimitive.Label.displayName;

const DropdownMenuSeparator = React.forwardRef<React.ElementRef<typeof DropdownMenuPrimitive.Separator>, DropdownSeparatorProps>(
  function DropdownMenuSeparator({ className, ...props }, ref) {
    return <DropdownMenuPrimitive.Separator ref={ref} className={cn("-mx-1 my-1 h-px bg-line", className)} {...props} />;
  }
);
DropdownMenuSeparator.displayName = DropdownMenuPrimitive.Separator.displayName;

export {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuRadioItem,
  DropdownMenuRadioGroup,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuGroup,
  DropdownMenuPortal
};
