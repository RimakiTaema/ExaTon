use crate::exaton_api_lib::keychain;
use crate::exaton_api_lib::token_convert::make_config;
use openapi::apis::account_api::get_account;
use openapi::models::GetAccount200Response;

pub fn init() {
    log::info!("Initializing accounts module");
}

#[tauri::command]
pub async fn get_acc_info(token: &str) -> Result<GetAccount200Response, String> {
    let config = make_config(token);
    get_account(&config).await.map_err(|e| e.to_string())
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub fn save_token(email: &str, token: &str) -> Result<(), String> {
    keychain::store_token(email, token)
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub fn get_token(email: &str) -> Result<String, String> {
    keychain::get_token(email)
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub fn delete_token(email: &str) -> Result<(), String> {
    keychain::delete_token(email)
}

#[cfg(any(target_os = "ios", target_os = "android"))]
#[tauri::command]
pub fn save_token(app: tauri::AppHandle, email: &str, token: &str) -> Result<(), String> {
    keychain::store_token_mobile(&app, email, token)
}

#[cfg(any(target_os = "ios", target_os = "android"))]
#[tauri::command]
pub fn get_token(app: tauri::AppHandle, email: &str) -> Result<String, String> {
    keychain::get_token_mobile(&app, email)
}

#[cfg(any(target_os = "ios", target_os = "android"))]
#[tauri::command]
pub fn delete_token(app: tauri::AppHandle, email: &str) -> Result<(), String> {
    keychain::delete_token_mobile(&app, email)
}
