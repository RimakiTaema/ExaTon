// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';

import 'package:exaton/exaroton/src/apis/server.dart';
import 'package:exaton/exaroton/src/env/env.dart';
import 'package:exaton/extra/AuthStorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openapi_client/api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Server> _servers = const [];
  bool _loading = true;
  String? _busyServerId;
  String? _fetchError;

  final Map<String, WebSocket> _statusSockets = <String, WebSocket>{};
  final Set<String> _connectingServerIds = <String>{};
  final Map<String, int?> _serverRamGb = <String, int?>{};
  final Map<String, _ServerStats> _serverStats = <String, _ServerStats>{};
  final Map<String, int?> _lastStatusByServer = <String, int?>{};

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  @override
  void dispose() {
    for (final socket in _statusSockets.values) {
      socket.close();
    }
    _statusSockets.clear();
    super.dispose();
  }

  Future<void> _loadServers() async {
    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _servers = const [];
        _loading = false;
        _fetchError = null;
      });
      return;
    }

    try {
      final servers = await GetServers(token: token).run();
      if (!mounted) return;
      setState(() {
        _servers = servers;
        _loading = false;
        _fetchError = null;
        for (final s in servers) {
          if (s.id != null) {
            _lastStatusByServer[s.id!] = s.status?.value;
          }
        }
      });
      await _syncServerSockets();
      _loadServerRam(token, servers);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _servers = const [];
        _loading = false;
        _fetchError = _fetchErrorMessage(e);
      });
    }
  }

  String _fetchErrorMessage(Object error) {
    if (error is ApiException && error.code == 429) {
      return 'Failed to fetch (too many request)';
    }
    return 'Failed to fetch servers';
  }

  Future<void> _syncServerSockets() async {
    final activeIds = _servers.map((s) => s.id).whereType<String>().toSet();

    final staleIds = _statusSockets.keys.where((id) => !activeIds.contains(id)).toList();
    for (final id in staleIds) {
      await _statusSockets[id]?.close();
      _statusSockets.remove(id);
      _serverStats.remove(id);
      _serverRamGb.remove(id);
      _lastStatusByServer.remove(id);
    }

    for (final id in activeIds) {
      await _connectServerSocket(id);
    }
  }

  Future<void> _connectServerSocket(String serverId) async {
    if (_statusSockets.containsKey(serverId) ||
        _connectingServerIds.contains(serverId)) {
      return;
    }

    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) return;

    _connectingServerIds.add(serverId);
    try {
      final restUri = Uri.parse('${Env.baseUrl}/servers/$serverId/websocket');
      final wsUri = restUri.replace(
        scheme: restUri.scheme == 'https' ? 'wss' : 'ws',
      );

      final socket = await WebSocket.connect(
        wsUri.toString(),
        headers: <String, dynamic>{'Authorization': 'Bearer $token'},
      );

      _statusSockets[serverId] = socket;
      socket.listen(
        (dynamic rawMessage) => _handleSocketMessage(serverId, rawMessage),
        onDone: () {
          _statusSockets.remove(serverId);
          _scheduleSocketReconnect(serverId);
        },
        onError: (_) {
          _statusSockets.remove(serverId);
          _scheduleSocketReconnect(serverId);
        },
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleSocketReconnect(serverId);
    } finally {
      _connectingServerIds.remove(serverId);
    }
  }

  void _scheduleSocketReconnect(String serverId) {
    final shouldReconnect = mounted && _servers.any((s) => s.id == serverId);
    if (!shouldReconnect) return;

    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_servers.any((s) => s.id == serverId)) {
        _connectServerSocket(serverId);
      }
    });
  }

  void _handleSocketMessage(String serverId, dynamic rawMessage) {
    try {
      final decoded = jsonDecode(rawMessage as String);
      if (decoded is! Map<String, dynamic>) return;

      if (decoded['stream'] == 'status' && decoded['type'] == 'status') {
        final payload = decoded['data'];
        if (payload is! Map) return;

        final updatedServer =
            Server.fromJson(Map<String, dynamic>.from(payload.cast<String, dynamic>()));
        if (updatedServer == null || updatedServer.id == null) return;
        _playStartedSoundIfNeeded(updatedServer.id!, updatedServer.status?.value);

        if (!mounted) return;
        setState(() {
          _servers = _servers.map((server) {
            if (server.id == updatedServer.id) {
              return updatedServer;
            }
            return server;
          }).toList(growable: false);
        });
      } else if (decoded['stream'] == 'stats' || decoded['type'] == 'stats') {
        final payload = decoded['data'];
        if (payload is! Map) return;
        final stats = _ServerStats.fromMap(Map<String, dynamic>.from(payload.cast<String, dynamic>()));
        if (!mounted) return;
        setState(() {
          _serverStats[serverId] = stats;
        });
      }
    } catch (_) {
      // Ignore malformed keep-alive/non-JSON messages.
    }
  }

  Future<void> _loadServerRam(String token, List<Server> servers) async {
    for (final server in servers) {
      final id = server.id;
      if (id == null) continue;
      try {
        final ramGb = await GetServerRam(token: token, serverId: id).run();
        if (!mounted) return;
        setState(() {
          _serverRamGb[id] = ramGb;
        });
      } catch (_) {
        // Ignore ram lookup errors per server.
      }
    }
  }

  Future<void> _runServerAction({
    required String serverId,
    required String action,
  }) async {
    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) return;

    setState(() {
      _busyServerId = serverId;
    });

    if (action == 'start') {
      _applyLocalStatusCode(serverId, 2);
    } else if (action == 'stop') {
      _applyLocalStatusCode(serverId, 3);
    } else if (action == 'restart') {
      _applyLocalStatusCode(serverId, 4);
    }

    try {
      final actions = ServerActions(token: token, serverId: serverId);
      if (action == 'start') {
        await actions.start();
      } else if (action == 'restart') {
        await actions.restart();
      } else if (action == 'stop') {
        await actions.stop();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Action "$action" Sent Successfully')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Action failed: $e')));
      await _loadServers();
    } finally {
      if (!mounted) return;
      setState(() {
        _busyServerId = null;
      });
    }
  }

  void _applyLocalStatusCode(String serverId, int statusCode) {
    final status = _statusFromCode(statusCode);
    if (status == null) return;

    setState(() {
      _servers = _servers.map((server) {
        if (server.id == serverId) {
          return Server(
            id: server.id,
            name: server.name,
            address: server.address,
            motd: server.motd,
            status: status,
            host: server.host,
            port: server.port,
            players: server.players,
            software: server.software,
            shared: server.shared,
          );
        }
        return server;
      }).toList(growable: false);
      _lastStatusByServer[serverId] = statusCode;
    });
  }

  void _playStartedSoundIfNeeded(String serverId, int? newStatusCode) {
    final previousStatus = _lastStatusByServer[serverId];
    _lastStatusByServer[serverId] = newStatusCode;
    if (previousStatus != 1 && newStatusCode == 1) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  ServerStatus? _statusFromCode(int code) {
    switch (code) {
      case 0:
        return ServerStatus.OFFLINE;
      case 1:
        return ServerStatus.ONLINE;
      case 2:
        return ServerStatus.STARTING;
      case 3:
        return ServerStatus.STOPPING;
      case 4:
        return ServerStatus.RESTARTING;
      case 5:
        return ServerStatus.SAVING;
      case 6:
        return ServerStatus.LOADING;
      case 7:
        return ServerStatus.CRASHED;
      case 8:
        return ServerStatus.PENDING;
      case 9:
        return ServerStatus.TRANSFERRING;
      case 10:
        return ServerStatus.PREPARING;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: ListView(
        children: [
          _searchBar(),
          const SizedBox(height: 40),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            _serverList(_servers),
        ],
      ),
    );
  }

  Widget _serverList(List<Server> servers) {
    final scheme = Theme.of(context).colorScheme;
    if (servers.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Servers (0)',
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20),
            Text(_fetchError ?? 'No servers found.'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Servers (${servers.length})',
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 40),
        ListView.separated(
          itemCount: servers.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(height: 25),
          padding: const EdgeInsets.only(left: 10, right: 10),
          itemBuilder: (context, index) {
            final server = servers[index];
            final serverId = server.id;
            final isBusy = _busyServerId == serverId;

            return Container(
              height: 220,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff1D1617).withOpacity(0.07),
                    offset: const Offset(0, 10),
                    blurRadius: 40,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        server.name ?? 'Unnamed Server',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurface,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        server.address ?? '-',
                        style: const TextStyle(
                          color: Color(0xff7B6F72),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _metricBar(
                              label: 'CPU',
                              valueText: _cpuText(serverId),
                              progress: _cpuProgress(serverId),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _metricBar(
                              label: 'RAM',
                              valueText: _ramText(serverId),
                              progress: _ramProgress(serverId),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _metricBar(
                              label: 'Players',
                              valueText: _playersText(server),
                              progress: _playersProgress(server),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _statusBadge(server.status?.value),
                      if (serverId != null) ..._actionButtonsForStatus(
                        serverId: serverId,
                        statusCode: server.status?.value,
                        isBusy: isBusy,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String _statusFor(int? statusCode) {
    switch (statusCode) {
      case 0:
        return 'Offline';
      case 1:
        return 'Online';
      case 2:
        return 'Starting';
      case 3:
        return 'Stopping';
      case 4:
        return 'Restarting';
      case 5:
        return 'Saving';
      case 6:
        return 'Loading';
      case 7:
        return 'Crashed';
      case 8:
        return 'Pending';
      case 9:
        return 'Transfer';
      case 10:
        return 'Preparing';
      default:
        return 'Unknown';
    }
  }

  Color _statusColor(int? statusCode) {
    switch (statusCode) {
      case 1:
        return Colors.lightGreenAccent;
      case 0:
      case 7:
        return Colors.redAccent;
      case 2:
      case 3:
      case 4:
      case 5:
      case 6:
      case 8:
      case 9:
      case 10:
        return Colors.orangeAccent;
      default:
        return Colors.blueGrey.shade200;
    }
  }

  Widget _statusBadge(int? statusCode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _statusColor(statusCode),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _statusIcon(statusCode),
            size: 14,
            color: Colors.blueGrey.shade900,
          ),
          const SizedBox(width: 6),
          Text(
            _statusFor(statusCode),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade900,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _actionButtonsForStatus({
    required String serverId,
    required int? statusCode,
    required bool isBusy,
  }) {
    final actions = _actionsForStatus(statusCode);
    if (actions.isEmpty) return const <Widget>[];

    return actions.map((action) {
      return Padding(
        padding: const EdgeInsets.only(left: 15),
        child: _actionButton(
          label: _actionLabel(action),
          color: _actionColor(action),
          enabled: !isBusy,
          onTap: () => _runServerAction(serverId: serverId, action: action),
        ),
      );
    }).toList(growable: false);
  }

  List<String> _actionsForStatus(int? statusCode) {
    switch (statusCode) {
      case 0:
      case 7:
        return const ['start'];
      case 1:
        return const ['stop', 'restart'];
      default:
        return const [];
    }
  }

  String _actionLabel(String action) {
    switch (action) {
      case 'start':
        return 'Start';
      case 'stop':
        return 'Stop';
      case 'restart':
        return 'Restart';
      default:
        return action;
    }
  }

  Color _actionColor(String action) {
    switch (action) {
      case 'start':
        return Colors.greenAccent;
      case 'stop':
        return Colors.redAccent;
      case 'restart':
        return Colors.yellowAccent;
      default:
        return Colors.blueGrey.shade200;
    }
  }

  Widget _metricBar({
    required String label,
    required String valueText,
    required double progress,
  }) {
    final clamped = progress.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xff7B6F72)),
            ),
            Text(
              valueText,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: clamped,
            minHeight: 6,
            color: const Color(0xff6BCB77),
            backgroundColor: const Color(0xffE9ECEF),
          ),
        ),
      ],
    );
  }

  String _cpuText(String? serverId) {
    final cpu = serverId == null ? null : _serverStats[serverId]?.cpuPercent;
    return cpu == null ? 'N/A' : '${cpu.toStringAsFixed(0)}%';
  }

  double _cpuProgress(String? serverId) {
    final cpu = serverId == null ? null : _serverStats[serverId]?.cpuPercent;
    if (cpu == null) return 0;
    return cpu / 100;
  }

  String _ramText(String? serverId) {
    final stats = serverId == null ? null : _serverStats[serverId];
    if (stats?.ramPercent != null) {
      return '${stats!.ramPercent!.toStringAsFixed(0)}%';
    }
    final ramGb = serverId == null ? null : _serverRamGb[serverId];
    return ramGb == null ? 'N/A' : '$ramGb GB';
  }

  double _ramProgress(String? serverId) {
    final ramPercent = serverId == null ? null : _serverStats[serverId]?.ramPercent;
    if (ramPercent == null) return 0;
    return ramPercent / 100;
  }

  String _playersText(Server server) {
    final online = server.players?.count ?? 0;
    final max = server.players?.max ?? 0;
    return '$online/$max';
  }

  double _playersProgress(Server server) {
    final online = server.players?.count ?? 0;
    final max = server.players?.max ?? 0;
    if (max <= 0) return 0;
    return online / max;
  }

  IconData _statusIcon(int? statusCode) {
    switch (statusCode) {
      case 1:
        return Icons.check_circle;
      case 0:
      case 7:
        return Icons.cancel;
      case 2:
      case 3:
      case 4:
      case 5:
      case 6:
      case 8:
      case 9:
      case 10:
        return Icons.autorenew;
      default:
        return Icons.help;
    }
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1D1617).withOpacity(0.11),
            blurRadius: 40,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: scheme.surfaceContainerLow,
          contentPadding: const EdgeInsets.all(15),
          hintText: 'Servers',
          hintStyle: const TextStyle(color: Color(0xffDDDADA), fontSize: 14),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: SizedBox(
            width: 100,
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  VerticalDivider(
                    color: Colors.black,
                    indent: 10,
                    endIndent: 10,
                    thickness: 0.1,
                  ),
                  Icon(Icons.filter),
                ],
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _ServerStats {
  final double? cpuPercent;
  final double? ramPercent;

  const _ServerStats({
    this.cpuPercent,
    this.ramPercent,
  });

  factory _ServerStats.fromMap(Map<String, dynamic> json) {
    double? normalize(dynamic value) {
      if (value is num) {
        final raw = value.toDouble();
        return raw <= 1 ? raw * 100 : raw;
      }
      return null;
    }

    dynamic readKey(List<String> keys) {
      for (final key in keys) {
        if (json.containsKey(key)) return json[key];
      }
      return null;
    }

    final cpu = normalize(readKey(const ['cpu', 'cpuUsage', 'cpu_percent']));
    final ram = normalize(
      readKey(const ['ram', 'memory', 'ramUsage', 'ram_percent', 'memory_percent']),
    );

    return _ServerStats(cpuPercent: cpu, ramPercent: ram);
  }
}
