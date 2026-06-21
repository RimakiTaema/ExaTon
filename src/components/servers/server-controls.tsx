"use client";
import {
  ArrowsClockwiseIcon,
  CoinsIcon,
  PlayIcon,
  StopIcon,
  UserIcon,
} from "@phosphor-icons/react";
import { invoke } from "@tauri-apps/api/core";
import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { ButtonGroup } from "@/components/ui/button-group";
import { type CachedAccountSummary, loadCachedSummary } from "@/lib/account-summary";
import { recordDebugEvent } from "@/lib/debug-log";

type Props = {
  email: string;
  serverid: string;
  status: number;
  shared?: boolean;
};

export function ServerControls({ email, serverid, status, shared }: Props) {
  const [busyAction, setBusyAction] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [showPaymentPrompt, setShowPaymentPrompt] = useState<boolean>(false);
  const [creditSummary, setCreditSummary] = useState<CachedAccountSummary | null>(null);

  useEffect(() => {
    if (showPaymentPrompt) {
      setCreditSummary(loadCachedSummary(email));
    }
  }, [showPaymentPrompt, email]);

  const call = async (action: string) => {
    setBusyAction(action);
    setMessage(null);
    setError(null);
    recordDebugEvent({ scope: "actions", message: `${action} requested`, detail: { serverid } });
    try {
      await invoke(action, { email, serverid });
      setMessage("Action sent.");
      recordDebugEvent({ scope: "actions", message: `${action} succeeded`, detail: { serverid } });
    } catch (err) {
      setError(String(err));
      recordDebugEvent({
        level: "error",
        scope: "actions",
        message: `${action} failed`,
        detail: err,
      });
    } finally {
      setBusyAction(null);
    }
  };

  const startServer = async (useOwnCredits: boolean) => {
    setBusyAction("start_server_action");
    setMessage(null);
    setError(null);
    recordDebugEvent({
      scope: "actions",
      message: `start_server_action requested (useOwnCredits: ${useOwnCredits})`,
      detail: { serverid },
    });
    try {
      await invoke("start_server_action", {
        email,
        serverid,
        useOwnCredits,
      });
      setMessage("Action sent.");
      recordDebugEvent({
        scope: "actions",
        message: `start_server_action succeeded`,
        detail: { serverid },
      });
    } catch (err) {
      setError(String(err));
      recordDebugEvent({
        level: "error",
        scope: "actions",
        message: `start_server_action failed`,
        detail: err,
      });
    } finally {
      setBusyAction(null);
    }
  };

  return (
    <div className="flex flex-col gap-2">
      <div className="flex flex-col gap-2">
        <ButtonGroup>
          <Button
            onClick={() => setShowPaymentPrompt(true)}
            disabled={status !== 0 || busyAction !== null}
            className="cursor-pointer hover:bg-emerald-700 outline-1 outline-emerald-200 disabled:opacity-60"
          >
            <PlayIcon size={14} /> Start
          </Button>
          <Button
            onClick={() => call("restart_server_action")}
            disabled={status !== 1 || busyAction !== null}
            className="cursor-pointer hover:bg-emerald-700 outline-1 outline-emerald-200 disabled:opacity-60"
          >
            <ArrowsClockwiseIcon
              size={14}
              className={busyAction === "restart_server_action" ? "animate-spin" : ""}
            />{" "}
            Restart
          </Button>
          <Button
            onClick={() => call("stop_server_action")}
            variant="destructive"
            disabled={status !== 1 || busyAction !== null}
            className="cursor-pointer hover:bg-red-700 outline-1 outline-red-200 disabled:opacity-60"
          >
            <StopIcon size={14} /> Stop
          </Button>
        </ButtonGroup>
      </div>
      {message && <p className="text-xs text-emerald-700">{message}</p>}
      {error && (
        <div className="flex items-center gap-2">
          <p className="text-xs text-red-600">{error}</p>
          <Button variant="outline" size="sm" onClick={() => setError(null)}>
            Dismiss
          </Button>
        </div>
      )}

      {showPaymentPrompt && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-xs flex items-center justify-center z-50 animate-in fade-in duration-200">
          <div className="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-xl p-6 shadow-2xl max-w-sm w-full mx-4 flex flex-col gap-4 animate-in zoom-in-95 duration-200">
            <div>
              <h3 className="text-base font-semibold text-zinc-900 dark:text-zinc-50">
                Select Credit Payment Method
              </h3>
              <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-1">
                Choose the credit source to cover the cost of starting this server.
              </p>
            </div>
            {/* Credit balances */}
            <div className="rounded-lg bg-emerald-50 dark:bg-emerald-950/40 px-3 py-2">
              <div className="flex items-center gap-2 text-xs font-medium text-emerald-700 dark:text-emerald-400 mb-1">
                <CoinsIcon size={14} />
                Available Credits
              </div>
              <div className="flex items-center justify-between text-sm">
                <span className="flex items-center gap-1.5 text-muted-foreground">
                  <UserIcon size={13} />
                  Personal
                </span>
                <span className="font-semibold">
                  {(creditSummary?.personalCredits ?? 0).toFixed(2)} cr
                </span>
              </div>
              <div className="flex items-center justify-between text-sm">
                <span className="flex items-center gap-1.5 text-muted-foreground">
                  <CoinsIcon size={13} />
                  Pool
                </span>
                <span className="font-semibold">
                  {(creditSummary?.poolCredits ?? 0).toFixed(2)} cr
                </span>
              </div>
            </div>
            <div className="flex flex-col gap-2">
              <Button
                onClick={() => {
                  setShowPaymentPrompt(false);
                  startServer(false);
                }}
                className="w-full justify-center text-sm font-medium border border-zinc-300 dark:border-zinc-700 text-zinc-700 dark:text-zinc-300 bg-transparent hover:bg-zinc-50 dark:hover:bg-zinc-800"
                variant="outline"
              >
                Use Server Credits
              </Button>
              <Button
                onClick={() => {
                  setShowPaymentPrompt(false);
                  startServer(true);
                }}
                disabled={!shared}
                className="w-full justify-center text-sm font-medium bg-emerald-600 hover:bg-emerald-700 text-white disabled:opacity-50 disabled:pointer-events-none"
              >
                Use Own Credits
              </Button>
              {!shared && (
                <p className="text-[10px] text-center text-red-500 dark:text-red-400">
                  Own credits can only be used on shared servers.
                </p>
              )}
            </div>
            <div className="flex justify-end border-t border-zinc-100 dark:border-zinc-800 pt-3">
              <Button
                onClick={() => setShowPaymentPrompt(false)}
                variant="ghost"
                className="text-xs text-zinc-500 hover:text-zinc-700 dark:hover:text-zinc-300"
              >
                Cancel
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
