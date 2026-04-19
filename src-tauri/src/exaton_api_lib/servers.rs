use openapi::apis::server_files_api::get_file_info;
use openapi::apis::servers_api::get_servers;
use openapi::apis::servers_api::get_server;
use openapi::apis::server_actions_api::{get_start_server, stop_server, restart_server};
#[cfg(not(any(target_os = "ios", target_os = "android")))]
use openapi::models::GetServer200Response;
use openapi::models::GetServers200Response;
use openapi::models::GetStartServer200Response;

use crate::exaton_api_lib::api_access::{run_checks, CheckMode, ReachabilityError};
use crate::exaton_api_lib::keychain;
use crate::exaton_api_lib::token_convert::make_config;

pub async fn init() -> Result<(), ReachabilityError> {
    log::info!("Initializing servers module");
    run_checks(CheckMode::Anonymous).await
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn probe_api(
    email: Option<&str>,
    serverid: Option<&str>,
    path: Option<&str>,
) -> Result<(), String> {
    match (email, serverid, path) {
        (Some(e), Some(sid), Some(p)) => {
            let token = keychain::get_token(e)?;
            run_checks(CheckMode::Authenticated {
                token: &token,
                server_id: sid,
                path: p,
            })
            .await
            .map_err(|err| err.to_string())
        }
        _ => run_checks(CheckMode::Anonymous)
            .await
            .map_err(|err| err.to_string()),
    }
}

#[cfg(any(target_os = "ios", target_os = "android"))]
#[tauri::command]
pub async fn probe_api(
    app: tauri::AppHandle,
    email: Option<&str>,
    serverid: Option<&str>,
    path: Option<&str>,
) -> Result<(), String> {
    match (email, serverid, path) {
        (Some(e), Some(sid), Some(p)) => {
            let token = keychain::get_token_mobile(&app, e)?;
            run_checks(CheckMode::Authenticated {
                token: &token,
                server_id: sid,
                path: p,
            })
            .await
            .map_err(|err| err.to_string())
        }
        _ => run_checks(CheckMode::Anonymous)
            .await
            .map_err(|err| err.to_string()),
    }
}

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

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn get_server_files_info(email: &str, serverid: &str, path: &str) -> Result<openapi::models::GetFileInfo200Response, String> {
    let token = keychain::get_token(email)?;
    let config = make_config(&token);
    get_file_info(&config, serverid, path).await.map_err(|e| e.to_string()) 
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn get_server_files(email: &str, serverid: &str, path: &str) -> Result<openapi::models::GetFileInfo200Response, String> {
    let token = keychain::get_token(email)?;
    let config = make_config(&token);
    log::info!("Getting server files for server, Using Common path...");
    get_file_info(&config, serverid, path).await.map_err(|e| e.to_string()) 
}
