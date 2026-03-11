import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  images: { unoptimized: true },
  output: "export",
  distDir: "out",
  missingSuspenseWithCSRBailout: false,
};

export default nextConfig;
