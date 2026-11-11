import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

import '../../core/exaroton/client.dart';
import '../../core/storage/account_store.dart';
import '../../core/storage/database.dart';
import '../servers/status_alerts.dart';
import '../settings/settings.dart';
import 'credits.dart';
import 'estimate.dart';

/// Local-only low-credit alerts. Android checks in the background with
/// WorkManager about once an hour; on iOS and desktop the check runs only
/// while the app is open.
class CreditAlerts {
  CreditAlerts._();
  static final instance = CreditAlerts._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _channel = AndroidNotificationDetails(
    'credits_low',
    'Low credits',
    channelDescription: 'When time left on credits drops under your threshold',
    importance: Importance.defaultImportance,
  );

  static const _statusChannel = AndroidNotificationDetails(
    'server_status',
    'Server status',
    channelDescription: 'When a server crashes, comes online or stops',
    importance: Importance.high,
  );

  /// Notifies a server status change.
  Future<void> notifyStatus(StatusAlert a) async {
    await init();
    if (!_ready) return;
    try {
      await _plugin.show(
        id: 'status.${a.server.id}'.hashCode & 0x7fffffff,
        title: a.title,
        body: a.body,
        notificationDetails: const NotificationDetails(android: _statusChannel),
      );
    } catch (_) {}
  }

  Future<void> init() async {
    if (_ready) return;
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
          macOS: DarwinInitializationSettings(),
          linux: LinuxInitializationSettings(defaultActionName: 'Open ExaTon'),
          windows: WindowsInitializationSettings(
            appName: 'ExaTon',
            appUserModelId: 'net.rimaki.exatonext',
            guid: 'b5f2d9a4-1c3e-4f7a-9d2b-6e8c0a1f3b47',
          ),
        ),
      );
      _ready = true;
    } catch (_) {
      // Notifications are best effort; the in-app banner still shows.
    }
  }

  Future<void> requestPermission() async {
    await init();
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: false,
      sound: false,
    );
  }

  /// Fires once when a payer goes low, and again only after it recovers.
  Future<void> evaluate(CreditsOverview o, AppSettings settings, AppDatabase db, String accountId) async {
    if (!settings.alertsEnabled) return;
    final state = (await db.readJson('alerts.$accountId')) ?? {};
    var changed = false;
    final payers = [o.accountSummary, ...o.poolSummaries.values];
    for (final p in payers) {
      if (p.poolId != null && settings.mutedPools.contains(p.poolId)) continue;
      final key = p.poolId ?? 'account';
      final d = decideAlert(
        estimate: p.estimate,
        credits: p.credits,
        thresholdDays: settings.alertThresholdDays,
        creditFloor: settings.creditFloor,
        alreadyAlerted: state[key] == true,
      );
      if (d.shouldNotify) {
        await _notify(p);
        state[key] = true;
        changed = true;
      } else if (!d.low && state[key] == true) {
        state[key] = false; // Recovered: may alert again.
        changed = true;
      }
    }
    if (changed) await db.writeJson('alerts.$accountId', state);
  }

  Future<void> _notify(PayerSummary p) async {
    await init();
    if (!_ready) return;
    final left = p.estimate?.timeLeft;
    final what = p.poolId == null ? 'Your account' : p.name;
    final body = left != null
        ? '$what has ${formatTimeLeft(left)} of credits left (${p.credits.toStringAsFixed(2)} credits).'
        : '$what is down to ${p.credits.toStringAsFixed(2)} credits.';
    try {
      await _plugin.show(
        id: (p.poolId ?? 'account').hashCode & 0x7fffffff,
        title: 'Credits running low',
        body: body,
        notificationDetails: const NotificationDetails(android: _channel),
      );
    } catch (_) {}
  }
}

// ── Android background check ───────────────────────────────────────────

const backgroundTaskName = 'exaton.creditsCheck';

/// Every 15 minutes (Android's shortest) when status alerts are on, since a
/// crash an hour late is not much use; hourly for credit alerts alone.
Duration backgroundFrequency(AppSettings s) =>
    s.statusAlerts.isEmpty ? const Duration(hours: 1) : const Duration(minutes: 15);

Future<void> registerBackgroundCheck(AppSettings settings) async {
  if (!Platform.isAndroid) return;
  await Workmanager().initialize(backgroundDispatcher);
  if (!settings.needsBackgroundCheck) {
    await Workmanager().cancelByUniqueName(backgroundTaskName);
    return;
  }
  await Workmanager().registerPeriodicTask(
    backgroundTaskName,
    backgroundTaskName,
    frequency: backgroundFrequency(settings),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
  );
}

@pragma('vm:entry-point')
void backgroundDispatcher() {
  Workmanager().executeTask((task, _) async {
    WidgetsFlutterBinding.ensureInitialized();
    final db = AppDatabase.open();
    try {
      final settings = await AppSettings.load(db);
      if (!settings.needsBackgroundCheck) return true;
      final accounts = await AccountStore().load();
      for (final a in accounts) {
        final client = ExarotonClient(a.token);
        try {
          if (settings.statusAlerts.isNotEmpty) {
            final list = await client.getServers();
            for (final alert in await checkStatuses(db, a.id, list, settings.statusAlerts)) {
              await CreditAlerts.instance.notifyStatus(alert);
            }
          }
          if (!settings.alertsEnabled) continue;
          final account = await client.getAccount();
          await db.addSample(sampleOwner(a.id), account.credits);
          final pools = await client.getPools();
          for (final p in pools) {
            await db.addSample(sampleOwner(a.id, p.id), p.credits);
          }
          final typed = {for (final p in pools) p.id: await client.getPoolServers(p.id)};
          final servers = await client.getServers();
          final cache = await db.ramCache();
          final overview = await computeOverview(
            accountId: a.id,
            account: account,
            pools: pools,
            poolServers: typed,
            myServers: servers,
            settings: settings,
            db: db,
            ram: (ids) async {
              for (final id in ids.where((id) => !cache.containsKey(id))) {
                try {
                  cache[id] = await client.getRam(id);
                  await db.setRam(id, cache[id]!);
                } catch (_) {}
              }
              return cache;
            },
          );
          await CreditAlerts.instance.evaluate(overview, settings, db, a.id);
        } catch (_) {
          // Try again next hour.
        } finally {
          client.close();
        }
      }
      return true;
    } finally {
      await db.close();
    }
  });
}
