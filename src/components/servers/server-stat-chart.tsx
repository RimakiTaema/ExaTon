"use client";
import type { ReactNode } from "react";
import { Area, AreaChart, CartesianGrid, XAxis, YAxis } from "recharts";
import {
  type ChartConfig,
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
} from "@/components/ui/chart";
import type { StatsPoint } from "@/lib/server-stats";

type StatKey = "ramMb" | "tps" | "tickMs";

type Props = {
  title: string;
  data: StatsPoint[];
  dataKey: StatKey;
  config: ChartConfig;
  headerStat?: ReactNode;
  empty?: ReactNode;
  yAxisWidth?: number;
  yAxisDomain?: [number, number];
};

export function ServerStatChart({
  title,
  data,
  dataKey,
  config,
  headerStat,
  empty,
  yAxisWidth = 40,
  yAxisDomain,
}: Props) {
  return (
    <div className="rounded-lg border bg-card p-4">
      <div className="flex items-center justify-between mb-3">
        <h3 className="text-sm font-medium">{title}</h3>
        {headerStat}
      </div>
      {empty ? (
        <div className="h-40 flex items-center justify-center text-xs text-muted-foreground italic">
          {empty}
        </div>
      ) : (
        <ChartContainer config={config} className="h-40 w-full">
          <AreaChart data={data} margin={{ left: 12, right: 12 }}>
            <CartesianGrid strokeDasharray="3 3" vertical={false} />
            <XAxis dataKey="time" tickLine={false} axisLine={false} tickMargin={8} fontSize={10} />
            <YAxis
              tickLine={false}
              axisLine={false}
              tickMargin={8}
              fontSize={10}
              width={yAxisWidth}
              domain={yAxisDomain}
            />
            <ChartTooltip content={<ChartTooltipContent indicator="line" />} />
            <Area
              dataKey={dataKey}
              type="monotone"
              fill={`var(--color-${dataKey})`}
              fillOpacity={0.15}
              stroke={`var(--color-${dataKey})`}
              strokeWidth={2}
            />
          </AreaChart>
        </ChartContainer>
      )}
    </div>
  );
}
