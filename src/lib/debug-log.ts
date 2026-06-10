export type DebugLevel = "info" | "warn" | "error";

export type DebugEvent = {
  id: string;
  ts: number;
  level: DebugLevel;
  scope: string;
  message: string;
  detail?: string;
};

const STORAGE_KEY = "exaton_debug_events";
const CHANGE_EVENT = "exaton_debug_events_changed";
const MAX_EVENTS = 120;

function canUseStorage() {
  return typeof window !== "undefined" && typeof window.localStorage !== "undefined";
}

function eventId() {
  if (typeof crypto !== "undefined" && "randomUUID" in crypto) {
    return crypto.randomUUID();
  }
  return `${Date.now()}-${Math.random().toString(36).slice(2)}`;
}

function stringifyDetail(detail: unknown): string | undefined {
  if (detail === undefined || detail === null) return undefined;
  if (typeof detail === "string") return detail;
  if (detail instanceof Error) return detail.message;
  try {
    return JSON.stringify(detail);
  } catch {
    return String(detail);
  }
}

export function loadDebugEvents(): DebugEvent[] {
  if (!canUseStorage()) return [];
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return [];
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? (parsed as DebugEvent[]) : [];
  } catch {
    return [];
  }
}

export function recordDebugEvent({
  level = "info",
  scope,
  message,
  detail,
}: {
  level?: DebugLevel;
  scope: string;
  message: string;
  detail?: unknown;
}) {
  if (!canUseStorage()) return;
  try {
    const event: DebugEvent = {
      id: eventId(),
      ts: Date.now(),
      level,
      scope,
      message,
      detail: stringifyDetail(detail),
    };
    const next = [event, ...loadDebugEvents()].slice(0, MAX_EVENTS);
    localStorage.setItem(STORAGE_KEY, JSON.stringify(next));
    window.dispatchEvent(new CustomEvent(CHANGE_EVENT));
  } catch {
    /* debug logging must never break app flow */
  }
}

export function clearDebugEvents() {
  if (!canUseStorage()) return;
  try {
    localStorage.removeItem(STORAGE_KEY);
    window.dispatchEvent(new CustomEvent(CHANGE_EVENT));
  } catch {
    /* non-fatal */
  }
}

export function subscribeDebugEvents(listener: () => void) {
  if (typeof window === "undefined") return () => {};
  window.addEventListener(CHANGE_EVENT, listener);
  return () => window.removeEventListener(CHANGE_EVENT, listener);
}
