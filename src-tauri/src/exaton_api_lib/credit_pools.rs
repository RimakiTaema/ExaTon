use futures_util::future::join;
use openapi::apis::account_api::get_account;
use openapi::apis::credit_pools_api::get_credit_pools;
use serde::Serialize;

use crate::exaton_api_lib::keychain;
use crate::exaton_api_lib::token_convert::make_config;

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct PoolSummary {
    pub id: String,
    pub name: String,
    pub own_credits: f64,
    pub total_credits: f64,
    pub is_owner: bool,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct AccountSummary {
    pub email: String,
    pub name: String,
    pub personal_credits: f64,
    pub pool_credits: f64,
    pub pools: Vec<PoolSummary>,
}

async fn fetch_summary(email: &str, token: &str) -> Result<AccountSummary, String> {
    let cfg = make_config(token);
    let (acc_result, pools_result) = join(get_account(&cfg), get_credit_pools(&cfg)).await;

    let acc = acc_result.map_err(|e| e.to_string())?;
    let pools_resp = pools_result.map_err(|e| e.to_string())?;

    let acc_data = acc.data.flatten();
    let personal_credits = acc_data.as_ref().and_then(|d| d.credits).unwrap_or(0.0);
    let name = acc_data.as_ref().and_then(|d| d.name.clone()).unwrap_or_default();

    let pools: Vec<PoolSummary> = pools_resp
        .data
        .unwrap_or_default()
        .into_iter()
        .map(|p| PoolSummary {
            id: p.id.unwrap_or_default(),
            name: p.name.unwrap_or_default(),
            own_credits: p.own_credits.unwrap_or(0.0),
            total_credits: p.credits.unwrap_or(0.0),
            is_owner: p.is_owner.unwrap_or(false),
        })
        .collect();

    let pool_credits = pools.iter().map(|p| p.own_credits).sum();

    Ok(AccountSummary {
        email: email.to_owned(),
        name,
        personal_credits,
        pool_credits,
        pools,
    })
}

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn refresh_account_summary(email: &str) -> Result<AccountSummary, String> {
    let token = keychain::get_token(email)?;
    fetch_summary(email, &token).await
}

#[cfg(any(target_os = "ios", target_os = "android"))]
#[tauri::command]
pub async fn refresh_account_summary(
    app: tauri::AppHandle,
    email: &str,
) -> Result<AccountSummary, String> {
    let token = keychain::get_token_mobile(&app, email)?;
    fetch_summary(email, &token).await
}
