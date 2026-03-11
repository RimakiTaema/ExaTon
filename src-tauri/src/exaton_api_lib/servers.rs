use openapi::apis::servers_api::get_servers;
use openapi::apis::servers_api::get_server;
use openapi::apis::server_actions_api::{get_start_server, stop_server, restart_server};
#[cfg(not(any(target_os = "ios", target_os = "android")))]
use openapi::models::GetServer200Response;
use openapi::models::GetServers200Response;
use openapi::models::GetStartServer200Response;

use crate::exaton_api_lib::keychain;
use crate::exaton_api_lib::token_convert::make_config;

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn get_servers_info(email: &str) -> Result<GetServers200Response, String> {
    let token = keychain::get_token(email)?;
    let config = make_config(&token);
    get_servers(&config).await.map_err(|e| e.to_string())
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn get_server_info(email: &str,serverid: &str) -> Result<GetServer200Response, String> {
    let token = keychain::get_token(email)?;
    let config = make_config(&token);
    get_server(&config, serverid).await.map_err(|e| e.to_string())
}


#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn start_server_action(email: &str, serverid: &str) -> Result<GetStartServer200Response, String> {
    let token = keychain::get_token(email)?;
    let config = make_config(&token);
    get_start_server(&config, serverid).await.map_err(|e| e.to_string())
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn stop_server_action(email: &str, serverid: &str) -> Result<GetStartServer200Response, String> {
    let token = keychain::get_token(email)?;
    let config = make_config(&token);
    stop_server(&config, serverid).await.map_err(|e| e.to_string())
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn restart_server_action(email: &str, serverid: &str) -> Result<GetStartServer200Response, String> {
    let token = keychain::get_token(email)?;
    let config = make_config(&token);
    restart_server(&config, serverid).await.map_err(|e| e.to_string())
}

#[cfg(any(target_os = "ios", target_os = "android"))]
#[tauri::command]
pub async fn get_servers_info(app: tauri::AppHandle, email: &str) -> Result<GetServers200Response, String> {
    let token = keychain::get_token_mobile(&app, email)?;
    let config = make_config(&token);
    get_servers(&config).await.map_err(|e| e.to_string())
}
