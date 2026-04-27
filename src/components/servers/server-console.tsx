"use client";
import { PaperPlaneRightIcon } from "@phosphor-icons/react";
import { useEffect, useRef, useState } from "react";

type Props = {
  lines: string[];
  status: number;
  connected: boolean;
  onSend: (command: string) => void;
};

export function ServerConsole({ lines, status, connected, onSend }: Props) {
  const [input, setInput] = useState("");
  const endRef = useRef<HTMLDivElement>(null);

  // biome-ignore lint/correctness/useExhaustiveDependencies: `lines` is the trigger — scroll-to-bottom must fire when new console output arrives, even though the body only touches the ref.
  useEffect(() => {
    endRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [lines]);

  const handleSend = () => {
    const cmd = input.trim();
    if (!cmd) return;
    onSend(cmd);
    setInput("");
  };

  const canInteract = connected && status === 1;
  const placeholder = canInteract ? "Type a command..." : "Server offline";

  return (
    <div className="flex flex-col rounded-lg border border-gray-700 bg-gray-900 overflow-hidden shadow-lg">
      <div className="h-80 overflow-y-auto flex-wrap p-3 font-mono text-xs leading-5 text-gray-300">
        {lines.length === 0 ? (
          <span className="text-gray-500 italic">
            {status === 1
              ? connected
                ? "Waiting for output..."
                : "Connecting..."
              : "Server is offline"}
          </span>
        ) : (
          lines.map((line, i) => (
            // biome-ignore lint/suspicious/noArrayIndexKey: console output is append-only (never reordered or spliced), so index is stable enough as a key.
            <div key={`${i}:${line}`} className="hover:bg-gray-800/50 px-1 -mx-1 rounded">
              {line}
            </div>
          ))
        )}
        <div ref={endRef} />
      </div>
      <div className="flex items-center gap-2 border-t border-gray-700 bg-gray-800 px-3 py-2">
        <span className="text-emerald-500 font-mono text-sm select-none">&gt;</span>
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === "Enter") handleSend();
          }}
          placeholder={placeholder}
          disabled={!canInteract}
          className="flex-1 bg-transparent text-gray-200 font-mono text-sm placeholder:text-gray-600 outline-none disabled:opacity-40"
        />
        <button
          type="button"
          onClick={handleSend}
          disabled={!canInteract || !input.trim()}
          className="text-gray-400 hover:text-emerald-400 disabled:opacity-30 disabled:hover:text-gray-400 transition-colors cursor-pointer disabled:cursor-not-allowed"
          aria-label="Send command"
        >
          <PaperPlaneRightIcon size={16} />
        </button>
      </div>
    </div>
  );
}
