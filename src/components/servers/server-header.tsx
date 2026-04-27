"use client";
import { WifiHighIcon, WifiSlashIcon } from "@phosphor-icons/react";
import { type ServerData, STATUS_MAP } from "@/components/server-card";

type Props = {
  server: ServerData;
  wsConnected: boolean;
  wsFailed: boolean;
};

export function ServerHeader({ server, wsConnected, wsFailed }: Props) {
  const statusInfo = STATUS_MAP[server.status] ?? STATUS_MAP[0];

  return (
    <div className="flex items-center gap-3">
      <div className="text-2xl font-bold">{server.name}</div>
      <div className="flex items-center gap-1.5">
        <span
          className={`size-2 rounded-full ${statusInfo.dot} ${server.status === 1 ? "animate-pulse" : ""}`}
        />
        <span className={`text-xs font-medium ${statusInfo.color}`}>{statusInfo.label}</span>
      </div>
      <div className="flex items-center gap-1 ml-auto">
        {wsConnected ? (
          <WifiHighIcon size={14} className="text-emerald-500" />
        ) : (
          <WifiSlashIcon size={14} className="text-gray-400" />
        )}
        <span className={`text-xs ${wsConnected ? "text-emerald-600" : "text-gray-400"}`}>
          {wsConnected ? "Live" : wsFailed ? "REST" : "Connecting..."}
        </span>
      </div>
    </div>
  );
}
