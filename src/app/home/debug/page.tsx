"use client";

import {
  ArrowsClockwiseIcon,
  BugIcon,
  ClipboardTextIcon,
  DoorOpenIcon,
  PlugsConnectedIcon,
  TrashIcon,
} from "@phosphor-icons/react";
import { useRouter } from "next/navigation";
import { useCallback, useEffect, useMemo, useState } from "react";
import { PageTransition } from "@/components/page-transition";
import { Button } from "@/components/ui/button";
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

export default function DebugPage() {
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [selectedEmail, setSelectedEmail] = useState<string | null>(null);
  const [events, setEvents] = useState<DebugEvent[]>([]);
  const [recent, setRecent] = useState<RecentServer[]>([]);
  const [probeState, setProbeState] = useState("Idle");
  const [copyState, setCopyState] = useState("");
  const router = useRouter();

  const selectedAccount = useMemo(
    () => accounts.find((account) => account.email === selectedEmail) ?? null,
    [accounts, selectedEmail],
  );

  const reloadState = useCallback(() => {
    try {
      const nextSelected = localStorage.getItem("exaton_selected_account");
      const nextAccounts: Account[] = JSON.parse(localStorage.getItem("exaton_accounts") ?? "[]");
      setSelectedEmail(nextSelected);
      setAccounts(nextAccounts);
      setRecent(loadRecentServers(nextSelected));
      setEvents(loadDebugEvents());
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

  return (
    <PageTransition>
      <div className="flex max-w-5xl flex-col gap-4 px-2 py-2">
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

        <div className="flex flex-wrap gap-2">
          <Button variant="outline" onClick={() => window.location.reload()}>
            <ArrowsClockwiseIcon size={14} />
            Reload
          </Button>
          <Button variant="outline" onClick={() => router.push("/")}>
            <DoorOpenIcon size={14} />
            Main Menu
          </Button>
          <Button variant="outline" onClick={() => runProbe(false)}>
            <PlugsConnectedIcon size={14} />
            Probe API
          </Button>
          <Button
            variant="outline"
            onClick={() => runProbe(true)}
            disabled={!selectedAccount || recent.length === 0}
          >
            <PlugsConnectedIcon size={14} />
            Probe Auth
          </Button>
          <Button variant="outline" onClick={copyReport}>
            <ClipboardTextIcon size={14} />
            Copy
          </Button>
          <Button variant="destructive" onClick={clearEvents}>
            <TrashIcon size={14} />
            Clear Events
          </Button>
        </div>

        <div className="grid gap-4 md:grid-cols-2">
          <section className="rounded-md border p-3">
            <p className="mb-3 text-sm font-medium">State</p>
            <div className="flex flex-col gap-2 text-sm">
              <Row label="Selected" value={selectedAccount?.email ?? "None"} />
              <Row label="Accounts" value={String(accounts.length)} />
              <Row label="Recent Servers" value={String(recent.length)} />
              <Row label="Probe" value={probeState} />
            </div>
            <Button
              variant="outline"
              size="sm"
              className="mt-3"
              onClick={clearRecent}
              disabled={recent.length === 0}
            >
              Clear Recent Servers
            </Button>
          </section>

          <section className="rounded-md border p-3">
            <p className="mb-3 text-sm font-medium">Recent Servers</p>
            {recent.length === 0 ? (
              <p className="text-sm text-muted-foreground">No recent server visits saved.</p>
            ) : (
              <div className="flex flex-col gap-2">
                {recent.slice(0, 6).map((server) => (
                  <div key={`${server.accountEmail}:${server.id}`} className="text-sm">
                    <p className="truncate font-medium">{server.name}</p>
                    <p className="truncate text-xs text-muted-foreground">
                      {server.address || server.id}
                    </p>
                  </div>
                ))}
              </div>
            )}
          </section>
        </div>

        {copyState && <p className="text-sm text-emerald-700">{copyState}</p>}

        <section className="rounded-md border">
          <div className="flex items-center justify-between border-b px-3 py-2">
            <p className="text-sm font-medium">Event Log</p>
            <p className="text-xs text-muted-foreground">{events.length} events</p>
          </div>
          {events.length === 0 ? (
            <p className="px-3 py-2 text-sm text-muted-foreground">No debug events yet.</p>
          ) : (
            <div className="max-h-[48vh] overflow-auto">
              {events.map((event) => (
                <div key={event.id} className="border-b px-3 py-2 last:border-b-0">
                  <div className="flex flex-wrap items-center gap-2 text-xs text-muted-foreground">
                    <span>{new Date(event.ts).toLocaleTimeString()}</span>
                    <span className={levelClass(event.level)}>{event.level}</span>
                    <span>{event.scope}</span>
                  </div>
                  <p className="mt-1 text-sm">{event.message}</p>
                  {event.detail && (
                    <pre className="mt-1 max-h-20 overflow-auto whitespace-pre-wrap break-words rounded-md bg-muted p-2 text-xs">
                      {event.detail}
                    </pre>
                  )}
                </div>
              ))}
            </div>
          )}
        </section>
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

function levelClass(level: DebugEvent["level"]) {
  if (level === "error") return "rounded bg-red-50 px-1.5 py-0.5 text-red-600";
  if (level === "warn") return "rounded bg-yellow-50 px-1.5 py-0.5 text-yellow-700";
  return "rounded bg-emerald-50 px-1.5 py-0.5 text-emerald-700";
}
