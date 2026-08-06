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
