/** @type {import("next").NextConfig} */
const API_URL = process.env.NEXT_PUBLIC_API_URL || "https://api.saachi.ai";

const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ["@saachi/ui", "@saachi/api-client", "@saachi/utils", "@saachi/store"],
  typescript: {
    ignoreBuildErrors: true
  },
  eslint: {
    ignoreDuringBuilds: true
  },
  async rewrites() {
    return [
      {
        source: "/api/proxy/:path*",
        destination: `${API_URL}/admin/:path*`
      }
    ];
  }
};

module.exports = nextConfig;