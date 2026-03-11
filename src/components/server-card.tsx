"use client"

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip"
import { UsersIcon, GlobeIcon, CubeIcon, ShareNetworkIcon } from "@phosphor-icons/react"
import Link from "next/link"

export type ServerPlayers = {
  count: number
  max: number
  list?: string[]
}

export type ServerSoftware = {
  id: string
  name: string
  version: string
}

export type ServerData = {
  id: string
  name: string
  address: string
  motd: string
  status: number
  players: ServerPlayers
  software: ServerSoftware | null
  shared: boolean
}

export const STATUS_MAP: Record<number, { label: string; color: string; dot: string }> = {
  0: { label: "Offline", color: "text-gray-500", dot: "bg-gray-400" },
  1: { label: "Online", color: "text-emerald-600", dot: "bg-emerald-500" },
  2: { label: "Starting", color: "text-yellow-600", dot: "bg-yellow-500" },
  3: { label: "Stopping", color: "text-orange-600", dot: "bg-orange-500" },
  4: { label: "Restarting", color: "text-yellow-600", dot: "bg-yellow-500" },
  5: { label: "Saving", color: "text-blue-600", dot: "bg-blue-500" },
  6: { label: "Loading", color: "text-blue-600", dot: "bg-blue-500" },
  7: { label: "Crashed", color: "text-red-600", dot: "bg-red-500" },
  8: { label: "Pending", color: "text-gray-500", dot: "bg-gray-400" },
  9: { label: "Transferring", color: "text-purple-600", dot: "bg-purple-500" },
  10: { label: "Preparing", color: "text-blue-600", dot: "bg-blue-500" },
}

export function ServerCard({ server }: { server: ServerData }) {
  const statusInfo = STATUS_MAP[server.status] ?? STATUS_MAP[0]
  const isOnline = server.status === 1

  return (
    <Link href={`/home/servers?id=${server.id}`}>
      <Card className="cursor-pointer transition-shadow hover:shadow-md hover:ring-emerald-300/50" size="sm">
        <CardHeader>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <CardTitle className="truncate">{server.name}</CardTitle>
              {server.shared && (
                <Tooltip>
                  <TooltipTrigger>
                    <ShareNetworkIcon size={14} className="text-muted-foreground" />
                  </TooltipTrigger>
                  <TooltipContent>Shared server</TooltipContent>
                </Tooltip>
              )}
            </div>
            <div className="flex items-center gap-1.5">
              <span className={`size-2 rounded-full ${statusInfo.dot} ${isOnline ? "animate-pulse" : ""}`} />
              <span className={`text-xs font-medium ${statusInfo.color}`}>{statusInfo.label}</span>
            </div>
          </div>
          <CardDescription className="truncate">{server.address}</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="flex items-center gap-4 text-xs text-muted-foreground">
            <Tooltip>
              <TooltipTrigger className="flex items-center gap-1">
                <UsersIcon size={14} />
                <span>{server.players?.count ?? 0}/{server.players?.max ?? 0}</span>
              </TooltipTrigger>
              <TooltipContent>Players</TooltipContent>
            </Tooltip>
            {server.software?.name && (
              <Tooltip>
                <TooltipTrigger className="flex items-center gap-1">
                  <CubeIcon size={14} />
                  <span>{server.software.name} {server.software.version}</span>
                </TooltipTrigger>
                <TooltipContent>Server software</TooltipContent>
              </Tooltip>
            )}
            {server.address && (
              <Tooltip>
                <TooltipTrigger className="flex items-center gap-1">
                  <GlobeIcon size={14} />
                  <span className="truncate max-w-32">{server.address}</span>
                </TooltipTrigger>
                <TooltipContent>{server.address}</TooltipContent>
              </Tooltip>
            )}
          </div>
        </CardContent>
      </Card>
    </Link>
  )
}
