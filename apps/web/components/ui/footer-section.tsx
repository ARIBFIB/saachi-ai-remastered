"use client";

import React from "react";
import type { ComponentProps, ReactNode } from "react";
import Link from "next/link";
import { motion, useReducedMotion } from "motion/react";
import { FacebookIcon, InstagramIcon, LinkedinIcon, YoutubeIcon } from "lucide-react";

interface FooterLink {
  title: string;
  href: string;
  icon?: React.ComponentType<{ className?: string }>;
}

interface FooterSection {
  label: string;
  links: FooterLink[];
}

const footerLinks: FooterSection[] = [
  {
    label: "Platform",
    links: [
      { title: "Browse courses", href: "/courses" },
      { title: "Pricing", href: "/pricing" },
      { title: "Become an instructor", href: "/register" },
      { title: "Mentorship", href: "/mentorship" }
    ]
  },
  {
    label: "Company",
    links: [
      { title: "About us", href: "/about" },
      { title: "Contact", href: "/contact" },
      { title: "Blog", href: "/blog" },
      { title: "News", href: "/news" }
    ]
  },
  {
    label: "Legal",
    links: [
      { title: "Terms & Conditions", href: "/legal/terms" },
      { title: "Privacy Policy", href: "/legal/privacy" },
      { title: "Refund Policy", href: "/legal/refund-policy" },
      { title: "Instructor Agreement", href: "/legal/instructor-agreement" }
    ]
  },
  {
    label: "Social",
    links: [
      { title: "Facebook", href: "#", icon: FacebookIcon },
      { title: "Instagram", href: "#", icon: InstagramIcon },
      { title: "Youtube", href: "#", icon: YoutubeIcon },
      { title: "LinkedIn", href: "#", icon: LinkedinIcon }
    ]
  }
];

export function Footer() {
  return (
    <footer className="relative mt-24 w-full border-t border-line bg-card px-6 py-12 lg:py-16">
      <div className="bg-accent-violet/20 absolute top-0 right-1/2 left-1/2 h-px w-1/3 -translate-x-1/2 -translate-y-1/2 rounded-full blur" />

      <div className="mx-auto grid w-full max-w-7xl gap-8 xl:grid-cols-3 xl:gap-8">
        <AnimatedContainer className="space-y-4">
          <Link href="/" className="font-display text-[20px] font-bold text-ink">
            Saachi<span className="text-gold-dark">AI</span>
          </Link>
          <p className="mt-8 max-w-[260px] text-sm text-ink-soft md:mt-4">
            A skills exchange for the AI era. Learn practical AI skills, and sell what you know.
          </p>
          <p className="text-sm text-ink-soft/70">
            &copy; {new Date().getFullYear()} Saachi AI. All rights reserved.
          </p>
        </AnimatedContainer>

        <div className="mt-10 grid grid-cols-2 gap-8 md:grid-cols-4 xl:col-span-2 xl:mt-0">
          {footerLinks.map((section, index) => (
            <AnimatedContainer key={section.label} delay={0.1 + index * 0.1}>
              <div className="mb-10 md:mb-0">
                <h3 className="text-xs font-semibold uppercase tracking-[0.06em] text-ink-soft/70">
                  {section.label}
                </h3>
                <ul className="mt-4 space-y-2 text-sm text-ink-soft">
                  {section.links.map((link) => (
                    <li key={link.title}>
                      <Link
                        href={link.href}
                        className="inline-flex items-center transition-colors duration-150 ease-out hover:text-ink"
                      >
                        {link.icon && <link.icon className="me-1.5 size-4" />}
                        {link.title}
                      </Link>
                    </li>
                  ))}
                </ul>
              </div>
            </AnimatedContainer>
          ))}
        </div>
      </div>
    </footer>
  );
}

type ViewAnimationProps = {
  delay?: number;
  className?: ComponentProps<typeof motion.div>["className"];
  children: ReactNode;
};

function AnimatedContainer({ className, delay = 0.1, children }: ViewAnimationProps) {
  const shouldReduceMotion = useReducedMotion();

  if (shouldReduceMotion) {
    return <>{children}</>;
  }

  return (
    <motion.div
      initial={{ filter: "blur(4px)", translateY: -8, opacity: 0 }}
      whileInView={{ filter: "blur(0px)", translateY: 0, opacity: 1 }}
      viewport={{ once: true }}
      transition={{ delay, duration: 0.8 }}
      className={className}
    >
      {children}
    </motion.div>
  );
}