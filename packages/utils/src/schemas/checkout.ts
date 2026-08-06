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
