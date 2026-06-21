"use client";

import { invoke } from "@tauri-apps/api/core";
import gsap from "gsap";
import Link from "next/link";
import { useEffect, useState } from "react";
import { PageTransition } from "@/components/page-transition";
import { ServerCard, type ServerData } from "@/components/server-card";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { recordDebugEvent } from "@/lib/debug-log";

type Account = {
  name: string;
  email: string;
  credits: number;
};

export default function HomePage() {
  const [account, setAccount] = useState<Account | null>(null);
  const [servers, setServers] = useState<ServerData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    try {
      const selectedEmail = localStorage.getItem("exaton_selected_account");
      if (!selectedEmail) {
        setLoading(false);
        return;
      }
      const accounts: Account[] = JSON.parse(localStorage.getItem("exaton_accounts") ?? "[]");
      const found = accounts.find((a) => a.email === selectedEmail);
      if (found) {
        setAccount(found);
      } else {
        setLoading(false);
      }
    } catch (err) {
      recordDebugEvent({
        level: "error",
        scope: "home",
        message: "Account load failed",
        detail: err,
      });
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    if (!account) return;

    const fetchServers = async () => {
      try {
        setLoading(true);
        setError("");
        recordDebugEvent({
          scope: "home",
          message: "Loading home server preview",
          detail: { email: account.email },
        });
        const result = await invoke<{ success?: boolean; data?: ServerData[] }>(
          "get_servers_info",
          { email: account.email },
        );
        setServers(result.data ?? []);
      } catch (err) {
        recordDebugEvent({
          level: "error",
          scope: "home",
          message: "Home server preview failed",
          detail: err,
        });
        setError(String(err));
      } finally {
        setLoading(false);
      }
    };

    fetchServers();
  }, [account]);

  useEffect(() => {
    if (!loading && servers.length > 0) {
      gsap.from("[data-server-card]", {
        opacity: 0,
        y: 15,
        duration: 0.3,
        stagger: 0.06,
        ease: "power2.out",
      });
    }
  }, [loading, servers]);

  return (
    <PageTransition>
      <div className="flex flex-col px-2 py-2 gap-4">
        <div className="text-2xl font-bold">
          Welcome Back{account?.name ? ` ${account.name}` : ""}!
        </div>
        <div>
          <div className="text-xl font-semibold mb-3">Servers</div>
          {loading && (
            <div className="grid gap-3 sm:grid-cols-1 md:grid-cols-2 lg:grid-cols-3">
              {[1, 2, 3].map((i) => (
                <Skeleton key={i} className="h-28 rounded-xl" />
              ))}
            </div>
          )}
          {error && (
            <div className="flex items-center gap-2">
              <p className="text-sm text-red-600">{error}</p>
              <Button variant="outline" size="sm" onClick={() => window.location.reload()}>
                Retry
              </Button>
            </div>
          )}
          {!loading && !error && servers.length === 0 && (
            <p className="text-sm text-muted-foreground">No servers found.</p>
          )}
          {!loading && servers.length > 0 && (
            <>
              <div className="grid gap-3 sm:grid-cols-1 md:grid-cols-2 lg:grid-cols-3">
                {servers.slice(0, 2).map((server) => (
                  <div key={server.id} data-server-card>
                    <ServerCard server={server} />
                  </div>
                ))}
              </div>
              <Link
                href="/home/servers"
                className="text-sm text-muted-foreground hover:text-foreground transition-colors text-center block mt-3"
              >
                View all {servers.length} servers →
              </Link>
            </>
          )}
        </div>
      </div>
    </PageTransition>
  );
}
