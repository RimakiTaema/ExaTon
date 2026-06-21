"use client";

import { CheckIcon, PencilSimpleLineIcon, PlusIcon, TrashIcon, XIcon } from "@phosphor-icons/react";
import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  addPreset,
  BUILT_IN_PRESETS,
  type CommandPreset,
  getAllPresets,
  removePreset,
  updatePreset,
} from "@/lib/console-presets";

type Props = {
  open: boolean;
  onClose: () => void;
};

export function ConsolePresetsManager({ open, onClose }: Props) {
  const [presets, setPresets] = useState<CommandPreset[]>([]);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editLabel, setEditLabel] = useState("");
  const [editCommand, setEditCommand] = useState("");
  const [adding, setAdding] = useState(false);
  const [newLabel, setNewLabel] = useState("");
  const [newCommand, setNewCommand] = useState("");

  useEffect(() => {
    if (open) setPresets(getAllPresets());
  }, [open]);

  if (!open) return null;

  const handleAdd = () => {
    const label = newLabel.trim();
    const command = newCommand.trim();
    if (!label || !command) return;
    addPreset(label, command);
    setPresets(getAllPresets());
    setNewLabel("");
    setNewCommand("");
    setAdding(false);
  };

  const handleEdit = (id: string) => {
    const preset = presets.find((p) => p.id === id);
    if (!preset) return;
    setEditingId(id);
    setEditLabel(preset.label);
    setEditCommand(preset.command);
  };

  const handleSaveEdit = (id: string) => {
    const label = editLabel.trim();
    const command = editCommand.trim();
    if (!label || !command) return;
    updatePreset(id, label, command);
    setPresets(getAllPresets());
    setEditingId(null);
  };

  const handleDelete = (id: string) => {
    removePreset(id);
    setPresets(getAllPresets());
  };

  const builtInIds = new Set(BUILT_IN_PRESETS.map((p) => p.id));

  return (
    <div className="fixed inset-0 bg-black/60 backdrop-blur-xs flex items-center justify-center z-50 animate-in fade-in duration-200">
      <div className="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-xl p-5 shadow-2xl max-w-lg w-full mx-4 flex flex-col gap-4 animate-in zoom-in-95 duration-200 max-h-[80vh]">
        <div className="flex items-center justify-between">
          <h3 className="text-base font-semibold text-zinc-900 dark:text-zinc-50">
            Command Presets
          </h3>
          <button
            type="button"
            onClick={onClose}
            className="rounded-md p-1 text-zinc-400 hover:text-zinc-600 hover:bg-zinc-100 dark:hover:bg-zinc-800 transition-colors"
          >
            <XIcon size={18} />
          </button>
        </div>

        <div className="flex-1 overflow-y-auto flex flex-col gap-1.5 min-h-0">
          {presets.length === 0 && (
            <p className="text-sm text-muted-foreground text-center py-8">
              No custom presets yet. Add one below.
            </p>
          )}
          {presets.map((preset) => {
            const isBuiltIn = builtInIds.has(preset.id);
            const isEditing = editingId === preset.id;

            return (
              <div
                key={preset.id}
                className={`rounded-lg border px-3 py-2.5 flex items-center gap-2 ${
                  isBuiltIn ? "bg-muted/30 border-dashed" : "bg-card"
                }`}
              >
                {isEditing ? (
                  <div className="flex-1 flex flex-col gap-1.5">
                    <Input
                      value={editLabel}
                      onChange={(e) => setEditLabel(e.target.value)}
                      placeholder="Label"
                      className="h-7 text-xs"
                    />
                    <Input
                      value={editCommand}
                      onChange={(e) => setEditCommand(e.target.value)}
                      placeholder="Command"
                      className="h-7 text-xs font-mono"
                    />
                    <div className="flex items-center gap-1.5 mt-0.5">
                      <Button
                        size="sm"
                        className="h-6 text-xs px-2"
                        onClick={() => handleSaveEdit(preset.id)}
                        disabled={!editLabel.trim() || !editCommand.trim()}
                      >
                        <CheckIcon size={12} />
                        Save
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        className="h-6 text-xs px-2"
                        onClick={() => setEditingId(null)}
                      >
                        Cancel
                      </Button>
                    </div>
                  </div>
                ) : (
                  <>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium truncate">{preset.label}</p>
                      <p className="text-[11px] font-mono text-muted-foreground truncate">
                        /{preset.command}
                      </p>
                    </div>
                    <div className="flex items-center gap-1 shrink-0">
                      {!isBuiltIn && (
                        <>
                          <button
                            type="button"
                            onClick={() => handleEdit(preset.id)}
                            className="rounded p-1 text-zinc-400 hover:text-zinc-600 hover:bg-zinc-100 dark:hover:bg-zinc-800 transition-colors"
                            title="Edit"
                          >
                            <PencilSimpleLineIcon size={14} />
                          </button>
                          <button
                            type="button"
                            onClick={() => handleDelete(preset.id)}
                            className="rounded p-1 text-zinc-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-950/30 transition-colors"
                            title="Delete"
                          >
                            <TrashIcon size={14} />
                          </button>
                        </>
                      )}
                      {isBuiltIn && (
                        <span className="text-[10px] text-muted-foreground italic">built-in</span>
                      )}
                    </div>
                  </>
                )}
              </div>
            );
          })}
        </div>

        {adding ? (
          <div className="rounded-lg border border-dashed p-3 flex flex-col gap-2">
            <Input
              value={newLabel}
              onChange={(e) => setNewLabel(e.target.value)}
              placeholder="Preset label (e.g. 'Whitelist add')"
              className="h-7 text-xs"
              autoFocus
            />
            <Input
              value={newCommand}
              onChange={(e) => setNewCommand(e.target.value)}
              placeholder="Command (e.g. 'whitelist add {player}')"
              className="h-7 text-xs font-mono"
            />
            <p className="text-[10px] text-muted-foreground">
              Use <code className="text-zinc-600 dark:text-zinc-400">{`{player}`}</code> as a
              placeholder — you'll be prompted for the value when executing.
            </p>
            <div className="flex items-center gap-1.5">
              <Button
                size="sm"
                className="h-7 text-xs"
                onClick={handleAdd}
                disabled={!newLabel.trim() || !newCommand.trim()}
              >
                <CheckIcon size={12} />
                Add
              </Button>
              <Button
                variant="ghost"
                size="sm"
                className="h-7 text-xs"
                onClick={() => {
                  setAdding(false);
                  setNewLabel("");
                  setNewCommand("");
                }}
              >
                Cancel
              </Button>
            </div>
          </div>
        ) : (
          <Button variant="outline" size="sm" onClick={() => setAdding(true)} className="gap-1.5">
            <PlusIcon size={14} />
            Add Preset
          </Button>
        )}
      </div>
    </div>
  );
}
