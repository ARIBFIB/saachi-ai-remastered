/** @type {import("next").NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ["@saachi/ui", "@saachi/api-client", "@saachi/utils", "@saachi/store"],
  images: {
    remotePatterns: [
      { protocol: "https", hostname: "**.cloudfront.net" },
      { protocol: "https", hostname: "res.cloudinary.com" }
    ]
  },
  async rewrites() {
    return [
      {
        source: "/api/proxy/:path*",
        destination: `${process.env.NEXT_PUBLIC_API_URL}/:path*`
      }
    ];
  }
};

module.exports = nextConfig;
