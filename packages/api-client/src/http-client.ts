export type ApiError = {
  code: string;
  message: string;
  fieldErrors?: Record<string, string[]>;
};

export class ApiRequestError extends Error {
  code: string;
  fieldErrors?: Record<string, string[]>;
  status: number;

  constructor(status: number, error: ApiError) {
    super(error.message);
    this.name = "ApiRequestError";
    this.status = status;
    this.code = error.code;
    this.fieldErrors = error.fieldErrors;
  }
}

type RequestOptions = {
  method?: "GET" | "POST" | "PATCH" | "PUT" | "DELETE";
  body?: unknown;
  params?: Record<string, string | number | boolean | undefined>;
  signal?: AbortSignal;
};

function buildUrl(path: string, params?: RequestOptions["params"]): string {
  const base = process.env.NEXT_PUBLIC_API_URL ?? "";
  const url = new URL(path.replace(/^\//, ""), base.endsWith("/") ? base : `${base}/`);
  if (params) {
    Object.entries(params).forEach(([key, value]) => {
      if (value !== undefined) url.searchParams.set(key, String(value));
    });
  }
  return url.toString();
}

export async function apiRequest<TResponse>(
  path: string,
  options: RequestOptions = {}
): Promise<TResponse> {
  const { method = "GET", body, params, signal } = options;

  const response = await fetch(buildUrl(path, params), {
    method,
    credentials: "include",
    headers: {
      "Content-Type": "application/json"
    },
    body: body ? JSON.stringify(body) : undefined,
    signal
  });

  if (!response.ok) {
    let errorPayload: ApiError = { code: "unknown_error", message: "Something went wrong" };
    try {
      errorPayload = await response.json();
    } catch {
      // response had no JSON body
    }
    throw new ApiRequestError(response.status, errorPayload);
  }

  if (response.status === 204) return undefined as TResponse;
  return response.json() as Promise<TResponse>;
}
