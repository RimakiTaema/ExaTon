import { invoke } from "@tauri-apps/api/core";

export type PoolSummary = {
  id: string;
  name: string;
  ownCredits: number;
  totalCredits: number;
  isOwner: boolean;
};

export type AccountSummary = {
  email: string;
  name: string;
  personalCredits: number;
  poolCredits: number;
  pools: PoolSummary[];
};

export type CachedAccountSummary = AccountSummary & { updatedAt: number };

const CACHE_PREFIX = "exaton_credits_";

export async function refreshAccountSummary(email: string): Promise<AccountSummary> {
  return await invoke<AccountSummary>("refresh_account_summary", { email });
}

export function loadCachedSummary(email: string): CachedAccountSummary | null {
  try {
    const raw = localStorage.getItem(`${CACHE_PREFIX}${email}`);
    if (!raw) return null;
    return JSON.parse(raw) as CachedAccountSummary;
  } catch {
    return null;
  }
}

export function saveCachedSummary(summary: AccountSummary): CachedAccountSummary {
  const cached: CachedAccountSummary = { ...summary, updatedAt: Date.now() };
  try {
    localStorage.setItem(`${CACHE_PREFIX}${summary.email}`, JSON.stringify(cached));
  } catch {
    /* storage quota / private mode — non-fatal */
  }
  return cached;
}

export function clearCachedSummary(email: string): void {
  try {
    localStorage.removeItem(`${CACHE_PREFIX}${email}`);
  } catch {
    /* non-fatal */
  }
}

export function formatAgo(updatedAt: number): string {
  const secs = Math.floor((Date.now() - updatedAt) / 1000);
  if (secs < 10) return "just now";
  if (secs < 60) return `${secs}s ago`;
  const mins = Math.floor(secs / 60);
  if (mins < 60) return `${mins}m ago`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `${hours}h ago`;
  return `${Math.floor(hours / 24)}d ago`;
}
