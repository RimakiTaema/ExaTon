"use client";

import {
  ArrowsClockwiseIcon,
  ChartLineUpIcon,
  CoinsIcon,
  TrashIcon,
  TrendDownIcon,
  TrendUpIcon,
} from "@phosphor-icons/react";
import { useMemo, useState } from "react";
import {
  Area,
  AreaChart,
  CartesianGrid,
  Legend,
  ReferenceLine,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { Button } from "@/components/ui/button";
import {
  type CreditSnapshot,
  clearCreditHistory,
  computeBurnRate,
  formatTs,
  formatTsDate,
} from "@/lib/credit-history";

type Props = {
  email: string;
  history: CreditSnapshot[];
  onHistoryChange: (h: CreditSnapshot[]) => void;
};

type Range = "1h" | "6h" | "24h" | "all";
const RANGES: { label: string; value: Range; ms: number }[] = [
  { label: "1h", value: "1h", ms: 3_600_000 },
  { label: "6h", value: "6h", ms: 6 * 3_600_000 },
  { label: "24h", value: "24h", ms: 24 * 3_600_000 },
  { label: "All", value: "all", ms: 0 },
];

// Custom dark tooltip
function CreditTooltip({
  active,
  payload,
  label,
}: {
  active?: boolean;
  payload?: Array<{ name: string; value: number; color: string }>;
  label?: string | number;
}) {
  if (!active || !payload?.length) return null;
  return (
    <div className="rounded-lg border border-zinc-700 bg-zinc-900 px-3 py-2 text-xs shadow-xl">
      <p className="mb-1.5 font-medium text-zinc-300">{label}</p>
      {payload.map((p) => (
        <div key={p.name} className="flex items-center gap-2">
          <span className="inline-block h-2 w-2 rounded-full" style={{ background: p.color }} />
          <span className="text-zinc-400">{p.name}:</span>
          <span className="font-semibold text-zinc-100">{p.value.toFixed(2)} cr</span>
        </div>
      ))}
    </div>
  );
}

export function GlobalCreditGraph({ email, history, onHistoryChange }: Props) {
  const [range, setRange] = useState<Range>("24h");

  const filtered = useMemo(() => {
    const r = RANGES.find((r) => r.value === range)!;
    if (r.ms === 0) return history;
    const cutoff = Date.now() - r.ms;
    return history.filter((p) => p.ts >= cutoff);
  }, [history, range]);

  const chartData = useMemo(
    () =>
      filtered.map((p) => ({
        time: formatTs(p.ts),
        fullTime: formatTsDate(p.ts),
        personal: p.personal,
        pool: p.pool,
        total: p.personal + p.pool,
      })),
    [filtered],
  );

  const burnRates = useMemo(() => computeBurnRate(filtered), [filtered]);
  const avgBurn =
    burnRates.length > 0 ? burnRates.reduce((s, r) => s + r.burnRate, 0) / burnRates.length : null;

  const first = filtered[0];
  const last = filtered[filtered.length - 1];
  const netChange = last && first ? last.personal - first.personal : null;

  const handleClear = () => {
    if (!confirm("Clear all credit history for this account?")) return;
    clearCreditHistory(email);
    onHistoryChange([]);
  };

  return (
    <div className="flex flex-col gap-4">
      {/* Header */}
      <div className="flex flex-wrap items-center gap-3">
        <div className="flex items-center gap-2">
          <ChartLineUpIcon size={18} className="text-emerald-600" />
          <div>
            <p className="text-sm font-semibold">Credit Balance History</p>
            <p className="text-xs text-muted-foreground">
              {history.length} snapshot{history.length !== 1 ? "s" : ""} recorded
            </p>
          </div>
        </div>

        {/* Range pills */}
        <div className="flex items-center gap-1 ml-auto">
          {RANGES.map((r) => (
            <button
              key={r.value}
              type="button"
              onClick={() => setRange(r.value)}
              className={`rounded-full px-3 py-1 text-xs font-medium transition-colors ${
                range === r.value
                  ? "bg-emerald-600 text-white"
                  : "bg-muted text-muted-foreground hover:bg-muted/70"
              }`}
            >
              {r.label}
            </button>
          ))}
        </div>

        <Button variant="ghost" size="icon-xs" onClick={handleClear} title="Clear history">
          <TrashIcon size={13} className="text-muted-foreground hover:text-red-500" />
        </Button>
      </div>

      {/* Summary stat chips */}
      <div className="grid grid-cols-2 gap-2 sm:grid-cols-4">
        <StatChip
          icon={<CoinsIcon size={14} />}
          label="Current"
          value={last ? `${last.personal.toFixed(2)} cr` : "—"}
          color="emerald"
        />
        <StatChip
          icon={<CoinsIcon size={14} />}
          label="Pool"
          value={last ? `${last.pool.toFixed(2)} cr` : "—"}
          color="blue"
        />
        <StatChip
          icon={
            netChange !== null && netChange >= 0 ? (
              <TrendUpIcon size={14} />
            ) : (
              <TrendDownIcon size={14} />
            )
          }
          label={`Change (${range})`}
          value={
            netChange !== null ? `${netChange >= 0 ? "+" : ""}${netChange.toFixed(2)} cr` : "—"
          }
          color={netChange === null ? "zinc" : netChange >= 0 ? "emerald" : "red"}
        />
        <StatChip
          icon={<TrendDownIcon size={14} />}
          label="Avg Burn"
          value={avgBurn !== null ? `${avgBurn.toFixed(3)} cr/hr` : "—"}
          color="amber"
        />
      </div>

      {/* Chart */}
      {chartData.length < 2 ? (
        <div className="flex h-52 flex-col items-center justify-center gap-2 rounded-lg border border-dashed text-muted-foreground">
          <ArrowsClockwiseIcon size={24} className="opacity-30" />
          <p className="text-sm">
            {history.length === 0
              ? "No data yet — credits are recorded each time you refresh the account."
              : "Not enough data in this range."}
          </p>
        </div>
      ) : (
        <div className="rounded-lg border bg-card p-4">
          <ResponsiveContainer width="100%" height={200}>
            <AreaChart data={chartData} margin={{ left: 0, right: 4, top: 4, bottom: 0 }}>
              <defs>
                <linearGradient id="gradPersonal" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="hsl(142,71%,45%)" stopOpacity={0.3} />
                  <stop offset="95%" stopColor="hsl(142,71%,45%)" stopOpacity={0} />
                </linearGradient>
                <linearGradient id="gradPool" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="hsl(217,91%,60%)" stopOpacity={0.3} />
                  <stop offset="95%" stopColor="hsl(217,91%,60%)" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" vertical={false} />
              <XAxis
                dataKey="time"
                tickLine={false}
                axisLine={false}
                fontSize={10}
                tick={{ fill: "hsl(var(--muted-foreground))" }}
                interval="preserveStartEnd"
              />
              <YAxis
                tickLine={false}
                axisLine={false}
                fontSize={10}
                width={48}
                tick={{ fill: "hsl(var(--muted-foreground))" }}
                tickFormatter={(v) => `${v}`}
              />
              <Tooltip content={<CreditTooltip />} />
              <Legend
                wrapperStyle={{ fontSize: 11 }}
                formatter={(v) => <span className="text-muted-foreground">{v}</span>}
              />
              {last && (
                <ReferenceLine
                  y={last.personal}
                  stroke="hsl(142,71%,45%)"
                  strokeDasharray="4 3"
                  strokeOpacity={0.4}
                />
              )}
              <Area
                type="monotone"
                dataKey="personal"
                name="Personal"
                stroke="hsl(142,71%,45%)"
                strokeWidth={2}
                fill="url(#gradPersonal)"
                dot={false}
                activeDot={{ r: 4 }}
              />
              <Area
                type="monotone"
                dataKey="pool"
                name="Pool"
                stroke="hsl(217,91%,60%)"
                strokeWidth={2}
                fill="url(#gradPool)"
                dot={false}
                activeDot={{ r: 4 }}
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>
      )}
    </div>
  );
}

function StatChip({
  icon,
  label,
  value,
  color,
}: {
  icon: React.ReactNode;
  label: string;
  value: string;
  color: "emerald" | "blue" | "red" | "amber" | "zinc";
}) {
  const colorMap = {
    emerald: "text-emerald-600",
    blue: "text-blue-500",
    red: "text-red-500",
    amber: "text-amber-500",
    zinc: "text-zinc-500",
  };
  return (
    <div className="rounded-lg border bg-card px-3 py-2.5">
      <p className="mb-0.5 flex items-center gap-1.5 text-[10px] text-muted-foreground uppercase tracking-wide">
        <span className={colorMap[color]}>{icon}</span>
        {label}
      </p>
      <p className={`text-sm font-semibold ${colorMap[color]}`}>{value}</p>
    </div>
  );
}
