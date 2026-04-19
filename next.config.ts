import path from "node:path";
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  images: { unoptimized: true },
  output: "export",
  distDir: "out",
  outputFileTracingRoot: path.resolve(import.meta.dirname),
  turbopack: {
    root: path.resolve(import.meta.dirname),
  },
};

export default nextConfig;
