"use client";
import {
  ArrowArcLeftIcon,
  DownloadSimpleIcon,
  FileIcon,
  FolderIcon,
  TrashIcon,
  UploadSimpleIcon,
} from "@phosphor-icons/react";
import { open, save } from "@tauri-apps/plugin-dialog";
import { useCallback, useEffect, useMemo, useState } from "react";
import { FileViewer } from "@/components/files/file-viewer";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import {
  deleteServerFile,
  downloadFile,
  type FileInfo,
  listFiles,
  uploadFile,
} from "@/lib/exaroton-files";
import { formatSize, joinPath, parentPath, splitPath } from "@/lib/files-utils";

type Props = {
  email: string;
  serverid: string;
};

export function FilesPanel({ email, serverid }: Props) {
  const [currentPath, setCurrentPath] = useState<string>("");
  const [entries, setEntries] = useState<FileInfo[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [viewingPath, setViewingPath] = useState<string | null>(null);

  const crumbs = useMemo(() => splitPath(currentPath), [currentPath]);

  const refresh = useCallback(
    async (path: string) => {
      setLoading(true);
      setError(null);
      try {
        const info = await listFiles({ email, serverid, path });
        setEntries(info?.children ?? []);
      } catch (e) {
        setError(String(e));
      } finally {
        setLoading(false);
      }
    },
    [email, serverid],
  );

  useEffect(() => {
    if (!viewingPath) refresh(currentPath);
  }, [currentPath, viewingPath, refresh]);

  const goTo = (path: string) => {
    setCurrentPath(path);
    setViewingPath(null);
  };

  const openEntry = (entry: FileInfo) => {
    if (entry.isDirectory) {
      goTo(entry.path ?? joinPath([...crumbs, entry.name ?? ""]));
      return;
    }
    if (!entry.isTextFile) {
      setError("Binary files can only be downloaded.");
      return;
    }
    setError(null);
    setViewingPath(entry.path ?? "");
  };

  const removeEntry = async (entry: FileInfo) => {
    if (!entry.path) return;
    if (!confirm(`Delete ${entry.name}?`)) return;
    setError(null);
    try {
      await deleteServerFile({ email, serverid, path: entry.path });
      await refresh(currentPath);
    } catch (e) {
      setError(String(e));
    }
  };

  const handleUpload = async () => {
    const selected = await open({ multiple: false, directory: false });
    if (!selected || typeof selected !== "string") return;
    const name = selected.split(/[/\\]/).pop() ?? "upload";
    const remotePath = joinPath([...crumbs, name]);
    setError(null);
    try {
      await uploadFile({ email, serverid, remotePath, localPath: selected });
      await refresh(currentPath);
    } catch (e) {
      setError(String(e));
    }
  };

  const handleDownload = async (entry: FileInfo) => {
    if (!entry.path) return;
    const target = await save({ defaultPath: entry.name });
    if (!target) return;
    setError(null);
    try {
      await downloadFile({ email, serverid, remotePath: entry.path, savePath: target });
    } catch (e) {
      setError(String(e));
    }
  };

  if (viewingPath !== null) {
    return (
      <FileViewer
        email={email}
        serverid={serverid}
        path={viewingPath}
        onBack={() => setViewingPath(null)}
      />
    );
  }

  const sorted = [...entries].sort((a, b) => {
    if (a.isDirectory !== b.isDirectory) return a.isDirectory ? -1 : 1;
    return (a.name ?? "").localeCompare(b.name ?? "");
  });

  return (
    <div className="flex flex-col gap-3">
      <Breadcrumbs crumbs={crumbs} onGoTo={goTo} onUpload={handleUpload} />
      {error && <p className="text-sm text-red-600">{error}</p>}
      {loading ? (
        <ListSkeleton />
      ) : (
        <div className="flex flex-col rounded-md border">
          {crumbs.length > 0 && <UpOneRow onClick={() => goTo(parentPath(currentPath))} />}
          {sorted.length === 0 && !crumbs.length && (
            <p className="px-3 py-2 text-sm text-muted-foreground italic">Empty directory.</p>
          )}
          {sorted.map((entry) => (
            <EntryRow
              key={entry.path ?? entry.name}
              entry={entry}
              onOpen={() => openEntry(entry)}
              onDownload={() => handleDownload(entry)}
              onDelete={() => removeEntry(entry)}
            />
          ))}
        </div>
      )}
    </div>
  );
}

function Breadcrumbs({
  crumbs,
  onGoTo,
  onUpload,
}: {
  crumbs: string[];
  onGoTo: (path: string) => void;
  onUpload: () => void;
}) {
  return (
    <div className="flex items-center gap-2 text-sm">
      <button
        type="button"
        className="text-muted-foreground hover:text-foreground"
        onClick={() => onGoTo("")}
      >
        /
      </button>
      {crumbs.map((seg, i) => {
        const target = joinPath(crumbs.slice(0, i + 1));
        return (
          <span key={target} className="flex items-center gap-2">
            <span className="text-muted-foreground">/</span>
            <button type="button" className="hover:text-foreground" onClick={() => onGoTo(target)}>
              {seg}
            </button>
          </span>
        );
      })}
      <Button variant="outline" size="sm" className="ml-auto" onClick={onUpload}>
        <UploadSimpleIcon size={14} /> Upload
      </Button>
    </div>
  );
}

function UpOneRow({ onClick }: { onClick: () => void }) {
  return (
    <button
      type="button"
      className="flex items-center gap-2 border-b px-3 py-2 text-left hover:bg-muted/40"
      onClick={onClick}
    >
      <ArrowArcLeftIcon size={16} className="text-muted-foreground" />
      <span className="text-sm text-muted-foreground">..</span>
    </button>
  );
}

function EntryRow({
  entry,
  onOpen,
  onDownload,
  onDelete,
}: {
  entry: FileInfo;
  onOpen: () => void;
  onDownload: () => void;
  onDelete: () => void;
}) {
  return (
    <div className="flex items-center gap-3 border-b px-3 py-2 last:border-b-0 hover:bg-muted/40">
      <button type="button" className="flex flex-1 items-center gap-2 text-left" onClick={onOpen}>
        {entry.isDirectory ? (
          <FolderIcon size={16} className="text-amber-500" />
        ) : (
          <FileIcon size={16} className="text-muted-foreground" />
        )}
        <span className="text-sm">{entry.name}</span>
        {!entry.isDirectory && typeof entry.size === "number" && (
          <span className="ml-auto text-xs text-muted-foreground">{formatSize(entry.size)}</span>
        )}
      </button>
      {!entry.isDirectory && (
        <button
          type="button"
          className="text-muted-foreground hover:text-foreground"
          onClick={onDownload}
          aria-label={`Download ${entry.name}`}
        >
          <DownloadSimpleIcon size={16} />
        </button>
      )}
      <button
        type="button"
        className="text-muted-foreground hover:text-red-500"
        onClick={onDelete}
        aria-label={`Delete ${entry.name}`}
      >
        <TrashIcon size={16} />
      </button>
    </div>
  );
}

function ListSkeleton() {
  return (
    <div className="flex flex-col gap-2">
      {[1, 2, 3, 4].map((i) => (
        <Skeleton key={i} className="h-9 rounded-md" />
      ))}
    </div>
  );
}
