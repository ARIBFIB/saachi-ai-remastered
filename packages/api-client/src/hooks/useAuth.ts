import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { authKeys } from "../query-keys";
import type { Session } from "../types";
import type { LoginInput, RegisterInput } from "@saachi/utils";
import { DUMMY_SESSION } from "../dummy-data";

const SESSION_COOKIE = "saachi_session";
const SESSION_STORAGE_KEY = "saachi_demo_session";

function setSessionCookie() {
  if (typeof document === "undefined") return;
  document.cookie = `${SESSION_COOKIE}=demo_token; path=/; max-age=${60 * 60 * 24 * 7}`;
}

function clearSessionCookie() {
  if (typeof document === "undefined") return;
  document.cookie = `${SESSION_COOKIE}=; path=/; max-age=0`;
}

function readStoredSession(): Session | null {
  if (typeof window === "undefined") return null;
  const raw = window.localStorage.getItem(SESSION_STORAGE_KEY);
  if (!raw) return null;
  try {
    return JSON.parse(raw) as Session;
  } catch {
    return null;
  }
}

function storeSession(session: Session) {
  if (typeof window === "undefined") return;
  window.localStorage.setItem(SESSION_STORAGE_KEY, JSON.stringify(session));
}

function clearStoredSession() {
  if (typeof window === "undefined") return;
  window.localStorage.removeItem(SESSION_STORAGE_KEY);
}

function delay<T>(value: T, ms = 500): Promise<T> {
  return new Promise((resolve) => setTimeout(() => resolve(value), ms));
}

// NOTE: Demo mode. There is no backend yet, so login/register accept ANY
// email/password and create a local mock session. Swap these mutationFns
// for real apiRequest(...) calls once the NestJS backend is available.

export function useSession() {
  return useQuery({
    queryKey: authKeys.session,
    queryFn: async () => readStoredSession(),
    staleTime: 60 * 1000
  });
}

export function useLogin() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: LoginInput) => {
      const session: Session = {
        ...DUMMY_SESSION,
        email: input.email || DUMMY_SESSION.email
      };
      return delay(session);
    },
    onSuccess: (session) => {
      storeSession(session);
      setSessionCookie();
      queryClient.setQueryData(authKeys.session, session);
    }
  });
}

export function useRegister() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: RegisterInput) => {
      const session: Session = {
        ...DUMMY_SESSION,
        fullName: input.fullName,
        email: input.email,
        role: input.role === "instructor" ? "instructor" : "learner"
      };
      return delay(session);
    },
    onSuccess: (session) => {
      storeSession(session);
      setSessionCookie();
      queryClient.setQueryData(authKeys.session, session);
    }
  });
}

export function useLogout() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async () => {
      clearStoredSession();
      clearSessionCookie();
      return delay(undefined, 200);
    },
    onSuccess: () => {
      queryClient.clear();
    }
  });
}