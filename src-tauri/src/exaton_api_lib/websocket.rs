use std::collections::HashMap;
use std::sync::Arc;

use futures_util::{SinkExt, StreamExt};
use serde::{Deserialize, Serialize};
use tauri::{AppHandle, Emitter};
use tokio::sync::Mutex;
use tokio_tungstenite::tungstenite::http::Request;
use tokio_tungstenite::tungstenite::Message;

use crate::exaton_api_lib::keychain;

// ── Exaroton WS protocol types ──────────────────────────────────────────

#[derive(Debug, Serialize, Deserialize, Clone)]
struct WsOutgoing {
    #[serde(rename = "type")]
    msg_type: String,
    stream: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    data: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct WsIncoming {
    #[serde(rename = "type")]
    msg_type: String,
    #[serde(default)]
    stream: String,
    #[serde(default)]
    data: serde_json::Value,
}

// ── Event payloads emitted to frontend ──────────────────────────────────

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct WsStatusEvent {
    pub server_id: String,
    pub status: serde_json::Value,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct WsConsoleEvent {
    pub server_id: String,
    pub line: String,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct WsStatsEvent {
    pub server_id: String,
    pub data: serde_json::Value,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct WsConnectionEvent {
    pub server_id: String,
}

// ── Connection state ────────────────────────────────────────────────────

struct WsConnection {
    /// Channel to send messages to the WS write task
    tx: tokio::sync::mpsc::UnboundedSender<String>,
    /// Handle to abort the WS read/write tasks on disconnect
    abort_handle: tokio::task::AbortHandle,
}

#[derive(Default)]
pub struct WsState {
    connections: Arc<Mutex<HashMap<String, WsConnection>>>,
}

// ── Tauri commands ──────────────────────────────────────────────────────

#[cfg(not(any(target_os = "ios", target_os = "android")))]
#[tauri::command]
pub async fn ws_connect(
    app: AppHandle,
    state: tauri::State<'_, WsState>,
    email: String,
    server_id: String,
) -> Result<(), String> {
    // Don't connect twice
    {
        let conns = state.connections.lock().await;
        if conns.contains_key(&server_id) {
            return Ok(());
        }
    }

    let token = keychain::get_token(&email)?;

    let url = format!(
        "wss://api.exaroton.com/v1/servers/{}/websocket",
        server_id
    );

    let request = Request::builder()
        .uri(&url)
        .header("Authorization", format!("Bearer {}", token))
        .header("Host", "api.exaroton.com")
        .header("Connection", "Upgrade")
        .header("Upgrade", "websocket")
        .header("Sec-WebSocket-Version", "13")
        .header(
            "Sec-WebSocket-Key",
            tokio_tungstenite::tungstenite::handshake::client::generate_key(),
        )
        .body(())
        .map_err(|e| e.to_string())?;

    let (ws_stream, _) = tokio_tungstenite::connect_async(request)
        .await
        .map_err(|e| format!("WebSocket connect failed: {}", e))?;

    let (mut write, mut read) = ws_stream.split();

    // Channel for sending messages from commands → WS write task
    let (tx, mut rx) = tokio::sync::mpsc::unbounded_channel::<String>();

    let sid = server_id.clone();
    let app_handle = app.clone();
    let connections = state.connections.clone();

    // Spawn a single task that handles both read and write
    let task = tokio::spawn(async move {
        let sid_inner = sid.clone();
        let app_inner = app_handle.clone();

        // Emit connected event
        let _ = app_inner.emit("ws:connected", WsConnectionEvent {
            server_id: sid_inner.clone(),
        });

        // Auto-subscribe to status stream on connect
        let start_status = serde_json::to_string(&WsOutgoing {
            msg_type: "start".to_string(),
            stream: "status".to_string(),
            data: None,
        })
        .unwrap();
        let _ = write.send(Message::Text(start_status.into())).await;

        loop {
            tokio::select! {
                // Messages from the WS server
                msg = read.next() => {
                    match msg {
                        Some(Ok(Message::Text(text))) => {
                            handle_ws_message(&app_inner, &sid_inner, &text);
                        }
                        Some(Ok(Message::Close(_))) | None => {
                            break;
                        }
                        Some(Err(e)) => {
                            log::error!("WS read error for {}: {}", sid_inner, e);
                            break;
                        }
                        _ => {} // Ping/Pong handled automatically
                    }
                }
                // Messages from Tauri commands to send to WS
                outgoing = rx.recv() => {
                    match outgoing {
                        Some(msg) => {
                            if write.send(Message::Text(msg.into())).await.is_err() {
                                break;
                            }
                        }
                        None => break, // Channel closed
                    }
                }
            }
        }

        // Cleanup on disconnect
        let _ = app_inner.emit("ws:disconnected", WsConnectionEvent {
            server_id: sid_inner.clone(),
        });

        let mut conns = connections.lock().await;
        conns.remove(&sid_inner);
    });

    let abort_handle = task.abort_handle();

    // Store the connection
    let mut conns = state.connections.lock().await;
    conns.insert(
        server_id,
        WsConnection { tx, abort_handle },
    );

    Ok(())
}

#[tauri::command]
pub async fn ws_disconnect(
    state: tauri::State<'_, WsState>,
    server_id: String,
) -> Result<(), String> {
    let mut conns = state.connections.lock().await;
    if let Some(conn) = conns.remove(&server_id) {
        conn.abort_handle.abort();
    }
    Ok(())
}

#[tauri::command]
pub async fn ws_subscribe(
    state: tauri::State<'_, WsState>,
    server_id: String,
    stream: String,
) -> Result<(), String> {
    let conns = state.connections.lock().await;
    let conn = conns
        .get(&server_id)
        .ok_or_else(|| "Not connected".to_string())?;

    let msg = serde_json::to_string(&WsOutgoing {
        msg_type: "start".to_string(),
        stream,
        data: None,
    })
    .map_err(|e| e.to_string())?;

    conn.tx.send(msg).map_err(|e| e.to_string())
}

#[tauri::command]
pub async fn ws_unsubscribe(
    state: tauri::State<'_, WsState>,
    server_id: String,
    stream: String,
) -> Result<(), String> {
    let conns = state.connections.lock().await;
    let conn = conns
        .get(&server_id)
        .ok_or_else(|| "Not connected".to_string())?;

    let msg = serde_json::to_string(&WsOutgoing {
        msg_type: "stop".to_string(),
        stream,
        data: None,
    })
    .map_err(|e| e.to_string())?;

    conn.tx.send(msg).map_err(|e| e.to_string())
}

#[tauri::command]
pub async fn ws_send_command(
    state: tauri::State<'_, WsState>,
    server_id: String,
    command: String,
) -> Result<(), String> {
    let conns = state.connections.lock().await;
    let conn = conns
        .get(&server_id)
        .ok_or_else(|| "Not connected".to_string())?;

    let msg = serde_json::to_string(&WsOutgoing {
        msg_type: "command".to_string(),
        stream: "console".to_string(),
        data: Some(command),
    })
    .map_err(|e| e.to_string())?;

    conn.tx.send(msg).map_err(|e| e.to_string())
}

// ── Message handler ─────────────────────────────────────────────────────

fn handle_ws_message(app: &AppHandle, server_id: &str, text: &str) {
    let incoming: WsIncoming = match serde_json::from_str(text) {
        Ok(v) => v,
        Err(e) => {
            log::warn!("Failed to parse WS message: {} — raw: {}", e, text);
            return;
        }
    };

    match (incoming.msg_type.as_str(), incoming.stream.as_str()) {
        ("status", "status") => {
            let _ = app.emit(
                "ws:status",
                WsStatusEvent {
                    server_id: server_id.to_string(),
                    status: incoming.data,
                },
            );
        }
        ("line", "console") => {
            let line = incoming.data.as_str().unwrap_or("").to_string();
            let _ = app.emit(
                "ws:console",
                WsConsoleEvent {
                    server_id: server_id.to_string(),
                    line,
                },
            );
        }
        ("status", "stats") | ("tick", "tick") | ("stats", "stats") => {
            let _ = app.emit(
                "ws:stats",
                WsStatsEvent {
                    server_id: server_id.to_string(),
                    data: incoming.data,
                },
            );
        }
        ("heap", "heap") => {
            let _ = app.emit(
                "ws:stats",
                WsStatsEvent {
                    server_id: server_id.to_string(),
                    data: incoming.data,
                },
            );
        }
        ("started", _) | ("stopped", _) => {
            // Stream start/stop confirmations — log only
            log::info!("WS stream {}: {} for {}", incoming.msg_type, incoming.stream, server_id);
        }
        ("ready", _) => {
            log::info!("WS ready for server {}", server_id);
        }
        _ => {
            log::debug!(
                "WS unhandled message type={} stream={} for {}",
                incoming.msg_type,
                incoming.stream,
                server_id
            );
        }
    }
}
