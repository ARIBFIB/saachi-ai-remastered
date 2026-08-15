"use client"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Separator } from "@/components/ui/separator"
import { Quote, Star } from "lucide-react"
import { motion, useAnimation, useInView } from "framer-motion"
import { useEffect, useRef, useState } from "react"

export interface Testimonial {
  id: number
  name: string
  role: string
  company: string
  content: string
  rating: number
  avatar: string
}

export interface AnimatedTestimonialsProps {
  title?: string
  subtitle?: string
  badgeText?: string
  testimonials?: Testimonial[]
  autoRotateInterval?: number
  trustedCompanies?: string[]
  trustedCompaniesTitle?: string
  className?: string
}

export function AnimatedTestimonials({
  title = "Loved by the community",
  subtitle = "Don't just take our word for it. See what learners have to say.",
  badgeText = "Trusted by learners",
  testimonials = [],
  autoRotateInterval = 6000,
  trustedCompanies = [],
  trustedCompaniesTitle = "Trusted by learners from companies worldwide",
  className,
}: AnimatedTestimonialsProps) {
  const [activeIndex, setActiveIndex] = useState(0)

  const sectionRef = useRef(null)
  const isInView = useInView(sectionRef, { once: true, amount: 0.2 })
  const controls = useAnimation()

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: { staggerChildren: 0.1, delayChildren: 0.2 },
    },
  }

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: { duration: 0.5, ease: "easeOut" },
    },
  }

  useEffect(() => {
    if (isInView) controls.start("visible")
  }, [isInView, controls])

  useEffect(() => {
    if (autoRotateInterval <= 0 || testimonials.length <= 1) return
    const interval = setInterval(() => {
      setActiveIndex((current) => (current + 1) % testimonials.length)
    }, autoRotateInterval)
    return () => clearInterval(interval)
  }, [autoRotateInterval, testimonials.length])

  if (testimonials.length === 0) return null

  return (
    <section
      ref={sectionRef}
      id="testimonials"
      className={`py-24 overflow-hidden bg-paper-dim/40 ${className ?? ""}`}
    >
      <div className="mx-auto max-w-7xl px-4 md:px-8">
        <motion.div
          initial="hidden"
          animate={controls}
          variants={containerVariants}
          className="grid grid-cols-1 gap-16 w-full md:grid-cols-2 lg:gap-24"
        >
          <motion.div variants={itemVariants} className="flex flex-col justify-center">
            <div className="space-y-6">
              {badgeText && (
                <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[12px] font-semibold bg-gold-tint text-gold-dark border border-gold-dark/20">
                  <Star className="h-3.5 w-3.5 fill-gold-dark" />
                  {badgeText}
                </div>
              )}

              <h2 className="font-display text-3xl font-bold tracking-tight text-ink sm:text-4xl md:text-5xl">
                {title}
              </h2>

              <p className="max-w-[520px] text-[15px] leading-relaxed text-ink-soft md:text-[17px]">
                {subtitle}
              </p>

              <div className="flex items-center gap-3 pt-4">
                {testimonials.map((_, index) => (
                  <button
                    key={index}
                    onClick={() => setActiveIndex(index)}
                    className={`h-2.5 rounded-full transition-all duration-300 ${
                      activeIndex === index
                        ? "w-10 bg-accent-violet"
                        : "w-2.5 bg-line-strong"
                    }`}
                    aria-label={`View testimonial ${index + 1}`}
                  />
                ))}
              </div>
            </div>
          </motion.div>

          <motion.div
            variants={itemVariants}
            className="relative h-full mr-10 min-h-[300px] md:min-h-[400px]"
          >
            {testimonials.map((testimonial, index) => (
              <motion.div
                key={testimonial.id}
                className="absolute inset-0"
                initial={{ opacity: 0, x: 100 }}
                animate={{
                  opacity: activeIndex === index ? 1 : 0,
                  x: activeIndex === index ? 0 : 100,
                  scale: activeIndex === index ? 1 : 0.9,
                }}
                transition={{ duration: 0.5, ease: "easeInOut" }}
                style={{ zIndex: activeIndex === index ? 10 : 0 }}
              >
                <div className="rounded-card border border-line bg-card shadow-lg p-8 h-full flex flex-col">
                  <div className="mb-6 flex gap-1">
                    {Array(testimonial.rating)
                      .fill(0)
                      .map((_, i) => (
                        <Star key={i} className="h-5 w-5 fill-gold-dark text-gold-dark" />
                      ))}
                  </div>

                  <div className="relative mb-6 flex-1">
                    <Quote className="absolute -top-2 -left-2 h-8 w-8 text-accent-violet/20 rotate-180" />
                    <p className="relative z-10 text-[16px] font-medium leading-relaxed text-ink">
                      &ldquo;{testimonial.content}&rdquo;
                    </p>
                  </div>

                  <Separator className="my-4" />

                  <div className="flex items-center gap-4">
                    <Avatar className="h-12 w-12 border border-line">
                      <AvatarImage src={testimonial.avatar} alt={testimonial.name} />
                      <AvatarFallback>{testimonial.name.charAt(0)}</AvatarFallback>
                    </Avatar>
                    <div>
                      <h3 className="text-[14px] font-semibold text-ink">{testimonial.name}</h3>
                      <p className="text-[12.5px] text-ink-soft">
                        {testimonial.role}, {testimonial.company}
                      </p>
                    </div>
                  </div>
                </div>
              </motion.div>
            ))}

            <div className="absolute -bottom-6 -left-6 h-24 w-24 rounded-xl bg-accent-violet/5 pointer-events-none" />
            <div className="absolute -top-6 -right-6 h-24 w-24 rounded-xl bg-accent-pink/5 pointer-events-none" />
          </motion.div>
        </motion.div>

        {trustedCompanies.length > 0 && (
          <motion.div
            variants={itemVariants}
            initial="hidden"
            animate={controls}
            className="mt-24 text-center"
          >
            <h3 className="text-[12.5px] font-medium uppercase tracking-[0.08em] text-ink-soft/60 mb-8">
              {trustedCompaniesTitle}
            </h3>
            <div className="flex flex-wrap justify-center gap-x-12 gap-y-6">
              {trustedCompanies.map((company) => (
                <div
                  key={company}
                  className="font-display text-[18px] font-bold text-ink-soft/40 hover:text-ink-soft transition-colors"
                >
                  {company}
                </div>
              ))}
            </div>
          </motion.div>
        )}
      </div>
    </section>
  )
}