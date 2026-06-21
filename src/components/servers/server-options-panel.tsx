"use client";

import { ArrowsClockwiseIcon, CpuIcon, FloppyDiskIcon, MemoryIcon } from "@phosphor-icons/react";
import { useCallback, useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
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

// Minecraft color codes with their hex equivalents
const MC_COLORS = [
  { code: "§0", label: "Black", hex: "#000000" },
  { code: "§1", label: "Dark Blue", hex: "#0000AA" },
  { code: "§2", label: "Dark Green", hex: "#00AA00" },
  { code: "§3", label: "Dark Aqua", hex: "#00AAAA" },
  { code: "§4", label: "Dark Red", hex: "#AA0000" },
  { code: "§5", label: "Dark Purple", hex: "#AA00AA" },
  { code: "§6", label: "Gold", hex: "#FFAA00" },
  { code: "§7", label: "Gray", hex: "#AAAAAA" },
  { code: "§8", label: "Dark Gray", hex: "#555555" },
  { code: "§9", label: "Blue", hex: "#5555FF" },
  { code: "§a", label: "Green", hex: "#55FF55" },
  { code: "§b", label: "Aqua", hex: "#55FFFF" },
  { code: "§c", label: "Red", hex: "#FF5555" },
  { code: "§d", label: "Light Purple", hex: "#FF55FF" },
  { code: "§e", label: "Yellow", hex: "#FFFF55" },
  { code: "§f", label: "White", hex: "#FFFFFF" },
] as const;

const MC_FORMATS = [
  { code: "§k", label: "Obfuscated" },
  { code: "§l", label: "Bold" },
  { code: "§m", label: "Strike" },
  { code: "§n", label: "Underline" },
  { code: "§o", label: "Italic" },
  { code: "§r", label: "Reset" },
] as const;

/** Converts §-coded MOTD string into styled spans for preview */
function MotdPreview({ motd }: { motd: string }) {
  // Build segments by scanning § codes
  const segments: {
    text: string;
    color?: string;
    bold?: boolean;
    italic?: boolean;
    strike?: boolean;
    underline?: boolean;
  }[] = [];
  let i = 0;
  let currentColor: string | undefined;
  let bold = false;
  let italic = false;
  let strike = false;
  let underline = false;

  while (i < motd.length) {
    if (motd[i] === "§" && i + 1 < motd.length) {
      const code = motd[i + 1].toLowerCase();
      const colorEntry = MC_COLORS.find((c) => c.code[1] === code);
      if (colorEntry) {
        currentColor = colorEntry.hex;
        bold = false;
        italic = false;
        strike = false;
        underline = false;
      } else if (code === "l") {
        bold = true;
      } else if (code === "o") {
        italic = true;
      } else if (code === "m") {
        strike = true;
      } else if (code === "n") {
        underline = true;
      } else if (code === "r") {
        currentColor = undefined;
        bold = false;
        italic = false;
        strike = false;
        underline = false;
      }
      i += 2;
    } else {
      // Collect plain text until next §
      let j = i;
      while (j < motd.length && motd[j] !== "§") j++;
      const text = motd.slice(i, j);
      if (text) segments.push({ text, color: currentColor, bold, italic, strike, underline });
      i = j;
    }
  }

  if (segments.length === 0) {
    return <span className="text-muted-foreground italic">Preview will appear here…</span>;
  }

  return (
    <>
      {segments.map((seg, idx) => {
        const decorations = [seg.strike && "line-through", seg.underline && "underline"]
          .filter(Boolean)
          .join(" ");
        return (
          <span
            // biome-ignore lint/suspicious/noArrayIndexKey: static render
            key={idx}
            style={{
              color: seg.color,
              fontWeight: seg.bold ? "bold" : undefined,
              fontStyle: seg.italic ? "italic" : undefined,
              textDecoration: decorations || undefined,
            }}
          >
            {seg.text}
          </span>
        );
      })}
    </>
  );
}

export function ServerOptionsPanel({ email, serverid, fallbackMotd = "" }: Props) {
  const [motd, setMotd] = useState(fallbackMotd);
  const [savedMotd, setSavedMotd] = useState(fallbackMotd);
  const [ram, setRam] = useState<number>(2);
  const [savedRam, setSavedRam] = useState<number>(2);
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
      const nextRam = ramResult.value?.ram ?? 2;
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
    const nextRam = Math.min(16, Math.max(2, Math.round(ram || 2)));
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
        <Skeleton className="h-24 rounded-md" />
        <Skeleton className="h-32 rounded-md" />
      </div>
    );
  }

  const ramPct = ((ram - 2) / (16 - 2)) * 100;
  const cpuCores = ram * 0.5;

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

      {/* ── RAM & CPU ──────────────────────────────────── */}
      <div className="rounded-md border p-3">
        <div className="mb-3 flex items-center justify-between gap-2">
          <div>
            <p className="flex items-center gap-2 text-sm font-medium">
              <MemoryIcon size={16} />
              RAM &amp; CPU
            </p>
            <p className="text-xs text-muted-foreground">Allocated server memory and compute share.</p>
          </div>
          <Button size="sm" onClick={handleSaveRam} disabled={savingRam || ram === savedRam}>
            <FloppyDiskIcon size={14} />
            Save
          </Button>
        </div>

        {/* Slider */}
        <div className="flex flex-col gap-1.5">
          <div className="flex items-center justify-between text-xs text-muted-foreground">
            <span>2 GB</span>
            <span className="font-semibold text-sm text-foreground">| {ram} GB |</span>
            <span>16 GB</span>
          </div>
          <div className="relative h-6 flex items-center">
            {/* Track background */}
            <div className="absolute inset-x-0 h-2 rounded-full bg-muted overflow-hidden">
              <div
                className="h-full rounded-full bg-emerald-500 transition-all duration-100"
                style={{ width: `${ramPct}%` }}
              />
            </div>
            {/* Native range input */}
            <input
              type="range"
              min={2}
              max={16}
              step={1}
              value={ram}
              onChange={(e) => setRam(Number(e.target.value))}
              className="ram-slider relative w-full h-2 appearance-none bg-transparent cursor-pointer"
              aria-label="RAM allocation in GB"
            />
          </div>
          {/* Step ticks */}
          <div className="relative h-4">
            {Array.from({ length: 15 }, (_, i) => i + 2).map((v) => (
              <button
                key={v}
                type="button"
                onClick={() => setRam(v)}
                className={`absolute bottom-0 text-[9px] leading-none transition-colors -translate-x-1/2 ${
                  v === ram
                    ? "text-emerald-600 font-bold"
                    : "text-muted-foreground hover:text-foreground"
                }`}
                style={{ left: `${((v - 2) / 14) * 100}%` }}
              >
                | {v} |
              </button>
            ))}
          </div>
        </div>

        {/* CPU cores derived from RAM */}
        <div className="mt-3 flex items-center gap-2 rounded-md bg-muted/50 px-3 py-2">
          <CpuIcon size={15} className="text-muted-foreground shrink-0" />
          <span className="text-xs text-muted-foreground">
            ~{cpuCores} CPU core{cpuCores === 1 ? "" : "s"} (0.5 per GB)
          </span>
        </div>
      </div>

      {/* ── MOTD ────────────────────────────────────────── */}
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
          className="h-24 w-full resize-none rounded-md border bg-background p-2 text-sm font-mono outline-none focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50"
          spellCheck={false}
          placeholder="e.g. §aA §6Minecraft §cServer"
        />

        {/* Live preview */}
        <div className="mt-2 rounded-md border border-dashed bg-zinc-950 px-3 py-2 min-h-[2rem] text-sm font-minecraft font-mono leading-snug">
          <MotdPreview motd={motd} />
        </div>

        {/* Minecraft color code reference */}
        <div className="mt-3">
          <p className="mb-1.5 text-[11px] font-medium text-muted-foreground uppercase tracking-wide">
            Color Codes
          </p>
          <div className="grid grid-cols-4 gap-1 sm:grid-cols-8">
            {MC_COLORS.map(({ code, label, hex }) => (
              <button
                key={code}
                type="button"
                title={`${label} — click to copy ${code}`}
                onClick={() => {
                  setMotd((prev) => prev + code);
                }}
                className="group flex items-center gap-1 rounded px-1.5 py-1 text-[10px] hover:bg-muted transition-colors cursor-pointer"
              >
                <span
                  className="inline-block h-3 w-3 flex-shrink-0 rounded-sm border border-black/20"
                  style={{ backgroundColor: hex }}
                />
                <span className="truncate text-muted-foreground group-hover:text-foreground font-mono">
                  {code}
                </span>
              </button>
            ))}
          </div>

          <p className="mb-1.5 mt-2 text-[11px] font-medium text-muted-foreground uppercase tracking-wide">
            Formatting Codes
          </p>
          <div className="flex flex-wrap gap-1">
            {MC_FORMATS.map(({ code, label }) => (
              <button
                key={code}
                type="button"
                title={`${label} — click to insert ${code}`}
                onClick={() => setMotd((prev) => prev + code)}
                className="rounded border px-2 py-0.5 text-[10px] font-mono text-muted-foreground hover:bg-muted hover:text-foreground transition-colors cursor-pointer"
              >
                {code} {label}
              </button>
            ))}
          </div>
        </div>
      </div>

      <style>{`
        .ram-slider::-webkit-slider-thumb {
          -webkit-appearance: none;
          appearance: none;
          width: 18px;
          height: 18px;
          border-radius: 50%;
          background: white;
          border: 2px solid #10b981;
          box-shadow: 0 1px 4px rgba(0,0,0,0.25);
          cursor: pointer;
          transition: border-color 0.15s, box-shadow 0.15s;
        }
        .ram-slider::-webkit-slider-thumb:hover {
          border-color: #059669;
          box-shadow: 0 0 0 4px rgba(16,185,129,0.15);
        }
        .ram-slider::-moz-range-thumb {
          width: 18px;
          height: 18px;
          border-radius: 50%;
          background: white;
          border: 2px solid #10b981;
          box-shadow: 0 1px 4px rgba(0,0,0,0.25);
          cursor: pointer;
        }
      `}</style>
    </div>
  );
}
