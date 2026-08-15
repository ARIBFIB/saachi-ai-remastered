"use client";

import { useQuery } from "@tanstack/react-query";
import { DUMMY_NEWS, type NewsArticle } from "../dummy-data-news";
import { DUMMY_BLOG_POSTS, type BlogPost } from "../dummy-data-blog";
import { DUMMY_COMMUNITY_POSTS, type CommunityPost } from "../dummy-data-community";
import { DUMMY_CERTIFICATES, type CertificateRecord } from "../dummy-data-certificates";

function delay<T>(value: T, ms = 300): Promise<T> {
  return new Promise((resolve) => setTimeout(() => resolve(value), ms));
}

export type ContentSearchFilters = { search?: string };

export function useNewsList(filters: ContentSearchFilters = {}) {
  return useQuery({
    queryKey: ["news", "list", filters],
    queryFn: async () => {
      let items = [...DUMMY_NEWS];
      if (filters.search) {
        const q = filters.search.toLowerCase();
        items = items.filter((n) => n.title.toLowerCase().includes(q) || n.excerpt.toLowerCase().includes(q) || n.category.toLowerCase().includes(q));
      }
      return delay(items);
    }
  });
}

export function useNewsDetail(slug: string) {
  return useQuery({
    queryKey: ["news", "detail", slug],
    queryFn: async () => {
      const found = DUMMY_NEWS.find((n) => n.slug === slug);
      if (!found) throw new Error("Article not found");
      return delay(found);
    },
    enabled: Boolean(slug)
  });
}

export function useBlogList(filters: ContentSearchFilters = {}) {
  return useQuery({
    queryKey: ["blog", "list", filters],
    queryFn: async () => {
      let items = [...DUMMY_BLOG_POSTS];
      if (filters.search) {
        const q = filters.search.toLowerCase();
        items = items.filter((b) => b.title.toLowerCase().includes(q) || b.excerpt.toLowerCase().includes(q) || b.tag.toLowerCase().includes(q));
      }
      return delay(items);
    }
  });
}

export function useBlogDetail(slug: string) {
  return useQuery({
    queryKey: ["blog", "detail", slug],
    queryFn: async () => {
      const found = DUMMY_BLOG_POSTS.find((b) => b.slug === slug);
      if (!found) throw new Error("Post not found");
      return delay(found);
    },
    enabled: Boolean(slug)
  });
}

export function useCommunityList(filters: ContentSearchFilters = {}) {
  return useQuery({
    queryKey: ["community", "list", filters],
    queryFn: async () => {
      let items = [...DUMMY_COMMUNITY_POSTS];
      if (filters.search) {
        const q = filters.search.toLowerCase();
        items = items.filter((c) => c.title.toLowerCase().includes(q) || c.body.toLowerCase().includes(q) || c.category.toLowerCase().includes(q));
      }
      return delay(items);
    }
  });
}

export function useCommunityDetail(id: string) {
  return useQuery({
    queryKey: ["community", "detail", id],
    queryFn: async () => {
      const found = DUMMY_COMMUNITY_POSTS.find((c) => c.id === id);
      if (!found) throw new Error("Post not found");
      return delay(found);
    },
    enabled: Boolean(id)
  });
}

export function useCertificateList(filters: ContentSearchFilters = {}) {
  return useQuery({
    queryKey: ["certificates", "list", filters],
    queryFn: async () => {
      let items = [...DUMMY_CERTIFICATES];
      if (filters.search) {
        const q = filters.search.toLowerCase();
        items = items.filter((c) => c.courseTitle.toLowerCase().includes(q) || c.learnerName.toLowerCase().includes(q) || c.category.toLowerCase().includes(q));
      }
      return delay(items);
    }
  });
}

export type { NewsArticle, BlogPost, CommunityPost, CertificateRecord };