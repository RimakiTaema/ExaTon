"use client";
import { useEffect, useState } from "react";
import { appendStatsPoint, buildStatsPoint, type StatsPoint } from "@/lib/server-stats";

export function useStatsHistory(stats: Record<string, unknown> | null | undefined): StatsPoint[] {
  const [history, setHistory] = useState<StatsPoint[]>([]);

  useEffect(() => {
    if (!stats) return;
    const point = buildStatsPoint(stats);
    if (!point) return;
    setHistory((prev) => appendStatsPoint(prev, point));
  }, [stats]);

  return history;
}
