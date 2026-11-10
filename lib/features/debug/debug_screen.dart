import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_info.dart';
import '../../core/exaroton/client.dart';
import '../../core/exaroton/websocket.dart';
import '../../ui/components.dart';
import '../../ui/tokens.dart';
import '../accounts/accounts.dart';
import '../console/live_session.dart';
import '../servers/servers.dart';
import 'probe.dart';

/// Builds the client for the anonymous probe: no token, no interceptors.
/// Overridable in tests.
final probeDioProvider = Provider<Dio Function()>(
  (ref) =>
      () => Dio(
        BaseOptions(
          baseUrl: exarotonApiBase,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          responseType: ResponseType.plain,
          validateStatus: (_) => true,
        ),
      ),
);

/// Connection checks and build details, for working out why something
/// does not load. Every request here only reads.
class DebugScreen extends ConsumerStatefulWidget {
  const DebugScreen({super.key});

  @override
  ConsumerState<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends ConsumerState<DebugScreen> {
  bool _checking = false;
  ProbeResult? _anonymous;
  ProbeResult? _account;
  ProbeResult? _server;

  Future<void> _run(Future<void> Function() probe) async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      await probe();
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _probeAnonymous() => _run(() async {
    final dio = ref.read(probeDioProvider)();
    try {
      final r = await runProbe(() => dio.get<dynamic>('/'), passes: reachedApi);
      if (mounted) setState(() => _anonymous = r);
    } finally {
      dio.close();
    }
  });

  Future<void> _probeAuthenticated() => _run(() async {
    final client = ref.read(clientProvider);
    if (client == null) return;
    final serverId = ref.read(selectedServerProvider);
    final account = await runProbe(() => client.dio.get<dynamic>('/account/'), passes: envelopeOk);
    final server = serverId == null
        ? null
        : await runProbe(() => client.dio.get<dynamic>('/servers/$serverId/'), passes: envelopeOk);
    if (mounted) {
      setState(() {
        _account = account;
        _server = server;
      });
    }
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final label = TextStyle(color: t.onSurfaceMuted, fontWeight: FontWeight.w600, fontSize: 15);
    final stored = ref.watch(activeAccountProvider);
    final info = ref.watch(accountInfoProvider);
    final selected = ref.watch(selectedServerProvider);
    final selectedServer = selected == null ? null : ref.watch(serverByIdProvider(selected));

    Widget row(String name, String value, {Color? color}) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(name, style: TextStyle(color: t.onSurfaceMuted)),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    Widget probeRow(String name, ProbeResult? r) => row(
      name,
      r == null ? (_checking ? 'Checking...' : 'Idle') : r.summary,
      color: r == null ? t.onSurfaceMuted : (r.passed ? t.success : t.error),
    );

    final tokenNote = switch (info) {
      AsyncData() => ('Accepted by exaroton', t.success),
      AsyncError(:final error) when error is ExarotonException && error.isUnauthorized => (
        'Rejected - sign in again with a new token',
        t.error,
      ),
      AsyncError(:final error) => ('Not checked - ${describeError(error).title}', t.warning),
      _ => ('Checking...', t.onSurfaceMuted),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Debug')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(gutter, 8, gutter, 32),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('API', style: label),
                  row('Endpoint', exarotonApiBase),
                  probeRow('Anonymous', _anonymous),
                  probeRow('Account', _account),
                  if (selected != null || _server != null) probeRow('Selected server', _server),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton(
                        onPressed: _checking ? null : _probeAnonymous,
                        child: const Text('Anonymous probe'),
                      ),
                      FilledButton(
                        onPressed: _checking || stored == null ? null : _probeAuthenticated,
                        child: const Text('Authenticated probe'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'The anonymous probe checks that exaroton can be reached. The authenticated probe reads the '
                    'account and the selected server with your token. Nothing is changed.',
                    style: TextStyle(color: t.onSurfaceMuted, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Account', style: label),
                  row('Saved as', stored?.name ?? 'No account'),
                  if (info.value case final a?) ...[
                    row('Email', a.email.isEmpty ? 'Not reported' : a.email),
                    row('Credits', formatCredits(a.credits)),
                    row('Server limit', a.maxServers == null ? 'Not reported' : '${a.maxServers}'),
                    row('Verified', a.verified ? 'Yes' : 'No'),
                  ],
                  row('Token', tokenNote.$1, color: tokenNote.$2),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Live connection', style: label),
                  if (selectedServer == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Open a server first to check its websocket.',
                        style: TextStyle(color: t.onSurfaceMuted),
                      ),
                    )
                  else ...[
                    row('Server', '${selectedServer.name} (${selectedServer.status.label})'),
                    _SocketRow(serverId: selectedServer.id, row: row),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Version', style: label),
                  row('App', '$appVersionName (build $appVersionCode)'),
                  row('Dart', Platform.version.split(' ').first),
                  row('Platform', '${Platform.operatingSystem} ${Platform.operatingSystemVersion}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Websocket state of one server. Watching the session opens the socket
/// while this screen is up, the same read-only one the console uses.
class _SocketRow extends ConsumerWidget {
  const _SocketRow({required this.serverId, required this.row});
  final String serverId;
  final Widget Function(String name, String value, {Color? color}) row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final session = ref.watch(liveSessionProvider(serverId));
    if (session == null) return row('Websocket', 'Not available', color: t.onSurfaceMuted);
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) => switch (session.socketState) {
        SocketState.ready => row('Websocket', 'Ready', color: t.success),
        SocketState.connecting => row('Websocket', 'Connecting...', color: t.onSurfaceMuted),
        SocketState.reconnecting => row('Websocket', 'Reconnecting - the connection dropped', color: t.warning),
        SocketState.closed => row('Websocket', 'Closed', color: t.onSurfaceMuted),
      },
    );
  }
}
