"use client";

import { create } from "zustand";

export type BottomPanelTabKind = "details" | "log" | "info";

export type BottomPanelDetailRow = {
  label: string;
  value: string;
};

export type BottomPanelTab = {
  id: string;
  title: string;
  kind: BottomPanelTabKind;
  rows: BottomPanelDetailRow[];
};

type BottomPanelState = {
  isOpen: boolean;
  height: number;
  tabs: BottomPanelTab[];
  activeTabId: string | null;
  openTab: (tab: BottomPanelTab) => void;
  closeTab: (id: string) => void;
  closeAllTabs: () => void;
  setActiveTab: (id: string) => void;
  setHeight: (height: number) => void;
  togglePanel: () => void;
  collapse: () => void;
};

export const MIN_PANEL_HEIGHT = 140;
export const MAX_PANEL_HEIGHT = 640;
export const DEFAULT_PANEL_HEIGHT = 260;

export const useBottomPanelStore = create<BottomPanelState>((set, get) => ({
  isOpen: false,
  height: DEFAULT_PANEL_HEIGHT,
  tabs: [],
  activeTabId: null,

  openTab: (tab) => {
    const existing = get().tabs.find((t) => t.id === tab.id);
    if (existing) {
      set((state) => ({
        tabs: state.tabs.map((t) => (t.id === tab.id ? tab : t)),
        activeTabId: tab.id,
        isOpen: true,
      }));
      return;
    }
    set((state) => ({
      tabs: [...state.tabs, tab],
      activeTabId: tab.id,
      isOpen: true,
    }));
  },

  closeTab: (id) => {
    set((state) => {
      const remaining = state.tabs.filter((t) => t.id !== id);
      const wasActive = state.activeTabId === id;
      const nextActive = wasActive
        ? (remaining[remaining.length - 1]?.id ?? null)
        : state.activeTabId;
      return {
        tabs: remaining,
        activeTabId: nextActive,
        isOpen: remaining.length > 0 ? state.isOpen : false,
      };
    });
  },

  closeAllTabs: () => set({ tabs: [], activeTabId: null, isOpen: false }),
  setActiveTab: (id) => set({ activeTabId: id }),

  setHeight: (height) => {
    const clamped = Math.min(MAX_PANEL_HEIGHT, Math.max(MIN_PANEL_HEIGHT, height));
    set({ height: clamped });
  },

  togglePanel: () => set((state) => ({ isOpen: !state.isOpen })),
  collapse: () => set({ isOpen: false }),
}));