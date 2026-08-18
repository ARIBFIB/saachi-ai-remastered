"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import {
  UserCircle,
  Settings as SettingsIcon,
  Bell,
  GraduationCap,
  LogOut,
  Smile,
  Moon
} from "lucide-react";
import { useSession, useLogout } from "@saachi/api-client";
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuRadioGroup,
  DropdownMenuRadioItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger
} from "@/components/ui/dropdown-menu";

// NOTE: demo-only status toggle. Presence status has no backend concept yet -
// it's local UI state only and is not persisted or sent anywhere.

const STATUS_OPTIONS = [
  { value: "online", icon: Smile, label: "Active" },
  { value: "offline", icon: Moon, label: "Appear offline" }
];

function getInitials(name?: string) {
  if (!name) return "?";
  const parts = name.trim().split(/\s+/);
  const initials = parts.slice(0, 2).map((p) => p[0]?.toUpperCase() ?? "");
  return initials.join("") || "?";
}

export function UserDropdown() {
  const router = useRouter();
  const { data: session } = useSession();
  const logout = useLogout();
  const [status, setStatus] = useState("online");

  if (!session) return null;

  const initials = getInitials(session.fullName);

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <button type="button" aria-label="Open account menu" className="rounded-full outline-none">
          <Avatar className="cursor-pointer border border-line">
            <AvatarImage src={session.avatarUrl} alt={session.fullName} />
            <AvatarFallback>{initials}</AvatarFallback>
          </Avatar>
        </button>
      </DropdownMenuTrigger>

      <DropdownMenuContent className="w-[280px]" align="end">
        <div className="flex items-center gap-2.5 px-2.5 py-2">
          <Avatar className="border border-line">
            <AvatarImage src={session.avatarUrl} alt={session.fullName} />
            <AvatarFallback>{initials}</AvatarFallback>
          </Avatar>
          <div className="min-w-0 flex-1">
            <p className="truncate text-[13.5px] font-semibold text-ink">{session.fullName}</p>
            <p className="truncate text-[12px] text-ink-soft">{session.email}</p>
          </div>
          <Badge variant={status === "online" ? "teal" : "muted"}>
            {status === "online" ? "Active" : "Offline"}
          </Badge>
        </div>

        <DropdownMenuSeparator />

        <DropdownMenuGroup>
          <DropdownMenuRadioGroup value={status} onValueChange={setStatus}>
            {STATUS_OPTIONS.map((opt) => {
              const Icon = opt.icon;
              return (
                <DropdownMenuRadioItem key={opt.value} value={opt.value}>
                  <Icon size={15} className="text-ink-soft" />
                  {opt.label}
                </DropdownMenuRadioItem>
              );
            })}
          </DropdownMenuRadioGroup>
        </DropdownMenuGroup>

        <DropdownMenuSeparator />

        <DropdownMenuGroup>
          <DropdownMenuItem onClick={() => router.push("/settings")}>
            <UserCircle size={16} className="text-ink-soft" />
            Your profile
          </DropdownMenuItem>
          <DropdownMenuItem onClick={() => router.push("/notifications")}>
            <Bell size={16} className="text-ink-soft" />
            Notifications
          </DropdownMenuItem>
          <DropdownMenuItem onClick={() => router.push("/settings")}>
            <SettingsIcon size={16} className="text-ink-soft" />
            Settings
          </DropdownMenuItem>
          <DropdownMenuItem onClick={() => router.push("/become-instructor")}>
            <GraduationCap size={16} className="text-ink-soft" />
            Become an instructor
          </DropdownMenuItem>
        </DropdownMenuGroup>

        <DropdownMenuSeparator />

        <DropdownMenuGroup>
          <DropdownMenuItem onClick={() => logout.mutate()} className="text-error">
            <LogOut size={16} />
            Log out
          </DropdownMenuItem>
        </DropdownMenuGroup>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}

export default UserDropdown;
