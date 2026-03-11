"use client"

import { PageTransition } from "@/components/page-transition"
import { ServerCard, type ServerData } from "@/components/server-card"
import { Skeleton } from "@/components/ui/skeleton"
import { useState, useEffect } from "react"
import { invoke } from "@tauri-apps/api/core"
import gsap from "gsap"

type Account = {
  name: string
  email: string
  credits: number
}

export default function HomePage() {
    const [account, setAccount] = useState<Account | null>(null)
    const [servers, setServers] = useState<ServerData[]>([])
    const [loading, setLoading] = useState(true)
    const [error, setError] = useState("")

    useEffect(() => {
        try {
            const selectedEmail = localStorage.getItem("exaton_selected_account")
            if (!selectedEmail) return
            const accounts: Account[] = JSON.parse(localStorage.getItem("exaton_accounts") ?? "[]")
            const found = accounts.find((a) => a.email === selectedEmail)
            if (found) setAccount(found)
        } catch { /* empty */ }
    }, [])

    useEffect(() => {
        if (!account) return

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
    }, [account])

    useEffect(() => {
        if (!loading && servers.length > 0) {
            gsap.from("[data-server-card]", {
                opacity: 0,
                y: 15,
                duration: 0.3,
                stagger: 0.06,
                ease: "power2.out",
            })
        }
    }, [loading, servers])

    return (
        <PageTransition>
            <div className="flex flex-col px-2 py-2 gap-4">
                <div className="text-2xl font-bold">
                    Welcome Back {account?.name}!
                </div>
                <div>
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
                                {servers.slice(0,2).map((server) => (
                                    <div key={server.id} data-server-card>
                                        <ServerCard server={server} />
                                    </div>
                                ))}
                            </div>
                            <p className="text-sm text-gray-300 text-center mt-3">
                                And More At Servers Tab
                            </p>
                        </>
                    )}
                </div>
            </div>
        </PageTransition>
    )
}
