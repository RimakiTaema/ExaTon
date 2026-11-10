// Checks for the spec's "UX review changes" that are behaviour rather than
// layout or colour (those are in layout_test.dart and theme_test.dart).
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:exaton/core/exaroton/models.dart';
import 'package:exaton/core/storage/account_store.dart';
import 'package:exaton/core/storage/database.dart';
import 'package:exaton/features/accounts/accounts.dart';
import 'package:exaton/features/console/live_session.dart';
import 'package:exaton/features/credits/alerts.dart';
import 'package:exaton/features/credits/credits.dart';
import 'package:exaton/features/credits/estimate.dart';
import 'package:exaton/features/credits/top_up.dart';
import 'package:exaton/features/settings/settings.dart';
import 'package:exaton/main.dart';
import 'package:exaton/ui/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'migration_test.dart' show settle;
import 'support/fake_api.dart';
import 'widget_test.dart' show FakeAccountStore, SilentChannel;

/// Holds GET /servers/ until [release] is called, to see the loading state.
class GatedAdapter extends FakeAdapter {
  GatedAdapter(super.routes);
  final _gate = Completer<void>();
  void release() => _gate.complete();

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? s, Future<void>? c) async {
    if (o.uri.path.endsWith('/servers/')) await _gate.future;
    return super.fetch(o, s, c);
  }
}

Map<String, Object?> serversWith({required int players}) {
  final j = jsonDecode(jsonEncode(fixture('servers'))) as Map<String, dynamic>;
  (j['data'] as List)[0]['players']['count'] = players;
  return j;
}

Future<AppDatabase> pump(WidgetTester tester, FakeAdapter api, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
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
  await settle(tester);
  return db;
}

bool sentStop(FakeAdapter api) => api.requests.any((r) => r.uri.path.endsWith('/stop/'));

void main() {
  group('P0 #2: Stop asks when players are online', () {
    testWidgets('4 players: confirmation names the count; Cancel sends nothing', (tester) async {
      final api = FakeAdapter({
        ...standardRoutes(),
        'GET /servers/': (200, serversWith(players: 4)),
        'GET /servers/Srv0000000000001/stop/': (200, ok(null)),
      });
      await pump(tester, api);
      await tester.tap(find.text('Stop'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Stop Survival SMP?'), findsOneWidget);
      expect(find.text('4 players are online and will be disconnected.'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(sentStop(api), isFalse);

      await tester.tap(find.text('Stop'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Stop server'));
      await settle(tester, rounds: 6);
      expect(sentStop(api), isTrue);
    });

    testWidgets('nobody online: stops at once', (tester) async {
      final api = FakeAdapter({
        ...standardRoutes(),
        'GET /servers/': (200, serversWith(players: 0)),
        'GET /servers/Srv0000000000001/stop/': (200, ok(null)),
      });
      await pump(tester, api);
      await tester.tap(find.text('Stop'));
      await settle(tester, rounds: 6);
      expect(find.text('Stop Survival SMP?'), findsNothing);
      expect(sentStop(api), isTrue);
    });
  });

  test('P0 #5: Google sign-in leaves the webview', () {
    expect(mustOpenInBrowser(Uri.parse('https://accounts.google.com/o/oauth2/auth?x=1')), isTrue);
    expect(mustOpenInBrowser(Uri.parse('https://exaroton.com/go/')), isFalse);
    expect(mustOpenInBrowser(Uri.parse('https://www.paypal.com/checkout')), isFalse);
  });

  test('P1 #9: muting one pool does not stop alerts for another', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    PayerSummary low(String id) => PayerSummary(
      poolId: id,
      name: id,
      credits: 10,
      estimate: const Estimate(method: EstimateMethod.runningServers, creditsPerHour: 1, timeLeft: Duration(hours: 10)),
      low: true,
    );
    final overview = CreditsOverview(
      account: const Account(name: 'Main', email: '', verified: true, credits: 1000),
      accountSummary: const PayerSummary(poolId: null, name: 'Main', credits: 1000, estimate: null, low: false),
      pools: const [],
      poolSummaries: {'A': low('A'), 'B': low('B')},
      payerOf: const {},
      running: const [],
      updated: DateTime(2026),
    );
    await CreditAlerts.instance.evaluate(overview, const AppSettings(mutedPools: {'A'}), db, 'acc1');
    final state = await db.readJson('alerts.acc1');
    expect(state?['B'], isTrue, reason: 'B still alerts');
    expect(state?.containsKey('A'), isFalse, reason: 'A is muted');
  });

  testWidgets('P1 #11: failed refresh keeps data and says so; clears on success', (tester) async {
    final api = FakeAdapter(standardRoutes());
    await pump(tester, api);
    expect(find.textContaining('Updated '), findsOneWidget);

    api.routes['GET /servers/'] = (503, apiError('Service unavailable'));
    await tester.tap(find.byTooltip('Refresh'));
    await settle(tester, rounds: 8);
    expect(find.textContaining("Can't reach exaroton. Showing data from"), findsOneWidget);
    expect(find.text('Survival SMP'), findsOneWidget, reason: 'old data stays');

    api.routes['GET /servers/'] = (200, fixture('servers'));
    await tester.tap(find.text('Retry'));
    await settle(tester, rounds: 8);
    expect(find.textContaining("Can't reach exaroton"), findsNothing);
  });

  testWidgets('P1 #12: skeletons while the list loads, then the list', (tester) async {
    final api = GatedAdapter(standardRoutes());
    await pump(tester, api);
    expect(find.byType(Skeleton), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing, reason: 'no centered spinner');
    api.release();
    await settle(tester, rounds: 10);
    expect(find.text('Survival SMP'), findsOneWidget);
  });

  testWidgets('P1 #14: shortcut label is ⌘ K on macOS', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await pump(tester, FakeAdapter(standardRoutes()), size: const Size(1440, 900));
      expect(find.text('⌘ K'), findsOneWidget);
      expect(find.text('Ctrl K'), findsNothing);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('P1 #14: shortcut label is Ctrl K elsewhere', (tester) async {
    await pump(tester, FakeAdapter(standardRoutes()), size: const Size(1440, 900));
    expect(find.text('Ctrl K'), findsOneWidget);
  });

  testWidgets('P1 #16: an empty account explains what to do', (tester) async {
    await pump(tester, FakeAdapter({...standardRoutes(), 'GET /servers/': (200, ok(<Object>[]))}));
    expect(find.text('No servers yet'), findsOneWidget);
    expect(find.text('Create on exaroton'), findsOneWidget);
  });

  testWidgets('P1 #16: a revoked token offers to sign in again', (tester) async {
    await pump(tester, FakeAdapter({...standardRoutes(), 'GET /servers/': (401, apiError('Invalid API token'))}));
    expect(find.text('Sign-in expired'), findsOneWidget);
    expect(find.text('Sign in again'), findsOneWidget);
    expect(find.textContaining('Details: HTTP 401'), findsOneWidget);
  });

  test('copy rules: errors never show raw exceptions in the main text', () {
    final info = describeError(StateError('boom'));
    expect(info.body, isNot(contains('StateError')));
    expect(info.details, contains('boom'));
  });

  test('P2 #17, #18: no raw colours or Material icons outside the theme files', () {
    const allowed = {'lib/ui/tokens.dart', 'lib/ui/theme.dart', 'lib/ui/app_icons.dart'};
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      final path = f.path.replaceAll(r'\', '/');
      if (!path.endsWith('.dart') || allowed.contains(path)) continue;
      final src = f.readAsStringSync();
      if (RegExp(r'\bColors\.').hasMatch(src)) offenders.add('$path uses Colors.*');
      if (RegExp(r'\bIcons\.').hasMatch(src)) offenders.add('$path uses Icons.*');
    }
    expect(offenders, isEmpty);
  });

  test('server status: code 7 is "Crashed"', () {
    expect(ServerStatus.fromCode(7).label, 'Crashed');
  });
}
