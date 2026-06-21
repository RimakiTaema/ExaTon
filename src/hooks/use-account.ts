"use client";

import { openUrl } from "@tauri-apps/plugin-opener";
import { useRouter } from "next/navigation";
import { useCallback, useEffect, useState } from "react";
import {
  type CachedAccountSummary,
  loadCachedSummary,
  refreshAccountSummary,
  saveCachedSummary,
} from "@/lib/account-summary";
import { type CreditDisplay, loadCreditDisplay } from "@/lib/display-prefs";

type Account = {
  name: string;
  email: string;
  credits: number;
};

export function useAccount() {
  const router = useRouter();
  const [account, setAccount] = useState<Account | null>(null);
  const [summary, setSummary] = useState<CachedAccountSummary | null>(null);
  const [displayMode, setDisplayMode] = useState<CreditDisplay>("both");
  const [refreshing, setRefreshing] = useState(false);

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
          .catch(() => {});
      }
    } catch {}
  }, []);

  useEffect(() => {
    const syncDisplay = () => setDisplayMode(loadCreditDisplay());
    syncDisplay();
    window.addEventListener("focus", syncDisplay);
    return () => window.removeEventListener("focus", syncDisplay);
  }, []);

  const handleRefresh = useCallback(
    async (e: React.MouseEvent) => {
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
        setRefreshing(false);
        throw new Error("Failed to refresh account");
      }
      setRefreshing(false);
    },
    [account, refreshing],
  );

  const handleDashboard = useCallback((e: React.MouseEvent) => {
    e.stopPropagation();
    openUrl("https://exaroton.com/account/");
  }, []);

  const handleProfile = useCallback(
    (e: React.MouseEvent) => {
      e.stopPropagation();
      router.push("/home/settings");
    },
    [router],
  );

  const handleGoBack = useCallback(
    (e: React.MouseEvent) => {
      e.stopPropagation();
      router.push("/");
    },
    [router],
  );

  return {
    account,
    summary,
    displayMode,
    refreshing,
    handleRefresh,
    handleDashboard,
    handleProfile,
    handleGoBack,
  };
}
