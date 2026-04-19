"use client";
import { useCallback, useEffect, useRef, useState } from "react";
import { type ProbeArgs, probeApi } from "@/lib/api-probe";

export type ProbeStatus = "checking" | "online" | "offline" | "broken";

export type ProbeState = {
  status: ProbeStatus;
  error: string | null;
  retry: () => void;
};

export function useApiProbe({ email, serverid, path }: ProbeArgs = {}): ProbeState {
  const [status, setStatus] = useState<ProbeStatus>("checking");
  const [error, setError] = useState<string | null>(null);
  const runIdRef = useRef(0);

  const execute = useCallback(() => {
    const runId = ++runIdRef.current;
    setStatus("checking");
    setError(null);
    probeApi({ email, serverid, path })
      .then(() => {
        if (runId !== runIdRef.current) return;
        setStatus("online");
        setError(null);
      })
      .catch((e: unknown) => {
        if (runId !== runIdRef.current) return;
        const msg = typeof e === "string" ? e : e instanceof Error ? e.message : String(e);
        setError(msg);
        setStatus(msg.toLowerCase().includes("offline") ? "offline" : "broken");
      });
  }, [email, serverid, path]);

  useEffect(() => {
    execute();
    return () => {
      runIdRef.current++;
    };
  }, [execute]);

  return { status, error, retry: execute };
}
