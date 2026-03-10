use keyring::Entry;

const SERVICE_NAME: &str = "net.rimaki.exatonext";

fn entry_for(email: &str) -> Result<Entry, String> {
    Entry::new(SERVICE_NAME, email).map_err(|e| e.to_string())
}

pub fn store_token(email: &str, token: &str) -> Result<(), String> {
    entry_for(email)?
        .set_password(token)
        .map_err(|e| e.to_string())
}

pub fn get_token(email: &str) -> Result<String, String> {
    entry_for(email)?
        .get_password()
        .map_err(|e| e.to_string())
}

pub fn delete_token(email: &str) -> Result<(), String> {
    entry_for(email)?
        .delete_credential()
        .map_err(|e| e.to_string())
}
