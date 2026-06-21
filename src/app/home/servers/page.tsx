"use client";

import {
  ArrowLeftIcon,
  CubeIcon,
  GlobeIcon,
  ShareNetworkIcon,
  UsersIcon,
  WifiHighIcon,
  WifiSlashIcon,
} from "@phosphor-icons/react";
import { invoke } from "@tauri-apps/api/core";
import gsap from "gsap";
import { useRouter, useSearchParams } from "next/navigation";
import { useEffect, useRef, useState } from "react";
import { FilesPanel } from "@/components/files/files-panel";
import { PageTransition } from "@/components/page-transition";
import type { ServerData } from "@/components/server-card";
import { STATUS_MAP } from "@/components/server-card";
import { ServerConsole } from "@/components/servers/server-console";
import { ServerList } from "@/components/servers/server-list";
import { ServerLogsPanel } from "@/components/servers/server-logs-panel";
import { SchedulePanel } from "@/components/servers/schedule-panel";
import { ServerOptionsPanel } from "@/components/servers/server-options-panel";
import { ServerOverview } from "@/components/servers/server-overview";
import { ServerPlayersPanel } from "@/components/servers/server-players-panel";
import { Skeleton } from "@/components/ui/skeleton";
import { useAccount } from "@/hooks/use-account";
import { useServerWs } from "@/hooks/use-server-ws";
import { useStatsHistory } from "@/hooks/use-stats-history";
import { recordDebugEvent } from "@/lib/debug-log";
import { useLayoutCtx } from "@/lib/layout-context";
import { type LayoutMode, loadLayoutMode } from "@/lib/display-prefs";
import { rememberRecentServer } from "@/lib/recent-servers";

export default function ServerPage() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const id = searchParams.get("id");
  const tab = searchParams.get("tab") ?? "overview";
  const { account } = useAccount();
  const { setIsServerDetail } = useLayoutCtx();
  const [layout, setLayout] = useState<LayoutMode | null>(null);

  useEffect(() => {
    setLayout(loadLayoutMode());
    const handleChange = () => setLayout(loadLayoutMode());
    window.addEventListener("layout-mode-changed", handleChange);
    return () => window.removeEventListener("layout-mode-changed", handleChange);
  }, []);

  const [servers, setServers] = useState<ServerData[]>([]);
  const [restServer, setRestServer] = useState<ServerData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const tabContentRef = useRef<HTMLDivElement>(null);

  const ws = useServerWs(account?.email ?? null, id);
  const statsHistory = useStatsHistory(ws.stats as Record<string, unknown> | null | undefined);
  const server = id ? (ws.serverData ?? restServer) : null;
  const rememberedKeyRef = useRef("");

  // Tell the layout whether this is server detail or list
  useEffect(() => {
    setIsServerDetail(!!id);
    return () => setIsServerDetail(false);
  }, [id, setIsServerDetail]);

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
    ws.subscribe("console").catch(() => {});
    return () => {
      ws.unsubscribe("console").catch(() => {});
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
    ws.subscribe("stats").catch(() => {});
    ws.subscribe("tick").catch(() => {});
    return () => {
      ws.unsubscribe("stats").catch(() => {});
      ws.unsubscribe("tick").catch(() => {});
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

  const TABS = [
    { key: "overview", label: "Overview" },
    { key: "console", label: "Console" },
    { key: "files", label: "Files" },
    { key: "players", label: "Players" },
    { key: "logs", label: "Logs" },
    { key: "options", label: "Options" },
    { key: "schedules", label: "Schedules" },
  ] as const;

  if (!id) {
    return (
      <PageTransition>
        <ServerList servers={servers} loading={loading} error={error} />
      </PageTransition>
    );
  }

  return (
    <PageTransition>
      <div className="flex flex-col gap-4">
        {loading && !server && (
          <div className="px-2 py-2">
            <Skeleton className="h-8 w-48 rounded-md" />
          </div>
        )}
        {error && !server && <p className="px-2 py-2 text-sm text-red-600">{error}</p>}
        {server && account && (
          <>
            {layout !== "sidebar" && (
              <>
                {/* Pterodactyl-style server info bar */}
                <div className="flex items-center gap-3 border-b border-border bg-card px-4 py-2.5">
                  <button
                    type="button"
                    onClick={() => router.push("/home/servers")}
                    className="rounded-md p-1.5 text-muted-foreground hover:text-foreground hover:bg-muted transition-colors"
                    title="Back to servers"
                  >
                    <ArrowLeftIcon size={16} />
                  </button>
                  <div className="flex items-center gap-2 min-w-0">
                    <span
                      className={`h-2.5 w-2.5 shrink-0 rounded-full ${STATUS_MAP[server.status]?.dot ?? "bg-gray-400"} ${server.status === 1 ? "animate-pulse" : ""}`}
                    />
                    <span className="text-sm font-semibold truncate">{server.name}</span>
                  </div>
                  <div className="hidden sm:flex items-center gap-3 text-xs text-muted-foreground ml-2">
                    <span className="flex items-center gap-1">
                      <UsersIcon size={13} />
                      {server.players?.count ?? 0}/{server.players?.max ?? 0}
                    </span>
                    <span className="flex items-center gap-1">
                      <GlobeIcon size={13} />
                      {server.address || "—"}
                    </span>
                    {server.software?.name && (
                      <span className="flex items-center gap-1">
                        <CubeIcon size={13} />
                        {server.software.name} {server.software.version ?? ""}
                      </span>
                    )}
                  </div>
                  <div className="ml-auto flex items-center gap-2">
                    {ws.connected ? (
                      <WifiHighIcon size={15} className="text-emerald-600" />
                    ) : (
                      <WifiSlashIcon size={15} className="text-muted-foreground" />
                    )}
                    {server.shared && (
                      <span title="Shared server">
                        <ShareNetworkIcon size={14} className="text-muted-foreground" />
                      </span>
                    )}
                  </div>
                </div>
                {/* Inline tab navigation */}
                <div className="flex flex-wrap gap-1 border-b border-border px-4">
                  {TABS.map(({ key, label }) => (
                    <button
                      key={key}
                      type="button"
                      onClick={() => router.push(`/home/servers?id=${id}&tab=${key}`)}
                      className={`px-3 py-1.5 text-xs font-medium rounded-t-md border border-b-0 transition-colors cursor-pointer ${
                        tab === key
                          ? "bg-card text-foreground border-border"
                          : "text-muted-foreground hover:text-foreground border-transparent hover:border-border/50"
                      }`}
                    >
                      {label}
                    </button>
                  ))}
                </div>
              </>
            )}
            {layout === "sidebar" && (
              <div className="flex flex-col gap-0.5 px-4 pt-1">
                <span className="text-base font-bold truncate">{server.name}</span>
                <span className="flex items-center gap-1.5 text-xs text-muted-foreground">
                  {ws.connected ? (
                    <WifiHighIcon size={13} className="text-emerald-600" />
                  ) : (
                    <WifiSlashIcon size={13} className="text-muted-foreground" />
                  )}
                  {ws.connected ? "Connected" : "Disconnected"}
                </span>
              </div>
            )}
            <div className="px-4 pb-4">
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
                {tab === "schedules" && (
                  <SchedulePanel email={account.email} serverid={id} />
                )}
                {tab === "options" && (
                  <ServerOptionsPanel
                    email={account.email}
                    serverid={id}
                    fallbackMotd={server.motd}
                  />
                )}
                {!["overview", "console", "files", "players", "logs", "options", "schedules"].includes(tab) && (
                  <p className="text-sm text-muted-foreground">Unknown server tab.</p>
                )}
              </div>
            </div>
          </>
        )}
      </div>
    </PageTransition>
  );
}
