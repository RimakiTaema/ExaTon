import { invoke } from "@tauri-apps/api/core";

export type ProbeArgs = {
  email?: string;
  serverid?: string;
  path?: string;
};

export async function probeApi(args: ProbeArgs = {}): Promise<void> {
  await invoke("probe_api", args);
}
