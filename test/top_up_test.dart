import 'package:drift/native.dart';
import 'package:exaton/core/storage/account_store.dart';
import 'package:exaton/core/storage/database.dart';
import 'package:exaton/features/accounts/accounts.dart';
import 'package:exaton/features/console/live_session.dart';
import 'package:exaton/features/credits/top_up.dart';
import 'package:exaton/features/settings/settings.dart';
import 'package:exaton/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'migration_test.dart' show settle;
import 'support/fake_api.dart';
import 'widget_test.dart' show FakeAccountStore, SilentChannel;

void main() {
  test('top-up targets point at exaroton', () {
    expect(const TopUpTarget.account().resolved.toString(), 'https://exaroton.com/buy/');
    expect(const TopUpTarget.pool('Friends').resolved.toString(), 'https://exaroton.com/pools/');
    expect(const TopUpTarget.pool('Friends').title, 'Deposit to Friends');
  });

  late List<TopUpTarget> opened;

  Future<AppDatabase> pump(WidgetTester tester, Size size) async {
    opened = [];
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
          topUpLauncherProvider.overrideWithValue((context, target) async => opened.add(target)),
        ],
        child: const ExaTonApp(),
      ),
    );
    await settle(tester);
    return db;
  }

  testWidgets('server list credit card has a top-up button', (tester) async {
    await pump(tester, const Size(390, 844));
    // A labeled button, not an icon (UX review P1 #10).
    await tester.tap(find.text('Top up'));
    await tester.pump();
    expect(opened.single.poolName, isNull);
    expect(opened.single.resolved, topUpAccountUrl);
  });

  testWidgets('credits screen: Top up opens the account page', (tester) async {
    await pump(tester, const Size(390, 844));
    await tester.tap(find.text('Credits').last);
    await settle(tester);
    await tester.tap(find.text('Top up'));
    await tester.pump();
    expect(opened.single.resolved, topUpAccountUrl);
  });

  testWidgets('pool detail: Deposit opens the pool page', (tester) async {
    await pump(tester, const Size(390, 844));
    await tester.tap(find.text('Credits').last);
    await settle(tester);
    await tester.scrollUntilVisible(find.text('Friends SMP pool'), 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Friends SMP pool'));
    await settle(tester);
    await tester.tap(find.text('Deposit'));
    await tester.pump();
    expect(opened.single.poolName, 'Friends SMP pool');
    expect(opened.single.resolved, topUpPoolsUrl);
  });

  testWidgets('desktop list pane has a top-up button', (tester) async {
    await pump(tester, const Size(1440, 900));
    expect(find.text('Top up'), findsOneWidget);
  });
}
