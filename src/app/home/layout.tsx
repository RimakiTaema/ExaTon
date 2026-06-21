"use client";

import { Suspense, useEffect, useState } from "react";
import { AppSidebar } from "@/components/app-sidebar";
import { PageTransition } from "@/components/page-transition";
import { TopBar } from "@/components/topbar";
import { SidebarProvider } from "@/components/ui/sidebar";
import { type LayoutMode, loadLayoutMode } from "@/lib/display-prefs";
import { LayoutCtx } from "@/lib/layout-context";

function HomeLayoutInner({ children }: { children: React.ReactNode }) {
  const [layout, setLayout] = useState<LayoutMode>("topbar");
  const [isServerDetail, setIsServerDetail] = useState(false);

  useEffect(() => {
    setLayout(loadLayoutMode());
    const handleChange = () => setLayout(loadLayoutMode());
    window.addEventListener("layout-mode-changed", handleChange);
    return () => window.removeEventListener("layout-mode-changed", handleChange);
  }, []);

  // Server detail: pure content, no sidebar/topbar — self-contained with inline tabs
  if (isServerDetail) {
    return (
      <LayoutCtx.Provider value={{ isServerDetail, setIsServerDetail }}>
        <main className="flex-1 min-w-0">
          <Suspense>
            <PageTransition>{children}</PageTransition>
          </Suspense>
        </main>
      </LayoutCtx.Provider>
    );
  }

  // Non-server pages: sidebar or topbar
  return (
    <LayoutCtx.Provider value={{ isServerDetail, setIsServerDetail }}>
      {layout === "topbar" ? (
        <div className="flex flex-col w-full">
          <TopBar />
          <main className="flex-1">
            <Suspense>
              <PageTransition>{children}</PageTransition>
            </Suspense>
          </main>
        </div>
      ) : (
        <SidebarProvider>
          <Suspense>
            <AppSidebar />
          </Suspense>
          <main className="flex-1">
            <Suspense>
              <PageTransition>{children}</PageTransition>
            </Suspense>
          </main>
        </SidebarProvider>
      )}
    </LayoutCtx.Provider>
  );
}

export default function HomeLayout({ children }: { children: React.ReactNode }) {
  return (
    <Suspense>
      <HomeLayoutInner>{children}</HomeLayoutInner>
    </Suspense>
  );
}
