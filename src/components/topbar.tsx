"use client";

import { CubeIcon, HouseIcon, UserIcon } from "@phosphor-icons/react";
import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";

const links = [
  { title: "Home", href: "/home", icon: HouseIcon },
  { title: "Servers", href: "/home/servers", icon: CubeIcon },
  { title: "Settings", href: "/home/settings", icon: UserIcon },
];

export function TopBar() {
  const pathname = usePathname();

  return (
    <header className="flex items-center gap-3 border-b border-border bg-card px-4 py-2">
      <Link href="/home" className="flex items-center gap-2 shrink-0">
        <Image src="/66498436.png" alt="ExaTon" width={22} height={22} />
        <span className="text-sm font-semibold hidden sm:inline">ExaTon NEXT</span>
      </Link>
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
    </header>
  );
}
