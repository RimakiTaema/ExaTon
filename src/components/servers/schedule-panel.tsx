"use client";

import {
  CaretDown,
  CaretRight,
  Clock,
  PencilSimpleLine,
  Plus,
  Trash,
  WarningCircle,
} from "@phosphor-icons/react";
import { useCallback, useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Skeleton } from "@/components/ui/skeleton";
import {
  createSchedule,
  deleteSchedule,
  lastRunLabel,
  listSchedules,
  type Schedule,
  type ScheduleTask,
  scheduleCronPretty,
  toggleSchedule,
  updateSchedule,
} from "@/lib/server-schedules";

type Props = {
  email: string;
  serverid: string;
};

type ActionOption = "command" | "start" | "stop" | "restart";
const ACTION_LABELS: Record<ActionOption, string> = {
  command: "Send command",
  start: "Start server",
  stop: "Stop server",
  restart: "Restart server",
};

// ── Helpers ─────────────────────────────────────────────────────────────

function makeTaskId(): string {
  return `tsk_${Date.now()}_${Math.random().toString(36).slice(2, 6)}`;
}

function emptyTask(seq: number): ScheduleTask {
  return {
    id: makeTaskId(),
    sequence_id: seq,
    action: "command",
    payload: "",
    time_offset: 0,
  };
}

function blankSchedule(email: string, serverId: string): Schedule {
  return {
    id: "",
    name: "",
    email,
    server_id: serverId,
    cron_minute: "*",
    cron_hour: "*",
    cron_day_of_month: "*",
    cron_month: "*",
    cron_day_of_week: "*",
    only_when_online: false,
    only_one_task: false,
    continue_on_failure: false,
    tasks: [emptyTask(1)],
    enabled: true,
    is_processing: null,
    last_run_at: null,
    last_run_status: null,
  };
}

// ── Component ───────────────────────────────────────────────────────────

export function SchedulePanel({ email, serverid }: Props) {
  const [schedules, setSchedules] = useState<Schedule[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);

  // Create/edit form state
  const [creating, setCreating] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [draft, setDraft] = useState<Schedule>(blankSchedule(email, serverid));
  const [saving, setSaving] = useState(false);
  const [expandedId, setExpandedId] = useState<string | null>(null);

  const refresh = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const all = await listSchedules();
      setSchedules(all.filter((s) => s.server_id === serverid));
    } catch (e) {
      setError(String(e));
    } finally {
      setLoading(false);
    }
  }, [serverid]);

  useEffect(() => {
    refresh();
  }, [refresh]);

  // ── Draft helpers ──

  function setCron(field: keyof Schedule, value: string) {
    setDraft((prev) => ({ ...prev, [field]: value }));
  }

  function setDraftBool(field: keyof Schedule, value: boolean) {
    setDraft((prev) => ({ ...prev, [field]: value }));
  }

  function updateTask(taskId: string, patch: Partial<ScheduleTask>) {
    setDraft((prev) => ({
      ...prev,
      tasks: prev.tasks.map((t) => (t.id === taskId ? { ...t, ...patch } : t)),
    }));
  }

  function removeTask(taskId: string) {
    setDraft((prev) => {
      const filtered = prev.tasks
        .filter((t) => t.id !== taskId)
        .map((t, i) => ({ ...t, sequence_id: i + 1 }));
      return { ...prev, tasks: filtered };
    });
  }

  function addTask() {
    setDraft((prev) => ({
      ...prev,
      tasks: [...prev.tasks, emptyTask(prev.tasks.length + 1)],
    }));
  }

  // ── Form lifecycle ──

  function startCreate() {
    setDraft(blankSchedule(email, serverid));
    setCreating(true);
    setEditingId(null);
    setError(null);
    setMessage(null);
  }

  function startEdit(s: Schedule) {
    setDraft({ ...s });
    setEditingId(s.id);
    setCreating(false);
    setExpandedId(s.id);
    setError(null);
    setMessage(null);
  }

  function cancelForm() {
    setCreating(false);
    setEditingId(null);
    setError(null);
  }

  // ── Save ──

  async function handleSave() {
    if (!draft.name.trim()) {
      setError("Schedule name is required");
      return;
    }
    setSaving(true);
    setError(null);
    setMessage(null);
    try {
      if (creating) {
        const created = await createSchedule(
          draft.name.trim(),
          draft.email,
          draft.server_id,
          draft.cron_minute,
          draft.cron_hour,
          draft.cron_day_of_month,
          draft.cron_month,
          draft.cron_day_of_week,
          draft.only_when_online,
          draft.only_one_task,
          draft.continue_on_failure,
          draft.tasks,
        );
        setMessage(`Schedule "${created.name}" created`);
        setCreating(false);
      } else if (editingId) {
        const updated = await updateSchedule(
          editingId,
          draft.name.trim(),
          draft.cron_minute,
          draft.cron_hour,
          draft.cron_day_of_month,
          draft.cron_month,
          draft.cron_day_of_week,
          draft.only_when_online,
          draft.only_one_task,
          draft.continue_on_failure,
          draft.tasks,
        );
        setMessage(`Schedule "${updated.name}" saved`);
        setEditingId(null);
      }
      await refresh();
    } catch (e) {
      setError(String(e));
    } finally {
      setSaving(false);
    }
  }

  async function handleToggle(s: Schedule) {
    try {
      await toggleSchedule(s.id, !s.enabled);
      await refresh();
    } catch (e) {
      setError(String(e));
    }
  }

  async function handleDelete(id: string) {
    try {
      await deleteSchedule(id);
      setMessage("Schedule deleted");
      if (expandedId === id) setExpandedId(null);
      if (editingId === id) setEditingId(null);
      await refresh();
    } catch (e) {
      setError(String(e));
    }
  }

  // ── Render ──

  if (loading) {
    return (
      <div className="flex flex-col gap-3">
        <Skeleton className="h-8 w-48 rounded-md" />
        <Skeleton className="h-32 rounded-md" />
        <Skeleton className="h-24 rounded-md" />
      </div>
    );
  }

  const isFormOpen = creating || editingId;

  return (
    <div className="flex max-w-3xl flex-col gap-4">
      {/* Warning banner */}
      <div className="flex items-start gap-2 rounded-md border border-red-500/40 bg-red-500/10 p-3">
        <WarningCircle size={18} className="mt-0.5 shrink-0 text-red-500" />
        <div className="text-xs text-red-400 leading-relaxed">
          <p className="font-semibold text-red-400">Important</p>
          <p>
            This scheduler requires your PC to stay on and the ExaTon app to be running. It is a
            temporary solution. For production use, we recommend an OS-native scheduler (cron / Task
            Scheduler) or a custom daemon.
          </p>
        </div>
      </div>

      {/* Header */}
      <div className="flex items-center justify-between">
        <p className="text-sm font-medium">Schedules</p>
        {!isFormOpen && (
          <Button size="sm" onClick={startCreate}>
            <Plus size={14} />
            Create Schedule
          </Button>
        )}
      </div>

      {error && <p className="text-sm text-red-600">{error}</p>}
      {message && <p className="text-sm text-emerald-700">{message}</p>}

      {/* Create/Edit form */}
      {isFormOpen && (
        <ScheduleForm
          draft={draft}
          saving={saving}
          isNew={creating}
          onCron={setCron}
          onBool={setDraftBool}
          onUpdateTask={updateTask}
          onRemoveTask={removeTask}
          onAddTask={addTask}
          onSave={handleSave}
          onCancel={cancelForm}
        />
      )}

      {/* Schedule list */}
      <div className="rounded-md border overflow-hidden">
        {schedules.length === 0 && !isFormOpen ? (
          <p className="text-xs text-muted-foreground px-3 py-4">
            No schedules yet. Create one above.
          </p>
        ) : (
          schedules.map((s) => {
            const isExpanded = expandedId === s.id;
            const isEditing = editingId === s.id;
            // Don't show in list while editing inline
            if (isEditing) return null;
            return (
              <div key={s.id}>
                {/* Schedule row */}
                <div className="group flex items-center gap-3 px-3 py-2.5 border-b last:border-b-0 hover:bg-muted/30">
                  <button
                    type="button"
                    onClick={() => setExpandedId(isExpanded ? null : s.id)}
                    className="shrink-0 text-muted-foreground hover:text-foreground"
                  >
                    {isExpanded ? <CaretDown size={12} /> : <CaretRight size={12} />}
                  </button>
                  <button
                    type="button"
                    onClick={() => handleToggle(s)}
                    className={`h-4 w-4 shrink-0 rounded border transition-colors ${
                      s.enabled
                        ? "bg-emerald-600 border-emerald-600"
                        : "bg-transparent border-muted-foreground/30"
                    }`}
                    aria-label={s.enabled ? "Disable" : "Enable"}
                  />
                  <div className="min-w-0 flex-1">
                    <p className="text-sm font-medium truncate">{s.name}</p>
                    <p className="text-[11px] text-muted-foreground font-mono">
                      {scheduleCronPretty(s)}
                    </p>
                  </div>
                  <div className="hidden sm:flex items-center gap-3 text-[11px] text-muted-foreground">
                    <span className="flex items-center gap-1">
                      <Clock size={11} />
                      {lastRunLabel(s)}
                    </span>
                    {s.is_processing && (
                      <span className="text-amber-500 font-medium">Processing</span>
                    )}
                    {s.last_run_status === "success" && (
                      <span className="text-emerald-600">OK</span>
                    )}
                    {s.last_run_status === "failure" && (
                      <span className="text-red-500">Failed</span>
                    )}
                  </div>
                  <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                    <Button
                      variant="ghost"
                      size="icon-xs"
                      onClick={() => startEdit(s)}
                      aria-label="Edit schedule"
                    >
                      <PencilSimpleLine size={12} />
                    </Button>
                    <Button
                      variant="ghost"
                      size="icon-xs"
                      onClick={() => handleDelete(s.id)}
                      aria-label="Delete schedule"
                    >
                      <Trash size={12} />
                    </Button>
                  </div>
                </div>
                {/* Expanded task list */}
                {isExpanded && (
                  <div className="border-t border-border/50 bg-muted/20 px-6 py-3">
                    <p className="text-[11px] font-medium text-muted-foreground mb-2">Tasks</p>
                    {s.tasks.length === 0 ? (
                      <p className="text-xs text-muted-foreground italic">No tasks</p>
                    ) : (
                      <div className="flex flex-col gap-2">
                        {s.tasks
                          .slice()
                          .sort((a, b) => a.sequence_id - b.sequence_id)
                          .map((t, i) => (
                            <div
                              key={t.id}
                              className="flex items-center gap-2 text-xs rounded bg-background px-2.5 py-1.5 border"
                            >
                              <span className="text-muted-foreground font-mono w-4">#{i + 1}</span>
                              <span className="font-medium w-24">
                                {ACTION_LABELS[t.action as ActionOption] || t.action}
                              </span>
                              {t.action === "command" && (
                                <span className="font-mono text-muted-foreground truncate flex-1">
                                  {t.payload || "—"}
                                </span>
                              )}
                              {t.time_offset > 0 && (
                                <span className="text-muted-foreground ml-auto">
                                  +{t.time_offset}s
                                </span>
                              )}
                            </div>
                          ))}
                      </div>
                    )}
                    <div className="flex items-center gap-3 mt-2 text-[11px] text-muted-foreground">
                      {s.only_when_online && <span>Only when online</span>}
                      {s.only_one_task && <span>One at a time</span>}
                      {s.continue_on_failure && <span>Continue on failure</span>}
                    </div>
                  </div>
                )}
              </div>
            );
          })
        )}
      </div>

      <p className="text-xs text-muted-foreground">
        The daemon checks every 30 seconds and runs once per minute per schedule.
      </p>
    </div>
  );
}

// ── Schedule Form (create / edit) ────────────────────────────────────────

type FormProps = {
  draft: Schedule;
  saving: boolean;
  isNew: boolean;
  onCron: (field: keyof Schedule, value: string) => void;
  onBool: (field: keyof Schedule, value: boolean) => void;
  onUpdateTask: (id: string, patch: Partial<ScheduleTask>) => void;
  onRemoveTask: (id: string) => void;
  onAddTask: () => void;
  onSave: () => void;
  onCancel: () => void;
};

function ScheduleForm({
  draft,
  saving,
  isNew,
  onCron,
  onBool,
  onUpdateTask,
  onRemoveTask,
  onAddTask,
  onSave,
  onCancel,
}: FormProps) {
  return (
    <div className="rounded-md border p-3 flex flex-col gap-3">
      <p className="text-sm font-medium">{isNew ? "Create Schedule" : "Edit Schedule"}</p>

      {/* Name */}
      <div className="flex flex-col gap-1">
        <p className="text-[11px] text-muted-foreground font-medium">Name</p>
        <Input
          value={draft.name}
          onChange={(e) => onCron("name", e.target.value)}
          className="h-8 text-sm"
          placeholder="e.g. Daily restart"
        />
      </div>

      {/* Cron fields */}
      <div className="grid grid-cols-5 gap-2">
        {(
          [
            "cron_minute",
            "cron_hour",
            "cron_day_of_month",
            "cron_month",
            "cron_day_of_week",
          ] as const
        ).map((field) => {
          const labels: Record<string, string> = {
            cron_minute: "Minute",
            cron_hour: "Hour",
            cron_day_of_month: "Day (Mo)",
            cron_month: "Month",
            cron_day_of_week: "Day (Wk)",
          };
          return (
            <div key={field} className="flex flex-col gap-1">
              <p className="text-[11px] text-muted-foreground font-medium">{labels[field]}</p>
              <Input
                value={draft[field] as string}
                onChange={(e) => onCron(field, e.target.value)}
                className="h-8 text-xs font-mono"
                placeholder="*"
              />
            </div>
          );
        })}
      </div>
      <p className="text-[10px] text-muted-foreground">
        Use * for any, numbers for exact, commas for multiple (e.g. "0,30"), */n for every n, or a-b
        for ranges.
      </p>

      {/* Flags */}
      <div className="flex flex-wrap gap-4">
        <label className="flex items-center gap-1.5 text-xs cursor-pointer">
          <input
            type="checkbox"
            checked={draft.only_when_online}
            onChange={(e) => onBool("only_when_online", e.target.checked)}
            className="accent-emerald-600"
          />
          Only when online
        </label>
        <label className="flex items-center gap-1.5 text-xs cursor-pointer">
          <input
            type="checkbox"
            checked={draft.only_one_task}
            onChange={(e) => onBool("only_one_task", e.target.checked)}
            className="accent-emerald-600"
          />
          One task at a time
        </label>
        <label className="flex items-center gap-1.5 text-xs cursor-pointer">
          <input
            type="checkbox"
            checked={draft.continue_on_failure}
            onChange={(e) => onBool("continue_on_failure", e.target.checked)}
            className="accent-emerald-600"
          />
          Continue on failure
        </label>
      </div>

      {/* Tasks */}
      <div>
        <div className="flex items-center justify-between mb-2">
          <p className="text-[11px] text-muted-foreground font-medium">Tasks</p>
          <Button variant="outline" size="icon-xs" onClick={onAddTask}>
            <Plus size={12} />
          </Button>
        </div>
        <div className="flex flex-col gap-2">
          {draft.tasks
            .slice()
            .sort((a, b) => a.sequence_id - b.sequence_id)
            .map((task, i) => (
              <TaskRow
                key={task.id}
                task={task}
                index={i}
                onUpdate={(patch) => onUpdateTask(task.id, patch)}
                onRemove={() => onRemoveTask(task.id)}
                disableRemove={draft.tasks.length <= 1}
              />
            ))}
        </div>
      </div>

      {/* Actions */}
      <div className="flex items-center gap-2 justify-end">
        <Button variant="outline" size="sm" onClick={onCancel}>
          Cancel
        </Button>
        <Button size="sm" onClick={onSave} disabled={saving}>
          {saving ? "Saving..." : isNew ? "Create" : "Save"}
        </Button>
      </div>
    </div>
  );
}

// ── Task Row ─────────────────────────────────────────────────────────────

type TaskRowProps = {
  task: ScheduleTask;
  index: number;
  onUpdate: (patch: Partial<ScheduleTask>) => void;
  onRemove: () => void;
  disableRemove: boolean;
};

const ACTION_OPTIONS: ActionOption[] = ["command", "start", "stop", "restart"];

function TaskRow({ task, index, onUpdate, onRemove, disableRemove }: TaskRowProps) {
  return (
    <div className="flex items-start gap-2 rounded border bg-background p-2">
      <span className="text-xs text-muted-foreground font-mono mt-1.5 w-4 shrink-0">
        #{index + 1}
      </span>
      <div className="flex flex-1 flex-wrap items-end gap-2">
        <div className="flex flex-col gap-0.5">
          <p className="text-[10px] text-muted-foreground">Action</p>
          <select
            value={task.action}
            onChange={(e) => onUpdate({ action: e.target.value as ActionOption })}
            className="h-7 rounded border border-input bg-transparent px-1.5 text-xs outline-none focus-visible:ring-1 focus-visible:ring-ring"
          >
            {ACTION_OPTIONS.map((a) => (
              <option key={a} value={a}>
                {ACTION_LABELS[a]}
              </option>
            ))}
          </select>
        </div>
        {task.action === "command" && (
          <div className="flex flex-col gap-0.5 flex-1 min-w-[120px]">
            <p className="text-[10px] text-muted-foreground">Command</p>
            <Input
              value={task.payload ?? ""}
              onChange={(e) => onUpdate({ payload: e.target.value })}
              className="h-7 text-xs font-mono"
              placeholder="say Hello"
            />
          </div>
        )}
        <div className="flex flex-col gap-0.5 w-20">
          <p className="text-[10px] text-muted-foreground">Delay (s)</p>
          <Input
            type="number"
            min={0}
            value={task.time_offset}
            onChange={(e) => onUpdate({ time_offset: Math.max(0, Number(e.target.value)) })}
            className="h-7 text-xs"
          />
        </div>
        <button
          type="button"
          onClick={onRemove}
          disabled={disableRemove}
          className="mt-1.5 text-muted-foreground hover:text-red-500 disabled:opacity-30 disabled:cursor-not-allowed"
          aria-label="Remove task"
        >
          <Trash size={13} />
        </button>
      </div>
    </div>
  );
}
