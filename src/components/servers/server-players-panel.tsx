"use client";

import {
  ArrowsClockwiseIcon,
  CheckCircleIcon,
  FunnelIcon,
  PlusIcon,
  TrashIcon,
  UserListIcon,
  UserPlusIcon,
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

/** Avatar initials block for a player name */
function PlayerAvatar({ name }: { name: string }) {
  return (
    <span className="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-emerald-100 text-[10px] font-bold text-emerald-700 uppercase select-none">
      {name.slice(0, 2)}
    </span>
  );
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
  const [successMsg, setSuccessMsg] = useState<string | null>(null);

  // Search / bulk-select
  const [entrySearch, setEntrySearch] = useState("");
  const [selected, setSelected] = useState<Set<string>>(new Set());

  const sortedEntries = useMemo(() => [...entries].sort((a, b) => a.localeCompare(b)), [entries]);

  const filteredEntries = useMemo(
    () =>
      entrySearch
        ? sortedEntries.filter((e) => e.toLowerCase().includes(entrySearch.toLowerCase()))
        : sortedEntries,
    [sortedEntries, entrySearch],
  );

  const flash = (msg: string) => {
    setSuccessMsg(msg);
    setTimeout(() => setSuccessMsg(null), 2500);
  };

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
      setSelected(new Set());
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

  const handleAddEntries = async (names?: string[]) => {
    const toAdd = names ?? parseEntries(entryDraft);
    if (!selectedList || toAdd.length === 0) return;
    setSaving(true);
    setError(null);
    try {
      const updated = await addPlayerListEntries({
        email,
        serverid,
        list: selectedList,
        entries: toAdd,
      });
      setEntries(updated);
      setEntryDraft("");
      flash(`Added ${toAdd.length} player${toAdd.length !== 1 ? "s" : ""}.`);
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
      setSelected((s) => {
        const n = new Set(s);
        n.delete(entry);
        return n;
      });
      flash(`Removed ${entry}.`);
    } catch (err) {
      setError(String(err));
    } finally {
      setSaving(false);
    }
  };

  const handleBulkRemove = async () => {
    if (!selectedList || selected.size === 0) return;
    const toRemove = [...selected];
    setSaving(true);
    setError(null);
    try {
      const updated = await deletePlayerListEntries({
        email,
        serverid,
        list: selectedList,
        entries: toRemove,
      });
      setEntries(updated);
      setSelected(new Set());
      flash(`Removed ${toRemove.length} player${toRemove.length !== 1 ? "s" : ""}.`);
    } catch (err) {
      setError(String(err));
    } finally {
      setSaving(false);
    }
  };

  const toggleSelect = (entry: string) => {
    setSelected((s) => {
      const n = new Set(s);
      if (n.has(entry)) n.delete(entry);
      else n.add(entry);
      return n;
    });
  };

  const toggleSelectAll = () => {
    if (selected.size === filteredEntries.length) {
      setSelected(new Set());
    } else {
      setSelected(new Set(filteredEntries));
    }
  };

  return (
    <div className="grid gap-4 lg:grid-cols-[220px_minmax(0,1fr)]">
      {/* ── Left sidebar ─────────────────────────────── */}
      <div className="flex flex-col gap-3">
        {/* Player lists */}
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
                  className={`flex items-center justify-between rounded-md px-2 py-2 text-left text-sm transition-colors ${
                    list === selectedList
                      ? "bg-emerald-50 text-emerald-700 dark:bg-emerald-950/40 dark:text-emerald-400"
                      : "hover:bg-muted/60"
                  }`}
                  onClick={() => setSelectedList(list)}
                >
                  <span>{labelForList(list)}</span>
                  {list === selectedList && entries.length > 0 && (
                    <span className="rounded-full bg-emerald-200 dark:bg-emerald-800 px-1.5 py-0.5 text-[10px] font-semibold text-emerald-800 dark:text-emerald-300">
                      {entries.length}
                    </span>
                  )}
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Online players */}
        <div className="rounded-md border px-3 py-2">
          <div className="mb-2 flex items-center gap-2 text-sm font-medium">
            <UsersIcon size={16} />
            Online Now
            <span className="ml-auto rounded-full bg-emerald-100 dark:bg-emerald-900 px-2 py-0.5 text-[10px] font-semibold text-emerald-700 dark:text-emerald-300">
              {onlinePlayers.length}
            </span>
          </div>
          {onlinePlayers.length > 0 ? (
            <div className="flex flex-col gap-1.5">
              {onlinePlayers.map((player) => (
                <div key={player} className="flex items-center gap-2 group">
                  <PlayerAvatar name={player} />
                  <span className="flex-1 min-w-0 truncate text-xs font-medium">{player}</span>
                  {selectedList && (
                    <button
                      type="button"
                      title={`Add ${player} to ${labelForList(selectedList)}`}
                      disabled={saving || entries.includes(player)}
                      onClick={() => handleAddEntries([player])}
                      className="opacity-60 hover:opacity-100 disabled:opacity-30 transition-opacity text-muted-foreground hover:text-emerald-600"
                    >
                      <UserPlusIcon size={14} />
                    </button>
                  )}
                </div>
              ))}
            </div>
          ) : (
            <p className="text-xs text-muted-foreground">No players online.</p>
          )}
        </div>
      </div>

      {/* ── Right main panel ─────────────────────────── */}
      <div className="flex min-w-0 flex-col gap-3">
        {/* Toolbar */}
        <div className="flex flex-wrap items-center gap-2">
          <div className="min-w-0">
            <p className="text-sm font-medium">
              {selectedList ? labelForList(selectedList) : "List"}
            </p>
            <p className="text-xs text-muted-foreground">
              {entries.length} {entries.length === 1 ? "entry" : "entries"}
              {entrySearch && ` · ${filteredEntries.length} shown`}
            </p>
          </div>
          <div className="ml-auto flex items-center gap-1.5">
            {selected.size > 0 && (
              <Button
                size="sm"
                variant="destructive"
                onClick={handleBulkRemove}
                disabled={saving}
                className="gap-1"
              >
                <TrashIcon size={14} />
                Remove {selected.size}
              </Button>
            )}
            <Button
              size="sm"
              variant="outline"
              onClick={() => refreshEntries(selectedList)}
              disabled={!selectedList || loadingEntries}
            >
              <ArrowsClockwiseIcon size={14} className={loadingEntries ? "animate-spin" : ""} />
              Refresh
            </Button>
          </div>
        </div>

        {/* Add entry */}
        <div className="flex gap-2">
          <Input
            value={entryDraft}
            onChange={(event) => setEntryDraft(event.target.value)}
            placeholder="Add player names, separated by commas…"
            disabled={!selectedList || saving}
            onKeyDown={(event) => {
              if (event.key === "Enter") handleAddEntries();
            }}
          />
          <Button
            onClick={() => handleAddEntries()}
            disabled={!selectedList || !entryDraft.trim() || saving}
          >
            <PlusIcon size={14} />
            Add
          </Button>
        </div>

        {error && <p className="text-sm text-red-600">{error}</p>}
        {successMsg && (
          <p className="flex items-center gap-1.5 text-sm text-emerald-700">
            <CheckCircleIcon size={14} />
            {successMsg}
          </p>
        )}

        {/* Search + select all */}
        {!loadingEntries && sortedEntries.length > 0 && (
          <div className="flex items-center gap-2">
            <div className="relative flex-1">
              <FunnelIcon
                size={12}
                className="absolute left-2.5 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none"
              />
              <Input
                value={entrySearch}
                onChange={(e) => setEntrySearch(e.target.value)}
                placeholder="Search entries…"
                className="pl-7 h-8 text-xs"
              />
            </div>
            <button
              type="button"
              onClick={toggleSelectAll}
              className="text-xs text-muted-foreground hover:text-foreground transition-colors whitespace-nowrap"
            >
              {selected.size === filteredEntries.length && filteredEntries.length > 0
                ? "Deselect all"
                : "Select all"}
            </button>
          </div>
        )}

        {/* Entry list */}
        <div className="min-h-40 rounded-md border overflow-hidden">
          {loadingEntries ? (
            <div className="flex flex-col gap-2 p-3">
              <Skeleton className="h-8 rounded-md" />
              <Skeleton className="h-8 rounded-md" />
              <Skeleton className="h-8 rounded-md" />
            </div>
          ) : filteredEntries.length === 0 ? (
            <div className="flex flex-col items-center justify-center gap-2 py-10 text-muted-foreground">
              <UsersIcon size={28} className="opacity-30" />
              <p className="text-sm">
                {entrySearch ? "No entries match your search." : "This list is empty."}
              </p>
            </div>
          ) : (
            <div className="divide-y">
              {filteredEntries.map((entry) => {
                const isOnline = onlinePlayers.includes(entry);
                const isChecked = selected.has(entry);
                return (
                  <div
                    key={entry}
                    className={`flex items-center gap-2.5 px-3 py-2 transition-colors ${
                      isChecked ? "bg-red-50 dark:bg-red-950/30" : "hover:bg-muted/40"
                    }`}
                  >
                    {/* Checkbox */}
                    <button
                      type="button"
                      onClick={() => toggleSelect(entry)}
                      className={`h-4 w-4 shrink-0 rounded border transition-colors flex items-center justify-center ${
                        isChecked
                          ? "bg-red-500 border-red-500 text-white"
                          : "border-muted-foreground/40 hover:border-muted-foreground"
                      }`}
                      aria-label={`${isChecked ? "Deselect" : "Select"} ${entry}`}
                    >
                      {isChecked && (
                        <svg width="9" height="9" viewBox="0 0 10 10" fill="none" aria-hidden>
                          <path
                            d="M2 5l2.5 2.5L8 3"
                            stroke="white"
                            strokeWidth="1.5"
                            strokeLinecap="round"
                            strokeLinejoin="round"
                          />
                        </svg>
                      )}
                    </button>

                    <PlayerAvatar name={entry} />

                    <span className="min-w-0 flex-1 truncate text-sm font-medium">{entry}</span>

                    {isOnline && (
                      <span className="rounded-full bg-emerald-100 dark:bg-emerald-900/50 px-2 py-0.5 text-[10px] font-semibold text-emerald-700 dark:text-emerald-400">
                        Online
                      </span>
                    )}

                    <Button
                      size="icon-xs"
                      variant="ghost"
                      onClick={() => handleRemoveEntry(entry)}
                      disabled={saving}
                      aria-label={`Remove ${entry}`}
                      className="shrink-0 text-muted-foreground hover:text-red-600"
                    >
                      <TrashIcon size={14} />
                    </Button>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
