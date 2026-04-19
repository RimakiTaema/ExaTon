use std::path::PathBuf;
use std::time::{SystemTime, UNIX_EPOCH};

use openapi::apis::server_files_api::{
    delete_file, get_file_content, get_file_info, put_file_data,
};
use openapi::models::{FileInfo, GetFileInfo200Response, GetStartServer200Response};

use crate::exaton_api_lib::keychain;
use crate::exaton_api_lib::token_convert::make_config;

fn temp_upload_path() -> PathBuf {
    let nanos = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_nanos())
        .unwrap_or(0);
    std::env::temp_dir().join(format!("exaton-upload-{nanos}"))
}

async fn fetch_bytes(
    token: &str,
    server_id: &str,
    path: &str,
) -> Result<Vec<u8>, String> {
    let cfg = make_config(token);
    let resp = get_file_content(&cfg, server_id, path)
        .await
        .map_err(|e| e.to_string())?;
    let bytes = resp.bytes().await.map_err(|e| e.to_string())?;
    Ok(bytes.to_vec())
}

async fn do_write(
    token: &str,
    server_id: &str,
    path: &str,
    content: &[u8],
) -> Result<GetStartServer200Response, String> {
    let tmp = temp_upload_path();
    std::fs::write(&tmp, content).map_err(|e| e.to_string())?;
    let cfg = make_config(token);
    let result = put_file_data(&cfg, server_id, path, Some(tmp.clone()))
        .await
        .map_err(|e| e.to_string());
    let _ = std::fs::remove_file(&tmp);
    result
}

async fn do_upload(
    token: &str,
    server_id: &str,
    remote_path: &str,
    local_path: PathBuf,
) -> Result<GetStartServer200Response, String> {
    let cfg = make_config(token);
    put_file_data(&cfg, server_id, remote_path, Some(local_path))
        .await
        .map_err(|e| e.to_string())
}

async fn do_download(
    token: &str,
    server_id: &str,
    remote_path: &str,
    save_path: PathBuf,
) -> Result<(), String> {
    let bytes = fetch_bytes(token, server_id, remote_path).await?;
    std::fs::write(&save_path, bytes).map_err(|e| e.to_string())
}

// ── Desktop (keychain) ───────────────────────────────────────────────────────

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn list_files(
    email: &str,
    serverid: &str,
    path: &str,
) -> Result<GetFileInfo200Response, String> {
    let token = keychain::get_token(email)?;
    let cfg = make_config(&token);
    get_file_info(&cfg, serverid, path)
        .await
        .map_err(|e| e.to_string())
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn read_file(
    email: &str,
    serverid: &str,
    path: &str,
) -> Result<Vec<u8>, String> {
    let token = keychain::get_token(email)?;
    fetch_bytes(&token, serverid, path).await
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn write_file(
    email: &str,
    serverid: &str,
    path: &str,
    content: Vec<u8>,
) -> Result<GetStartServer200Response, String> {
    let token = keychain::get_token(email)?;
    do_write(&token, serverid, path, &content).await
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn delete_server_file(
    email: &str,
    serverid: &str,
    path: &str,
) -> Result<GetStartServer200Response, String> {
    let token = keychain::get_token(email)?;
    let cfg = make_config(&token);
    delete_file(&cfg, serverid, path)
        .await
        .map_err(|e| e.to_string())
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn upload_file(
    email: &str,
    serverid: &str,
    remote_path: &str,
    local_path: &str,
) -> Result<GetStartServer200Response, String> {
    let token = keychain::get_token(email)?;
    do_upload(&token, serverid, remote_path, PathBuf::from(local_path)).await
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn download_file(
    email: &str,
    serverid: &str,
    remote_path: &str,
    save_path: &str,
) -> Result<(), String> {
    let token = keychain::get_token(email)?;
    do_download(&token, serverid, remote_path, PathBuf::from(save_path)).await
}

// ── Mobile (tauri-plugin-store via AppHandle) ────────────────────────────────

#[cfg(any(target_os = "ios", target_os = "android"))]
#[tauri::command]
pub async fn list_files(
    app: tauri::AppHandle,
    email: &str,
    serverid: &str,
    path: &str,
) -> Result<GetFileInfo200Response, String> {
    let token = keychain::get_token_mobile(&app, email)?;
    let cfg = make_config(&token);
    get_file_info(&cfg, serverid, path)
        .await
        .map_err(|e| e.to_string())
}

#[cfg(any(target_os = "ios", target_os = "android"))]
#[tauri::command]
pub async fn read_file(
    app: tauri::AppHandle,
    email: &str,
    serverid: &str,
    path: &str,
) -> Result<Vec<u8>, String> {
    let token = keychain::get_token_mobile(&app, email)?;
    fetch_bytes(&token, serverid, path).await
}

#[cfg(any(target_os = "ios", target_os = "android"))]
#[tauri::command]
pub async fn write_file(
    app: tauri::AppHandle,
    email: &str,
    serverid: &str,
    path: &str,
    content: Vec<u8>,
) -> Result<GetStartServer200Response, String> {
    let token = keychain::get_token_mobile(&app, email)?;
    do_write(&token, serverid, path, &content).await
}

#[cfg(any(target_os = "ios", target_os = "android"))]
#[tauri::command]
pub async fn delete_server_file(
    app: tauri::AppHandle,
    email: &str,
    serverid: &str,
    path: &str,
) -> Result<GetStartServer200Response, String> {
    let token = keychain::get_token_mobile(&app, email)?;
    let cfg = make_config(&token);
    delete_file(&cfg, serverid, path)
        .await
        .map_err(|e| e.to_string())
}

#[cfg(any(target_os = "ios", target_os = "android"))]
#[tauri::command]
pub async fn upload_file(
    app: tauri::AppHandle,
    email: &str,
    serverid: &str,
    remote_path: &str,
    local_path: &str,
) -> Result<GetStartServer200Response, String> {
    let token = keychain::get_token_mobile(&app, email)?;
    do_upload(&token, serverid, remote_path, PathBuf::from(local_path)).await
}

#[cfg(any(target_os = "ios", target_os = "android"))]
#[tauri::command]
pub async fn download_file(
    app: tauri::AppHandle,
    email: &str,
    serverid: &str,
    remote_path: &str,
    save_path: &str,
) -> Result<(), String> {
    let token = keychain::get_token_mobile(&app, email)?;
    do_download(&token, serverid, remote_path, PathBuf::from(save_path)).await
}

#[allow(dead_code)]
fn _assert_file_info_usable(_: &FileInfo) {}
