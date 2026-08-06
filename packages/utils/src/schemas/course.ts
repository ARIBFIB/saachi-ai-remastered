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
