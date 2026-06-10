"use client";

import { ArrowsClockwiseIcon, ClipboardTextIcon, ShareNetworkIcon } from "@phosphor-icons/react";
import { openUrl } from "@tauri-apps/plugin-opener";
import { useCallback, useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { getServerLog, shareServerLog } from "@/lib/server-details";

type Props = {
  email: string;
  serverid: string;
};

export function ServerLogsPanel({ email, serverid }: Props) {
  const [content, setContent] = useState("");
  const [loading, setLoading] = useState(true);
  const [sharing, setSharing] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const refresh = useCallback(async () => {
    setLoading(true);
    setError(null);
    setMessage(null);
    try {
      const data = await getServerLog({ email, serverid });
      setContent(data?.content ?? "");
    } catch (err) {
      setError(String(err));
    } finally {
      setLoading(false);
    }
  }, [email, serverid]);

  useEffect(() => {
    refresh();
  }, [refresh]);

  const handleShare = async () => {
    setSharing(true);
    setError(null);
    setMessage(null);
    try {
      const data = await shareServerLog({ email, serverid });
      if (data?.url) {
        await openUrl(data.url);
        setMessage(data.url);
      } else {
        setMessage("The API did not return a share URL.");
      }
    } catch (err) {
      setError(String(err));
    } finally {
      setSharing(false);
    }
  };

  const handleCopy = async () => {
    if (!content || !navigator.clipboard) return;
    await navigator.clipboard.writeText(content);
    setMessage("Copied log content.");
  };

  return (
    <div className="flex flex-col gap-3">
      <div className="flex flex-wrap items-center gap-2">
        <div>
          <p className="text-sm font-medium">Server Log</p>
          <p className="text-xs text-muted-foreground">
            {content ? `${content.split("\n").length} lines loaded` : "Latest log snapshot"}
          </p>
        </div>
        <div className="ml-auto flex items-center gap-2">
          <Button variant="outline" size="sm" onClick={handleCopy} disabled={!content}>
            <ClipboardTextIcon size={14} />
            Copy
          </Button>
          <Button variant="outline" size="sm" onClick={handleShare} disabled={sharing}>
            <ShareNetworkIcon size={14} />
            Share
          </Button>
          <Button variant="outline" size="sm" onClick={refresh} disabled={loading}>
            <ArrowsClockwiseIcon size={14} className={loading ? "animate-spin" : ""} />
            Refresh
          </Button>
        </div>
      </div>

      {error && <p className="text-sm text-red-600">{error}</p>}
      {message && <p className="break-words text-sm text-emerald-700">{message}</p>}

      {loading ? (
        <div className="flex flex-col gap-2">
          <Skeleton className="h-10 rounded-md" />
          <Skeleton className="h-72 rounded-md" />
        </div>
      ) : (
        <pre className="h-[62vh] overflow-auto rounded-md border bg-black p-3 font-mono text-xs leading-relaxed text-green-100">
          {content || "No log content returned."}
        </pre>
      )}
    </div>
  );
}
