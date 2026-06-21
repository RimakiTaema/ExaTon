/**
 * Credit Usage History — persists timestamped credit snapshots in localStorage
 * so we can render trend charts across sessions.
 */

const MAX_POINTS = 288; // 24h at 5-min intervals

export type CreditSnapshot = {
  ts: number; // Unix ms
  personal: number;
  pool: number;
};

export type ServerCreditSnapshot = {
  ts: number;
  credits: number; // personal credits at that moment
  running: boolean;
};

const GLOBAL_PREFIX = "exaton_credit_history_";
const SERVER_PREFIX = "exaton_server_credit_history_";

// ─── Global (per-account) ─────────────────────────────────────────────────────

export function loadCreditHistory(email: string): CreditSnapshot[] {
  try {
    const raw = localStorage.getItem(`${GLOBAL_PREFIX}${email}`);
    if (!raw) return [];
    return JSON.parse(raw) as CreditSnapshot[];
  } catch {
    return [];
  }
}

export function appendCreditSnapshot(
  email: string,
  snap: Omit<CreditSnapshot, "ts">,
): CreditSnapshot[] {
  const history = loadCreditHistory(email);
  const ts = Date.now();

  // Deduplicate: skip if last point is within 60s and values are identical
  const last = history[history.length - 1];
  if (last && ts - last.ts < 60_000 && last.personal === snap.personal && last.pool === snap.pool) {
    return history;
  }

  const next: CreditSnapshot = { ts, ...snap };
  const updated = [...history, next].slice(-MAX_POINTS);
  try {
    localStorage.setItem(`${GLOBAL_PREFIX}${email}`, JSON.stringify(updated));
  } catch {
    /* quota / private mode */
  }
  return updated;
}

export function clearCreditHistory(email: string): void {
  try {
    localStorage.removeItem(`${GLOBAL_PREFIX}${email}`);
  } catch {
    /* non-fatal */
  }
}

// ─── Per-server ───────────────────────────────────────────────────────────────

export function loadServerCreditHistory(email: string, serverid: string): ServerCreditSnapshot[] {
  try {
    const raw = localStorage.getItem(`${SERVER_PREFIX}${email}_${serverid}`);
    if (!raw) return [];
    return JSON.parse(raw) as ServerCreditSnapshot[];
  } catch {
    return [];
  }
}

export function appendServerCreditSnapshot(
  email: string,
  serverid: string,
  snap: Omit<ServerCreditSnapshot, "ts">,
): ServerCreditSnapshot[] {
  const history = loadServerCreditHistory(email, serverid);
  const ts = Date.now();

  const last = history[history.length - 1];
  if (
    last &&
    ts - last.ts < 60_000 &&
    last.credits === snap.credits &&
    last.running === snap.running
  ) {
    return history;
  }

  const next: ServerCreditSnapshot = { ts, ...snap };
  const updated = [...history, next].slice(-MAX_POINTS);
  try {
    localStorage.setItem(`${SERVER_PREFIX}${email}_${serverid}`, JSON.stringify(updated));
  } catch {
    /* quota */
  }
  return updated;
}

export function clearServerCreditHistory(email: string, serverid: string): void {
  try {
    localStorage.removeItem(`${SERVER_PREFIX}${email}_${serverid}`);
  } catch {
    /* non-fatal */
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

export function formatTs(ts: number): string {
  return new Date(ts).toLocaleTimeString([], {
    hour: "2-digit",
    minute: "2-digit",
  });
}

export function formatTsDate(ts: number): string {
  return new Date(ts).toLocaleDateString([], {
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

/** Estimate total credits spent by a server given its snapshot history.
 *  Exaroton charges 1 cr per hour when online. We detect intervals where
 *  running === true and sum the duration.
 */
export function estimateServerCreditUsage(history: ServerCreditSnapshot[]): number {
  if (history.length < 2) return 0;
  let totalMs = 0;
  for (let i = 1; i < history.length; i++) {
    if (history[i - 1].running) {
      totalMs += history[i].ts - history[i - 1].ts;
    }
  }
  return totalMs / 3_600_000; // ms → hours → credits (1 cr/hr)
}

/** Compute per-point credit burn rate (credits/hr) between adjacent snapshots */
export function computeBurnRate(
  history: CreditSnapshot[],
): Array<{ ts: number; burnRate: number }> {
  const result: Array<{ ts: number; burnRate: number }> = [];
  for (let i = 1; i < history.length; i++) {
    const dt = (history[i].ts - history[i - 1].ts) / 3_600_000; // hours
    if (dt <= 0) continue;
    const delta = history[i - 1].personal - history[i].personal; // drop = positive burn
    result.push({ ts: history[i].ts, burnRate: Math.max(0, delta / dt) });
  }
  return result;
}
