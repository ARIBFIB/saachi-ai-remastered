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
  images: {
    remotePatterns: [
      { protocol: "https", hostname: "**.cloudfront.net" },
      { protocol: "https", hostname: "res.cloudinary.com" },
      { protocol: "https", hostname: "picsum.photos" }
    ]
  },
  async rewrites() {
    return [
      {
        source: "/api/proxy/:path*",
        destination: `${API_URL}/:path*`
      }
    ];
  }
};

module.exports = nextConfig;