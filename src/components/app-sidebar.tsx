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
} from "@/components/ui/sidebar"
import { useEffect, useRef, useState } from "react"
import gsap from "gsap"
import { HouseIcon, CubeIcon, GearIcon, UserIcon, ClockIcon } from "@phosphor-icons/react"
import Image from "next/image"
import Link from "next/link"

type Account = {
  name: string
  email: string
  credits: number
}

const navItems = [
  { title: "Home", href: "/home", icon: HouseIcon, className: "" },
  { title: "Servers", href: "/home/servers", icon: CubeIcon, className: "" },
  { title: "Settings", href: "/home/settings", icon: GearIcon, className: "" },
  { title: "Debug Option", href: "/home/debug", icon: GearIcon, className: "text-red-500 hover:bg-red-50 hover:text-red-600 data-[active=true]:bg-red-50 data-[active=true]:text-red-600"}
]

export function AppSidebar() {
  const sidebarRef = useRef<HTMLDivElement>(null)
  const [account, setAccount] = useState<Account | null>(null)

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
  }, [account])

  return (
    <div ref={sidebarRef}>
    <Sidebar collapsible="icon">
      <SidebarHeader>
        <div className="flex items-center gap-2 px-2 py-1">
          <Image src="/66498436.png" alt="ExaTon" width={24} height={24} className="shrink-0" />
          <span className="text-sm font-semibold truncate group-data-[collapsible=icon]:hidden">ExaTon NEXT</span>
        </div>
      </SidebarHeader>
      <SidebarContent>
        <SidebarGroup>
          <SidebarGroupLabel>Navigation</SidebarGroupLabel>
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
      </SidebarContent>
      <SidebarFooter data-sidebar-footer>
        {account && (
          <SidebarMenu>
            <SidebarMenuItem>
              <SidebarMenuButton size="lg">
                <div className="flex size-8 shrink-0 items-center justify-center rounded-full bg-emerald-100 text-emerald-700">
                  <UserIcon size={16} />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-gray-900 truncate group-data-[collapsible=icon]:hidden">{account.name}</p>
                  <p className="text-xs text-gray-500 truncate group-data-[collapsible=icon]:hidden">{account.email}</p>
                </div>
              </SidebarMenuButton>
            </SidebarMenuItem>
          </SidebarMenu>
        )}
      </SidebarFooter>
    </Sidebar>
    </div>
  )
}
