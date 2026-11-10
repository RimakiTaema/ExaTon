import 'dart:convert';
import 'dart:typed_data';

import 'package:exaton/core/exaroton/models.dart';
import 'package:exaton/features/servers/server_icon.dart';
import 'package:exaton/ui/app_icons.dart';
import 'package:exaton/ui/theme.dart';
import 'package:exaton/features/accounts/accounts.dart';
import 'package:exaton/core/storage/account_store.dart';
import 'package:exaton/features/servers/servers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_api.dart';

/// A real 1x1 PNG, so the image decodes.
final png = Uint8List.fromList(
  base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='),
);

class _Store extends AccountStore {
  @override
  Future<List<StoredAccount>> load() async => const [StoredAccount(id: 'acc1', name: 'Main', token: 't')];
  @override
  Future<String?> activeId() async => 'acc1';
}

Server server(String id, String software, {bool shared = false, List<String>? permissions}) => Server.fromJson({
  'id': id,
  'name': 'Survival',
  'address': 's.exaroton.me',
  'status': 0,
  'players': {'max': 20, 'count': 0},
  'software': {'id': 'sw', 'name': software, 'version': '1.21', 'type': software.toLowerCase()},
  'shared': shared,
  'permissions': permissions,
});

void main() {
  test('recognises image files by their first bytes', () {
    expect(looksLikeImage(png), isTrue);
    expect(looksLikeImage([0xFF, 0xD8, 0xFF, 0xE0]), isTrue);
    expect(looksLikeImage(utf8.encode('GIF89a')), isTrue);
    expect(looksLikeImage(utf8.encode('RIFF....WEBP')), isTrue);
    expect(looksLikeImage(utf8.encode('<html>not found</html>')), isFalse);
    expect(looksLikeImage(const []), isFalse);
  });

  group('loadServerIcon', () {
    test('uses server-icon.png when the server has it', () async {
      final api = FakeAdapter({'GET /servers/abc/files/data/server-icon.png/': (200, png)});
      expect(await loadServerIcon(fakeClient(api), 'abc'), png);
      expect(api.requests, hasLength(1));
    });

    test('falls back to icon.png, which the game itself ignores', () async {
      final api = FakeAdapter({'GET /servers/abc/files/data/icon.png/': (200, png)});
      expect(await loadServerIcon(fakeClient(api), 'abc'), png);
      expect(api.requests.map((r) => r.uri.path), [
        '/v1/servers/abc/files/data/server-icon.png/',
        '/v1/servers/abc/files/data/icon.png/',
      ]);
    });

    test('no file, no access or a file that is not an image all mean no icon', () async {
      expect(await loadServerIcon(fakeClient(FakeAdapter({})), 'abc'), isNull);
      final forbidden = FakeAdapter({
        for (final f in serverIconFiles) 'GET /servers/abc/files/data/$f/': (403, fixture('forbidden')),
      });
      expect(await loadServerIcon(fakeClient(forbidden), 'abc'), isNull);
      final text = FakeAdapter({
        'GET /servers/abc/files/data/server-icon.png/': (200, Uint8List.fromList(utf8.encode('hello'))),
      });
      expect(await loadServerIcon(fakeClient(text), 'abc'), isNull);
    });
  });

  group('ServerIcon', () {
    Future<FakeAdapter> pump(WidgetTester tester, Server s, Map<String, (int, Object?)> routes) async {
      final api = FakeAdapter(routes);
      await tester.pumpWidget(
        ProviderScope(
          retry: (_, _) => null,
          overrides: [
            accountStoreProvider.overrideWithValue(_Store()),
            clientFactoryProvider.overrideWithValue((token) => fakeClient(api, token)),
            serversProvider.overrideWith(() => _Servers([s])),
          ],
          child: MaterialApp(
            theme: buildTheme(const ThemeSettings().tokensFor(Brightness.dark), Brightness.dark),
            home: Scaffold(body: Center(child: ServerIcon(s))),
          ),
        ),
      );
      for (var i = 0; i < 8; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
        await tester.pump(const Duration(milliseconds: 50));
      }
      return api;
    }

    testWidgets('shows the server image with the Java badge', (tester) async {
      await pump(tester, server('Srv0000000000001', 'Paper'), {
        'GET /servers/Srv0000000000001/files/data/server-icon.png/': (200, png),
      });
      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(AppIcons.java), findsOneWidget);
      expect(find.text('S'), findsNothing);
    });

    testWidgets('a Java server without an image shows its initial and the Java badge', (tester) async {
      await pump(tester, server('Srv0000000000001', 'Paper'), {});
      expect(find.byType(Image), findsNothing);
      expect(find.text('S'), findsOneWidget);
      expect(find.byIcon(AppIcons.java), findsOneWidget);
    });

    testWidgets('a Bedrock server without an image shows the Bedrock mark once', (tester) async {
      await pump(tester, server('Srv0000000000001', 'Bedrock'), {});
      expect(find.byIcon(AppIcons.bedrock), findsOneWidget);
      expect(find.byIcon(AppIcons.java), findsNothing);
      expect(find.text('S'), findsNothing);
    });

    testWidgets('a Bedrock server with icon.png uses it and keeps the Bedrock badge', (tester) async {
      await pump(tester, server('Srv0000000000001', 'Bedrock'), {
        'GET /servers/Srv0000000000001/files/data/icon.png/': (200, png),
      });
      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(AppIcons.bedrock), findsOneWidget);
    });

    testWidgets('a shared server without file access is not asked for its icon', (tester) async {
      final api = await pump(tester, server('Srv0000000000001', 'Paper', shared: true, permissions: ['console']), {
        'GET /servers/Srv0000000000001/files/data/server-icon.png/': (200, png),
      });
      expect(api.requests, isEmpty);
      expect(find.byType(Image), findsNothing);
      expect(find.text('S'), findsOneWidget);
    });
  });
}

class _Servers extends ServersNotifier {
  _Servers(this.list);
  final List<Server> list;
  @override
  Future<List<Server>> build() async => list;
}
