"use client";

import {
  ArrowDownIcon,
  ArrowsClockwiseIcon,
  ClipboardTextIcon,
  DownloadSimpleIcon,
  FunnelIcon,
  ShareNetworkIcon,
  WarningIcon,
  XCircleIcon,
} from "@phosphor-icons/react";
import { openUrl } from "@tauri-apps/plugin-opener";
import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Skeleton } from "@/components/ui/skeleton";
import { getServerLog, shareServerLog } from "@/lib/server-details";

type Props = {
  email: string;
  serverid: string;
};

type LogLevel = "ERROR" | "WARN" | "INFO" | "DEBUG" | "OTHER";

function detectLevel(line: string): LogLevel {
  const u = line.toUpperCase();
  if (u.includes("[ERROR]") || u.includes(" ERROR ") || u.includes("SEVERE")) return "ERROR";
  if (u.includes("[WARN]") || u.includes(" WARN ") || u.includes("WARNING")) return "WARN";
  if (u.includes("[INFO]") || u.includes(" INFO ")) return "INFO";
  if (u.includes("[DEBUG]") || u.includes(" DEBUG ")) return "DEBUG";
  return "OTHER";
}

const LEVEL_STYLE: Record<LogLevel, string> = {
  ERROR: "text-red-400",
  WARN: "text-yellow-400",
  INFO: "text-green-300",
  DEBUG: "text-zinc-500",
  OTHER: "text-zinc-300",
};

const LEVEL_OPTIONS: Array<{ value: LogLevel | "ALL"; label: string }> = [
  { value: "ALL", label: "All" },
  { value: "ERROR", label: "Error" },
  { value: "WARN", label: "Warn" },
  { value: "INFO", label: "Info" },
  { value: "DEBUG", label: "Debug" },
];

export function ServerLogsPanel({ email, serverid }: Props) {
  const [content, setContent] = useState("");
  const [loading, setLoading] = useState(true);
  const [sharing, setSharing] = useState(false);
  const [copied, setCopied] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const [levelFilter, setLevelFilter] = useState<LogLevel | "ALL">("ALL");
  const [showLineNumbers, setShowLineNumbers] = useState(true);
  const preRef = useRef<HTMLDivElement>(null);
  const [atBottom, setAtBottom] = useState(true);

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

  // Auto-scroll to bottom when content loads
  useEffect(() => {
    if (!loading && preRef.current && atBottom) {
      preRef.current.scrollTop = preRef.current.scrollHeight;
    }
  }, [loading, atBottom]);

  const lines = useMemo(() => content.split("\n"), [content]);

  const filteredLines = useMemo(() => {
    return lines
      .map((line, idx) => ({ line, idx, level: detectLevel(line) }))
      .filter(({ line, level }) => {
        if (levelFilter !== "ALL" && level !== levelFilter) return false;
        if (search && !line.toLowerCase().includes(search.toLowerCase())) return false;
        return true;
      });
  }, [lines, search, levelFilter]);

  // Level counts
  const levelCounts = useMemo(() => {
    const counts: Record<string, number> = { ERROR: 0, WARN: 0, INFO: 0, DEBUG: 0 };
    for (const { level } of lines.map((l) => ({ level: detectLevel(l) }))) {
      if (level in counts) counts[level]++;
    }
    return counts;
  }, [lines]);

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
    try {
      await navigator.clipboard.writeText(content);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      // Clipboard API may fail (permission denied, etc.)
    }
  };

  const handleDownload = () => {
    if (!content) return;
    const blob = new Blob([content], { type: "text/plain" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `server-${serverid}-log.txt`;
    a.click();
    URL.revokeObjectURL(url);
  };

  const scrollToBottom = () => {
    if (preRef.current) {
      preRef.current.scrollTop = preRef.current.scrollHeight;
      setAtBottom(true);
    }
  };

  const handleScroll = () => {
    const el = preRef.current;
    if (!el) return;
    setAtBottom(el.scrollTop + el.clientHeight >= el.scrollHeight - 20);
  };

  return (
    <div className="flex flex-col gap-3">
      {/* Header */}
      <div className="flex flex-wrap items-center gap-2">
        <div>
          <p className="text-sm font-medium">Server Log</p>
          <p className="text-xs text-muted-foreground">
            {content
              ? `${lines.length.toLocaleString()} lines · ${filteredLines.length.toLocaleString()} shown`
              : "Latest log snapshot"}
          </p>
        </div>
        <div className="ml-auto flex flex-wrap items-center gap-1.5">
          <Button variant="outline" size="sm" onClick={handleCopy} disabled={!content}>
            <ClipboardTextIcon size={14} />
            {copied ? "Copied!" : "Copy"}
          </Button>
          <Button variant="outline" size="sm" onClick={handleDownload} disabled={!content}>
            <DownloadSimpleIcon size={14} />
            Download
          </Button>
          <Button variant="outline" size="sm" onClick={handleShare} disabled={sharing}>
            <ShareNetworkIcon size={14} />
            {sharing ? "Sharing…" : "Share"}
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
        <>
          {/* Filters row */}
          <div className="flex flex-wrap items-center gap-2">
            {/* Search */}
            <div className="relative flex-1 min-w-40">
              <FunnelIcon
                size={13}
                className="absolute left-2.5 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none"
              />
              <Input
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Filter lines…"
                className="pl-7 h-8 text-xs font-mono"
              />
            </div>
            {/* Level filter pills */}
            <div className="flex items-center gap-1">
              {LEVEL_OPTIONS.map(({ value, label }) => (
                <button
                  key={value}
                  type="button"
                  onClick={() => setLevelFilter(value)}
                  className={`rounded-full px-2.5 py-0.5 text-[11px] font-medium transition-colors ${
                    levelFilter === value
                      ? "bg-emerald-600 text-white"
                      : "bg-muted text-muted-foreground hover:bg-muted/80"
                  }`}
                >
                  {label}
                  {value !== "ALL" && levelCounts[value] > 0 && (
                    <span className="ml-1 opacity-70">{levelCounts[value]}</span>
                  )}
                </button>
              ))}
            </div>
            {/* Line numbers toggle */}
            <button
              type="button"
              onClick={() => setShowLineNumbers((v) => !v)}
              className={`rounded px-2 py-1 text-[11px] font-mono transition-colors ${
                showLineNumbers ? "bg-zinc-700 text-zinc-200" : "bg-muted text-muted-foreground"
              }`}
            >
              #
            </button>
          </div>

          {/* Level stats row */}
          {content && (
            <div className="flex flex-wrap gap-3 text-[11px]">
              {levelCounts.ERROR > 0 && (
                <span className="flex items-center gap-1 text-red-500">
                  <XCircleIcon size={11} />
                  {levelCounts.ERROR} error{levelCounts.ERROR !== 1 ? "s" : ""}
                </span>
              )}
              {levelCounts.WARN > 0 && (
                <span className="flex items-center gap-1 text-yellow-500">
                  <WarningIcon size={11} />
                  {levelCounts.WARN} warning{levelCounts.WARN !== 1 ? "s" : ""}
                </span>
              )}
              {levelCounts.ERROR === 0 && levelCounts.WARN === 0 && (
                <span className="text-emerald-600">✓ No errors or warnings</span>
              )}
            </div>
          )}

          {/* Log viewer */}
          <div className="relative">
            <div
              ref={preRef}
              onScroll={handleScroll}
              className="h-[60vh] overflow-auto rounded-md border bg-zinc-950 p-3 font-mono text-xs leading-relaxed"
            >
              {filteredLines.length === 0 ? (
                <p className="text-zinc-500 italic">No lines match the current filter.</p>
              ) : (
                filteredLines.map(({ line, idx, level }) => (
                  <div key={idx} className="flex gap-2 hover:bg-white/5 rounded-sm px-1 -mx-1">
                    {showLineNumbers && (
                      <span className="select-none w-10 shrink-0 text-right text-zinc-600">
                        {idx + 1}
                      </span>
                    )}
                    <span className={`whitespace-pre-wrap break-all ${LEVEL_STYLE[level]}`}>
                      {line || " "}
                    </span>
                  </div>
                ))
              )}
            </div>
            {!atBottom && (
              <button
                type="button"
                onClick={scrollToBottom}
                className="absolute bottom-3 right-3 flex items-center gap-1 rounded-full bg-zinc-800 px-2.5 py-1.5 text-[11px] text-zinc-200 shadow-lg hover:bg-zinc-700 transition-colors"
              >
                <ArrowDownIcon size={11} />
                Bottom
              </button>
            )}
          </div>
        </>
      )}
    </div>
  );
}
