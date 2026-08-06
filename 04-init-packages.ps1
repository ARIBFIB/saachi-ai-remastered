# =============================================================
# Saachi AI Frontend - Step 4: Shared Packages
# Creates packages/ui, packages/api-client, packages/utils,
# packages/config - consumed by both apps/web and apps/admin
# =============================================================

$ProjectRoot = "D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2"
$PackagesRoot = Join-Path $ProjectRoot "packages"

Write-Host "=== Saachi AI Frontend Scaffold - Step 4 (packages) ===" -ForegroundColor Cyan

if (-not (Test-Path $PackagesRoot)) {
    Write-Host "ERROR: packages folder not found. Run 01-scaffold-monorepo.ps1 first." -ForegroundColor Red
    exit 1
}

# =================================================================
# packages/utils
# =================================================================
$UtilsRoot = Join-Path $PackagesRoot "utils"
Set-Location $UtilsRoot

$utilsPackageJson = @'
{
  "name": "@saachi/utils",
  "version": "0.1.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "dependencies": {
    "zod": "^3.23.0"
  },
  "devDependencies": {
    "typescript": "^5.5.0"
  }
}
'@
Set-Content -Path (Join-Path $UtilsRoot "package.json") -Value $utilsPackageJson -Encoding UTF8

$utilsTsconfig = @'
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020"],
    "module": "esnext",
    "moduleResolution": "bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "declaration": true,
    "jsx": "preserve"
  },
  "include": ["src"]
}
'@
Set-Content -Path (Join-Path $UtilsRoot "tsconfig.json") -Value $utilsTsconfig -Encoding UTF8

# --- Zod schemas: auth ---
$authSchemas = @'
import { z } from "zod";

export const loginSchema = z.object({
  email: z.string().email("Enter a valid email address"),
  password: z.string().min(8, "Password must be at least 8 characters")
});
export type LoginInput = z.infer<typeof loginSchema>;

export const registerSchema = z
  .object({
    fullName: z.string().min(2, "Full name is required"),
    email: z.string().email("Enter a valid email address"),
    password: z.string().min(8, "Password must be at least 8 characters"),
    confirmPassword: z.string(),
    role: z.enum(["learner", "instructor"]).default("learner")
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: "Passwords do not match",
    path: ["confirmPassword"]
  });
export type RegisterInput = z.infer<typeof registerSchema>;

export const forgotPasswordSchema = z.object({
  email: z.string().email("Enter a valid email address")
});
export type ForgotPasswordInput = z.infer<typeof forgotPasswordSchema>;

export const resetPasswordSchema = z
  .object({
    token: z.string().min(1),
    password: z.string().min(8, "Password must be at least 8 characters"),
    confirmPassword: z.string()
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: "Passwords do not match",
    path: ["confirmPassword"]
  });
export type ResetPasswordInput = z.infer<typeof resetPasswordSchema>;

export const twoFactorSchema = z.object({
  code: z.string().length(6, "Enter the 6-digit code")
});
export type TwoFactorInput = z.infer<typeof twoFactorSchema>;
'@
Set-Content -Path (Join-Path $UtilsRoot "src\schemas\auth.ts") -Value $authSchemas -Encoding UTF8

# --- Zod schemas: course ---
$courseSchemas = @'
import { z } from "zod";

export const courseBasicsSchema = z.object({
  title: z.string().min(5, "Title must be at least 5 characters").max(120),
  subtitle: z.string().max(180).optional(),
  categoryId: z.string().min(1, "Select a category"),
  tags: z.array(z.string()).max(10).default([]),
  language: z.string().min(1, "Select a language"),
  level: z.enum(["beginner", "intermediate", "advanced"])
});
export type CourseBasicsInput = z.infer<typeof courseBasicsSchema>;

export const coursePricingSchema = z.object({
  price: z.number().min(0, "Price cannot be negative"),
  currency: z.enum(["PKR", "USD", "GBP"]).default("USD"),
  subscriptionIncluded: z.boolean().default(false),
  couponEligible: z.boolean().default(true)
});
export type CoursePricingInput = z.infer<typeof coursePricingSchema>;

export const lessonSchema = z.object({
  title: z.string().min(3, "Lesson title is required"),
  type: z.enum(["video", "text", "quiz", "resource"]),
  content: z.string().optional(),
  durationSeconds: z.number().int().min(0).optional()
});
export type LessonInput = z.infer<typeof lessonSchema>;

export const moduleSchema = z.object({
  title: z.string().min(3, "Module title is required"),
  lessons: z.array(lessonSchema).default([])
});
export type ModuleInput = z.infer<typeof moduleSchema>;

export const curriculumSchema = z.object({
  modules: z.array(moduleSchema).min(1, "Add at least one module")
});
export type CurriculumInput = z.infer<typeof curriculumSchema>;
'@
Set-Content -Path (Join-Path $UtilsRoot "src\schemas\course.ts") -Value $courseSchemas -Encoding UTF8

# --- Zod schemas: checkout ---
$checkoutSchemas = @'
import { z } from "zod";

export const billingDetailsSchema = z.object({
  fullName: z.string().min(2, "Full name is required"),
  email: z.string().email("Enter a valid email address"),
  country: z.string().min(1, "Select a country"),
  address: z.string().optional(),
  city: z.string().optional(),
  postalCode: z.string().optional()
});
export type BillingDetailsInput = z.infer<typeof billingDetailsSchema>;

export const couponSchema = z.object({
  code: z.string().min(1, "Enter a coupon code")
});
export type CouponInput = z.infer<typeof couponSchema>;

export const paymentMethodSchema = z.object({
  gateway: z.enum(["stripe", "paypal", "easypaisa", "jazzcash", "bank_transfer"]),
  saveForFuture: z.boolean().default(false)
});
export type PaymentMethodInput = z.infer<typeof paymentMethodSchema>;
'@
Set-Content -Path (Join-Path $UtilsRoot "src\schemas\checkout.ts") -Value $checkoutSchemas -Encoding UTF8

# --- Formatting utils ---
$formatCurrency = @'
const CURRENCY_LOCALE: Record<string, string> = {
  USD: "en-US",
  PKR: "en-PK",
  GBP: "en-GB"
};

export function formatCurrency(amount: number, currency: string = "USD"): string {
  const locale = CURRENCY_LOCALE[currency] ?? "en-US";
  return new Intl.NumberFormat(locale, {
    style: "currency",
    currency,
    minimumFractionDigits: 2
  }).format(amount);
}

export function formatCompactNumber(value: number): string {
  return new Intl.NumberFormat("en-US", {
    notation: "compact",
    maximumFractionDigits: 1
  }).format(value);
}
'@
Set-Content -Path (Join-Path $UtilsRoot "src\formatting\currency.ts") -Value $formatCurrency -Encoding UTF8

$formatDate = @'
export function formatDate(input: string | Date, locale: string = "en-US"): string {
  const date = typeof input === "string" ? new Date(input) : input;
  return new Intl.DateTimeFormat(locale, {
    year: "numeric",
    month: "short",
    day: "numeric"
  }).format(date);
}

export function formatRelativeTime(input: string | Date): string {
  const date = typeof input === "string" ? new Date(input) : input;
  const diffMs = date.getTime() - Date.now();
  const diffMinutes = Math.round(diffMs / 60000);

  const rtf = new Intl.RelativeTimeFormat("en", { numeric: "auto" });

  if (Math.abs(diffMinutes) < 60) return rtf.format(diffMinutes, "minute");
  const diffHours = Math.round(diffMinutes / 60);
  if (Math.abs(diffHours) < 24) return rtf.format(diffHours, "hour");
  const diffDays = Math.round(diffHours / 24);
  return rtf.format(diffDays, "day");
}

export function formatDuration(totalSeconds: number): string {
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  if (hours > 0) return `${hours}h ${minutes}m`;
  return `${minutes}m`;
}
'@
Set-Content -Path (Join-Path $UtilsRoot "src\formatting\date.ts") -Value $formatDate -Encoding UTF8

# --- Constants ---
$constants = @'
export const INSTRUCTOR_TRUST_TIERS = [
  "new",
  "verified",
  "top_rated",
  "partner"
] as const;
export type InstructorTrustTier = (typeof INSTRUCTOR_TRUST_TIERS)[number];

export const ADMIN_ROLES = [
  "super_admin",
  "admin",
  "finance_officer",
  "support_officer"
] as const;
export type AdminRole = (typeof ADMIN_ROLES)[number];

export const COURSE_STATUS = [
  "draft",
  "pending_review",
  "published",
  "rejected",
  "archived"
] as const;
export type CourseStatus = (typeof COURSE_STATUS)[number];

export const PAYMENT_GATEWAYS = [
  "stripe",
  "paypal",
  "easypaisa",
  "jazzcash",
  "bank_transfer"
] as const;
export type PaymentGateway = (typeof PAYMENT_GATEWAYS)[number];
'@
Set-Content -Path (Join-Path $UtilsRoot "src\constants.ts") -Value $constants -Encoding UTF8

# --- index.ts (barrel export) ---
$utilsIndex = @'
export * from "./schemas/auth";
export * from "./schemas/course";
export * from "./schemas/checkout";
export * from "./formatting/currency";
export * from "./formatting/date";
export * from "./constants";
'@
Set-Content -Path (Join-Path $UtilsRoot "src\index.ts") -Value $utilsIndex -Encoding UTF8

Write-Host "packages/utils scaffolded (auth/course/checkout schemas, formatting, constants)." -ForegroundColor Green

# =================================================================
# packages/api-client
# =================================================================
$ApiClientRoot = Join-Path $PackagesRoot "api-client"
Set-Location $ApiClientRoot

$apiClientPackageJson = @'
{
  "name": "@saachi/api-client",
  "version": "0.1.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "dependencies": {
    "@tanstack/react-query": "^5.56.0",
    "@saachi/utils": "workspace:*"
  },
  "devDependencies": {
    "typescript": "^5.5.0",
    "@types/react": "^18.3.0"
  }
}
'@
Set-Content -Path (Join-Path $ApiClientRoot "package.json") -Value $apiClientPackageJson -Encoding UTF8

$apiClientTsconfig = @'
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["dom", "ES2020"],
    "module": "esnext",
    "moduleResolution": "bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "declaration": true,
    "jsx": "react-jsx"
  },
  "include": ["src"]
}
'@
Set-Content -Path (Join-Path $ApiClientRoot "tsconfig.json") -Value $apiClientTsconfig -Encoding UTF8

# --- Core fetch wrapper ---
$httpClient = @'
export type ApiError = {
  code: string;
  message: string;
  fieldErrors?: Record<string, string[]>;
};

export class ApiRequestError extends Error {
  code: string;
  fieldErrors?: Record<string, string[]>;
  status: number;

  constructor(status: number, error: ApiError) {
    super(error.message);
    this.name = "ApiRequestError";
    this.status = status;
    this.code = error.code;
    this.fieldErrors = error.fieldErrors;
  }
}

type RequestOptions = {
  method?: "GET" | "POST" | "PATCH" | "PUT" | "DELETE";
  body?: unknown;
  params?: Record<string, string | number | boolean | undefined>;
  signal?: AbortSignal;
};

function buildUrl(path: string, params?: RequestOptions["params"]): string {
  const base = process.env.NEXT_PUBLIC_API_URL ?? "";
  const url = new URL(path.replace(/^\//, ""), base.endsWith("/") ? base : `${base}/`);
  if (params) {
    Object.entries(params).forEach(([key, value]) => {
      if (value !== undefined) url.searchParams.set(key, String(value));
    });
  }
  return url.toString();
}

export async function apiRequest<TResponse>(
  path: string,
  options: RequestOptions = {}
): Promise<TResponse> {
  const { method = "GET", body, params, signal } = options;

  const response = await fetch(buildUrl(path, params), {
    method,
    credentials: "include",
    headers: {
      "Content-Type": "application/json"
    },
    body: body ? JSON.stringify(body) : undefined,
    signal
  });

  if (!response.ok) {
    let errorPayload: ApiError = { code: "unknown_error", message: "Something went wrong" };
    try {
      errorPayload = await response.json();
    } catch {
      // response had no JSON body
    }
    throw new ApiRequestError(response.status, errorPayload);
  }

  if (response.status === 204) return undefined as TResponse;
  return response.json() as Promise<TResponse>;
}
'@
Set-Content -Path (Join-Path $ApiClientRoot "src\http-client.ts") -Value $httpClient -Encoding UTF8

# --- Query key factories ---
$queryKeys = @'
export const courseKeys = {
  all: ["courses"] as const,
  list: (filters?: Record<string, unknown>) => ["courses", "list", filters] as const,
  detail: (id: string) => ["courses", "detail", id] as const,
  curriculum: (id: string) => ["courses", "curriculum", id] as const
};

export const authKeys = {
  session: ["auth", "session"] as const
};

export const cartKeys = {
  current: ["cart"] as const
};

export const enrollmentKeys = {
  myCourses: ["enrollments", "my-courses"] as const,
  progress: (courseId: string) => ["enrollments", "progress", courseId] as const
};

export const instructorKeys = {
  analytics: (instructorId: string) => ["instructor", "analytics", instructorId] as const,
  earnings: (instructorId: string) => ["instructor", "earnings", instructorId] as const,
  payouts: (instructorId: string) => ["instructor", "payouts", instructorId] as const
};

export const adminKeys = {
  users: (filters?: Record<string, unknown>) => ["admin", "users", filters] as const,
  moderationQueue: ["admin", "moderation-queue"] as const,
  transactions: (filters?: Record<string, unknown>) => ["admin", "transactions", filters] as const
};

export const notificationKeys = {
  list: ["notifications"] as const
};
'@
Set-Content -Path (Join-Path $ApiClientRoot "src\query-keys.ts") -Value $queryKeys -Encoding UTF8

# --- API types ---
$apiTypes = @'
export type UserRole = "learner" | "instructor" | "admin" | "super_admin";

export type Session = {
  id: string;
  fullName: string;
  email: string;
  role: UserRole;
  avatarUrl?: string;
};

export type Course = {
  id: string;
  slug: string;
  title: string;
  subtitle?: string;
  thumbnailUrl?: string;
  price: number;
  currency: string;
  rating: number;
  ratingCount: number;
  instructor: {
    id: string;
    fullName: string;
    avatarUrl?: string;
  };
  status: "draft" | "pending_review" | "published" | "rejected" | "archived";
};

export type Paginated<T> = {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
};
'@
Set-Content -Path (Join-Path $ApiClientRoot "src\types\index.ts") -Value $apiTypes -Encoding UTF8

# --- useAuth hook ---
$useAuth = @'
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiRequest } from "../http-client";
import { authKeys } from "../query-keys";
import type { Session } from "../types";
import type { LoginInput, RegisterInput } from "@saachi/utils";

export function useSession() {
  return useQuery({
    queryKey: authKeys.session,
    queryFn: () => apiRequest<Session>("/auth/session"),
    retry: false,
    staleTime: 60 * 1000
  });
}

export function useLogin() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: LoginInput) =>
      apiRequest<Session | { requires2fa: true }>("/auth/login", {
        method: "POST",
        body: input
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: authKeys.session });
    }
  });
}

export function useRegister() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: RegisterInput) =>
      apiRequest<Session>("/auth/register", { method: "POST", body: input }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: authKeys.session });
    }
  });
}

export function useLogout() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: () => apiRequest<void>("/auth/logout", { method: "POST" }),
    onSuccess: () => {
      queryClient.clear();
    }
  });
}
'@
Set-Content -Path (Join-Path $ApiClientRoot "src\hooks\useAuth.ts") -Value $useAuth -Encoding UTF8

# --- useCourses hook ---
$useCourses = @'
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiRequest } from "../http-client";
import { courseKeys } from "../query-keys";
import type { Course, Paginated } from "../types";

export type CourseListFilters = {
  category?: string;
  search?: string;
  priceMin?: number;
  priceMax?: number;
  level?: string;
  language?: string;
  sort?: string;
  page?: number;
};

export function useCourseList(filters: CourseListFilters = {}) {
  return useQuery({
    queryKey: courseKeys.list(filters),
    queryFn: () =>
      apiRequest<Paginated<Course>>("/courses", { params: filters as Record<string, any> })
  });
}

export function useCourseDetail(idOrSlug: string) {
  return useQuery({
    queryKey: courseKeys.detail(idOrSlug),
    queryFn: () => apiRequest<Course>(`/courses/${idOrSlug}`),
    enabled: Boolean(idOrSlug)
  });
}

export function useCreateCourse() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: Partial<Course>) =>
      apiRequest<Course>("/courses", { method: "POST", body: input }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: courseKeys.all });
    }
  });
}

export function useUpdateCourse(id: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: Partial<Course>) =>
      apiRequest<Course>(`/courses/${id}`, { method: "PATCH", body: input }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: courseKeys.detail(id) });
      queryClient.invalidateQueries({ queryKey: courseKeys.all });
    }
  });
}
'@
Set-Content -Path (Join-Path $ApiClientRoot "src\hooks\useCourses.ts") -Value $useCourses -Encoding UTF8

# --- api-client index.ts ---
$apiClientIndex = @'
export * from "./http-client";
export * from "./query-keys";
export * from "./types";
export * from "./hooks/useAuth";
export * from "./hooks/useCourses";
'@
Set-Content -Path (Join-Path $ApiClientRoot "src\index.ts") -Value $apiClientIndex -Encoding UTF8

Write-Host "packages/api-client scaffolded (http-client, query keys, useAuth, useCourses)." -ForegroundColor Green

# =================================================================
# packages/ui
# =================================================================
$UiRoot = Join-Path $PackagesRoot "ui"
Set-Location $UiRoot

$uiPackageJson = @'
{
  "name": "@saachi/ui",
  "version": "0.1.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "dependencies": {
    "clsx": "^2.1.0",
    "tailwind-merge": "^2.5.0",
    "lucide-react": "^0.445.0"
  },
  "peerDependencies": {
    "react": "^18.3.0"
  },
  "devDependencies": {
    "typescript": "^5.5.0",
    "@types/react": "^18.3.0"
  }
}
'@
Set-Content -Path (Join-Path $UiRoot "package.json") -Value $uiPackageJson -Encoding UTF8

$uiTsconfig = @'
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["dom", "ES2020"],
    "module": "esnext",
    "moduleResolution": "bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "declaration": true,
    "jsx": "react-jsx"
  },
  "include": ["src"]
}
'@
Set-Content -Path (Join-Path $UiRoot "tsconfig.json") -Value $uiTsconfig -Encoding UTF8

# --- cn utility ---
$cnUtil = @'
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
'@
Set-Content -Path (Join-Path $UiRoot "src\cn.ts") -Value $cnUtil -Encoding UTF8

# --- Button component ---
$buttonComponent = @'
import { forwardRef, type ButtonHTMLAttributes } from "react";
import { cn } from "../cn";

type ButtonVariant = "primary" | "secondary" | "ghost" | "danger";
type ButtonSize = "sm" | "md" | "lg";

export type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: ButtonVariant;
  size?: ButtonSize;
  loading?: boolean;
};

const variantStyles: Record<ButtonVariant, string> = {
  primary:
    "text-white shadow-[0_4px_20px_rgba(30,64,175,0.10)] hover:shadow-[0_0_32px_rgba(59,130,246,0.35)]",
  secondary:
    "border border-[var(--border-hairline,rgba(15,23,42,0.14))] bg-transparent hover:border-blue-400",
  ghost: "bg-transparent text-[var(--text-secondary,#475569)] hover:bg-[var(--surface-elevated,#F1F5F9)]",
  danger: "bg-red-500 text-white hover:bg-red-600"
};

const sizeStyles: Record<ButtonSize, string> = {
  sm: "h-9 px-4 text-sm",
  md: "h-11 px-5 text-[15px]",
  lg: "h-13 px-6 text-[17px]"
};

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = "primary", size = "md", loading, disabled, children, style, ...props }, ref) => {
    const isPrimary = variant === "primary";
    return (
      <button
        ref={ref}
        disabled={disabled || loading}
        className={cn(
          "inline-flex items-center justify-center rounded-full font-medium transition-all duration-200 ease-out disabled:opacity-60 disabled:pointer-events-none",
          variantStyles[variant],
          sizeStyles[size],
          className
        )}
        style={
          isPrimary
            ? {
                background:
                  "linear-gradient(135deg, #2563EB 0%, #0EA5E9 50%, #22D3EE 100%)",
                ...style
              }
            : style
        }
        {...props}
      >
        {loading ? "..." : children}
      </button>
    );
  }
);
Button.displayName = "Button";
'@
Set-Content -Path (Join-Path $UiRoot "src\components\Button.tsx") -Value $buttonComponent -Encoding UTF8

# --- Card component ---
$cardComponent = @'
import { forwardRef, type HTMLAttributes } from "react";
import { cn } from "../cn";

export type CardProps = HTMLAttributes<HTMLDivElement> & {
  featured?: boolean;
};

export const Card = forwardRef<HTMLDivElement, CardProps>(
  ({ className, featured, children, ...props }, ref) => {
    return (
      <div
        ref={ref}
        className={cn(
          "rounded-2xl border border-[var(--border-hairline,rgba(15,23,42,0.08))] bg-[var(--surface-card,#FFFFFF)] p-6 shadow-[0_2px_8px_rgba(30,64,175,0.06)] transition-all duration-200 ease-out hover:-translate-y-0.5 hover:shadow-[0_4px_20px_rgba(30,64,175,0.10)]",
          featured && "bg-gradient-to-br from-white to-blue-50",
          className
        )}
        {...props}
      >
        {children}
      </div>
    );
  }
);
Card.displayName = "Card";
'@
Set-Content -Path (Join-Path $UiRoot "src\components\Card.tsx") -Value $cardComponent -Encoding UTF8

# --- Badge component ---
$badgeComponent = @'
import type { HTMLAttributes } from "react";
import { cn } from "../cn";

type BadgeVariant = "default" | "success" | "warning" | "error" | "info";

export type BadgeProps = HTMLAttributes<HTMLSpanElement> & {
  variant?: BadgeVariant;
};

const variantStyles: Record<BadgeVariant, string> = {
  default: "bg-slate-100 text-slate-700",
  success: "bg-teal-50 text-teal-700",
  warning: "bg-amber-50 text-amber-700",
  error: "bg-red-50 text-red-700",
  info: "bg-blue-50 text-blue-700"
};

export function Badge({ className, variant = "default", children, ...props }: BadgeProps) {
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full px-3 py-1 text-xs font-medium",
        variantStyles[variant],
        className
      )}
      {...props}
    >
      {children}
    </span>
  );
}
'@
Set-Content -Path (Join-Path $UiRoot "src\components\Badge.tsx") -Value $badgeComponent -Encoding UTF8

# --- ui index.ts ---
$uiIndex = @'
export * from "./cn";
export * from "./components/Button";
export * from "./components/Card";
export * from "./components/Badge";
'@
Set-Content -Path (Join-Path $UiRoot "src\index.ts") -Value $uiIndex -Encoding UTF8

Write-Host "packages/ui scaffolded (Button, Card, Badge, cn utility)." -ForegroundColor Green

# =================================================================
# packages/config
# =================================================================
$ConfigRoot = Join-Path $PackagesRoot "config"
Set-Location $ConfigRoot

$configPackageJson = @'
{
  "name": "@saachi/config",
  "version": "0.1.0",
  "private": true
}
'@
Set-Content -Path (Join-Path $ConfigRoot "package.json") -Value $configPackageJson -Encoding UTF8

$baseTsconfig = @'
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["dom", "dom.iterable", "esnext"],
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true
  }
}
'@
Set-Content -Path (Join-Path $ConfigRoot "tsconfig.base.json") -Value $baseTsconfig -Encoding UTF8

$eslintBase = @'
{
  "extends": ["next/core-web-vitals"],
  "rules": {
    "@typescript-eslint/no-unused-vars": "warn"
  }
}
'@
Set-Content -Path (Join-Path $ConfigRoot "eslint-preset.json") -Value $eslintBase -Encoding UTF8

Write-Host "packages/config scaffolded (shared tsconfig base, eslint preset)." -ForegroundColor Green

Set-Location $ProjectRoot

Write-Host ""
Write-Host "=== Step 4 Complete ===" -ForegroundColor Cyan
Write-Host "All 4 shared packages scaffolded: ui, api-client, utils, config." -ForegroundColor Green
Write-Host ""
Write-Host "Now run from project root:" -ForegroundColor Yellow
Write-Host "  pnpm install" -ForegroundColor White
Write-Host "(this links workspace:* packages into apps/web and apps/admin)" -ForegroundColor Yellow
Write-Host ""
Write-Host "NEXT STEP: wire useSession/useLogin into app/(auth)/login page and test dev servers:" -ForegroundColor Yellow
Write-Host "  pnpm dev:web    (http://localhost:3000)" -ForegroundColor White
Write-Host "  pnpm dev:admin  (http://localhost:3001)" -ForegroundColor White