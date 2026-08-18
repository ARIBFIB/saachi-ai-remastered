"use client";

import * as React from "react";
import { motion } from "framer-motion";
import { ChevronDown, TrendingUp } from "lucide-react";
import { Card, Button, cn } from "@saachi/ui";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger
} from "@/components/ui/dropdown-menu";

// NOTE: demo-only. No backend learning-activity endpoint exists yet; this
// renders static per-range dummy data. The dropdown only swaps which local
// dataset is shown - no network request is made.

interface ActivityDataPoint {
  day: string;
  value: number;
}

interface ActivityChartCardProps {
  title?: string;
  className?: string;
}

const RANGE_DATA: Record<string, { total: string; trend: string; points: ActivityDataPoint[] }> = {
  Weekly: {
    total: "12h",
    trend: "+8% from last week",
    points: [
      { day: "S", value: 1 },
      { day: "M", value: 2.5 },
      { day: "T", value: 1.5 },
      { day: "W", value: 3 },
      { day: "T", value: 1 },
      { day: "F", value: 2 },
      { day: "S", value: 1 }
    ]
  },
  Monthly: {
    total: "46h",
    trend: "+15% from last month",
    points: [
      { day: "W1", value: 10 },
      { day: "W2", value: 14 },
      { day: "W3", value: 8 },
      { day: "W4", value: 14 }
    ]
  },
  Yearly: {
    total: "310h",
    trend: "+22% from last year",
    points: [
      { day: "Q1", value: 60 },
      { day: "Q2", value: 90 },
      { day: "Q3", value: 70 },
      { day: "Q4", value: 90 }
    ]
  }
};

const RANGES = Object.keys(RANGE_DATA);

const chartVariants = {
  hidden: { opacity: 0 },
  visible: { opacity: 1, transition: { staggerChildren: 0.08 } }
};

const barVariants = {
  hidden: { scaleY: 0, opacity: 0, transformOrigin: "bottom" as const },
  visible: {
    scaleY: 1,
    opacity: 1,
    transformOrigin: "bottom" as const,
    transition: { duration: 0.45, ease: [0.4, 0, 0.2, 1] as const }
  }
};

export const ActivityChartCard = ({ title = "Learning activity", className }: ActivityChartCardProps) => {
  const [selectedRange, setSelectedRange] = React.useState(RANGES[0]);
  const { total, trend, points } = RANGE_DATA[selectedRange];

  const maxValue = React.useMemo(() => points.reduce((max, p) => (p.value > max ? p.value : max), 0), [points]);

  return (
    <Card className={cn("w-full p-6", className)} aria-labelledby="activity-card-title">
      <div className="mb-5 flex items-center justify-between">
        <h2 id="activity-card-title" className="font-display text-[16px] font-semibold text-ink">
          {title}
        </h2>
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="secondary" size="sm" className="flex items-center gap-1">
              {selectedRange}
              <ChevronDown size={14} />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            {RANGES.map((option) => (
              <DropdownMenuItem key={option} onSelect={() => setSelectedRange(option)}>
                {option}
              </DropdownMenuItem>
            ))}
          </DropdownMenuContent>
        </DropdownMenu>
      </div>

      <div className="flex flex-col items-start gap-5 sm:flex-row sm:items-end">
        <div className="flex shrink-0 flex-col">
          <p className="font-display text-[36px] font-bold tracking-tight text-ink">{total}</p>
          <p className="mt-1 flex items-center gap-1 text-[12.5px] text-ink-soft">
            <TrendingUp size={14} className="text-teal" />
            {trend}
          </p>
        </div>

        <motion.div
          key={selectedRange}
          className="flex h-28 w-full items-end justify-between gap-2"
          variants={chartVariants}
          initial="hidden"
          animate="visible"
          aria-label="Learning activity chart"
        >
          {points.map((item, index) => (
            <div key={index} className="flex h-full w-full flex-col items-center justify-end gap-2" role="presentation">
              <motion.div
                className="w-full rounded-md bg-gold"
                style={{ height: `${maxValue > 0 ? (item.value / maxValue) * 100 : 0}%` }}
                variants={barVariants}
                aria-label={`${item.day}: ${item.value}h`}
              />
              <span className="text-[11px] text-ink-soft">{item.day}</span>
            </div>
          ))}
        </motion.div>
      </div>
    </Card>
  );
};

export default ActivityChartCard;
