"use client";
import {
  ArrowsClockwiseIcon,
  CoinsIcon,
  DotsThreeVerticalIcon,
  GearIcon,
  PlusIcon,
  UserIcon,
} from "@phosphor-icons/react";
import { invoke } from "@tauri-apps/api/core";
import { openUrl } from "@tauri-apps/plugin-opener";
import gsap from "gsap";
import Image from "next/image";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useCallback, useEffect, useRef, useState } from "react";
import { Button } from "@/components/ui/button";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import {
  type CachedAccountSummary,
  clearCachedSummary,
  formatAgo,
  loadCachedSummary,
  type PoolSummary,
  refreshAccountSummary,
  saveCachedSummary,
} from "@/lib/account-summary";
import { type CreditDisplay, loadCreditDisplay } from "@/lib/display-prefs";

type Account = {
  name: string;
  email: string;
  credits: number;
};

export default function Home() {
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [summaries, setSummaries] = useState<Record<string, CachedAccountSummary>>({});
  const [refreshing, setRefreshing] = useState<Record<string, boolean>>({});
  const [displayMode, setDisplayMode] = useState<CreditDisplay>("both");
  const cardRef = useRef<HTMLDivElement>(null);
  const contentRef = useRef<HTMLDivElement>(null);

  const refreshOne = useCallback(async (email: string) => {
    setRefreshing((r) => ({ ...r, [email]: true }));
    try {
      const summary = await refreshAccountSummary(email);
      const cached = saveCachedSummary(summary);
      setSummaries((prev) => ({ ...prev, [email]: cached }));
    } catch {
      /* keep cached value on failure */
    } finally {
      setRefreshing((r) => ({ ...r, [email]: false }));
    }
  }, []);

  const refreshAll = useCallback(
    (emails: string[]) => {
      for (const email of emails) refreshOne(email);
    },
    [refreshOne],
  );

  useEffect(() => {
    try {
      const raw = localStorage.getItem("exaton_accounts");
      if (!raw) return;
      const parsed: Account[] = JSON.parse(raw);
      setAccounts(parsed);
      const hydrated: Record<string, CachedAccountSummary> = {};
      for (const acc of parsed) {
        const cached = loadCachedSummary(acc.email);
        if (cached) hydrated[acc.email] = cached;
      }
      setSummaries(hydrated);
      refreshAll(parsed.map((a) => a.email));
    } catch {
      /* empty */
    }
  }, [refreshAll]);

  useEffect(() => {
    const syncDisplay = () => setDisplayMode(loadCreditDisplay());
    syncDisplay();
    window.addEventListener("focus", syncDisplay);
    return () => window.removeEventListener("focus", syncDisplay);
  }, []);

  useEffect(() => {
    const onFocus = () => refreshAll(accounts.map((a) => a.email));
    window.addEventListener("focus", onFocus);
    return () => window.removeEventListener("focus", onFocus);
  }, [accounts, refreshAll]);

  useEffect(() => {
    const ctx = gsap.context(() => {
      gsap.from(cardRef.current, {
        opacity: 0,
        y: 20,
        scale: 0.97,
        duration: 0.4,
        ease: "power3.out",
      });
      gsap.from(contentRef.current, {
        opacity: 0,
        x: -30,
        duration: 0.35,
        delay: 0.15,
        ease: "power2.out",
      });
    });
    return () => ctx.revert();
  }, []);

  // Stagger animate account cards after they render
  useEffect(() => {
    if (accounts.length > 0) {
      gsap.from("[data-account-card]", {
        opacity: 0,
        y: 12,
        duration: 0.3,
        stagger: 0.06,
        delay: 0.25,
        ease: "power2.out",
      });
    }
  }, [accounts]);

  useEffect(() => {
    window.addEventListener("keydown", (e) => {
      if (e.key === "p") {
        window.location.reload();
      }
    });
  }, []);

  const router = useRouter();

  const handleSelect = (account: Account) => {
    localStorage.setItem("exaton_selected_account", account.email);
    router.push("/home");
  };

  const handleLogout = async (e: React.MouseEvent, account: Account) => {
    e.stopPropagation();
    try {
      await invoke("delete_token", { email: account.email }).catch(() => {});
    } catch {
      /* empty */
    }
    clearCachedSummary(account.email);
    const updated = accounts.filter((a) => a.email !== account.email);
    setAccounts(updated);
    setSummaries((prev) => {
      const next = { ...prev };
      delete next[account.email];
      return next;
    });
    localStorage.setItem("exaton_accounts", JSON.stringify(updated));
    if (localStorage.getItem("exaton_selected_account") === account.email) {
      localStorage.removeItem("exaton_selected_account");
    }
  };

  return (
    <div className="flex h-screen items-center justify-center">
      <div ref={cardRef} className="relative w-96 rounded-xl bg-white p-8 shadow-lg">
        <Link
          href="/settings"
          className="absolute top-3 right-3 text-gray-400 hover:text-gray-700"
          aria-label="Settings"
        >
          <GearIcon size={18} />
        </Link>
        <div className="flex flex-col items-center justify-center">
          <Image src="/66498436.png" alt="Exaroton Logo" width={50} height={50} />
        </div>
        <div className="text-center text-2xl leading-tight tracking-tight text-gray-900 font-semibold">
          ExaTon
          <p className="text-lg leading-tight tracking-tight text-emerald-700 text-shadow-2xs text-shadow-emerald-300">
            NEXT
          </p>
        </div>
        <br />
        <div ref={contentRef}>
          {accounts.length > 0 ? (
            <div className="flex flex-col gap-2">
              {accounts.map((account) => {
                const summary = summaries[account.email];
                const personal = summary?.personalCredits ?? account.credits;
                const pool = summary?.poolCredits ?? 0;
                const isRefreshing = refreshing[account.email];
                return (
                  <button
                    type="button"
                    key={account.email}
                    data-account-card
                    onClick={() => handleSelect(account)}
                    className="flex items-center gap-3 rounded-lg border border-gray-200 p-3 text-left transition-colors hover:bg-gray-50 cursor-pointer"
                  >
                    <div className="flex h-9 w-9 items-center justify-center rounded-full bg-emerald-100 text-emerald-700">
                      <UserIcon size={18} />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-gray-900 truncate">{account.name}</p>
                      <p className="text-xs text-gray-500 truncate">{account.email}</p>
                    </div>
                    <div className="flex flex-col items-end gap-0.5">
                      <CreditsDisplay mode={displayMode} personal={personal} pool={pool} />
                      <div className="flex items-center gap-1">
                        {summary && (
                          <span className="text-[10px] text-gray-400">
                            {formatAgo(summary.updatedAt)}
                          </span>
                        )}
                        {summary && summary.pools.length > 0 && (
                          <PoolPopover pools={summary.pools} />
                        )}
                        <button
                          type="button"
                          className="text-gray-400 hover:text-emerald-600 disabled:opacity-40"
                          disabled={isRefreshing}
                          onClick={(e) => {
                            e.stopPropagation();
                            refreshOne(account.email);
                          }}
                          aria-label={`Refresh credits for ${account.email}`}
                        >
                          <ArrowsClockwiseIcon
                            size={12}
                            className={isRefreshing ? "animate-spin" : ""}
                          />
                        </button>
                      </div>
                    </div>
                    <Popover>
                      <PopoverTrigger onClick={(e) => e.stopPropagation()}>
                        <DotsThreeVerticalIcon size={16} />
                      </PopoverTrigger>
                      <PopoverContent className="w-40" onClick={(e) => e.stopPropagation()}>
                        <Button
                          variant="destructive"
                          className="w-full cursor-pointer"
                          onClick={(e) => handleLogout(e, account)}
                        >
                          Logout
                        </Button>
                      </PopoverContent>
                    </Popover>
                  </button>
                );
              })}
              <Link
                href="/login"
                data-account-card
                className="flex items-center gap-3 rounded-lg border border-dashed border-gray-300 p-3 text-left transition-colors hover:bg-gray-50 cursor-pointer"
              >
                <div className="flex h-9 w-9 items-center justify-center rounded-full bg-gray-100 text-gray-500">
                  <PlusIcon size={18} />
                </div>
                <p className="text-sm text-gray-500">Add another account</p>
              </Link>
            </div>
          ) : (
            <div className="flex content-center items-center justify-center gap-2">
              <Button>
                <Link href="/login">Login</Link>
              </Button>
              <Button
                className="cursor-pointer"
                onClick={() => openUrl("https://exaroton.com/signup")}
              >
                Register
              </Button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

function CreditsDisplay({
  mode,
  personal,
  pool,
}: {
  mode: CreditDisplay;
  personal: number;
  pool: number;
}) {
  if (mode === "personal") {
    return <span className="text-xs text-emerald-700 font-medium">{personal.toFixed(2)} cr</span>;
  }
  if (mode === "pool") {
    return <span className="text-xs text-emerald-700 font-medium">{pool.toFixed(2)} pool</span>;
  }
  return (
    <div className="flex items-baseline gap-1.5">
      <span className="text-xs text-emerald-700 font-medium">{personal.toFixed(2)} cr</span>
      {pool > 0 && <span className="text-[10px] text-gray-500">+{pool.toFixed(2)} pool</span>}
    </div>
  );
}

function PoolPopover({ pools }: { pools: PoolSummary[] }) {
  return (
    <Popover>
      <PopoverTrigger
        onClick={(e) => e.stopPropagation()}
        className="text-gray-400 hover:text-emerald-600"
        aria-label="View credit pools"
      >
        <CoinsIcon size={12} />
      </PopoverTrigger>
      <PopoverContent className="w-60" onClick={(e) => e.stopPropagation()}>
        <p className="mb-2 text-xs font-medium text-gray-700">Credit pools</p>
        <div className="flex flex-col gap-1.5">
          {pools.map((p) => (
            <div key={p.id} className="flex items-center justify-between gap-2 text-xs">
              <span className="truncate text-gray-900">
                {p.name}
                {p.isOwner && <span className="ml-1 text-[10px] text-emerald-600">(owner)</span>}
              </span>
              <span className="text-gray-500">
                {p.ownCredits.toFixed(2)}
                <span className="text-gray-400"> / {p.totalCredits.toFixed(2)}</span>
              </span>
            </div>
          ))}
        </div>
      </PopoverContent>
    </Popover>
  );
}
