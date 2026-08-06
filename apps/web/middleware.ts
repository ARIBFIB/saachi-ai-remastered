import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

const LEARNER_PREFIX = "/dashboard";
const INSTRUCTOR_PREFIX = "/instructor";

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const sessionCookie = request.cookies.get("saachi_session");

  const isProtected =
    pathname.startsWith(LEARNER_PREFIX) || pathname.startsWith(INSTRUCTOR_PREFIX);

  if (isProtected && !sessionCookie) {
    const loginUrl = new URL("/login", request.url);
    loginUrl.searchParams.set("redirect", pathname);
    return NextResponse.redirect(loginUrl);
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/dashboard/:path*", "/instructor/:path*"]
};
