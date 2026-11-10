import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:exaton/core/exaroton/models.dart';
import 'package:exaton/core/exaroton/websocket.dart';
import 'package:flutter_test/flutter_test.dart';

/// A local stand-in for the exaroton websocket.
class FakeSocketServer {
  late HttpServer _http;
  final connections = <WebSocket>[];
  final received = <Map<String, dynamic>>[];
  final headers = <String?>[];
  final _connected = StreamController<WebSocket>.broadcast();
  final _messages = StreamController<Map<String, dynamic>>.broadcast();

  Stream<WebSocket> get onConnect => _connected.stream;
  Stream<Map<String, dynamic>> get onMessage => _messages.stream;

  String get baseUrl => 'ws://127.0.0.1:${_http.port}/v1';

  Future<void> start() async {
    _http = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _http.listen((req) async {
      headers.add(req.headers.value('authorization'));
      final ws = await WebSocketTransformer.upgrade(req);
      connections.add(ws);
      ws.listen((m) {
        final msg = (jsonDecode(m as String) as Map).cast<String, dynamic>();
        received.add(msg);
        _messages.add(msg);
      });
      _connected.add(ws);
    });
  }

  static void send(WebSocket ws, Map<String, Object?> msg) => ws.add(jsonEncode(msg));

  Future<void> stop() async {
    for (final c in connections) {
      await c.close();
    }
    await _http.close(force: true);
  }
}

Map<String, Object?> statusMsg(int status) => {
  'stream': 'status',
  'type': 'status',
  'data': {
    'id': 'Srv0000000000001',
    'name': 'Survival SMP',
    'address': 'survival.exaroton.me',
    'status': status,
    'players': {
      'max': 20,
      'count': 1,
      'list': ['Steve'],
    },
    'software': {'id': 's', 'name': 'Paper', 'version': '1.21'},
  },
};

void main() {
  late FakeSocketServer server;

  setUp(() async {
    server = FakeSocketServer();
    await server.start();
  });

  tearDown(() => server.stop());

  ServerSocket make({List<Duration>? backoff}) => ServerSocket(
    serverId: 'Srv0000000000001',
    token: 'tok',
    baseUrl: server.baseUrl,
    backoff: backoff ?? const [Duration(milliseconds: 20)],
  );

  test('waits for ready, then starts wanted streams while online', () async {
    final s = make()
      ..want({LiveStream.console, LiveStream.stats, LiveStream.tick})
      ..seedStatus(ServerStatus.online);
    final connected = server.onConnect.first;
    s.connect();
    final conn = await connected.timeout(const Duration(seconds: 5));
    expect(server.headers.last, 'Bearer tok');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(server.received, isEmpty, reason: 'must wait for ready');

    final starts = server.onMessage.take(3).toList();
    FakeSocketServer.send(conn, {'type': 'ready'});
    await starts.timeout(const Duration(seconds: 5));
    expect(
      server.received,
      containsAll([
        {
          'stream': 'console',
          'type': 'start',
          'data': {'tail': 200},
        },
        {'stream': 'stats', 'type': 'start'},
        {'stream': 'tick', 'type': 'start'},
      ]),
    );
    expect(s.state, SocketState.ready);
    await s.close();
  });

  test('does not start streams while offline; starts when status turns Online', () async {
    final s = make()
      ..want({LiveStream.console})
      ..seedStatus(ServerStatus.offline);
    final connected = server.onConnect.first;
    s.connect();
    final conn = await connected;
    FakeSocketServer.send(conn, {'type': 'ready'});
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(server.received, isEmpty);

    final start = server.onMessage.first;
    final status = s.statuses.first;
    FakeSocketServer.send(conn, statusMsg(1));
    expect((await status).status, ServerStatus.online);
    expect(await start.timeout(const Duration(seconds: 5)), {
      'stream': 'console',
      'type': 'start',
      'data': {'tail': 200},
    });
    await s.close();
  });

  test('delivers console lines, stats, heap and tick', () async {
    final s = make()
      ..want({LiveStream.console})
      ..seedStatus(ServerStatus.online);
    final connected = server.onConnect.first;
    s.connect();
    final conn = await connected;
    FakeSocketServer.send(conn, {'type': 'ready'});

    final line = s.consoleLines.first;
    final mem = s.memory.first;
    final heap = s.heap.first;
    final tick = s.tick.first;
    FakeSocketServer.send(conn, {
      'stream': 'console',
      'type': 'line',
      'data': '[10:42:15 INFO]: Steve joined the game',
    });
    FakeSocketServer.send(conn, {
      'stream': 'stats',
      'type': 'stats',
      'data': {
        'memory': {'percent': 42.5, 'usage': 1073741824},
      },
    });
    FakeSocketServer.send(conn, {
      'stream': 'heap',
      'type': 'heap',
      'data': {'usage': 536870912},
    });
    FakeSocketServer.send(conn, {
      'stream': 'tick',
      'type': 'tick',
      'data': {'averageTickTime': 12.5},
    });

    expect(await line, contains('Steve joined'));
    expect((await mem).percent, 42.5);
    expect(await heap, 536870912);
    expect(await tick, 12.5);
    await s.close();
  });

  test('sendCommand goes over the socket only when ready', () async {
    final s = make()..seedStatus(ServerStatus.online);
    expect(s.sendCommand('list'), isFalse, reason: 'not connected: caller falls back to POST');
    final connected = server.onConnect.first;
    s.connect();
    final conn = await connected;
    FakeSocketServer.send(conn, {'type': 'ready'});
    await s.states.firstWhere((x) => x == SocketState.ready);
    final msg = server.onMessage.first;
    expect(s.sendCommand('list'), isTrue);
    expect(await msg, {'stream': 'console', 'type': 'command', 'data': 'list'});
    await s.close();
  });

  test('reconnects after a dropped socket and restarts streams', () async {
    final s = make()
      ..want({LiveStream.console})
      ..seedStatus(ServerStatus.online);
    final conns = server.onConnect.take(2).toList();
    s.connect();
    final first = await server.onConnect.first;
    FakeSocketServer.send(first, {'type': 'ready'});
    await server.onMessage.first;

    final reconnecting = s.states.firstWhere((x) => x == SocketState.reconnecting);
    await first.close();
    await reconnecting.timeout(const Duration(seconds: 5));

    final second = (await conns.timeout(const Duration(seconds: 5))).last;
    final restart = server.onMessage.first;
    FakeSocketServer.send(second, {'type': 'ready'});
    expect(await restart.timeout(const Duration(seconds: 5)), {
      'stream': 'console',
      'type': 'start',
      'data': {'tail': 200},
    });
    expect(server.connections.length, 2);
    await s.close();
  });

  test('disconnected message triggers a reconnect', () async {
    final s = make()..seedStatus(ServerStatus.offline);
    final two = server.onConnect.take(2).toList();
    s.connect();
    final first = await server.onConnect.first;
    FakeSocketServer.send(first, {'type': 'ready'});
    FakeSocketServer.send(first, {'type': 'disconnected', 'data': 'reason'});
    final conns = await two.timeout(const Duration(seconds: 5));
    expect(conns.length, 2);
    await s.close();
  });

  test('backoff follows 1, 2, 5, 10 then every 10 seconds', () {
    expect(ServerSocket.defaultBackoff, const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 5),
      Duration(seconds: 10),
    ]);
  });

  test('close sends stop for each started stream', () async {
    final s = make()
      ..want({LiveStream.console, LiveStream.stats})
      ..seedStatus(ServerStatus.online);
    final connected = server.onConnect.first;
    s.connect();
    final conn = await connected;
    final starts = server.onMessage.take(2).toList();
    FakeSocketServer.send(conn, {'type': 'ready'});
    await starts;
    final stops = server.onMessage.take(2).toList();
    await s.close();
    expect(
      await stops.timeout(const Duration(seconds: 5)),
      containsAll([
        {'stream': 'console', 'type': 'stop'},
        {'stream': 'stats', 'type': 'stop'},
      ]),
    );
    expect(s.state, SocketState.closed);
  });
}
