"use client";
import { ArrowsClockwiseIcon, PlayIcon, StopIcon } from "@phosphor-icons/react";
import { invoke } from "@tauri-apps/api/core";
import { Button } from "@/components/ui/button";
import { ButtonGroup } from "@/components/ui/button-group";

type Props = {
  email: string;
  serverid: string;
  status: number;
};

export function ServerControls({ email, serverid, status }: Props) {
  const call = async (action: string) => {
    try {
      await invoke(action, { email, serverid });
    } catch (err) {
      console.error(`Failed to ${action}:`, err);
    }
  };

  return (
    <ButtonGroup>
      <Button
        onClick={() => call("start_server_action")}
        disabled={status !== 0}
        className="cursor-pointer hover:bg-emerald-700 outline-1 outline-emerald-200 disabled:opacity-60"
      >
        <PlayIcon size={8} /> Start
      </Button>
      <Button
        onClick={() => call("restart_server_action")}
        disabled={status !== 1}
        className="cursor-pointer hover:bg-emerald-700 outline-1 outline-emerald-200 disabled:opacity-60"
      >
        <ArrowsClockwiseIcon size={8} /> Restart
      </Button>
      <Button
        onClick={() => call("stop_server_action")}
        variant="destructive"
        disabled={status !== 1}
        className="cursor-pointer hover:bg-red-700 outline-1 outline-red-200 disabled:opacity-60"
      >
        <StopIcon size={8} /> Stop
      </Button>
    </ButtonGroup>
  );
}
