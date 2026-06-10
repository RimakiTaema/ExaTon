"use client";

import {
  ArrowsClockwiseIcon,
  PlusIcon,
  TrashIcon,
  UserListIcon,
  UsersIcon,
} from "@phosphor-icons/react";
import { useCallback, useEffect, useMemo, useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Skeleton } from "@/components/ui/skeleton";
import {
  addPlayerListEntries,
  deletePlayerListEntries,
  getPlayerList,
  getPlayerLists,
} from "@/lib/server-details";

type Props = {
  email: string;
  serverid: string;
  onlinePlayers?: string[];
};

function parseEntries(value: string): string[] {
  return [
    ...new Set(
      value
        .split(/[\n,]+/)
        .map((entry) => entry.trim())
        .filter(Boolean),
    ),
  ];
}

function labelForList(list: string): string {
  return list
    .split(/[-_]/)
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
}

export function ServerPlayersPanel({ email, serverid, onlinePlayers = [] }: Props) {
  const [lists, setLists] = useState<string[]>([]);
  const [selectedList, setSelectedList] = useState("");
  const [entries, setEntries] = useState<string[]>([]);
  const [entryDraft, setEntryDraft] = useState("");
  const [loadingLists, setLoadingLists] = useState(true);
  const [loadingEntries, setLoadingEntries] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const sortedEntries = useMemo(() => [...entries].sort((a, b) => a.localeCompare(b)), [entries]);

  const refreshLists = useCallback(async () => {
    setLoadingLists(true);
    setError(null);
    try {
      const nextLists = await getPlayerLists({ email, serverid });
      setLists(nextLists);
      setSelectedList((current) => {
        if (current && nextLists.includes(current)) return current;
        return nextLists[0] ?? "";
      });
    } catch (err) {
      setError(String(err));
    } finally {
      setLoadingLists(false);
    }
  }, [email, serverid]);

  const refreshEntries = useCallback(
    async (list: string) => {
      if (!list) {
        setEntries([]);
        return;
      }
      setLoadingEntries(true);
      setError(null);
      try {
        const nextEntries = await getPlayerList({ email, serverid, list });
        setEntries(nextEntries);
      } catch (err) {
        setError(String(err));
      } finally {
        setLoadingEntries(false);
      }
    },
    [email, serverid],
  );

  useEffect(() => {
    refreshLists();
  }, [refreshLists]);

  useEffect(() => {
    refreshEntries(selectedList);
  }, [selectedList, refreshEntries]);

  const handleAddEntries = async () => {
    const nextEntries = parseEntries(entryDraft);
    if (!selectedList || nextEntries.length === 0) return;
    setSaving(true);
    setError(null);
    try {
      const updated = await addPlayerListEntries({
        email,
        serverid,
        list: selectedList,
        entries: nextEntries,
      });
      setEntries(updated);
      setEntryDraft("");
    } catch (err) {
      setError(String(err));
    } finally {
      setSaving(false);
    }
  };

  const handleRemoveEntry = async (entry: string) => {
    if (!selectedList) return;
    setSaving(true);
    setError(null);
    try {
      const updated = await deletePlayerListEntries({
        email,
        serverid,
        list: selectedList,
        entries: [entry],
      });
      setEntries(updated);
    } catch (err) {
      setError(String(err));
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="grid gap-4 lg:grid-cols-[220px_minmax(0,1fr)]">
      <div className="flex flex-col gap-3">
        <div className="rounded-md border">
          <div className="flex items-center gap-2 border-b px-3 py-2 text-sm font-medium">
            <UserListIcon size={16} />
            Player Lists
            <Button
              size="icon-xs"
              variant="ghost"
              className="ml-auto"
              onClick={refreshLists}
              disabled={loadingLists}
              aria-label="Refresh player lists"
            >
              <ArrowsClockwiseIcon size={14} className={loadingLists ? "animate-spin" : ""} />
            </Button>
          </div>
          {loadingLists ? (
            <div className="flex flex-col gap-2 p-3">
              <Skeleton className="h-8 rounded-md" />
              <Skeleton className="h-8 rounded-md" />
              <Skeleton className="h-8 rounded-md" />
            </div>
          ) : lists.length === 0 ? (
            <p className="px-3 py-2 text-sm text-muted-foreground">No editable lists found.</p>
          ) : (
            <div className="flex flex-col p-1">
              {lists.map((list) => (
                <button
                  key={list}
                  type="button"
                  className={`rounded-md px-2 py-2 text-left text-sm ${
                    list === selectedList ? "bg-emerald-50 text-emerald-700" : "hover:bg-muted/60"
                  }`}
                  onClick={() => setSelectedList(list)}
                >
                  {labelForList(list)}
                </button>
              ))}
            </div>
          )}
        </div>
        <div className="rounded-md border px-3 py-2">
          <div className="mb-1 flex items-center gap-2 text-sm font-medium">
            <UsersIcon size={16} />
            Online Now
          </div>
          {onlinePlayers.length > 0 ? (
            <div className="flex flex-wrap gap-1.5">
              {onlinePlayers.map((player) => (
                <span key={player} className="rounded-md bg-muted px-2 py-1 text-xs">
                  {player}
                </span>
              ))}
            </div>
          ) : (
            <p className="text-xs text-muted-foreground">No live player names available.</p>
          )}
        </div>
      </div>

      <div className="flex min-w-0 flex-col gap-3">
        <div className="flex flex-wrap items-center gap-2">
          <div className="min-w-0">
            <p className="text-sm font-medium">
              {selectedList ? labelForList(selectedList) : "List"}
            </p>
            <p className="text-xs text-muted-foreground">
              {entries.length} {entries.length === 1 ? "entry" : "entries"}
            </p>
          </div>
          <Button
            size="sm"
            variant="outline"
            className="ml-auto"
            onClick={() => refreshEntries(selectedList)}
            disabled={!selectedList || loadingEntries}
          >
            <ArrowsClockwiseIcon size={14} className={loadingEntries ? "animate-spin" : ""} />
            Refresh
          </Button>
        </div>

        <div className="flex gap-2">
          <Input
            value={entryDraft}
            onChange={(event) => setEntryDraft(event.target.value)}
            placeholder="Add names, separated by commas"
            disabled={!selectedList || saving}
            onKeyDown={(event) => {
              if (event.key === "Enter") handleAddEntries();
            }}
          />
          <Button
            onClick={handleAddEntries}
            disabled={!selectedList || !entryDraft.trim() || saving}
          >
            <PlusIcon size={14} />
            Add
          </Button>
        </div>

        {error && <p className="text-sm text-red-600">{error}</p>}

        <div className="min-h-40 rounded-md border">
          {loadingEntries ? (
            <div className="flex flex-col gap-2 p-3">
              <Skeleton className="h-8 rounded-md" />
              <Skeleton className="h-8 rounded-md" />
              <Skeleton className="h-8 rounded-md" />
            </div>
          ) : sortedEntries.length === 0 ? (
            <p className="px-3 py-2 text-sm text-muted-foreground">This list is empty.</p>
          ) : (
            sortedEntries.map((entry) => (
              <div
                key={entry}
                className="flex items-center gap-2 border-b px-3 py-2 last:border-b-0"
              >
                <span className="min-w-0 flex-1 truncate text-sm">{entry}</span>
                <Button
                  size="icon-xs"
                  variant="ghost"
                  onClick={() => handleRemoveEntry(entry)}
                  disabled={saving}
                  aria-label={`Remove ${entry}`}
                >
                  <TrashIcon size={14} />
                </Button>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
}
