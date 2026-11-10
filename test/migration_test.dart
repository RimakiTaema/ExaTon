import 'package:drift/native.dart';
import 'package:exaton/core/storage/account_store.dart';
import 'package:exaton/core/storage/database.dart';
import 'package:exaton/features/accounts/accounts.dart';
import 'package:exaton/features/accounts/migration.dart';
import 'package:exaton/features/console/live_session.dart';
import 'package:exaton/features/settings/settings.dart';
import 'package:exaton/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_api.dart';
import 'widget_test.dart' show SilentChannel;

/// In-memory store so imports can be checked.
class MemoryAccountStore extends AccountStore {
  final accounts = <StoredAccount>[];
  String? active;
  var _n = 0;

  @override
  Future<List<StoredAccount>> load() async => List.of(accounts);
  @override
  Future<StoredAccount> add(String name, String token) async {
    final a = StoredAccount(id: 'id${_n++}', name: name, token: token);
    accounts.add(a);
    return a;
  }

  @override
  Future<String?> activeId() async => active;
  @override
  Future<void> setActive(String id) async => active = id;
}

class FakeLegacySource extends LegacyTokenSource {
  FakeLegacySource(this.found);
  final List<LegacyAccount> found;
  @override
  Future<List<LegacyAccount>> find() async => found;
}

void main() {
  late AppDatabase db;
  late MemoryAccountStore store;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    store = MemoryAccountStore();
  });
  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester, List<LegacyAccount> legacy) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final api = FakeAdapter({
      ...standardRoutes(),
      // The second 1.5 token was revoked.
      'GET /account/': (200, fixture('account')),
    });
    final bad = FakeAdapter({'GET /account/': (401, apiError('Invalid API token'))});
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          databaseProvider.overrideWithValue(db),
          initialSettingsProvider.overrideWithValue(const AppSettings(alertsEnabled: false)),
          accountStoreProvider.overrideWithValue(store),
          legacyTokenSourceProvider.overrideWithValue(FakeLegacySource(legacy)),
          clientFactoryProvider.overrideWithValue((token) => fakeClient(token == 'revoked' ? bad : api, token)),
          socketConnectorProvider.overrideWithValue((uri, headers) => SilentChannel()),
        ],
        child: const ExaTonApp(),
      ),
    );
    await settle(tester);
  }

  testWidgets('offers 1.5 logins on first launch and imports the chosen ones', (tester) async {
    await pump(tester, const [
      LegacyAccount(email: 'main@example.com', token: 'good'),
      LegacyAccount(email: 'old@example.com', token: 'revoked'),
    ]);

    expect(find.text('Bring your accounts from ExaTon 1.5'), findsOneWidget);
    expect(find.text('main@example.com'), findsOneWidget);
    expect(find.text('old@example.com'), findsOneWidget);
    expect(find.text('Import 2 accounts'), findsOneWidget);

    await tester.tap(find.text('Import 2 accounts'));
    await settle(tester);

    expect(store.accounts.map((a) => a.token), ['good'], reason: 'revoked token is not saved');
    expect(store.active, store.accounts.single.id);
    expect(find.text('Token no longer valid'), findsOneWidget);
    expect(find.textContaining('1 imported, 1 could not'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await settle(tester);
    expect(find.text('Servers'), findsWidgets);
    expect(find.text('Bring your accounts from ExaTon 1.5'), findsNothing);
    expect((await db.readJson('migration'))?['answered'], isTrue);
  });

  testWidgets('unchecking an account skips it', (tester) async {
    await pump(tester, const [
      LegacyAccount(email: 'main@example.com', token: 'good'),
      LegacyAccount(email: 'old@example.com', token: 'revoked'),
    ]);
    await tester.tap(find.text('old@example.com'));
    await tester.pump();
    expect(find.text('Import 1 account'), findsOneWidget);
    await tester.tap(find.text('Import 1 account'));
    await settle(tester, rounds: 40);
    expect(store.accounts.map((a) => a.token), ['good']);
    // All selected imports worked, so it moves on by itself.
    expect(find.text('Bring your accounts from ExaTon 1.5'), findsNothing);
  });

  testWidgets('"Not now" goes to sign-in and is not asked again', (tester) async {
    await pump(tester, const [LegacyAccount(email: 'main@example.com', token: 'good')]);
    await tester.tap(find.text('Not now, start fresh'));
    await settle(tester);
    expect(find.text('Welcome to ExaTon'), findsOneWidget);
    expect(store.accounts, isEmpty);
    expect((await db.readJson('migration'))?['answered'], isTrue);
  });

  testWidgets('nothing found: straight to sign-in', (tester) async {
    await pump(tester, const []);
    expect(find.text('Welcome to ExaTon'), findsOneWidget);
    expect(find.text('Bring your accounts from ExaTon 1.5'), findsNothing);
  });

  testWidgets('already imported tokens are not offered again', (tester) async {
    store.accounts.add(const StoredAccount(id: 'x', name: 'Main', token: 'good'));
    store.active = 'x';
    await pump(tester, const [LegacyAccount(email: 'main@example.com', token: 'good')]);
    expect(find.text('Bring your accounts from ExaTon 1.5'), findsNothing);
    expect(find.text('Survival SMP'), findsOneWidget);
  });
}

Future<void> settle(WidgetTester tester, {int rounds = 25}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump(const Duration(milliseconds: 60));
  }
}
