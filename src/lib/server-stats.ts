export type StatsPoint = {
  time: string;
  ramMb: number;
  ramPercent: number;
  tps: number;
  tickMs: number;
};

export const MAX_STATS_POINTS = 30;

export const BEDROCK_IDS = ["bedrock", "pocketmine", "nukkit"];

export function isBedrock(softwareId: string | undefined): boolean {
  if (!softwareId) return false;
  return BEDROCK_IDS.includes(softwareId.toLowerCase());
}

export function nowTimeLabel(): string {
  return new Date().toLocaleTimeString([], {
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
  });
}

export function buildStatsPoint(stats: Record<string, unknown>): StatsPoint | null {
  const memory = stats.memory as Record<string, unknown> | undefined;
  const tps = stats.tps as number | undefined;
  const avgTickTime = stats.averageTickTime as number | undefined;

  if (!memory && tps === undefined && avgTickTime === undefined) return null;

  const usageBytes = (memory?.usage as number) ?? 0;
  const ramMb = Math.round((usageBytes / (1024 * 1024)) * 10) / 10;
  const resolvedTps = tps ?? (avgTickTime ? Math.min(20, 1000 / avgTickTime) : 0);
  const tickMs = avgTickTime ?? 0;

  return {
    time: nowTimeLabel(),
    ramMb,
    ramPercent: (memory?.percent as number) ?? 0,
    tps: Math.round(resolvedTps * 10) / 10,
    tickMs: Math.round(tickMs * 100) / 100,
  };
}

export function appendStatsPoint(history: StatsPoint[], point: StatsPoint): StatsPoint[] {
  const last = history[history.length - 1];

  if (last && last.time === point.time) {
    const merged: StatsPoint = {
      ...last,
      ramMb: point.ramMb || last.ramMb,
      ramPercent: point.ramPercent || last.ramPercent,
      tps: point.tps || last.tps,
      tickMs: point.tickMs || last.tickMs,
    };
    return [...history.slice(0, -1), merged];
  }

  const carried: StatsPoint = last
    ? {
        time: point.time,
        ramMb: point.ramMb || last.ramMb,
        ramPercent: point.ramPercent || last.ramPercent,
        tps: point.tps || last.tps,
        tickMs: point.tickMs || last.tickMs,
      }
    : point;

  const next = [...history, carried];
  return next.length > MAX_STATS_POINTS ? next.slice(next.length - MAX_STATS_POINTS) : next;
}
