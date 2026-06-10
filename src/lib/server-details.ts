import { invoke } from "@tauri-apps/api/core";
import { recordDebugEvent } from "@/lib/debug-log";

type ApiResponse<T> = {
  success?: boolean;
  error?: string | null;
  data?: T | null;
};

type Auth = {
  email: string;
  serverid: string;
};

export type ServerLogData = {
  content?: string | null;
};

export type SharedLogData = {
  id?: string | null;
  url?: string | null;
  raw?: string | null;
};

export type ServerMotdData = {
  motd?: string | null;
};

export type ServerRamData = {
  ram?: number | null;
};

async function callServerDetail<T>(
  command: string,
  args: Record<string, unknown>,
  scope: string,
): Promise<ApiResponse<T>> {
  const started = Date.now();
  recordDebugEvent({ scope, message: `${command} started`, detail: args });
  try {
    const result = await invoke<ApiResponse<T>>(command, args);
    const elapsed = Date.now() - started;
    recordDebugEvent({
      level: result.error ? "warn" : "info",
      scope,
      message: result.error ? `${command} returned an API error` : `${command} succeeded`,
      detail: { elapsedMs: elapsed, error: result.error ?? null },
    });
    return result;
  } catch (error) {
    recordDebugEvent({ level: "error", scope, message: `${command} failed`, detail: error });
    throw error;
  }
}

export async function getPlayerLists(args: Auth): Promise<string[]> {
  const result = await callServerDetail<string[]>("get_player_lists_info", args, "players");
  return result.data ?? [];
}

export async function getPlayerList(args: Auth & { list: string }): Promise<string[]> {
  const result = await callServerDetail<string[]>("get_player_list_info", args, "players");
  return result.data ?? [];
}

export async function addPlayerListEntries(
  args: Auth & { list: string; entries: string[] },
): Promise<string[]> {
  const result = await callServerDetail<string[]>("add_player_list_entries", args, "players");
  return result.data ?? [];
}

export async function deletePlayerListEntries(
  args: Auth & { list: string; entries: string[] },
): Promise<string[]> {
  const result = await callServerDetail<string[]>("delete_player_list_entries", args, "players");
  return result.data ?? [];
}

export async function getServerLog(args: Auth): Promise<ServerLogData | null> {
  const result = await callServerDetail<ServerLogData>("get_server_log_info", args, "logs");
  return result.data ?? null;
}

export async function shareServerLog(args: Auth): Promise<SharedLogData | null> {
  const result = await callServerDetail<SharedLogData>("share_server_log_info", args, "logs");
  return result.data ?? null;
}

export async function getServerMotd(args: Auth): Promise<ServerMotdData | null> {
  const result = await callServerDetail<ServerMotdData>("get_server_motd_option", args, "options");
  return result.data ?? null;
}

export async function updateServerMotd(
  args: Auth & { motd: string },
): Promise<ServerMotdData | null> {
  const result = await callServerDetail<ServerMotdData>(
    "update_server_motd_option",
    args,
    "options",
  );
  return result.data ?? null;
}

export async function getServerRam(args: Auth): Promise<ServerRamData | null> {
  const result = await callServerDetail<ServerRamData>("get_server_ram_option", args, "options");
  return result.data ?? null;
}

export async function updateServerRam(args: Auth & { ram: number }): Promise<ServerRamData | null> {
  const result = await callServerDetail<ServerRamData>("update_server_ram_option", args, "options");
  return result.data ?? null;
}
