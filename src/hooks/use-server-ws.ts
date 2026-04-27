"use client"

import { useEffect, useRef, useState, useCallback } from "react"
import { invoke } from "@tauri-apps/api/core"
import { listen, type UnlistenFn } from "@tauri-apps/api/event"
import type { ServerData } from "@/components/server-card"

// ── WS event payload types ──────────────────────────────────────────────

type WsStatusEvent = {
  server_id: string
  status: Record<string, unknown>
}

type WsConsoleEvent = {
  server_id: string
  line: string
}

type WsStatsEvent = {
  server_id: string
  data: Record<string, unknown>
}

type WsConnectionEvent = {
  server_id: string
}

// ── Return type ─────────────────────────────────────────────────────────

type UseServerWsReturn = {
  /** Whether the WebSocket is connected */
  connected: boolean
  /** Whether the WS connection attempt failed (triggers REST fallback) */
  failed: boolean
  /** Full server data parsed from WS status stream */
  serverData: ServerData | null
  /** Console output lines */
  consoleLines: string[]
  /** Live stats (memory, tps, etc.) */
  stats: Record<string, unknown> | null
  /** Send a console command */
  sendCommand: (command: string) => Promise<void>
  /** Subscribe to a stream (console, stats, tick, heap) */
  subscribe: (stream: string) => Promise<void>
  /** Unsubscribe from a stream */
  unsubscribe: (stream: string) => Promise<void>
}

const MAX_CONSOLE_LINES = 500

// ── Parse raw WS/REST server data into our ServerData type ──────────────

function parseServerData(raw: Record<string, unknown>): ServerData | null {
  if (!raw.id || !raw.name) return null

  const players = raw.players as Record<string, unknown> | undefined
  const software = raw.software as Record<string, unknown> | null | undefined

  return {
    id: raw.id as string,
    name: raw.name as string,
    address: (raw.address as string) ?? "",
    motd: (raw.motd as string) ?? "",
    status: (raw.status as number) ?? 0,
    players: {
      count: (players?.count as number) ?? 0,
      max: (players?.max as number) ?? 0,
      list: (players?.list as string[]) ?? [],
    },
    software: software
      ? {
          id: (software.id as string) ?? "",
          name: (software.name as string) ?? "",
          version: (software.version as string) ?? "",
        }
      : null,
    shared: (raw.shared as boolean) ?? false,
  }
}

// ── Hook ────────────────────────────────────────────────────────────────

export function useServerWs(
  email: string | null,
  serverId: string | null
): UseServerWsReturn {
  const [connected, setConnected] = useState(false)
  const [failed, setFailed] = useState(false)
  const [serverData, setServerData] = useState<ServerData | null>(null)
  const [consoleLines, setConsoleLines] = useState<string[]>([])
  const [stats, setStats] = useState<Record<string, unknown> | null>(null)
  const unlistenRefs = useRef<UnlistenFn[]>([])

  // Connect and subscribe to events
  useEffect(() => {
    if (!email || !serverId) return

    let cancelled = false

    const setup = async () => {
      try {
        // Connect WebSocket
        await invoke("ws_connect", { email, serverId })

        if (cancelled) {
          await invoke("ws_disconnect", { serverId }).catch(() => {})
          return
        }

        // Listen for connection events
        const unlistenConnected = await listen<WsConnectionEvent>(
          "ws:connected",
          (event) => {
            if (event.payload.server_id === serverId) {
              setConnected(true)
              setFailed(false)
            }
          }
        )

        const unlistenDisconnected = await listen<WsConnectionEvent>(
          "ws:disconnected",
          (event) => {
            if (event.payload.server_id === serverId) {
              setConnected(false)
            }
          }
        )

        // Listen for status updates (contains full server data)
        const unlistenStatus = await listen<WsStatusEvent>(
          "ws:status",
          (event) => {
            if (event.payload.server_id === serverId) {
              const parsed = parseServerData(event.payload.status)
              if (parsed) {
                setServerData(parsed)
              }
            }
          }
        )

        // Listen for console lines
        const unlistenConsole = await listen<WsConsoleEvent>(
          "ws:console",
          (event) => {
            if (event.payload.server_id === serverId) {
              setConsoleLines((prev) => {
                const next = [...prev, event.payload.line]
                return next.length > MAX_CONSOLE_LINES
                  ? next.slice(next.length - MAX_CONSOLE_LINES)
                  : next
              })
            }
          }
        )

        // Listen for stats (merges memory + tick data instead of replacing)
        const unlistenStats = await listen<WsStatsEvent>(
          "ws:stats",
          (event) => {
            if (event.payload.server_id === serverId) {
              setStats((prev) => {
                const next = { ...(prev ?? {}) }
                const data = event.payload.data
                if ("memory" in data) {
                  next.memory = data.memory
                }
                if ("usage" in data) {
                  // heap stream — single usage field
                  next.heapUsage = data.usage
                }
                if ("tps" in data) {
                  next.tps = data.tps
                }
                if ("averageTickTime" in data) {
                  next.averageTickTime = data.averageTickTime
                }
                return next
              })
            }
          }
        )

        if (!cancelled) {
          setConnected(true)
          setFailed(false)
          unlistenRefs.current = [
            unlistenConnected,
            unlistenDisconnected,
            unlistenStatus,
            unlistenConsole,
            unlistenStats,
          ]
        } else {
          unlistenConnected()
          unlistenDisconnected()
          unlistenStatus()
          unlistenConsole()
          unlistenStats()
        }
      } catch (err) {
        console.error("WS connect failed:", err)
        if (!cancelled) {
          setFailed(true)
          setConnected(false)
        }
      }
    }

    setup()

    return () => {
      cancelled = true
      for (const unlisten of unlistenRefs.current) {
        unlisten()
      }
      unlistenRefs.current = []
      invoke("ws_disconnect", { serverId }).catch(() => {})
      setConnected(false)
      setServerData(null)
      setConsoleLines([])
      setStats(null)
    }
  }, [email, serverId])

  const sendCommand = useCallback(
    async (command: string) => {
      if (!serverId) return
      await invoke("ws_send_command", { serverId, command })
    },
    [serverId]
  )

  const subscribe = useCallback(
    async (stream: string) => {
      if (!serverId) return
      await invoke("ws_subscribe", { serverId, stream })
    },
    [serverId]
  )

  const unsubscribe = useCallback(
    async (stream: string) => {
      if (!serverId) return
      await invoke("ws_unsubscribe", { serverId, stream })
    },
    [serverId]
  )

  return {
    connected,
    failed,
    serverData,
    consoleLines,
    stats,
    sendCommand,
    subscribe,
    unsubscribe,
  }
}
