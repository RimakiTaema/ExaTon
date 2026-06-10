"use client";
import { ArrowsClockwiseIcon, PlayIcon, StopIcon } from "@phosphor-icons/react";
import { invoke } from "@tauri-apps/api/core";
import { useState } from "react";
import { Button } from "@/components/ui/button";
import { ButtonGroup } from "@/components/ui/button-group";
import { recordDebugEvent } from "@/lib/debug-log";

type Props = {
  email: string;
  serverid: string;
  status: number;
};

export function ServerControls({ email, serverid, status }: Props) {
  const [busyAction, setBusyAction] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

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

  return (
    <div className="flex flex-col gap-2">
      <ButtonGroup>
        <Button
          onClick={() => call("start_server_action")}
          disabled={status !== 0 || busyAction !== null}
          className="cursor-pointer hover:bg-emerald-700 outline-1 outline-emerald-200 disabled:opacity-60"
        >
          <PlayIcon size={8} /> Start
        </Button>
        <Button
          onClick={() => call("restart_server_action")}
          disabled={status !== 1 || busyAction !== null}
          className="cursor-pointer hover:bg-emerald-700 outline-1 outline-emerald-200 disabled:opacity-60"
        >
          <ArrowsClockwiseIcon
            size={8}
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
          <StopIcon size={8} /> Stop
        </Button>
      </ButtonGroup>
      {message && <p className="text-xs text-emerald-700">{message}</p>}
      {error && <p className="text-xs text-red-600">{error}</p>}
    </div>
  );
}
