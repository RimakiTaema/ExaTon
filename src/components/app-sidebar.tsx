"use client";

import {
  ArrowLeftIcon,
  ClockIcon,
  CubeIcon,
  FolderIcon,
  HouseIcon,
  ScrollIcon,
  SlidersIcon,
  TerminalIcon,
  UserIcon,
  UsersIcon,
  XIcon,
} from "@phosphor-icons/react";
import { invoke } from "@tauri-apps/api/core";
import gsap from "gsap";
import Image from "next/image";
import Link from "next/link";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { useEffect, useRef, useState } from "react";
import { STATUS_MAP } from "@/components/server-card";
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
import { loadRecentServers, type RecentServer, subscribeRecentServers } from "@/lib/recent-servers";
import { useAccount } from "@/hooks/use-account";
import { useErrorReporter } from "@/components/error-handler";
import { AccountInfoCard, AccountActions } from "@/components/account-popover";
import { Popover, PopoverContent, PopoverTrigger } from "./ui/popover";

const mainNavItems = [
  { title: "Home", href: "/home", icon: HouseIcon, className: "" },
  { title: "Servers", href: "/home/servers", icon: CubeIcon, className: "" },
  { title: "Settings", href: "/home/settings", icon: UserIcon, className: "" },
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
  {
    title: "Schedules",
    href: `/home/servers?id=${serverId}&tab=schedules`,
    icon: ClockIcon,
    className: "",
  },
];

export function AppSidebar() {
  const sidebarRef = useRef<HTMLDivElement>(null);
  const { toggleSidebar, open } = useSidebar();
  const acct = useAccount();
  const { reportError } = useErrorReporter();
  const [recentServers, setRecentServers] = useState<RecentServer[]>([]);
  const [serverName, setServerName] = useState<string>("");
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const router = useRouter();
  const logoClickCount = useRef(0);
  const logoTimer = useRef<ReturnType<typeof setTimeout>>(undefined);

  const handleLogoClicks = () => {
    logoClickCount.current += 1;
    clearTimeout(logoTimer.current);

    if (logoClickCount.current >= 3) {
      logoClickCount.current = 0;
      router.push("/home/debug");
      return;
    }

    logoTimer.current = setTimeout(() => {
      logoClickCount.current = 0;
      router.push("/home");
    }, 400);
  };

  const isServerDetail = pathname === "/home/servers" && searchParams.get("id");
  const serverId = searchParams.get("id");
  const navItems = isServerDetail && serverId ? serverNavItems(serverId) : mainNavItems;

  useEffect(() => {
    const currentAccount = acct.account;
    if (!currentAccount) {
      setRecentServers([]);
      return;
    }
    const syncRecent = () => setRecentServers(loadRecentServers(currentAccount.email).slice(0, 5));
    syncRecent();
    return subscribeRecentServers(syncRecent);
  }, [acct.account]);

  useEffect(() => {
    const currentAccount = acct.account;
    if (!isServerDetail || !serverId || !currentAccount) {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setServerName("");
      return;
    }
    const fetchName = async () => {
      try {
        const result = await invoke<{ data?: { name?: string } }>("get_server_info", {
          email: currentAccount.email,
          serverid: serverId,
        });
        setServerName(result.data?.name ?? "");
      } catch {
        reportError("Failed to load server info");
      }
    };
    fetchName();
  }, [isServerDetail, serverId, acct.account]);

  useEffect(() => {
    const hasAccount = !!acct.account;
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
      if (hasAccount) {
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
  }, [acct.account]);

  return (
    <div ref={sidebarRef}>
      <Sidebar collapsible="icon">
        <SidebarHeader>
          <div className="flex items-center justify-between px-2 py-1">
            <button
              type="button"
              onClick={(e) => {
                handleLogoClicks();
                if (!open) toggleSidebar();
              }}
              className="flex items-center gap-2 group-data-[collapsible=icon]:cursor-pointer"
            >
              <Image src="/66498436.png" alt="ExaTon" width={24} height={24} className="shrink-0" />
              <span className="text-sm font-semibold truncate group-data-[collapsible=icon]:hidden">
                ExaTon NEXT
              </span>
            </button>
            <button
              type="button"
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
                    {recentServers.length === 0 && (
                      <SidebarMenuItem>
                        <SidebarMenuButton tooltip="No recent servers" disabled>
                          <ClockIcon />
                          <span className="text-muted-foreground">No recent servers</span>
                        </SidebarMenuButton>
                      </SidebarMenuItem>
                    )}
                    {recentServers.map((server) => {
                      const status = STATUS_MAP[server.status] ?? STATUS_MAP[0];
                      return (
                        <SidebarMenuItem key={`${server.accountEmail}:${server.id}`}>
                          <SidebarMenuButton
                            tooltip={server.name}
                            render={<Link href={`/home/servers?id=${server.id}`} />}
                          >
                            <span className={`size-2 rounded-full ${status.dot}`} />
                            <span>{server.name}</span>
                          </SidebarMenuButton>
                        </SidebarMenuItem>
                      );
                    })}
                  </SidebarMenu>
                </SidebarGroupContent>
              </SidebarGroup>
            </>
          )}
        </SidebarContent>
        <SidebarFooter data-sidebar-footer>
          {acct.account && (
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
                            {acct.account.name}
                          </p>
                          <p className="text-xs text-gray-500 truncate group-data-[collapsible=icon]:hidden">
                            {acct.account.email}
                          </p>
                        </div>
                      </SidebarMenuButton>
                    </PopoverTrigger>
                    <PopoverContent className="w-64" side="top" align="start">
                      <AccountInfoCard
                        account={acct.account}
                        summary={acct.summary}
                        displayMode={acct.displayMode}
                        onProfile={acct.handleProfile}
                      />
                    </PopoverContent>
                  </Popover>
                  <div className="flex items-center gap-1 group-data-[collapsible=icon]:hidden">
                    <AccountActions
                      account={acct.account}
                      refreshing={acct.refreshing}
                      onRefresh={acct.handleRefresh}
                      onDashboard={acct.handleDashboard}
                      onGoBack={acct.handleGoBack}
                    />
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
