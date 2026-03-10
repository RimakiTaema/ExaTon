use crate::exaton_api_lib::keychain;
use crate::exaton_api_lib::token_convert::make_config;
use openapi::apis::account_api::get_account;
use openapi::models::GetAccount200Response;

#[tauri::command]
pub async fn get_acc_info(token: &str) -> Result<GetAccount200Response, String> {
    let config = make_config(token);
    get_account(&config).await.map_err(|e| e.to_string())
}

#[tauri::command]
pub fn save_token(email: &str, token: &str) -> Result<(), String> {
    keychain::store_token(email, token)
}

#[tauri::command]
pub fn get_token(email: &str) -> Result<String, String> {
    keychain::get_token(email)
}

#[tauri::command]
pub fn delete_token(email: &str) -> Result<(), String> {
    keychain::delete_token(email)
}
