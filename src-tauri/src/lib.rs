mod exaton_api_lib;

use exaton_api_lib::websocket::WsState;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_os::init())
        .plugin(tauri_plugin_opener::init())
        .plugin(tauri_plugin_store::Builder::default().build())
        .manage(WsState::default())
        .invoke_handler(tauri::generate_handler![
            exaton_api_lib::accounts::get_acc_info,
            exaton_api_lib::accounts::save_token,
            exaton_api_lib::accounts::get_token,
            exaton_api_lib::accounts::delete_token,
            exaton_api_lib::servers::get_servers_info,
            exaton_api_lib::servers::get_server_info,
            exaton_api_lib::servers::start_server_action,
            exaton_api_lib::servers::stop_server_action,
            exaton_api_lib::servers::restart_server_action,
            exaton_api_lib::websocket::ws_connect,
            exaton_api_lib::websocket::ws_disconnect,
            exaton_api_lib::websocket::ws_subscribe,
            exaton_api_lib::websocket::ws_unsubscribe,
            exaton_api_lib::websocket::ws_send_command,
        ])
        .setup(|app| {
            if cfg!(debug_assertions) {
                app.handle().plugin(
                    tauri_plugin_log::Builder::default()
                        .level(log::LevelFilter::Info)
                        .build(),
                )?;
            }
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
