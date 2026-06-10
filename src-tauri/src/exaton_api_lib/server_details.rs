use openapi::apis::server_logs_api::{get_server_log, share_server_log};
use openapi::apis::server_options_api::{
    get_server_motd, get_server_ram, post_server_motd, post_server_ram,
};
use openapi::apis::server_players_api::{
    delete_player_list, get_player_list, get_player_lists, put_player_list,
};
use openapi::models::{
    DeletePlayerListRequestBody, GetPlayerList200Response, GetPlayerLists200Response,
    GetServerLog200Response, GetServerMotd200Response, GetServerRam200Response,
    PostServerMotdRequest, PostServerRamRequest, PutPlayerListRequestBody,
    ShareServerLog200Response,
};

use crate::exaton_api_lib::keychain;
use crate::exaton_api_lib::token_convert::make_config;

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn get_player_lists_info(
    email: &str,
    serverid: &str,
) -> Result<GetPlayerLists200Response, String> {
    log::info!("loading player lists for server {serverid}");
    let token = keychain::get_token(email)?;
    let config = make_config(&token);
    get_player_lists(&config, serverid)
        .await
        .map_err(|e| e.to_string())
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn get_player_list_info(
    email: &str,
    serverid: &str,
    list: &str,
) -> Result<GetPlayerList200Response, String> {
    log::info!("loading player list {list} for server {serverid}");
    let token = keychain::get_token(email)?;
    let config = make_config(&token);
    get_player_list(&config, serverid, list)
        .await
        .map_err(|e| e.to_string())
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn add_player_list_entries(
    email: &str,
    serverid: &str,
    list: &str,
    entries: Vec<String>,
) -> Result<GetPlayerList200Response, String> {
    log::info!(
        "adding {} player list entries to {list} for server {serverid}",
        entries.len()
    );
    let token = keychain::get_token(email)?;
    let config = make_config(&token);
    let body = PutPlayerListRequestBody {
        entries: Some(entries),
    };
    put_player_list(&config, serverid, list, Some(body))
        .await
        .map_err(|e| e.to_string())
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn delete_player_list_entries(
    email: &str,
    serverid: &str,
    list: &str,
    entries: Vec<String>,
) -> Result<GetPlayerList200Response, String> {
    log::info!(
        "deleting {} player list entries from {list} for server {serverid}",
        entries.len()
    );
    let token = keychain::get_token(email)?;
    let config = make_config(&token);
    let body = DeletePlayerListRequestBody {
        entries: Some(entries),
    };
    delete_player_list(&config, serverid, list, Some(body))
        .await
        .map_err(|e| e.to_string())
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn get_server_log_info(
    email: &str,
    serverid: &str,
) -> Result<GetServerLog200Response, String> {
    log::info!("loading log for server {serverid}");
    let token = keychain::get_token(email)?;
    let config = make_config(&token);
    get_server_log(&config, serverid)
        .await
        .map_err(|e| e.to_string())
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn share_server_log_info(
    email: &str,
    serverid: &str,
) -> Result<ShareServerLog200Response, String> {
    log::info!("sharing log for server {serverid}");
    let token = keychain::get_token(email)?;
    let config = make_config(&token);
    share_server_log(&config, serverid)
        .await
        .map_err(|e| e.to_string())
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn get_server_motd_option(
    email: &str,
    serverid: &str,
) -> Result<GetServerMotd200Response, String> {
    log::info!("loading MOTD option for server {serverid}");
    let token = keychain::get_token(email)?;
    let config = make_config(&token);
    get_server_motd(&config, serverid)
        .await
        .map_err(|e| e.to_string())
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn update_server_motd_option(
    email: &str,
    serverid: &str,
    motd: &str,
) -> Result<GetServerMotd200Response, String> {
    log::info!("updating MOTD option for server {serverid}");
    let token = keychain::get_token(email)?;
    let config = make_config(&token);
    post_server_motd(
        &config,
        serverid,
        PostServerMotdRequest::new(motd.to_string()),
    )
    .await
    .map_err(|e| e.to_string())
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn get_server_ram_option(
    email: &str,
    serverid: &str,
) -> Result<GetServerRam200Response, String> {
    log::info!("loading RAM option for server {serverid}");
    let token = keychain::get_token(email)?;
    let config = make_config(&token);
    get_server_ram(&config, serverid)
        .await
        .map_err(|e| e.to_string())
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn update_server_ram_option(
    email: &str,
    serverid: &str,
    ram: i32,
) -> Result<GetServerRam200Response, String> {
    log::info!("updating RAM option to {ram} GB for server {serverid}");
    let token = keychain::get_token(email)?;
    let config = make_config(&token);
    post_server_ram(&config, serverid, PostServerRamRequest::new(ram))
        .await
        .map_err(|e| e.to_string())
}
