"use client"

import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarSeparator,
  useSidebar,
} from "@/components/ui/sidebar"
import { useEffect, useRef, useState } from "react"
import { usePathname, useSearchParams } from "next/navigation"
import gsap from "gsap"
import {
  HouseIcon,
  CubeIcon,
  GearIcon,
  UserIcon,
  ClockIcon,
  BugIcon,
  XIcon,
  ArrowLeftIcon,
  TerminalIcon,
  FolderIcon,
  ScrollIcon,
  UsersIcon,
  SlidersIcon,
  PlayIcon,
  DoorOpenIcon,
  ArrowsClockwiseIcon,
  ArrowSquareOutIcon,
} from "@phosphor-icons/react"
import { invoke } from "@tauri-apps/api/core"
import { openUrl } from "@tauri-apps/plugin-opener"
import Image from "next/image"
import Link from "next/link"
import { useRouter } from "next/navigation"
import { Popover, PopoverContent, PopoverTrigger } from "./ui/popover"
import { Button } from "./ui/button"
import { Tooltip, TooltipContent, TooltipTrigger } from "./ui/tooltip"

type Account = {
  name: string
  email: string
  credits: number
}

const mainNavItems = [
  { title: "Home", href: "/home", icon: HouseIcon, className: "" },
  { title: "Servers", href: "/home/servers", icon: CubeIcon, className: "" },
  { title: "Settings", href: "/home/settings", icon: GearIcon, className: "" },
  { title: "Debug Option", href: "/home/debug", icon: BugIcon, className: "text-red-500 hover:bg-red-50 hover:text-red-600 data-[active=true]:bg-red-50 data-[active=true]:text-red-600" },
]

const serverNavItems = (serverId: string) => [
  { title: "Overview", href: `/home/servers?id=${serverId}`, icon: CubeIcon, className: "" },
  { title: "Console", href: `/home/servers?id=${serverId}&tab=console`, icon: TerminalIcon, className: "" },
  { title: "Files", href: `/home/servers?id=${serverId}&tab=files`, icon: FolderIcon, className: "" },
  { title: "Players", href: `/home/servers?id=${serverId}&tab=players`, icon: UsersIcon, className: "" },
  { title: "Logs", href: `/home/servers?id=${serverId}&tab=logs`, icon: ScrollIcon, className: "" },
  { title: "Options", href: `/home/servers?id=${serverId}&tab=options`, icon: SlidersIcon, className: "" },
]

export function AppSidebar() {
  const sidebarRef = useRef<HTMLDivElement>(null)
  const { toggleSidebar, open } = useSidebar()
  const [account, setAccount] = useState<Account | null>(null)
  const [serverName, setServerName] = useState<string>("")
  const [refreshing, setRefreshing] = useState(false)
  const pathname = usePathname()
  const searchParams = useSearchParams()
  const router = useRouter()

  const handleGoBack = (e: React.MouseEvent) => {
    e.stopPropagation()
    router.push("/")
  }

  const handleRefreshAccount = async (e: React.MouseEvent) => {
    e.stopPropagation()
    if (!account || refreshing) return
    setRefreshing(true)
    try {
      const token = await invoke<string>("get_token", { email: account.email })
      const result = await invoke<{ data?: { name?: string; email?: string; credits?: number } }>("get_acc_info", { token })
      if (result.data) {
        const updated: Account = {
          name: result.data.name ?? account.name,
          email: result.data.email ?? account.email,
          credits: result.data.credits ?? account.credits,
        }
        setAccount(updated)
        // sync to localStorage
        const accounts: Account[] = JSON.parse(localStorage.getItem("exaton_accounts") ?? "[]")
        const idx = accounts.findIndex((a) => a.email === account.email)
        if (idx !== -1) {
          const next = [...accounts]
          next[idx] = updated
          localStorage.setItem("exaton_accounts", JSON.stringify(next))
        }
      }
    } catch { /* empty */ }
    setRefreshing(false)
  }

  const handleOpenDashboard = (e: React.MouseEvent) => {
    e.stopPropagation()
    openUrl("https://exaroton.com/account/")
  }

  const isServerDetail = pathname === "/home/servers" && searchParams.get("id")
  const serverId = searchParams.get("id")
  const navItems = isServerDetail && serverId ? serverNavItems(serverId) : mainNavItems

  useEffect(() => {
    try {
      const selectedEmail = localStorage.getItem("exaton_selected_account")
      if (!selectedEmail) return
      const accounts: Account[] = JSON.parse(localStorage.getItem("exaton_accounts") ?? "[]")
      const found = accounts.find((a) => a.email === selectedEmail)
      // eslint-disable-next-line react-hooks/set-state-in-effect
      if (found) setAccount(found)
    } catch { /* empty */ }
  }, [])

  useEffect(() => {
    if (!isServerDetail || !serverId || !account) {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setServerName("")
      return
    }
    const fetchName = async () => {
      try {
        const result = await invoke<{ data?: { name?: string } }>("get_server_info", { email: account.email, serverid: serverId })
        setServerName(result.data?.name ?? "")
      } catch { /* empty */ }
    }
    fetchName()
  }, [isServerDetail, serverId, account])

  useEffect(() => {
    if (!sidebarRef.current) return
    const ctx = gsap.context(() => {
      const tl = gsap.timeline()
      tl.from("[data-sidebar-nav-item]", {
        opacity: 0,
        x: -15,
        duration: 0.3,
        stagger: 0.05,
        delay: 0.1,
        ease: "power2.out",
      })
      if (account) {
        tl.from("[data-sidebar-footer]", {
          opacity: 0,
          y: 10,
          duration: 0.3,
          ease: "power2.out",
        }, "-=0.1")
      }
    }, sidebarRef)
    return () => ctx.revert()
  }, [account, isServerDetail])

  return (
    <div ref={sidebarRef}>
    <Sidebar collapsible="icon">
      <SidebarHeader>
        <div className="flex items-center justify-between px-2 py-1">
          <button onClick={() => !open && toggleSidebar()} className="flex items-center gap-2 group-data-[collapsible=icon]:cursor-pointer">
            <Image src="/66498436.png" alt="ExaTon" width={24} height={24} className="shrink-0" />
            <span className="text-sm font-semibold truncate group-data-[collapsible=icon]:hidden">ExaTon NEXT</span>
          </button>
          <button onClick={toggleSidebar} className="group-data-[collapsible=icon]:hidden cursor-pointer text-muted-foreground hover:text-foreground">
            <XIcon size={18} />
          </button>
        </div>
      </SidebarHeader>
      <SidebarContent>
        {isServerDetail && (
          <SidebarGroup>
            <SidebarGroupContent>
              <SidebarMenu>
                <SidebarMenuItem data-sidebar-nav-item>
                  <SidebarMenuButton tooltip="Back to Servers" render={<Link href="/home/servers" />}>
                    <ArrowLeftIcon />
                    <span>Back to Servers</span>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              </SidebarMenu>
            </SidebarGroupContent>
          </SidebarGroup>
        )}
        <SidebarGroup>
          <SidebarGroupLabel>{isServerDetail ? (serverName || "Server") : "Navigation"}</SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu className="flex">
              {navItems.map((item) => (
                <SidebarMenuItem key={item.title} data-sidebar-nav-item>
                  <SidebarMenuButton tooltip={item.title} render={<Link href={item.href} />} className={item.className}>
                    <item.icon />
                    <span>{item.title}</span>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>
        {!isServerDetail && (
          <>
            <SidebarSeparator className="hidden group-data-[collapsible=icon]:group-data-[state=collapsed]:block" />
            <SidebarGroup>
              <SidebarGroupLabel>Recent Servers</SidebarGroupLabel>
              <SidebarGroupContent>
                <SidebarMenu>
                  <SidebarMenuItem>
                    <SidebarMenuButton tooltip="Coming soon" disabled>
                      <ClockIcon />
                      <span className="text-muted-foreground">Coming soon</span>
                    </SidebarMenuButton>
                  </SidebarMenuItem>
                </SidebarMenu>
              </SidebarGroupContent>
            </SidebarGroup>
          </>
        )}
      </SidebarContent>
      <SidebarFooter data-sidebar-footer>
        {account && (
          <SidebarMenu>
            <SidebarMenuItem>
              <div className="flex flex-col gap-1">
                <Popover>
                  <PopoverTrigger>
                    <SidebarMenuButton size="lg">
                      <div className="flex size-8 shrink-0 items-center justify-center rounded-full bg-emerald-100 text-emerald-700">
                        <UserIcon size={16} />
                      </div>
                      <div className="flex-1 min-w-0 text-left">
                        <p className="text-sm font-medium text-gray-900 truncate group-data-[collapsible=icon]:hidden">{account.name}</p>
                        <p className="text-xs text-gray-500 truncate group-data-[collapsible=icon]:hidden">{account.email}</p>
                      </div>
                    </SidebarMenuButton>
                  </PopoverTrigger>
                  <PopoverContent className="w-64" side="top" align="start">
                    <div className="flex flex-col gap-3">
                      <div className="flex items-center gap-3">
                        <div className="flex size-10 shrink-0 items-center justify-center rounded-full bg-emerald-100 text-emerald-700">
                          <UserIcon size={20} />
                        </div>
                        <div className="min-w-0">
                          <p className="text-sm font-semibold text-gray-900 truncate">{account.name}</p>
                          <p className="text-xs text-gray-500 truncate">{account.email}</p>
                        </div>
                      </div>
                      <div className="rounded-md bg-emerald-50 px-3 py-2">
                        <p className="text-xs text-emerald-600 font-medium">Credits</p>
                        <p className="text-lg font-bold text-emerald-700">{account.credits.toFixed(2)} cr</p>
                      </div>
                    </div>
                  </PopoverContent>
                </Popover>
                <div className="flex items-center gap-1 group-data-[collapsible=icon]:hidden">
                  <Tooltip>
                    <TooltipTrigger render={<Button className="flex-1 cursor-pointer" size="sm" variant="outline" onClick={handleRefreshAccount} disabled={refreshing} />}>
                      <ArrowsClockwiseIcon size={14} className={refreshing ? "animate-spin" : ""} />
                      <span className="text-xs">Refresh</span>
                    </TooltipTrigger>
                    <TooltipContent side="top">Refresh account info</TooltipContent>
                  </Tooltip>
                  <Tooltip>
                    <TooltipTrigger render={<Button className="flex-1 cursor-pointer" size="sm" variant="outline" onClick={handleOpenDashboard} />}>
                      <ArrowSquareOutIcon size={14} />
                      <span className="text-xs">Dashboard</span>
                    </TooltipTrigger>
                    <TooltipContent side="top">Open exaroton.com</TooltipContent>
                  </Tooltip>
                  <Tooltip>
                    <TooltipTrigger render={<Button className="shrink-0 cursor-pointer" size="sm" variant="destructive" onClick={handleGoBack} />}>
                      <DoorOpenIcon size={14} />
                    </TooltipTrigger>
                    <TooltipContent side="top">Switch account</TooltipContent>
                  </Tooltip>
                </div>
              </div>
            </SidebarMenuItem>
          </SidebarMenu>
        )}
      </SidebarFooter>
    </Sidebar>
    </div>
  )
}
