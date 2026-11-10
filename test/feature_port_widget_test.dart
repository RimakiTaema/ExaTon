import 'dart:async';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:exaton/core/storage/account_store.dart';
import 'package:exaton/core/storage/database.dart';
import 'package:exaton/features/accounts/accounts.dart';
import 'package:exaton/features/charts/time_series_chart.dart';
import 'package:exaton/features/console/live_session.dart';
import 'package:exaton/features/debug/debug_screen.dart';
import 'package:exaton/features/servers/access_tab.dart';
import 'package:exaton/features/servers/recent_servers.dart';
import 'package:exaton/features/settings/settings.dart';
import 'package:exaton/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'support/fake_api.dart';

class _Store extends AccountStore {
  @override
  Future<List<StoredAccount>> load() async => const [StoredAccount(id: 'acc1', name: 'Main', token: 't')];
  @override
  Future<String?> activeId() async => 'acc1';
  @override
  Future<void> setActive(String id) async {}
}

/// A websocket the test can speak through.
class FakeChannel with StreamChannelMixin<dynamic> implements WebSocketChannel {
  final incoming = StreamController<dynamic>();
  final _out = StreamController<dynamic>();
  late final _Sink _sink = _Sink(_out);

  void say(String stream, String type, [Object? data]) =>
      incoming.add(jsonEncode({'stream': stream, 'type': type, 'data': ?data}));

  @override
  Stream<dynamic> get stream => incoming.stream;
  @override
  WebSocketSink get sink => _sink;
  @override
  String? get protocol => null;
  @override
  int? get closeCode => null;
  @override
  String? get closeReason => null;
  @override
  Future<void> get ready => Future.value();
}

class _Sink implements WebSocketSink {
  _Sink(this._c);
  final StreamController<dynamic> _c;
  @override
  void add(dynamic data) {}
  @override
  void addError(Object error, [StackTrace? stackTrace]) {}
  @override
  Future<void> addStream(Stream<dynamic> stream) => stream.drain<void>();
  @override
  Future<void> close([int? closeCode, String? closeReason]) => _c.close();
  @override
  Future<void> get done => _c.done;
}

Map<String, Object?> server(String id, String name, int status, {bool shared = false, List<String>? permissions}) => {
  'id': id,
  'name': name,
  'address': '${name.toLowerCase()}.exaroton.me',
  'motd': '',
  'status': status,
  'players': {'max': 20, 'count': 0, 'list': <String>[]},
  'software': {
    'id': 'SwPaper000001210',
    'name': 'Paper',
    'version': '1.21',
    'type': 'paper',
    'addons': ['plugin'],
  },
  'shared': shared,
  'permissions': permissions,
};

const alpha = 'Srv00000000000A1', beta = 'Srv00000000000B2', gamma = 'Srv00000000000C3';

/// An account with a limit of 10: Alpha (owned, online), Beta (owned,
/// offline) and Gamma (shared, offline).
Map<String, (int, Object?)> routes() => {
  'GET /account/': (200, fixture('account_max_servers')),
  'GET /servers/': (
    200,
    ok([
      server(alpha, 'Alpha', 1),
      server(beta, 'Beta', 0),
      server(gamma, 'Gamma', 0, shared: true, permissions: ['console', 'players']),
    ]),
  ),
  'GET /billing/pools/': (200, ok(<Object>[])),
  for (final id in [alpha, beta, gamma]) ...{
    'GET /servers/$id/options/ram/': (200, ok({'ram': 4})),
    'GET /servers/$id/options/motd/': (200, ok({'motd': 'Hi'})),
    'GET /servers/$id/logs/': (
      200,
      ok({'content': '[12:00:00] [Server thread/INFO]: Done (3.2s)!\n[12:00:05] [Server thread/WARN]: Slow tick'}),
    ),
    'GET /servers/$id/': (200, ok(server(id, 'Probe', 0))),
  },
  'GET /software/': (200, fixture('software_list')),
  'GET /servers/$beta/software/SwPack0000000001/': (200, fixture('software_details')),
};

late FakeAdapter api;
late AppDatabase db;
final channels = <FakeChannel>[];

Future<void> settle(WidgetTester tester, [int n = 12]) async {
  for (var i = 0; i < n; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> pumpApp(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  Map<String, (int, Object?)>? extra,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  api = FakeAdapter({...routes(), ...?extra});
  channels.clear();
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        databaseProvider.overrideWithValue(db),
        initialSettingsProvider.overrideWithValue(const AppSettings(alertsEnabled: false)),
        accountStoreProvider.overrideWithValue(_Store()),
        clientFactoryProvider.overrideWithValue((token) => fakeClient(api, token)),
        socketConnectorProvider.overrideWithValue((uri, headers) {
          final c = FakeChannel();
          channels.add(c);
          return c;
        }),
        probeDioProvider.overrideWithValue(() => fakeClient(api).dio),
      ],
      child: const ExaTonApp(),
    ),
  );
  await settle(tester, 20);
}

Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

Future<void> openTab(WidgetTester tester, String label) async {
  final tab = find.widgetWithText(Tab, label);
  await tester.ensureVisible(tab);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(tab);
  await settle(tester);
}

Iterable<String> mutating() => api.requests.where((r) => r.method != 'GET').map((r) => '${r.method} ${r.uri.path}');

void main() {
  testWidgets('header shows owned servers against the account limit', (tester) async {
    await pumpApp(tester);
    // Gamma is shared, so it does not count.
    expect(find.textContaining('2 / 10 servers'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('add server: needs a name and software, and Cancel creates nothing', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip('Add server'));
    await settle(tester);
    expect(find.text('Add server'), findsOneWidget);
    FilledButton create() => tester.widget(find.widgetWithText(FilledButton, 'Create server'));
    expect(create().onPressed, isNull);

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'example');
    await tester.pump();
    expect(create().onPressed, isNull, reason: 'software is still missing');

    await tester.tap(find.text('Choose software'));
    await settle(tester);
    expect(find.text('Latest vanilla'), findsOneWidget);
    expect(find.text('Vanilla 1.20.4'), findsOneWidget);
    await tester.tap(find.text('Latest vanilla'));
    await settle(tester);
    expect(find.text('Latest vanilla'), findsOneWidget);
    expect(create().onPressed, isNotNull);

    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.text('Create server'), findsNothing);
    expect(mutating(), isEmpty);
    await unmount(tester);
  });

  testWidgets('add server: create posts the form, and the limit error names the maximum', (tester) async {
    await pumpApp(tester, extra: {'POST /servers/': (413, fixture('server_limit'))});
    await tester.tap(find.byTooltip('Add server'));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'example');
    await tester.tap(find.text('Choose software'));
    await settle(tester);
    await tester.tap(find.text('Paper 1.21'));
    await settle(tester);
    await tester.tap(find.text('Create server'));
    await settle(tester);
    expect(api.requests.lastWhere((r) => r.method == 'POST').data, {'name': 'example', 'software': 'SwPaper000001210'});
    expect(find.text('Server limit reached (10 max)'), findsOneWidget);
    expect(find.text('Create server'), findsOneWidget, reason: 'the dialog stays open to fix or cancel');
    await unmount(tester);
  });

  testWidgets('logs tab loads the log; overview shows software and sharing', (tester) async {
    await pumpApp(tester);
    await tester.scrollUntilVisible(find.text('Gamma'), 200, scrollable: find.byType(Scrollable).first);
    // Clear of the bottom bar before tapping.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -200));
    await settle(tester, 4);
    await tester.tap(find.text('Gamma'));
    await settle(tester);
    // Shared with console and players: no Files or Config tab.
    expect(find.widgetWithText(Tab, 'Logs'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Files'), findsNothing);
    expect(find.widgetWithText(Tab, 'Players'), findsOneWidget);

    await openTab(tester, 'Logs');
    expect(find.textContaining('Done (3.2s)!'), findsOneWidget);
    expect(find.textContaining('Slow tick'), findsOneWidget);
    expect(find.byTooltip('Share log on mclo.gs'), findsOneWidget);

    // Sharing lives on its own tab: what was granted and what that opens.
    await openTab(tester, 'Access');
    expect(find.text('Shared'), findsOneWidget);
    expect(find.text('console'), findsOneWidget);
    expect(find.text('Read the console and send commands'), findsOneWidget);
    expect(find.text('players'), findsOneWidget);
    expect(find.text('Manage player lists: whitelist, operators and bans'), findsOneWidget);
    final list = find.descendant(of: find.byType(AccessTab), matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(find.text('Software and delete'), 200, scrollable: list);
    expect(find.text('Available'), findsNWidgets(2), reason: 'console and players');
    expect(find.text('Not available'), findsNWidgets(4), reason: 'files, config, options and owner-only');

    await openTab(tester, 'Overview');
    expect(find.text('Shared'), findsNothing);
    expect(find.text('Paper 1.21'), findsOneWidget);
    // Owner-only actions are hidden on a shared server.
    expect(find.text('Change software'), findsNothing);
    expect(find.text('Delete server'), findsNothing);
    await unmount(tester);
  });

  testWidgets('overview charts memory and tick time from the live streams', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Alpha'));
    await settle(tester);
    expect(find.widgetWithText(Tab, 'Access'), findsNothing, reason: 'own servers have no Access tab');
    await openTab(tester, 'Overview');
    expect(find.text('No samples yet - stats stream in progress.'), findsOneWidget);
    expect(find.byType(TimeSeriesChart), findsNothing);
    expect(find.textContaining('RAM allocated'), findsOneWidget);

    final ch = channels.last;
    ch.say('status', 'ready');
    await settle(tester, 3);
    ch.say('stats', 'stats', {
      'memory': {'percent': 50, 'usage': 2 * 1024 * 1024 * 1024},
    });
    ch.say('tick', 'tick', {'averageTickTime': 42.5});
    await settle(tester, 10);
    expect(find.byType(TimeSeriesChart), findsNWidgets(2), reason: 'memory and tick; no TPS in the payload');
    expect(find.text('TPS'), findsNothing);
    expect(find.text('No samples yet - stats stream in progress.'), findsNothing);

    ch.say('tick', 'tick', {'averageTickTime': 50, 'tps': 20});
    await settle(tester, 10);
    expect(find.byType(TimeSeriesChart), findsNWidgets(3), reason: 'TPS is charted once the payload carries it');
    await unmount(tester);
  });

  testWidgets('delete: an online server must be stopped first, and nothing is sent', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip('Actions for Alpha'));
    await settle(tester, 10);
    await tester.tap(find.text('Delete server'));
    await settle(tester, 10);
    expect(find.text('Stop Alpha first'), findsOneWidget);
    expect(find.text('Stop server'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await settle(tester, 10);
    expect(mutating(), isEmpty);
    expect(api.requests.where((r) => r.uri.path.endsWith('/stop/')), isEmpty);
    await unmount(tester);
  });

  testWidgets('delete: shared servers have no delete action', (tester) async {
    await pumpApp(tester);
    await tester.scrollUntilVisible(
      find.byTooltip('Actions for Gamma'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    // Clear of the bottom bar before tapping.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -200));
    await settle(tester, 4);
    await tester.tap(find.byTooltip('Actions for Gamma'));
    await settle(tester, 10);
    expect(find.text('Start with my credits'), findsOneWidget);
    expect(find.text('Delete server'), findsNothing);
    await unmount(tester);
  });

  testWidgets('delete: warns that files are lost; Cancel keeps the server, confirm deletes it', (tester) async {
    await pumpApp(tester, extra: {'DELETE /servers/$beta/': (200, ok(null))});
    Future<void> openDelete() async {
      await tester.tap(find.byTooltip('Actions for Beta'));
      await settle(tester, 10);
      await tester.tap(find.text('Delete server'));
      await settle(tester, 10);
    }

    await openDelete();
    expect(find.text('Delete Beta?'), findsOneWidget);
    expect(find.textContaining('permanently deleted'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await settle(tester, 10);
    expect(mutating(), isEmpty);

    await openDelete();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete server'));
    await settle(tester);
    expect(mutating(), ['DELETE /v1/servers/$beta/']);
    expect(find.text('Beta deleted'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('change software: a reinstall is confirmed twice and Cancel installs nothing', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Beta'));
    await settle(tester);
    await openTab(tester, 'Overview');
    await tester.scrollUntilVisible(find.text('Change software'), 200, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('Change software'));
    await settle(tester);
    expect(find.textContaining('installed'), findsOneWidget, reason: 'the current software is marked');
    await tester.tap(find.text('All the Mods 9 0.2.60'));
    await settle(tester);
    expect(find.textContaining('Every file on the server is deleted'), findsOneWidget);
    await tester.tap(find.text('Reinstall...'));
    await settle(tester, 10);
    expect(find.text('Reinstall Beta?'), findsOneWidget);
    await tester.tap(find.text('Cancel').last);
    await settle(tester, 10);
    expect(mutating(), isEmpty);
    await unmount(tester);
  });

  testWidgets('recent servers: the phone lists opened servers under the Recent filter', (tester) async {
    await pumpApp(tester);
    expect(find.text('Recent 0'), findsOneWidget);
    await tester.tap(find.text('Beta'));
    await settle(tester);
    await tester.tap(find.byTooltip('Back to servers'));
    await settle(tester);
    expect(find.text('Recent 1'), findsOneWidget);
    // The chip row scrolls sideways; bring the last chip in.
    await tester.ensureVisible(find.text('Recent 1'));
    await settle(tester, 4);
    await tester.tap(find.text('Recent 1'));
    await settle(tester);
    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('Alpha'), findsNothing);
    final stored = decodeRecent(await tester.runAsync<Map<String, dynamic>?>(() => db.readJson(recentServersKey)));
    expect(stored.map((r) => (r.id, r.accountId)), [(beta, 'acc1')]);
    await unmount(tester);
  });

  testWidgets('phone: Account is the last bottom button and opens the switcher without leaving the page', (
    tester,
  ) async {
    await pumpApp(tester);
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect((bar.destinations.last as NavigationDestination).label, 'Account');
    await tester.tap(find.text('Account'));
    await settle(tester);
    expect(find.text('Accounts'), findsOneWidget);
    expect(find.text('Add account'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex, 0);
    await unmount(tester);
  });

  testWidgets('rail: logo on top, then recent between separators, Account and Settings at the bottom', (tester) async {
    await pumpApp(tester, size: const Size(1280, 900));
    final rail = find.byType(NavigationRail);
    Finder inRail(Finder f) => find.descendant(of: rail, matching: f);
    expect(inRail(find.byType(Image)), findsOneWidget);
    final logo = tester.getCenter(inRail(find.byType(Image))).dy;
    final credits = tester.getCenter(inRail(find.text('Credits'))).dy;
    final account = tester.getCenter(inRail(find.text('Account'))).dy;
    final settings = tester.getCenter(inRail(find.text('Settings'))).dy;
    expect(logo < credits && credits < account && account < settings, isTrue);
    expect(settings, greaterThan(820), reason: 'pinned to the bottom of a 900 px window');

    await tester.tap(find.text('Beta'));
    await settle(tester);
    await tester.tap(find.text('Alpha').first);
    await settle(tester);
    final recent = tester.getCenter(inRail(find.text('Recent'))).dy;
    expect(credits < recent && recent < account, isTrue);

    await tester.tap(inRail(find.text('Settings')));
    await settle(tester);
    expect(find.text('Theme'), findsOneWidget);
    await tester.tap(inRail(find.text('Account')));
    await settle(tester);
    expect(find.text('Add account'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('recent servers: the rail lists them on wide windows, without the open one', (tester) async {
    await pumpApp(tester, size: const Size(1280, 900));
    // Alpha is selected by default and was not opened by the user.
    expect(find.text('Recent'), findsNothing);
    await tester.tap(find.text('Beta'));
    await settle(tester);
    await tester.tap(find.text('Alpha').first);
    await settle(tester);
    expect(find.text('Recent'), findsOneWidget);
    expect(find.byTooltip('Beta - Offline'), findsOneWidget);
    expect(find.byTooltip('Alpha - Online'), findsNothing);
    await unmount(tester);
  });

  testWidgets('debug screen: opens from Settings and both probes report', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Settings').last);
    await settle(tester, 10);
    await tester.scrollUntilVisible(find.text('Debug'), 300, scrollable: find.byType(Scrollable).first);
    // Clear of the bottom bar before tapping.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -200));
    await settle(tester, 4);
    await tester.tap(find.text('Debug'));
    await settle(tester);
    expect(find.text('main@example.com'), findsOneWidget);
    expect(find.text('Accepted by exaroton'), findsOneWidget);
    expect(find.text('Idle'), findsNWidgets(2));

    await tester.tap(find.text('Authenticated probe'));
    await settle(tester);
    expect(find.textContaining('Passed - HTTP 200'), findsOneWidget);

    // The fake API has no "/" route, so it answers 404: reached, so passed.
    await tester.tap(find.text('Anonymous probe'));
    await settle(tester);
    expect(find.textContaining('Passed - HTTP 404'), findsOneWidget);
    expect(mutating(), isEmpty);

    await tester.scrollUntilVisible(
      find.text('1.0.0 (build 1)'),
      200,
      scrollable: find.descendant(of: find.byType(DebugScreen), matching: find.byType(Scrollable)).first,
    );
    expect(find.text('1.0.0 (build 1)'), findsOneWidget);
    await unmount(tester);
  });
}
