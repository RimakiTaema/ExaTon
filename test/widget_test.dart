import 'dart:async';

import 'package:drift/native.dart';
import 'package:exaton/core/storage/account_store.dart';
import 'package:exaton/core/storage/database.dart';
import 'package:exaton/features/accounts/accounts.dart';
import 'package:exaton/features/console/live_session.dart';
import 'package:exaton/features/settings/settings.dart';
import 'package:exaton/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'support/fake_api.dart';

class FakeAccountStore extends AccountStore {
  FakeAccountStore(this.accounts);
  final List<StoredAccount> accounts;

  @override
  Future<List<StoredAccount>> load() async => accounts;
  @override
  Future<String?> activeId() async => accounts.firstOrNull?.id;
  @override
  Future<void> setActive(String id) async {}
}

/// A websocket that connects and never speaks, so widget tests stay offline.
class SilentChannel with StreamChannelMixin<dynamic> implements WebSocketChannel {
  final _in = StreamController<dynamic>();
  final _out = StreamController<dynamic>();
  late final _SilentSink _sink = _SilentSink(_out);

  @override
  Stream<dynamic> get stream => _in.stream;
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

class _SilentSink implements WebSocketSink {
  _SilentSink(this._c);
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

Future<void> pumpApp(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  final api = FakeAdapter(standardRoutes());

  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        databaseProvider.overrideWithValue(db),
        initialSettingsProvider.overrideWithValue(const AppSettings(alertsEnabled: false)),
        accountStoreProvider.overrideWithValue(
          FakeAccountStore([const StoredAccount(id: 'acc1', name: 'Main', token: 't')]),
        ),
        clientFactoryProvider.overrideWithValue((token) => fakeClient(api, token)),
        socketConnectorProvider.overrideWithValue((uri, headers) => SilentChannel()),
      ],
      child: const ExaTonApp(),
    ),
  );
  // Let accounts, servers, pools and the RAM cache load. Busy servers show
  // a spinner forever, so pump a fixed time instead of pumpAndSettle.
  for (var i = 0; i < 20; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('compact: bottom bar, server cards and status groups', (tester) async {
    await pumpApp(tester, const Size(390, 844));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Servers'), findsWidgets);
    expect(find.textContaining('Signed in as Main'), findsOneWidget);
    expect(find.text('Survival SMP'), findsOneWidget);
    expect(find.text('Creative Plots'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Modded 1.20.1'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('Modded 1.20.1'), findsOneWidget);

    // Exact status names, never colour alone.
    expect(find.text('Online'), findsWidgets);
    expect(find.text('Starting'), findsWidgets);
    expect(find.text('Offline'), findsWidgets);

    // Online → Stop, Offline → Start, Busy → disabled.
    expect(find.text('Stop'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    final busy = tester.widget<OutlinedButton>(
      find.ancestor(of: find.text('Starting').last, matching: find.byType(OutlinedButton)),
    );
    expect(busy.onPressed, isNull);

    // Filters with counts.
    expect(find.text('All 3'), findsOneWidget);
    expect(find.text('Online 1'), findsOneWidget);
    expect(find.text('Offline 1'), findsOneWidget);

    // A 4 GB server in a 312-credit pool: about 3 days, under the 5-day threshold.
    expect(find.textContaining('1 pool low'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('compact: search filters by name or address', (tester) async {
    await pumpApp(tester, const Size(390, 844));
    await tester.enterText(find.byType(TextField).first, 'plots.exaroton');
    await tester.pump();
    expect(find.text('Creative Plots'), findsOneWidget);
    expect(find.text('Survival SMP'), findsNothing);
    await unmount(tester);
  });

  testWidgets('compact: credits screen shows pools as view only with time left', (tester) async {
    await pumpApp(tester, const Size(390, 844));
    await tester.tap(find.text('Credits').last);
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Your account'), findsOneWidget);
    expect(find.text('Balance history'), findsOneWidget);
    // The balance graph sits between the account and the pools.
    await tester.scrollUntilVisible(find.text('Friends SMP pool'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('View only'), findsOneWidget);
    expect(find.text('Friends SMP pool'), findsOneWidget);
    // 312 credits / (4 GB running + storage for 1 server) = ~77.7 hours.
    expect(find.text('~3 days left'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Paid by Friends SMP pool'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Paid by Friends SMP pool'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('medium: rail instead of bottom bar, list without detail pane', (tester) async {
    await pumpApp(tester, const Size(800, 1000));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Survival SMP'), findsOneWidget);
    expect(find.byType(TabBar), findsNothing);
    await unmount(tester);
  });

  testWidgets('expanded: rail, list and detail pane with tabs', (tester) async {
    await pumpApp(tester, const Size(1440, 900));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Ctrl K'), findsOneWidget);
    expect(find.text('Account credits'), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);
    for (final tab in ['Overview', 'Console', 'Players', 'Files', 'Config', 'Pool', 'Calculate']) {
      expect(find.widgetWithText(Tab, tab), findsOneWidget, reason: tab);
    }
    expect(find.text('Restart'), findsOneWidget);
    expect(find.text('Players online - 4'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('expanded: shared server hides tabs its permissions do not allow', (tester) async {
    await pumpApp(tester, const Size(1440, 900));
    await tester.tap(find.text('Modded 1.20.1'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.widgetWithText(Tab, 'Console'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Files'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Config'), findsNothing);
    expect(find.widgetWithText(Tab, 'Players'), findsNothing);
    await unmount(tester);
  });

  testWidgets('every icon button in the console has a label', (tester) async {
    await pumpApp(tester, const Size(1440, 900));
    for (final label in ['Copy lines', 'Clear console', 'Command history']) {
      expect(find.byTooltip(label), findsOneWidget, reason: label);
    }
    // Share log is in the toolbar when there is room, and always in the menu.
    if (find.byTooltip('Share log on mclo.gs').evaluate().isEmpty) {
      await tester.tap(find.byTooltip('Actions for Survival SMP').first);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Share log on mclo.gs'), findsOneWidget);
    }
    await unmount(tester);
  });
}
