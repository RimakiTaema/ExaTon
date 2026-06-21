"use client";
import { CpuIcon } from "@phosphor-icons/react";
import type { ServerData } from "@/components/server-card";
import { ServerControls } from "@/components/servers/server-controls";
import { ServerStatChart } from "@/components/servers/server-stat-chart";
import type { ChartConfig } from "@/components/ui/chart";
import { isBedrock, type StatsPoint } from "@/lib/server-stats";

type Props = {
  server: ServerData;
  email: string;
  serverid: string;
  history: StatsPoint[];
  wsConnected: boolean;
};

const ramConfig = {
  ramMb: { label: "RAM (MB)", color: "hsl(142, 71%, 45%)" },
} satisfies ChartConfig;

const tpsConfig = {
  tps: { label: "TPS", color: "hsl(217, 91%, 60%)" },
} satisfies ChartConfig;

const tickConfig = {
  tickMs: { label: "Tick (ms)", color: "hsl(280, 65%, 60%)" },
} satisfies ChartConfig;

function tpsColorClass(tps: number): string {
  if (tps >= 19) return "text-emerald-500";
  if (tps >= 15) return "text-yellow-500";
  return "text-red-500";
}

function tickColorClass(ms: number): string {
  if (ms <= 50) return "text-emerald-500";
  if (ms <= 100) return "text-yellow-500";
  return "text-red-500";
}

function tpsHealth(tps: number): string {
  if (tps >= 19) return "Great";
  if (tps >= 15) return "Degraded";
  return "Poor";
}

export function ServerOverview({ server, email, serverid, history, wsConnected }: Props) {
  const last = history[history.length - 1];
  const bedrock = isBedrock(server.software?.name, server.software?.version);
  const offline = server.status !== 1;
  const tickFallback = bedrock ? "Not available for Bedrock" : "Waiting for tick data…";

  const ramEmpty = offline
    ? "Server is offline"
    : history.length === 0
      ? wsConnected
        ? "Waiting for stats…"
        : "Connecting…"
      : null;

  const tpsEmpty = offline
    ? "Server is offline"
    : history.length === 0 || !history.some((p) => p.tps > 0)
      ? wsConnected
        ? tickFallback
        : "Connecting…"
      : null;

  const tickEmpty = offline
    ? "Server is offline"
    : history.length === 0 || !history.some((p) => p.tickMs > 0)
      ? wsConnected
        ? tickFallback
        : "Connecting…"
      : null;

  return (
    <div className="flex flex-col gap-5">
      {/* ── Live stat chips (only when online) ──────── */}
      {!offline && last && (
        <div className="grid grid-cols-3 gap-2">
          {/* RAM live */}
          <div className="rounded-lg border bg-card px-3 py-2">
            <div className="flex items-center justify-between mb-1.5">
              <span className="text-[10px] text-muted-foreground uppercase tracking-wide">RAM</span>
              <span className="text-xs font-semibold text-emerald-600">{last.ramMb} MB</span>
            </div>
            <div className="h-1.5 w-full overflow-hidden rounded-full bg-muted">
              <div
                className="h-full rounded-full bg-emerald-500 transition-all duration-700"
                style={{ width: `${Math.min(100, last.ramPercent)}%` }}
              />
            </div>
            <p className="mt-1 text-[10px] text-muted-foreground">
              {last.ramPercent.toFixed(1)}% used
            </p>
          </div>

          {/* TPS live */}
          <div className="rounded-lg border bg-card px-3 py-2">
            <div className="flex items-center justify-between mb-1">
              <span className="text-[10px] text-muted-foreground uppercase tracking-wide flex items-center gap-1">
                <CpuIcon size={11} /> TPS
              </span>
              <span className={`text-xs font-semibold ${tpsColorClass(last.tps)}`}>
                {last.tps > 0 ? last.tps.toFixed(1) : "—"}
              </span>
            </div>
            <div className="h-1.5 w-full overflow-hidden rounded-full bg-muted">
              <div
                className={`h-full rounded-full transition-all duration-700 ${
                  last.tps >= 19
                    ? "bg-emerald-500"
                    : last.tps >= 15
                      ? "bg-yellow-500"
                      : "bg-red-500"
                }`}
                style={{ width: `${Math.min(100, (last.tps / 20) * 100)}%` }}
              />
            </div>
            <p className={`mt-1 text-[10px] ${tpsColorClass(last.tps)}`}>
              {last.tps > 0 ? tpsHealth(last.tps) : "No data"}
            </p>
          </div>

          {/* Tick time live */}
          <div className="rounded-lg border bg-card px-3 py-2">
            <div className="flex items-center justify-between mb-1">
              <span className="text-[10px] text-muted-foreground uppercase tracking-wide">
                Tick
              </span>
              <span
                className={`text-xs font-semibold ${last.tickMs > 0 ? tickColorClass(last.tickMs) : "text-muted-foreground"}`}
              >
                {last.tickMs > 0 ? `${last.tickMs.toFixed(1)} ms` : "—"}
              </span>
            </div>
            <div className="h-1.5 w-full overflow-hidden rounded-full bg-muted">
              <div
                className={`h-full rounded-full transition-all duration-700 ${
                  last.tickMs <= 50
                    ? "bg-emerald-500"
                    : last.tickMs <= 100
                      ? "bg-yellow-500"
                      : "bg-red-500"
                }`}
                style={{ width: `${Math.min(100, (last.tickMs / 200) * 100)}%` }}
              />
            </div>
            <p
              className={`mt-1 text-[10px] ${last.tickMs > 0 ? tickColorClass(last.tickMs) : "text-muted-foreground"}`}
            >
              {last.tickMs > 0
                ? last.tickMs <= 50
                  ? "Smooth"
                  : last.tickMs <= 100
                    ? "Lagging"
                    : "Overloaded"
                : "No data"}
            </p>
          </div>
        </div>
      )}

      {/* ── Server controls ──────────────────────────── */}
      <ServerControls
        email={email}
        serverid={serverid}
        status={server.status}
        shared={server.shared}
      />

      {/* ── History charts ───────────────────────────── */}
      <div className="grid gap-4 md:grid-cols-3">
        <ServerStatChart
          title="RAM Usage"
          data={history}
          dataKey="ramMb"
          config={ramConfig}
          empty={ramEmpty}
          headerStat={
            last && last.ramMb > 0 ? (
              <span className="text-xs text-muted-foreground">
                {last.ramMb} MB ({last.ramPercent.toFixed(1)}%)
              </span>
            ) : null
          }
          yAxisWidth={40}
        />
        <ServerStatChart
          title="TPS"
          data={history}
          dataKey="tps"
          config={tpsConfig}
          empty={tpsEmpty}
          headerStat={
            last && last.tps > 0 ? (
              <span className={`text-xs ${tpsColorClass(last.tps)}`}>{last.tps.toFixed(1)}</span>
            ) : null
          }
          yAxisWidth={30}
          yAxisDomain={[0, 20]}
        />
        <ServerStatChart
          title="Tick Time"
          data={history}
          dataKey="tickMs"
          config={tickConfig}
          empty={tickEmpty}
          headerStat={
            last && last.tickMs > 0 ? (
              <span className={`text-xs ${tickColorClass(last.tickMs)}`}>
                {last.tickMs.toFixed(1)} ms
              </span>
            ) : null
          }
          yAxisWidth={35}
        />
      </div>

      <p className="text-[10px] text-muted-foreground font-mono">ID: {serverid}</p>
    </div>
  );
}
