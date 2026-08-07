"use client";

import { useEffect } from "react";
import { useNotificationStore } from "@saachi/store";

const DEMO_MESSAGES = [
  { title: "New course recommendation", body: "Based on your activity, you might like AI Automation & Workflow Tools.", type: "system" as const },
  { title: "Instructor replied", body: "Your question in the course Q&A received a new reply.", type: "community" as const },
  { title: "Payment reminder", body: "A saved cart item has a limited-time coupon expiring soon.", type: "payment" as const }
];

export function useRealtimeNotifications(enabled: boolean) {
  useEffect(() => {
    if (!enabled) return;

    const interval = setInterval(() => {
      const msg = DEMO_MESSAGES[Math.floor(Math.random() * DEMO_MESSAGES.length)];
      const store = useNotificationStore.getState();
      const alreadyExists = store.items.some((n) => n.title === msg.title && !n.read);
      if (alreadyExists) return;

      useNotificationStore.setState({
        items: [
          {
            id: `ntf_rt_${Date.now()}`,
            title: msg.title,
            body: msg.body,
            type: msg.type,
            createdAt: new Date().toISOString(),
            read: false
          },
          ...store.items
        ]
      });
    }, 45000);

    return () => clearInterval(interval);
  }, [enabled]);
}