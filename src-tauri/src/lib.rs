mod exaton_api_lib;

use exaton_api_lib::websocket::WsState;
use tauri::Manager;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_os::init())
        .plugin(tauri_plugin_opener::init())
        .plugin(tauri_plugin_dialog::init())
        .plugin(tauri_plugin_store::Builder::default().build())
        .manage(WsState::default())
        .manage(exaton_api_lib::scheduler::Scheduler::new())
        .invoke_handler(tauri::generate_handler![
            exaton_api_lib::accounts::get_acc_info,
            exaton_api_lib::accounts::save_token,
            exaton_api_lib::accounts::get_token,
            exaton_api_lib::accounts::delete_token,
            exaton_api_lib::credit_pools::refresh_account_summary,
            exaton_api_lib::servers::get_servers_info,
            exaton_api_lib::servers::get_server_info,
            exaton_api_lib::servers::start_server_action,
            exaton_api_lib::servers::stop_server_action,
            exaton_api_lib::servers::restart_server_action,
            exaton_api_lib::servers::probe_api,
            exaton_api_lib::server_details::get_player_lists_info,
            exaton_api_lib::server_details::get_player_list_info,
            exaton_api_lib::server_details::add_player_list_entries,
            exaton_api_lib::server_details::delete_player_list_entries,
            exaton_api_lib::server_details::get_server_log_info,
            exaton_api_lib::server_details::share_server_log_info,
            exaton_api_lib::server_details::get_server_motd_option,
            exaton_api_lib::server_details::update_server_motd_option,
            exaton_api_lib::server_details::get_server_ram_option,
            exaton_api_lib::server_details::update_server_ram_option,
            exaton_api_lib::files::list_files,
            exaton_api_lib::files::read_file,
            exaton_api_lib::files::write_file,
            exaton_api_lib::files::delete_server_file,
            exaton_api_lib::files::upload_file,
            exaton_api_lib::files::download_file,
            exaton_api_lib::websocket::ws_connect,
            exaton_api_lib::websocket::ws_disconnect,
            exaton_api_lib::websocket::ws_subscribe,
            exaton_api_lib::websocket::ws_unsubscribe,
            exaton_api_lib::websocket::ws_send_command,
            exaton_api_lib::scheduler::list_schedules,
            exaton_api_lib::scheduler::create_schedule,
            exaton_api_lib::scheduler::update_schedule,
            exaton_api_lib::scheduler::delete_schedule,
            exaton_api_lib::scheduler::toggle_schedule,
        ])
        .setup(|app| {
            if cfg!(debug_assertions) {
                app.handle().plugin(
                    tauri_plugin_log::Builder::default()
                        .level(log::LevelFilter::Info)
                        .build(),
                )?;
            }

            let app_handle = app.handle().clone();
            tauri::async_runtime::spawn(async move {
                // Load schedules from persistent store
                let scheduler = app_handle.state::<exaton_api_lib::scheduler::Scheduler>();
                scheduler.load(&app_handle).await;

                // Spawn the daemon loop
                let sched_arc = scheduler.schedules.clone();
                exaton_api_lib::scheduler::spawn_daemon(sched_arc, app_handle.clone());

                // Start server init last
                if let Err(e) = exaton_api_lib::servers::init().await {
                    log::error!("servers init failed: {e}");
                }
            });

            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
