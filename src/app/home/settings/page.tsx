"use client";

import {
  ArrowSquareOutIcon,
  ArrowsClockwiseIcon,
  ClockCounterClockwiseIcon,
  DoorOpenIcon,
  SlidersIcon,
  UserIcon,
} from "@phosphor-icons/react";
import { openUrl } from "@tauri-apps/plugin-opener";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { GlobalCreditGraph } from "@/components/credit/global-credit-graph";
import { PageTransition } from "@/components/page-transition";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { useAccount } from "@/hooks/use-account";
import {
  type CachedAccountSummary,
  formatAgo,
  loadCachedSummary,
  refreshAccountSummary,
  saveCachedSummary,
} from "@/lib/account-summary";
import { APP_VERSION } from "@/lib/app-info";
import { type CreditSnapshot, loadCreditHistory } from "@/lib/credit-history";
import {
  type CreditDisplay,
  type LayoutMode,
  loadCreditDisplay,
  loadLayoutMode,
  saveCreditDisplay,
  saveLayoutMode,
} from "@/lib/display-prefs";
import { clearRecentServers, loadRecentServers } from "@/lib/recent-servers";

const DISPLAY_OPTIONS: { value: CreditDisplay; label: string; hint: string }[] = [
  { value: "both", label: "Both", hint: "Personal credits plus pool credits." },
  { value: "personal", label: "Personal", hint: "Only your own balance." },
  { value: "pool", label: "Pool", hint: "Only your pool share." },
];

export default function SettingPage() {
  const account = useAccount();
  const router = useRouter();
  const [summary, setSummary] = useState<CachedAccountSummary | null>(null);
  const [displayMode, setDisplayMode] = useState<CreditDisplay>("both");
  const [layoutMode, setLayoutMode] = useState<LayoutMode>("topbar");
  const [recentCount, setRecentCount] = useState(0);
  const [refreshing, setRefreshing] = useState(false);
  const [creditHistory, setCreditHistory] = useState<CreditSnapshot[]>([]);

  useEffect(() => {
    setDisplayMode(loadCreditDisplay());
    setLayoutMode(loadLayoutMode());
  }, []);

  useEffect(() => {
    if (!account) return;
    setSummary(loadCachedSummary(account.email));
    setRecentCount(loadRecentServers(account.email).length);
    const history = loadCreditHistory(account.email);
    setCreditHistory(history);
  }, [account]);

  const chooseDisplay = (mode: CreditDisplay) => {
    setDisplayMode(mode);
    saveCreditDisplay(mode);
  };

  const chooseLayout = (mode: LayoutMode) => {
    setLayoutMode(mode);
    saveLayoutMode(mode);
  };

  const refreshProfile = async () => {
    if (!account || refreshing) return;
    setRefreshing(true);
    try {
      const fresh = await refreshAccountSummary(account.email);
      setSummary(saveCachedSummary(fresh));
      setCreditHistory(loadCreditHistory(account.email));
    } finally {
      setRefreshing(false);
    }
  };

  const clearRecent = () => {
    if (!account) return;
    clearRecentServers(account.email);
    setRecentCount(0);
  };

  const switchAccount = () => {
    router.push("/");
  };

  if (!account) {
    return (
      <PageTransition>
        <div className="flex flex-col gap-3 p-2">
          <Skeleton className="h-10 w-56 rounded-md" />
          <p className="text-sm text-muted-foreground">No active profile selected.</p>
        </div>
      </PageTransition>
    );
  }

  return (
    <PageTransition>
      <div className="flex max-w-4xl flex-col gap-5 px-2 py-2">
        <div className="flex flex-wrap items-center gap-3">
          <div className="flex size-10 items-center justify-center rounded-md bg-emerald-100 text-emerald-700">
            <UserIcon size={20} />
          </div>
          <div className="min-w-0">
            <h1 className="text-xl font-semibold">Profile</h1>
            <p className="truncate text-sm text-muted-foreground">{account.email}</p>
          </div>
          <Button
            variant="outline"
            size="sm"
            className="ml-auto"
            onClick={refreshProfile}
            disabled={refreshing}
          >
            <ArrowsClockwiseIcon size={14} className={refreshing ? "animate-spin" : ""} />
            Refresh
          </Button>
        </div>

        <div className="grid gap-4 md:grid-cols-2">
          <section className="rounded-md border p-3">
            <div className="mb-3 flex items-center gap-2">
              <UserIcon size={16} />
              <p className="text-sm font-medium">Account</p>
            </div>
            <div className="flex flex-col gap-2 text-sm">
              <Row label="Name" value={summary?.name || account.name} />
              <Row label="Email" value={summary?.email || account.email} />
              <Row
                label="Personal Credits"
                value={`${(summary?.personalCredits ?? account.credits).toFixed(2)} cr`}
              />
              <Row label="Pool Credits" value={`${(summary?.poolCredits ?? 0).toFixed(2)} cr`} />
              {summary && <Row label="Updated" value={formatAgo(summary.updatedAt)} />}
            </div>
            <div className="mt-3 flex flex-wrap gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => openUrl("https://exaroton.com/account/")}
              >
                <ArrowSquareOutIcon size={14} />
                Dashboard
              </Button>
              <Button variant="outline" size="sm" onClick={switchAccount}>
                <DoorOpenIcon size={14} />
                Switch
              </Button>
            </div>
          </section>

          <section className="rounded-md border p-3">
            <div className="mb-3 flex items-center gap-2">
              <SlidersIcon size={16} />
              <p className="text-sm font-medium">Display</p>
            </div>
            <div className="flex flex-col gap-2">
              {DISPLAY_OPTIONS.map((option) => {
                const active = option.value === displayMode;
                return (
                  <button
                    key={option.value}
                    type="button"
                    onClick={() => chooseDisplay(option.value)}
                    className={`rounded-md border px-3 py-2 text-left transition-colors ${
                      active
                        ? "border-emerald-500 bg-emerald-50 text-emerald-800"
                        : "hover:bg-muted/60"
                    }`}
                  >
                    <span className="block text-sm font-medium">{option.label}</span>
                    <span className="block text-xs text-muted-foreground">{option.hint}</span>
                  </button>
                );
              })}
            </div>
          </section>

          <section className="rounded-md border p-3">
            <div className="mb-3 flex items-center gap-2">
              <SlidersIcon size={16} />
              <p className="text-sm font-medium">Layout</p>
            </div>
            <div className="flex flex-col gap-2">
              <button
                type="button"
                onClick={() => chooseLayout("sidebar")}
                className={`rounded-md border px-3 py-2 text-left transition-colors ${
                  layoutMode === "sidebar"
                    ? "border-emerald-500 bg-emerald-50 text-emerald-800"
                    : "hover:bg-muted/60"
                }`}
              >
                <span className="block text-sm font-medium">Sidebar</span>
                <span className="block text-xs text-muted-foreground">
                  Classic navigation sidebar on the left.
                </span>
              </button>
              <button
                type="button"
                onClick={() => chooseLayout("topbar")}
                className={`rounded-md border px-3 py-2 text-left transition-colors ${
                  layoutMode === "topbar"
                    ? "border-emerald-500 bg-emerald-50 text-emerald-800"
                    : "hover:bg-muted/60"
                }`}
              >
                <span className="block text-sm font-medium">Top Bar</span>
                <span className="block text-xs text-muted-foreground">
                  Navigation bar at the top. Server pages always use this mode.
                </span>
              </button>
            </div>
          </section>
        </div>

        <section className="rounded-md border p-3">
          <GlobalCreditGraph
            email={account.email}
            history={creditHistory}
            onHistoryChange={setCreditHistory}
          />
        </section>

        <section className="rounded-md border p-3">
          <div className="flex flex-wrap items-center gap-2">
            <ClockCounterClockwiseIcon size={16} />
            <div>
              <p className="text-sm font-medium">Recent Servers</p>
              <p className="text-xs text-muted-foreground">{recentCount} saved for this profile</p>
            </div>
            <Button
              variant="outline"
              size="sm"
              className="ml-auto"
              onClick={clearRecent}
              disabled={recentCount === 0}
            >
              Clear
            </Button>
          </div>
        </section>

        <p className="text-xs text-muted-foreground">ExaTon NEXT {APP_VERSION}</p>
      </div>
    </PageTransition>
  );
}

function Row({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-center justify-between gap-3">
      <span className="text-muted-foreground">{label}</span>
      <span className="min-w-0 truncate text-right font-medium">{value}</span>
    </div>
  );
}
