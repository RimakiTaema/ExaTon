import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:exaton/core/exaroton/models.dart';
import 'package:exaton/core/modrinth/modrinth.dart';
import 'package:exaton/core/storage/database.dart';
import 'package:exaton/features/addons/addons.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_api.dart';
import 'support/fake_modrinth.dart';

ServerSoftware sw(String name, String version, {String type = '', List<String>? addons}) =>
    ServerSoftware(id: 'x', name: name, version: version, type: type, addons: addons);

Map<String, Object?> version(
  String id,
  String project,
  String file, {
  String sha1 = 'aaa',
  List<Map<String, Object?>> deps = const [],
}) => {
  'id': id,
  'project_id': project,
  'name': '$project $id',
  'version_number': id,
  'files': [
    {
      'url': 'https://cdn.modrinth.com/data/$project/versions/$id/$file',
      'filename': file,
      'primary': true,
      'size': 3,
      'hashes': {'sha1': sha1},
    },
  ],
  'dependencies': deps,
  'game_versions': ['1.21'],
  'loaders': ['fabric'],
};

void main() {
  group('addon target', () {
    test('picks the folder and loaders from the software', () {
      final paper = addonTargetFor(sw('Paper', '1.21', type: 'paper', addons: ['plugin']))!;
      expect(paper.kind, AddonKind.plugin);
      expect(paper.folder, 'plugins');
      expect(paper.loaders, ['paper', 'spigot', 'bukkit']);
      expect(paper.gameVersion, '1.21');

      final neo = addonTargetFor(sw('NeoForge', '1.21.1', type: 'neoforge', addons: ['mod']))!;
      expect(neo.loaders, ['neoforge'], reason: 'not matched as plain forge');
      expect(neo.folder, 'mods');

      expect(addonTargetFor(sw('Velocity', '3.3.0', type: 'velocity'))!.kind, AddonKind.proxyPlugin);
      expect(addonTargetFor(sw('Vanilla', '1.21', type: 'vanilla', addons: [])), isNull);
      expect(addonTargetFor(sw('Bedrock', '1.21', type: 'bedrock')), isNull);
      expect(addonTargetFor(null), isNull);
    });

    test('a modpack names no loader or Minecraft version', () {
      final pack = addonTargetFor(sw('All the Mods 9', '0.2.60', type: 'modpack', addons: ['mod']))!;
      expect(pack.kind, AddonKind.mod);
      expect(pack.loaders, isEmpty);
      expect(pack.gameVersion, isNull);
    });

    test('search facets OR the loaders and filter by version', () {
      final t = addonTargetFor(sw('Fabric', '1.21', type: 'fabric', addons: ['mod']))!;
      expect(jsonDecode(searchFacets(t)), [
        ['project_type:mod', 'project_type:plugin'],
        ['categories:fabric'],
        ['versions:1.21'],
      ]);
      expect(jsonDecode(searchFacets(t, anyVersion: true)), hasLength(2));
    });
  });

  group('installer', () {
    late AppDatabase db;
    late FakeAdapter exaroton;
    late FakeModrinth modrinth;
    late AddonInstaller installer;
    final target = addonTargetFor(sw('Fabric', '1.21', type: 'fabric', addons: ['mod']))!;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      exaroton = FakeAdapter({
        'PUT /servers/abc/files/data/mods/sodium.jar/': (200, ok(null)),
        'PUT /servers/abc/files/data/mods/fabric-api.jar/': (200, ok(null)),
        'PUT /servers/abc/files/data/mods/sodium-2.jar/': (200, ok(null)),
        'DELETE /servers/abc/files/data/mods/sodium.jar/': (200, ok(null)),
      });
      modrinth = FakeModrinth({
        'GET /project/sodium/version': (
          200,
          [
            version(
              'v1',
              'sodium',
              'sodium.jar',
              deps: [
                {'project_id': 'fabric-api', 'version_id': null, 'dependency_type': 'required'},
                {'project_id': 'iris', 'version_id': null, 'dependency_type': 'optional'},
              ],
            ),
          ],
        ),
        'GET /project/fabric-api/version': (200, [version('f1', 'fabric-api', 'fabric-api.jar', sha1: 'fff')]),
        'GET https://cdn.modrinth.com/data/sodium/versions/v1/sodium.jar': (200, Uint8List.fromList([1, 2, 3])),
        'GET https://cdn.modrinth.com/data/fabric-api/versions/f1/fabric-api.jar': (200, Uint8List.fromList([4])),
        'GET https://cdn.modrinth.com/data/sodium/versions/v2/sodium-2.jar': (200, Uint8List.fromList([5])),
        'POST /version_files/update': (200, {'aaa': version('v2', 'sodium', 'sodium-2.jar', sha1: 'bbb')}),
      });
      installer = AddonInstaller(
        exaroton: fakeClient(exaroton),
        modrinth: fakeModrinth(modrinth),
        db: db,
        serverId: 'abc',
      );
    });

    tearDown(() => db.close());

    test('installs required dependencies first and records both', () async {
      final v = (await installer.bestVersion('sodium', target))!;
      final plan = await installer.plan(v, target);
      expect(plan.map((p) => p.projectId), ['fabric-api', 'sodium'], reason: 'optional iris is skipped');

      await installer.install(plan, target);
      final puts = exaroton.requests.where((r) => r.method == 'PUT').map((r) => r.uri.path).toList();
      expect(puts, ['/v1/servers/abc/files/data/mods/fabric-api.jar/', '/v1/servers/abc/files/data/mods/sodium.jar/']);
      final versionReq = modrinth.requests.firstWhere((r) => r.uri.path.endsWith('/sodium/version'));
      expect(versionReq.uri.queryParameters['loaders'], '["fabric"]');
      expect(versionReq.uri.queryParameters['game_versions'], '["1.21"]');

      final saved = await installer.installed();
      expect(saved.keys, unorderedEquals(['mods/fabric-api.jar', 'mods/sodium.jar']));
      expect(saved['mods/sodium.jar']!.sha1, 'aaa');

      // Already installed: a second plan does not pull fabric-api again.
      expect((await installer.plan(v, target)).map((p) => p.projectId), ['sodium']);
    });

    test('finds an update by hash and replaces the old file', () async {
      final v = (await installer.bestVersion('sodium', target))!;
      await installer.install([v], target);
      final updates = await installer.findUpdates(target);
      expect(updates.keys, ['mods/sodium.jar']);
      expect(updates['mods/sodium.jar']!.versionNumber, 'v2');

      await installer.update('mods/sodium.jar', updates['mods/sodium.jar']!, target);
      expect(exaroton.requests.any((r) => r.method == 'DELETE' && r.uri.path.endsWith('/mods/sodium.jar/')), isTrue);
      final saved = await installer.installed();
      expect(saved.keys, ['mods/sodium-2.jar']);
      expect(saved['mods/sodium-2.jar']!.versionId, 'v2');
    });

    test('forgets files deleted elsewhere', () async {
      final v = (await installer.bestVersion('sodium', target))!;
      await installer.install([v], target);
      await installer.forgetMissing({});
      expect(await installer.installed(), isEmpty);
    });
  });

  test('downloads only from Modrinth hosts', () async {
    final c = fakeModrinth(FakeModrinth({}));
    await expectLater(
      c.download(const ModrinthFile(url: 'https://evil.example/x.jar', filename: 'x.jar', primary: true)),
      throwsA(isA<ModrinthException>()),
    );
  });
}
