"use client";

import { Suspense, useEffect, useState } from "react";
import { AppSidebar } from "@/components/app-sidebar";
import { PageTransition } from "@/components/page-transition";
import { TopBar } from "@/components/topbar";
import { SidebarProvider } from "@/components/ui/sidebar";
import { type LayoutMode, loadLayoutMode } from "@/lib/display-prefs";
import { LayoutCtx } from "@/lib/layout-context";

function HomeLayoutInner({ children }: { children: React.ReactNode }) {
  const [layout, setLayout] = useState<LayoutMode | null>(null);
  const [isServerDetail, setIsServerDetail] = useState(false);

  useEffect(() => {
    setLayout(loadLayoutMode());
    const handleChange = () => setLayout(loadLayoutMode());
    window.addEventListener("layout-mode-changed", handleChange);
    return () => window.removeEventListener("layout-mode-changed", handleChange);
  }, []);

  return (
    <LayoutCtx.Provider value={{ isServerDetail, setIsServerDetail }}>
      {layout === "sidebar" ? (
        <div className="flex w-full min-h-svh">
          <SidebarProvider>
            <AppSidebar />
            <main className="flex-1 min-w-0">
              <Suspense>
                <PageTransition>{children}</PageTransition>
              </Suspense>
            </main>
          </SidebarProvider>
        </div>
      ) : (
        <div className="flex flex-col w-full min-h-svh">
          {layout !== null && !isServerDetail && <TopBar />}
          <main className="flex-1 min-w-0 min-h-svh">
            <Suspense>
              <PageTransition>{children}</PageTransition>
            </Suspense>
          </main>
        </div>
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
