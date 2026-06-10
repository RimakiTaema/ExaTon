import { invoke } from "@tauri-apps/api/core";
import { recordDebugEvent } from "@/lib/debug-log";

export type FileInfo = {
  path?: string;
  name?: string;
  isTextFile?: boolean;
  isConfigFile?: boolean;
  isDirectory?: boolean;
  isLog?: boolean;
  isReadable?: boolean;
  isWritable?: boolean;
  size?: number;
  children?: FileInfo[] | null;
};

export type FileInfoResponse = {
  success?: boolean;
  error?: string | null;
  data?: FileInfo;
};

type Auth = { email: string; serverid: string };

function debugArgs(args: Record<string, unknown>) {
  if (!("content" in args)) return args;
  const content = args.content;
  return {
    ...args,
    content: undefined,
    contentBytes: Array.isArray(content) ? content.length : undefined,
  };
}

async function invokeFile<T>(command: string, args: Record<string, unknown>): Promise<T> {
  const started = Date.now();
  recordDebugEvent({ scope: "files", message: `${command} started`, detail: debugArgs(args) });
  try {
    const result = await invoke<T>(command, args);
    recordDebugEvent({
      scope: "files",
      message: `${command} succeeded`,
      detail: { elapsedMs: Date.now() - started },
    });
    return result;
  } catch (error) {
    recordDebugEvent({
      level: "error",
      scope: "files",
      message: `${command} failed`,
      detail: error,
    });
    throw error;
  }
}

export async function listFiles({
  email,
  serverid,
  path,
}: Auth & { path: string }): Promise<FileInfo | undefined> {
  const res = await invokeFile<FileInfoResponse>("list_files", { email, serverid, path });
  return res.data;
}

export async function readFile({
  email,
  serverid,
  path,
}: Auth & { path: string }): Promise<Uint8Array> {
  const bytes = await invokeFile<number[]>("read_file", { email, serverid, path });
  return new Uint8Array(bytes);
}

export async function readFileText(args: Auth & { path: string }): Promise<string> {
  const bytes = await readFile(args);
  return new TextDecoder().decode(bytes);
}

export async function writeFile({
  email,
  serverid,
  path,
  content,
}: Auth & { path: string; content: Uint8Array }): Promise<void> {
  await invokeFile("write_file", { email, serverid, path, content: Array.from(content) });
}

export async function writeFileText(args: Auth & { path: string; text: string }): Promise<void> {
  const bytes = new TextEncoder().encode(args.text);
  await writeFile({ email: args.email, serverid: args.serverid, path: args.path, content: bytes });
}

export async function deleteServerFile({
  email,
  serverid,
  path,
}: Auth & { path: string }): Promise<void> {
  await invokeFile("delete_server_file", { email, serverid, path });
}

export async function uploadFile({
  email,
  serverid,
  remotePath,
  localPath,
}: Auth & { remotePath: string; localPath: string }): Promise<void> {
  await invokeFile("upload_file", { email, serverid, remotePath, localPath });
}

export async function downloadFile({
  email,
  serverid,
  remotePath,
  savePath,
}: Auth & { remotePath: string; savePath: string }): Promise<void> {
  await invokeFile("download_file", { email, serverid, remotePath, savePath });
}
