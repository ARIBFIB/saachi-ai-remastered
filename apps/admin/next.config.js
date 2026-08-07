/** @type {import("next").NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ["@saachi/ui", "@saachi/api-client", "@saachi/utils", "@saachi/store"],
  async rewrites() {
    return [
      {
        source: "/api/proxy/:path*",
        destination: `${process.env.NEXT_PUBLIC_API_URL}/admin/:path*`
      }
    ];
  }
};

module.exports = nextConfig;
