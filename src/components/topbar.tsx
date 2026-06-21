"use client";

import { CubeIcon, HouseIcon, UserIcon } from "@phosphor-icons/react";
import Image from "next/image";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useRef } from "react";
import { useAccount } from "@/hooks/use-account";
import { AccountInfoCard, AccountActions } from "@/components/account-popover";
import { Popover, PopoverContent, PopoverTrigger } from "./ui/popover";

const links = [
  { title: "Home", href: "/home", icon: HouseIcon },
  { title: "Servers", href: "/home/servers", icon: CubeIcon },
  { title: "Settings", href: "/home/settings", icon: UserIcon },
];

export function TopBar() {
  const pathname = usePathname();
  const router = useRouter();
  const acct = useAccount();
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

  return (
    <header className="flex items-center gap-3 border-b border-border bg-card px-4 py-2">
      <button
        type="button"
        onClick={handleLogoClicks}
        className="flex items-center gap-2 shrink-0 cursor-pointer"
      >
        <Image src="/66498436.png" alt="ExaTon" width={22} height={22} />
        <span className="text-sm font-semibold hidden sm:inline">ExaTon NEXT</span>
      </button>
      <nav className="flex items-center gap-1 ml-4">
        {links.map(({ title, href, icon: Icon }) => {
          const active = pathname === href || (href !== "/home" && pathname.startsWith(href));
          return (
            <Link
              key={href}
              href={href}
              className={`flex items-center gap-1.5 rounded-md px-3 py-1.5 text-xs font-medium transition-colors ${
                active
                  ? "bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400"
                  : "text-muted-foreground hover:text-foreground hover:bg-muted"
              }`}
            >
              <Icon size={14} />
              {title}
            </Link>
          );
        })}
      </nav>
      {acct.account && (
        <div className="ml-auto">
          <Popover>
            <PopoverTrigger
              render={
                <button
                  type="button"
                  className="flex items-center gap-2 rounded-md px-2 py-1 text-xs text-muted-foreground hover:text-foreground hover:bg-muted transition-colors cursor-pointer"
                />
              }
            >
              <UserIcon size={14} />
              <span className="hidden sm:inline">{acct.account.name}</span>
            </PopoverTrigger>
            <PopoverContent className="w-64" side="bottom" align="end">
              <AccountInfoCard
                account={acct.account}
                summary={acct.summary}
                displayMode={acct.displayMode}
                onProfile={acct.handleProfile}
              />
              <div className="mt-2 border-t border-border pt-2">
                <AccountActions
                  account={acct.account}
                  refreshing={acct.refreshing}
                  onRefresh={acct.handleRefresh}
                  onDashboard={acct.handleDashboard}
                  onGoBack={acct.handleGoBack}
                  variant="popover"
                />
              </div>
            </PopoverContent>
          </Popover>
        </div>
      )}
    </header>
  );
}
