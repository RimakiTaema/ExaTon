import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';

import '../../core/exaroton/client.dart';
import '../../core/exaroton/models.dart';
import '../../core/storage/account_store.dart';

/// The Android widget provider class (android/app/src/main/kotlin).
const widgetProvider = 'net.rimaki.exatonext.ServerWidgetProvider';

/// What the home-screen widget shows for one server, as the strings the
/// Kotlin provider reads.
Map<String, String> widgetData({required String accountId, Server? server, double? credits}) {
  if (server == null) {
    return {'accountId': accountId, 'serverId': '', 'name': 'No server', 'status': 'Open ExaTon', 'action': ''};
  }
  final status = server.status;
  final players = status == ServerStatus.online ? ' - ${server.players.count}/${server.players.max} players' : '';
  return {
    'accountId': accountId,
    'serverId': server.id,
    'name': server.name,
    'status': '${status.label}$players',
    'statusGroup': status.group.name,
    // Left out when unknown, so a background update keeps the last value.
    if (credits != null) 'credits': '${credits.toStringAsFixed(2)} credits',
    // Shared servers may not allow start and stop; the app handles those.
    'action': server.shared
        ? ''
        : switch (status.group) {
            StatusGroup.online => 'stop',
            StatusGroup.offline || StatusGroup.crashed => 'start',
            _ => '',
          },
  };
}

/// Sends [data] to the widget. Android only; does nothing elsewhere.
Future<void> pushWidget(Map<String, String> data) async {
  if (!Platform.isAndroid) return;
  try {
    for (final e in data.entries) {
      await HomeWidget.saveWidgetData<String>(e.key, e.value);
    }
    await HomeWidget.updateWidget(qualifiedAndroidName: widgetProvider);
  } catch (_) {
    // No widget placed, or the plugin is missing (tests): nothing to do.
  }
}

/// The server the widget follows, from its saved data.
Future<String?> widgetServerId() async {
  if (!Platform.isAndroid) return null;
  try {
    final id = await HomeWidget.getWidgetData<String>('serverId');
    return id == null || id.isEmpty ? null : id;
  } catch (_) {
    return null;
  }
}

/// Lets the widget's Start or Stop button run without opening the app.
Future<void> registerWidgetActions() async {
  if (!Platform.isAndroid) return;
  try {
    await HomeWidget.registerInteractivityCallback(widgetAction);
  } catch (_) {}
}

/// Parses the button's `exaton://start?server=..&account=..` link.
({String action, String serverId, String accountId})? parseWidgetAction(Uri? uri) {
  if (uri == null || uri.scheme != 'exaton') return null;
  final action = uri.host;
  final server = uri.queryParameters['server'];
  final account = uri.queryParameters['account'];
  if (!{'start', 'stop'}.contains(action) || server == null || account == null) return null;
  return (action: action, serverId: server, accountId: account);
}

/// Runs in a background isolate when the widget button is tapped.
@pragma('vm:entry-point')
Future<void> widgetAction(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  final a = parseWidgetAction(uri);
  if (a == null) return;
  final accounts = await AccountStore().load();
  final account = accounts.where((x) => x.id == a.accountId).firstOrNull;
  if (account == null) return;
  final client = ExarotonClient(account.token);
  try {
    await HomeWidget.saveWidgetData<String>('status', a.action == 'start' ? 'Starting...' : 'Stopping...');
    await HomeWidget.saveWidgetData<String>('action', '');
    await HomeWidget.updateWidget(qualifiedAndroidName: widgetProvider);
    if (a.action == 'start') {
      await client.start(a.serverId);
    } else {
      await client.stop(a.serverId);
    }
  } catch (e) {
    final msg = e is ExarotonException ? e.message : 'Could not reach exaroton';
    await HomeWidget.saveWidgetData<String>('status', msg);
    await HomeWidget.updateWidget(qualifiedAndroidName: widgetProvider);
  } finally {
    client.close();
  }
}
