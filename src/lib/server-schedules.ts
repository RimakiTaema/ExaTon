import { invoke } from "@tauri-apps/api/core";

export type ScheduleTask = {
  id: string;
  sequence_id: number;
  action: string;
  payload: string | null;
  time_offset: number;
};

export type Schedule = {
  id: string;
  name: string;
  email: string;
  server_id: string;
  cron_minute: string;
  cron_hour: string;
  cron_day_of_month: string;
  cron_month: string;
  cron_day_of_week: string;
  only_when_online: boolean;
  only_one_task: boolean;
  continue_on_failure: boolean;
  tasks: ScheduleTask[];
  enabled: boolean;
  is_processing: boolean | null;
  last_run_at: number | null;
  last_run_status: string | null;
};

export function scheduleCronPretty(s: Schedule): string {
  const parts = [s.cron_minute, s.cron_hour, s.cron_day_of_month, s.cron_month, s.cron_day_of_week];
  return parts.join(" ");
}

export function lastRunLabel(s: Schedule): string {
  if (!s.last_run_at) return "Never";
  const d = new Date(s.last_run_at);
  return d.toLocaleString();
}

export async function listSchedules(): Promise<Schedule[]> {
  return await invoke<Schedule[]>("list_schedules");
}

export async function createSchedule(
  name: string,
  email: string,
  serverId: string,
  cronMinute: string,
  cronHour: string,
  cronDayOfMonth: string,
  cronMonth: string,
  cronDayOfWeek: string,
  onlyWhenOnline: boolean,
  onlyOneTask: boolean,
  continueOnFailure: boolean,
  tasks: ScheduleTask[],
): Promise<Schedule> {
  return await invoke<Schedule>("create_schedule", {
    name,
    email,
    serverId,
    cronMinute,
    cronHour,
    cronDayOfMonth,
    cronMonth,
    cronDayOfWeek,
    onlyWhenOnline,
    onlyOneTask,
    continueOnFailure,
    tasks,
  });
}

export async function updateSchedule(
  id: string,
  name: string,
  cronMinute: string,
  cronHour: string,
  cronDayOfMonth: string,
  cronMonth: string,
  cronDayOfWeek: string,
  onlyWhenOnline: boolean,
  onlyOneTask: boolean,
  continueOnFailure: boolean,
  tasks: ScheduleTask[],
): Promise<Schedule> {
  return await invoke<Schedule>("update_schedule", {
    id,
    name,
    cronMinute,
    cronHour,
    cronDayOfMonth,
    cronMonth,
    cronDayOfWeek,
    onlyWhenOnline,
    onlyOneTask,
    continueOnFailure,
    tasks,
  });
}

export async function deleteSchedule(id: string): Promise<void> {
  await invoke("delete_schedule", { id });
}

export async function toggleSchedule(id: string, enabled: boolean): Promise<void> {
  await invoke("toggle_schedule", { id, enabled });
}
