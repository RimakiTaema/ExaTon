export type CommandPreset = {
  id: string;
  label: string;
  command: string;
};

const STORAGE_KEY = "exaton_console_presets";
const CHANGE_EVENT = "exaton_console_presets_changed";

export const BUILT_IN_PRESETS: CommandPreset[] = [
  { id: "_builtin_list", label: "List", command: "list" },
  { id: "_builtin_saveall", label: "Save-all", command: "save-all" },
  { id: "_builtin_time", label: "Time day", command: "time set day" },
  { id: "_builtin_tps", label: "TPS", command: "tps" },
];

function isBuiltIn(id: string): boolean {
  return id.startsWith("_builtin_");
}

export function loadPresets(): CommandPreset[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return [];
    const parsed = JSON.parse(raw) as CommandPreset[];
    return parsed.filter((p) => p.id && p.label && p.command);
  } catch {
    return [];
  }
}

export function savePresets(presets: CommandPreset[]): void {
  const custom = presets.filter((p) => !isBuiltIn(p.id));
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(custom));
    window.dispatchEvent(new CustomEvent(CHANGE_EVENT));
  } catch {
    /* non-fatal */
  }
}

export function getAllPresets(): CommandPreset[] {
  return [...BUILT_IN_PRESETS, ...loadPresets()];
}

export function addPreset(label: string, command: string): CommandPreset {
  const preset: CommandPreset = {
    id: `preset_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`,
    label,
    command,
  };
  const presets = loadPresets();
  presets.push(preset);
  savePresets(presets);
  return preset;
}

export function removePreset(id: string): void {
  if (isBuiltIn(id)) return;
  const presets = loadPresets().filter((p) => p.id !== id);
  savePresets(presets);
}

export function updatePreset(id: string, label: string, command: string): void {
  if (isBuiltIn(id)) return;
  const presets = loadPresets().map((p) => (p.id === id ? { ...p, label, command } : p));
  savePresets(presets);
}
