// Spec, UX review P0 #1: every screen holds at text scale 1.0, 1.5 and 2.0
// at 390 px wide: no overflow, no balance wrapped inside itself, every
// action reachable. An overflow is a framework error, which fails the test.
import 'package:drift/native.dart';
import 'package:exaton/core/storage/account_store.dart';
import 'package:exaton/core/storage/database.dart';
import 'package:exaton/features/accounts/accounts.dart';
import 'package:exaton/features/accounts/migration.dart';
import 'package:exaton/features/console/live_session.dart';
import 'package:exaton/features/settings/settings.dart';
import 'package:exaton/main.dart';
import 'package:exaton/ui/components.dart';
import 'package:exaton/ui/motion.dart';
import 'package:exaton/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'migration_test.dart' show FakeLegacySource, settle;
import 'support/fake_api.dart';
import 'widget_test.dart' show FakeAccountStore, SilentChannel;

Map<String, (int, Object?)> richRoutes() => {
  ...standardRoutes(),
  'GET /servers/Srv0000000000001/options/motd/': (200, ok({'motd': 'Welcome to Survival'})),
  'GET /servers/Srv0000000000001/playerlists/': (200, ok(['whitelist', 'ops', 'banned-players'])),
  'GET /servers/Srv0000000000001/playerlists/whitelist/': (200, ok(['Steve', 'Kai', 'Mira'])),
  'GET /servers/Srv0000000000001/files/info/': (
    200,
    ok({
      'path': '/',
      'name': '',
      'isDirectory': true,
      'isReadable': true,
      'children': [
        {'path': 'world', 'name': 'world', 'isDirectory': true, 'isReadable': true},
        {
          'path': 'server.properties',
          'name': 'server.properties',
          'isConfigFile': true,
          'isTextFile': true,
          'isReadable': true,
          'isWritable': true,
          'size': 1200,
        },
      ],
    }),
  ),
  'GET /servers/Srv0000000000001/files/config/server.properties/': (200, fixture('config')),
};

Future<void> pumpAt(
  WidgetTester tester,
  double scale, {
  List<StoredAccount> accounts = const [StoredAccount(id: 'a', name: 'Main', token: 't')],
  List<LegacyAccount> legacy = const [],
  Size size = const Size(390, 844),
  ThemeModeSetting mode = ThemeModeSetting.dark,
}) async {
  FadeSlideIn.resetPlayed();
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  final api = FakeAdapter(richRoutes());
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        databaseProvider.overrideWithValue(db),
        initialSettingsProvider.overrideWithValue(AppSettings(alertsEnabled: false, theme: ThemeSettings(mode: mode))),
        accountStoreProvider.overrideWithValue(FakeAccountStore(accounts)),
        legacyTokenSourceProvider.overrideWithValue(FakeLegacySource(legacy)),
        clientFactoryProvider.overrideWithValue((token) => fakeClient(api, token)),
        socketConnectorProvider.overrideWithValue((uri, headers) => SilentChannel()),
      ],
      child: const ExaTonApp(),
    ),
  );
  await settle(tester);
}

/// Scrolls the first scrollable to the end so every lazily built child is
/// laid out at least once.
Future<void> scrollThrough(WidgetTester tester) async {
  final scrollables = find.byType(Scrollable);
  if (scrollables.evaluate().isEmpty) return;
  for (var i = 0; i < 8; i++) {
    await tester.drag(scrollables.first, const Offset(0, -400), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Scrolls until [f] is fully on screen, not just touching the edge.
Future<void> reveal(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(f, 200, scrollable: find.byType(Scrollable).first);
  await tester.ensureVisible(f);
  await tester.pump(const Duration(milliseconds: 300));
}

/// Every balance renders on one line.
void expectBalancesOnOneLine(WidgetTester tester) {
  for (final e in find.byType(CreditsAmount).evaluate()) {
    final paragraph = find.descendant(of: find.byWidget(e.widget), matching: find.byType(RichText));
    for (final p in paragraph.evaluate()) {
      final rp = p.renderObject! as RenderParagraph;
      // Laid out at least as wide as its widest single line: nothing wrapped.
      expect(
        rp.size.width,
        greaterThanOrEqualTo(rp.getMaxIntrinsicWidth(double.infinity) - 0.5),
        reason: 'balance wrapped inside the number',
      );
    }
  }
}

Future<void> goto(WidgetTester tester, String navLabel) async {
  await tester.tap(find.text(navLabel).last);
  await settle(tester, rounds: 12);
}

void main() {
  for (final scale in const [1.0, 1.5, 2.0]) {
    group('text scale $scale at 390 px', () {
      testWidgets('servers', (tester) async {
        await pumpAt(tester, scale);
        expectBalancesOnOneLine(tester);
        expect(find.text('Top up'), findsOneWidget);
        // Reachable means visible after scrolling, at any text size.
        await reveal(tester, find.text('Stop'));
        expect(find.text('Stop').hitTestable(), findsOneWidget);
        await reveal(tester, find.text('Start'));
        expect(find.text('Start').hitTestable(), findsOneWidget);
      });

      testWidgets('server detail, every tab', (tester) async {
        await pumpAt(tester, scale);
        await reveal(tester, find.text('Survival SMP'));
        await tester.tap(find.text('Survival SMP'));
        await settle(tester, rounds: 12);
        for (final tab in ['Overview', 'Console', 'Players', 'Files', 'Config', 'Pool']) {
          final f = find.widgetWithText(Tab, tab);
          await tester.ensureVisible(f);
          await tester.tap(f);
          await settle(tester, rounds: 10);
          await scrollThrough(tester);
        }
        // Stop stays reachable, as a button or in the overflow menu.
        final stopVisible = find.text('Stop').hitTestable().evaluate().isNotEmpty;
        if (!stopVisible) {
          await tester.tap(find.byTooltip('Actions for Survival SMP'));
          await settle(tester, rounds: 4);
          expect(find.text('Stop'), findsOneWidget);
        }
      });

      testWidgets('credits and pool detail', (tester) async {
        await pumpAt(tester, scale);
        await goto(tester, 'Credits');
        expectBalancesOnOneLine(tester);
        await scrollThrough(tester);
        await tester.drag(find.byType(Scrollable).first, const Offset(0, 4000));
        await settle(tester, rounds: 4);
        await reveal(tester, find.text('Friends SMP pool'));
        await tester.tap(find.text('Friends SMP pool'));
        await settle(tester, rounds: 12);
        expectBalancesOnOneLine(tester);
        await scrollThrough(tester);
        expect(find.text('Deposit').hitTestable(), findsOneWidget);
      });

      testWidgets('settings', (tester) async {
        await pumpAt(tester, scale);
        await goto(tester, 'Settings');
        await scrollThrough(tester);
      });

      testWidgets('console tab picker', (tester) async {
        await pumpAt(tester, scale);
        await goto(tester, 'Console');
        await scrollThrough(tester);
      });

      testWidgets('sign in', (tester) async {
        await pumpAt(tester, scale, accounts: const []);
        expect(find.text('Sign in'), findsOneWidget);
      });

      testWidgets('1.3 migration', (tester) async {
        await pumpAt(
          tester,
          scale,
          accounts: const [],
          legacy: const [LegacyAccount(email: 'someone.with.a.long.address@example.com', token: 'x')],
        );
        expect(find.text('Import 1 account'), findsOneWidget);
        await scrollThrough(tester);
      });
    });
  }

  for (final width in const [599.0, 600.0, 839.0, 840.0, 1024.0, 1440.0]) {
    testWidgets('layout at $width px', (tester) async {
      await pumpAt(tester, 1.0, size: Size(width, 900));
      final size = WindowSize.fromWidth(width);
      expect(find.byType(NavigationBar), size == WindowSize.compact ? findsOneWidget : findsNothing);
      expect(find.byType(NavigationRail), size == WindowSize.compact ? findsNothing : findsOneWidget);
      // The detail pane sits beside the list from 840 px.
      expect(find.byType(TabBar), size == WindowSize.expanded ? findsOneWidget : findsNothing);
    });
  }
}
