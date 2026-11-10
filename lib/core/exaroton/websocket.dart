import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'models.dart';

/// Opens a channel. Swappable so tests can use a fake server.
typedef SocketConnector = WebSocketChannel Function(Uri uri, Map<String, String> headers);

WebSocketChannel _ioConnector(Uri uri, Map<String, String> headers) =>
    IOWebSocketChannel.connect(uri, headers: headers, pingInterval: const Duration(seconds: 30));

enum SocketState {
  connecting,

  /// `ready` received; streams may be started.
  ready,

  /// Dropped or `disconnected`; retrying with backoff.
  reconnecting,
  closed,
}

/// Streams the app can start once the server is online.
enum LiveStream { console, stats, heap, tick }

/// One websocket per open server at `/v1/servers/{id}/websocket`.
///
/// Written by hand against the exaroton Node library, because the websocket
/// is not in the OpenAPI spec. Message shape: `{stream, type, data}`.
///
/// Lifecycle (spec "Console and live stats"):
/// 1. Connect with the bearer header, wait for `ready` before sending.
/// 2. `status` is on by default. While Online, start each wanted stream.
/// 3. On `disconnected` or a dropped socket, retry after 1, 2, 5, 10 s, then
///    every 10 s.
/// 4. [close] sends each `stop` and closes the socket.
class ServerSocket {
  ServerSocket({
    required this.serverId,
    required String token,
    SocketConnector? connector,
    String baseUrl = 'wss://api.exaroton.com/v1',
    List<Duration>? backoff,
    this.consoleTail = 200,
  }) : _token = token,
       _connector = connector ?? _ioConnector,
       _baseUrl = baseUrl,
       _backoff = backoff ?? defaultBackoff;

  static const defaultBackoff = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 5),
    Duration(seconds: 10),
  ];

  final String serverId;
  final String _token;
  final SocketConnector _connector;
  final String _baseUrl;
  final List<Duration> _backoff;
  final int consoleTail;

  final _state = StreamController<SocketState>.broadcast();
  final _status = StreamController<Server>.broadcast();
  final _lines = StreamController<String>.broadcast();
  final _memory = StreamController<MemoryStats>.broadcast();
  final _heap = StreamController<int>.broadcast();
  final _tick = StreamController<double>.broadcast();
  final _tps = StreamController<double>.broadcast();

  Stream<SocketState> get states => _state.stream;
  Stream<Server> get statuses => _status.stream;
  Stream<String> get consoleLines => _lines.stream;
  Stream<MemoryStats> get memory => _memory.stream;

  /// Java heap usage in bytes.
  Stream<int> get heap => _heap.stream;

  /// Average tick time in ms.
  Stream<double> get tick => _tick.stream;

  /// Ticks per second, only when the `tick` payload carries a `tps` field.
  /// The API documents `averageTickTime` alone, so this may never emit.
  Stream<double> get tps => _tps.stream;

  SocketState _current = SocketState.closed;
  SocketState get state => _current;

  final Set<LiveStream> _wanted = {};
  final Set<LiveStream> _started = {};
  ServerStatus? _lastStatus;
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  Timer? _retry;
  int _attempt = 0;
  bool _closed = false;

  /// The streams to run while the server is online.
  void want(Set<LiveStream> streams) {
    final removed = _wanted.difference(streams);
    _wanted
      ..clear()
      ..addAll(streams);
    for (final s in removed) {
      if (_started.remove(s)) _write(s.name, 'stop');
    }
    _startWanted();
  }

  /// Seeds the status from a REST response. The status stream only reports
  /// changes, so without a seed an already-online server would never start
  /// its streams.
  void seedStatus(ServerStatus status) {
    _lastStatus = status;
    _startWanted();
  }

  void connect() {
    if (_closed) throw StateError('ServerSocket was closed');
    _open();
  }

  /// Sends a console command. Returns false when the socket is not ready, so
  /// the caller can fall back to `POST /command/`.
  bool sendCommand(String command) {
    if (_current != SocketState.ready) return false;
    _write('console', 'command', command);
    return true;
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _retry?.cancel();
    if (_current == SocketState.ready) {
      for (final s in _started) {
        _write(s.name, 'stop');
      }
    }
    _started.clear();
    await _sub?.cancel();
    await _channel?.sink.close();
    _setState(SocketState.closed);
    await Future.wait([
      _state.close(),
      _status.close(),
      _lines.close(),
      _memory.close(),
      _heap.close(),
      _tick.close(),
      _tps.close(),
    ]);
  }

  // ── Internals ─────────────────────────────────────────────────────────

  void _open() {
    _setState(_attempt == 0 ? SocketState.connecting : SocketState.reconnecting);
    final uri = Uri.parse('$_baseUrl/servers/$serverId/websocket');
    try {
      final ch = _connector(uri, {'Authorization': 'Bearer $_token'});
      _channel = ch;
      _sub = ch.stream.listen(_onMessage, onError: (_) => _dropped(), onDone: _dropped, cancelOnError: true);
    } catch (_) {
      _dropped();
    }
  }

  void _dropped() {
    if (_closed) return;
    _sub?.cancel();
    _sub = null;
    _channel = null;
    _started.clear();
    _setState(SocketState.reconnecting);
    final delay = _backoff[_attempt < _backoff.length ? _attempt : _backoff.length - 1];
    _attempt++;
    _retry?.cancel();
    _retry = Timer(delay, () {
      if (!_closed) _open();
    });
  }

  void _onMessage(dynamic raw) {
    if (raw is! String) return;
    final Map<String, dynamic> msg;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      msg = decoded.cast<String, dynamic>();
    } catch (_) {
      return;
    }
    final type = msg['type'];
    final stream = msg['stream'];
    final data = msg['data'];

    switch (type) {
      case 'ready':
        _attempt = 0;
        _setState(SocketState.ready);
        _startWanted();
        return;
      case 'disconnected':
        // Server ended the session; treat like a dropped socket.
        _channel?.sink.close();
        _dropped();
        return;
      case 'connected' || 'keep-alive' || 'started':
        return;
      case 'stopped':
        if (stream is String) _started.removeWhere((s) => s.name == stream);
        return;
    }

    switch (stream) {
      case 'status' when type == 'status' && data is Map:
        final server = Server.fromJson(data.cast());
        final wasOnline = _lastStatus == ServerStatus.online;
        _lastStatus = server.status;
        if (!_status.isClosed) _status.add(server);
        if (server.status == ServerStatus.online && !wasOnline) {
          _startWanted();
        } else if (server.status != ServerStatus.online) {
          _started.clear(); // The server ends streams when it goes offline.
        }
      case 'console' when type == 'line' && data is String:
        if (!_lines.isClosed) _lines.add(data);
      case 'stats' when data is Map:
        if (!_memory.isClosed) _memory.add(MemoryStats.fromJson(data.cast()));
        if (data['tps'] is num && !_tps.isClosed) _tps.add((data['tps'] as num).toDouble());
      case 'heap' when data is Map && data['usage'] is num:
        if (!_heap.isClosed) _heap.add((data['usage'] as num).toInt());
      case 'tick' when data is Map && data['averageTickTime'] is num:
        if (!_tick.isClosed) _tick.add((data['averageTickTime'] as num).toDouble());
        if (data['tps'] is num && !_tps.isClosed) _tps.add((data['tps'] as num).toDouble());
    }
  }

  void _startWanted() {
    if (_current != SocketState.ready || _lastStatus != ServerStatus.online) return;
    for (final s in _wanted) {
      if (_started.add(s)) {
        _write(s.name, 'start', s == LiveStream.console ? {'tail': consoleTail} : null);
      }
    }
  }

  void _write(String stream, String type, [Object? data]) {
    final ch = _channel;
    if (ch == null) return;
    final msg = <String, Object?>{'stream': stream, 'type': type};
    if (data != null) msg['data'] = data;
    ch.sink.add(jsonEncode(msg));
  }

  void _setState(SocketState s) {
    if (_current == s) return;
    _current = s;
    if (!_state.isClosed) _state.add(s);
  }
}
