"use client";

import {
  ArrowLeftIcon,
  ArrowSquareOutIcon,
  ArrowsClockwiseIcon,
  BugIcon,
  ClockIcon,
  CubeIcon,
  DoorOpenIcon,
  FolderIcon,
  GearIcon,
  HouseIcon,
  ScrollIcon,
  SlidersIcon,
  TerminalIcon,
  UserIcon,
  UsersIcon,
  XIcon,
} from "@phosphor-icons/react";
import { invoke } from "@tauri-apps/api/core";
import { openUrl } from "@tauri-apps/plugin-opener";
import gsap from "gsap";
import Image from "next/image";
import Link from "next/link";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { useEffect, useRef, useState } from "react";
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
} from "@/components/ui/sidebar";
import {
  type CachedAccountSummary,
  formatAgo,
  loadCachedSummary,
  refreshAccountSummary,
  saveCachedSummary,
} from "@/lib/account-summary";
import { type CreditDisplay, loadCreditDisplay } from "@/lib/display-prefs";
import { Button } from "./ui/button";
import { Popover, PopoverContent, PopoverTrigger } from "./ui/popover";
import { Tooltip, TooltipContent, TooltipTrigger } from "./ui/tooltip";

type Account = {
  name: string;
  email: string;
  credits: number;
};

const mainNavItems = [
  { title: "Home", href: "/home", icon: HouseIcon, className: "" },
  { title: "Servers", href: "/home/servers", icon: CubeIcon, className: "" },
  { title: "Settings", href: "/home/settings", icon: GearIcon, className: "" },
  {
    title: "Debug Option",
    href: "/home/debug",
    icon: BugIcon,
    className:
      "text-red-500 hover:bg-red-50 hover:text-red-600 data-[active=true]:bg-red-50 data-[active=true]:text-red-600",
  },
];

const serverNavItems = (serverId: string) => [
  { title: "Overview", href: `/home/servers?id=${serverId}`, icon: CubeIcon, className: "" },
  {
    title: "Console",
    href: `/home/servers?id=${serverId}&tab=console`,
    icon: TerminalIcon,
    className: "",
  },
  {
    title: "Files",
    href: `/home/servers?id=${serverId}&tab=files`,
    icon: FolderIcon,
    className: "",
  },
  {
    title: "Players",
    href: `/home/servers?id=${serverId}&tab=players`,
    icon: UsersIcon,
    className: "",
  },
  { title: "Logs", href: `/home/servers?id=${serverId}&tab=logs`, icon: ScrollIcon, className: "" },
  {
    title: "Options",
    href: `/home/servers?id=${serverId}&tab=options`,
    icon: SlidersIcon,
    className: "",
  },
];

export function AppSidebar() {
  const sidebarRef = useRef<HTMLDivElement>(null);
  const { toggleSidebar, open } = useSidebar();
  const [account, setAccount] = useState<Account | null>(null);
  const [summary, setSummary] = useState<CachedAccountSummary | null>(null);
  const [displayMode, setDisplayMode] = useState<CreditDisplay>("both");
  const [serverName, setServerName] = useState<string>("");
  const [refreshing, setRefreshing] = useState(false);
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const router = useRouter();

  const handleGoBack = (e: React.MouseEvent) => {
    e.stopPropagation();
    router.push("/");
  };

  const handleRefreshAccount = async (e: React.MouseEvent) => {
    e.stopPropagation();
    if (!account || refreshing) return;
    setRefreshing(true);
    try {
      const fresh = await refreshAccountSummary(account.email);
      const cached = saveCachedSummary(fresh);
      setSummary(cached);
      const updated: Account = {
        name: fresh.name || account.name,
        email: fresh.email,
        credits: fresh.personalCredits,
      };
      setAccount(updated);
      const accounts: Account[] = JSON.parse(localStorage.getItem("exaton_accounts") ?? "[]");
      const idx = accounts.findIndex((a) => a.email === account.email);
      if (idx !== -1) {
        const next = [...accounts];
        next[idx] = updated;
        localStorage.setItem("exaton_accounts", JSON.stringify(next));
      }
    } catch {
      /* empty */
    }
    setRefreshing(false);
  };

  const handleOpenDashboard = (e: React.MouseEvent) => {
    e.stopPropagation();
    openUrl("https://exaroton.com/account/");
  };

  const isServerDetail = pathname === "/home/servers" && searchParams.get("id");
  const serverId = searchParams.get("id");
  const navItems = isServerDetail && serverId ? serverNavItems(serverId) : mainNavItems;

  useEffect(() => {
    try {
      const selectedEmail = localStorage.getItem("exaton_selected_account");
      if (!selectedEmail) return;
      const accounts: Account[] = JSON.parse(localStorage.getItem("exaton_accounts") ?? "[]");
      const found = accounts.find((a) => a.email === selectedEmail);
      if (found) {
        setAccount(found);
        const cached = loadCachedSummary(found.email);
        if (cached) setSummary(cached);
        refreshAccountSummary(found.email)
          .then((fresh) => setSummary(saveCachedSummary(fresh)))
          .catch(() => {
            /* keep cached */
          });
      }
    } catch {
      /* empty */
    }
  }, []);

  useEffect(() => {
    const syncDisplay = () => setDisplayMode(loadCreditDisplay());
    syncDisplay();
    window.addEventListener("focus", syncDisplay);
    return () => window.removeEventListener("focus", syncDisplay);
  }, []);

  useEffect(() => {
    if (!isServerDetail || !serverId || !account) {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setServerName("");
      return;
    }
    const fetchName = async () => {
      try {
        const result = await invoke<{ data?: { name?: string } }>("get_server_info", {
          email: account.email,
          serverid: serverId,
        });
        setServerName(result.data?.name ?? "");
      } catch {
        /* empty */
      }
    };
    fetchName();
  }, [isServerDetail, serverId, account]);

  useEffect(() => {
    if (!sidebarRef.current) return;
    const ctx = gsap.context(() => {
      const tl = gsap.timeline();
      tl.from("[data-sidebar-nav-item]", {
        opacity: 0,
        x: -15,
        duration: 0.3,
        stagger: 0.05,
        delay: 0.1,
        ease: "power2.out",
      });
      if (account) {
        tl.from(
          "[data-sidebar-footer]",
          {
            opacity: 0,
            y: 10,
            duration: 0.3,
            ease: "power2.out",
          },
          "-=0.1",
        );
      }
    }, sidebarRef);
    return () => ctx.revert();
  }, [account]);

  return (
    <div ref={sidebarRef}>
      <Sidebar collapsible="icon">
        <SidebarHeader>
          <div className="flex items-center justify-between px-2 py-1">
            <button
              onClick={() => !open && toggleSidebar()}
              className="flex items-center gap-2 group-data-[collapsible=icon]:cursor-pointer"
            >
              <Image src="/66498436.png" alt="ExaTon" width={24} height={24} className="shrink-0" />
              <span className="text-sm font-semibold truncate group-data-[collapsible=icon]:hidden">
                ExaTon NEXT
              </span>
            </button>
            <button
              onClick={toggleSidebar}
              className="group-data-[collapsible=icon]:hidden cursor-pointer text-muted-foreground hover:text-foreground"
            >
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
                    <SidebarMenuButton
                      tooltip="Back to Servers"
                      render={<Link href="/home/servers" />}
                    >
                      <ArrowLeftIcon />
                      <span>Back to Servers</span>
                    </SidebarMenuButton>
                  </SidebarMenuItem>
                </SidebarMenu>
              </SidebarGroupContent>
            </SidebarGroup>
          )}
          <SidebarGroup>
            <SidebarGroupLabel>
              {isServerDetail ? serverName || "Server" : "Navigation"}
            </SidebarGroupLabel>
            <SidebarGroupContent>
              <SidebarMenu className="flex">
                {navItems.map((item) => (
                  <SidebarMenuItem key={item.title} data-sidebar-nav-item>
                    <SidebarMenuButton
                      tooltip={item.title}
                      render={<Link href={item.href} />}
                      className={item.className}
                    >
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
                          <p className="text-sm font-medium text-gray-900 truncate group-data-[collapsible=icon]:hidden">
                            {account.name}
                          </p>
                          <p className="text-xs text-gray-500 truncate group-data-[collapsible=icon]:hidden">
                            {account.email}
                          </p>
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
                            <p className="text-sm font-semibold text-gray-900 truncate">
                              {account.name}
                            </p>
                            <p className="text-xs text-gray-500 truncate">{account.email}</p>
                          </div>
                        </div>
                        <div className="rounded-md bg-emerald-50 px-3 py-2">
                          <p className="text-xs text-emerald-600 font-medium">Credits</p>
                          {displayMode === "personal" && (
                            <p className="text-lg font-bold text-emerald-700">
                              {(summary?.personalCredits ?? account.credits).toFixed(2)} cr
                            </p>
                          )}
                          {displayMode === "pool" && (
                            <p className="text-lg font-bold text-emerald-700">
                              {(summary?.poolCredits ?? 0).toFixed(2)} pool
                            </p>
                          )}
                          {displayMode === "both" && (
                            <>
                              <p className="text-lg font-bold text-emerald-700">
                                {(summary?.personalCredits ?? account.credits).toFixed(2)} cr
                              </p>
                              {summary && summary.poolCredits > 0 && (
                                <p className="text-xs text-emerald-700/80">
                                  + {summary.poolCredits.toFixed(2)} pool
                                </p>
                              )}
                            </>
                          )}
                          {summary && (
                            <p className="mt-1 text-[10px] text-emerald-700/60">
                              updated {formatAgo(summary.updatedAt)}
                            </p>
                          )}
                        </div>
                        {summary && summary.pools.length > 0 && (
                          <div className="rounded-md bg-gray-50 px-3 py-2">
                            <p className="mb-1 text-xs font-medium text-gray-600">Pools</p>
                            <div className="flex flex-col gap-1">
                              {summary.pools.map((p) => (
                                <div
                                  key={p.id}
                                  className="flex items-center justify-between gap-2 text-xs"
                                >
                                  <span className="truncate text-gray-900">
                                    {p.name}
                                    {p.isOwner && (
                                      <span className="ml-1 text-[10px] text-emerald-600">
                                        (owner)
                                      </span>
                                    )}
                                  </span>
                                  <span className="text-gray-500">
                                    {p.ownCredits.toFixed(2)}
                                    <span className="text-gray-400">
                                      {" "}
                                      / {p.totalCredits.toFixed(2)}
                                    </span>
                                  </span>
                                </div>
                              ))}
                            </div>
                          </div>
                        )}
                      </div>
                    </PopoverContent>
                  </Popover>
                  <div className="flex items-center gap-1 group-data-[collapsible=icon]:hidden">
                    <Tooltip>
                      <TooltipTrigger
                        render={
                          <Button
                            className="flex-1 cursor-pointer"
                            size="sm"
                            variant="outline"
                            onClick={handleRefreshAccount}
                            disabled={refreshing}
                          />
                        }
                      >
                        <ArrowsClockwiseIcon
                          size={14}
                          className={refreshing ? "animate-spin" : ""}
                        />
                        <span className="text-xs">Refresh</span>
                      </TooltipTrigger>
                      <TooltipContent side="top">Refresh account info</TooltipContent>
                    </Tooltip>
                    <Tooltip>
                      <TooltipTrigger
                        render={
                          <Button
                            className="flex-1 cursor-pointer"
                            size="sm"
                            variant="outline"
                            onClick={handleOpenDashboard}
                          />
                        }
                      >
                        <ArrowSquareOutIcon size={14} />
                        <span className="text-xs">Dashboard</span>
                      </TooltipTrigger>
                      <TooltipContent side="top">Open exaroton.com</TooltipContent>
                    </Tooltip>
                    <Tooltip>
                      <TooltipTrigger
                        render={
                          <Button
                            className="shrink-0 cursor-pointer"
                            size="sm"
                            variant="destructive"
                            onClick={handleGoBack}
                          />
                        }
                      >
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
  );
}
