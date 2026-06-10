"use client";

import { ArrowsClockwiseIcon, FloppyDiskIcon, MemoryIcon } from "@phosphor-icons/react";
import { useCallback, useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Skeleton } from "@/components/ui/skeleton";
import {
  getServerMotd,
  getServerRam,
  updateServerMotd,
  updateServerRam,
} from "@/lib/server-details";

type Props = {
  email: string;
  serverid: string;
  fallbackMotd?: string;
};

export function ServerOptionsPanel({ email, serverid, fallbackMotd = "" }: Props) {
  const [motd, setMotd] = useState(fallbackMotd);
  const [savedMotd, setSavedMotd] = useState(fallbackMotd);
  const [ram, setRam] = useState<number>(1);
  const [savedRam, setSavedRam] = useState<number>(1);
  const [loading, setLoading] = useState(true);
  const [savingMotd, setSavingMotd] = useState(false);
  const [savingRam, setSavingRam] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);

  const refresh = useCallback(async () => {
    setLoading(true);
    setError(null);
    setMessage(null);
    const [motdResult, ramResult] = await Promise.allSettled([
      getServerMotd({ email, serverid }),
      getServerRam({ email, serverid }),
    ]);

    if (motdResult.status === "fulfilled") {
      const nextMotd = motdResult.value?.motd ?? fallbackMotd;
      setMotd(nextMotd);
      setSavedMotd(nextMotd);
    } else {
      setError(String(motdResult.reason));
    }

    if (ramResult.status === "fulfilled") {
      const nextRam = ramResult.value?.ram ?? 1;
      setRam(nextRam);
      setSavedRam(nextRam);
    } else {
      setError((current) => current ?? String(ramResult.reason));
    }

    setLoading(false);
  }, [email, fallbackMotd, serverid]);

  useEffect(() => {
    refresh();
  }, [refresh]);

  const handleSaveMotd = async () => {
    setSavingMotd(true);
    setError(null);
    setMessage(null);
    try {
      const updated = await updateServerMotd({ email, serverid, motd });
      const nextMotd = updated?.motd ?? motd;
      setMotd(nextMotd);
      setSavedMotd(nextMotd);
      setMessage("MOTD saved.");
    } catch (err) {
      setError(String(err));
    } finally {
      setSavingMotd(false);
    }
  };

  const handleSaveRam = async () => {
    const nextRam = Math.max(1, Math.round(ram || 1));
    setSavingRam(true);
    setError(null);
    setMessage(null);
    try {
      const updated = await updateServerRam({ email, serverid, ram: nextRam });
      const saved = updated?.ram ?? nextRam;
      setRam(saved);
      setSavedRam(saved);
      setMessage("RAM saved.");
    } catch (err) {
      setError(String(err));
    } finally {
      setSavingRam(false);
    }
  };

  if (loading) {
    return (
      <div className="flex flex-col gap-3">
        <Skeleton className="h-32 rounded-md" />
        <Skeleton className="h-24 rounded-md" />
      </div>
    );
  }

  return (
    <div className="flex max-w-3xl flex-col gap-4">
      <div className="flex items-center gap-2">
        <div>
          <p className="text-sm font-medium">Server Options</p>
          <p className="text-xs text-muted-foreground">Editable values from the exaroton API.</p>
        </div>
        <Button variant="outline" size="sm" className="ml-auto" onClick={refresh}>
          <ArrowsClockwiseIcon size={14} />
          Refresh
        </Button>
      </div>

      {error && <p className="text-sm text-red-600">{error}</p>}
      {message && <p className="text-sm text-emerald-700">{message}</p>}

      <div className="rounded-md border p-3">
        <div className="mb-2 flex items-center justify-between gap-2">
          <div>
            <p className="text-sm font-medium">MOTD</p>
            <p className="text-xs text-muted-foreground">Message shown in the server list.</p>
          </div>
          <Button size="sm" onClick={handleSaveMotd} disabled={savingMotd || motd === savedMotd}>
            <FloppyDiskIcon size={14} />
            Save
          </Button>
        </div>
        <textarea
          value={motd}
          onChange={(event) => setMotd(event.target.value)}
          className="h-24 w-full resize-none rounded-md border bg-background p-2 text-sm outline-none focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50"
          spellCheck={false}
        />
      </div>

      <div className="rounded-md border p-3">
        <div className="mb-2 flex items-center justify-between gap-2">
          <div>
            <p className="flex items-center gap-2 text-sm font-medium">
              <MemoryIcon size={16} />
              RAM
            </p>
            <p className="text-xs text-muted-foreground">Allocated server memory in GB.</p>
          </div>
          <Button size="sm" onClick={handleSaveRam} disabled={savingRam || ram === savedRam}>
            <FloppyDiskIcon size={14} />
            Save
          </Button>
        </div>
        <div className="flex max-w-xs items-center gap-2">
          <Input
            type="number"
            min={1}
            step={1}
            value={Number.isFinite(ram) ? ram : 1}
            onChange={(event) => setRam(Number(event.target.value))}
          />
          <span className="text-sm text-muted-foreground">GB</span>
        </div>
      </div>
    </div>
  );
}
