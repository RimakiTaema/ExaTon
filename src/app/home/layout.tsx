"use client"

import { Suspense } from "react"
import { SidebarProvider } from "@/components/ui/sidebar"
import { AppSidebar } from "@/components/app-sidebar"
import { PageTransition } from "@/components/page-transition"

export default function HomeLayout({ children }: { children: React.ReactNode }) {

  return (
    <SidebarProvider>
      <Suspense>
        <AppSidebar />
      </Suspense>
      <main className="flex-1">
        <Suspense>
          <PageTransition>
            {children}
          </PageTransition>
        </Suspense>
      </main>
    </SidebarProvider>
  )
}
