"use client"

import { useEffect } from "react"
import { useRouter } from "next/navigation"
import { invoke } from "@tauri-apps/api/core"
import { SidebarProvider } from "@/components/ui/sidebar"
import { AppSidebar } from "@/components/app-sidebar"
import { PageTransition } from "@/components/page-transition"

export default function HomeLayout({ children }: { children: React.ReactNode }) {

  return (
    <SidebarProvider>
      <AppSidebar />
      <main className="flex-1">
        <PageTransition>
          {children}
        </PageTransition>
      </main>
    </SidebarProvider>
  )
}
