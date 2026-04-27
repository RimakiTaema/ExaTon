"use client";
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

export function ServerOverview({ server, email, serverid, history, wsConnected }: Props) {
  const last = history[history.length - 1];
  const bedrock = isBedrock(server.software?.id);
  const offline = server.status !== 1;
  const tickFallback = bedrock ? "Not available for Bedrock" : "Waiting for tick data...";

  const ramEmpty = offline
    ? "Server is offline"
    : history.length === 0
      ? wsConnected
        ? "Waiting for stats..."
        : "Connecting..."
      : null;

  const tpsEmpty = offline
    ? "Server is offline"
    : history.length === 0 || !history.some((p) => p.tps > 0)
      ? wsConnected
        ? tickFallback
        : "Connecting..."
      : null;

  const tickEmpty = offline
    ? "Server is offline"
    : history.length === 0 || !history.some((p) => p.tickMs > 0)
      ? wsConnected
        ? tickFallback
        : "Connecting..."
      : null;

  return (
    <div className="flex flex-col gap-5">
      <div className="flex flex-wrap gap-4 text-sm text-muted-foreground">
        <span>Address: {server.address}</span>
        <span>
          Players: {server.players?.count ?? 0}/{server.players?.max ?? 0}
        </span>
        {server.software?.name && (
          <span>
            Software: {server.software.name} {server.software.version}
          </span>
        )}
        {server.software?.id && <span>Edition: {bedrock ? "Bedrock" : "Java"}</span>}
      </div>

      <ServerControls email={email} serverid={serverid} status={server.status} />

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

      <p className="text-xs text-muted-foreground">ID: {serverid}</p>
    </div>
  );
}
