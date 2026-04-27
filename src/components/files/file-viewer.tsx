"use client";
import { ArrowArcLeftIcon, FloppyDiskIcon } from "@phosphor-icons/react";
import { useEffect, useState } from "react";
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
  const [dirty, setDirty] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    readFileText({ email, serverid, path })
      .then((text) => {
        if (!cancelled) setContent(text);
      })
      .catch((e) => {
        if (!cancelled) setError(String(e));
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
      setDirty(false);
    } catch (e) {
      setError(String(e));
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="flex flex-col gap-3">
      <div className="flex items-center gap-2">
        <Button variant="outline" size="sm" onClick={handleBack}>
          <ArrowArcLeftIcon size={14} /> Back
        </Button>
        <span className="text-sm font-mono text-muted-foreground truncate">{path}</span>
        <Button size="sm" className="ml-auto" disabled={!dirty || saving} onClick={handleSave}>
          <FloppyDiskIcon size={14} /> {saving ? "Saving…" : "Save"}
        </Button>
      </div>
      {error && <p className="text-sm text-red-600">{error}</p>}
      <textarea
        value={content}
        onChange={(e) => {
          setContent(e.target.value);
          setDirty(true);
        }}
        className="h-[60vh] w-full resize-none rounded-md border bg-background p-3 font-mono text-sm"
        spellCheck={false}
      />
    </div>
  );
}
