import 'package:drift/native.dart';
import 'package:exaton/core/exaroton/models.dart';
import 'package:exaton/core/storage/database.dart';
import 'package:exaton/features/credits/alerts.dart';
import 'package:exaton/features/servers/status_alerts.dart';
import 'package:exaton/features/settings/settings.dart';
import 'package:flutter_test/flutter_test.dart';

Server srv(String id, ServerStatus status) => Server.fromJson({
  'id': id,
  'name': 'S$id',
  'address': 's$id.exaroton.me',
  'motd': '',
  'status': status.code,
  'players': {'max': 20, 'count': 0, 'list': <String>[]},
  'shared': false,
});

void main() {
  const all = {StatusEvent.crashed, StatusEvent.online, StatusEvent.offline};

  test('alerts on real moves only, and only for wanted events', () {
    final before = {'a': ServerStatus.online.code, 'b': ServerStatus.starting.code, 'c': ServerStatus.crashed.code};
    final now = [
      srv('a', ServerStatus.crashed),
      srv('b', ServerStatus.online),
      srv('c', ServerStatus.offline), // after a crash: no second alert
      srv('new', ServerStatus.crashed), // unknown before: no alert
    ];
    final alerts = statusAlerts(before, now, all);
    expect(alerts.map((a) => '${a.server.id}:${a.event.name}'), ['a:crashed', 'b:online']);
    expect(alerts.first.title, 'Sa crashed');
    expect(statusAlerts(before, now, {StatusEvent.online}).single.server.id, 'b');
    expect(statusAlerts({'a': ServerStatus.online.code}, [srv('a', ServerStatus.stopping)], all), isEmpty);
    expect(
      statusAlerts({'a': ServerStatus.stopping.code}, [srv('a', ServerStatus.offline)], all).single.event,
      StatusEvent.offline,
    );
  });

  test('stored statuses are shared, so a change alerts once', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    expect(await checkStatuses(db, 'acc', [srv('a', ServerStatus.online)], all), isEmpty, reason: 'first sight');
    expect((await checkStatuses(db, 'acc', [srv('a', ServerStatus.crashed)], all)).single.event, StatusEvent.crashed);
    expect(await checkStatuses(db, 'acc', [srv('a', ServerStatus.crashed)], all), isEmpty, reason: 'already told');
    // Recorded with alerts off too, so turning them on replays nothing.
    expect(await checkStatuses(db, 'acc', [srv('a', ServerStatus.online)], const {}), isEmpty);
    expect(await checkStatuses(db, 'acc', [srv('a', ServerStatus.online)], all), isEmpty);
  });

  test('settings keep the chosen events; crashes are on by default', () {
    expect(const AppSettings().statusAlerts, {StatusEvent.crashed});
    final s = const AppSettings(alertsEnabled: false).copyWith(statusAlerts: {StatusEvent.online});
    final back = AppSettings.fromJson(s.toJson());
    expect(back.statusAlerts, {StatusEvent.online});
    expect(back.needsBackgroundCheck, isTrue);
    expect(backgroundFrequency(back), const Duration(minutes: 15));
    final none = back.copyWith(statusAlerts: {});
    expect(AppSettings.fromJson(none.toJson()).statusAlerts, isEmpty);
    expect(none.needsBackgroundCheck, isFalse);
    expect(backgroundFrequency(none.copyWith(alertsEnabled: true)), const Duration(hours: 1));
  });
}
