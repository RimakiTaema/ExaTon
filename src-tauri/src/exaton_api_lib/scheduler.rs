use openapi::apis::server_actions_api::{
    get_start_server, post_server_command, restart_server, stop_server,
};
use openapi::models::{PostServerCommandRequestBody, ServerStatus};
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use tauri::AppHandle;
use tauri_plugin_store::StoreExt;
use tokio::sync::Mutex;
use tokio::time::{interval, Duration};

use crate::exaton_api_lib::keychain;
use crate::exaton_api_lib::token_convert::make_config;
use chrono::Datelike;
use chrono::Timelike;

// ── Models ──────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScheduleTask {
    pub id: String,
    pub sequence_id: u32,
    /// "command" | "start" | "stop" | "restart"
    pub action: String,
    /// Command text when action is "command"
    pub payload: Option<String>,
    /// Seconds to wait after the previous task starts
    pub time_offset: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Schedule {
    pub id: String,
    pub name: String,
    pub email: String,
    pub server_id: String,
    pub cron_minute: String,
    pub cron_hour: String,
    pub cron_day_of_month: String,
    pub cron_month: String,
    pub cron_day_of_week: String,
    pub only_when_online: bool,
    pub only_one_task: bool,
    pub continue_on_failure: bool,
    pub tasks: Vec<ScheduleTask>,
    pub enabled: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub is_processing: Option<bool>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub last_run_at: Option<i64>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub last_run_status: Option<String>,
}

// ── Cron matching ───────────────────────────────────────────────────────

fn cron_field_matches(field: &str, value: u32) -> bool {
    if field == "*" {
        return true;
    }
    for part in field.split(',') {
        let trimmed = part.trim();
        if let Ok(n) = trimmed.parse::<u32>() {
            if n == value {
                return true;
            }
        }
        // Support "*/n" step syntax
        if let Some(step_str) = trimmed.strip_prefix("*/") {
            if let Ok(step) = step_str.parse::<u32>() {
                if step > 0 && value % step == 0 {
                    return true;
                }
            }
        }
        // Support "n-m" range syntax
        if let Some((lo, hi)) = trimmed.split_once('-') {
            if let (Ok(l), Ok(h)) = (lo.trim().parse::<u32>(), hi.trim().parse::<u32>()) {
                if value >= l && value <= h {
                    return true;
                }
            }
        }
    }
    false
}

fn cron_matches(s: &Schedule, now: &chrono::DateTime<chrono::Local>) -> bool {
    let dow = now.weekday().num_days_from_sunday(); // 0=Sun
    cron_field_matches(&s.cron_minute, now.minute())
        && cron_field_matches(&s.cron_hour, now.hour())
        && cron_field_matches(&s.cron_day_of_month, now.day())
        && cron_field_matches(&s.cron_month, now.month())
        && cron_field_matches(&s.cron_day_of_week, dow)
}

// ── Storage ─────────────────────────────────────────────────────────────

const STORE_FILE: &str = "schedules.json";

pub struct Scheduler {
    pub schedules: Arc<Mutex<Vec<Schedule>>>,
}

impl Scheduler {
    pub fn new() -> Self {
        Self {
            schedules: Arc::new(Mutex::new(Vec::new())),
        }
    }

    pub async fn load(&self, app: &AppHandle) {
        let store = match app.store(STORE_FILE) {
            Ok(s) => s,
            Err(e) => {
                log::error!("scheduler: failed to open store: {e}");
                return;
            }
        };
        let raw = store.get("schedules");
        let loaded: Vec<Schedule> = match raw {
            Some(val) => serde_json::from_value(val.clone()).unwrap_or_default(),
            None => Vec::new(),
        };
        let mut schedules = self.schedules.lock().await;
        *schedules = loaded;
        for s in schedules.iter_mut() {
            s.is_processing = Some(false);
        }
        log::info!("scheduler: loaded {} schedule(s)", schedules.len());
    }

    pub async fn save(&self, app: &AppHandle) {
        let store = match app.store(STORE_FILE) {
            Ok(s) => s,
            Err(e) => {
                log::error!("scheduler: failed to open store for save: {e}");
                return;
            }
        };
        let schedules = self.schedules.lock().await;
        let val = serde_json::to_value(&*schedules).unwrap_or_default();
        let _ = store.set("schedules", val);
        if let Err(e) = store.save() {
            log::error!("scheduler: store save failed: {e}");
        }
    }
}

// ── Daemon ──────────────────────────────────────────────────────────────

pub fn spawn_daemon(schedules: Arc<Mutex<Vec<Schedule>>>, app: AppHandle) {
    tauri::async_runtime::spawn(async move {
        log::info!("scheduler: daemon started");
        let mut tick = interval(Duration::from_secs(30));

        // Track which (schedule, minute) we've already fired to avoid double-execution
        let mut fired: Vec<(String, i64)> = Vec::new();

        loop {
            tick.tick().await;
            let now = chrono::Local::now();
            let minute_key = now.format("%Y%m%d%H%M").to_string().parse::<i64>().unwrap_or(0);

            let mut to_execute: Vec<(usize, Schedule)> = Vec::new();
            {
                let guard = schedules.lock().await;
                for (i, s) in guard.iter().enumerate() {
                    if !s.enabled {
                        continue;
                    }
                    if s.is_processing.unwrap_or(false) && s.only_one_task {
                        continue;
                    }
                    // Already fired for this minute?
                    let fk = (s.id.clone(), minute_key);
                    if fired.contains(&fk) {
                        continue;
                    }
                    if cron_matches(s, &now) {
                        // Check "only when online"
                        if s.only_when_online {
                            match check_online(&app, &s.email, &s.server_id).await {
                                Ok(true) => {}
                                Ok(false) => continue,
                                Err(e) => {
                                    log::error!("scheduler: online check failed: {e}");
                                    continue;
                                }
                            }
                        }
                        fired.push(fk.clone());
                        to_execute.push((i, s.clone()));
                    }
                }
            }

            // Spawn each schedule's execution in parallel so long time_offsets
            // don't block other schedules from starting.
            let fire_time = now.timestamp_millis();
            for (idx, mut schedule) in to_execute {
                let schedules = schedules.clone();
                tauri::async_runtime::spawn(async move {
                    // Mark as processing
                    {
                        let mut guard = schedules.lock().await;
                        if let Some(s) = guard.get_mut(idx) {
                            s.is_processing = Some(true);
                        }
                    }

                    let result = execute_schedule(&schedule).await;

                    // Update status
                    {
                        let mut guard = schedules.lock().await;
                        if let Some(s) = guard.get_mut(idx) {
                            s.is_processing = Some(false);
                            s.last_run_at = Some(fire_time);
                            s.last_run_status = Some(if result.is_ok() {
                                "success".into()
                            } else {
                                "failure".into()
                            });
                        }
                    }
                });
            }

            // Prune old fired entries (keep last 100 per schedule)
            if fired.len() > 1000 {
                fired.drain(0..fired.len().saturating_sub(500));
            }
        }
    });
}

async fn check_online(app: &AppHandle, email: &str, server_id: &str) -> Result<bool, String> {
    let token = keychain::get_token(email)?;
    let config = make_config(&token);
    let resp = openapi::apis::servers_api::get_server(&config, server_id)
        .await
        .map_err(|e| e.to_string())?;
    let status = resp
        .data
        .and_then(|s| s.status)
        .unwrap_or(ServerStatus::OFFLINE);
    Ok(status == ServerStatus::ONLINE)
}

async fn execute_schedule(schedule: &Schedule) -> Result<(), String> {
    let token = keychain::get_token(&schedule.email)?;
    let config = make_config(&token);

    let mut tasks = schedule.tasks.clone();
    tasks.sort_by_key(|t| t.sequence_id);

    for task in &tasks {
        // Wait for time offset (skip for first task if offset is 0)
        if task.time_offset > 0 {
            tokio::time::sleep(Duration::from_secs(task.time_offset as u64)).await;
        }

        let task_result = match task.action.as_str() {
            "command" => {
                let cmd = task.payload.as_deref().unwrap_or("");
                log::info!(
                    "scheduler: sending command to server {}: {cmd}",
                    schedule.server_id
                );
                let body = PostServerCommandRequestBody {
                    command: Some(cmd.to_string()),
                };
                post_server_command(&config, &schedule.server_id, Some(body))
                    .await
                    .map_err(|e| e.to_string())?;
                Ok(())
            }
            "start" => {
                log::info!("scheduler: starting server {}", schedule.server_id);
                get_start_server(&config, &schedule.server_id)
                    .await
                    .map_err(|e| e.to_string())?;
                Ok(())
            }
            "stop" => {
                log::info!("scheduler: stopping server {}", schedule.server_id);
                stop_server(&config, &schedule.server_id)
                    .await
                    .map_err(|e| e.to_string())?;
                Ok(())
            }
            "restart" => {
                log::info!("scheduler: restarting server {}", schedule.server_id);
                restart_server(&config, &schedule.server_id)
                    .await
                    .map_err(|e| e.to_string())?;
                Ok(())
            }
            other => Err(format!("unknown action: {other}")),
        };

        if task_result.is_err() && !schedule.continue_on_failure {
            return task_result;
        }
    }

    Ok(())
}

// ── Tauri commands ──────────────────────────────────────────────────────

#[tauri::command]
pub async fn list_schedules(
    state: tauri::State<'_, Scheduler>,
) -> Result<Vec<Schedule>, String> {
    let guard = state.schedules.lock().await;
    Ok(guard.clone())
}

#[tauri::command]
pub async fn create_schedule(
    app: AppHandle,
    state: tauri::State<'_, Scheduler>,
    name: String,
    email: String,
    server_id: String,
    cron_minute: String,
    cron_hour: String,
    cron_day_of_month: String,
    cron_month: String,
    cron_day_of_week: String,
    only_when_online: bool,
    only_one_task: bool,
    continue_on_failure: bool,
    tasks: Vec<ScheduleTask>,
) -> Result<Schedule, String> {
    if name.trim().is_empty() {
        return Err("Schedule name is required".into());
    }

    let schedule = Schedule {
        id: format!("sch_{}", chrono::Utc::now().timestamp_millis()),
        name,
        email,
        server_id,
        cron_minute: if cron_minute.is_empty() { "*".into() } else { cron_minute },
        cron_hour: if cron_hour.is_empty() { "*".into() } else { cron_hour },
        cron_day_of_month: if cron_day_of_month.is_empty() { "*".into() } else { cron_day_of_month },
        cron_month: if cron_month.is_empty() { "*".into() } else { cron_month },
        cron_day_of_week: if cron_day_of_week.is_empty() { "*".into() } else { cron_day_of_week },
        only_when_online,
        only_one_task,
        continue_on_failure,
        tasks,
        enabled: true,
        is_processing: Some(false),
        last_run_at: None,
        last_run_status: None,
    };

    {
        let mut guard = state.schedules.lock().await;
        guard.push(schedule.clone());
    }
    state.save(&app).await;
    log::info!("scheduler: created schedule {}", schedule.id);
    Ok(schedule)
}

#[tauri::command]
pub async fn update_schedule(
    app: AppHandle,
    state: tauri::State<'_, Scheduler>,
    id: String,
    name: String,
    cron_minute: String,
    cron_hour: String,
    cron_day_of_month: String,
    cron_month: String,
    cron_day_of_week: String,
    only_when_online: bool,
    only_one_task: bool,
    continue_on_failure: bool,
    tasks: Vec<ScheduleTask>,
) -> Result<Schedule, String> {
    if name.trim().is_empty() {
        return Err("Schedule name is required".into());
    }

    let updated = {
        let mut guard = state.schedules.lock().await;
        let existing = guard
            .iter_mut()
            .find(|s| s.id == id)
            .ok_or_else(|| "Schedule not found".to_string())?;

        existing.name = name;
        existing.cron_minute = if cron_minute.is_empty() { "*".into() } else { cron_minute };
        existing.cron_hour = if cron_hour.is_empty() { "*".into() } else { cron_hour };
        existing.cron_day_of_month = if cron_day_of_month.is_empty() { "*".into() } else { cron_day_of_month };
        existing.cron_month = if cron_month.is_empty() { "*".into() } else { cron_month };
        existing.cron_day_of_week = if cron_day_of_week.is_empty() { "*".into() } else { cron_day_of_week };
        existing.only_when_online = only_when_online;
        existing.only_one_task = only_one_task;
        existing.continue_on_failure = continue_on_failure;
        existing.tasks = tasks;

        existing.clone()
    };

    state.save(&app).await;
    log::info!("scheduler: updated schedule {id}");
    Ok(updated)
}

#[tauri::command]
pub async fn delete_schedule(
    app: AppHandle,
    state: tauri::State<'_, Scheduler>,
    id: String,
) -> Result<(), String> {
    {
        let mut guard = state.schedules.lock().await;
        guard.retain(|s| s.id != id);
    }
    state.save(&app).await;
    log::info!("scheduler: deleted schedule {id}");
    Ok(())
}

#[tauri::command]
pub async fn toggle_schedule(
    app: AppHandle,
    state: tauri::State<'_, Scheduler>,
    id: String,
    enabled: bool,
) -> Result<(), String> {
    {
        let mut guard = state.schedules.lock().await;
        if let Some(s) = guard.iter_mut().find(|s| s.id == id) {
            s.enabled = enabled;
        }
    }
    state.save(&app).await;
    log::info!("scheduler: toggled schedule {id} -> {enabled}");
    Ok(())
}
