"use client";

import {
  ArrowsClockwiseIcon,
  BugIcon,
  ClipboardTextIcon,
  DoorOpenIcon,
  PlugsConnectedIcon,
  TrashIcon,
  WarningCircleIcon,
} from "@phosphor-icons/react";
import { useRouter } from "next/navigation";
import { useCallback, useEffect, useMemo, useState } from "react";
import { PageTransition } from "@/components/page-transition";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useErrorReporter } from "@/components/error-handler";
import { probeApi } from "@/lib/api-probe";
import { APP_VERSION } from "@/lib/app-info";
import {
  clearDebugEvents,
  type DebugEvent,
  loadDebugEvents,
  recordDebugEvent,
  subscribeDebugEvents,
} from "@/lib/debug-log";
import { clearRecentServers, loadRecentServers, type RecentServer } from "@/lib/recent-servers";

type Account = {
  name: string;
  email: string;
  credits: number;
};

type LevelFilter = "all" | "error" | "warn" | "info";

const LEVEL_FILTERS: LevelFilter[] = ["all", "error", "warn", "info"];

export default function DebugPage() {
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [selectedEmail, setSelectedEmail] = useState<string | null>(null);
  const [events, setEvents] = useState<DebugEvent[]>([]);
  const [recent, setRecent] = useState<RecentServer[]>([]);
  const [probeState, setProbeState] = useState("Idle");
  const [copyState, setCopyState] = useState("");
  const [levelFilter, setLevelFilter] = useState<LevelFilter>("all");
  const router = useRouter();
  const { reportError } = useErrorReporter();

  const selectedAccount = useMemo(
    () => accounts.find((account) => account.email === selectedEmail) ?? null,
    [accounts, selectedEmail],
  );

  const filteredEvents = useMemo(
    () => (levelFilter === "all" ? events : events.filter((e) => e.level === levelFilter)),
    [events, levelFilter],
  );

  const reloadState = useCallback(() => {
    try {
      const nextSelected = localStorage.getItem("exaton_selected_account");
      const nextAccounts: Account[] = JSON.parse(localStorage.getItem("exaton_accounts") ?? "[]");
      setSelectedEmail(nextSelected);
      setAccounts(nextAccounts);
      setRecent(loadRecentServers(nextSelected));
      setEvents(loadDebugEvents());
      setCopyState("");
    } catch (error) {
      recordDebugEvent({
        level: "error",
        scope: "debug",
        message: "Debug state load failed",
        detail: error,
      });
    }
  }, []);

  useEffect(() => {
    reloadState();
    return subscribeDebugEvents(() => setEvents(loadDebugEvents()));
  }, [reloadState]);

  const runProbe = async (authenticated: boolean) => {
    setProbeState("Checking...");
    setCopyState("");
    const target = recent[0];
    try {
      if (authenticated && selectedAccount && target) {
        await probeApi({ email: selectedAccount.email, serverid: target.id, path: "/" });
      } else {
        await probeApi();
      }
      setProbeState(authenticated ? "Authenticated probe passed" : "Anonymous probe passed");
      recordDebugEvent({
        scope: "debug",
        message: authenticated ? "Authenticated probe passed" : "Anonymous probe passed",
        detail: authenticated ? { serverid: target?.id } : undefined,
      });
    } catch (error) {
      const message = String(error);
      setProbeState(message);
      recordDebugEvent({
        level: "error",
        scope: "debug",
        message: "API probe failed",
        detail: error,
      });
    }
  };

  const clearEvents = () => {
    clearDebugEvents();
    setEvents([]);
  };

  const clearRecent = () => {
    clearRecentServers(selectedEmail);
    setRecent([]);
    recordDebugEvent({ scope: "debug", message: "Recent servers cleared" });
  };

  const copyReport = async () => {
    const report = {
      version: APP_VERSION,
      selectedEmail,
      accountCount: accounts.length,
      recentCount: recent.length,
      probeState,
      events: events.slice(0, 20),
    };
    await navigator.clipboard?.writeText(JSON.stringify(report, null, 2));
    setCopyState("Copied diagnostics.");
  };

  const simulateError = () => {
    reportError("This is a simulated error from the debug page", () => {
      reportError("Retry attempted — error cleared");
    });
    recordDebugEvent({ scope: "debug", message: "Simulated error triggered" });
  };

  const simulateCrash = () => {
    recordDebugEvent({ scope: "debug", message: "Simulated fatal crash triggered" });
    throw new Error("Simulated fatal crash from debug page");
  };

  const toggleDarkMode = () => {
    const html = document.documentElement;
    const isDark = html.classList.contains("dark");
    html.classList.toggle("dark");
    localStorage.setItem("exaton_dark_mode", isDark ? "false" : "true");
    recordDebugEvent({
      scope: "debug",
      message: `Dark mode ${isDark ? "disabled" : "enabled"}`,
    });
  };

  const clearAllData = () => {
    const keys = Object.keys(localStorage).filter((k) => k.startsWith("exaton_"));
    keys.forEach((k) => localStorage.removeItem(k));
    recordDebugEvent({ scope: "debug", message: `Cleared ${keys.length} localStorage keys` });
    reloadState();
  };

  const targetName = recent.length > 0 ? recent[0].name : "—";

  return (
    <PageTransition>
      <div className="flex max-w-6xl flex-col gap-4 px-2 py-2">
        {/* Header */}
        <div className="flex flex-wrap items-center gap-3">
          <div className="flex size-10 items-center justify-center rounded-md bg-red-50 text-red-600">
            <BugIcon size={20} />
          </div>
          <div>
            <h1 className="text-xl font-semibold">Debug Option</h1>
            <p className="text-sm text-muted-foreground">ExaTon NEXT {APP_VERSION}</p>
          </div>
          <Button variant="outline" size="sm" className="ml-auto" onClick={reloadState}>
            <ArrowsClockwiseIcon size={14} />
            Refresh
          </Button>
        </div>

        {/* Action bar */}
        <div className="flex flex-wrap gap-2">
          <Button variant="outline" size="sm" onClick={() => window.location.reload()}>
            <ArrowsClockwiseIcon size={14} />
            Reload App
          </Button>
          <Button variant="outline" size="sm" onClick={() => router.push("/home")}>
            <DoorOpenIcon size={14} />
            Home
          </Button>
          <Button variant="outline" size="sm" onClick={copyReport}>
            <ClipboardTextIcon size={14} />
            Copy Report
          </Button>
        </div>

        {copyState && <p className="text-sm text-emerald-700">{copyState}</p>}

        {/* Category cards */}
        <div className="grid gap-4 md:grid-cols-3">
          {/* API */}
          <Card>
            <CardHeader>
              <CardTitle>API</CardTitle>
            </CardHeader>
            <CardContent className="flex flex-col gap-3">
              <Row label="Status" value={probeState} />
              <Row label="Target" value={targetName} />
              <div className="flex flex-wrap gap-2 mt-1">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => runProbe(false)}
                >
                  <PlugsConnectedIcon size={14} />
                  Probe API
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => runProbe(true)}
                  disabled={!selectedAccount || recent.length === 0}
                >
                  <PlugsConnectedIcon size={14} />
                  Probe Auth
                </Button>
              </div>
            </CardContent>
          </Card>

          {/* Info */}
          <Card>
            <CardHeader>
              <CardTitle>Info</CardTitle>
            </CardHeader>
            <CardContent className="flex flex-col gap-3">
              <Row label="Version" value={APP_VERSION} />
              <Row label="Account" value={selectedAccount?.email ?? "None"} />
              <Row label="Accounts" value={String(accounts.length)} />
              <Row label="Recent" value={String(recent.length)} />
              <Button
                variant="outline"
                size="sm"
                onClick={clearRecent}
                disabled={recent.length === 0}
              >
                <TrashIcon size={14} />
                Clear Recent
              </Button>
            </CardContent>
          </Card>

          {/* Event Log */}
          <Card>
            <CardHeader>
              <CardTitle>
                Event Log
                <span className="ml-1.5 text-xs text-muted-foreground font-normal">
                  {events.length}
                </span>
              </CardTitle>
            </CardHeader>
            <CardContent className="flex flex-col gap-2">
              {/* Level filter tabs */}
              <div className="flex gap-1">
                {LEVEL_FILTERS.map((f) => (
                  <button
                    key={f}
                    type="button"
                    onClick={() => setLevelFilter(f)}
                    className={`rounded px-2 py-0.5 text-xs font-medium transition-colors cursor-pointer ${
                      levelFilter === f
                        ? "bg-foreground/10 text-foreground"
                        : "text-muted-foreground hover:text-foreground hover:bg-foreground/5"
                    }`}
                  >
                    {f}
                  </button>
                ))}
              </div>
              {/* Event list */}
              {filteredEvents.length === 0 ? (
                <p className="py-4 text-center text-sm text-muted-foreground">
                  No {levelFilter === "all" ? "" : `${levelFilter} `}events.
                </p>
              ) : (
                <div className="max-h-60 overflow-auto rounded-md border">
                  {filteredEvents.map((event) => (
                    <div key={event.id} className="border-b px-3 py-2 last:border-b-0">
                      <div className="flex flex-wrap items-center gap-2 text-xs text-muted-foreground">
                        <span>{new Date(event.ts).toLocaleTimeString()}</span>
                        <span className={levelClass(event.level)}>{event.level}</span>
                        <span>{event.scope}</span>
                      </div>
                      <p className="mt-0.5 text-sm">{event.message}</p>
                      {event.detail && (
                        <pre className="mt-1 max-h-16 overflow-auto whitespace-pre-wrap break-words rounded bg-muted p-1.5 text-xs">
                          {event.detail}
                        </pre>
                      )}
                    </div>
                  ))}
                </div>
              )}
              <Button variant="outline" size="sm" onClick={clearEvents}>
                <TrashIcon size={14} />
                Clear Events
              </Button>
            </CardContent>
          </Card>
        </div>

        {/* Developer Tools */}
        <Card>
          <CardHeader>
            <CardTitle>Developer Tools</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex flex-wrap gap-2">
              <Button variant="outline" size="sm" onClick={simulateError}>
                <WarningCircleIcon size={14} />
                Simulate Error
              </Button>
              <Button variant="destructive" size="sm" onClick={simulateCrash}>
                <WarningCircleIcon size={14} />
                Simulate Fatal Crash
              </Button>
              <Button variant="outline" size="sm" onClick={toggleDarkMode}>
                Toggle Dark Mode
              </Button>
              <Button variant="destructive" size="sm" onClick={clearAllData}>
                <TrashIcon size={14} />
                Clear All Local Data
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </PageTransition>
  );
}

function Row({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-center justify-between gap-3">
      <span className="text-muted-foreground text-xs">{label}</span>
      <span className="min-w-0 truncate text-right text-sm font-medium">{value}</span>
    </div>
  );
}

function levelClass(level: DebugEvent["level"]) {
  if (level === "error") return "rounded bg-red-50 px-1.5 py-0.5 text-red-600";
  if (level === "warn") return "rounded bg-yellow-50 px-1.5 py-0.5 text-yellow-700";
  return "rounded bg-emerald-50 px-1.5 py-0.5 text-emerald-700";
}
