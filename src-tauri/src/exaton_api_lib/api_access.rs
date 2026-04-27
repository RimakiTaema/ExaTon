use std::time::Duration;

use openapi::apis::server_actions_api::{get_start_server, restart_server, stop_server};
use openapi::apis::server_files_api::get_file_info;
use openapi::apis::servers_api::{get_server, get_servers};
use openapi::apis::Error as ApiError;

use crate::exaton_api_lib::token_convert::make_config;

const PROBE_DELAY_MS: u64 = 400;
const DUMMY_TOKEN: &str = "invalid_token_for_probe";
const DUMMY_SERVER_ID: &str = "00000000-0000-0000-0000-000000000000";
const DUMMY_PATH: &str = "/";

#[derive(Debug)]
pub enum ReachabilityError {
    Offline,
    RouteBroken(&'static str, String),
}

impl std::fmt::Display for ReachabilityError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Offline => write!(f, "offline: cannot reach exaroton API"),
            Self::RouteBroken(name, msg) => write!(f, "route {name} broken: {msg}"),
        }
    }
}

impl std::error::Error for ReachabilityError {}

#[derive(Debug)]
enum ProbeOutcome {
    Ok,
    Http(u16),
    Offline,
    Other(String),
}

fn classify<T, V>(result: Result<V, ApiError<T>>) -> ProbeOutcome {
    match result {
        Ok(_) => ProbeOutcome::Ok,
        Err(ApiError::ResponseError(r)) => ProbeOutcome::Http(r.status.as_u16()),
        Err(ApiError::Reqwest(e)) if e.is_connect() || e.is_timeout() => ProbeOutcome::Offline,
        Err(e) => ProbeOutcome::Other(e.to_string()),
    }
}

#[derive(Clone, Copy)]
pub enum CheckMode<'a> {
    Anonymous,
    Authenticated {
        token: &'a str,
        server_id: &'a str,
        path: &'a str,
    },
}

pub async fn run_checks(mode: CheckMode<'_>) -> Result<(), ReachabilityError> {
    let (token, server_id, path, expect_401) = match mode {
        CheckMode::Anonymous => (DUMMY_TOKEN, DUMMY_SERVER_ID, DUMMY_PATH, true),
        CheckMode::Authenticated { token, server_id, path } => (token, server_id, path, false),
    };
    let cfg = make_config(token);

    log::info!("checking API access (expect_401={expect_401})...");

    probe("get_servers", classify(get_servers(&cfg).await), expect_401)?;
    tokio::time::sleep(Duration::from_millis(PROBE_DELAY_MS)).await;

    probe("get_server", classify(get_server(&cfg, server_id).await), expect_401)?;
    tokio::time::sleep(Duration::from_millis(PROBE_DELAY_MS)).await;

    probe("get_start_server", classify(get_start_server(&cfg, server_id).await), expect_401)?;
    tokio::time::sleep(Duration::from_millis(PROBE_DELAY_MS)).await;

    probe("stop_server", classify(stop_server(&cfg, server_id).await), expect_401)?;
    tokio::time::sleep(Duration::from_millis(PROBE_DELAY_MS)).await;

    probe("restart_server", classify(restart_server(&cfg, server_id).await), expect_401)?;
    tokio::time::sleep(Duration::from_millis(PROBE_DELAY_MS)).await;

    probe("get_file_info", classify(get_file_info(&cfg, server_id, path).await), expect_401)?;

    log::info!("all API probes passed.");
    Ok(())
}

fn probe(
    name: &'static str,
    outcome: ProbeOutcome,
    expect_401: bool,
) -> Result<(), ReachabilityError> {
    match outcome {
        ProbeOutcome::Ok => {
            log::info!("  {name}: ok");
            Ok(())
        }
        ProbeOutcome::Http(status) if expect_401 && (400..500).contains(&status) => {
            log::info!("  {name}: ok ({status} expected in anonymous mode)");
            Ok(())
        }
        ProbeOutcome::Http(status) => {
            Err(ReachabilityError::RouteBroken(name, format!("HTTP {status}")))
        }
        ProbeOutcome::Offline => Err(ReachabilityError::Offline),
        ProbeOutcome::Other(msg) => Err(ReachabilityError::RouteBroken(name, msg)),
    }
}

