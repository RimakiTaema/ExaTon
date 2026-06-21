"use client";
import {
  ArrowArcLeftIcon,
  FloppyDiskIcon,
  SpinnerIcon,
  WarningDiamondIcon,
} from "@phosphor-icons/react";
import { useEffect, useRef, useState } from "react";
import { Button } from "@/components/ui/button";
import { readFileText, writeFileText } from "@/lib/exaroton-files";

type Props = {
  email: string;
  serverid: string;
  path: string;
  onBack: () => void;
};

export function FileViewer({ email, serverid, path, onBack }: Props) {
  const [content, setContent] = useState("");
  const [original, setOriginal] = useState("");
  const [loading, setLoading] = useState(true);
  const [dirty, setDirty] = useState(false);
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const textareaRef = useRef<HTMLTextAreaElement>(null);
  const handleSaveRef = useRef<() => Promise<void>>(async () => {});

  const filename = path.split("/").pop() ?? path;
  const ext = filename.split(".").pop()?.toLowerCase() ?? "";
  const lineCount = content.split("\n").length;

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    setError(null);
    readFileText({ email, serverid, path })
      .then((text) => {
        if (!cancelled) {
          setContent(text);
          setOriginal(text);
          setLoading(false);
        }
      })
      .catch((e) => {
        if (!cancelled) {
          setError(String(e));
          setLoading(false);
        }
      });
    return () => {
      cancelled = true;
    };
  }, [email, serverid, path]);

  const handleBack = () => {
    if (dirty && !confirm("Discard unsaved changes?")) return;
    onBack();
  };

  const handleSave = async () => {
    setSaving(true);
    setError(null);
    try {
      await writeFileText({ email, serverid, path, text: content });
      setOriginal(content);
      setDirty(false);
      setSaved(true);
      setTimeout(() => setSaved(false), 2000);
    } catch (e) {
      setError(String(e));
    } finally {
      setSaving(false);
    }
  };

  handleSaveRef.current = handleSave;

  // Ctrl/Cmd+S to save
  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if ((e.ctrlKey || e.metaKey) && e.key === "s") {
        e.preventDefault();
        if (dirty && !saving) handleSaveRef.current();
      }
    };
    window.addEventListener("keydown", handler);
    return () => window.removeEventListener("keydown", handler);
  }, [dirty, saving]);

  const handleChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    setContent(e.target.value);
    setDirty(e.target.value !== original);
  };

  const handleReset = () => {
    if (!confirm("Revert all changes?")) return;
    setContent(original);
    setDirty(false);
  };

  return (
    <div className="flex flex-col gap-0 overflow-hidden rounded-lg border">
      {/* Top bar */}
      <div className="flex items-center gap-2 border-b bg-muted/30 px-3 py-2">
        <Button variant="ghost" size="sm" onClick={handleBack} className="gap-1.5 text-xs">
          <ArrowArcLeftIcon size={13} />
          Back
        </Button>

        <div className="flex items-center gap-1.5 min-w-0 flex-1">
          <span className="truncate font-mono text-xs text-muted-foreground">{path}</span>
          {dirty && (
            <span
              className="shrink-0 rounded-full bg-amber-500 w-1.5 h-1.5"
              title="Unsaved changes"
            />
          )}
        </div>

        <div className="flex items-center gap-1.5 shrink-0">
          {dirty && (
            <Button
              variant="ghost"
              size="sm"
              onClick={handleReset}
              className="text-xs text-muted-foreground"
            >
              Revert
            </Button>
          )}
          <Button
            size="sm"
            disabled={!dirty || saving}
            onClick={handleSave}
            className="gap-1.5 text-xs"
          >
            {saving ? (
              <SpinnerIcon size={13} className="animate-spin" />
            ) : (
              <FloppyDiskIcon size={13} />
            )}
            {saving ? "Saving…" : saved ? "Saved!" : "Save"}
          </Button>
        </div>
      </div>

      {/* Error bar */}
      {error && (
        <div className="flex items-center gap-2 border-b bg-red-50 dark:bg-red-950/30 px-3 py-1.5 text-xs text-red-700 dark:text-red-400">
          <WarningDiamondIcon size={13} className="shrink-0" />
          {error}
        </div>
      )}

      {/* Editor */}
      {loading ? (
        <div className="flex h-[60vh] items-center justify-center text-muted-foreground">
          <SpinnerIcon size={22} className="animate-spin" />
        </div>
      ) : (
        <textarea
          ref={textareaRef}
          value={content}
          onChange={handleChange}
          className="h-[60vh] w-full resize-none bg-background p-3 font-mono text-sm leading-relaxed outline-none"
          spellCheck={false}
          autoCorrect="off"
          autoCapitalize="off"
        />
      )}

      {/* Footer status bar */}
      <div className="flex items-center justify-between border-t bg-muted/20 px-3 py-1">
        <span className="font-mono text-[10px] text-muted-foreground">
          {filename}
          {ext && ` · .${ext}`}
        </span>
        <div className="flex items-center gap-3 text-[10px] text-muted-foreground font-mono">
          <span>{lineCount} lines</span>
          {dirty && <span className="text-amber-600 font-semibold">Modified · ⌘S to save</span>}
          {saved && <span className="text-emerald-600 font-semibold">Saved ✓</span>}
        </div>
      </div>
    </div>
  );
}
