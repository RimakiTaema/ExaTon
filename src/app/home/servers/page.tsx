"use client"

import { useSearchParams } from "next/navigation"
import { PageTransition } from "@/components/page-transition"
import { ServerCard, STATUS_MAP, type ServerData } from "@/components/server-card"
import { Skeleton } from "@/components/ui/skeleton"
import { useState, useEffect, useRef } from "react"
import { invoke } from "@tauri-apps/api/core"
import { useServerWs } from "@/hooks/use-server-ws"
import { WifiHighIcon, WifiSlashIcon, PaperPlaneRightIcon, PlayIcon, ArrowsClockwiseIcon, StopIcon } from "@phosphor-icons/react"
import { ChartContainer, ChartTooltip, ChartTooltipContent, type ChartConfig } from "@/components/ui/chart"
import { AreaChart, Area, XAxis, YAxis, CartesianGrid } from "recharts"
import gsap from "gsap"
import { ButtonGroup } from "@/components/ui/button-group"
import { Button } from "@/components/ui/button"

type StatsPoint = {
    time: string
    ramMb: number
    ramPercent: number
    tps: number
    tickMs: number
}

const MAX_STATS_POINTS = 30

const ramChartConfig = {
    ramMb: {
        label: "RAM (MB)",
        color: "hsl(142, 71%, 45%)",
    },
} satisfies ChartConfig

const tpsChartConfig = {
    tps: {
        label: "TPS",
        color: "hsl(217, 91%, 60%)",
    },
} satisfies ChartConfig

const tickChartConfig = {
    tickMs: {
        label: "Tick (ms)",
        color: "hsl(280, 65%, 60%)",
    },
} satisfies ChartConfig

type Account = {
  name: string
  email: string
  credits: number
}

export default function ServerPage() {
    const searchParams = useSearchParams()
    const id = searchParams.get("id")
    const tab = searchParams.get("tab") ?? "overview"
    const [servers, setServers] = useState<ServerData[]>([])
    const [restServer, setRestServer] = useState<ServerData | null>(null)
    const [loading, setLoading] = useState(true)
    const [account, setAccount] = useState<Account | null>(null)
    const [error, setError] = useState("")
    const [commandInput, setCommandInput] = useState("")
    const [statsHistory, setStatsHistory] = useState<StatsPoint[]>([])
    const consoleEndRef = useRef<HTMLDivElement>(null)
    const tabContentRef = useRef<HTMLDivElement>(null)

    // WebSocket hook — primary data source for server detail view
    const ws = useServerWs(account?.email ?? null, id)

    // Load account from localStorage
    useEffect(() => {
        try {
            const selectedEmail = localStorage.getItem("exaton_selected_account")
            if (!selectedEmail) return
            const accounts: Account[] = JSON.parse(localStorage.getItem("exaton_accounts") ?? "[]")
            const found = accounts.find((a) => a.email === selectedEmail)
            if (found) setAccount(found)
        } catch { /* empty */ }
    }, [])

    // Server list — REST only (no WS for list view)
    useEffect(() => {
        if (!account || id) return

        const fetchServers = async () => {
            try {
                setLoading(true)
                const result = await invoke<{ success?: boolean; data?: ServerData[] }>("get_servers_info", { email: account.email })
                setServers(result.data ?? [])
            } catch (err) {
                setError(String(err))
            } finally {
                setLoading(false)
            }
        }

        fetchServers()
    }, [account, id])

    // Always fetch initial server data via REST, WS overrides with live updates
    useEffect(() => {
        if (!account || !id) return

        const fetchServer = async () => {
            try {
                setLoading(true)
                const result = await invoke<{ data?: ServerData }>("get_server_info", { email: account.email, serverid: id })
                if (result.data) setRestServer(result.data)
            } catch (err) {
                setError(String(err))
            } finally {
                setLoading(false)
            }
        }
        fetchServer()
    }, [account, id])

    // Subscribe to console stream only on the console tab
    useEffect(() => {
        if (!ws.connected || !id || tab !== "console") return
        ws.subscribe("console")
        return () => { ws.unsubscribe("console") }
    }, [ws.connected, id, tab])

    // Subscribe to stats + tick streams on the overview tab
    useEffect(() => {
        if (!ws.connected || !id || tab !== "overview") return
        ws.subscribe("stats")
        ws.subscribe("tick")
        return () => {
            ws.unsubscribe("stats")
            ws.unsubscribe("tick")
        }
    }, [ws.connected, id, tab])

    // Accumulate stats data into history for charts
    useEffect(() => {
        if (!ws.stats) return
        const memory = ws.stats.memory as Record<string, unknown> | undefined
        const tps = ws.stats.tps as number | undefined
        const avgTickTime = ws.stats.averageTickTime as number | undefined

        if (!memory && tps === undefined && avgTickTime === undefined) return

        // Memory is in bytes — convert to MB
        const usageBytes = (memory?.usage as number) ?? 0
        const ramMb = Math.round((usageBytes / (1024 * 1024)) * 10) / 10

        // TPS from tick stream, or calculate from averageTickTime
        const resolvedTps = tps ?? (avgTickTime ? Math.min(20, 1000 / avgTickTime) : 0)
        const tickMs = avgTickTime ?? 0

        const point: StatsPoint = {
            time: new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", second: "2-digit" }),
            ramMb,
            ramPercent: (memory?.percent as number) ?? 0,
            tps: Math.round(resolvedTps * 10) / 10,
            tickMs: Math.round(tickMs * 100) / 100,
        }

        setStatsHistory((prev) => {
            const last = prev[prev.length - 1]
            // Merge with last point if within same second (stats + tick arrive separately)
            if (last && last.time === point.time) {
                const merged: StatsPoint = {
                    ...last,
                    ramMb: point.ramMb || last.ramMb,
                    ramPercent: point.ramPercent || last.ramPercent,
                    tps: point.tps || last.tps,
                    tickMs: point.tickMs || last.tickMs,
                }
                return [...prev.slice(0, -1), merged]
            }
            // Carry forward previous values for fields that didn't update
            if (last) {
                if (!point.ramMb && last.ramMb) point.ramMb = last.ramMb
                if (!point.ramPercent && last.ramPercent) point.ramPercent = last.ramPercent
                if (!point.tps && last.tps) point.tps = last.tps
                if (!point.tickMs && last.tickMs) point.tickMs = last.tickMs
            }
            const next = [...prev, point]
            return next.length > MAX_STATS_POINTS ? next.slice(next.length - MAX_STATS_POINTS) : next
        })
    }, [ws.stats])

    // Animate tab content on tab switch
    useEffect(() => {
        if (!tabContentRef.current) return
        const ctx = gsap.context(() => {
            gsap.from(tabContentRef.current, {
                opacity: 0,
                y: 8,
                duration: 0.25,
                ease: "power2.out",
            })
        })
        return () => ctx.revert()
    }, [tab])

    // Auto-scroll console to bottom on new lines
    useEffect(() => {
        consoleEndRef.current?.scrollIntoView({ behavior: "smooth" })
    }, [ws.consoleLines])

    const handleSendCommand = () => {
        const cmd = commandInput.trim()
        if (!cmd) return
        ws.sendCommand(cmd)
        setCommandInput("")
    }

    const handleStartServer = async () => {
        if (!account || !id) return
        try {
            await invoke("start_server_action", { email: account.email, serverid: id })
        } catch (err) {
            console.error("Failed to start server:", err)
        }
    }

    const handleStopServer = async () => {
        if (!account || !id) return
        try {
            await invoke("stop_server_action", { email: account.email, serverid: id })
        } catch (err) {
            console.error("Failed to stop server:", err)
        }
    }

    const handleRestartServer = async () => {
        if (!account || !id) return
        try {
            await invoke("restart_server_action", { email: account.email, serverid: id })
        } catch (err) {
            console.error("Failed to restart server:", err)
        }
    }

    // ── Server list view ────────────────────────────────────────────────
    if (!id) {
        return (
            <PageTransition>
                <div className="p-2">
                    <div className="text-xl font-semibold mb-3">
                        Servers
                    </div>
                    {loading && (
                        <div className="grid gap-3 sm:grid-cols-1 md:grid-cols-2 lg:grid-cols-3">
                            {[1, 2, 3].map((i) => (
                                <Skeleton key={i} className="h-28 rounded-xl" />
                            ))}
                        </div>
                    )}
                    {error && (
                        <p className="text-sm text-red-600">{error}</p>
                    )}
                    {!loading && !error && servers.length === 0 && (
                        <p className="text-sm text-muted-foreground">No servers found.</p>
                    )}
                    {!loading && servers.length > 0 && (
                        <>
                            <div className="grid gap-3 sm:grid-cols-1 md:grid-cols-2 lg:grid-cols-3">
                                {servers.map((server) => (
                                    <div key={server.id} data-server-card>
                                        <ServerCard server={server} />
                                    </div>
                                ))}
                            </div>
                        </>
                    )}
                </div>
            </PageTransition>
        )
    }

    // ── Server detail view ──────────────────────────────────────────────

    // WS data is primary, REST is fallback
    const server = ws.serverData ?? restServer
    const statusInfo = server ? (STATUS_MAP[server.status] ?? STATUS_MAP[0]) : STATUS_MAP[0]

    return (
        <PageTransition>
            <div className="flex flex-col px-2 py-2 gap-4">
                {loading && !server && (
                    <Skeleton className="h-8 w-48 rounded-md" />
                )}
                {error && !server && (
                    <p className="text-sm text-red-600">{error}</p>
                )}
                {server && (
                    <>
                        <div className="flex items-center gap-3">
                            <div className="text-2xl font-bold">{server.name}</div>
                            <div className="flex items-center gap-1.5">
                                <span className={`size-2 rounded-full ${statusInfo.dot} ${server.status === 1 ? "animate-pulse" : ""}`} />
                                <span className={`text-xs font-medium ${statusInfo.color}`}>{statusInfo.label}</span>
                            </div>
                            <div className="flex items-center gap-1 ml-auto">
                                {ws.connected ? (
                                    <WifiHighIcon size={14} className="text-emerald-500" />
                                ) : (
                                    <WifiSlashIcon size={14} className="text-gray-400" />
                                )}
                                <span className={`text-xs ${ws.connected ? "text-emerald-600" : "text-gray-400"}`}>
                                    {ws.connected ? "Live" : ws.failed ? "REST" : "Connecting..."}
                                </span>
                            </div>
                        </div>
                        {/* ── Tab content ──────────────────────────── */}
                        <div ref={tabContentRef} key={tab}>

                        {tab === "overview" && (
                            <div className="flex flex-col gap-5">
                                <div className="flex flex-wrap gap-4 text-sm text-muted-foreground">
                                    <span>Address: {server.address}</span>
                                    <span>Players: {server.players?.count ?? 0}/{server.players?.max ?? 0}</span>
                                    {server.software?.name && (
                                        <span>Software: {server.software.name} {server.software.version}</span>
                                    )}
                                    {server.software?.id && (
                                        <span>Edition: {
                                            ["bedrock", "pocketmine", "nukkit", "Bedrock"].includes(server.software.id.toLowerCase())
                                                ? "Bedrock"
                                                : "Java"
                                        }</span>
                                    )}
                                </div>
                                <div>
                                    <ButtonGroup>
                                        <Button onClick={handleStartServer} disabled={server.status !== 0} className={"cursor-pointer hover:bg-emerald-700 outline-1 outline-emerald-200 disabled:opacity-60"}><PlayIcon size={8}/> Start</Button>
                                        <Button onClick={handleRestartServer} disabled={server.status !== 1} className={"cursor-pointer hover:bg-emerald-700 outline-1 outline-emerald-200 disabled:opacity-60"}><ArrowsClockwiseIcon size={8}/> Restart</Button>
                                        <Button onClick={handleStopServer} variant={"destructive"} disabled={server.status !== 1} className={"cursor-pointer hover:bg-red-700 outline-1 outline-red-200 disabled:opacity-60"}><StopIcon size={8}/> Stop</Button>
                                    </ButtonGroup>
                                </div>
                                {/* Stats Charts — 3 columns */}
                                <div className="grid gap-4 md:grid-cols-3">
                                    {/* RAM Usage Chart */}
                                    <div className="rounded-lg border bg-card p-4">
                                        <div className="flex items-center justify-between mb-3">
                                            <h3 className="text-sm font-medium">RAM Usage</h3>
                                            {statsHistory.length > 0 && statsHistory[statsHistory.length - 1].ramMb > 0 && (
                                                <span className="text-xs text-muted-foreground">
                                                    {statsHistory[statsHistory.length - 1].ramMb} MB ({statsHistory[statsHistory.length - 1].ramPercent.toFixed(1)}%)
                                                </span>
                                            )}
                                        </div>
                                        {server.status !== 1 ? (
                                            <div className="h-40 flex items-center justify-center text-xs text-muted-foreground italic">
                                                Server is offline
                                            </div>
                                        ) : statsHistory.length === 0 ? (
                                            <div className="h-40 flex items-center justify-center text-xs text-muted-foreground italic">
                                                {ws.connected ? "Waiting for stats..." : "Connecting..."}
                                            </div>
                                        ) : (
                                            <ChartContainer config={ramChartConfig} className="h-40 w-full">
                                                <AreaChart data={statsHistory} margin={{ left: 12, right: 12 }}>
                                                    <CartesianGrid strokeDasharray="3 3" vertical={false} />
                                                    <XAxis
                                                        dataKey="time"
                                                        tickLine={false}
                                                        axisLine={false}
                                                        tickMargin={8}
                                                        fontSize={10}
                                                    />
                                                    <YAxis
                                                        tickLine={false}
                                                        axisLine={false}
                                                        tickMargin={8}
                                                        fontSize={10}
                                                        width={40}
                                                    />
                                                    <ChartTooltip
                                                        content={<ChartTooltipContent indicator="line" />}
                                                    />
                                                    <Area
                                                        dataKey="ramMb"
                                                        type="monotone"
                                                        fill="var(--color-ramMb)"
                                                        fillOpacity={0.15}
                                                        stroke="var(--color-ramMb)"
                                                        strokeWidth={2}
                                                    />
                                                </AreaChart>
                                            </ChartContainer>
                                        )}
                                    </div>

                                    {/* TPS Chart */}
                                    <div className="rounded-lg border bg-card p-4">
                                        <div className="flex items-center justify-between mb-3">
                                            <h3 className="text-sm font-medium">TPS</h3>
                                            {statsHistory.length > 0 && statsHistory[statsHistory.length - 1].tps > 0 && (
                                                <span className={`text-xs ${
                                                    statsHistory[statsHistory.length - 1].tps >= 19
                                                        ? "text-emerald-500"
                                                        : statsHistory[statsHistory.length - 1].tps >= 15
                                                        ? "text-yellow-500"
                                                        : "text-red-500"
                                                }`}>
                                                    {statsHistory[statsHistory.length - 1].tps.toFixed(1)}
                                                </span>
                                            )}
                                        </div>
                                        {server.status !== 1 ? (
                                            <div className="h-40 flex items-center justify-center text-xs text-muted-foreground italic">
                                                Server is offline
                                            </div>
                                        ) : statsHistory.length === 0 || !statsHistory.some((p) => p.tps > 0) ? (
                                            <div className="h-40 flex items-center justify-center text-xs text-muted-foreground italic">
                                                {ws.connected
                                                    ? (server.software?.id && ["bedrock", "pocketmine", "nukkit"].includes(server.software.id.toLowerCase())
                                                        ? "Not available for Bedrock"
                                                        : "Waiting for tick data...")
                                                    : "Connecting..."}
                                            </div>
                                        ) : (
                                            <ChartContainer config={tpsChartConfig} className="h-40 w-full">
                                                <AreaChart data={statsHistory} margin={{ left: 12, right: 12 }}>
                                                    <CartesianGrid strokeDasharray="3 3" vertical={false} />
                                                    <XAxis
                                                        dataKey="time"
                                                        tickLine={false}
                                                        axisLine={false}
                                                        tickMargin={8}
                                                        fontSize={10}
                                                    />
                                                    <YAxis
                                                        tickLine={false}
                                                        axisLine={false}
                                                        tickMargin={8}
                                                        fontSize={10}
                                                        width={30}
                                                        domain={[0, 20]}
                                                    />
                                                    <ChartTooltip
                                                        content={<ChartTooltipContent indicator="line" />}
                                                    />
                                                    <Area
                                                        dataKey="tps"
                                                        type="monotone"
                                                        fill="var(--color-tps)"
                                                        fillOpacity={0.15}
                                                        stroke="var(--color-tps)"
                                                        strokeWidth={2}
                                                    />
                                                </AreaChart>
                                            </ChartContainer>
                                        )}
                                    </div>

                                    {/* Tick Time Chart */}
                                    <div className="rounded-lg border bg-card p-4">
                                        <div className="flex items-center justify-between mb-3">
                                            <h3 className="text-sm font-medium">Tick Time</h3>
                                            {statsHistory.length > 0 && statsHistory[statsHistory.length - 1].tickMs > 0 && (
                                                <span className={`text-xs ${
                                                    statsHistory[statsHistory.length - 1].tickMs <= 50
                                                        ? "text-emerald-500"
                                                        : statsHistory[statsHistory.length - 1].tickMs <= 100
                                                        ? "text-yellow-500"
                                                        : "text-red-500"
                                                }`}>
                                                    {statsHistory[statsHistory.length - 1].tickMs.toFixed(1)} ms
                                                </span>
                                            )}
                                        </div>
                                        {server.status !== 1 ? (
                                            <div className="h-40 flex items-center justify-center text-xs text-muted-foreground italic">
                                                Server is offline
                                            </div>
                                        ) : statsHistory.length === 0 || !statsHistory.some((p) => p.tickMs > 0) ? (
                                            <div className="h-40 flex items-center justify-center text-xs text-muted-foreground italic">
                                                {ws.connected
                                                    ? (server.software?.id && ["bedrock", "pocketmine", "nukkit"].includes(server.software.id.toLowerCase())
                                                        ? "Not available for Bedrock"
                                                        : "Waiting for tick data...")
                                                    : "Connecting..."}
                                            </div>
                                        ) : (
                                            <ChartContainer config={tickChartConfig} className="h-40 w-full">
                                                <AreaChart data={statsHistory} margin={{ left: 12, right: 12 }}>
                                                    <CartesianGrid strokeDasharray="3 3" vertical={false} />
                                                    <XAxis
                                                        dataKey="time"
                                                        tickLine={false}
                                                        axisLine={false}
                                                        tickMargin={8}
                                                        fontSize={10}
                                                    />
                                                    <YAxis
                                                        tickLine={false}
                                                        axisLine={false}
                                                        tickMargin={8}
                                                        fontSize={10}
                                                        width={35}
                                                    />
                                                    <ChartTooltip
                                                        content={<ChartTooltipContent indicator="line" />}
                                                    />
                                                    <Area
                                                        dataKey="tickMs"
                                                        type="monotone"
                                                        fill="var(--color-tickMs)"
                                                        fillOpacity={0.15}
                                                        stroke="var(--color-tickMs)"
                                                        strokeWidth={2}
                                                    />
                                                </AreaChart>
                                            </ChartContainer>
                                        )}
                                    </div>
                                </div>

                                <p className="text-xs text-muted-foreground">ID: {id}</p>
                            </div>
                        )}

                        {tab === "console" && (
                            <div className="flex flex-col rounded-lg border border-gray-700 bg-gray-900 overflow-hidden shadow-lg">
                                {/* Console output */}
                                <div className="h-80 overflow-y-auto flex-wrap p-3 font-mono text-xs leading-5 text-gray-300">
                                    {ws.consoleLines.length === 0 ? (
                                        <span className="text-gray-500 italic">
                                            {server.status === 1
                                                ? (ws.connected ? "Waiting for output..." : "Connecting...")
                                                : "Server is offline"}
                                        </span>
                                    ) : (
                                        ws.consoleLines.map((line, i) => (
                                            <div key={i} className="hover:bg-gray-800/50 px-1 -mx-1 rounded">
                                                {line}
                                            </div>
                                        ))
                                    )}
                                    <div ref={consoleEndRef} />
                                </div>
                                {/* Command input */}
                                <div className="flex items-center gap-2 border-t border-gray-700 bg-gray-800 px-3 py-2">
                                    <span className="text-emerald-500 font-mono text-sm select-none">&gt;</span>
                                    <input
                                        type="text"
                                        value={commandInput}
                                        onChange={(e) => setCommandInput(e.target.value)}
                                        onKeyDown={(e) => {
                                            if (e.key === "Enter") handleSendCommand()
                                        }}
                                        placeholder={ws.connected && server.status === 1 ? "Type a command..." : "Server offline"}
                                        disabled={!ws.connected || server.status !== 1}
                                        className="flex-1 bg-transparent text-gray-200 font-mono text-sm placeholder:text-gray-600 outline-none disabled:opacity-40"
                                    />
                                    <button
                                        onClick={handleSendCommand}
                                        disabled={!ws.connected || server.status !== 1 || !commandInput.trim()}
                                        className="text-gray-400 hover:text-emerald-400 disabled:opacity-30 disabled:hover:text-gray-400 transition-colors cursor-pointer disabled:cursor-not-allowed"
                                    >
                                        <PaperPlaneRightIcon size={16} />
                                    </button>
                                </div>
                            </div>
                        )}

                        {tab === "files" && (
                            <p className="text-sm text-muted-foreground italic">Files — coming soon</p>
                        )}

                        {tab === "players" && (
                            <p className="text-sm text-muted-foreground italic">Players — coming soon</p>
                        )}

                        {tab === "logs" && (
                            <p className="text-sm text-muted-foreground italic">Logs — coming soon</p>
                        )}

                        {tab === "options" && (
                            <p className="text-sm text-muted-foreground italic">Options — coming soon</p>
                        )}

                        </div>
                    </>
                )}
            </div>
        </PageTransition>
    )
}
