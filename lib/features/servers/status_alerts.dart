import '../../core/exaroton/models.dart';
import '../../core/storage/database.dart';

/// Server status changes a notification can be sent for.
enum StatusEvent {
  crashed('Crashed', 'A server crashes'),
  online('Online', 'A server finishes starting'),
  offline('Stopped', 'A server stops');

  const StatusEvent(this.label, this.description);
  final String label;
  final String description;
}

/// One notification to send.
class StatusAlert {
  const StatusAlert(this.server, this.event);
  final Server server;
  final StatusEvent event;

  String get title => switch (event) {
    StatusEvent.crashed => '${server.name} crashed',
    StatusEvent.online => '${server.name} is online',
    StatusEvent.offline => '${server.name} stopped',
  };

  String get body => switch (event) {
    StatusEvent.crashed => 'Open ExaTon to read the log or restart it.',
    StatusEvent.online => 'Join at ${server.address}.',
    StatusEvent.offline => 'It is no longer using credits.',
  };
}

/// Alerts for the moves from [before] (server ID to status code) to [now].
/// A server not in [before] is new to the app and never alerts.
List<StatusAlert> statusAlerts(Map<String, int> before, List<Server> now, Set<StatusEvent> wanted) {
  final out = <StatusAlert>[];
  for (final s in now) {
    final old = before[s.id];
    if (old == null || old == s.status.code) continue;
    final prev = ServerStatus.fromCode(old);
    final event = switch (s.status) {
      ServerStatus.crashed => StatusEvent.crashed,
      ServerStatus.online => StatusEvent.online,
      // A crashed server going offline already alerted as a crash.
      ServerStatus.offline when prev != ServerStatus.crashed => StatusEvent.offline,
      _ => null,
    };
    if (event != null && wanted.contains(event)) out.add(StatusAlert(s, event));
  }
  return out;
}

/// Compares [servers] with the statuses stored for [accountId], stores the
/// new ones, and returns what to notify. Shared by the app and the Android
/// background check so neither repeats the other's alert.
Future<List<StatusAlert>> checkStatuses(
  AppDatabase db,
  String accountId,
  List<Server> servers,
  Set<StatusEvent> wanted,
) async {
  final key = 'status.$accountId';
  final stored = await db.readJson(key) ?? const {};
  final before = {
    for (final e in stored.entries)
      if (e.value is num) e.key: (e.value as num).toInt(),
  };
  final now = {for (final s in servers) s.id: s.status.code};
  final alerts = statusAlerts(before, servers, wanted);
  if (!_same(before, now)) await db.writeJson(key, now);
  return alerts;
}

bool _same(Map<String, int> a, Map<String, int> b) =>
    a.length == b.length && a.entries.every((e) => b[e.key] == e.value);
