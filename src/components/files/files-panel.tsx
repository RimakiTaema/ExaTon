"use client";
import {
  ArrowArcLeftIcon,
  ArrowsClockwiseIcon,
  CaretRightIcon,
  DownloadSimpleIcon,
  FileCodeIcon,
  FileCsvIcon,
  FileIcon,
  FileTextIcon,
  FolderIcon,
  FolderOpenIcon,
  HouseIcon,
  TrashIcon,
  UploadSimpleIcon,
  WarningIcon,
} from "@phosphor-icons/react";
import { open, save } from "@tauri-apps/plugin-dialog";
import { useCallback, useEffect, useMemo, useState } from "react";
import { FileViewer } from "@/components/files/file-viewer";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
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

/** Pick an icon based on file extension */
function FileEntryIcon({ entry }: { entry: FileInfo }) {
  if (entry.isDirectory) return <FolderIcon size={16} className="text-amber-500 shrink-0" />;
  const ext = (entry.name ?? "").split(".").pop()?.toLowerCase() ?? "";
  if (["yml", "yaml", "toml", "json", "properties", "cfg", "conf"].includes(ext))
    return <FileCodeIcon size={16} className="text-sky-400 shrink-0" />;
  if (["txt", "md", "log"].includes(ext))
    return <FileTextIcon size={16} className="text-zinc-400 shrink-0" />;
  if (ext === "csv") return <FileCsvIcon size={16} className="text-emerald-400 shrink-0" />;
  return <FileIcon size={16} className="text-zinc-500 shrink-0" />;
}

export function FilesPanel({ email, serverid }: Props) {
  const [currentPath, setCurrentPath] = useState<string>("");
  const [entries, setEntries] = useState<FileInfo[]>([]);
  const [loading, setLoading] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [viewingPath, setViewingPath] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const [deletingPath, setDeletingPath] = useState<string | null>(null);

  const crumbs = useMemo(() => splitPath(currentPath), [currentPath]);

  const refresh = useCallback(
    async (path: string) => {
      setLoading(true);
      setError(null);
      setSearch("");
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
      setError(`"${entry.name}" is a binary file — use Download instead.`);
      return;
    }
    setError(null);
    setViewingPath(entry.path ?? "");
  };

  const removeEntry = async (entry: FileInfo) => {
    if (!entry.path) return;
    setDeletingPath(entry.path);
    setError(null);
    try {
      await deleteServerFile({ email, serverid, path: entry.path });
      await refresh(currentPath);
    } catch (e) {
      setError(String(e));
    } finally {
      setDeletingPath(null);
    }
  };

  const handleUpload = async () => {
    const selected = await open({ multiple: false, directory: false });
    if (!selected || typeof selected !== "string") return;
    const name = selected.split(/[/\\]/).pop() ?? "upload";
    const remotePath = joinPath([...crumbs, name]);
    setError(null);
    setUploading(true);
    try {
      await uploadFile({ email, serverid, remotePath, localPath: selected });
      await refresh(currentPath);
    } catch (e) {
      setError(String(e));
    } finally {
      setUploading(false);
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

  const filtered = search
    ? sorted.filter((e) => (e.name ?? "").toLowerCase().includes(search.toLowerCase()))
    : sorted;

  const dirs = filtered.filter((e) => e.isDirectory);
  const files = filtered.filter((e) => !e.isDirectory);

  return (
    <div className="flex flex-col gap-3">
      {/* Breadcrumb + actions */}
      <div className="flex flex-wrap items-center gap-2">
        {/* Breadcrumbs */}
        <nav className="flex flex-1 items-center gap-0.5 min-w-0 text-sm font-mono overflow-hidden">
          <button
            type="button"
            onClick={() => goTo("")}
            className="flex items-center gap-1 rounded px-1.5 py-0.5 text-muted-foreground hover:text-foreground hover:bg-muted/50 transition-colors shrink-0"
            title="Server root"
          >
            <HouseIcon size={13} />
          </button>
          {crumbs.map((seg, i) => {
            const target = joinPath(crumbs.slice(0, i + 1));
            const isLast = i === crumbs.length - 1;
            return (
              <span key={target} className="flex items-center gap-0.5 min-w-0">
                <CaretRightIcon size={11} className="text-muted-foreground shrink-0" />
                <button
                  type="button"
                  onClick={() => goTo(target)}
                  className={`truncate rounded px-1.5 py-0.5 transition-colors hover:bg-muted/50 max-w-[120px] ${
                    isLast
                      ? "text-foreground font-semibold"
                      : "text-muted-foreground hover:text-foreground"
                  }`}
                >
                  {seg}
                </button>
              </span>
            );
          })}
        </nav>
        {/* Toolbar */}
        <div className="flex items-center gap-1.5 shrink-0">
          <Button
            variant="outline"
            size="sm"
            onClick={() => refresh(currentPath)}
            disabled={loading}
          >
            <ArrowsClockwiseIcon size={13} className={loading ? "animate-spin" : ""} />
            Refresh
          </Button>
          <Button variant="outline" size="sm" onClick={handleUpload} disabled={uploading}>
            <UploadSimpleIcon size={13} />
            {uploading ? "Uploading…" : "Upload"}
          </Button>
        </div>
      </div>

      {error && (
        <div className="flex items-center gap-2 rounded-md border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-700 dark:border-red-900 dark:bg-red-950/40 dark:text-red-400">
          <WarningIcon size={14} className="shrink-0" />
          {error}
        </div>
      )}

      {/* Search */}
      {!loading && entries.length > 5 && (
        <div className="relative">
          <Input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder={`Search ${entries.length} items…`}
            className="h-8 text-sm pl-3"
          />
        </div>
      )}

      {loading ? (
        <ListSkeleton />
      ) : (
        <div className="rounded-md border overflow-hidden">
          {/* Up one level */}
          {crumbs.length > 0 && (
            <button
              type="button"
              className="flex w-full items-center gap-2 border-b bg-muted/30 px-3 py-2 text-left hover:bg-muted/50 transition-colors"
              onClick={() => goTo(parentPath(currentPath))}
            >
              <ArrowArcLeftIcon size={14} className="text-muted-foreground" />
              <span className="font-mono text-sm text-muted-foreground">..</span>
              <span className="text-xs text-muted-foreground ml-1">Go up</span>
            </button>
          )}

          {filtered.length === 0 ? (
            <div className="flex flex-col items-center justify-center gap-2 py-12 text-muted-foreground">
              <FolderOpenIcon size={32} className="opacity-30" />
              <p className="text-sm">
                {search ? "No files match your search." : "This directory is empty."}
              </p>
            </div>
          ) : (
            <>
              {/* Directory section */}
              {dirs.length > 0 && (
                <>
                  {files.length > 0 && (
                    <p className="px-3 py-1 text-[10px] font-semibold uppercase tracking-widest text-muted-foreground bg-muted/20 border-b">
                      Folders — {dirs.length}
                    </p>
                  )}
                  {dirs.map((entry) => (
                    <EntryRow
                      key={entry.path ?? entry.name}
                      entry={entry}
                      deleting={deletingPath === entry.path}
                      onOpen={() => openEntry(entry)}
                      onDownload={() => handleDownload(entry)}
                      onDelete={() => removeEntry(entry)}
                    />
                  ))}
                </>
              )}
              {/* Files section */}
              {files.length > 0 && (
                <>
                  {dirs.length > 0 && (
                    <p className="px-3 py-1 text-[10px] font-semibold uppercase tracking-widest text-muted-foreground bg-muted/20 border-b border-t">
                      Files — {files.length}
                    </p>
                  )}
                  {files.map((entry) => (
                    <EntryRow
                      key={entry.path ?? entry.name}
                      entry={entry}
                      deleting={deletingPath === entry.path}
                      onOpen={() => openEntry(entry)}
                      onDownload={() => handleDownload(entry)}
                      onDelete={() => removeEntry(entry)}
                    />
                  ))}
                </>
              )}
            </>
          )}
        </div>
      )}

      {/* Stats footer */}
      {!loading && entries.length > 0 && (
        <p className="text-[11px] text-muted-foreground">
          {dirs.length} folder{dirs.length !== 1 ? "s" : ""}, {files.length} file
          {files.length !== 1 ? "s" : ""}
          {search && ` (filtered from ${entries.length})`}
        </p>
      )}
    </div>
  );
}

function EntryRow({
  entry,
  deleting,
  onOpen,
  onDownload,
  onDelete,
}: {
  entry: FileInfo;
  deleting: boolean;
  onOpen: () => void;
  onDownload: () => void;
  onDelete: () => void;
}) {
  const [confirmDelete, setConfirmDelete] = useState(false);

  const handleDeleteClick = () => {
    if (confirmDelete) {
      onDelete();
      setConfirmDelete(false);
    } else {
      setConfirmDelete(true);
      setTimeout(() => setConfirmDelete(false), 3000);
    }
  };

  return (
    <div
      className={`group flex items-center gap-2 border-b px-3 py-2 last:border-b-0 transition-colors ${
        deleting ? "opacity-40 pointer-events-none" : "hover:bg-muted/30"
      }`}
    >
      <button
        type="button"
        className="flex flex-1 min-w-0 items-center gap-2.5 text-left"
        onClick={onOpen}
      >
        <FileEntryIcon entry={entry} />
        <span className="truncate text-sm">{entry.name}</span>
        {entry.isReadable === false && (
          <span className="shrink-0 rounded bg-yellow-100 dark:bg-yellow-900/40 px-1.5 py-0.5 text-[9px] font-medium text-yellow-700 dark:text-yellow-400">
            No read
          </span>
        )}
        {!entry.isWritable && !entry.isDirectory && (
          <span className="shrink-0 rounded bg-muted px-1.5 py-0.5 text-[9px] font-medium text-muted-foreground">
            Read-only
          </span>
        )}
        {!entry.isDirectory && typeof entry.size === "number" && (
          <span className="ml-auto shrink-0 text-xs text-muted-foreground pr-1">
            {formatSize(entry.size)}
          </span>
        )}
      </button>

      {/* Action buttons — visible on hover */}
      <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity shrink-0">
        {!entry.isDirectory && (
          <button
            type="button"
            className="rounded p-1 text-muted-foreground hover:text-foreground hover:bg-muted transition-colors"
            onClick={onDownload}
            aria-label={`Download ${entry.name}`}
            title="Download"
          >
            <DownloadSimpleIcon size={14} />
          </button>
        )}
        <button
          type="button"
          className={`rounded p-1 transition-colors ${
            confirmDelete
              ? "bg-red-500 text-white hover:bg-red-600"
              : "text-muted-foreground hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-950/30"
          }`}
          onClick={handleDeleteClick}
          aria-label={confirmDelete ? `Confirm delete ${entry.name}` : `Delete ${entry.name}`}
          title={confirmDelete ? "Click again to confirm" : "Delete"}
        >
          <TrashIcon size={14} />
        </button>
      </div>
    </div>
  );
}

function ListSkeleton() {
  return (
    <div className="flex flex-col gap-1.5">
      {[1, 2, 3, 4, 5].map((i) => (
        <Skeleton key={i} className="h-9 rounded-md" />
      ))}
    </div>
  );
}
