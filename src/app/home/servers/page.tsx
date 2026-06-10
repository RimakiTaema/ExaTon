"use client";

import { invoke } from "@tauri-apps/api/core";
import gsap from "gsap";
import { useSearchParams } from "next/navigation";
import { useEffect, useRef, useState } from "react";
import { FilesPanel } from "@/components/files/files-panel";
import { PageTransition } from "@/components/page-transition";
import type { ServerData } from "@/components/server-card";
import { ServerConsole } from "@/components/servers/server-console";
import { ServerHeader } from "@/components/servers/server-header";
import { ServerList } from "@/components/servers/server-list";
import { ServerLogsPanel } from "@/components/servers/server-logs-panel";
import { ServerOptionsPanel } from "@/components/servers/server-options-panel";
import { ServerOverview } from "@/components/servers/server-overview";
import { ServerPlayersPanel } from "@/components/servers/server-players-panel";
import { Skeleton } from "@/components/ui/skeleton";
import { useAccount } from "@/hooks/use-account";
import { useServerWs } from "@/hooks/use-server-ws";
import { useStatsHistory } from "@/hooks/use-stats-history";
import { recordDebugEvent } from "@/lib/debug-log";
import { rememberRecentServer } from "@/lib/recent-servers";

export default function ServerPage() {
  const searchParams = useSearchParams();
  const id = searchParams.get("id");
  const tab = searchParams.get("tab") ?? "overview";
  const account = useAccount();

  const [servers, setServers] = useState<ServerData[]>([]);
  const [restServer, setRestServer] = useState<ServerData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const tabContentRef = useRef<HTMLDivElement>(null);

  const ws = useServerWs(account?.email ?? null, id);
  const statsHistory = useStatsHistory(ws.stats as Record<string, unknown> | null | undefined);
  const server = id ? (ws.serverData ?? restServer) : null;
  const rememberedKeyRef = useRef("");

  useEffect(() => {
    if (!account) setLoading(false);
  }, [account]);

  useEffect(() => {
    if (!account || id) return;
    (async () => {
      try {
        setLoading(true);
        setError("");
        recordDebugEvent({
          scope: "servers",
          message: "Loading server list",
          detail: { email: account.email },
        });
        const result = await invoke<{ success?: boolean; data?: ServerData[] }>(
          "get_servers_info",
          { email: account.email },
        );
        setServers(result.data ?? []);
      } catch (err) {
        recordDebugEvent({
          level: "error",
          scope: "servers",
          message: "Server list failed",
          detail: err,
        });
        setError(String(err));
      } finally {
        setLoading(false);
      }
    })();
  }, [account, id]);

  useEffect(() => {
    if (!account || !id) return;
    (async () => {
      try {
        setLoading(true);
        setError("");
        recordDebugEvent({
          scope: "servers",
          message: "Loading server detail",
          detail: { email: account.email, serverid: id },
        });
        const result = await invoke<{ data?: ServerData }>("get_server_info", {
          email: account.email,
          serverid: id,
        });
        if (result.data) setRestServer(result.data);
      } catch (err) {
        recordDebugEvent({
          level: "error",
          scope: "servers",
          message: "Server detail failed",
          detail: err,
        });
        setError(String(err));
      } finally {
        setLoading(false);
      }
    })();
  }, [account, id]);

  useEffect(() => {
    if (!ws.connected || !id || tab !== "console") return;
    ws.subscribe("console");
    return () => {
      ws.unsubscribe("console");
    };
  }, [ws.connected, ws.subscribe, ws.unsubscribe, id, tab]);

  useEffect(() => {
    if (!account || !server?.id) return;
    const key = `${account.email}:${server.id}:${server.name}:${server.address}:${server.status}`;
    if (rememberedKeyRef.current === key) return;
    rememberedKeyRef.current = key;
    rememberRecentServer(account.email, {
      id: server.id,
      name: server.name,
      address: server.address,
      status: server.status,
    });
  }, [account, server?.address, server?.id, server?.name, server?.status]);

  useEffect(() => {
    if (!ws.connected || !id || tab !== "overview") return;
    ws.subscribe("stats");
    ws.subscribe("tick");
    return () => {
      ws.unsubscribe("stats");
      ws.unsubscribe("tick");
    };
  }, [ws.connected, ws.subscribe, ws.unsubscribe, id, tab]);

  // biome-ignore lint/correctness/useExhaustiveDependencies: `tab` is the trigger — animation must replay on every tab switch, even though the body doesn't read it.
  useEffect(() => {
    if (!tabContentRef.current) return;
    const ctx = gsap.context(() => {
      gsap.from(tabContentRef.current, {
        opacity: 0,
        y: 8,
        duration: 0.25,
        ease: "power2.out",
      });
    });
    return () => ctx.revert();
  }, [tab]);

  if (!id) {
    return (
      <PageTransition>
        <ServerList servers={servers} loading={loading} error={error} />
      </PageTransition>
    );
  }

  return (
    <PageTransition>
      <div className="flex flex-col px-2 py-2 gap-4">
        {loading && !server && <Skeleton className="h-8 w-48 rounded-md" />}
        {error && !server && <p className="text-sm text-red-600">{error}</p>}
        {server && account && (
          <>
            <ServerHeader server={server} wsConnected={ws.connected} wsFailed={ws.failed} />
            <div ref={tabContentRef} key={tab}>
              {tab === "overview" && (
                <ServerOverview
                  server={server}
                  email={account.email}
                  serverid={id}
                  history={statsHistory}
                  wsConnected={ws.connected}
                />
              )}
              {tab === "console" && (
                <ServerConsole
                  lines={ws.consoleLines}
                  status={server.status}
                  connected={ws.connected}
                  onSend={ws.sendCommand}
                />
              )}
              {tab === "files" && <FilesPanel email={account.email} serverid={id} />}
              {tab === "players" && (
                <ServerPlayersPanel
                  email={account.email}
                  serverid={id}
                  onlinePlayers={server.players?.list ?? []}
                />
              )}
              {tab === "logs" && <ServerLogsPanel email={account.email} serverid={id} />}
              {tab === "options" && (
                <ServerOptionsPanel
                  email={account.email}
                  serverid={id}
                  fallbackMotd={server.motd}
                />
              )}
              {!["overview", "console", "files", "players", "logs", "options"].includes(tab) && (
                <p className="text-sm text-muted-foreground">Unknown server tab.</p>
              )}
            </div>
          </>
        )}
      </div>
    </PageTransition>
  );
}
