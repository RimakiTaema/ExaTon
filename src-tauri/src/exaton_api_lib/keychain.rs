#[allow(dead_code)]
const SERVICE_NAME: &str = "net.rimaki.exatonext";
#[allow(dead_code)]
const STORE_FILENAME: &str = "secure-tokens.json";
 pub fn init() {
    log::info!("Initializing keychain module");
}

// Desktop: use system keychain (macOS Keychain, Windows Credential Manager, Linux Secret Service)
#[cfg(not(any(target_os = "ios", target_os = "android")))]
pub fn store_token(email: &str, token: &str) -> Result<(), String> {
    keyring::Entry::new(SERVICE_NAME, email)
        .map_err(|e| e.to_string())?
        .set_password(token)
        .map_err(|e| e.to_string())
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
pub fn get_token(email: &str) -> Result<String, String> {
    keyring::Entry::new(SERVICE_NAME, email)
        .map_err(|e| e.to_string())?
        .get_password()
        .map_err(|e| e.to_string())
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
pub fn delete_token(email: &str) -> Result<(), String> {
    keyring::Entry::new(SERVICE_NAME, email)
        .map_err(|e| e.to_string())?
        .delete_credential()
        .map_err(|e| e.to_string())
}

// Mobile: use tauri-plugin-store (sandboxed app storage)
#[cfg(any(target_os = "ios", target_os = "android"))]
pub fn store_token_mobile(app: &tauri::AppHandle, email: &str, token: &str) -> Result<(), String> {
    use tauri_plugin_store::StoreExt;
    let store = app.store(STORE_FILENAME).map_err(|e| e.to_string())?;
    store.set(email.to_string(), serde_json::json!(token));
    store.save().map_err(|e| e.to_string())
}

#[cfg(any(target_os = "ios", target_os = "android"))]
pub fn get_token_mobile(app: &tauri::AppHandle, email: &str) -> Result<String, String> {
    use tauri_plugin_store::StoreExt;
    let store = app.store(STORE_FILENAME).map_err(|e| e.to_string())?;
    store
        .get(email)
        .and_then(|v| v.as_str().map(|s| s.to_string()))
        .ok_or_else(|| "Token not found".to_string())
}

#[cfg(any(target_os = "ios", target_os = "android"))]
pub fn delete_token_mobile(app: &tauri::AppHandle, email: &str) -> Result<(), String> {
    use tauri_plugin_store::StoreExt;
    let store = app.store(STORE_FILENAME).map_err(|e| e.to_string())?;
    store.delete(email).map_err(|e| e.to_string())?;
    store.save().map_err(|e| e.to_string())
}
