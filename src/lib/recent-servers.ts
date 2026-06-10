export type RecentServer = {
  id: string;
  name: string;
  address: string;
  status: number;
  accountEmail: string;
  visitedAt: number;
};

type ServerLike = {
  id?: string | null;
  name?: string | null;
  address?: string | null;
  status?: number | null;
};

const STORAGE_KEY = "exaton_recent_servers";
const CHANGE_EVENT = "exaton_recent_servers_changed";
const MAX_RECENT = 12;

function canUseStorage() {
  return typeof window !== "undefined" && typeof window.localStorage !== "undefined";
}

function readAll(): RecentServer[] {
  if (!canUseStorage()) return [];
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return [];
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) return [];
    return parsed.filter((item): item is RecentServer => {
      return (
        typeof item?.id === "string" &&
        typeof item?.name === "string" &&
        typeof item?.accountEmail === "string" &&
        typeof item?.visitedAt === "number"
      );
    });
  } catch {
    return [];
  }
}

function writeAll(items: RecentServer[]) {
  if (!canUseStorage()) return;
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(items.slice(0, MAX_RECENT)));
    window.dispatchEvent(new CustomEvent(CHANGE_EVENT));
  } catch {
    /* non-fatal */
  }
}

export function loadRecentServers(accountEmail?: string | null): RecentServer[] {
  const items = readAll().sort((a, b) => b.visitedAt - a.visitedAt);
  if (!accountEmail) return items;
  return items.filter((item) => item.accountEmail === accountEmail);
}

export function rememberRecentServer(accountEmail: string, server: ServerLike) {
  if (!server.id) return;
  const entry: RecentServer = {
    id: server.id,
    name: server.name || server.id,
    address: server.address || "",
    status: typeof server.status === "number" ? server.status : 0,
    accountEmail,
    visitedAt: Date.now(),
  };
  const next = [
    entry,
    ...readAll().filter(
      (item) => !(item.id === entry.id && item.accountEmail === entry.accountEmail),
    ),
  ];
  writeAll(next);
}

export function clearRecentServers(accountEmail?: string | null) {
  if (!accountEmail) {
    writeAll([]);
    return;
  }
  writeAll(readAll().filter((item) => item.accountEmail !== accountEmail));
}

export function subscribeRecentServers(listener: () => void) {
  if (typeof window === "undefined") return () => {};
  window.addEventListener(CHANGE_EVENT, listener);
  window.addEventListener("focus", listener);
  return () => {
    window.removeEventListener(CHANGE_EVENT, listener);
    window.removeEventListener("focus", listener);
  };
}
