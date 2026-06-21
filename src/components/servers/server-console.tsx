"use client";
import {
  ArrowDownIcon,
  ClockClockwiseIcon,
  GearSixIcon,
  PaperPlaneRightIcon,
  ProhibitIcon,
  TerminalIcon,
  TrashIcon,
} from "@phosphor-icons/react";
import { useCallback, useEffect, useRef, useState } from "react";
import { ConsolePresetsManager } from "@/components/servers/console-presets-manager";
import { type CommandPreset, getAllPresets } from "@/lib/console-presets";

type ConsoleLine = { id: number; text: string };

type Props = {
  lines: string[];
  status: number;
  connected: boolean;
  onSend: (command: string) => void;
};

/** Colour-code a Minecraft server console line */
function lineClass(line: string): string {
  const u = line.toUpperCase();
  if (u.includes("[ERROR]") || u.includes("ERROR)") || u.includes("SEVERE")) return "text-red-400";
  if (u.includes("[WARN]") || u.includes("WARN)") || u.includes("WARNING"))
    return "text-yellow-400";
  if (u.includes("[INFO]") || u.includes("INFO)")) return "text-green-300";
  if (u.includes("joined the game") || u.includes("left the game")) return "text-sky-400";
  if (u.includes("[DEBUG]")) return "text-zinc-500";
  return "text-zinc-300";
}

export function ServerConsole({ lines, status, connected, onSend }: Props) {
  const [input, setInput] = useState("");
  const [history, setHistory] = useState<string[]>([]);
  const [histIdx, setHistIdx] = useState(-1);
  const [atBottom, setAtBottom] = useState(true);
  const [presets, setPresets] = useState<CommandPreset[]>([]);
  const [showPresetManager, setShowPresetManager] = useState(false);
  const [pendingPreset, setPendingPreset] = useState<CommandPreset | null>(null);
  const [variableValue, setVariableValue] = useState("");
  const keyCounter = useRef(0);
  const scrollRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  const variableInputRef = useRef<HTMLInputElement>(null);

  // Reload presets on mount and when the storage changes (cross-tab sync)
  const reloadPresets = useCallback(() => setPresets(getAllPresets()), []);
  useEffect(() => {
    reloadPresets();
    const handler = () => reloadPresets();
    window.addEventListener("exaton_console_presets_changed", handler);
    return () => window.removeEventListener("exaton_console_presets_changed", handler);
  }, [reloadPresets]);

  const canInteract = connected && status === 1;

  // Chronologically-ordered merged array: server lines from WS interleaved
  // with local echoes inserted at the moment the user typed the command.
  const [allLines, setAllLines] = useState<ConsoleLine[]>([]);
  const linesLenRef = useRef(0);

  // Track new server lines from the lines prop and append them in order
  useEffect(() => {
    if (lines.length > linesLenRef.current) {
      const newServerLines = lines.slice(linesLenRef.current).map((text) => ({
        id: ++keyCounter.current,
        text,
      }));
      linesLenRef.current = lines.length;
      setAllLines((prev) => [...prev, ...newServerLines]);
    } else if (lines.length < linesLenRef.current) {
      linesLenRef.current = lines.length;
    }
  }, [lines]);

  // biome-ignore lint/correctness/useExhaustiveDependencies: scroll on new lines
  useEffect(() => {
    if (atBottom && scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [allLines, atBottom]);

  const handleScroll = () => {
    const el = scrollRef.current;
    if (!el) return;
    setAtBottom(el.scrollTop + el.clientHeight >= el.scrollHeight - 20);
  };

  const scrollToBottom = () => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
      setAtBottom(true);
    }
  };

  const send = (cmd: string) => {
    const trimmed = cmd.trim();
    if (!trimmed) return;
    onSend(trimmed);
    setAllLines((prev) => [...prev, { id: ++keyCounter.current, text: `> ${trimmed}` }]);
    setHistory((h) => [trimmed, ...h.slice(0, 49)]);
    setHistIdx(-1);
    setInput("");
    setAtBottom(true);
  };

  const sendPreset = (preset: CommandPreset) => {
    const hasVar = preset.command.includes("{player}");
    if (hasVar) {
      setPendingPreset(preset);
      setVariableValue("");
      // Focus prompt input next tick
      setTimeout(() => variableInputRef.current?.focus(), 50);
      return;
    }
    send(preset.command);
  };

  const executePendingPreset = () => {
    if (!pendingPreset) return;
    const cmd = pendingPreset.command.replace(/\{player\}/g, variableValue.trim());
    setPendingPreset(null);
    setVariableValue("");
    send(cmd);
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter") {
      send(input);
      return;
    }
    if (e.key === "ArrowUp") {
      e.preventDefault();
      const next = Math.min(histIdx + 1, history.length - 1);
      setHistIdx(next);
      setInput(history[next] ?? "");
    }
    if (e.key === "ArrowDown") {
      e.preventDefault();
      const next = Math.max(histIdx - 1, -1);
      setHistIdx(next);
      setInput(next === -1 ? "" : (history[next] ?? ""));
    }
  };

  const clearLocal = () => setAllLines((prev) => prev.filter((l) => !l.text.startsWith("> ")));

  return (
    <div className="flex flex-col rounded-xl border border-zinc-700/80 bg-zinc-950 overflow-hidden shadow-xl">
      {/* Status bar */}
      <div className="flex items-center gap-2 border-b border-zinc-800 bg-zinc-900 px-3 py-1.5">
        <TerminalIcon size={13} className="text-zinc-500" />
        <span className="text-[11px] font-mono text-zinc-400">Server Console</span>
        <span
          className={`ml-1 flex items-center gap-1 text-[10px] font-medium ${
            canInteract ? "text-emerald-500" : "text-zinc-600"
          }`}
        >
          <span
            className={`inline-block h-1.5 w-1.5 rounded-full ${
              canInteract ? "bg-emerald-500 animate-pulse" : "bg-zinc-600"
            }`}
          />
          {canInteract ? "Connected" : status === 1 ? "Connecting…" : "Offline"}
        </span>
        <div className="ml-auto flex items-center gap-1">
          <button
            type="button"
            onClick={() => setShowPresetManager(true)}
            title="Manage presets"
            className="rounded p-1 text-zinc-600 hover:text-zinc-300 transition-colors"
          >
            <GearSixIcon size={12} />
          </button>
          <button
            type="button"
            onClick={clearLocal}
            title="Clear local echo"
            className="rounded p-1 text-zinc-600 hover:text-zinc-300 transition-colors"
          >
            <TrashIcon size={12} />
          </button>
        </div>
      </div>

      {/* Output area */}
      <div
        ref={scrollRef}
        onScroll={handleScroll}
        className="relative h-80 overflow-y-auto p-3 font-mono text-xs leading-5 selection:bg-emerald-900/50"
      >
        {allLines.length === 0 ? (
          <span className="text-zinc-600 italic">
            {status === 1
              ? connected
                ? "Waiting for output…"
                : "Connecting…"
              : "Server is offline — start it to enable the console."}
          </span>
        ) : (
          allLines.map((entry) => (
            <div
              key={entry.id}
              className={`hover:bg-white/5 px-1 -mx-1 rounded whitespace-pre-wrap break-all ${lineClass(entry.text)}`}
            >
              {entry.text}
            </div>
          ))
        )}
        <div className="h-px" />
      </div>

      {/* Preset commands */}
      {canInteract && presets.length > 0 && (
        <div className="flex flex-wrap items-center gap-1 border-t border-zinc-800 bg-zinc-900/60 px-3 py-1.5">
          <ClockClockwiseIcon size={11} className="text-zinc-600 mr-0.5" />
          {presets.map((preset) => (
            <button
              key={preset.id}
              type="button"
              onClick={() => sendPreset(preset)}
              className="rounded border border-zinc-700 px-2 py-0.5 text-[10px] font-mono text-zinc-400 hover:border-emerald-700 hover:text-emerald-400 transition-colors"
            >
              {preset.label}
            </button>
          ))}
        </div>
      )}

      {/* Input row */}
      <div className="flex items-center gap-2 border-t border-zinc-700 bg-zinc-900 px-3 py-2">
        <span className="font-mono text-sm text-emerald-500 select-none">&gt;</span>
        <input
          ref={inputRef}
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={handleKeyDown}
          placeholder={canInteract ? "Type a command… (↑↓ for history)" : "Server offline"}
          disabled={!canInteract}
          className="flex-1 bg-transparent font-mono text-sm text-zinc-200 placeholder:text-zinc-600 outline-none disabled:opacity-40"
        />
        {!atBottom && (
          <button
            type="button"
            onClick={scrollToBottom}
            className="text-zinc-600 hover:text-zinc-300 transition-colors"
            title="Jump to bottom"
          >
            <ArrowDownIcon size={14} />
          </button>
        )}
        {!canInteract && <ProhibitIcon size={14} className="text-zinc-700" />}
        <button
          type="button"
          onClick={() => send(input)}
          disabled={!canInteract || !input.trim()}
          className="text-zinc-500 hover:text-emerald-400 disabled:opacity-30 transition-colors cursor-pointer disabled:cursor-not-allowed"
          aria-label="Send command"
        >
          <PaperPlaneRightIcon size={15} />
        </button>
      </div>

      {/* Variable prompt modal */}
      {pendingPreset && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-xs flex items-center justify-center z-50 animate-in fade-in duration-200">
          <div className="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-xl p-5 shadow-2xl max-w-sm w-full mx-4 flex flex-col gap-4 animate-in zoom-in-95 duration-200">
            <div>
              <h3 className="text-base font-semibold text-zinc-900 dark:text-zinc-50">
                {pendingPreset.label}
              </h3>
              <p className="text-xs text-muted-foreground mt-1">
                This preset contains a{" "}
                <code className="text-zinc-600 dark:text-zinc-400 font-mono">{`{player}`}</code>{" "}
                placeholder.
              </p>
            </div>
            <div className="flex flex-col gap-1.5">
              <label className="text-xs text-muted-foreground font-medium">Player name</label>
              <input
                ref={variableInputRef}
                type="text"
                value={variableValue}
                onChange={(e) => setVariableValue(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === "Enter") executePendingPreset();
                  if (e.key === "Escape") setPendingPreset(null);
                }}
                placeholder="Enter player name…"
                className="flex h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-xs transition-colors placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring font-mono"
              />
            </div>
            <div className="flex items-center gap-2 justify-end">
              <button
                type="button"
                onClick={() => setPendingPreset(null)}
                className="rounded-md px-3 py-1.5 text-xs font-medium text-zinc-600 hover:text-zinc-800 hover:bg-zinc-100 dark:text-zinc-400 dark:hover:text-zinc-200 dark:hover:bg-zinc-800 transition-colors"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={executePendingPreset}
                disabled={!variableValue.trim()}
                className="rounded-md bg-emerald-600 px-3 py-1.5 text-xs font-medium text-white hover:bg-emerald-700 disabled:opacity-50 disabled:pointer-events-none transition-colors"
              >
                Send
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Presets manager modal */}
      <ConsolePresetsManager open={showPresetManager} onClose={() => setShowPresetManager(false)} />
    </div>
  );
}
